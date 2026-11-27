import React, { useEffect, useRef, useState } from 'react';
import { useApp } from './App.jsx';
import { api, streamText, pct } from './lib.js';

export function Teacher() {
  const { me, teacherSeed, setTeacherSeed } = useApp();
  const [messages, setMessages] = useState([]);
  const [model, setModel] = useState(undefined);
  const [input, setInput] = useState('');
  const [streaming, setStreaming] = useState(false);
  const [arabic, setArabic] = useState(false);
  const feed = useRef(null);
  const abort = useRef(null);

  useEffect(() => { api('/api/teacher').then((d) => { setMessages(d.messages); setModel(d.model); }); return () => abort.current?.abort(); }, []);
  useEffect(() => { feed.current?.scrollTo({ top: feed.current.scrollHeight, behavior: 'smooth' }); }, [messages]);
  useEffect(() => { if (teacherSeed && model !== undefined) { send(teacherSeed); setTeacherSeed(null); } }, [teacherSeed, model]); // eslint-disable-line

  const send = async (text) => {
    const t = (text ?? input).trim();
    if (!t || streaming) return;
    setInput('');
    setMessages((m) => [...m, { role: 'user', content: t }, { role: 'assistant', content: '' }]);
    setStreaming(true);
    abort.current = new AbortController();
    try {
      await streamText('/api/teacher/chat', { message: t, arabic }, (full) => setMessages((m) => [...m.slice(0, -1), { role: 'assistant', content: full }]), abort.current.signal);
    } catch (e) {
      if (e.name !== 'AbortError') setMessages((m) => [...m.slice(0, -1), { role: 'assistant', content: `⚠ ${e.message}` }]);
    } finally { setStreaming(false); }
  };

  const weak = me.weak[0];
  const chips = [
    ['Band 9 Upgrade Coach', `Act as my Band 9 IELTS coach. Look at my current bands, weakest skills, and mistakes, and give me a concrete Band 7 → 8 → 9 upgrade plan for today with 3 high-level drills.`],
    me.recentAttempts.some((a) => a.type === 'full') && ['Teach me from my last exam', 'Look at the mistakes from my most recent exams, find the patterns, and teach me the most important ones first. Then quiz me with new questions.'],
    weak && [`Fix: ${weak.title}`, `My weakest skill is ${weak.title} (${pct(weak.accuracy)} in ${weak.module}). Teach me the exact Band 9 method using my own mistakes, then give me 3 practice questions.`],
    ['Revise open mistakes', 'Build a short revision lesson from my open mistakes, then test me with brand-new questions on the same rules.'],
    ['Band 9 Essay Clinic', `Teach me how to upgrade a Band 7 Writing Task 2 paragraph to Band 9 (cohesion without mechanical linkers, hedging, and complex syntax), then ask me to rewrite a paragraph for critique.`],
    ['Speaking Part 3 Mock', 'Run an interactive Band 9 Speaking Part 3 abstract discussion with me. Ask one challenging question at a time, wait for my reply, then upgrade my phrasing and structure.'],
    ['Arabic L1 Interference Fix', 'Identify the top Arabic-to-English interference errors (articles, double conjunctions, comma splices, resumptive pronouns) relevant to IELTS Writing and quiz me with 3 targeted fixes.'],
  ].filter(Boolean);

  return (
    <div className="chat">
      <div className="sticky-bar" style={{ position: 'static' }}>
        <strong>AI Teacher</strong>
        {model === null ? <span className="badge warn">Offline: Ollama not running</span> : model ? <span className="badge teal">{model}</span> : null}
        <span className="spacer" />
        <label className="row small" style={{ gap: 6, cursor: 'pointer' }}><input type="checkbox" checked={arabic} onChange={(e) => setArabic(e.target.checked)} />Arabic explanations</label>
        <button className="btn sm" disabled={streaming || !messages.length} onClick={async () => { if (confirm('Clear the conversation history?')) { await api('/api/teacher/clear', { method: 'POST' }); setMessages([]); } }}>Clear</button>
      </div>
      <div className="chat-feed" ref={feed}>
        {messages.length === 0 && (
          <div className="card pad-lg stack" style={{ maxWidth: 760 }}>
            <h2>Your personal teacher</h2>
            <div className="muted">It knows your target ({me.targetBand}), your weakest skills and every mistake from your practice and exams, and it teaches from them: it explains the rule, shows an example, then checks you understood.</div>
            {model === null && <div className="notice">The teacher is offline because Ollama isn't running on the Mac that hosts this site. The written lessons in Skills Coach still work.</div>}
          </div>
        )}
        {messages.map((m, i) => (
          <div key={i} className={`bubble ${m.role === 'user' ? 'me' : ''}`} dir="auto">
            {m.content || (streaming && i === messages.length - 1 ? <span className="muted">Thinking…</span> : '')}
          </div>
        ))}
      </div>
      <div className="chat-chips">
        {chips.map(([label, prompt]) => <button key={label} className="chip" style={{ flexShrink: 0 }} disabled={streaming} onClick={() => send(prompt)}>{label}</button>)}
      </div>
      <div className="composer">
        <textarea className="textarea" rows={2} value={input} dir="auto" placeholder="Ask a question or paste a sentence to check… (⌘/Ctrl + Enter to send)"
          onChange={(e) => setInput(e.target.value)} onKeyDown={(e) => { if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) { e.preventDefault(); send(); } }} />
        {streaming ? <button className="btn lg" onClick={() => abort.current?.abort()}>■ Stop</button> : <button className="btn primary lg" disabled={!input.trim()} onClick={() => send()}>Send</button>}
      </div>
    </div>
  );
}
