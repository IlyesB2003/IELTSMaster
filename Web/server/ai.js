// AI layer: talks to Ollama on this Mac. Every AI score is labelled as an estimate,
// and every endpoint has an honest fallback when no model is running.
import { roundOfficialBand, countWords } from './lib.js';

const OLLAMA = process.env.OLLAMA_URL || 'http://127.0.0.1:11434';

export async function listModels() {
  try {
    const r = await fetch(`${OLLAMA}/api/tags`, { signal: AbortSignal.timeout(3000) });
    if (!r.ok) return [];
    const j = await r.json();
    return (j.models || []).map((m) => ({ name: m.name, sizeGB: +(m.size / 1e9).toFixed(1) }));
  } catch { return []; }
}

/** Preferred model: configured one if installed, else a 7–9B instruct model, else the first installed. */
export async function pickModel(config) {
  const models = await listModels();
  if (!models.length) return null;
  if (config?.model && models.some((m) => m.name === config.model)) return config.model;
  const pref = models.find((m) => /qwen2\.5|llama3|gemma|mistral/i.test(m.name) && m.sizeGB < 10);
  return (pref || models[0]).name;
}

export async function chatJSON(model, system, user, timeoutMs = 180000) {
  const r = await fetch(`${OLLAMA}/api/chat`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ model, stream: false, format: 'json', options: { temperature: 0.2 }, messages: [{ role: 'system', content: system }, { role: 'user', content: user }] }),
    signal: AbortSignal.timeout(timeoutMs),
  });
  if (!r.ok) throw new Error(`Ollama returned ${r.status}`);
  const j = await r.json();
  const text = j.message?.content ?? '';
  const start = text.indexOf('{'), end = text.lastIndexOf('}');
  return JSON.parse(text.slice(start, end + 1));
}

/** Streams a chat reply from Ollama, calling onToken for each piece of text. */
export async function chatStream(model, messages, onToken, signal) {
  const r = await fetch(`${OLLAMA}/api/chat`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ model, stream: true, options: { temperature: 0.4 }, messages }),
    signal,
  });
  if (!r.ok || !r.body) throw new Error(`Ollama returned ${r.status}`);
  const decoder = new TextDecoder();
  let buf = '', full = '';
  for await (const chunk of r.body) {
    buf += decoder.decode(chunk, { stream: true });
    let i;
    while ((i = buf.indexOf('\n')) >= 0) {
      const line = buf.slice(0, i).trim(); buf = buf.slice(i + 1);
      if (!line) continue;
      const j = JSON.parse(line);
      const t = j.message?.content || '';
      if (t) { full += t; onToken(t); }
    }
  }
  return full;
}

const halfBand = (x) => roundOfficialBand(Number(x) || 0);

// ---------------------------------------------------------------- writing

const WRITING_SYSTEM = (task, words) => `You are an IELTS Academic Writing rubric evaluator. Use only the public IELTS Writing band descriptors.
You are not an official examiner; your scores are estimates. Task ${task} (minimum ${task === 1 ? 150 : 250} words; this response has ${words}).
Under-length responses lose marks for Task ${task === 1 ? 'Achievement' : 'Response'}.
Return JSON: {"taskAchievement": n, "coherenceCohesion": n, "lexicalResource": n, "grammaticalRange": n,
"summary": "2-3 sentences", "strengths": ["..."], "improvements": ["specific, teachable points"],
"corrections": [{"original": "exact sentence from the response", "corrected": "...", "why": "the rule"}],
"vocabularyUpgrades": ["plain word -> academic alternative (with example)"]}
Scores are 0-9 in steps of 0.5. Give 3-6 corrections quoting the learner's own sentences. Teach why each error happens; do not rewrite the whole text.`;

export async function evaluateWriting({ model, task, prompt, text }) {
  const words = countWords(text);
  if (!words) return { band: 0, criteria: null, words, aiUsed: false, summary: 'No response was written, so this task scores 0, as in the real test.' };
  if (model) {
    try {
      const j = await chatJSON(model, WRITING_SYSTEM(task, words), `Task prompt:\n${prompt}\n\nCandidate response:\n${text}`);
      const c = [j.taskAchievement, j.coherenceCohesion, j.lexicalResource, j.grammaticalRange].map(halfBand);
      return {
        band: roundOfficialBand(c.reduce((s, x) => s + x, 0) / 4), words, aiUsed: true, model,
        criteria: { taskAchievement: c[0], coherenceCohesion: c[1], lexicalResource: c[2], grammaticalRange: c[3] },
        summary: j.summary || '', strengths: j.strengths || [], improvements: j.improvements || [],
        corrections: (j.corrections || []).slice(0, 8), vocabularyUpgrades: j.vocabularyUpgrades || [],
      };
    } catch (e) { /* fall through to the offline estimate */ }
  }
  return offlineWriting(task, text, words);
}

