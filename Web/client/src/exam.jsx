import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useApp } from './App.jsx';
import { api, fmtBand, wordCount, speak, stopSpeaking } from './lib.js';
import { Question, DialoguePlayer, Recorder, useCountdown, fmtTime, SkillBar, QuestionList } from './components.jsx';

// ================================================================ chart for Writing Task 1

export function Task1Chart({ task }) {
  const pts = task.dataPoints || [];
  const v = task.visualType || '';
  if (/process/i.test(v)) return <ProcessVisual steps={task.processSteps} />;
  if (/map/i.test(v)) return <MapVisual steps={task.processSteps} />;
  if (!pts.length) return null;
  if (/pie/i.test(v)) return <PieVisual pts={pts} />;
  if (/table/i.test(v)) return <TableVisual pts={pts} />;
  if (/combined/i.test(v)) {
    const bars = pts.filter((p) => !p.series.startsWith('~'));
    const lines = pts.filter((p) => p.series.startsWith('~')).map((p) => ({ ...p, series: p.series.slice(1) }));
    return <div className="stack">{bars.length > 0 && <BarLine pts={bars} />}{lines.length > 0 && <BarLine pts={lines} isLine />}</div>;
  }
  return <BarLine pts={pts} isLine={/line/i.test(v)} />;
}

const T1COLORS = ['#3B82F6', '#2CC3A9', '#E8B04B', '#8B5CF6', '#EF6F6C', '#64748B', '#14B8A6'];

function BarLine({ pts, isLine }) {
  const series = [...new Set(pts.map((p) => p.series))];
  const cats = [...new Set(pts.map((p) => p.category))];
  const max = Math.max(...pts.map((p) => p.value)) * 1.1 || 1;
  const W = 640, H = 300, L = 46, B = 54, T = 20, R = 10, iw = W - L - R, ih = H - T - B;
  const y = (val) => T + ih - (val / max) * ih;
  const unit = pts[0].unit;
  return (
    <div className="card" style={{ overflowX: 'auto' }}>
      <svg viewBox={`0 0 ${W} ${H}`} style={{ width: '100%', minWidth: 480, height: 'auto' }} role="img">
        {[0, 0.25, 0.5, 0.75, 1].map((f) => <g key={f}><line x1={L} x2={W - R} y1={y(max * f)} y2={y(max * f)} stroke="currentColor" opacity=".1" /><text x={L - 6} y={y(max * f) + 4} fontSize="11" textAnchor="end" fill="currentColor" opacity=".6">{Math.round(max * f)}</text></g>)}
        {isLine
          ? series.map((s, si) => {
            const xs = (i) => L + (i + 0.5) * (iw / cats.length);
            const d = cats.map((c, i) => `${i ? 'L' : 'M'}${xs(i)},${y(pts.find((p) => p.series === s && p.category === c)?.value || 0)}`).join(' ');
            return <g key={s}><path d={d} fill="none" stroke={T1COLORS[si % 7]} strokeWidth="2.5" />{cats.map((c, i) => <circle key={c} cx={xs(i)} cy={y(pts.find((p) => p.series === s && p.category === c)?.value || 0)} r="3.5" fill={T1COLORS[si % 7]} />)}</g>;
          })
          : cats.map((c, ci) => {
            const gw = iw / cats.length, bw = (gw * 0.75) / series.length;
            return series.map((s, si) => { const val = pts.find((p) => p.series === s && p.category === c)?.value || 0; const x = L + ci * gw + gw * 0.125 + si * bw; return <rect key={s + c} x={x} y={y(val)} width={bw - 2} height={T + ih - y(val)} rx="2" fill={T1COLORS[si % 7]} />; });
          })}
        {cats.map((c, i) => <text key={c} x={L + (i + 0.5) * (iw / cats.length)} y={H - B + 16} fontSize="11" textAnchor="middle" fill="currentColor" opacity=".75">{c}</text>)}
        {series.map((s, si) => <g key={s} transform={`translate(${L + si * 120},${H - 16})`}><rect width="10" height="10" fill={T1COLORS[si % 7]} rx="2" /><text x="14" y="9" fontSize="11" fill="currentColor">{s}</text></g>)}
        <text x={W - R} y={T - 2} fontSize="10" textAnchor="end" fill="currentColor" opacity=".6">Values in {unit}</text>
      </svg>
    </div>
  );
}

function PieVisual({ pts }) {
  const groups = [...new Set(pts.map((p) => p.series))];
  const cats = [...new Set(pts.map((p) => p.category))];
  return (
    <div className="card">
      <div className="row" style={{ justifyContent: 'center', gap: 28 }}>
        {groups.map((g) => {
          const items = pts.filter((p) => p.series === g); const total = items.reduce((s, p) => s + p.value, 0) || 1;
          let a = -Math.PI / 2;
          return (
            <div key={g} className="stack" style={{ alignItems: 'center', gap: 6 }}>
              <svg viewBox="-110 -110 220 220" style={{ width: 200, height: 200 }}>
                {items.map((p) => {
                  const ci = cats.indexOf(p.category); const a0 = a; a += (p.value / total) * Math.PI * 2; const a1 = a;
                  const large = a1 - a0 > Math.PI ? 1 : 0; const mid = (a0 + a1) / 2;
                  return <g key={p.category}><path d={`M0,0 L${100 * Math.cos(a0)},${100 * Math.sin(a0)} A100,100 0 ${large} 1 ${100 * Math.cos(a1)},${100 * Math.sin(a1)} Z`} fill={T1COLORS[ci % 7]} stroke="var(--card)" strokeWidth="1.5" />
                    {p.value / total > 0.05 && <text x={64 * Math.cos(mid)} y={64 * Math.sin(mid) + 4} fontSize="12" fontWeight="700" textAnchor="middle" fill="#fff">{p.value}{p.unit === '%' ? '%' : ''}</text>}</g>;
                })}
              </svg>
              <strong>{g}</strong>
            </div>
          );
        })}
      </div>
      <div className="row" style={{ justifyContent: 'center', gap: 14, marginTop: 8 }}>{cats.map((c, i) => <span key={c} className="small row" style={{ gap: 6 }}><i style={{ width: 10, height: 10, borderRadius: 2, background: T1COLORS[i % 7], display: 'inline-block' }} />{c}</span>)}</div>
    </div>
  );
}

