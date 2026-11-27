// IELTS Master web server. Runs on this Mac; published at https://ielts.agriai.cloud through a Cloudflare tunnel.
// No external packages: Node 18+ built-ins only.
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  Store, Content, hashPassword, verifyPassword, sha256, newToken, newId, parseCookies, normalizeEmail,
  rawToBand, writingBand, roundOfficialBand, grade, recordResults, nextUnit, weaknesses, skillMastery,
  stripExam, stripPassage, stripPart, bandSummary, cefr, sm2Update,
} from './lib.js';
import { pickModel, listModels, evaluateWriting, evaluateSpeaking, chatStream, teacherSystemPrompt, retrieveKnowledge } from './ai.js';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const PORT = Number(process.env.PORT || 8790);
const DATA = process.env.IELTS_DATA || path.join(ROOT, '..', 'data', 'db.json');
const STATIC = path.join(ROOT, '..', 'client', 'dist');
const store = new Store(DATA);
const content = new Content(path.join(ROOT, 'content', 'content.json'));
const COOKIE = 'im_session';
const TEN_YEARS = 10 * 365 * 24 * 3600;

// ---------------------------------------------------------------- helpers

const json = (res, status, body, headers = {}) => {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store', ...headers });
  res.end(JSON.stringify(body));
};

async function readBody(req, limit = 2_000_000) {
  let size = 0; const chunks = [];
  for await (const c of req) { size += c.length; if (size > limit) throw Object.assign(new Error('Request too large'), { status: 413 }); chunks.push(c); }
  if (!chunks.length) return {};
  try { return JSON.parse(Buffer.concat(chunks).toString('utf8')); } catch { throw Object.assign(new Error('Invalid JSON'), { status: 400 }); }
}

function currentUser(req) {
  const token = parseCookies(req.headers.cookie)[COOKIE];
  if (!token) return null;
  const session = store.data.sessions.find((s) => s.tokenHash === sha256(token));
  if (!session) return null;
  const user = store.data.users.find((u) => u.id === session.userId);
  if (!user) return null;
  if (Date.now() - Date.parse(session.lastSeen || 0) > 3600_000) { session.lastSeen = new Date().toISOString(); store.save(); }
  return user;
}

const publicUser = (u) => ({ id: u.id, firstName: u.firstName, lastName: u.lastName, email: u.email, role: u.role, createdAt: u.createdAt });
const isHttps = (req) => req.headers['x-forwarded-proto'] === 'https' || !!req.headers['cf-visitor'];

function sessionCookie(req, token, maxAge = TEN_YEARS) {
  return `${COOKIE}=${token}; Path=/; HttpOnly; SameSite=Lax; Max-Age=${maxAge}${isHttps(req) ? '; Secure' : ''}`;
}

const loginAttempts = new Map();
function rateLimited(ip) {
  const now = Date.now();
  const list = (loginAttempts.get(ip) || []).filter((t) => now - t < 10 * 60_000);
  list.push(now); loginAttempts.set(ip, list);
  return list.length > 10;
}

