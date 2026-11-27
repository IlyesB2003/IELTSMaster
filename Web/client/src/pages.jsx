import React, { useEffect, useMemo, useState } from 'react';
import { useApp } from './App.jsx';
import { api, fmtBand, pct, accuracyColor, moduleColor, stopSpeaking } from './lib.js';
import { BandRing, Bar, SkillBar, Question, DialoguePlayer, Arabic, Recorder, GroupHeader } from './components.jsx';

// ================================================================ Today

export function Today() {
  const { me, go, setFocus } = useApp();
  const b = me.bands;
  const hour = new Date().getHours();
  const greet = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
  const weak = me.weak[0];
  const next = weak
    ? { ico: '🎯', title: `Fix: ${weak.title}`, text: `You're getting ${pct(weak.accuracy)} right in ${weak.module} on this skill. Learn the method, then practise with new questions.`, btn: 'Learn & practise', act: () => { setFocus(weak.skillTag); go('coach'); } }
    : me.unseen.reading > 0
      ? { ico: '📖', title: 'New Reading set', text: "A passage you haven't seen yet. Every answer builds your skill profile.", btn: 'Start', act: () => go('practice', 'reading') }
      : me.recommended
        ? { ico: '📝', title: me.recommended.attempts ? 'Retake a full mock' : 'Take a full mock exam', text: me.recommended.title, btn: 'Open', act: () => go('exams') }
        : { ico: '✨', title: 'Keep practising', text: 'Listening and Writing are always available.', btn: 'Practice', act: () => go('practice') };
  const gap = b.partial != null ? me.targetBand - b.partial : null;
  return (
    <div className="page fade-in">
      <div><div className="small muted">{new Date().toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long' })}</div><h1>{greet}, {me.user.firstName}</h1></div>

      <div className="card pad-lg">
        <div className="row top" style={{ gap: 28 }}>
          <div className="row" style={{ gap: 18, flexWrap: 'nowrap' }}>
            <BandRing score={b.partial} target={me.targetBand} size={118} />
            <div className="stack" style={{ gap: 6, maxWidth: 260 }}>
              <div className="small muted">{b.overall != null ? 'Estimated overall band' : 'Estimated band so far'}</div>
              <div className="row" style={{ gap: 6 }}><span className="badge gold" style={{ cursor: 'pointer' }} onClick={() => go('account')}>🏁 Target {fmtBand(me.targetBand)}</span>{b.cefr && <span className="badge">CEFR ~{b.cefr}</span>}</div>
              <div className="small muted">
                {b.modulesMeasured === 0 ? 'Take a full mock exam to get your first band estimate.'
                  : gap > 0 ? `${gap.toFixed(1)} bands to your target. Raising your weakest module is the fastest way up.` : "You're at or above your target. Keep it steady with full mocks."}
              </div>
              <div className="tiny faint">Based on {b.modulesMeasured}/4 modules measured · estimate, not an official result</div>
            </div>
          </div>
          <div className="stack" style={{ flex: 1, minWidth: 240, gap: 12 }}>
            {['listening', 'reading', 'writing', 'speaking'].map((m) => (
              <SkillBar key={m} title={m[0].toUpperCase() + m.slice(1)} value={(b[m] ?? 0) / 9} right={fmtBand(b[m])} color={moduleColor(m)} />
            ))}
          </div>
        </div>
      </div>

      <div className="card cta">
        <div className="icon-tile grad">{next.ico}</div>
        <div className="grow"><div className="eyebrow" style={{ color: 'var(--primary)' }}>Next best step</div><h3>{next.title}</h3><div className="small muted">{next.text}</div></div>
        <button className="btn primary lg" onClick={next.act}>{next.btn}</button>
      </div>

      <div className="eyebrow">Start practising</div>
      <div className="grid" style={{ '--min': '250px' }}>
        <Tile ico="📖" color="var(--reading)" title="Reading set" text={me.unseen.reading ? `${me.unseen.reading} new passage${me.unseen.reading === 1 ? '' : 's'} · targets weak skills` : 'All seen · oldest returns first'} onClick={() => go('practice', 'reading')} />
        <Tile ico="🎧" color="var(--listening)" title="Listening part" text={me.unseen.listening ? `${me.unseen.listening} new parts · several accents` : 'All seen · oldest returns first'} onClick={() => go('practice', 'listening')} />
        <Tile ico="📝" color="var(--primary)" title="Full mock exam" text={me.recommended ? `${me.recommended.attempts ? 'Retake' : 'Next'}: ${me.recommended.title}` : '—'} onClick={() => go('exams')} />
        <Tile ico="✍️" color="var(--writing)" title="Writing task" text="Task 1 or 2 with criterion-by-criterion feedback" onClick={() => go('writing')} />
        <Tile ico="🎙️" color="var(--speaking)" title="Speaking test" text="Examiner voice, your microphone, transcript and feedback" onClick={() => go('speaking')} />
        <Tile ico="🧑‍🏫" color="var(--teal)" title="AI teacher" text="Lessons built from the mistakes in your exams" onClick={() => go('teacher')} />
      </div>

      <div className="grid" style={{ '--min': '340px' }}>
        <div className="card stack">
          <div className="row"><h3>Skills to work on</h3><span className="spacer" /><button className="btn link small" onClick={() => go('coach')}>Skills Coach</button></div>
          {me.weak.length === 0
            ? <div className="small muted">{me.answers < 10 ? 'Answer a few practice sets and your weak skills will appear here, measured from your real answers.' : 'Every skill you have practised is above 75%. Push yourself with a full mock.'}</div>
            : me.weak.slice(0, 4).map((w) => (
              <button key={w.module + w.skillTag} className="btn link" style={{ display: 'block', textAlign: 'left', color: 'inherit' }} onClick={() => { setFocus(w.skillTag); go('coach'); }}>
                <SkillBar title={`${w.title} · ${w.module}`} value={w.accuracy} right={pct(w.accuracy)} />
              </button>
            ))}
        </div>
        <div className="card stack">
          <h3>Recent results</h3>
          {me.recentAttempts.length === 0 ? <div className="small muted">Your results will appear here.</div> : me.recentAttempts.slice(0, 6).map((a) => (
            <div key={a.id} className="row" style={{ flexWrap: 'nowrap' }}>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div className="small" style={{ fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{a.title}</div>
                <div className="tiny muted">{a.type === 'full' ? 'Full mock' : a.type === 'practice' ? `${a.module} practice` : a.module} · {new Date(a.date).toLocaleDateString('en-GB')}</div>
              </div>
              <strong>{a.type === 'practice' ? `${a.raw}/${a.total}` : fmtBand(a.headline ?? a.writing ?? a.speaking)}</strong>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function Tile({ ico, color, title, text, onClick }) {
  return (
    <button className="tile" onClick={onClick}>
      <div className="icon-tile" style={{ background: `color-mix(in srgb, ${color} 15%, transparent)`, color }}>{ico}</div>
      <div style={{ flex: 1 }}><div style={{ fontWeight: 600 }}>{title}</div><div className="small muted">{text}</div></div>
      <span className="faint">›</span>
    </button>
  );
}

// ================================================================ Smart Practice

export function Practice({ arg }) {
  const { me, go, focus, setFocus, refresh } = useApp();
  const [unit, setUnit] = useState(null);
  const [error, setError] = useState('');
  const kind = arg === 'listening' ? 'listening' : arg === 'reading' ? 'reading' : null;

  useEffect(() => {
    if (!kind) return;
    api('/api/practice/next', { method: 'POST', body: { kind, focusSkill: focus } }).then(setUnit).catch((e) => setError(e.message));
    setFocus(null);
  }, [kind]); // eslint-disable-line

  if (kind && unit) return <PracticeSession unit={unit} onNext={async () => { setUnit(null); await refresh(); const u = await api('/api/practice/next', { method: 'POST', body: { kind, excludeId: unit.id } }); setUnit(u); }} onExit={() => { stopSpeaking(); refresh(); go('practice'); }} />;
  if (kind) return <div className="page"><div className="muted">{error || 'Choosing a set you haven’t seen…'}</div></div>;

  return (
    <div className="page fade-in">
      <div><h1>Smart Practice</h1><div className="muted" style={{ maxWidth: 760 }}>All four IELTS Academic modules drawn exclusively from the dedicated Practice Pool — completely separate from your Full Mock Exams. Nothing repeats until you have completed every unseen unit.</div></div>
      <div className="grid" style={{ '--min': '260px' }}>
        <KindCard ico="📖" color="var(--reading)" title="Reading" unseen={me.unseen.reading} total={me.unseen.readingTotal} text="Focused sessions of 2–4 questions with explanations and evidence. Several sessions may study different skills using the same practice text." onStart={() => go('practice', 'reading')} />
        <KindCard ico="🎧" color="var(--listening)" title="Listening" unseen={me.unseen.listening} total={me.unseen.listeningTotal} text="Focused sessions of 2–4 questions with replay. The transcript opens after submission. Full mock recordings remain separate." onStart={() => go('practice', 'listening')} />
        <KindCard ico="✍️" color="var(--writing)" title="Writing" unseen={me.unseen.writing ?? 0} total={me.unseen.writingTotal ?? 20} text="Task 1 visual data & process diagrams or Task 2 essays with criterion-by-criterion AI rubric feedback." onStart={() => go('writing')} />
        <KindCard ico="🎙️" color="var(--speaking)" title="Speaking" unseen={me.unseen.speaking ?? 0} total={me.unseen.speakingTotal ?? 10} text="Examiner voice, Parts 1–3 cue cards, microphone recording, live transcript and fluency analysis." onStart={() => go('speaking')} />
      </div>
      {me.mastery.length > 0 && <>
        <div className="eyebrow">Practise one skill</div>
        <div className="grid" style={{ '--min': '230px' }}>
          {[...me.mastery].sort((a, b) => a.accuracy - b.accuracy).slice(0, 9).map((m) => (
            <Tile key={m.module + m.skillTag} ico="🎯" color={accuracyColor(m.accuracy)} title={m.title} text={`${pct(m.accuracy)} right recently · ${m.module}`}
              onClick={() => { setFocus(m.skillTag); go('practice', m.module.toLowerCase()); }} />
          ))}
        </div>
      </>}
    </div>
  );
}

function KindCard({ ico, color, title, unseen, total, text, onStart }) {
  return (
    <div className="card pad-lg stack" style={{ gap: 12 }}>
      <div className="row"><div className="icon-tile" style={{ background: `color-mix(in srgb, ${color} 15%, transparent)`, color }}>{ico}</div><div><h2>{title}</h2><div className="small muted">{unseen} new of {total}</div></div></div>
      <div className="small muted">{text}</div>
      <Bar value={total ? (total - unseen) / total : 0} color={color} height={5} />
      <button className="btn primary lg" onClick={onStart}>▶ {unseen ? 'Start a new set' : 'Repeat the oldest set'}</button>
    </div>
  );
}

function highlight(text, phrases) {
  if (!phrases.length) return text;
  const lower = text.toLowerCase();
  const marks = [];
  for (const p of phrases) { const i = lower.indexOf(p.toLowerCase()); if (i >= 0) marks.push([i, i + p.length]); }
  if (!marks.length) return text;
  marks.sort((a, b) => a[0] - b[0]);
  const out = []; let pos = 0;
  marks.forEach(([s, e], k) => { if (s < pos) return; out.push(text.slice(pos, s)); out.push(<mark key={k}>{text.slice(s, e)}</mark>); pos = e; });
  out.push(text.slice(pos));
  return out;
}

export function PracticeSession({ unit, onNext, onExit }) {
  const { go, setFocus } = useApp();
  const [responses, setResponses] = useState({});
  const [graded, setGraded] = useState(null);
  const [busy, setBusy] = useState(false);
  const [showArabic, setShowArabic] = useState(false);
  const [showReadAloud, setShowReadAloud] = useState(false);
  const [lessons, setLessons] = useState(null);
  const questions = unit.passage?.questions || unit.part?.questions || [];
  const results = useMemo(() => Object.fromEntries((graded?.results || []).map((r) => [r.id, r])), [graded]);
  const wrongEvidence = (graded?.results || []).filter((r) => !r.correct && r.evidence).map((r) => r.evidence);
  const answered = questions.filter((q) => (responses[q.id] || '').trim()).length;

  useEffect(() => { if (graded && showArabic && !lessons) api('/api/lessons').then(setLessons); }, [graded, showArabic, lessons]);

  const submit = async () => {
    setBusy(true); stopSpeaking();
    try { setGraded(await api('/api/practice/submit', { method: 'POST', body: { unitId: unit.id, responses } })); } finally { setBusy(false); }
  };
  const learn = (tag) => { setFocus(tag); go('coach'); };
  const lessonFor = (tag) => lessons?.lessons.find((l) => l.skillTags.includes(tag));

  return (
    <div className="fade-in">
      <div className="sticky-bar">
        <button className="btn sm" onClick={onExit}>‹ Practice</button>
        <div style={{ minWidth: 0 }}><strong>{unit.passage?.title || unit.part?.title}</strong><div className="tiny muted">{unit.source}{unit.isRepeat ? ' · seen before' : ''}</div></div>
        <span className="spacer" />
        {graded && <button className={`btn sm ${showArabic ? 'primary' : ''}`} onClick={() => setShowArabic(!showArabic)}>عربي</button>}
        {graded ? <button className="btn primary" onClick={onNext}>Next set →</button>
          : <><span className="small muted">{answered}/{questions.length}</span><button className="btn primary" disabled={busy} onClick={submit}>{busy ? 'Marking…' : 'Submit'}</button></>}
      </div>
      <div className="split">
        <div>
          {unit.passage ? (
            <div className="passage" style={{ maxWidth: 720 }}>
              <div className="row" style={{ marginBottom: 8 }}>
                <div className="eyebrow" style={{ color: 'var(--reading)' }}>{unit.passage.discipline}</div>
                <span className="spacer" />
                <button className={`btn sm ${showReadAloud ? 'primary' : ''}`} onClick={() => setShowReadAloud(!showReadAloud)}>
                  {showReadAloud ? 'Hide Mic' : '🎙️ Read Aloud (Mic)'}
                </button>
              </div>
              {showReadAloud && (
                <div className="card stack" style={{ marginBottom: 14 }}>
                  <div className="small muted">Practice reading this passage aloud with your microphone to train academic fluency and pronunciation.</div>
                  <Recorder label="Record reading aloud" />
                </div>
              )}
              <h2 style={{ margin: '4px 0 16px' }}>{unit.passage.title}</h2>
              {unit.passage.paragraphs.map((p, i) => <p key={i}><span className="plabel">{String.fromCharCode(65 + i)}</span>{highlight(p, wrongEvidence)}</p>)}
            </div>
          ) : (
            <div className="stack" style={{ maxWidth: 720, gap: 14 }}>
              <div className="eyebrow" style={{ color: 'var(--listening)' }}>Part {unit.part.partNumber}</div>
              <h2>{unit.part.title}</h2>
              <div className="small muted">{unit.part.contextDescription}</div>
              <DialoguePlayer turns={unit.part.dialogue} />
              {graded?.transcript ? (
                <div className="card stack">
                  <h3>Transcript</h3><div className="tiny muted">Evidence for wrong answers is highlighted.</div>
                  {graded.transcript.map((t, i) => <div key={i}><div className="tiny muted" style={{ fontWeight: 700 }}>{t.speaker}</div><div>{highlight(t.text, wrongEvidence)}</div></div>)}
                </div>
              ) : <div className="card small muted">🔒 The transcript opens after you submit.</div>}
            </div>
          )}
        </div>
        <div className="stack" style={{ gap: 12 }}>
          {graded && (
            <div className="card stack">
              <div className="row"><span style={{ fontSize: 30, fontWeight: 800 }}>{graded.raw}/{graded.total}</span><span className="muted">correct</span></div>
              <div className="tiny muted">One set can't give a reliable band, so none is shown. Bands come from full 40-question tests.</div>
              {Object.entries(graded.results.reduce((acc, r) => { (acc[r.skillTag] ??= []).push(r); return acc; }, {}))
                .map(([tag, rs]) => ({ tag, right: rs.filter((r) => r.correct).length, total: rs.length }))
                .sort((a, b) => a.right / a.total - b.right / b.total)
                .map((s) => (
                  <div key={s.tag} className="row" style={{ flexWrap: 'nowrap' }}>
                    <div style={{ flex: 1 }}><SkillBar title={graded.skillTitles[s.tag]} value={s.right / s.total} right={`${s.right}/${s.total}`} /></div>
                    {s.right < s.total && <button className="btn sm" onClick={() => learn(s.tag)}>Lesson</button>}
                  </div>
                ))}
            </div>
          )}
          {questions.map((q) => (
            <div key={q.id}>
              {(unit.passage || unit.part)?.groups?.find((g) => g.from === q.number) && <div style={{ marginBottom: 10 }}><GroupHeader group={(unit.passage || unit.part).groups.find((g) => g.from === q.number)} /></div>}
              <Question q={q} value={responses[q.id]} onChange={(v) => setResponses({ ...responses, [q.id]: v })} result={results[q.id]} onLearn={learn} skillTitle={graded?.skillTitles?.[q.skillTag]} />
              {results[q.id] && !results[q.id].correct && showArabic && lessonFor(q.skillTag) && <div style={{ marginTop: 8 }}><Arabic title={lessonFor(q.skillTag).arabicTitle} text={lessonFor(q.skillTag).arabicSummary} /></div>}
            </div>
          ))}
          {!graded && <button className="btn primary lg" disabled={busy} onClick={submit}>Submit answers</button>}
        </div>
      </div>
    </div>
  );
}

// ================================================================ Skills Coach

export function Coach() {
  const { me, go, focus, setFocus, setTeacherSeed } = useApp();
  const [data, setData] = useState(null);
  const [sel, setSel] = useState(null);
  useEffect(() => { api('/api/lessons').then(setData); }, []);
  if (!data) return <div className="page muted">Loading lessons…</div>;
  const lessons = data.lessons;
  const lesson = lessons.find((l) => l.id === sel) || (focus && lessons.find((l) => l.skillTags.includes(focus))) || (me.weak[0] && lessons.find((l) => l.skillTags.includes(me.weak[0].skillTag))) || lessons[0];
  const stats = me.mastery.filter((m) => lesson.skillTags.includes(m.skillTag));
  const kind = lesson.module === 'Listening' ? 'listening' : 'reading';
  return (
    <div className="page fade-in">
      <div><h1>Skills Coach</h1><div className="muted">{me.answers ? `Measured from your last ${me.answers} answers. Recent answers count most.` : 'Your skill profile builds from every answer you submit. All lessons are ready now.'}</div></div>
      <div className="coach-grid">
        <div className="stack">
          {me.weak.length > 0 && <><div className="eyebrow">Work on these first</div>{me.weak.map((w) => (
            <button key={w.module + w.skillTag} className="tile" style={{ display: 'block' }} onClick={() => { setFocus(null); setSel(lessons.find((l) => l.skillTags.includes(w.skillTag))?.id); }}>
              <SkillBar title={w.title} value={w.accuracy} right={pct(w.accuracy)} /><div className="tiny muted" style={{ marginTop: 4 }}>{w.module} · {w.correct}/{w.attempts} right · {w.confidence.toLowerCase()} confidence</div>
            </button>))}</>}
          <div className="eyebrow">All lessons</div>
          {lessons.map((l) => (
            <button key={l.id} className={`nav-item ${l.id === lesson.id ? 'active' : ''}`} onClick={() => { setFocus(null); setSel(l.id); }}>🎓 {l.title}</button>
          ))}
        </div>
        <div className="stack" style={{ gap: 16, maxWidth: 780 }}>
          <div><div className="eyebrow" style={{ color: moduleColor(lesson.module) }}>{lesson.module}</div><h1>{lesson.title}</h1><div className="muted" style={{ marginTop: 6 }}>{lesson.whatItTests}</div></div>
          {stats.length > 0 && <div className="grid" style={{ '--min': '170px' }}>{stats.map((s) => <div key={s.module + s.skillTag} className="card"><div className="tiny muted">{s.title} · {s.module}</div><div style={{ fontSize: 26, fontWeight: 800 }}>{pct(s.accuracy)}</div><div className="tiny muted">{s.correct} of {s.attempts} right</div></div>)}</div>}
          <div className="card pad-lg stack"><h3>The method</h3>{lesson.steps.map((s, i) => <div key={i} className="row top" style={{ flexWrap: 'nowrap' }}><span className="q-num">{i + 1}</span><span>{s}</span></div>)}</div>
          <div className="card pad-lg stack"><h3>💡 Worked example</h3><div style={{ lineHeight: 1.7 }}>{lesson.workedExample}</div></div>
          <div className="card pad-lg stack"><h3 style={{ color: 'var(--warn)' }}>⚠ Traps to avoid</h3>{lesson.traps.map((t, i) => <div key={i}>• {t}</div>)}</div>
          <Arabic title={lesson.arabicTitle} text={lesson.arabicSummary} />
          <div className="row">
            <button className="btn primary lg" onClick={() => { setFocus(lesson.skillTags[0]); go('practice', kind); }}>▶ Practise this now</button>
            <button className="btn lg" onClick={() => { setTeacherSeed(`Teach me "${lesson.title}" step by step, using my own mistakes on this skill. Then give me 3 short check questions and wait for my answers.`); go('teacher'); }}>🧑‍🏫 Ask the teacher to go deeper</button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ================================================================ Mistakes

export function Mistakes() {
  const { go, setTeacherSeed, setFocus } = useApp();
  const [list, setList] = useState(null);
  const [filter, setFilter] = useState('open');
  const load = () => api('/api/mistakes').then((d) => setList(d.mistakes));
  useEffect(() => { load(); }, []);
  if (!list) return <div className="page muted">Loading…</div>;
  const shown = list.filter((m) => (filter === 'open' ? !m.mastered : filter === 'repeat' ? m.count > 1 && !m.mastered : true));
  return (
    <div className="page fade-in">
      <div className="row"><div><h1>Mistake Notebook</h1><div className="muted">Every wrong answer from practice and exams, grouped so repeated mistakes stand out.</div></div><span className="spacer" />
        <button className="btn primary" disabled={!list.some((m) => !m.mastered)} onClick={() => { setTeacherSeed('Build me a revision lesson from my open mistakes: find the 2-3 patterns behind them, teach each one, then quiz me with new questions (not the same ones).'); go('teacher'); }}>🧑‍🏫 Revise with the teacher</button></div>
      <div className="seg">{[['open', 'Open'], ['repeat', 'Repeated'], ['all', 'All']].map(([k, l]) => <button key={k} className={filter === k ? 'on' : ''} onClick={() => setFilter(k)}>{l}</button>)}</div>
      {shown.length === 0 ? <div className="card muted">Nothing here. {filter === 'open' ? 'Great work.' : ''}</div> : shown.map((m) => (
        <div key={m.id} className="card stack" style={{ gap: 6 }}>
          <div className="row" style={{ gap: 6 }}><span className="badge" style={{ color: moduleColor(m.module) }}>{m.module}</span><span className="badge">{m.skillTitle}</span>{m.count > 1 && <span className="badge bad">×{m.count}</span>}<span className="spacer" /><span className="tiny muted">{new Date(m.date).toLocaleDateString('en-GB')}</span></div>
          <div style={{ fontWeight: 600 }}>{m.prompt}</div>
          <div className="small">Your answer: <span style={{ color: 'var(--bad)' }}>{m.response}</span> · Correct: <span style={{ color: 'var(--ok)', fontWeight: 600 }}>{m.answer}</span></div>
          <div className="small muted">{m.explanation}</div>
          <div className="row"><button className="btn sm" onClick={() => { setFocus(m.skillTag); go('coach'); }}>Lesson</button><button className="btn sm" onClick={async () => { await api(`/api/mistakes/${m.id}/mastered`, { method: 'POST' }); load(); }}>{m.mastered ? 'Mark as open' : '✓ I understand this now'}</button></div>
        </div>
      ))}
    </div>
  );
}

// ================================================================ Account

const BANDS = [5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9];
const DESC = (b) => (b < 6 ? 'Modest user' : b < 7 ? 'Competent user' : b < 8 ? 'Good user' : b < 9 ? 'Very good user' : 'Expert user');

export function Account() {
  const { me, refresh } = useApp();
  const [msg, setMsg] = useState('');
  const [pw, setPw] = useState({ current: '', next: '' });
  const setTarget = async (band) => { await api('/api/target', { method: 'POST', body: { band } }); await refresh(); setMsg(`Target set to ${fmtBand(band)}.`); };
  const changePw = async (e) => { e.preventDefault(); try { await api('/api/password', { method: 'POST', body: pw }); setPw({ current: '', next: '' }); setMsg('Password changed.'); } catch (err) { setMsg(err.message); } };
  const logout = async () => { await api('/api/logout', { method: 'POST' }); location.hash = ''; location.reload(); };
  return (
    <div className="page fade-in" style={{ maxWidth: 820 }}>
      <h1>Account & target</h1>
      <div className="card pad-lg stack">
        <h3>Target band</h3><div className="small muted">Your goal shapes recommendations, the teacher and the gap shown on Today. Change it any time.</div>
        <div className="grid" style={{ '--min': '130px', gap: 10 }}>
          {BANDS.map((b) => (
            <button key={b} className="tile" style={{ flexDirection: 'column', gap: 2, borderColor: me.targetBand === b ? 'var(--gold)' : undefined, background: me.targetBand === b ? 'color-mix(in srgb, var(--gold) 12%, var(--card))' : undefined }} onClick={() => setTarget(b)}>
              <strong style={{ fontSize: 22 }}>{fmtBand(b)}</strong><span className="tiny muted">{DESC(b)}</span>
            </button>
          ))}
        </div>
      </div>
      <form className="card pad-lg stack" onSubmit={changePw}>
        <h3>Change password</h3>
        <div className="grid" style={{ '--min': '220px' }}>
          <label className="field">Current password<input className="input" type="password" autoComplete="current-password" value={pw.current} onChange={(e) => setPw({ ...pw, current: e.target.value })} /></label>
          <label className="field">New password (8+ characters)<input className="input" type="password" autoComplete="new-password" value={pw.next} onChange={(e) => setPw({ ...pw, next: e.target.value })} /></label>
        </div>
        <div><button className="btn primary" disabled={!pw.current || pw.next.length < 8}>Change password</button></div>
      </form>
      <div className="card pad-lg row"><div><h3>{me.user.firstName} {me.user.lastName}</h3><div className="small muted">{me.user.email} · {me.user.role === 'admin' ? 'Administrator' : 'Learner'}</div></div><span className="spacer" /><button className="btn danger" onClick={logout}>Sign out</button></div>
      {msg && <div className="notice info">{msg}</div>}
    </div>
  );
}

// ================================================================ Admin

export function Admin() {
  const { me } = useApp();
  const [users, setUsers] = useState([]);
  const [sys, setSys] = useState(null);
  const [form, setForm] = useState({ firstName: '', lastName: '', email: '', password: '', role: 'user' });
  const [msg, setMsg] = useState('');
  const load = async () => { setUsers((await api('/api/admin/users')).users); setSys(await api('/api/admin/system')); };
  useEffect(() => { load(); }, []);
  const create = async (e) => {
    e.preventDefault(); setMsg('');
    try { await api('/api/admin/users', { method: 'POST', body: form }); setMsg(`Account created for ${form.email}. They can sign in now.`); setForm({ firstName: '', lastName: '', email: '', password: '', role: 'user' }); load(); }
    catch (err) { setMsg(err.message); }
  };
  const remove = async (u) => { if (!confirm(`Delete ${u.firstName} ${u.lastName}'s account and all their progress? They will be signed out everywhere. This can't be undone.`)) return; await api(`/api/admin/users/${u.id}`, { method: 'DELETE' }); load(); };
  const reset = async (u) => { const p = prompt(`New password for ${u.email} (6+ characters):`); if (!p) return; try { await api(`/api/admin/users/${u.id}/password`, { method: 'POST', body: { password: p } }); setMsg(`Password changed for ${u.email}; they've been signed out everywhere.`); } catch (err) { setMsg(err.message); } };
  return (
    <div className="page fade-in">
      <h1>Users</h1>
      <form className="card pad-lg stack" onSubmit={create}>
        <h3>Add an account</h3>
        <div className="grid" style={{ '--min': '200px' }}>
          <label className="field">First name<input className="input" value={form.firstName} onChange={(e) => setForm({ ...form, firstName: e.target.value })} required /></label>
          <label className="field">Last name<input className="input" value={form.lastName} onChange={(e) => setForm({ ...form, lastName: e.target.value })} required /></label>
          <label className="field">Email<input className="input" type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} required /></label>
          <label className="field">Password<input className="input" type="text" autoComplete="off" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} required minLength={6} /></label>
          <label className="field">Role<select className="select" value={form.role} onChange={(e) => setForm({ ...form, role: e.target.value })}><option value="user">Learner</option><option value="admin">Administrator</option></select></label>
        </div>
        <div><button className="btn primary">Create account</button></div>
        {msg && <div className="notice info">{msg}</div>}
      </form>
      <div className="card table-wrap">
        <table className="list">
          <thead><tr><th>Name</th><th>Email</th><th className="hide-sm">Role</th><th className="hide-sm">Answers</th><th className="hide-sm">Last active</th><th /></tr></thead>
          <tbody>{users.map((u) => (
            <tr key={u.id}>
              <td><strong>{u.firstName} {u.lastName}</strong></td><td className="small">{u.email}</td>
              <td className="hide-sm">{u.role === 'admin' ? <span className="badge gold">Admin</span> : <span className="badge">Learner</span>}</td>
              <td className="hide-sm small">{u.answers}</td><td className="hide-sm tiny muted">{u.lastSeen ? new Date(u.lastSeen).toLocaleString('en-GB') : 'never'}</td>
              <td style={{ textAlign: 'right', whiteSpace: 'nowrap' }}><button className="btn sm" onClick={() => reset(u)}>Reset password</button> {u.id !== me.user.id && <button className="btn sm danger" onClick={() => remove(u)}>Delete</button>}</td>
            </tr>))}</tbody>
        </table>
      </div>
      {sys && <div className="card stack">
        <h3>AI model (Ollama on this Mac)</h3>
        {sys.models.length === 0 ? <div className="notice">Ollama isn't running or has no models, so the teacher and AI scoring are offline. On the Mac: open Ollama, then run <code>ollama pull qwen2.5:7b</code>.</div>
          : <div className="row"><select className="select" style={{ maxWidth: 320 }} value={sys.model || ''} onChange={async (e) => { await api('/api/admin/model', { method: 'POST', body: { model: e.target.value } }); load(); }}>{sys.models.map((m) => <option key={m.name} value={m.name}>{m.name} ({m.sizeGB} GB)</option>)}</select><span className="small muted">Used for the teacher and for Writing/Speaking scoring.</span></div>}
        <div className="tiny muted">Content version {sys.contentVersion} · {sys.exams} exams</div>
      </div>}
    </div>
  );
}
