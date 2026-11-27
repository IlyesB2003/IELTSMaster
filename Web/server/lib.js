// Core logic for the IELTS Master web server: storage, auth, scoring, skills, practice selection.
// Ports of the Swift IELTSCore rules so the web app and the Mac app score identically.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { focusedDrills } from './practice-drills.js';
import { numberPublishedMocks } from './catalog-order.js';

// ---------------------------------------------------------------- storage

/** Tiny JSON-file database with atomic writes. Fine for a handful of users. */
export class Store {
  constructor(file) {
    this.file = file;
    fs.mkdirSync(path.dirname(file), { recursive: true });
    this.data = fs.existsSync(file)
      ? JSON.parse(fs.readFileSync(file, 'utf8'))
      : { users: [], sessions: [], progress: {}, config: {} };
    this.data.users ??= []; this.data.sessions ??= []; this.data.progress ??= {}; this.data.config ??= {};
    this.timer = null;
  }
  save() {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => this.flush(), 150);
  }
  flush() {
    const tmp = this.file + '.tmp';
    fs.writeFileSync(tmp, JSON.stringify(this.data));
    fs.renameSync(tmp, this.file);
  }
  progress(userId) {
    const p = (this.data.progress[userId] ??= {});
    p.targetBand ??= 7.5;
    p.skillEvents ??= [];
    p.exposure ??= { seenUnits: {}, examAttempts: {}, seenQuestions: {} };
    p.exposure.seenQuestions ??= {};
    p.attempts ??= [];
    p.mistakes ??= [];
    p.teacher ??= [];
    p.grammar ??= {};
    p.vocabSM2 ??= {};
    p.planMinutes ??= 45;
    p.planCompleted ??= {};
    return p;
  }
}

// ---------------------------------------------------------------- passwords & sessions

export function hashPassword(password, salt = crypto.randomBytes(16).toString('hex')) {
  const hash = crypto.scryptSync(password, salt, 64, { N: 16384, r: 8, p: 1 }).toString('hex');
  return { salt, hash };
}

export function verifyPassword(password, user) {
  const { hash } = hashPassword(password, user.salt);
  return crypto.timingSafeEqual(Buffer.from(hash, 'hex'), Buffer.from(user.passwordHash, 'hex'));
}

export const sha256 = (s) => crypto.createHash('sha256').update(s).digest('hex');
export const newToken = () => crypto.randomBytes(32).toString('base64url');
export const newId = () => crypto.randomUUID();

export function parseCookies(header = '') {
  const out = {};
  for (const part of header.split(';')) {
    const i = part.indexOf('=');
    if (i > 0) out[part.slice(0, i).trim()] = decodeURIComponent(part.slice(i + 1).trim());
  }
  return out;
}

export const normalizeEmail = (e) => String(e || '').trim().toLowerCase();

// ---------------------------------------------------------------- scoring (ported from IELTSScoringEngine)

export function roundOfficialBand(x) {
  const c = Math.min(Math.max(x, 0), 9);
  return Math.min(Math.max(Math.floor(c * 2 + 0.5 + 1e-9) / 2, 0), 9);
}

const LISTENING = [[39, 9], [37, 8.5], [35, 8], [32, 7.5], [30, 7], [26, 6.5], [23, 6], [18, 5.5], [16, 5], [13, 4.5], [11, 4], [8, 3.5], [6, 3], [4, 2.5], [2, 2], [1, 1]];
const READING = [[39, 9], [37, 8.5], [35, 8], [33, 7.5], [30, 7], [27, 6.5], [23, 6], [19, 5.5], [15, 5], [13, 4.5], [10, 4], [8, 3.5], [6, 3], [4, 2.5], [2, 2], [1, 1]];
export function rawToBand(raw, listening) {
  for (const [min, band] of listening ? LISTENING : READING) if (raw >= min) return band;
  return 0;
}
export const writingBand = (t1, t2) => roundOfficialBand((t1 + 2 * t2) / 3);

export function normalizeAnswer(input) {
  const collapsed = String(input ?? '').trim().toLowerCase()
    .replace(/’/g, "'").replace(/[–—]/g, '-').split(/\s+/).filter(Boolean).join(' ');
  switch (collapsed) {
    case 't': return 'true';
    case 'f': return 'false';
    case 'ng': case 'not given': return 'not given';
    case 'y': return 'yes';
    case 'n': return 'no';
    default: return collapsed.endsWith('.') ? collapsed.slice(0, -1) : collapsed;
  }
}

