// API client + browser speech helpers (text-to-speech, recording, speech recognition).

export async function api(path, { method = 'GET', body } = {}) {
  const r = await fetch(path, {
    method,
    headers: body ? { 'content-type': 'application/json' } : undefined,
    body: body ? JSON.stringify(body) : undefined,
    credentials: 'same-origin',
  });
  const data = await r.json().catch(() => ({}));
  if (!r.ok) throw Object.assign(new Error(data.error || `Request failed (${r.status})`), { status: r.status });
  return data;
}

/** Streams a text response, calling onText with the accumulated text. */
export async function streamText(path, body, onText, signal) {
  const r = await fetch(path, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body), signal });
  if (!r.ok) { const d = await r.json().catch(() => ({})); throw new Error(d.error || `Request failed (${r.status})`); }
  const reader = r.body.getReader(); const dec = new TextDecoder(); let text = '';
  for (;;) { const { done, value } = await reader.read(); if (done) break; text += dec.decode(value, { stream: true }); onText(text); }
  return text;
}

export const fmtBand = (b) => (b == null ? '–' : Number(b).toFixed(1));
export const pct = (x) => `${Math.round((x || 0) * 100)}%`;
export const wordCount = (t) => String(t || '').split(/\s+/).filter(Boolean).length;
export const accuracyColor = (a) => (a >= 0.8 ? 'var(--ok)' : a >= 0.6 ? 'var(--warn)' : 'var(--bad)');
export const moduleColor = (m = '') => ({ listening: 'var(--listening)', reading: 'var(--reading)', writing: 'var(--writing)', speaking: 'var(--speaking)' }[m.toLowerCase()] || 'var(--primary)');

// ---------------------------------------------------------------- text-to-speech (Chrome + Safari hardened)

let voicesCache = [];
let activeUtterance = null;
let ttsHeartbeat = null;
let ttsCancelled = false;

function loadVoices() {
  if (!('speechSynthesis' in window)) return [];
  voicesCache = speechSynthesis.getVoices();
  return voicesCache;
}
if ('speechSynthesis' in window) { loadVoices(); speechSynthesis.onvoiceschanged = loadVoices; }

export const ttsAvailable = () => typeof window !== 'undefined' && 'speechSynthesis' in window;

function voicesFor(lang) {
  const all = voicesCache.length ? voicesCache : loadVoices();
  const exact = all.filter((v) => v.lang?.replace('_', '-').toLowerCase() === lang.toLowerCase());
  const prefix = all.filter((v) => v.lang?.toLowerCase().startsWith(lang.slice(0, 2).toLowerCase()));
  const en = all.filter((v) => v.lang?.toLowerCase().startsWith('en'));
  const rank = (v) => (/(premium|enhanced|natural|neural|samantha|daniel|karen|moira|google)/i.test(v.name) ? 0 : 1);
  const chosen = exact.length ? exact : (prefix.length ? prefix : en);
  return [...chosen].sort((a, b) => rank(a) - rank(b));
}

export function stopSpeaking() {
  ttsCancelled = true;
  clearInterval(ttsHeartbeat);
  ttsHeartbeat = null;
  activeUtterance = null;
  if (ttsAvailable()) {
    try { speechSynthesis.cancel(); } catch { /* ignore */ }
  }
}

/** Speaks dialogue turns reliably across Chrome, Safari, iOS and macOS with turn callbacks and heartbeat. */
export function speakDialogue(turns, { rate = 0.95, onTurn } = {}) {
  return new Promise((resolve) => {
    if (!ttsAvailable() || !turns?.length) return resolve(false);
    stopSpeaking();
    ttsCancelled = false;

    const speakerVoice = new Map();
    let i = 0;

    // Chrome bug workaround: keep synthesis alive during long academic lectures (>15s)
    ttsHeartbeat = setInterval(() => {
      if (ttsAvailable() && speechSynthesis.speaking && !speechSynthesis.paused) {
        try { speechSynthesis.resume(); } catch { /* ignore */ }
      }
    }, 5000);

    const finish = (ok) => {
      clearInterval(ttsHeartbeat);
      ttsHeartbeat = null;
      activeUtterance = null;
      resolve(ok);
    };

    const next = () => {
      if (ttsCancelled) return finish(false);
      if (i >= turns.length) return finish(true);
      const t = turns[i];
      const lang = t.accent || 'en-GB';
      if (!speakerVoice.has(t.speaker)) {
        const vs = voicesFor(lang);
        speakerVoice.set(t.speaker, vs[speakerVoice.size % Math.max(1, vs.length)] || null);
      }
      const u = new SpeechSynthesisUtterance(t.text);
      activeUtterance = u; // prevent GC from dropping onend
      u.lang = lang;
      u.rate = rate;
      const v = speakerVoice.get(t.speaker);
      if (v) u.voice = v;
      u.pitch = 1 + ((speakerVoice.size % 2) ? 0 : 0.06) * (i % 2 ? 1 : -1);
      u.onend = () => { if (!ttsCancelled) { i += 1; next(); } };
      u.onerror = (e) => {
        if (ttsCancelled || e.error === 'interrupted' || e.error === 'canceled') finish(false);
        else { i += 1; next(); }
      };
      onTurn?.(i, t);
      try {
        speechSynthesis.speak(u);
      } catch {
        finish(false);
      }
    };

    // Delay 60ms after cancel() to prevent Chrome silent-utterance bug
    setTimeout(next, 60);
  });
}