function summary(user) {
  const p = store.progress(user.id);
  const weak = weaknesses(p.skillEvents).map((w) => ({ ...w, title: content.skillTitle(w.skillTag) }));
  const practicePool = content.practiceUnits;
  const reading = practicePool.filter((u) => u.kind === 'reading');
  const listening = practicePool.filter((u) => u.kind === 'listening');
  const writing = practicePool.filter((u) => u.kind === 'writing');
  const speaking = practicePool.filter((u) => u.kind === 'speaking');

  const formatExamMeta = (e) => {
    const att = p.attempts.filter((a) => a.examId === e.id && a.type === 'full');
    return {
      id: e.id, examNumber: e.examNumber, title: e.title, theme: e.theme, difficulty: e.difficulty, pool: e.pool || 'mock',
      attempts: p.exposure.examAttempts[e.id] || 0,
      best: att.length ? Math.max(...att.map((a) => a.headline ?? 0)) : null,
      writing1: e.writingTask1.visualType, writing2: e.writingTask2.essayType,
    };
  };

  const exams = content.mockExams().map(formatExamMeta);
  const practiceExams = content.practiceExams().map(formatExamMeta);
  const unseenMocks = exams.filter((e) => e.attempts === 0);
  const recommended = unseenMocks.length
    ? unseenMocks[Math.floor(Math.random() * unseenMocks.length)]
    : [...exams].sort((a, b) => a.attempts - b.attempts)[0] || null;

  const vocabAll = content.bundle.vocabulary || [];
  const now = Date.now();
  const dueVocab = vocabAll.filter((v) => {
    const s = p.vocabSM2?.[v.id];
    return !s || Date.parse(s.nextReview) <= now;
  }).length;
  const grammarMastered = Object.values(p.grammar || {}).filter((g) => g.status === 'Mastered').length;

  return {
    user: publicUser(user),
    targetBand: p.targetBand,
    bands: bandSummary(p),
    weak,
    mastery: skillMastery(p.skillEvents).map((m) => ({ ...m, title: content.skillTitle(m.skillTag) })),
    unseen: {
      reading: reading.filter((u) => !p.exposure.seenUnits[u.id]).length, readingTotal: reading.length,
      listening: listening.filter((u) => !p.exposure.seenUnits[u.id]).length, listeningTotal: listening.length,
      writing: writing.filter((u) => !p.exposure.seenUnits[u.id]).length, writingTotal: writing.length,
      speaking: speaking.filter((u) => !p.exposure.seenUnits[u.id]).length, speakingTotal: speaking.length,
    },
    exams, practiceExams, recommended,
    recentAttempts: p.attempts.slice(-20).reverse().map(a => {
      const exam = a.type === 'full' && a.examId ? content.exam(a.examId) : null;
      return exam ? { ...a, title: exam.title } : a;
    }),
    openMistakes: p.mistakes.filter((m) => !m.mastered).length,
    dueVocab,
    grammarMastered,
    grammarTotal: (content.bundle.grammarLessons || []).length,
    planMinutes: p.planMinutes || 45,
    planCompleted: p.planCompleted || {},
    answers: p.skillEvents.length,
  };
}

// ---------------------------------------------------------------- routes

const routes = [];
const route = (method, pattern, handler, { auth = true, admin = false } = {}) =>
  routes.push({ method, pattern: new RegExp(`^${pattern.replace(/:(\w+)/g, '(?<$1>[^/]+)')}$`), handler, auth, admin });

route('POST', '/api/login', async (req, res) => {
  const ip = req.headers['cf-connecting-ip'] || req.socket.remoteAddress;
  if (rateLimited(ip)) return json(res, 429, { error: 'Too many attempts. Wait a few minutes and try again.' });
  const { email, password } = await readBody(req);
  const user = store.data.users.find((u) => u.email === normalizeEmail(email));
  if (!user || !password || !verifyPassword(String(password), user)) return json(res, 401, { error: 'Email or password is incorrect.' });
  const token = newToken();
  store.data.sessions.push({ tokenHash: sha256(token), userId: user.id, createdAt: new Date().toISOString(), lastSeen: new Date().toISOString(), agent: String(req.headers['user-agent'] || '').slice(0, 120) });
  store.save();
  json(res, 200, { user: publicUser(user) }, { 'set-cookie': sessionCookie(req, token) });
}, { auth: false });

route('POST', '/api/logout', async (req, res) => {
  const token = parseCookies(req.headers.cookie)[COOKIE];
  if (token) { store.data.sessions = store.data.sessions.filter((s) => s.tokenHash !== sha256(token)); store.save(); }
  json(res, 200, { ok: true }, { 'set-cookie': sessionCookie(req, '', 0) });
}, { auth: false });

route('GET', '/api/me', async (req, res, { user }) => json(res, 200, summary(user)));