function TableVisual({ pts }) {
  const cols = [...new Set(pts.map((p) => p.series))];
  const rows = [...new Set(pts.map((p) => p.category))];
  const unit = pts[0]?.unit;
  return (
    <div className="card" style={{ overflowX: 'auto' }}>
      <table className="data-table">
        <thead><tr><th>{unit ? `(${unit})` : ''}</th>{cols.map((c) => <th key={c}>{c}</th>)}</tr></thead>
        <tbody>{rows.map((r) => <tr key={r}><td>{r}</td>{cols.map((c) => { const v = pts.find((p) => p.series === c && p.category === r)?.value; return <td key={c}>{v == null ? '–' : Number(v).toLocaleString('en-GB')}</td>; })}</tr>)}</tbody>
      </table>
    </div>
  );
}

function ProcessVisual({ steps = [] }) {
  return (
    <div className="card">
      <div className="row" style={{ gap: 8, alignItems: 'stretch' }}>
        {steps.map((s, i) => (
          <React.Fragment key={i}>
            <div style={{ flex: '1 1 150px', background: 'var(--elev)', borderRadius: 12, padding: '10px 12px', minWidth: 140 }}>
              <div className="tiny" style={{ color: 'var(--primary)', fontWeight: 800 }}>Stage {i + 1}</div>
              <div className="small">{s}</div>
            </div>
            {i < steps.length - 1 && <div style={{ alignSelf: 'center', opacity: 0.5 }}>→</div>}
          </React.Fragment>
        ))}
      </div>
    </div>
  );
}

/** Map comparison: processSteps entries are "Label|zone|feature", zones = NW N NE W C E SW S SE. */
function MapVisual({ steps = [] }) {
  const ZONES = ['NW', 'N', 'NE', 'W', 'C', 'E', 'SW', 'S', 'SE'];
  const maps = {};
  for (const s of steps) { const [label, zone, feat] = s.split('|'); if (!feat) continue; ((maps[label] ??= {})[zone.trim()] ??= []).push(feat.trim()); }
  return (
    <div className="card">
      <div className="row" style={{ gap: 18, alignItems: 'flex-start' }}>
        {Object.entries(maps).map(([label, zones]) => (
          <div key={label} className="stack" style={{ flex: '1 1 260px', gap: 6 }}>
            <strong style={{ textAlign: 'center' }}>{label}</strong>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 4, border: '1px solid var(--border)', borderRadius: 12, padding: 6 }}>
              {ZONES.map((z) => <div key={z} style={{ minHeight: 64, background: zones[z] ? 'var(--elev)' : 'transparent', borderRadius: 8, padding: 6, fontSize: 12, textAlign: 'center', display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 2 }}>{(zones[z] || []).map((f) => <div key={f}>{f}</div>)}</div>)}
            </div>
          </div>
        ))}
      </div>
      <div className="tiny muted" style={{ marginTop: 6, textAlign: 'center' }}>North is at the top.</div>
    </div>
  );
}

export function WritingFeedback({ r, task }) {
  if (!r) return null;
  const names = { taskAchievement: task === 1 ? 'Task Achievement' : 'Task Response', coherenceCohesion: 'Coherence & Cohesion', lexicalResource: 'Lexical Resource', grammaticalRange: 'Grammatical Range & Accuracy' };
  return (
    <div className="card pad-lg stack fade-in">
      <div className="row"><h3>Task {task} feedback</h3><span className="spacer" /><span className="badge blue">Band {fmtBand(r.band)}</span>{!r.aiUsed && <span className="badge warn">Low-confidence estimate</span>}</div>
      <div className="small muted">{r.words} words · {r.aiUsed ? `AI rubric (${r.model}) — an estimate, not an official score` : ''}</div>
      {r.criteria && <div className="grid" style={{ '--min': '200px' }}>{Object.entries(r.criteria).map(([k, v]) => <SkillBar key={k} title={names[k]} value={v / 9} right={fmtBand(v)} color="var(--writing)" />)}</div>}
      {r.summary && <div>{r.summary}</div>}
      {r.strengths?.length > 0 && <div><strong className="small">Strengths</strong>{r.strengths.map((s, i) => <div key={i} className="small">✓ {s}</div>)}</div>}
      {r.improvements?.length > 0 && <div><strong className="small">To improve</strong>{r.improvements.map((s, i) => <div key={i} className="small">→ {s}</div>)}</div>}
      {r.corrections?.length > 0 && <div className="stack" style={{ gap: 8 }}><strong className="small">Sentence corrections</strong>{r.corrections.map((c, i) => (
        <div key={i} className="small" style={{ background: 'var(--elev)', borderRadius: 10, padding: '8px 12px' }}>
          <div style={{ textDecoration: 'line-through', color: 'var(--bad)' }}>{c.original}</div><div style={{ color: 'var(--ok)', fontWeight: 600 }}>{c.corrected}</div><div className="muted">{c.why}</div>
        </div>))}</div>}
      {r.vocabularyUpgrades?.length > 0 && <div><strong className="small">Vocabulary</strong>{r.vocabularyUpgrades.map((s, i) => <div key={i} className="small">• {s}</div>)}</div>}
    </div>
  );
}

