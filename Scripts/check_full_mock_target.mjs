// Acceptance gate for the requested full-exam bank. Practice sessions and rejected
// legacy templates cannot contribute to the target. Exit nonzero until complete.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Content } from '../Web/server/lib.js';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const content = new Content(path.join(root, 'Web/server/content/content.json'));
const exams = content.mockExams();
const numbers = exams.map(e => e.examNumber).sort((a, b) => a - b);
const missing = Array.from({ length: 100 }, (_, i) => i + 1).filter(n => !numbers.includes(n));
console.log(JSON.stringify({ fullMocks: exams.length, target: 100, missingNumbers: missing }));
assert.equal(exams.length, 100, 'The bank does not yet contain 100 full mocks');
assert.deepEqual(numbers, Array.from({ length: 100 }, (_, i) => i + 1));
const practiceIDs = new Set(content.practiceUnits.flatMap(u => u.questions.map(q => q.id)));
const texts = new Set();
const questions = new Set();
for (const exam of exams) {
  assert.ok(!exam.provenance.isOfficialIELTSMaterial && exam.provenance.validationPassed === true, exam.id);
  assert.equal(exam.listeningParts.length, 4, exam.id);
  assert.equal(exam.readingPassages.length, 3, exam.id);
  for (const [kind, units] of [['listening', exam.listeningParts], ['reading', exam.readingPassages]]) {
    const qs = units.flatMap(u => u.questions);
    assert.equal(qs.length, 40, `${exam.id}: ${kind}`);
    assert.deepEqual(qs.map(q => q.number), Array.from({ length: 40 }, (_, i) => i + 1));
    for (const unit of units) {
      const body = (unit.paragraphs || unit.dialogue.map(t => t.text)).join(' ');
      const normalized = body.toLowerCase().replace(/\s+/g, ' ').trim();
      assert.ok(!texts.has(normalized), `Reused full source text: ${unit.id}`);
      texts.add(normalized);
      if (kind === 'listening') assert.equal(unit.questions.length, 10, unit.id);
      if (exam.examNumber >= 3) assert.ok(body.split(/\s+/).length >= (kind === 'listening' ? 600 : 700), unit.id);
      for (const q of unit.questions) {
        assert.ok(!questions.has(q.id) && !practiceIDs.has(q.id), `Reused question: ${q.id}`);
        questions.add(q.id);
        assert.ok(q.acceptedAnswers.length && q.explanation && q.evidenceQuote, q.id);
      }
    }
  }
  assert.ok(exam.writingTask1.instructions && exam.writingTask2.promptText && exam.speakingSet.part3Questions.length >= 4, exam.id);
}
const native = JSON.parse(fs.readFileSync(path.join(root, 'Sources/IELTSCore/Resources/Content/catalog.json')));
assert.deepEqual(native.mockExams, exams, 'Native catalog is stale');
console.log('PASS: 100 complete mocks, numbered 1–100, distinct source texts and questions, native/web parity.');