/** Rough, clearly-labelled estimate from measurable features when no model is available. */
function offlineWriting(task, text, words) {
  const min = task === 1 ? 150 : 250;
  const paragraphs = text.split(/\n\s*\n|\n/).filter((p) => p.trim()).length;
  const sentences = text.split(/[.!?]+/).filter((s) => s.trim()).length || 1;
  const tokens = text.toLowerCase().match(/[a-z']+/g) || [];
  const diversity = new Set(tokens).size / Math.max(1, tokens.length);
  const linkers = ['however', 'moreover', 'furthermore', 'therefore', 'whereas', 'although', 'in contrast', 'overall', 'consequently', 'for example', 'in addition', 'on the other hand'];
  const linkCount = linkers.filter((l) => text.toLowerCase().includes(l)).length;
  let ta = words >= min ? 6 : words >= min * 0.7 ? 5 : 4;
  let cc = 4.5 + Math.min(1.5, paragraphs >= (task === 1 ? 3 : 4) ? 1 : 0.5) + Math.min(1, linkCount * 0.25);
  let lr = 4.5 + Math.min(2, Math.max(0, (diversity - 0.4) * 6));
  const avgLen = words / sentences;
  let gr = 5 + (avgLen > 14 && avgLen < 28 ? 1 : 0);
  const cap = words < min * 0.5 ? 4.5 : words < min ? 5.5 : 7; // short texts can't show range
  const c = [ta, cc, lr, gr].map((x) => halfBand(Math.min(cap, x)));
  return {
    band: roundOfficialBand(c.reduce((s, x) => s + x, 0) / 4), words, aiUsed: false,
    criteria: { taskAchievement: c[0], coherenceCohesion: c[1], lexicalResource: c[2], grammaticalRange: c[3] },
    summary: 'No AI model was reachable, so this is a low-confidence estimate from measurable features (length, paragraphing, linking words, vocabulary variety, sentence length). Start Ollama on the Mac for a full rubric evaluation with corrections.',
    strengths: [], improvements: words < min ? [`Write at least ${min} words: short answers are penalised.`] : [], corrections: [], vocabularyUpgrades: [],
  };
}

// ---------------------------------------------------------------- speaking

const FILLERS = ['um', 'uh', 'er', 'erm', 'like', 'you know', 'i mean', 'sort of', 'kind of'];

export function speakingMetrics(transcript, seconds) {
  const tokens = (transcript.toLowerCase().match(/[a-z']+/g) || []);
  const minutes = Math.max(seconds / 60, 0.05);
  const fillers = FILLERS.reduce((n, f) => n + (transcript.toLowerCase().match(new RegExp(`\\b${f}\\b`, 'g')) || []).length, 0);
  return {
    words: tokens.length, wpm: Math.round(tokens.length / minutes), fillers,
    diversity: +(new Set(tokens).size / Math.max(1, tokens.length)).toFixed(2), seconds: Math.round(seconds),
  };
}

export async function evaluateSpeaking({ model, transcript, seconds, questions }) {
  const m = speakingMetrics(transcript, seconds);
  const pronunciationNote = 'Pronunciation is not scored: the browser gives a text transcript, and pronunciation cannot be judged fairly from text. A non-native accent is never penalised.';
  if (!m.words) return { band: null, metrics: m, aiUsed: false, pronunciationNote, summary: 'No speech was captured. Check that the microphone is allowed for this site.' };
  if (model) {
    try {
      const j = await chatJSON(model, `You are an IELTS Speaking rubric evaluator using the public band descriptors. Scores are estimates, not official.
Judge only Fluency & Coherence, Lexical Resource and Grammatical Range & Accuracy from the transcript and the metrics. Do NOT score pronunciation.
Return JSON: {"fluencyCoherence": n, "lexicalResource": n, "grammaticalRange": n, "summary": "...", "strengths": ["..."], "improvements": ["..."], "betterPhrases": ["what they said -> a more natural/academic way"]}`,
        `Questions asked:\n${questions.join('\n')}\n\nMetrics: ${JSON.stringify(m)}\n\nTranscript:\n${transcript}`);
      const c = [j.fluencyCoherence, j.lexicalResource, j.grammaticalRange].map(halfBand);
      return {
        band: roundOfficialBand(c.reduce((s, x) => s + x, 0) / 3), metrics: m, aiUsed: true, model, pronunciationNote,
        criteria: { fluencyCoherence: c[0], lexicalResource: c[1], grammaticalRange: c[2], pronunciation: null },
        summary: j.summary || '', strengths: j.strengths || [], improvements: j.improvements || [], betterPhrases: j.betterPhrases || [],
      };
    } catch { /* fall through */ }
  }
  return {
    band: null, metrics: m, aiUsed: false, pronunciationNote,
    summary: 'No AI model was reachable, so no Speaking band is given. Your transcript and fluency measures are saved; start Ollama on the Mac for a rubric evaluation.',
    strengths: [], improvements: m.fillers > 5 ? ['Reduce filler words (um, like, you know): pause silently instead.'] : [],
  };
}

// ---------------------------------------------------------------- local RAG retrieval & teacher

const STOPWORDS = new Set(['the', 'and', 'for', 'with', 'that', 'this', 'from', 'have', 'your', 'into', 'about', 'what', 'when', 'where', 'which', 'how', 'can', 'are', 'was', 'were', 'been', 'will']);

export function retrieveKnowledge(docs, query, topK = 2) {
  if (!Array.isArray(docs) || !docs.length || !query) return [];
  const qTokens = [...new Set((String(query).toLowerCase().match(/[a-z0-9]{3,}/g) || []).filter((t) => !STOPWORDS.has(t)))];
  if (!qTokens.length) return [];
  return docs.map((d) => {
    const hay = `${d.title} ${d.category} ${d.module} ${d.content}`.toLowerCase();
    let score = 0;
    for (const t of qTokens) {
      if (d.title.toLowerCase().includes(t)) score += 3;
      if (hay.includes(t)) score += 1;
    }
    return { doc: d, score };
  })
    .filter((x) => x.score >= 2)
    .sort((a, b) => b.score - a.score)
    .slice(0, topK)
    .map((x) => x.doc);
}

export function teacherSystemPrompt({ name, targetBand, bands, attempts, weak, mistakes, grammarWeak, vocabStats, ragDocs, arabic }) {
  const mistakeLines = mistakes.slice(0, 15).map((m) =>
    `- [${m.module} · ${m.skillTitle}] Q: "${m.prompt}" | learner: "${m.response}" | correct: "${m.answer}" | seen ${m.count}×`).join('\n');
  const attemptLines = (attempts || []).slice(-6).reverse().map((a) =>
    `- ${a.title} (${a.type}${a.module ? '/' + a.module : ''}): ${a.type === 'practice' ? `${a.raw}/${a.total}` : `Band ${a.headline ?? a.writing ?? a.speaking ?? a.listening ?? a.reading ?? '—'}`}`).join('\n');
  const bandLine = bands
    ? `Listening ${bands.listening ?? '—'}, Reading ${bands.reading ?? '—'}, Writing ${bands.writing ?? '—'}, Speaking ${bands.speaking ?? '—'}, Overall ${bands.overall ?? bands.partial ?? '—'}`
    : 'not yet measured';
  const ragBlock = (ragDocs && ragDocs.length)
    ? ragDocs.map((d, i) => `[Ref ${i + 1}: ${d.title} — ${d.sourceName}]\n${d.content.slice(0, 900)}`).join('\n\n')
    : '(general IELTS Academic criteria)';
  return `You are ${name}'s personal Band 9 IELTS Academic coach with full persistent memory of everything they have done in IELTS Master. Target band: ${targetBand}.
Teach like an elite IELTS tutor: diagnose the root gap, explain the exact Band 7 → 8 → 9 rule or strategy, show a concrete Band 8.5–9.0 worked example, then check understanding with 2–3 focused questions and wait for answers.
Base your teaching strictly on the learner's real performance data and verified IELTS reference documents below. Name the exact patterns behind repeated mistakes. Be concise, warm and direct.
Never claim to be an official examiner. Never invent IELTS rules; if unsure, say so.
${arabic ? 'After the English explanation, add a clear Arabic explanation (Modern Standard Arabic) labeled "الشرح بالعربية:" of the key rule.' : 'Use English only unless the learner asks for Arabic.'}

Current estimated module bands: ${bandLine}.
Recent activity & exams:
${attemptLines || '(none yet)'}
Weakest skills (measured from real answers): ${weak.length ? weak.map((w) => `${w.title} (${Math.round(w.accuracy * 100)}% in ${w.module})`).join(', ') : 'not enough data yet'}.
Grammar topics needing work: ${(grammarWeak && grammarWeak.length) ? grammarWeak.join(', ') : 'none flagged yet'}.
Vocabulary SM-2 status: ${vocabStats ? `${vocabStats.mastered} mastered, ${vocabStats.due} due for review` : 'not started'}.

Most recent open mistakes:
${mistakeLines || '(none yet)'}

Verified IELTS Reference Context (cite when helpful):
${ragBlock}`;
}
