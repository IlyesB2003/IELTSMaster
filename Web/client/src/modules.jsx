import React, { useEffect, useState } from 'react';
import { useApp } from './App.jsx';
import { api, fmtBand, pct, speak, stopSpeaking, moduleColor } from './lib.js';
import { Arabic, Bar, Recorder, SkillBar } from './components.jsx';

// ================================================================ My Learning Plan

export function LearningPlan() {
  const { me, refresh, go } = useApp();
  const [minutes, setMinutes] = useState(me.planMinutes || 45);
  const [completed, setCompleted] = useState(me.planCompleted || {});
  const durations = [15, 30, 45, 60, 90];

  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const weakMod = me.weak[0]?.module || 'Reading';
  const cycle = [weakMod, 'Writing', 'Grammar', 'Listening', 'Speaking', 'Vocabulary'];

  const sessions = days.flatMap((day, i) => {
    if (day === 'Sunday') {
      return [{ id: 'sun-rev', day, title: 'Active Recovery & Mistake Notebook Review', module: 'Mistake Notebook', target: 'mistakes', mins: Math.min(minutes, 20), isBreak: false }];
    }
    const primary = cycle[i % cycle.length];
    const targetFor = (m) => ({ Reading: 'reading', Listening: 'listening', Writing: 'writing', Speaking: 'speaking', Grammar: 'grammar', Vocabulary: 'vocabulary' }[m] || 'practice');
    if (minutes <= 30) {
      return [{ id: `${day}-1`, day, title: `${primary} Focused Practice & Review`, module: primary, target: targetFor(primary), mins: minutes, isBreak: false }];
    }
    const first = Math.floor(minutes / 2);
    const brk = minutes >= 60 ? 10 : 5;
    const second = Math.max(10, minutes - first - brk);
    const secMod = cycle[(i + 1) % cycle.length];
    return [
      { id: `${day}-1`, day, title: `${primary} Intensive Block`, module: primary, target: targetFor(primary), mins: first, isBreak: false },
      { id: `${day}-b`, day, title: 'Scheduled Cognitive Break', module: 'Break', target: null, mins: brk, isBreak: true },
      { id: `${day}-2`, day, title: `${secMod} Consolidation`, module: secMod, target: targetFor(secMod), mins: second, isBreak: false },
    ];
  });

  const changeMinutes = async (m) => {
    setMinutes(m);
    await api('/api/plan', { method: 'POST', body: { minutes: m } });
    refresh();
  };

  const toggle = async (id) => {
    setCompleted((c) => ({ ...c, [id]: !c[id] }));
    await api('/api/plan', { method: 'POST', body: { toggleId: id } });
  };

  return (
    <div className="page fade-in">
      <div><h1>My Learning Plan</h1><div className="muted">Adaptive weekly schedule built from your weaknesses ({me.weak[0]?.title || 'balanced baseline'}) and target Band {fmtBand(me.targetBand)}.</div></div>
      <div className="card row">
        <div className="grow"><strong>Session duration</strong><div className="small muted">Sessions of 45 minutes or more automatically include short cognitive breaks.</div></div>
        <div className="seg">{durations.map((m) => <button key={m} className={minutes === m ? 'on' : ''} onClick={() => changeMinutes(m)}>{m}m</button>)}</div>
      </div>
      <div className="card stack">
        {sessions.map((s) => (
          <div key={s.id} className="row" style={{ borderBottom: '1px solid var(--border)', paddingBottom: 10 }}>
            <input type="checkbox" disabled={s.isBreak} checked={!!completed[s.id]} onChange={() => toggle(s.id)} style={{ width: 18, height: 18, accentColor: 'var(--primary)' }} />
            <div className="grow">
              <div className="row" style={{ gap: 6 }}><span className="tiny muted" style={{ fontWeight: 700 }}>{s.day}</span><span className="badge">{s.mins} min</span><span className="badge blue">{s.module}</span></div>
              <div style={{ fontWeight: 600, marginTop: 2, opacity: completed[s.id] ? 0.5 : 1 }}>{s.title}</div>
            </div>
            {!s.isBreak && s.target && <button className="btn sm" onClick={() => go(s.target)}>Open</button>}
          </div>
        ))}
      </div>
    </div>
  );
}

// ================================================================ Grammar (20 Lessons)