route('POST', '/api/target', async (req, res, { user }) => {
  const { band } = await readBody(req);
  const b = Number(band);
  if (!(b >= 4 && b <= 9) || (b * 2) % 1 !== 0) return json(res, 400, { error: 'Target must be between 4.0 and 9.0 in half bands.' });
  store.progress(user.id).targetBand = b; store.save();
  json(res, 200, summary(user));
});

route('POST', '/api/password', async (req, res, { user }) => {
  const { current, next } = await readBody(req);
  if (!verifyPassword(String(current || ''), user)) return json(res, 400, { error: 'Current password is incorrect.' });
  if (String(next || '').length < 8) return json(res, 400, { error: 'New password must be at least 8 characters.' });
  Object.assign(user, (({ salt, hash }) => ({ salt, passwordHash: hash }))(hashPassword(String(next))));
  const currentTokenHash = sha256(parseCookies(req.headers.cookie)[COOKIE] || '');
  store.data.sessions = store.data.sessions.filter((s) => s.userId !== user.id || s.tokenHash === currentTokenHash);
  store.save(); json(res, 200, { ok: true });
});

route('GET', '/api/lessons', async (req, res) => json(res, 200, { lessons: content.bundle.lessons, skillTitles: content.bundle.skillTitles, skillTitlesArabic: content.bundle.skillTitlesArabic }));

route('GET', '/api/resources', async (req, res) => {
  json(res, 200, {
    sources: content.bundle.sources || [],
    knowledgeDocs: content.bundle.knowledgeDocs || [],
  });
});

route('GET', '/api/curriculum', async (req, res, { user }) => {
  const p = store.progress(user.id);
  json(res, 200, {
    grammarLessons: content.bundle.grammarLessons || [],
    grammarProgress: p.grammar || {},
    vocabulary: (content.bundle.vocabulary || []).map((v) => ({ ...v, sm2: p.vocabSM2?.[v.id] || null })),
    academicUnits: content.bundle.academicUnits || [],
    writingSamples: content.bundle.writingSamples || [],
  });
});

route('POST', '/api/grammar/submit', async (req, res, { user }) => {
  const { lessonId, answers = {} } = await readBody(req);
  const lesson = (content.bundle.grammarLessons || []).find((l) => l.id === lessonId);
  if (!lesson) return json(res, 404, { error: 'Lesson not found.' });
  const p = store.progress(user.id);
  let correct = 0;
  const date = new Date().toISOString();
  const details = lesson.exercises.map((ex) => {
    const picked = answers[ex.id];
    const ok = picked === ex.correctIndex;
    if (ok) correct += 1;
    p.skillEvents.push({ skillTag: lesson.id, module: 'Grammar', itemId: ex.id, correct: ok, date });
    if (!ok) {
      const learnerAns = (picked >= 0 && picked < ex.options.length) ? ex.options[picked] : '(blank)';
      const existing = p.mistakes.find((m) => m.itemId === ex.id);
      if (existing) { existing.count += 1; existing.date = date; existing.response = learnerAns; existing.mastered = false; }
      else p.mistakes.unshift({ id: newId(), itemId: ex.id, module: 'Grammar', source: lesson.title, skillTag: lesson.id, prompt: ex.prompt, response: learnerAns, answer: ex.options[ex.correctIndex], explanation: ex.explanation, count: 1, date, mastered: false });
    }
    return { id: ex.id, correct: ok, correctIndex: ex.correctIndex, explanation: ex.explanation, arabicExplanation: ex.arabicExplanation };
  });
  const prev = p.grammar[lesson.id] || { attempts: 0, correctCount: 0, totalCount: 0, status: 'Needs Work' };
  const attempts = prev.attempts + 1;
  const acc = lesson.exercises.length ? correct / lesson.exercises.length : 0;
  const status = (acc >= 0.85 && attempts >= 2) || (acc === 1 && lesson.exercises.length >= 2) ? 'Mastered' : acc >= 0.7 ? 'Reviewing' : 'Needs Work';
  p.grammar[lesson.id] = { attempts, correctCount: prev.correctCount + correct, totalCount: prev.totalCount + lesson.exercises.length, status, lastPracticedAt: date };
  p.attempts.push({ id: newId(), type: 'practice', module: 'grammar', title: `Grammar: ${lesson.title}`, raw: correct, total: lesson.exercises.length, date });
  store.save();
  json(res, 200, { correct, total: lesson.exercises.length, status, details });
});