function SpeakingFeedback({ r }) {
  if (!r) return null;
  return (
    <div className="card pad-lg stack fade-in">
      <div className="row"><h3>Speaking feedback</h3><span className="spacer" />{r.band != null ? <span className="badge blue">Band {fmtBand(r.band)}</span> : <span className="badge warn">No band</span>}</div>
      <div className="row small muted" style={{ gap: 14 }}><span>{r.metrics.words} words</span><span>{r.metrics.wpm} words/min</span><span>{r.metrics.fillers} fillers</span><span>variety {Math.round(r.metrics.diversity * 100)}%</span></div>
      {r.criteria && <div className="grid" style={{ '--min': '200px' }}>{[['fluencyCoherence', 'Fluency & Coherence'], ['lexicalResource', 'Lexical Resource'], ['grammaticalRange', 'Grammatical Range']].map(([k, n]) => <SkillBar key={k} title={n} value={r.criteria[k] / 9} right={fmtBand(r.criteria[k])} color="var(--speaking)" />)}</div>}
      <div className="small muted">{r.pronunciationNote}</div>
      {r.summary && <div>{r.summary}</div>}
      {r.improvements?.map((s, i) => <div key={i} className="small">→ {s}</div>)}
      {r.betterPhrases?.length > 0 && <div><strong className="small">Better ways to say it</strong>{r.betterPhrases.map((s, i) => <div key={i} className="small">• {s}</div>)}</div>}
    </div>
  );
}

// ================================================================ speaking parts (shared by exam + practice)

function SpeakingSection({ set, onComplete }) {
  const [part, setPart] = useState(1);
  const [qi, setQi] = useState(0);
  const [prep, setPrep] = useState(false);
  const [talk, setTalk] = useState(false);
  const outs = useRef({});
  const prepLeft = useCountdown(set.part2CueCard.prepSeconds || 60, prep, () => { setPrep(false); setTalk(true); speak('Please start speaking now.'); });
  useEffect(() => () => stopSpeaking(), []);
  const qs = part === 1 ? set.part1Questions : set.part3Questions;
  const ask = (i) => { setQi(i); speak(qs[i], 'en-GB', 0.95); };
  const done = (p) => (o) => { outs.current[p] = o; };
  const finish = () => {
    const parts = Object.values(outs.current);
    onComplete({ transcript: parts.map((o) => o.transcript).join(' '), seconds: parts.reduce((s, o) => s + o.seconds, 0), questions: [...set.part1Questions, set.part2CueCard.topic, ...set.part3Questions] });
  };
  return (
    <div className="stack" style={{ gap: 16 }}>
      <div className="seg">{[1, 2, 3].map((p) => <button key={p} className={part === p ? 'on' : ''} onClick={() => { stopSpeaking(); setPart(p); setQi(0); }}>Part {p}</button>)}</div>
      {part !== 2 ? (
        <div className="card pad-lg stack">
          <h3>Part {part}: {part === 1 ? 'introduction and familiar topics' : 'discussion'}</h3>
          <div className="small muted">Press “Ask” to hear the examiner, then answer aloud. Record the whole part in one go{part === 1 ? '; aim for 2–3 sentences per answer' : '; give reasons and examples'}.</div>
          {qs.map((q, i) => (
            <div key={i} className="row" style={{ flexWrap: 'nowrap', opacity: i <= qi ? 1 : 0.55 }}>
              <button className="btn sm" onClick={() => ask(i)}>🔊 Ask</button><span className={i === qi ? '' : 'muted'} style={{ fontWeight: i === qi ? 600 : 400 }}>{q}</span>
            </div>
          ))}
          <Recorder key={`p${part}`} onDone={done(part)} label={`Record Part ${part}`} />
          <div className="row"><button className="btn primary" onClick={() => { stopSpeaking(); if (part === 1) { setPart(2); } else finish(); }}>{part === 1 ? 'Continue to Part 2 →' : 'Finish Speaking'}</button></div>
        </div>
      ) : (
        <div className="card pad-lg stack">
          <h3>Part 2: long turn</h3>
          <div className="card" style={{ background: 'var(--elev)' }}><strong>{set.part2CueCard.topic}</strong><div className="small" style={{ marginTop: 6 }}>You should say:</div>{set.part2CueCard.bulletPoints.map((b, i) => <div key={i} className="small">• {b}</div>)}</div>
          {!prep && !talk && <div className="row"><button className="btn primary" onClick={() => { setPrep(true); speak('You have one minute to prepare. You can make notes.'); }}>Start 1-minute preparation</button><button className="btn" onClick={() => setTalk(true)}>Skip preparation</button></div>}
          {prep && <div className="row"><span className={`timer ${prepLeft < 10 ? 'low' : ''}`}>{fmtTime(prepLeft)}</span><span className="small muted">Prepare: make notes on each point.</span></div>}
          {talk && <Recorder key="p2" autoStart maxSeconds={set.part2CueCard.speakSeconds || 120} onDone={done(2)} label="Record your talk" />}
          <div className="row"><button className="btn primary" onClick={() => { stopSpeaking(); setPart(3); setQi(0); }}>Continue to Part 3 →</button></div>
        </div>
      )}
    </div>
  );
}

// ================================================================ exams list