export const countWords = (t) => String(t || '').split(/\s+/).filter(Boolean).length;

export function isCorrect(response, q) {
  const r = normalizeAnswer(response);
  if (!r) return false;
  if (q.maxWordCount && countWords(r) > q.maxWordCount) return false;
  return q.acceptedAnswers.some((a) => normalizeAnswer(a) === r);
}

export function cefr(band) {
  if (band >= 8.5) return 'C2';
  if (band >= 7) return 'C1';
  if (band >= 5.5) return 'B2';
  if (band >= 4) return 'B1';
  if (band >= 3) return 'A2';
  return 'A1';
}

// ---------------------------------------------------------------- skills (ported from SkillAnalyzer)

const HALF_LIFE_DAYS = 21, WEAK_THRESHOLD = 0.75, MIN_ATTEMPTS = 3;

export function skillMastery(events, now = Date.now()) {
  const groups = new Map();
  for (const e of events) {
    const k = `${e.module}|${e.skillTag}`;
    if (!groups.has(k)) groups.set(k, []);
    groups.get(k).push(e);
  }
  return [...groups.values()].map((g) => {
    let ws = 0, wc = 0;
    for (const e of g) {
      const age = Math.max(0, (now - Date.parse(e.date)) / 86_400_000);
      const w = Math.pow(0.5, age / HALF_LIFE_DAYS);
      ws += w; if (e.correct) wc += w;
    }
    const n = g.length;
    const accuracy = ws > 0 ? wc / ws : 0;
    return {
      skillTag: g[0].skillTag, module: g[0].module, attempts: n,
      correct: g.filter((e) => e.correct).length, accuracy,
      confidence: n < 5 ? 'Low' : n < 15 ? 'Moderate' : 'High',
      isWeak: n >= MIN_ATTEMPTS && accuracy < WEAK_THRESHOLD,
    };
  });
}

export const weaknesses = (events, limit = 5) =>
  skillMastery(events).filter((s) => s.isWeak).sort((a, b) => a.accuracy - b.accuracy).slice(0, limit);

// ---------------------------------------------------------------- content & practice selection