route('POST', '/api/vocabulary/review', async (req, res, { user }) => {
  const { wordId, quality } = await readBody(req);
  const p = store.progress(user.id);
  p.vocabSM2[wordId] = sm2Update(p.vocabSM2[wordId], quality);
  store.save();
  json(res, 200, { sm2: p.vocabSM2[wordId] });
});

route('POST', '/api/plan', async (req, res, { user }) => {
  const { minutes, toggleId } = await readBody(req);
  const p = store.progress(user.id);
  if (minutes && [15, 30, 45, 60, 90].includes(Number(minutes))) p.planMinutes = Number(minutes);
  if (toggleId) p.planCompleted[toggleId] = !p.planCompleted[toggleId];
  store.save();
  json(res, 200, { planMinutes: p.planMinutes, planCompleted: p.planCompleted });
});

// --- practice (uses dedicated practice pool separate from Full Mock Exams)

route('POST', '/api/practice/next', async (req, res, { user }) => {
  const { kind, focusSkill, excludeId } = await readBody(req);
  const p = store.progress(user.id);
  const pool = content.practiceUnits.filter((u) => u.kind === kind);
  const pick = nextUnit(pool, p.exposure, weaknesses(p.skillEvents).map((w) => w.skillTag), focusSkill, excludeId);
  if (!pick) return json(res, 404, { error: 'No practice material available.' });
  const u = pick.unit;
  if (kind === 'writing' || kind === 'speaking') {
    p.exposure.seenUnits[u.id] = new Date().toISOString();
    store.save();
  }
  json(res, 200, {
    id: u.id, kind: u.kind, source: u.source, isRepeat: pick.isRepeat,
    practiceMode: u.practiceMode || 'task', sourceUnitId: u.sourceUnitId || u.id,
    passage: u.passage ? stripPassage(u.passage) : null,
    part: u.part ? stripPart(u.part) : null,
    taskNumber: u.taskNumber || null,
    writingTask: u.writingTask || null,
    speakingSet: u.speakingSet || null,
  });
});

// Every Writing / Speaking practice prompt: practice-pool exams plus the standalone banks (mock exams stay unseen).
route('GET', '/api/prompts', async (req, res) => {
  const ex = content.practiceExams().filter((e) => e.pool === 'practice');
  const w1 = [...ex.map((e) => ({ ...e.writingTask1, source: e.title })), ...content.banks.writing1.map((t) => ({ ...t, source: 'Writing bank' }))];
  const w2 = [...ex.map((e) => ({ ...e.writingTask2, source: e.title })), ...content.banks.writing2.map((t) => ({ ...t, source: 'Writing bank' }))];
  const sp = [...ex.map((e) => ({ ...e.speakingSet, source: e.title })), ...content.banks.speaking.map((t) => ({ ...t, source: 'Speaking bank' }))];
  json(res, 200, { writing1: w1, writing2: w2, speaking: sp });
});

route('POST', '/api/exams/random', async (req, res, { user }) => {
  const { excludeId } = await readBody(req);
  const p = store.progress(user.id);
  const mocks = content.mockExams().filter((e) => e.id !== excludeId);
  const unseen = mocks.filter((e) => !(p.exposure.examAttempts[e.id] > 0));
  const candidates = unseen.length ? unseen : mocks;
  const pick = candidates[Math.floor(Math.random() * candidates.length)] || content.mockExams()[0];
  if (!pick) return json(res, 404, { error: 'No mock exams available.' });
  json(res, 200, { id: pick.id, title: pick.title });
});