export function Exams({ arg }) {
  const { me, go } = useApp();
  const [picking, setPicking] = useState(false);
  const [query, setQuery] = useState('');
  const [diff, setDiff] = useState('All');
  const [showCompleted, setShowCompleted] = useState(false);
  if (arg) return <ExamRunner examId={arg} />;
  const startRandom = async () => {
    setPicking(true);
    try {
      const r = await api('/api/exams/random', { method: 'POST', body: {} });
      go('exams', r.id);
    } finally { setPicking(false); }
  };
  const unseenCount = me.exams.filter((e) => !e.attempts).length;
  const filtered = me.exams.filter((e) =>
    (showCompleted || !e.attempts)
    && (diff === 'All' || e.difficulty.toLowerCase().includes(diff.toLowerCase()))
    && (!query || `${e.title} ${e.theme} ${e.writing1} ${e.writing2}`.toLowerCase().includes(query.toLowerCase()))
  );
  return (
    <div className="page fade-in">
      <div className="row">
        <div><h1>Full mock exams ({unseenCount} new of {me.exams.length})</h1><div className="muted" style={{ maxWidth: 740 }}>Realistic IELTS Academic computer-delivered simulations (Listening → Reading → Writing → Speaking), completely separate from your {me.practiceExams?.length || 40} dedicated single-module practice sets. Completed exams are automatically hidden so every exam you take is brand-new.</div></div>
        <span className="spacer" />
        <button className="btn primary lg" disabled={picking} onClick={startRandom}>{picking ? 'Choosing…' : 'Random fresh mock'}</button>
      </div>
      <div className="row">
        <input className="input" style={{ maxWidth: 260 }} placeholder="Search exams by topic or theme…" value={query} onChange={(e) => setQuery(e.target.value)} />
        <div className="seg">{['All', 'Foundation', 'Standard', 'Target', 'Advanced'].map((d) => <button key={d} className={diff === d ? 'on' : ''} onClick={() => setDiff(d)}>{d}</button>)}</div>
        <label className="row small" style={{ gap: 6, cursor: 'pointer' }}><input type="checkbox" checked={showCompleted} onChange={(e) => setShowCompleted(e.target.checked)} />Show completed</label>
      </div>
      {me.recommended && !query && diff === 'All' && (
        <div className="card cta">
          <div className="icon-tile grad">{me.recommended.attempts ? '↻' : '★'}</div>
          <div className="grow"><div className="eyebrow" style={{ color: 'var(--primary)' }}>{me.recommended.attempts ? 'Recommended retake' : 'Recommended next'}</div><h3>{me.recommended.title}</h3><div className="small muted">About 2 h 45 min. Find a quiet place and use headphones and a microphone.</div></div>
          <button className="btn primary lg" onClick={() => go('exams', me.recommended.id)}>Start exam</button>
        </div>
      )}
      <div className="grid" style={{ '--min': '300px' }}>
        {filtered.map((e) => (
          <div key={e.id} className="card stack">
            <div className="row" style={{ gap: 6 }}><span className="badge">{e.title.split(':')[0]}</span><span className="badge blue">{e.difficulty.split(' (')[0]}</span><span className="spacer" />{e.attempts ? <span className="badge warn">Taken {e.attempts}×</span> : <span className="badge teal">New</span>}</div>
            <h3>{e.theme}</h3>
            <div className="small muted">Listening 4 parts · Reading 3 passages · Writing: {e.writing1.toLowerCase()} + {e.writing2.toLowerCase()} · Speaking 3 parts</div>
            {e.best != null && <div className="small">Best: <strong>{fmtBand(e.best)}</strong></div>}
            <button className={`btn ${e.attempts ? '' : 'primary'}`} onClick={() => go('exams', e.id)}>{e.attempts ? '↻ Retake exam' : '▶ Start exam'}</button>
          </div>
        ))}
      </div>
    </div>
  );
}

// ================================================================ exam runner

const STAGES = ['intro', 'listening', 'reading', 'writing', 'speaking', 'scoring', 'results'];

