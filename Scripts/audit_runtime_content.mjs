import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Content } from '../Web/server/lib.js';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const c = new Content(path.join(root, 'Web/server/content/content.json'));
const key = value => value.normalize('NFKC').toLowerCase().replace(/[’‘]/g, "'").replace(/\s+/g, ' ').trim();
const fingerprint = u => u.passage ? u.passage.paragraphs.join(' ')
  : u.part ? u.part.dialogue.map(t => t.text).join(' ')
  : u.writingTask ? (u.writingTask.promptText || u.writingTask.instructions)
  : u.speakingSet.part2CueCard.topic;
const mocks = new Map();
for (const e of c.mockExams()) {
  for (const p of e.readingPassages) mocks.set(key(p.paragraphs.join(' ')), p.id);
  for (const p of e.listeningParts) mocks.set(key(p.dialogue.map(t => t.text).join(' ')), p.id);
  for (const t of [e.writingTask1.instructions, e.writingTask2.promptText, e.speakingSet.part2CueCard.topic]) mocks.set(key(t), e.id);
}
const overlap = [];
for (const u of c.practiceSourceUnits) {
  const match = mocks.get(key(fingerprint(u)));
  if (match) overlap.push({ practice: u.id, mock: match });
}
const practiceQ = c.practiceUnits.flatMap(u => u.questions.map(q => q.id));
const mockQ = new Set(c.units.flatMap(u => u.questions.map(q => q.id)));
console.log(JSON.stringify({
  published_mock_catalog: c.mockExams().map(e => ({ id: e.id, number: e.examNumber, authoringNumber: e.sourceExamNumber, title: e.title })),
  counts: Object.fromEntries(['reading', 'listening', 'writing', 'speaking'].map(k => [k, c.practiceUnits.filter(u => u.kind === k).length])),
  cross_pool_content_overlap: overlap,
  cross_pool_question_overlap: practiceQ.filter(id => mockQ.has(id)),
  repeated_drill_question_ids: practiceQ.filter((id, i) => practiceQ.indexOf(id) !== i),
  max_drill_questions: Math.max(...c.practiceUnits.filter(u => u.questions.length).map(u => u.questions.length)),
}));
