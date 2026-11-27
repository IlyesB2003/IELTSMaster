import React, { useEffect, useRef, useState } from 'react';
import { accuracyColor, fmtBand, speakDialogue, stopSpeaking, ttsAvailable, startRecording, micAvailable, recognitionAvailable } from './lib.js';

export function BandRing({ score, target, size = 120 }) {
  const stroke = Math.max(7, size * 0.085), r = (size - stroke) / 2, c = 2 * Math.PI * r;
  const p = Math.min(Math.max((score ?? 0) / 9, 0), 1), t = Math.min(Math.max((target ?? 9) / 9, 0), 1);
  const ta = t * 2 * Math.PI - Math.PI / 2;
  return (
    <div className="ring-wrap" style={{ width: size, height: size }} aria-label={`Band ${fmtBand(score)}, target ${fmtBand(target)}`}>
      <svg width={size} height={size}>
        <defs><linearGradient id="rg" x1="0" x2="1"><stop offset="0" stopColor="#3B82F6" /><stop offset="1" stopColor="#2CC3A9" /></linearGradient></defs>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="var(--elev)" strokeWidth={stroke} />
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="url(#rg)" strokeWidth={stroke} strokeLinecap="round"
          strokeDasharray={`${c * p} ${c}`} transform={`rotate(-90 ${size / 2} ${size / 2})`} style={{ transition: 'stroke-dasharray .6s ease' }} />
        {target < 9 && <circle cx={size / 2 + r * Math.cos(ta)} cy={size / 2 + r * Math.sin(ta)} r={stroke * 0.42} fill="var(--gold)" />}
      </svg>
      <div className="ring-label"><div className="ring-score">{score == null ? '–' : fmtBand(score)}</div><div className="tiny muted">of 9</div></div>
    </div>
  );
}

export function Bar({ value, color = 'var(--primary)', height = 7 }) {
  return <div className="bar" style={{ height }}><i style={{ width: `${Math.max(3, Math.min(100, (value || 0) * 100))}%`, background: color }} /></div>;
}

export function SkillBar({ title, value, right, color }) {
  return (
    <div className="stack" style={{ gap: 6 }}>
      <div className="row" style={{ gap: 6 }}><span className="small" style={{ fontWeight: 600 }}>{title}</span><span className="spacer" /><span className="tiny" style={{ fontWeight: 700, color: color || accuracyColor(value) }}>{right}</span></div>
      <Bar value={value} color={color || accuracyColor(value)} />
    </div>
  );
}

export function Arabic({ text, title }) {
  if (!text) return null;
  return <div className="arabic">{title && <div className="tiny muted" style={{ fontWeight: 700 }}>{title}</div>}{text}</div>;
}