function ExamRunner({ examId, only = null }) {
  const { go, refresh, setTeacherSeed } = useApp();
  const key = `exam-draft-${only ? only + '-' : ''}${examId}`;
  const home = only || 'exams';
  const [section, setSection] = useState(null);
  const [exam, setExam] = useState(null);
  const [stage, setStage] = useState('intro');
  const [ans, setAns] = useState(() => { try { return JSON.parse(localStorage.getItem(key)) || { listening: {}, reading: {}, w1: '', w2: '' }; } catch { return { listening: {}, reading: {}, w1: '', w2: '' }; } });
  const [partIdx, setPartIdx] = useState(0);
  const [passIdx, setPassIdx] = useState(0);
  const [task, setTask] = useState(1);
  const [speakingOut, setSpeakingOut] = useState(null);
  const [scoring, setScoring] = useState('');
  const [result, setResult] = useState(null);
  const [readAloud, setReadAloud] = useState(false);

  useEffect(() => { api(`/api/exams/${examId}`).then(setExam); return () => stopSpeaking(); }, [examId]);
  useEffect(() => { localStorage.setItem(key, JSON.stringify(ans)); }, [ans]); // autosave answers

  const limits = { listening: 32 * 60, reading: 60 * 60, writing: 60 * 60 };
  const next = (s) => { stopSpeaking(); setStage(s); document.querySelector('.main')?.scrollTo(0, 0); };
  const left = useCountdown(limits[stage] || 0, ['listening', 'reading', 'writing'].includes(stage), () => (only ? submitSection() : next(STAGES[STAGES.indexOf(stage) + 1])), stage);

  const submitSection = async () => {
    next('scoring');
    try {
      setScoring(`Marking ${only === 'listening' ? 'Listening' : 'Reading'}…`);
      const r = await api(`/api/exams/${examId}/section`, { method: 'POST', body: { module: only, answers: ans[only] } });
      setSection(r); localStorage.removeItem(key); await refresh(); next('results');
    } catch (e) { setScoring(`Something went wrong: ${e.message}. Your answers are saved in this browser; try again.`); }
  };

  const finish = async (sp) => {
    setSpeakingOut(sp); next('scoring');
    try {
      setScoring('Marking Listening and Reading…');
      const obj = await api(`/api/exams/${examId}/objective`, { method: 'POST', body: { listening: ans.listening, reading: ans.reading } });
      setScoring('Evaluating Writing Task 1… (a local model can take a minute)');
      const w1 = await api('/api/evaluate/writing', { method: 'POST', body: { task: 1, prompt: exam.writingTask1.instructions, text: ans.w1 } });
      setScoring('Evaluating Writing Task 2…');
      const w2 = await api('/api/evaluate/writing', { method: 'POST', body: { task: 2, prompt: exam.writingTask2.promptText, text: ans.w2 } });
      setScoring('Evaluating Speaking…');
      const s = sp ? await api('/api/evaluate/speaking', { method: 'POST', body: sp }) : null;
      const done = await api(`/api/exams/${examId}/complete`, { method: 'POST', body: { listening: obj.listening.band, reading: obj.reading.band, writing1: w1.band, writing2: w2.band, speaking: s?.band ?? null } });
      setResult({ obj, w1, w2, s, attempt: done.attempt });
      localStorage.removeItem(key);
      await refresh();
      next('results');
    } catch (e) { setScoring(`Something went wrong: ${e.message}. Your answers are saved in this browser; try again.`); }
  };

  if (!exam) return <div className="page muted">Loading exam…</div>;
  const bar = (title, extra) => (
    <div className="sticky-bar">
      <strong>{exam.title.split(':')[0]} · {title}</strong><span className="spacer" />{extra}
      {limits[stage] && <span className={`timer ${left < 300 ? 'low' : ''}`}>⏱ {fmtTime(left)}</span>}
    </div>
  );
  const setL = (id, v) => setAns({ ...ans, listening: { ...ans.listening, [id]: v } });
  const setR = (id, v) => setAns({ ...ans, reading: { ...ans.reading, [id]: v } });

  if (stage === 'intro') return (
    <div className="page fade-in" style={{ maxWidth: 820 }}>
      <button className="btn sm" style={{ alignSelf: 'flex-start' }} onClick={() => go(home)}>‹ Back</button>
      <h1>{only ? `${only === 'listening' ? 'Listening' : 'Reading'} test · ` : ''}{exam.title}</h1>
      {only ? (
      <div className="card pad-lg stack">
        <h3>Before you start</h3>
        {only === 'listening'
          ? <><div>• 4 parts, 40 questions, about 30 minutes. Each recording plays <strong>once</strong>, as in the real test.</div><div>• Read the questions before you press Play. Answer while you listen.</div></>
          : <><div>• 3 passages, 40 questions, 60 minutes. Move between passages freely.</div><div>• The timer submits your answers automatically at zero.</div></>}
        <div className="small muted">You get a band score using the official raw-score table, every wrong answer explained, and your mistakes go to the AI Teacher and Mistake Notebook.</div>
        {only === 'listening' && <div className="notice info">Use headphones. Chrome or Safari give the best voices.</div>}
        <div><button className="btn primary lg" onClick={() => next(only)}>Start {only === 'listening' ? 'Listening' : 'Reading'}</button></div>
      </div>) : (
      <div className="card pad-lg stack">
        <h3>Before you start</h3>
        <div>• Listening: about 30 minutes, 4 parts, 40 questions. Each recording plays <strong>once</strong>.</div>
        <div>• Reading: 60 minutes, 3 passages, 40 questions.</div>
        <div>• Writing: 60 minutes. Task 1 (150+ words, about 20 min) and Task 2 (250+ words, about 40 min; counts double).</div>
        <div>• Speaking: about 11–14 minutes, 3 parts, with an examiner voice and your microphone.</div>
        <div className="small muted">No hints, translation or AI help during the exam. Answers are saved in this browser as you go. Each timer moves you on automatically when it reaches zero.</div>
        <div className="notice info">Use headphones. Allow the microphone when your browser asks (Speaking). Chrome or Safari give the best results.</div>
        <div><button className="btn primary lg" onClick={() => next('listening')}>Start Listening</button></div>
      </div>)}
    </div>
  );

  if (stage === 'listening') {
    const p = exam.listeningParts[partIdx];
    return (
      <div className="fade-in">
        {bar(`Listening · Part ${partIdx + 1} of 4`, <button className="btn primary sm" onClick={() => (partIdx < 3 ? (stopSpeaking(), setPartIdx(partIdx + 1)) : only ? submitSection() : next('reading'))}>{partIdx < 3 ? 'Next part →' : only ? 'Submit answers ✓' : 'Finish Listening →'}</button>)}
        <div className="page" style={{ maxWidth: 860 }}>
          <div className="card stack"><h3>{p.title}</h3><div className="small muted">{p.contextDescription}</div><DialoguePlayer key={p.id} turns={p.dialogue} once label={`Play Part ${partIdx + 1}`} /></div>
          <QuestionList questions={p.questions} groups={p.groups} render={(q) => <Question q={q} value={ans.listening[q.id]} onChange={(v) => setL(q.id, v)} />} />
        </div>
      </div>
    );
  }

  if (stage === 'reading') {
    const p = exam.readingPassages[passIdx];
    return (
      <div className="fade-in">
        {bar('Reading', <><div className="seg">{exam.readingPassages.map((x, i) => <button key={x.id} className={i === passIdx ? 'on' : ''} onClick={() => setPassIdx(i)}>Passage {i + 1}</button>)}</div>{only === 'reading' && <button className={`btn sm ${readAloud ? 'primary' : ''}`} onClick={() => setReadAloud(!readAloud)}>{readAloud ? 'Hide Mic' : '🎙️ Read Aloud'}</button>}<button className="btn primary sm" onClick={() => (only ? submitSection() : next('writing'))}>{only ? 'Submit answers ✓' : 'Finish Reading →'}</button></>)}
        {only === 'reading' && readAloud && (
          <div className="page" style={{ maxWidth: 960, paddingBottom: 0 }}>
            <div className="card stack">
              <div className="small muted">Practice reading this passage aloud to build academic fluency and pronunciation confidence.</div>
              <Recorder key={`read-${p.id}`} label="Record reading aloud" onDone={() => {}} />
            </div>
          </div>
        )}
        <div className="split">
          <div className="passage" style={{ maxWidth: 760 }}><h2 style={{ marginBottom: 14 }}>{p.title}</h2>{p.paragraphs.map((t, i) => <p key={i}><span className="plabel">{String.fromCharCode(65 + i)}</span>{t}</p>)}</div>
          <div className="stack" style={{ gap: 12 }}><QuestionList questions={p.questions} groups={p.groups} render={(q) => <Question q={q} value={ans.reading[q.id]} onChange={(v) => setR(q.id, v)} />} /></div>
        </div>
      </div>
    );
  }

  if (stage === 'writing') {
    const t = task === 1 ? exam.writingTask1 : exam.writingTask2;
    const text = task === 1 ? ans.w1 : ans.w2;
    const words = wordCount(text), min = task === 1 ? 150 : 250;
    return (
      <div className="fade-in">
        {bar('Writing', <><div className="seg"><button className={task === 1 ? 'on' : ''} onClick={() => setTask(1)}>Task 1 · {wordCount(ans.w1)}w</button><button className={task === 2 ? 'on' : ''} onClick={() => setTask(2)}>Task 2 · {wordCount(ans.w2)}w</button></div><button className="btn primary sm" onClick={() => next('speaking')}>Finish Writing →</button></>)}
        <div className="page" style={{ maxWidth: 900 }}>
          <div className="card stack"><div className="eyebrow">Task {task}{task === 1 ? ` · ${t.visualType}` : ` · ${t.essayType}`}</div><div style={{ fontWeight: 600 }}>{task === 1 ? t.instructions : t.promptText}</div>{task === 2 && <div className="small muted">Give reasons for your answer and include any relevant examples from your own knowledge or experience. Write at least 250 words.</div>}</div>
          {task === 1 && <Task1Chart task={t} />}
          <textarea className="textarea" style={{ minHeight: 360, fontSize: 16 }} spellCheck={false} value={text} placeholder="Write your answer here…" onChange={(e) => setAns({ ...ans, [task === 1 ? 'w1' : 'w2']: e.target.value })} />
          <div className="row small"><span style={{ color: words >= min ? 'var(--ok)' : 'var(--muted)', fontWeight: 600 }}>{words} / {min}+ words</span><span className="muted">Spell-check is off, as in the real test.</span></div>
        </div>
      </div>
    );
  }

  if (stage === 'speaking') return (
    <div className="fade-in">
      {bar('Speaking', <button className="btn sm" onClick={() => finish(null)}>Skip Speaking</button>)}
      <div className="page" style={{ maxWidth: 860 }}><SpeakingSection set={exam.speakingSet} onComplete={finish} /></div>
    </div>
  );

  if (stage === 'scoring') return <div className="page" style={{ maxWidth: 700 }}><div className="card pad-lg stack" style={{ alignItems: 'center', textAlign: 'center' }}><div style={{ fontSize: 40 }}>⏳</div><h2>Scoring your exam</h2><div className="muted">{scoring}</div></div></div>;

  if (only && section) {
    const name = only === 'listening' ? 'Listening' : 'Reading';
    const wrongS = section.results.filter((r) => !r.correct);
    const teachS = () => {
      const lines = wrongS.slice(0, 20).map((r) => `- [${r.skillTag}] "${r.prompt}" — I answered "${r.response || '(blank)'}", correct "${r.answer}"`).join('\n');
      setTeacherSeed(`I just finished the ${name} test of ${exam.title}: ${section.raw}/40 (band ${fmtBand(section.band)}).\nHere are my wrong answers:\n${lines || '(none)'}\nFind the patterns behind my mistakes, teach me the 2-3 most important ones step by step with examples, then test me with new questions.`);
      go('teacher');
    };
    return (
      <div className="page fade-in">
        <div className="row"><div><h1>{name} result</h1><div className="muted">{exam.title}</div></div><span className="spacer" />{wrongS.length > 0 && <button className="btn primary lg" onClick={teachS}>🧑‍🏫 Learn from my mistakes</button>}</div>
        <div className="grid" style={{ '--min': '180px' }}>
          <div className="card" style={{ borderColor: 'var(--gold)' }}><div className="tiny muted">Band (estimate)</div><div style={{ fontSize: 34, fontWeight: 800 }}>{fmtBand(section.band)}</div><div className="tiny muted">official raw-score table</div></div>
          <div className="card"><div className="tiny muted">Correct</div><div style={{ fontSize: 34, fontWeight: 800 }}>{section.raw}/{section.total}</div><div className="tiny muted">{wrongS.length} to review</div></div>
        </div>
        <div className="card stack"><h3>Answer review</h3>
          {section.results.map((r) => <div key={r.id} className="small" style={{ borderTop: '1px solid var(--border)', paddingTop: 8 }}><span className={`badge ${r.correct ? 'teal' : 'warn'}`}>{r.correct ? '✓' : '✗'} Q{r.number ?? ''}</span> <strong>{r.prompt}</strong><div>You: <span style={{ color: r.correct ? 'var(--ok)' : 'var(--bad)' }}>{r.response || '(blank)'}</span>{!r.correct && <> · Correct: <span style={{ color: 'var(--ok)', fontWeight: 600 }}>{r.answer}</span></>}</div>{!r.correct && <div className="muted">{r.explanation}</div>}</div>)}
        </div>
        <div className="row"><button className="btn" onClick={() => go(home)}>Other {name} tests</button><button className="btn" onClick={() => go('exams')}>Full mock exams</button></div>
      </div>
    );
  }

  // results
  const { obj, w1, w2, s, attempt } = result;
  const wrong = [...obj.listening.results.map((r) => ({ ...r, module: 'Listening' })), ...obj.reading.results.map((r) => ({ ...r, module: 'Reading' }))].filter((r) => !r.correct);
  const teach = () => {
    const lines = wrong.slice(0, 20).map((r) => `- ${r.module} [${r.skillTag}] "${r.prompt}" — I answered "${r.response || '(blank)'}", correct "${r.answer}"`).join('\n');
    setTeacherSeed(`I just finished ${exam.title}. Listening ${obj.listening.raw}/40, Reading ${obj.reading.raw}/40, Writing ${fmtBand(attempt.writing)}${s?.band != null ? `, Speaking ${fmtBand(s.band)}` : ''}.
Here are my wrong answers:\n${lines || '(none)'}\n${w2.improvements?.length ? `Writing feedback: ${w2.improvements.slice(0, 3).join('; ')}` : ''}
Find the patterns behind my mistakes, teach me the 2-3 most important ones step by step with examples, then test me with new questions.`);
    go('teacher');
  };
  return (
    <div className="page fade-in">
      <div className="row"><div><h1>Your result</h1><div className="muted">{exam.title}</div></div><span className="spacer" /><button className="btn primary lg" onClick={teach}>🧑‍🏫 Learn from my mistakes</button></div>
      <div className="grid" style={{ '--min': '160px' }}>
        {[['Listening', obj.listening.band, `${obj.listening.raw}/40`], ['Reading', obj.reading.band, `${obj.reading.raw}/40`], ['Writing', attempt.writing, `T1 ${fmtBand(w1.band)} · T2 ${fmtBand(w2.band)}`], ['Speaking', s?.band, s?.band == null ? 'not scored' : 'estimate']].map(([n, b, d]) => (
          <div key={n} className="card"><div className="tiny muted">{n}</div><div style={{ fontSize: 30, fontWeight: 800 }}>{fmtBand(b)}</div><div className="tiny muted">{d}</div></div>
        ))}
        <div className="card" style={{ borderColor: 'var(--gold)' }}><div className="tiny muted">{attempt.overall != null ? 'Overall (estimate)' : 'Average of scored modules'}</div><div style={{ fontSize: 30, fontWeight: 800 }}>{fmtBand(attempt.headline)}</div><div className="tiny muted">official rounding</div></div>
      </div>
      <div className="small muted">Listening and Reading use the published raw-score conversion. Writing and Speaking are AI rubric estimates{w1.aiUsed ? '' : ' (no model reachable: low confidence)'}. None of these are official IELTS results.</div>
      <WritingFeedback r={w1} task={1} /><WritingFeedback r={w2} task={2} /><SpeakingFeedback r={s} />
      <div className="card stack"><h3>Wrong answers ({wrong.length})</h3><div className="small muted">All are saved in your Mistake Notebook and update your Skills Coach.</div>
        {wrong.map((r) => <div key={r.id} className="small" style={{ borderTop: '1px solid var(--border)', paddingTop: 8 }}><span className="badge">{r.module}</span> <strong>{r.prompt}</strong><div>You: <span style={{ color: 'var(--bad)' }}>{r.response || '(blank)'}</span> · Correct: <span style={{ color: 'var(--ok)', fontWeight: 600 }}>{r.answer}</span></div><div className="muted">{r.explanation}</div></div>)}
      </div>
      <div className="row"><button className="btn" onClick={() => go('exams')}>All exams</button><button className="btn" onClick={() => go('coach')}>Skills Coach</button></div>
    </div>
  );
}

