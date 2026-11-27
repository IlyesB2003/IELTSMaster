// Build the native resource from the same catalog and drill transformation as the web.
// Run after build_exams.py and before packaging the macOS application.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Content } from '../Web/server/lib.js';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const content = new Content(path.join(root, 'Web/server/content/content.json'));
// Persist append order before publication. It survives authoring gaps and future arrivals.
const orderFile = path.join(root, 'Web/server/content/exam-order.json');
const previousIDs = fs.existsSync(orderFile) ? JSON.parse(fs.readFileSync(orderFile, 'utf8')) : [];
const knownIDs = new Set(previousIDs);
const publishedIDs = [...previousIDs, ...content.mockExams().map(e => e.id).filter(id => !knownIDs.has(id))];
fs.writeFileSync(orderFile, JSON.stringify(publishedIDs, null, 2) + '\n');
const sources = content.practiceSourceUnits;
const data = {
  mockExams: content.mockExams(),
  reading: content.practiceUnits.filter(u => u.kind === 'reading').map(u => u.passage),
  listening: content.practiceUnits.filter(u => u.kind === 'listening').map(u => u.part),
  writing1: sources.filter(u => u.kind === 'writing' && u.taskNumber === 1).map(u => u.writingTask),
  writing2: sources.filter(u => u.kind === 'writing' && u.taskNumber === 2).map(u => u.writingTask),
  speaking: sources.filter(u => u.kind === 'speaking').map(u => u.speakingSet),
};
const dir = path.join(root, 'Sources/IELTSCore/Resources/Content');
fs.mkdirSync(dir, { recursive: true });
fs.writeFileSync(path.join(dir, 'catalog.json'), JSON.stringify(data));
console.log(Object.fromEntries(Object.entries(data).map(([key, value]) => [key, value.length])));
