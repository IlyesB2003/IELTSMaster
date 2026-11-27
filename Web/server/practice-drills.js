// Focused practice uses dedicated practice sources only. Each source question belongs
// to one drill; several drills may intentionally study the same practice text.
// Full mock text is never a source for this transformation.
export function focusedDrills(unit, maxQuestions = 4) {
  if (unit.pool !== 'practice') throw new Error('Mock content cannot become a practice drill');
  if (!Number.isInteger(maxQuestions) || maxQuestions < 2) throw new Error('Invalid drill size');
  const field = unit.kind === 'reading' ? 'passage' : unit.kind === 'listening' ? 'part' : null;
  if (!field) return [unit];
  const source = unit[field];
  const groups = source.groups?.length ? source.groups : [{
    from: source.questions[0]?.number, to: source.questions.at(-1)?.number,
    instruction: 'Answer the questions below.',
  }];
  const assigned = new Set();
  const drills = groups.flatMap((group, gi) => {
    const questions = source.questions.filter((q) => q.number >= group.from && q.number <= group.to);
    const count = Math.ceil(questions.length / maxQuestions);
    const drills = [];
    let offset = 0;
    for (let i = 0; i < count; i++) {
      // Balance the final chunk instead of leaving a single question after a long set.
      const size = Math.ceil((questions.length - offset) / (count - i));
      const subset = questions.slice(offset, offset + size);
      offset += size;
      for (const q of subset) {
        if (assigned.has(q.id)) throw new Error(`Overlapping practice groups: ${q.id}`);
        assigned.add(q.id);
      }
      const from = subset[0].number, to = subset.at(-1).number;
      const range = from === to ? `Question ${from}` : `Questions ${from}–${to}`;
      const instruction = group.instruction.replace(/^Questions?\s+\d+(?:\s*[–—-]\s*\d+)?/i, range);
      const id = `${unit.id}-drill-${gi + 1}-${i + 1}`;
      drills.push({ ...unit, id, sourceUnitId: unit.id, practiceMode: 'focused',
        source: `${unit.source} · ${subset[0].format} · ${range.toLowerCase()}`,
        [field]: { ...source, id, questions: subset, groups: [{ ...group, from, to, instruction }] },
        questions: subset });
    }
    return drills;
  });
  if (assigned.size !== source.questions.length) {
    throw new Error(`Practice groups do not cover all questions: ${unit.id}`);
  }
  return drills;
}