// ================================================================ standalone writing & speaking

function usePrompts() {
  const [data, setData] = useState(null);
  useEffect(() => { api('/api/prompts').then(setData); }, []);
  return data;
}
const pickOther = (list, cur) => { const o = list.filter((x) => x.id !== cur); return (o[Math.floor(Math.random() * o.length)] || list[0])?.id; };

export function WritingPage() {
  const data = usePrompts();
  const [task, setTask] = useState(2);
  const [kind, setKind] = useState('all');
  const [id, setId] = useState(null);
  const [text, setText] = useState('');
  const [busy, setBusy] = useState(false);
  const [fb, setFb] = useState(null);
  const [samples, setSamples] = useState(null);
  const [showSamples, setShowSamples] = useState(false);
  useEffect(() => { if (showSamples && !samples) api('/api/curriculum').then((d) => setSamples(d.writingSamples || [])); }, [showSamples, samples]);
  if (!data) return <div className="page muted">Loading…</div>;
  const all = task === 1 ? data.writing1 : data.writing2;
  const kinds = [...new Set(all.map((t) => (task === 1 ? t.visualType : t.essayType)))];
  const list = kind === 'all' ? all : all.filter((t) => (task === 1 ? t.visualType : t.essayType) === kind);
  const t = list.find((x) => x.id === id) || list[0];
  const reset = () => { setFb(null); setText(''); };
  if (!t) return <div className="page muted">No prompts yet.</div>;
  const words = wordCount(text), min = task === 1 ? 150 : 250;
  const evaluate = async () => {
    setBusy(true); setFb(null);
    try { const r = await api('/api/evaluate/writing', { method: 'POST', body: { task, prompt: task === 1 ? t.instructions : t.promptText, text } }); setFb(r); if (r.band != null) api('/api/attempts/single', { method: 'POST', body: { module: 'writing', band: r.band, title: `Writing Task ${task}: ${t.title}` } }); }
    finally { setBusy(false); }
  };
  return (
    <div className="page fade-in" style={{ maxWidth: 940 }}>
      <div className="row">
        <div><h1>Writing Practice</h1><div className="muted">{data.writing1.length} Task 1 visuals and {data.writing2.length} Task 2 essays, separate from the full mock exams, with criterion-by-criterion feedback and Band 4–9 model essays.</div></div>
        <span className="spacer" />
        <button className="btn" onClick={() => { setId(pickOther(list, t.id)); reset(); }}>🎲 Random prompt</button>
        <button className="btn" onClick={() => setShowSamples(!showSamples)}>{showSamples ? 'Hide Band 4–9 samples' : 'Band 4–9 samples'}</button>
      </div>
      <div className="row">
        <div className="seg"><button className={task === 1 ? 'on' : ''} onClick={() => { setTask(1); setKind('all'); setId(null); reset(); }}>Task 1</button><button className={task === 2 ? 'on' : ''} onClick={() => { setTask(2); setKind('all'); setId(null); reset(); }}>Task 2</button></div>
        <select className="select" style={{ maxWidth: 260 }} value={kind} onChange={(e) => { setKind(e.target.value); setId(null); reset(); }}><option value="all">All types ({all.length})</option>{kinds.map((k) => <option key={k} value={k}>{k} ({all.filter((x) => (task === 1 ? x.visualType : x.essayType) === k).length})</option>)}</select>
        <select className="select" style={{ maxWidth: 380 }} value={t.id} onChange={(e) => { setId(e.target.value); reset(); }}>{list.map((x, i) => <option key={x.id} value={x.id}>{i + 1}. {x.title}</option>)}</select>
      </div>
      <div className="card stack"><div className="eyebrow">{task === 1 ? t.visualType : `${t.essayType} · ${t.topicDomain || ''}`}</div><div style={{ fontWeight: 600 }}>{task === 1 ? t.instructions : t.promptText}</div>{task === 2 && <div className="small muted">Give reasons for your answer and include any relevant examples from your own knowledge or experience. Write at least 250 words.</div>}</div>
      {task === 1 && <Task1Chart task={t} />}
      <textarea className="textarea" style={{ minHeight: 320, fontSize: 16 }} spellCheck={false} value={text} onChange={(e) => setText(e.target.value)} placeholder="Write your answer here…" />
      <div className="row"><span className="small" style={{ fontWeight: 600, color: words >= min ? 'var(--ok)' : 'var(--muted)' }}>{words} / {min}+ words</span><span className="spacer" /><button className="btn primary lg" disabled={busy || !words} onClick={evaluate}>{busy ? 'Evaluating… (up to a minute)' : 'Get feedback'}</button></div>
      <WritingFeedback r={fb} task={task} />
      {showSamples && samples && (
        <div className="card pad-lg stack">
          <h3>Illustrative Band 4.0 to Band 9.0 Model Samples</h3>
          <div className="tiny muted">Original educational examples illustrating official IELTS Writing band descriptors (not official exam scripts).</div>
          {samples.filter((s) => s.taskNumber === task).map((s) => (
            <details key={s.id} style={{ borderTop: '1px solid var(--border)', paddingTop: 10 }}>
              <summary style={{ cursor: 'pointer', fontWeight: 700 }}>Task {s.taskNumber} · Band {fmtBand(s.estimatedBand)} — {s.promptSummary.slice(0, 90)}…</summary>
              <div className="small" style={{ marginTop: 10, whiteSpace: 'pre-wrap', lineHeight: 1.7 }}>{s.essayText}</div>
              <div className="small" style={{ marginTop: 8, color: 'var(--primary)' }}>{s.examinerNotes}</div>
            </details>
          ))}
        </div>
      )}
    </div>
  );
}

