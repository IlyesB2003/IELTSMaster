import random
import unittest
from build_exams import cross_check, trigrams


class DuplicateCheckerTests(unittest.TestCase):
    def test_index_matches_exhaustive_jaccard(self):
        rng = random.Random(23)
        exams = []
        for i in range(30):
            texts = [' '.join(rng.choices('window river green quiet school book table old open walk'.split(), k=12)) for _ in range(6)]
            exams.append({'id': str(i), 'listeningParts': [], 'readingPassages': [
                {'id': f'p{i}', 'paragraphs': texts[:2], 'questions': [
                    {'id': f'q{i}-{j}', 'prompt': text} for j, text in enumerate(texts)]}]})
        expected = {}
        for what, threshold in [('stem', .6), ('paragraph', .3)]:
            items = []
            for e in exams:
                for p in e['readingPassages']:
                    entries = [(q['id'], q['prompt']) for q in p['questions']] if what == 'stem' else [(p['id'], t) for t in p['paragraphs']]
                    items.extend((e['id'], ident, trigrams(text)) for ident, text in entries)
            for i, a in enumerate(items):
                for b in items[i + 1:]:
                    if a[0] != b[0] and len(a[2] & b[2]) / len(a[2] | b[2]) >= threshold:
                        expected.setdefault(a[0], []).append(f'{what} {a[1]} near-duplicates {b[1]}')
        actual = {}
        cross_check(exams, actual)
        self.assertEqual(actual, expected)

    def test_copied_listening_script_is_rejected(self):
        text = 'The volunteer coordinator explained how visitors should arrange their equipment before joining the evening workshop in the community centre.'
        exams = [{'id': e, 'readingPassages': [], 'listeningParts': [
            {'id': f'{e}-lp1', 'questions': [], 'dialogue': [{'text': text}]}]} for e in ['examA', 'examB']]
        issues = {}
        cross_check(exams, issues)
        self.assertEqual(issues, {'examA': ['transcript examA-lp1 near-duplicates examB-lp1']})


if __name__ == '__main__':
    unittest.main()