export const speak = (text, lang = 'en-GB', rate = 0.95) => speakDialogue([{ speaker: 'Examiner', accent: lang, text }], { rate });

// ---------------------------------------------------------------- recording + speech recognition (Chrome + Safari hardened)

const Recognition = typeof window !== 'undefined' ? (window.SpeechRecognition || window.webkitSpeechRecognition) : null;
export const recognitionAvailable = () => !!Recognition;
export const micAvailable = () => typeof navigator !== 'undefined' && !!navigator.mediaDevices?.getUserMedia && typeof MediaRecorder !== 'undefined';

function preferredAudioMime() {
  if (typeof MediaRecorder === 'undefined' || !MediaRecorder.isTypeSupported) return '';
  for (const type of ['audio/webm;codecs=opus', 'audio/webm', 'audio/mp4', 'audio/ogg;codecs=opus']) {
    if (MediaRecorder.isTypeSupported(type)) return type;
  }
  return '';
}

/**
 * Records the microphone (works on Chrome, Safari, Edge, iOS/macOS) and transcribes live where supported.
 * Returns a controller: stop() resolves to { url, seconds, transcript }.
 */
export async function startRecording({ onTranscript, onLevel } = {}) {
  const stream = await navigator.mediaDevices.getUserMedia({ audio: { echoCancellation: true, noiseSuppression: true, autoGainControl: true } });
  const chunks = [];
  const mime = preferredAudioMime();
  const rec = mime ? new MediaRecorder(stream, { mimeType: mime }) : new MediaRecorder(stream);
  rec.ondataavailable = (e) => { if (e.data && e.data.size > 0) chunks.push(e.data); };
  rec.start(250);
  const started = performance.now();

  // level meter (explicitly resume AudioContext for Safari/Chrome autoplay policies)
  const AudioCtx = window.AudioContext || window.webkitAudioContext;
  const ctx = new AudioCtx();
  if (ctx.state === 'suspended') { try { await ctx.resume(); } catch { /* ignore */ } }
  const src = ctx.createMediaStreamSource(stream);
  const analyser = ctx.createAnalyser(); analyser.fftSize = 512; src.connect(analyser);
  const buf = new Uint8Array(analyser.fftSize);
  let raf = 0;
  const tick = () => {
    analyser.getByteTimeDomainData(buf);
    let sum = 0; for (const v of buf) sum += ((v - 128) / 128) ** 2;
    onLevel?.(Math.min(1, Math.sqrt(sum / buf.length) * 4.5));
    raf = requestAnimationFrame(tick);
  };
  tick();

  // live transcription
  let finalText = '', interim = '', recog = null, wantRecog = true;
  if (Recognition) {
    recog = new Recognition();
    recog.lang = 'en-GB'; recog.continuous = true; recog.interimResults = true;
    recog.onresult = (e) => {
      interim = '';
      for (let i = e.resultIndex; i < e.results.length; i++) {
        const r = e.results[i];
        if (r.isFinal) finalText += r[0].transcript.trim() + ' ';
        else interim += r[0].transcript;
      }
      onTranscript?.((finalText + interim).trim());
    };
    recog.onend = () => { if (wantRecog) { try { recog.start(); } catch { /* already running */ } } };
    recog.onerror = (e) => { if (e.error === 'not-allowed' || e.error === 'service-not-allowed') wantRecog = false; };
    try { recog.start(); } catch { /* ignore */ }
  }

  return {
    stop: () => new Promise((resolve) => {
      wantRecog = false;
      try { recog?.stop(); } catch { /* ignore */ }
      cancelAnimationFrame(raf);
      rec.onstop = () => {
        stream.getTracks().forEach((t) => t.stop());
        try { ctx.close(); } catch { /* ignore */ }
        const blob = new Blob(chunks, { type: rec.mimeType || mime || 'audio/webm' });
        setTimeout(() => resolve({ url: URL.createObjectURL(blob), seconds: (performance.now() - started) / 1000, transcript: (finalText + interim).trim() }), 600);
      };
      try { rec.stop(); } catch { resolve({ url: '', seconds: (performance.now() - started) / 1000, transcript: (finalText + interim).trim() }); }
    }),
  };
}