export function SpeakingPage() {
  const data = usePrompts();
  const [id, setId] = useState(null);
  const [fb, setFb] = useState(null);
  const [busy, setBusy] = useState(false);
  const [round, setRound] = useState(0);
  if (!data) return <div className="page muted">Loading…</div>;
  const list = data.speaking;
  const set = list.find((x) => x.id === id) || list[0];
  if (!set) return <div className="page muted">No topics yet.</div>;
  const complete = async (sp) => {
    setBusy(true);
    try { const r = await api('/api/evaluate/speaking', { method: 'POST', body: sp }); setFb(r); if (r.band != null) api('/api/attempts/single', { method: 'POST', body: { module: 'speaking', band: r.band, title: `Speaking: ${set.theme}` } }); }
    finally { setBusy(false); }
  };
  return (
    <div className="page fade-in" style={{ maxWidth: 900 }}>
      <div className="row">
        <div><h1>Speaking Practice</h1><div className="muted">{list.length} complete Part 1–2–3 topics. The examiner asks the questions aloud; you answer into your microphone and get a transcript, fluency measures and rubric feedback. An accent is never penalised.</div></div>
        <span className="spacer" />
        <button className="btn" onClick={() => { setId(pickOther(list, set.id)); setFb(null); setRound(round + 1); }}>🎲 Random topic</button>
      </div>
      <div className="row"><select className="select" style={{ maxWidth: 420 }} value={set.id} onChange={(e) => { setId(e.target.value); setFb(null); setRound(round + 1); }}>{list.map((x, i) => <option key={x.id} value={x.id}>{i + 1}. {x.theme}</option>)}</select></div>
      {fb ? <><SpeakingFeedback r={fb} /><div><button className="btn" onClick={() => { setFb(null); setRound(round + 1); }}>Try again</button></div></>
        : busy ? <div className="card muted">Evaluating your answers…</div>
          : <SpeakingSection key={round + set.id} set={set} onComplete={complete} />}
    </div>
  );
}