route('POST', '/api/practice/submit', async (req, res, { user }) => {
  const { unitId, responses } = await readBody(req);
  const unit = content.unit(unitId);
  if (!unit || unit.pool !== 'practice' || !['reading', 'listening'].includes(unit.kind)) {
    return json(res, 404, { error: 'Unknown practice set.' });
  }
  const p = store.progress(user.id);
  const graded = grade(unit.questions, responses || {});
  recordResults(p, graded, unit.kind === 'reading' ? 'Reading' : 'Listening', unit.source);
  p.exposure.seenUnits[unit.id] = new Date().toISOString();
  p.attempts.push({ id: newId(), type: 'practice', module: unit.kind, title: unit.passage?.title || unit.part?.title, raw: graded.raw, total: graded.total, date: new Date().toISOString() });
  store.save();
  json(res, 200, { ...graded, skillTitles: Object.fromEntries(graded.results.map((r) => [r.skillTag, content.skillTitle(r.skillTag)])), transcript: unit.part?.dialogue || null });
});

// --- full mock exams

route('GET', '/api/exams/:id', async (req, res, { params }) => {
  const e = content.exam(params.id);
  if (!e) return json(res, 404, { error: 'Exam not found.' });
  json(res, 200, stripExam(e));
});

route('POST', '/api/exams/:id/objective', async (req, res, { user, params }) => {
  const e = content.exam(params.id);
  if (!e) return json(res, 404, { error: 'Exam not found.' });
  const { listening = {}, reading = {} } = await readBody(req);
  const p = store.progress(user.id);
  const lq = e.listeningParts.flatMap((x) => x.questions), rq = e.readingPassages.flatMap((x) => x.questions);
  const lg = grade(lq, listening), rg = grade(rq, reading);
  recordResults(p, lg, 'Listening', e.title); recordResults(p, rg, 'Reading', e.title);
  for (const u of [...e.listeningParts, ...e.readingPassages]) p.exposure.seenUnits[u.id] = new Date().toISOString();
  store.save();
  json(res, 200, { listening: { ...lg, band: rawToBand(lg.raw, true) }, reading: { ...rg, band: rawToBand(rg.raw, false) } });
});

route('POST', '/api/exams/:id/section', async (req, res, { user, params }) => {
  const e = content.exam(params.id);
  if (!e) return json(res, 404, { error: 'Exam not found.' });
  const { module, answers = {} } = await readBody(req);
  if (!['listening', 'reading'].includes(module)) return json(res, 400, { error: 'Invalid section.' });
  const p = store.progress(user.id);
  const units = module === 'listening' ? e.listeningParts : e.readingPassages;
  const g = grade(units.flatMap((x) => x.questions), answers);
  const label = module === 'listening' ? 'Listening' : 'Reading';
  recordResults(p, g, label, e.title);
  for (const u of units) p.exposure.seenUnits[u.id] = new Date().toISOString();
  const band = rawToBand(g.raw, module === 'listening');
  p.attempts.push({ id: newId(), type: 'module', module, [module]: band, title: `${label} test: ${e.title}`, date: new Date().toISOString() });
  store.save();
  json(res, 200, { ...g, band });
});

route('POST', '/api/evaluate/writing', async (req, res) => {
  const { task, prompt, text } = await readBody(req);
  const model = await pickModel(store.data.config);
  json(res, 200, await evaluateWriting({ model, task: Number(task) === 1 ? 1 : 2, prompt: String(prompt || ''), text: String(text || '') }));
});

route('POST', '/api/evaluate/speaking', async (req, res) => {
  const { transcript, seconds, questions } = await readBody(req);
  const model = await pickModel(store.data.config);
  json(res, 200, await evaluateSpeaking({ model, transcript: String(transcript || ''), seconds: Number(seconds) || 0, questions: questions || [] }));
});

