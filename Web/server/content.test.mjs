import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Content, grade, stripPart, stripPassage } from './lib.js';
import { focusedDrills } from './practice-drills.js';
import { numberPublishedMocks } from './catalog-order.js';

const file = path.join(path.dirname(fileURLToPath(import.meta.url)), 'content/content.json');
const content = new Content(file);

test('published mock numbers and title prefixes are continuous', () => {
  const exams = content.mockExams();
  assert.deepEqual(exams.map(e => e.examNumber), Array.from({ length: exams.length }, (_, i) => i + 1));
  exams.forEach((e, i) => assert.ok(e.title.startsWith(`Mock Exam ${i + 1}:`)));
  assert.equal(content.exam('exam50').examNumber, 27);
  assert.equal(content.exam('exam51').examNumber, 28);
  assert.equal(content.exam('exam76').examNumber, 29);
  assert.equal(content.exam('exam77').examNumber, 30);
  assert.equal(content.exam('exam78').examNumber, 31);
});

test('new authoring files append without changing existing published numbers or progress keys', () => {
  const originals = [{ id: 'exam50', examNumber: 50, title: 'Mock Exam 50: Shore' },
    { id: 'exam26', examNumber: 26, title: 'Mock Exam 26: Clocks' }];
  const order = ['exam26', 'exam50'];
  const before = numberPublishedMocks(originals, order);
  const after = numberPublishedMocks([...originals, { id: 'exam27', examNumber: 27, title: 'Mock Exam 27: New' }], order);
  assert.deepEqual(after.slice(0, 2), before);
  assert.equal(after[2].id, 'exam27');
  assert.equal(after[2].examNumber, 3);
  assert.equal(after.find(e => e.id === 'exam50').sourceExamNumber, 50);
});

test('practice and mocks have disjoint question IDs and separate source pools', () => {
  const mock = new Set(content.units.flatMap(u => u.questions.map(q => q.id)));
  assert.ok(content.units.every(u => u.pool === 'mock'));
  assert.ok(content.practiceUnits.every(u => u.pool === 'practice'));
  assert.ok(content.practiceUnits.flatMap(u => u.questions).every(q => !mock.has(q.id)));
});

test('focused drills preserve every practice question exactly once', () => {
  const expected = content.practiceSourceUnits.flatMap(u => u.questions.map(q => q.id)).sort();
  const actual = content.practiceUnits.flatMap(u => u.questions.map(q => q.id)).sort();
  assert.deepEqual(actual, expected);
  assert.equal(new Set(actual).size, actual.length);
  for (const unit of content.practiceUnits.filter(u => u.questions.length)) {
    assert.ok(unit.questions.length >= 2 && unit.questions.length <= 4);
    const data = unit.passage || unit.part;
    const group = data.groups[0];
    assert.equal(group.from, data.questions[0].number);
    assert.equal(group.to, data.questions.at(-1).number);
    const responses = Object.fromEntries(unit.questions.map(q => [q.id, q.acceptedAnswers[0]]));
    assert.equal(grade(unit.questions, responses).raw, unit.questions.length);
  }
});

test('mock content cannot be transformed into focused practice', () => {
  assert.throws(() => focusedDrills(content.units[0]), /Mock content/);
});

test('an empty practice bank does not fall back to full mocks', () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'ielts-content-test-'));
  try {
    const file = path.join(temp, 'content.json');
    fs.writeFileSync(file, JSON.stringify({ exams: [content.mockExams()[0]] }));
    const empty = new Content(file);
    assert.equal(empty.mockExams().length, 1);
    assert.equal(empty.practiceExams().length, 0);
    assert.equal(empty.practiceUnits.length, 0);
  } finally { fs.rmSync(temp, { recursive: true, force: true }); }
});

test('answer keys and evidence are stripped from focused practice responses', () => {
  for (const unit of content.practiceUnits.filter(u => u.questions.length)) {
    const publicUnit = unit.passage ? stripPassage(unit.passage) : stripPart(unit.part);
    for (const q of publicUnit.questions) {
      assert.ok(!('acceptedAnswers' in q));
      assert.ok(!('evidenceQuote' in q));
      assert.ok(!('explanation' in q));
    }
  }
});

test('all four skills have at least 200 practice sessions', () => {
  for (const kind of ['listening', 'reading', 'writing', 'speaking']) {
    assert.ok(content.practiceUnits.filter(u => u.kind === kind).length >= 200, kind);
  }
});

test('new full mock has independent four-skill content and 40+40 objective questions', () => {
  for (const id of ['exam22', 'exam23']) {
  const exam = content.exam(id);
  assert.ok(content.mockExams().includes(exam));
  assert.equal(exam.listeningParts.length, 4);
  assert.equal(exam.readingPassages.length, 3);
  for (const units of [exam.listeningParts, exam.readingPassages]) {
    const qs = units.flatMap(u => u.questions);
    assert.equal(qs.length, 40);
    assert.equal(grade(qs, Object.fromEntries(qs.map(q => [q.id, q.acceptedAnswers[0]]))).raw, 40);
  }
  assert.equal(exam.provenance.isOfficialIELTSMaterial, false);
  assert.ok(exam.writingTask1.dataPoints.length >= 4);
  assert.ok(exam.writingTask2.promptText && exam.speakingSet.part3Questions.length >= 4);
  }
});

test('exam23 transport figures total 100 percent in each year and support the overview', () => {
  const task = content.exam('exam23').writingTask1;
  const totals = new Map();
  for (const point of task.dataPoints) totals.set(point.series, (totals.get(point.series) || 0) + point.value);
  assert.deepEqual([...totals.values()], [100, 100, 100]);
  const car = task.dataPoints.filter(p => p.category === 'Car').map(p => p.value);
  assert.deepEqual(car, [50, 35, 22]);
  const last = task.dataPoints.filter(p => p.series === '2026');
  assert.equal(last.sort((a, b) => b.value - a.value)[0].category, 'Walking');
});

test('native catalog exactly matches web practice selection and mock IDs', () => {
  const native = JSON.parse(fs.readFileSync(path.resolve(path.dirname(file), '../../../Sources/IELTSCore/Resources/Content/catalog.json'), 'utf8'));
  assert.deepEqual(native.mockExams.map(e => e.id), content.mockExams().map(e => e.id));
  for (const [kind, field, key] of [['reading', 'reading', 'passage'], ['listening', 'listening', 'part'], ['speaking', 'speaking', 'speakingSet']]) {
    assert.deepEqual(native[field], content.practiceUnits.filter(u => u.kind === kind).map(u => u[key]));
  }
});
