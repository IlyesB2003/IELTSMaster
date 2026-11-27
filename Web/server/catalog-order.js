// Published numbering is separate from authoring IDs, which are also progress keys.
// New exams append to the catalogue so an existing published number never moves
// merely because a lower-numbered authoring file arrives from another writer.
export function numberPublishedMocks(exams, publishedIDs = []) {
  if (!Array.isArray(publishedIDs) || publishedIDs.some(id => typeof id !== 'string') || new Set(publishedIDs).size !== publishedIDs.length) {
    throw new Error('Invalid published exam order');
  }
  const rank = new Map(publishedIDs.map((id, index) => [id, index]));
  return [...exams].sort((a, b) => {
    const ar = rank.get(a.id), br = rank.get(b.id);
    if (ar !== undefined || br !== undefined) return (ar ?? Infinity) - (br ?? Infinity);
    return (a.examNumber - b.examNumber) || a.id.localeCompare(b.id);
  }).map((exam, index) => ({
    ...exam,
    sourceExamNumber: exam.sourceExamNumber ?? exam.examNumber,
    examNumber: index + 1,
    title: exam.title.replace(/^Mock Exam\s+\d+:/i, `Mock Exam ${index + 1}:`),
  }));
}