route('POST', '/api/exams/:id/complete', async (req, res, { user, params }) => {
  const e = content.exam(params.id);
  if (!e) return json(res, 404, { error: 'Exam not found.' });
  const { listening, reading, writing1, writing2, speaking } = await readBody(req);
  const p = store.progress(user.id);
  const w = writing1 != null && writing2 != null ? writingBand(writing1, writing2) : null;
  const modules = [listening, reading, w, speaking].filter((x) => x != null);
  const headline = modules.length ? roundOfficialBand(modules.reduce((s, x) => s + x, 0) / modules.length) : null;
  const attempt = { id: newId(), type: 'full', examId: e.id, title: e.title, listening, reading, writing: w, speaking: speaking ?? null,
    headline, overall: modules.length === 4 ? headline : null, date: new Date().toISOString() };
  p.attempts.push(attempt);
  p.exposure.examAttempts[e.id] = (p.exposure.examAttempts[e.id] || 0) + 1;
  store.save();
  json(res, 200, { attempt, summary: summary(user) });
});

route('POST', '/api/attempts/single', async (req, res, { user }) => {
  const { module, band, title } = await readBody(req);
  if (!['writing', 'speaking'].includes(module) || band == null) return json(res, 400, { error: 'Invalid attempt.' });
  store.progress(user.id).attempts.push({ id: newId(), type: 'module', module, [module]: Number(band), title: String(title || ''), date: new Date().toISOString() });
  store.save(); json(res, 200, { ok: true });
});

// --- mistakes

route('GET', '/api/mistakes', async (req, res, { user }) => {
  const p = store.progress(user.id);
  json(res, 200, { mistakes: p.mistakes.map((m) => ({ ...m, skillTitle: content.skillTitle(m.skillTag) })) });
});

route('POST', '/api/mistakes/:id/mastered', async (req, res, { user, params }) => {
  const m = store.progress(user.id).mistakes.find((x) => x.id === params.id);
  if (m) { m.mastered = !m.mastered; store.save(); }
  json(res, 200, { ok: true });
});

// --- teacher

route('GET', '/api/teacher', async (req, res, { user }) => {
  const model = await pickModel(store.data.config);
  json(res, 200, { messages: store.progress(user.id).teacher.slice(-60), model });
});

route('POST', '/api/teacher/chat', async (req, res, { user }) => {
  const { message, arabic } = await readBody(req);
  const text = String(message || '').trim().slice(0, 6000);
  if (!text) return json(res, 400, { error: 'Empty message.' });
  const p = store.progress(user.id);
  const model = await pickModel(store.data.config);
  p.teacher.push({ role: 'user', content: text, date: new Date().toISOString() });
  if (!model) {
    const reply = 'The AI teacher is offline: Ollama is not running on the Mac that hosts this site. Your message is saved. Meanwhile, open Skills Coach for the written lesson on your weakest skill.';
    p.teacher.push({ role: 'assistant', content: reply, date: new Date().toISOString() }); store.save();
    res.writeHead(200, { 'content-type': 'text/plain; charset=utf-8', 'cache-control': 'no-store' });
    return res.end(reply);
  }
  const weak = weaknesses(p.skillEvents).map((w) => ({ ...w, title: content.skillTitle(w.skillTag) }));
  const mistakes = p.mistakes.filter((m) => !m.mastered).map((m) => ({ ...m, skillTitle: content.skillTitle(m.skillTag) }));
  const grammarWeak = (content.bundle.grammarLessons || [])
    .filter((l) => p.grammar?.[l.id] && p.grammar[l.id].status !== 'Mastered')
    .map((l) => `${l.title} (${p.grammar[l.id].status})`);
  const vocabAll = content.bundle.vocabulary || [];
  const nowMs = Date.now();
  const vocabStats = {
    mastered: vocabAll.filter((v) => (p.vocabSM2?.[v.id]?.repetitions || 0) >= 3).length,
    due: vocabAll.filter((v) => !p.vocabSM2?.[v.id] || Date.parse(p.vocabSM2[v.id].nextReview) <= nowMs).length,
  };
  const ragDocs = retrieveKnowledge(content.bundle.knowledgeDocs || [], text, 2);
  const system = teacherSystemPrompt({
    name: user.firstName,
    targetBand: p.targetBand,
    bands: bandSummary(p),
    attempts: p.attempts,
    weak,
    mistakes,
    grammarWeak,
    vocabStats,
    ragDocs,
    arabic: !!arabic,
  });
  const history = p.teacher.slice(-16).map((m) => ({ role: m.role, content: m.content }));
  res.writeHead(200, { 'content-type': 'text/plain; charset=utf-8', 'cache-control': 'no-store', 'x-accel-buffering': 'no' });
  const controller = new AbortController();
  req.on('close', () => { if (!res.writableEnded) controller.abort(); });
  let full = '';
  try {
    full = await chatStream(model, [{ role: 'system', content: system }, ...history], (t) => res.write(t), controller.signal);
  } catch (e) {
    if (!full) { full = `The model could not answer (${e.message}).`; res.write(full); }
  }
  p.teacher.push({ role: 'assistant', content: full, model, date: new Date().toISOString() });
  if (p.teacher.length > 400) p.teacher.splice(0, p.teacher.length - 400);
  store.save();
  res.end();
});