export class Content {
  constructor(file) { this.file = file; this.load(); }
  load() {
    this.bundle = JSON.parse(fs.readFileSync(this.file, 'utf8'));
    // Slot-filled template exams (validationPassed === false) are not real IELTS-length material: never serve them.
    this.bundle.exams = (this.bundle.exams || []).filter((e) => e.provenance?.validationPassed !== false);
    // Hand-authored exams built and validated by Scripts/build_exams.py live in content/exams/*.json.
    const dir = path.join(path.dirname(this.file), 'exams');
    if (fs.existsSync(dir)) {
      for (const f of fs.readdirSync(dir).filter((x) => x.endsWith('.json')).sort()) {
        try {
          const e = JSON.parse(fs.readFileSync(path.join(dir, f), 'utf8'));
          if (e.provenance?.validationPassed === false) continue;
          if (!this.bundle.exams.some((x) => x.id === e.id)) this.bundle.exams.push(e);
        } catch (err) { console.error('Skipping exam file', f, err.message); }
      }
    }
    const order = (e) => (e.pool === 'practice' ? 1000 : 0) + (e.examNumber || 0);
    this.bundle.exams.sort((a, b) => order(a) - order(b));
    const orderFile = path.join(path.dirname(this.file), 'exam-order.json');
    const publishedIDs = fs.existsSync(orderFile) ? JSON.parse(fs.readFileSync(orderFile, 'utf8')) : [];
    this.bundle.exams = [
      ...numberPublishedMocks(this.bundle.exams.filter(e => (e.pool || 'mock') === 'mock'), publishedIDs),
      ...this.bundle.exams.filter(e => e.pool === 'practice'),
    ];
    this.bundle.skillTitles = { map_labelling: 'Map and plan labelling', table_completion: 'Table completion', ...(this.bundle.skillTitles || {}) };
    // Extra standalone Writing / Speaking practice prompts (content/banks/*.json).
    this.banks = { writing1: [], writing2: [], speaking: [], reading: [], listening: [] };
    const bdir = path.join(path.dirname(this.file), 'banks');
    for (const k of Object.keys(this.banks)) {
      const f = path.join(bdir, `${k}.json`);
      if (fs.existsSync(f)) { try { this.banks[k] = JSON.parse(fs.readFileSync(f, 'utf8')); } catch (err) { console.error('Bad bank', f, err.message); } }
    }
    this.units = [];
    this.practiceUnits = [];
    this.questions = new Map();
    for (const exam of this.bundle.exams) {
      const pool = exam.pool || 'mock';
      const targetUnits = pool === 'practice' ? this.practiceUnits : this.units;
      for (const p of exam.readingPassages) {
        const u = { id: p.id, kind: 'reading', pool, examId: exam.id, source: exam.title, passage: p, questions: p.questions };
        targetUnits.push(u);
      }
      for (const p of exam.listeningParts) {
        const u = { id: p.id, kind: 'listening', pool, examId: exam.id, source: exam.title, part: p, questions: p.questions };
        targetUnits.push(u);
      }
      if (pool === 'practice') {
        if (exam.writingTask1) this.practiceUnits.push({ id: `${exam.id}-pw1`, kind: 'writing', pool, examId: exam.id, source: exam.title, taskNumber: 1, writingTask: exam.writingTask1, questions: [] });
        if (exam.writingTask2) this.practiceUnits.push({ id: `${exam.id}-pw2`, kind: 'writing', pool, examId: exam.id, source: exam.title, taskNumber: 2, writingTask: exam.writingTask2, questions: [] });
        if (exam.speakingSet) this.practiceUnits.push({ id: `${exam.id}-pspk`, kind: 'speaking', pool, examId: exam.id, source: exam.title, speakingSet: exam.speakingSet, questions: [] });
      }
      for (const q of [...exam.readingPassages, ...exam.listeningParts].flatMap((x) => x.questions)) this.questions.set(q.id, q);
    }
    for (const t of this.banks.writing1) this.practiceUnits.push({ id: t.id, kind: 'writing', pool: 'practice', examId: 'bank', source: 'Writing bank', taskNumber: 1, writingTask: t, questions: [] });
    for (const t of this.banks.writing2) this.practiceUnits.push({ id: t.id, kind: 'writing', pool: 'practice', examId: 'bank', source: 'Writing bank', taskNumber: 2, writingTask: t, questions: [] });
    for (const sp of this.banks.speaking) this.practiceUnits.push({ id: sp.id, kind: 'speaking', pool: 'practice', examId: 'bank', source: 'Speaking bank', speakingSet: sp, questions: [] });
    for (const passage of this.banks.reading) this.practiceUnits.push({ id: passage.id, kind: 'reading', pool: 'practice', examId: 'bank', source: 'Focused reading bank', passage, questions: passage.questions });
    for (const part of this.banks.listening) this.practiceUnits.push({ id: part.id, kind: 'listening', pool: 'practice', examId: 'bank', source: 'Focused listening bank', part, questions: part.questions });
    this.practiceSourceUnits = this.practiceUnits;
    this.practiceUnits = this.practiceSourceUnits.flatMap((unit) => focusedDrills(unit));
  }
  mockExams() { return this.bundle.exams.filter((e) => (e.pool || 'mock') === 'mock'); }
  practiceExams() {
    return this.bundle.exams.filter((e) => e.pool === 'practice');
  }
  exam(id) { return this.bundle.exams.find((e) => e.id === id); }
  unit(id) { return this.units.find((u) => u.id === id) || this.practiceUnits.find((u) => u.id === id) || this.practiceSourceUnits.find((u) => u.id === id); }
  skillTitle(tag) { return this.bundle.skillTitles?.[tag] ?? tag.replace(/_/g, ' '); }
}

/** Removes answers and explanations so they can't be read in the browser before submitting. */
export function stripQuestion(q) {
  const { id, number, format, prompt, options, maxWordCount, skillTag } = q;
  return { id, number, format, prompt, options, maxWordCount, skillTag };
}
export const stripPassage = (p) => ({ ...p, questions: p.questions.map(stripQuestion) });
export const stripPart = (p) => ({ ...p, questions: p.questions.map(stripQuestion) });
export function stripExam(e) {
  return { ...e, readingPassages: e.readingPassages.map(stripPassage), listeningParts: e.listeningParts.map(stripPart) };
}