// ================================================================ standalone full Listening / Reading tests

function SectionPage({ arg, only }) {
  const { me, go } = useApp();
  const [showCompleted, setShowCompleted] = useState(false);
  if (arg) return <ExamRunner examId={arg} only={only} />;
  const isL = only === 'listening';
  const pool = me.practiceExams || [];
  const unseen = pool.filter((e) => !e.attempts);
  const visible = showCompleted ? pool : (unseen.length ? unseen : pool);
  const startRandom = () => {
    const candidates = unseen.length ? unseen : pool;
    const pick = candidates[Math.floor(Math.random() * candidates.length)];
    if (pick) go(only, pick.id);
  };
  return (
    <div className="page fade-in">
      <div className="row">
        <div><h1>{isL ? 'Listening' : 'Reading'} Practice ({unseen.length} new of {pool.length})</h1><div className="muted" style={{ maxWidth: 740 }}>Dedicated {isL ? '40-question Listening' : '40-question Academic Reading'} practice tests completely separate from your Full Mock Exams. Completed sets are hidden automatically so you always get fresh tests.</div></div>
        <span className="spacer" />
        <label className="row small" style={{ gap: 6, cursor: 'pointer' }}><input type="checkbox" checked={showCompleted} onChange={(e) => setShowCompleted(e.target.checked)} />Show completed</label>
        <button className="btn primary lg" onClick={startRandom}>Random fresh {isL ? 'Listening' : 'Reading'} test</button>
      </div>
      <div className="grid" style={{ '--min': '300px' }}>
        {visible.map((e) => (
          <div key={e.id} className="card stack">
            <div className="row" style={{ gap: 6 }}><span className="badge">{e.title.split(':')[0]}</span><span className="badge blue">{isL ? '4 parts · 40 Q · 30 min' : '3 passages · 40 Q · 60 min'}</span><span className="spacer" />{e.attempts ? <span className="badge warn">Taken {e.attempts}×</span> : <span className="badge teal">New</span>}</div>
            <h3>{e.theme}</h3>
            <button className="btn primary" onClick={() => go(only, e.id)}>▶ Start {isL ? 'Listening' : 'Reading'} test</button>
          </div>
        ))}
      </div>
      <div className="card row"><span className="grow small muted">Want the real thing end to end? The full mock runs Listening → Reading → Writing → Speaking in one sitting.</span><button className="btn" onClick={() => go('exams')}>📝 Full mock exams</button></div>
    </div>
  );
}

export function ListeningPage({ arg }) { return <SectionPage arg={arg} only="listening" />; }
export function ReadingPage({ arg }) { return <SectionPage arg={arg} only="reading" />; }