route('POST', '/api/teacher/clear', async (req, res, { user }) => { store.progress(user.id).teacher = []; store.save(); json(res, 200, { ok: true }); });

// --- admin

route('GET', '/api/admin/users', async (req, res) => {
  json(res, 200, { users: store.data.users.map((u) => ({ ...publicUser(u), sessions: store.data.sessions.filter((s) => s.userId === u.id).length,
    answers: store.progress(u.id).skillEvents.length, lastSeen: store.data.sessions.filter((s) => s.userId === u.id).map((s) => s.lastSeen).sort().pop() || null })) });
}, { admin: true });

route('POST', '/api/admin/users', async (req, res) => {
  const { firstName, lastName, email, password, role } = await readBody(req);
  const e = normalizeEmail(email);
  if (!firstName?.trim() || !lastName?.trim()) return json(res, 400, { error: 'First name and last name are required.' });
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e)) return json(res, 400, { error: 'Enter a valid email address.' });
  if (String(password || '').length < 6) return json(res, 400, { error: 'Password must be at least 6 characters.' });
  if (store.data.users.some((u) => u.email === e)) return json(res, 409, { error: 'An account with this email already exists.' });
  const { salt, hash } = hashPassword(String(password));
  const user = { id: newId(), firstName: firstName.trim(), lastName: lastName.trim(), email: e, role: role === 'admin' ? 'admin' : 'user', salt, passwordHash: hash, createdAt: new Date().toISOString() };
  store.data.users.push(user); store.save();
  json(res, 201, { user: publicUser(user) });
}, { admin: true });

route('POST', '/api/admin/users/:id/password', async (req, res, { params }) => {
  const { password } = await readBody(req);
  const u = store.data.users.find((x) => x.id === params.id);
  if (!u) return json(res, 404, { error: 'User not found.' });
  if (String(password || '').length < 6) return json(res, 400, { error: 'Password must be at least 6 characters.' });
  const { salt, hash } = hashPassword(String(password));
  u.salt = salt; u.passwordHash = hash;
  store.data.sessions = store.data.sessions.filter((s) => s.userId !== u.id); // sign out everywhere
  store.save(); json(res, 200, { ok: true });
}, { admin: true });