/** One question: options as radio buttons (or a dropdown for long lists), or a text field. Shows feedback after grading. */
export function Question({ q, value, onChange, result, onLearn, skillTitle }) {
  const done = !!result;
  const cls = done ? (result.correct ? 'ok' : 'bad') : '';
  return (
    <div className="card q fade-in">
      <div className="row top" style={{ flexWrap: 'nowrap' }}>
        <div className={`q-num ${cls}`}>{q.number}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontWeight: 600, marginBottom: 6 }}>{q.prompt}</div>
          <div className="row" style={{ gap: 6, marginBottom: 8 }}>
            <span className="badge">{q.format}</span>
            {q.maxWordCount ? <span className="badge">{q.maxWordCount === 1 ? 'One word' : `Max ${q.maxWordCount} words`}</span> : null}
          </div>
          {q.options?.length ? (
            q.options.length > 5 ? (
              <select className="select" value={value || ''} disabled={done} onChange={(e) => onChange(e.target.value)}>
                <option value="">Choose…</option>
                {q.options.map((o) => <option key={o} value={o}>{o}</option>)}
              </select>
            ) : (
              <div className="stack" style={{ gap: 2 }}>
                {q.options.map((o) => (
                  <label key={o} className={`opt ${value === o ? 'on' : ''}`}>
                    <input type="radio" name={q.id} checked={value === o} disabled={done} onChange={() => onChange(o)} />
                    <span>{o}</span>
                  </label>
                ))}
              </div>
            )
          ) : (
            <input className="input" value={value || ''} disabled={done} placeholder="Type your answer" onChange={(e) => onChange(e.target.value)} autoComplete="off" spellCheck={false} />
          )}
          {done && (
            <div className="feedback">
              <div style={{ fontWeight: 700, color: result.correct ? 'var(--ok)' : 'var(--bad)' }}>{result.correct ? '✓ Correct' : `✗ Answer: ${result.answer}`}</div>
              <div style={{ marginTop: 4 }}>{result.explanation}</div>
              {result.evidence && <div className="small muted" style={{ marginTop: 4, fontStyle: 'italic' }}>“{result.evidence}”</div>}
              {!result.correct && result.distractor && <div className="small" style={{ marginTop: 4, color: 'var(--warn)' }}>⚠ {result.distractor}</div>}
              {!result.correct && onLearn && <button className="btn link small" style={{ marginTop: 6 }} onClick={() => onLearn(q.skillTag)}>🎓 Learn: {skillTitle || q.skillTag}</button>}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

/** Plays listening dialogue with Chrome/Safari-hardened browser voices, speaker indicator, speed control & audio test. */
export function DialoguePlayer({ turns, once = false, label = 'Play recording' }) {
  const [state, setState] = useState('idle'); // idle | playing | done
  const [turnIdx, setTurnIdx] = useState(-1);
  const [speaker, setSpeaker] = useState('');
  const [rate, setRate] = useState(0.95);
  const [testOk, setTestOk] = useState(false);

  useEffect(() => () => stopSpeaking(), []);
  if (!ttsAvailable()) return <div className="notice">This browser can't play synthesised audio. Use Chrome, Edge or Safari.</div>;

  const play = async () => {
    setState('playing');
    setTurnIdx(0);
    const finished = await speakDialogue(turns, {
      rate,
      onTurn: (idx, t) => { setTurnIdx(idx); setSpeaker(t?.speaker || ''); },
    });
    setTurnIdx(-1);
    setSpeaker('');
    setState(finished && once ? 'done' : 'idle');
  };

  const testAudio = async () => {
    setTestOk(true);
    await speakDialogue([{ speaker: 'Check', accent: 'en-GB', text: 'Audio check. Your Listening sound is working clearly.' }], { rate: 1.0 });
    setTestOk(false);
  };

  return (
    <div className="stack" style={{ gap: 8 }}>
      <div className="row">
        {state === 'playing'
          ? <button className="btn primary lg" onClick={() => { stopSpeaking(); setTurnIdx(-1); setSpeaker(''); setState(once ? 'done' : 'idle'); }}>■ Stop</button>
          : <button className="btn primary lg" disabled={state === 'done'} onClick={play}>▶ {state === 'done' ? 'Played (exam once-only)' : label}</button>}
        {!once && (
          <div className="seg">
            {[[0.82, '0.85×'], [0.95, '1.0×'], [1.1, '1.15×']].map(([r, lbl]) => (
              <button key={lbl} className={rate === r ? 'on' : ''} disabled={state === 'playing'} onClick={() => setRate(r)}>{lbl}</button>
            ))}
          </div>
        )}
        {state !== 'playing' && <button className="btn sm" disabled={testOk} onClick={testAudio}>{testOk ? 'Testing…' : '🔊 Test sound'}</button>}
        <span className="small muted">{once ? 'Exam conditions: plays once only.' : 'Practice: replay & adjust speed freely.'}</span>
      </div>
      {state === 'playing' && turnIdx >= 0 && (
        <div className="stack" style={{ gap: 4 }}>
          <div className="row tiny"><span className="badge blue">🔊 Speaking: {speaker || 'Audio'}</span><span className="muted">Segment {turnIdx + 1} of {turns.length}</span></div>
          <Bar value={(turnIdx + 1) / Math.max(1, turns.length)} color="var(--listening)" height={5} />
        </div>
      )}
    </div>
  );
}

/** Microphone recorder with live level meter, Safari/Chrome compatibility, Mic Test, and editable transcript fallback. */
export function Recorder({ onDone, maxSeconds, autoStart = false, label = 'Record answer' }) {
  const [rec, setRec] = useState(null);
  const [level, setLevel] = useState(0);
  const [live, setLive] = useState('');
  const [manualText, setManualText] = useState('');
  const [secs, setSecs] = useState(0);
  const [error, setError] = useState('');
  const [result, setResult] = useState(null);
  const levels = useRef(Array(32).fill(0.05));
  const timer = useRef(null);

  const start = async () => {
    setError(''); setResult(null); setLive(''); setSecs(0);
    try {
      const r = await startRecording({ onTranscript: setLive, onLevel: (l) => { levels.current = [...levels.current.slice(1), l]; setLevel(l); } });
      setRec(r);
      const t0 = Date.now();
      timer.current = setInterval(() => { const s = Math.floor((Date.now() - t0) / 1000); setSecs(s); if (maxSeconds && s >= maxSeconds) stopNow(r); }, 250);
    } catch (e) {
      setError(e.name === 'NotAllowedError' ? 'Microphone access was blocked. Allow the microphone for this site in the browser address bar, then try again.' : `Microphone unavailable: ${e.message}`);
    }
  };
  const stopNow = async (r = rec) => {
    clearInterval(timer.current);
    if (!r) return;
    setRec(null);
    const out = await r.stop();
    const finalTranscript = out.transcript || manualText;
    const merged = { ...out, transcript: finalTranscript };
    setManualText(finalTranscript);
    setResult(merged);
    onDone?.(merged);
  };
  useEffect(() => { if (autoStart) start(); return () => clearInterval(timer.current); }, []); // eslint-disable-line

  if (!micAvailable()) return <div className="notice">This browser can't record audio. Use Chrome, Edge or Safari over https.</div>;
  const wordsCount = (rec ? live : manualText).split(/\s+/).filter(Boolean).length;
  const wpm = secs > 2 ? Math.round((wordsCount / secs) * 60) : 0;

  return (
    <div className="stack">
      <div className="row">
        {rec
          ? <button className="btn lg" style={{ color: 'var(--bad)' }} onClick={() => stopNow()}>■ Stop ({secs}s{maxSeconds ? ` / ${maxSeconds}s` : ''})</button>
          : <button className="btn primary lg" onClick={start}>● {result ? 'Record again' : label}</button>}
        {result?.url && <audio controls src={result.url} style={{ height: 36 }} />}
        {wordsCount > 0 && <span className="badge teal">{wordsCount} words{wpm ? ` · ~${wpm} WPM` : ''}</span>}
      </div>
      {rec && <div className="wave" aria-label="Live microphone waveform">{levels.current.map((l, i) => <i key={i} style={{ height: `${Math.max(4, l * 44)}px` }} />)}</div>}
      {!recognitionAvailable() && <div className="tiny muted">Live speech-to-text is limited in this browser — your audio is still recorded cleanly, and you can type/paste your transcript below for scoring.</div>}
      {rec && live && <div className="small" style={{ background: 'var(--elev)', borderRadius: 10, padding: '8px 12px' }}><span className="tiny muted">Live transcript: </span>{live}</div>}
      {!rec && result && (
        <textarea
          className="textarea"
          rows={2}
          value={manualText}
          placeholder="Transcript captured here (you can edit minor speech-recognition typos before scoring)…"
          onChange={(e) => {
            setManualText(e.target.value);
            const updated = { ...result, transcript: e.target.value };
            setResult(updated);
            onDone?.(updated);
          }}
        />
      )}
      {error && <div className="notice">{error}</div>}
    </div>
  );
}

/** Countdown that restarts whenever `seconds`, `running` or `resetKey` changes. */
export function useCountdown(seconds, running, onExpire, resetKey) {
  const [left, setLeft] = useState(seconds);
  const cb = useRef(onExpire);
  cb.current = onExpire;
  useEffect(() => {
    setLeft(seconds);
    if (!running) return undefined;
    const end = Date.now() + seconds * 1000;
    let fired = false;
    const id = setInterval(() => {
      const l = Math.max(0, Math.round((end - Date.now()) / 1000));
      setLeft(l);
      if (l === 0 && !fired) { fired = true; clearInterval(id); cb.current?.(); }
    }, 500);
    return () => clearInterval(id);
  }, [seconds, running, resetKey]);
  return left;
}

export const fmtTime = (s) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;

/** Instruction box shown above a group of questions (as on the real test paper), with shared options and plans. */
export function GroupHeader({ group }) {
  if (!group) return null;
  return (
    <div className="group-head">
      <div className="group-ins">{group.instruction}</div>
      {group.map && <PlanMap map={group.map} />}
      {group.options?.length > 0 && (
        <div className="group-opts">{group.options.map((o) => <div key={o}>{o}</div>)}</div>
      )}
    </div>
  );
}

/** Renders a simple labelled plan from a grid description: cells = [col, row, w, h, label]. Single letters are answer slots. */
export function PlanMap({ map }) {
  const cw = 120, ch = 70, pad = 8;
  const W = map.cols * cw + pad * 2, H = map.rows * ch + pad * 2;
  return (
    <div style={{ overflowX: 'auto' }}>
      <svg viewBox={`0 0 ${W} ${H}`} style={{ width: '100%', maxWidth: 520, height: 'auto', display: 'block' }} role="img" aria-label="Plan">
        <rect x="1" y="1" width={W - 2} height={H - 2} rx="10" fill="none" stroke="currentColor" opacity=".35" />
        {map.cells.map(([c, r, w, h, label], i) => {
          const slot = /^[A-Z]$/.test(label);
          const x = pad + c * cw + 4, y = pad + r * ch + 4, ww = w * cw - 8, hh = h * ch - 8;
          return (
            <g key={i}>
              <rect x={x} y={y} width={ww} height={hh} rx="8" fill={slot ? 'var(--primary)' : 'var(--elev)'} fillOpacity={slot ? 0.14 : 1} stroke={slot ? 'var(--primary)' : 'currentColor'} strokeOpacity={slot ? 0.9 : 0.2} />
              <text x={x + ww / 2} y={y + hh / 2 + (slot ? 8 : 4)} textAnchor="middle" fontSize={slot ? 24 : 12} fontWeight={slot ? 800 : 500} fill={slot ? 'var(--primary)' : 'currentColor'}>{label}</text>
            </g>
          );
        })}
      </svg>
      {map.note && <div className="tiny muted" style={{ marginTop: 6 }}>{map.note}</div>}
    </div>
  );
}

/** Renders questions with their group instructions, like the printed test. */
export function QuestionList({ questions, groups, render }) {
  const byStart = Object.fromEntries((groups || []).map((g) => [g.from, g]));
  return questions.map((q) => (
    <React.Fragment key={q.id}>
      {byStart[q.number] && <GroupHeader group={byStart[q.number]} />}
      {render(q)}
    </React.Fragment>
  ));
}