export function GrammarPage() {
  const { refresh } = useApp();
  const [data, setData] = useState(null);
  const [selId, setSelId] = useState(null);
  const [answers, setAnswers] = useState({});
  const [result, setResult] = useState(null);
  const [showArabic, setShowArabic] = useState(true);

  const load = () => api('/api/curriculum').then((d) => { setData(d); if (!selId && d.grammarLessons?.[0]) setSelId(d.grammarLessons[0].id); });
  useEffect(() => { load(); }, []); // eslint-disable-line

  if (!data) return <div className="page muted">Loading grammar curriculum…</div>;
  const lessons = data.grammarLessons || [];
  const lesson = lessons.find((l) => l.id === selId) || lessons[0];
  if (!lesson) return <div className="page muted">No grammar lessons available.</div>;

  const submit = async () => {
    const r = await api('/api/grammar/submit', { method: 'POST', body: { lessonId: lesson.id, answers } });
    setResult(r);
    load();
    refresh();
  };

  return (
    <div className="page fade-in">
      <div className="row">
        <div><h1>Grammar</h1><div className="muted">20 structured academic grammar lessons with bilingual Arabic explanations and mistake tracking.</div></div>
        <span className="spacer" />
        <label className="row small" style={{ gap: 6, cursor: 'pointer' }}><input type="checkbox" checked={showArabic} onChange={(e) => setShowArabic(e.target.checked)} />Arabic explanations</label>
      </div>
      <div className="coach-grid">
        <div className="stack" style={{ gap: 4 }}>
          {lessons.map((l) => {
            const st = data.grammarProgress?.[l.id]?.status;
            return (
              <button key={l.id} className={`nav-item ${l.id === lesson.id ? 'active' : ''}`} onClick={() => { setSelId(l.id); setAnswers({}); setResult(null); }}>
                <span className="grow" style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{l.order}. {l.title}</span>
                {st && <span className={`badge ${st === 'Mastered' ? 'ok' : 'warn'}`}>{st}</span>}
              </button>
            );
          })}
        </div>
        <div className="stack" style={{ gap: 16 }}>
          <div className="card pad-lg stack">
            <div className="row"><span className="badge blue">{lesson.cefrRange}</span><span className="spacer" />{data.grammarProgress?.[lesson.id] && <span className="badge ok">{data.grammarProgress[lesson.id].status}</span>}</div>
            <h2>{lesson.title}</h2>
            <div className="muted">{lesson.summary}</div>
            <h3>Core rules</h3>
            {lesson.detailedRules.map((r, i) => <div key={i} className="small">• {r}</div>)}
            <h3>Academic examples</h3>
            {lesson.examples.map((ex, i) => <div key={i} className="small muted">{ex}</div>)}
            {lesson.commonIELTSTraps?.length > 0 && <><h3 style={{ color: 'var(--warn)' }}>Common IELTS traps</h3>{lesson.commonIELTSTraps.map((t, i) => <div key={i} className="small">• {t}</div>)}</>}
            {showArabic && <Arabic title="الشرح بالعربية" text={lesson.arabicExplanation} />}
          </div>

          <div className="card pad-lg stack">
            <h3>Mastery verification exercises</h3>
            {lesson.exercises.map((ex) => {
              const det = result?.details?.find((d) => d.id === ex.id);
              return (
                <div key={ex.id} className="stack" style={{ borderTop: '1px solid var(--border)', paddingTop: 12 }}>
                  <div style={{ fontWeight: 600 }}>{ex.prompt}</div>
                  {ex.options.map((opt, idx) => (
                    <label key={idx} className={`opt ${answers[ex.id] === idx ? 'on' : ''}`}>
                      <input type="radio" name={ex.id} checked={answers[ex.id] === idx} disabled={!!result} onChange={() => setAnswers({ ...answers, [ex.id]: idx })} />
                      <span>{opt}</span>
                    </label>
                  ))}
                  {det && (
                    <div className="feedback">
                      <strong style={{ color: det.correct ? 'var(--ok)' : 'var(--bad)' }}>{det.correct ? '✓ Correct' : `✗ Correct: ${ex.options[det.correctIndex]}`}</strong>
                      <div className="small muted">{det.explanation}</div>
                      {showArabic && <div style={{ marginTop: 6 }}><Arabic text={det.arabicExplanation} /></div>}
                    </div>
                  )}
                </div>
              );
            })}
            <div className="row">
              {result
                ? <><span className="badge ok">Score: {result.correct}/{result.total} · {result.status}</span><button className="btn" onClick={() => { setAnswers({}); setResult(null); }}>Practise again</button></>
                : <button className="btn primary" disabled={Object.keys(answers).length < lesson.exercises.length} onClick={submit}>Verify answers</button>}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ================================================================ Vocabulary (SM-2)

export function VocabularyPage() {
  const { refresh } = useApp();
  const [items, setItems] = useState(null);
  const [query, setQuery] = useState('');
  const [cat, setCat] = useState('All');
  const [cefrFilter, setCefrFilter] = useState('All');
  const [reviewMode, setReviewMode] = useState(false);
  const [reveal, setReveal] = useState(false);
  const [showArabic, setShowArabic] = useState(true);

  const load = () => api('/api/curriculum').then((d) => setItems(d.vocabulary || []));
  useEffect(() => { load(); }, []);

  if (!items) return <div className="page muted">Loading vocabulary…</div>;
  const now = Date.now();
  const due = items.filter((v) => !v.sm2 || Date.parse(v.sm2.nextReview) <= now);
  const categories = ['All', ...new Set(items.map((v) => v.category))].sort();
  const filtered = items.filter((v) =>
    (cat === 'All' || v.category === cat)
    && (cefrFilter === 'All' || v.cefrLevel === cefrFilter)
    && (!query || v.word.toLowerCase().includes(query.toLowerCase()) || v.definition.toLowerCase().includes(query.toLowerCase()))
  );

  const rate = async (wordId, quality) => {
    await api('/api/vocabulary/review', { method: 'POST', body: { wordId, quality } });
    setReveal(false);
    await load();
    refresh();
  };

  return (
    <div className="page fade-in">
      <div className="row">
        <div><h1>Vocabulary</h1><div className="muted">Academic IELTS lexicon with IPA, audio pronunciation, collocations, Arabic translations, and SM-2 spaced repetition.</div></div>
        <span className="spacer" />
        <button className="btn primary" onClick={() => { setReviewMode(!reviewMode); setReveal(false); }}>{reviewMode ? 'Browse all words' : `Start SM-2 Review (${due.length} due)`}</button>
      </div>

      {reviewMode ? (
        due.length === 0 ? <div className="card pad-lg"><h3>All caught up</h3><div className="muted">No cards are due right now. Switch back to Browse all words to review collocations.</div></div> : (
          <div className="card pad-lg stack" style={{ maxWidth: 700 }}>
            <div className="row"><span className="badge blue">{due[0].category}</span><span className="badge">{due[0].cefrLevel}</span><span className="spacer" /><button className="btn sm" onClick={() => speak(due[0].word)}>🔊 Pronounce</button></div>
            <h1 style={{ fontSize: 34 }}>{due[0].word}</h1>
            <div className="muted">{due[0].partOfSpeech} · {due[0].ipa}</div>
            {reveal ? (
              <>
                <div style={{ fontWeight: 600 }}>{due[0].definition}</div>
                <div className="small muted">{due[0].exampleSentence}</div>
                {due[0].collocations?.length > 0 && <div className="small">Collocations: {due[0].collocations.join(' · ')}</div>}
                {showArabic && <Arabic title="المعنى بالعربية" text={due[0].arabicTranslation} />}
                <div className="row" style={{ marginTop: 8 }}>
                  <button className="btn" onClick={() => rate(due[0].id, 1)}>Again (1d)</button>
                  <button className="btn" onClick={() => rate(due[0].id, 3)}>Hard</button>
                  <button className="btn primary" onClick={() => rate(due[0].id, 4)}>Good</button>
                  <button className="btn" onClick={() => rate(due[0].id, 5)}>Easy</button>
                </div>
              </>
            ) : <button className="btn primary lg" onClick={() => setReveal(true)}>Reveal meaning & collocations</button>}
          </div>
        )
      ) : (
        <>
          <div className="row">
            <input className="input" style={{ maxWidth: 260 }} placeholder="Search word or definition…" value={query} onChange={(e) => setQuery(e.target.value)} />
            <select className="select" style={{ maxWidth: 220 }} value={cat} onChange={(e) => setCat(e.target.value)}>{categories.map((c) => <option key={c} value={c}>{c}</option>)}</select>
            <div className="seg">{['All', 'B2', 'C1', 'C2'].map((lvl) => <button key={lvl} className={cefrFilter === lvl ? 'on' : ''} onClick={() => setCefrFilter(lvl)}>{lvl}</button>)}</div>
            <label className="row small" style={{ gap: 6, cursor: 'pointer' }}><input type="checkbox" checked={showArabic} onChange={(e) => setShowArabic(e.target.checked)} />Arabic</label>
          </div>
          <div className="grid" style={{ '--min': '300px' }}>
            {filtered.map((v) => (
              <div key={v.id} className="card stack" style={{ gap: 8 }}>
                <div className="row"><strong>{v.word}</strong><span className="tiny muted">{v.ipa}</span><span className="spacer" /><button className="btn sm" onClick={() => speak(`${v.word}. ${v.exampleSentence}`)}>🔊</button></div>
                <div className="row" style={{ gap: 6 }}><span className="badge">{v.partOfSpeech}</span><span className="badge blue">{v.cefrLevel}</span><span className="badge">{v.category}</span></div>
                <div className="small">{v.definition}</div>
                <div className="tiny muted">{v.exampleSentence}</div>
                {showArabic && <Arabic text={v.arabicTranslation} />}
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

// ================================================================ Pronunciation Lab

const MINIMAL_PAIRS = [
  ['/p/ vs /b/', 'pack / back · simple / symbol · rapid / rabid', 'Release a crisp burst of air (aspiration) on initial /p/.', 'تدرّب على إخراج دفعة هواء واضحة عند نطق /p/ للتمييز بينه وبين /b/.'],
  ['/f/ vs /v/', 'ferry / very · leaf / leave · safe / save', 'Keep vocal cords vibrating on /v/.', 'حافظ على اهتزاز الأحبال الصوتية عند نطق /v/.'],
  ['/ɪ/ vs /iː/', 'ship / sheep · live / leave · fill / feel', 'Short lax /ɪ/ versus longer tense /iː/.', 'فرّق بين الكسرة القصيرة في ship والمد الطويل في sheep.'],
  ['/θ/ vs /s/', 'think / sink · method / message · path / pass', 'Place tongue tip lightly between teeth for /θ/.', 'ضع طرف اللسان بين الأسنان لنطق صوت ث (/θ/) بوضوح.'],
  ['/tʃ/ vs /ʃ/', 'cheap / sheep · research / reshare · watch / wash', 'Add a crisp /t/ stop before /ʃ/ for /tʃ/.', 'أضف وقفة /t/ واضحة قبل /ʃ/ في كلمات مثل research.'],
  ['Consonant clusters', 'statistics · strengths · agricultural · products', 'Avoid inserting an extra vowel before initial st- or pr-.', 'تجنّب إضافة همزة أو حركة قبل تتابع الحروف الساكنة في بداية الكلمة.'],
];

const STRESS_DRILLS = [
  ['ANalyse (v) → aNALysis (n) → anaLYTical (adj)', 'Primary stress shifts across academic word families.'],
  ['ECOnomy → ecoNOMic → eCONomist', 'Reduce unstressed vowels cleanly to schwa /ə/.'],
  ['PHOto → phoTOgraphy → photoGRAPHic', 'Band 8–9 intelligibility relies on accurate syllable stress.'],
  ['CONtrast (n) vs conTRAST (v) · PROduce (n) vs proDUCE (v)', 'Two-syllable noun/verb pairs shift stress from 1st to 2nd syllable.'],
];

const SHADOW_PASSAGES = [
  'Although upfront installation costs remain substantial, precision irrigation has significantly improved both crop resilience and freshwater stewardship across Ireland.',
  'Adaptive governance outperforms rigid statutes by establishing transparent outcome targets while revising technical standards every three years as empirical datasets mature.',
  'Not only does integrating white clover into ryegrass pastures curb synthetic nitrogen demand, but it also stabilizes seasonal forage output during summer droughts.',
];

export function PronunciationPage() {
  const [accent, setAccent] = useState('en-GB');
  const [passageIdx, setPassageIdx] = useState(0);
  const [dictation, setDictation] = useState('');
  const [scoreMsg, setScoreMsg] = useState('');
  useEffect(() => () => stopSpeaking(), []);

  const activeText = SHADOW_PASSAGES[passageIdx];
  const checkDictation = () => {
    const target = new Set(activeText.toLowerCase().match(/[a-z]+/g) || []);
    const got = new Set(dictation.toLowerCase().match(/[a-z]+/g) || []);
    let hits = 0;
    for (const w of target) if (got.has(w)) hits += 1;
    setScoreMsg(`Matched ${hits}/${target.size} unique words (${Math.round((hits / target.size) * 100)}%).`);
  };

  return (
    <div className="page fade-in">
      <div className="row">
        <div><h1>Pronunciation Lab</h1><div className="muted">Intelligibility-focused training for Band 8–9 Speaking: minimal pairs, academic word stress, connected speech shadowing, and multi-accent dictation. Non-native accents are never penalised.</div></div>
        <span className="spacer" />
        <select className="select" style={{ width: 190 }} value={accent} onChange={(e) => setAccent(e.target.value)}>
          <option value="en-GB">British (en-GB)</option>
          <option value="en-IE">Irish (en-IE)</option>
          <option value="en-AU">Australian (en-AU)</option>
          <option value="en-US">American (en-US)</option>
          <option value="en-CA">Canadian (en-CA)</option>
        </select>
      </div>

      <div className="eyebrow">Minimal pairs & Arabic-speaker intelligibility targets</div>
      <div className="grid" style={{ '--min': '290px' }}>
        {MINIMAL_PAIRS.map(([pair, words, tip, ar]) => (
          <div key={pair} className="card stack">
            <div className="row"><span className="badge blue">{pair}</span><span className="spacer" /><button className="btn sm" onClick={() => speak(words.replace(/·/g, ','), accent, 0.85)}>🔊 Listen</button></div>
            <strong>{words}</strong>
            <div className="small muted">{tip}</div>
            <Arabic text={ar} />
          </div>
        ))}
      </div>

      <div className="eyebrow">Academic word & sentence stress</div>
      <div className="grid" style={{ '--min': '290px' }}>
        {STRESS_DRILLS.map(([phrase, note]) => (
          <div key={phrase} className="card stack">
            <div className="row"><strong className="grow">{phrase}</strong><button className="btn sm" onClick={() => speak(phrase.replace(/[→·()]/g, ', '), accent, 0.85)}>🔊</button></div>
            <div className="small muted">{note}</div>
          </div>
        ))}
      </div>

      <div className="card pad-lg stack">
        <div className="row">
          <h3>Band 8–9 Shadowing & academic dictation</h3>
          <span className="spacer" />
          <div className="seg">{SHADOW_PASSAGES.map((_, i) => <button key={i} className={passageIdx === i ? 'on' : ''} onClick={() => { setPassageIdx(i); setDictation(''); setScoreMsg(''); }}>Clip {i + 1}</button>)}</div>
        </div>
        <div>{activeText}</div>
        <div className="row">
          <button className="btn primary" onClick={() => speak(activeText, accent, 0.92)}>▶ Play normal</button>
          <button className="btn" onClick={() => speak(activeText, accent, 0.72)}>▶ Play slow</button>
        </div>
        <Recorder label="Record yourself shadowing" />
        <textarea className="textarea" rows={2} placeholder="Dictation check: type what you hear…" value={dictation} onChange={(e) => setDictation(e.target.value)} />
        <div className="row"><button className="btn" onClick={checkDictation}>Check dictation accuracy</button>{scoreMsg && <span className="badge ok">{scoreMsg}</span>}</div>
      </div>
    </div>
  );
}

// ================================================================ Academic English

export function AcademicEnglishPage() {
  const { go, setTeacherSeed } = useApp();
  const [units, setUnits] = useState(null);
  const [sel, setSel] = useState(null);
  const [draft, setDraft] = useState('');

  useEffect(() => { api('/api/curriculum').then((d) => { const u = d.academicUnits || []; setUnits(u); if (u[0]) setSel(u[0].id); }); }, []);
  if (!units) return <div className="page muted">Loading academic English…</div>;
  const unit = units.find((u) => u.id === sel) || units[0];
  if (!unit) return <div className="page muted">No units available.</div>;

  return (
    <div className="page fade-in">
      <div><h1>Academic English</h1><div className="muted">Research abstracts, scientific articles, presentations, Ireland/EU professional correspondence, and optional Agricultural & Animal Science tracks.</div></div>
      <div className="coach-grid">
        <div className="stack" style={{ gap: 4 }}>
          {units.map((u) => (
            <button key={u.id} className={`nav-item ${u.id === unit.id ? 'active' : ''}`} onClick={() => setSel(u.id)}>
              <span className="grow">{u.title}</span>
              {u.isSpecializedAgriBio && <span className="badge teal">Track</span>}
            </button>
          ))}
        </div>
        <div className="stack" style={{ gap: 16 }}>
          <div className="card pad-lg stack">
            <span className="badge blue" style={{ alignSelf: 'flex-start' }}>{unit.category}</span>
            <h2>{unit.title}</h2>
            <div className="muted">{unit.overview}</div>
            <h3>Key conventions</h3>
            {unit.keyConventions.map((c, i) => <div key={i} className="small">• {c}</div>)}
            <h3>Model excerpt</h3>
            <div className="small" style={{ background: 'var(--elev)', padding: 12, borderRadius: 10, lineHeight: 1.7 }}>{unit.modelExcerpt}</div>
            <Arabic title="ملاحظات بالعربية" text={unit.arabicNotes} />
          </div>
          <div className="card pad-lg stack">
            <h3>Practice task</h3>
            <div className="small muted">{unit.practiceTask}</div>
            <textarea className="textarea" value={draft} onChange={(e) => setDraft(e.target.value)} placeholder="Write your academic response here…" />
            <div><button className="btn primary" disabled={!draft.trim()} onClick={() => { setTeacherSeed(`Review this Academic English response for "${unit.title}". Evaluate register, clarity, concision and grammar:\n\n${draft}`); go('teacher'); }}>Review with AI Teacher</button></div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ================================================================ Progress & Analytics

export function AnalyticsPage() {
  const { me } = useApp();
  const attempts = [...(me.recentAttempts || [])].reverse();
  const bandPoints = attempts.filter((a) => (a.headline ?? a.writing ?? a.speaking ?? a.listening ?? a.reading) != null);

  return (
    <div className="page fade-in">
      <div><h1>Progress & Analytics</h1><div className="muted">Measured strictly from your real recorded exams, practice sets, grammar drills, and SM-2 reviews.</div></div>
      <div className="grid" style={{ '--min': '180px' }}>
        <div className="card"><div className="tiny muted">Estimated Band</div><div style={{ fontSize: 30, fontWeight: 800 }}>{fmtBand(me.bands.overall ?? me.bands.partial)}</div><div className="tiny muted">Target {fmtBand(me.targetBand)}</div></div>
        <div className="card"><div className="tiny muted">Grammar Mastered</div><div style={{ fontSize: 30, fontWeight: 800 }}>{me.grammarMastered}/{me.grammarTotal}</div><div className="tiny muted">Verified exercises</div></div>
        <div className="card"><div className="tiny muted">Vocabulary Due</div><div style={{ fontSize: 30, fontWeight: 800 }}>{me.dueVocab}</div><div className="tiny muted">SM-2 review queue</div></div>
        <div className="card"><div className="tiny muted">Open Mistakes</div><div style={{ fontSize: 30, fontWeight: 800 }}>{me.openMistakes}</div><div className="tiny muted">{me.answers} total answers</div></div>
      </div>

      <div className="card pad-lg stack">
        <h3>Module performance vs target ({fmtBand(me.targetBand)})</h3>
        {['listening', 'reading', 'writing', 'speaking'].map((m) => (
          <SkillBar key={m} title={m[0].toUpperCase() + m.slice(1)} value={(me.bands[m] ?? 0) / 9} right={fmtBand(me.bands[m])} color={moduleColor(m)} />
        ))}
      </div>

      <div className="card pad-lg stack">
        <h3>Band score trend</h3>
        {bandPoints.length < 2 ? <div className="small muted">Complete at least 2 scored tests to plot your trend line.</div> : (
          <svg viewBox="0 0 600 180" style={{ width: '100%', height: 'auto' }}>
            {[3, 5, 7, 9].map((v) => {
              const y = 160 - (v / 9) * 140;
              return <g key={v}><line x1="36" x2="585" y1={y} y2={y} stroke="currentColor" opacity=".1" /><text x="28" y={y + 4} fontSize="10" textAnchor="end" fill="currentColor" opacity=".6">{v}.0</text></g>;
            })}
            <polyline fill="none" stroke="var(--primary)" strokeWidth="2.5" points={bandPoints.map((a, i) => {
              const x = 44 + (i / Math.max(1, bandPoints.length - 1)) * 530;
              const val = a.headline ?? a.writing ?? a.speaking ?? a.listening ?? a.reading ?? 0;
              const y = 160 - (val / 9) * 140;
              return `${x},${y}`;
            }).join(' ')} />
          </svg>
        )}
      </div>

      {me.mastery.length > 0 && (
        <div className="card pad-lg stack">
          <h3>Skill accuracy breakdown</h3>
          {[...me.mastery].sort((a, b) => a.accuracy - b.accuracy).map((m) => (
            <SkillBar key={m.module + m.skillTag} title={`${m.title} (${m.module})`} value={m.accuracy} right={`${pct(m.accuracy)} · ${m.correct}/${m.attempts}`} />
          ))}
        </div>
      )}
    </div>
  );
}

// ================================================================ Resource Library (18 Verified Sources & 16 Band 7-9 Guides)

export function ResourceLibraryPage() {
  const [data, setData] = useState(null);
  const [query, setQuery] = useState('');
  const [modFilter, setModFilter] = useState('All');

  useEffect(() => { api('/api/resources').then(setData); }, []);
  if (!data) return <div className="page muted">Loading IELTS Resource Library…</div>;

  const docs = (data.knowledgeDocs || []).filter((d) =>
    (modFilter === 'All' || d.module === modFilter)
    && (!query || `${d.title} ${d.category} ${d.content}`.toLowerCase().includes(query.toLowerCase()))
  );
  const sources = (data.sources || []).filter((s) =>
    !query || `${s.sourceName} ${s.category} ${s.summary}`.toLowerCase().includes(query.toLowerCase())
  );

  return (
    <div className="page fade-in">
      <div><h1>IELTS Resource Library & Band 9 Knowledge Base</h1><div className="muted">{data.sources?.length || 0} verified authoritative sources and {data.knowledgeDocs?.length || 0} structured Band 7–9 reference guides powering your AI Teacher RAG.</div></div>

      <div className="row">
        <input className="input" style={{ maxWidth: 320 }} placeholder="Search guides, Band 9 strategies, sources…" value={query} onChange={(e) => setQuery(e.target.value)} />
        <div className="seg">{['All', 'General', 'Listening', 'Reading', 'Writing', 'Speaking'].map((m) => <button key={m} className={modFilter === m ? 'on' : ''} onClick={() => setModFilter(m)}>{m}</button>)}</div>
      </div>

      <div className="eyebrow">Band 7 → 9 Strategy Guides & Official Criteria ({docs.length})</div>
      <div className="stack" style={{ gap: 12 }}>
        {docs.map((d) => (
          <details key={d.id} className="card">
            <summary style={{ cursor: 'pointer', fontWeight: 700, display: 'flex', alignItems: 'center', gap: 8 }}>
              <span className="badge blue">{d.module}</span>
              <span className="badge">{d.category}</span>
              <span>{d.title}</span>
            </summary>
            <div className="small" style={{ marginTop: 12, whiteSpace: 'pre-wrap', lineHeight: 1.7 }}>{d.content}</div>
            <div className="tiny muted" style={{ marginTop: 8 }}>Source: <a href={d.sourceURL} target="_blank" rel="noreferrer">{d.sourceName}</a></div>
          </details>
        ))}
      </div>

      <div className="eyebrow">Verified Authoritative Sources ({sources.length})</div>
      <div className="grid" style={{ '--min': '310px' }}>
        {sources.map((s) => (
          <div key={s.id} className="card stack" style={{ gap: 6 }}>
            <div className="row"><span className="badge ok">{s.verificationStatus}</span><span className="badge">{s.category}</span></div>
            <strong>{s.sourceName}</strong>
            <div className="small muted">{s.summary}</div>
            <div className="tiny"><a href={s.originalURL} target="_blank" rel="noreferrer">{s.originalURL}</a></div>
            <div className="tiny faint">{s.copyrightAndLicense}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