route('DELETE', '/api/admin/users/:id', async (req, res, { user, params }) => {
  if (params.id === user.id) return json(res, 400, { error: "You can't delete your own admin account." });
  const target = store.data.users.find((u) => u.id === params.id);
  if (!target) return json(res, 404, { error: 'User not found.' });
  store.data.users = store.data.users.filter((u) => u.id !== params.id);
  store.data.sessions = store.data.sessions.filter((s) => s.userId !== params.id);
  delete store.data.progress[params.id];
  store.save(); json(res, 200, { ok: true });
}, { admin: true });

route('GET', '/api/admin/system', async (req, res) => {
  json(res, 200, { models: await listModels(), model: await pickModel(store.data.config), contentVersion: content.bundle.version, exams: content.bundle.exams.length });
}, { admin: true });

route('POST', '/api/admin/model', async (req, res) => {
  const { model } = await readBody(req);
  store.data.config.model = model || null; store.save();
  json(res, 200, { ok: true });
}, { admin: true });

// ---------------------------------------------------------------- static files

const TYPES = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml', '.png': 'image/png', '.ico': 'image/x-icon', '.json': 'application/json', '.webmanifest': 'application/manifest+json', '.woff2': 'font/woff2' };

function serveStatic(req, res) {
  const url = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  let file = path.normalize(path.join(STATIC, url));
  if (!file.startsWith(STATIC)) { res.writeHead(403); return res.end(); }
  if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) file = path.join(STATIC, 'index.html');
  if (!fs.existsSync(file)) { res.writeHead(503, { 'content-type': 'text/plain' }); return res.end('The web interface has not been built yet. Run Web/scripts/build.sh.'); }
  const ext = path.extname(file);
  res.writeHead(200, { 'content-type': TYPES[ext] || 'application/octet-stream', 'cache-control': ext === '.html' ? 'no-cache' : 'public, max-age=31536000, immutable' });
  fs.createReadStream(file).pipe(res);
}

// ---------------------------------------------------------------- server

const server = http.createServer(async (req, res) => {
  res.setHeader('x-content-type-options', 'nosniff');
  res.setHeader('x-frame-options', 'DENY');
  res.setHeader('referrer-policy', 'same-origin');
  res.setHeader('permissions-policy', 'microphone=(self)');
  const url = new URL(req.url, 'http://x');
  if (!url.pathname.startsWith('/api/')) return serveStatic(req, res);
  const r = routes.find((x) => x.method === req.method && x.pattern.test(url.pathname));
  if (!r) return json(res, 404, { error: 'Not found' });
  try {
    const user = currentUser(req);
    if (r.auth && !user) return json(res, 401, { error: 'Please sign in.' });
    if (r.admin && user?.role !== 'admin') return json(res, 403, { error: 'Admin only.' });
    await r.handler(req, res, { user, params: url.pathname.match(r.pattern).groups || {} });
  } catch (e) {
    if (!res.headersSent) json(res, e.status || 500, { error: e.status ? e.message : 'Server error.' });
    else res.end();
    if (!e.status) console.error(e);
  }
});

server.listen(PORT, '127.0.0.1', () => console.log(`IELTS Master web: http://127.0.0.1:${PORT}  (data: ${DATA}, content ${content.bundle.version})`));
for (const sig of ['SIGINT', 'SIGTERM']) process.on(sig, () => { store.flush(); process.exit(0); });

// Hot deploy: touching <runtime>/.restart makes the server exit; launchd (KeepAlive) starts it again
// with the new code and content. Lets updates be pushed without opening Terminal.
const RESTART_FLAG = path.join(ROOT, '..', '.restart');
let restartStamp = fs.existsSync(RESTART_FLAG) ? fs.statSync(RESTART_FLAG).mtimeMs : 0;
setInterval(() => {
  try {
    const m = fs.existsSync(RESTART_FLAG) ? fs.statSync(RESTART_FLAG).mtimeMs : 0;
    if (m && m !== restartStamp) { console.log('Restart requested, exiting so launchd reloads the new version.'); try { store.flush(); } catch { } setTimeout(() => process.exit(0), 300); }
  } catch { /* ignore */ }
}, 5000).unref();