/** Strict never-repeat selector: never returns a unit containing already-seen questions while unseen units remain. */
export function nextUnit(units, exposure, weakSkills, focusSkill, excludeId) {
  const seenQ = exposure.seenQuestions || {};
  let pool = units.filter((u) => u.id !== excludeId);
  if (!pool.length) pool = units;
  if (focusSkill) {
    const f = pool.filter((u) => u.questions.some((q) => q.skillTag === focusSkill));
    if (f.length) pool = f;
  }
  const weak = new Set(weakSkills);
  const overlap = (u) => new Set(u.questions.map((q) => q.skillTag).filter((t) => weak.has(t))).size;
  const hasSeenAnyQuestion = (u) => u.questions?.length > 0 && u.questions.some((q) => !!seenQ[q.id]);
  const unseen = pool.filter((u) => !exposure.seenUnits[u.id] && !hasSeenAnyQuestion(u));
  if (unseen.length) {
    const shuffled = [...unseen].sort(() => Math.random() - 0.5);
    shuffled.sort((a, b) => overlap(b) - overlap(a));
    return { unit: shuffled[0], isRepeat: false };
  }
  pool.sort((a, b) => Date.parse(exposure.seenUnits[a.id] || 0) - Date.parse(exposure.seenUnits[b.id] || 0));
  return pool.length ? { unit: pool[0], isRepeat: true } : null;
}

/** SM-2 spaced repetition update for vocabulary review. */
export function sm2Update(prev, quality, now = Date.now()) {
  const q = Math.max(0, Math.min(5, Number(quality) || 0));
  let ease = prev?.easeFactor ?? 2.5;
  let reps = prev?.repetitions ?? 0;
  let interval = prev?.intervalDays ?? 0;
  if (q < 3) {
    reps = 0;
    interval = 1;
  } else {
    interval = reps === 0 ? 1 : reps === 1 ? 6 : Math.max(1, Math.round(interval * ease));
    reps += 1;
  }
  ease = Math.max(1.3, +(ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))).toFixed(2));
  const nextReview = new Date(now + interval * 86_400_000).toISOString();
  return { easeFactor: ease, repetitions: reps, intervalDays: interval, nextReview, lastReviewedAt: new Date(now).toISOString() };
}

/** Grades a set of questions and returns per-question feedback (answers revealed after submit). */
export function grade(questions, responses) {
  const results = questions.map((q) => ({
    id: q.id, number: q.number, prompt: q.prompt, skillTag: q.skillTag, format: q.format,
    response: responses[q.id] ?? '', correct: isCorrect(responses[q.id], q),
    answer: q.acceptedAnswers[0], explanation: q.explanation, evidence: q.evidenceQuote, distractor: q.distractorNote,
  }));
  return { raw: results.filter((r) => r.correct).length, total: questions.length, results };
}

export function recordResults(progress, graded, module, source) {
  const date = new Date().toISOString();
  progress.exposure.seenQuestions ??= {};
  for (const r of graded.results) {
    progress.exposure.seenQuestions[r.id] = date;
    progress.skillEvents.push({ skillTag: r.skillTag, module, itemId: r.id, correct: r.correct, date });
    if (!r.correct) {
      const existing = progress.mistakes.find((m) => m.itemId === r.id);
      if (existing) { existing.count += 1; existing.date = date; existing.response = r.response; existing.mastered = false; }
      else progress.mistakes.unshift({
        id: newId(), itemId: r.id, module, source, skillTag: r.skillTag, prompt: r.prompt,
        response: r.response || '(blank)', answer: r.answer, explanation: r.explanation, count: 1, date, mastered: false,
      });
    }
  }
  if (progress.skillEvents.length > 20000) progress.skillEvents.splice(0, progress.skillEvents.length - 20000);
  if (progress.mistakes.length > 2000) progress.mistakes.length = 2000;
}

/** Latest band per module from complete tests; overall only when all four exist. */
export function bandSummary(progress) {
  const latest = {};
  for (const a of [...progress.attempts].sort((x, y) => Date.parse(x.date) - Date.parse(y.date))) {
    for (const m of ['listening', 'reading', 'writing', 'speaking']) if (a[m] != null) latest[m] = a[m];
  }
  const known = Object.values(latest);
  const overall = known.length === 4 ? roundOfficialBand(known.reduce((s, x) => s + x, 0) / 4) : null;
  const partial = known.length ? roundOfficialBand(known.reduce((s, x) => s + x, 0) / known.length) : null;
  return { ...latest, overall, partial, modulesMeasured: known.length, cefr: partial != null ? cefr(partial) : null };
}
