#!/usr/bin/env python3
"""Build original short skill drills, kept separate from complete examinations."""
import json
import runpy
import sys
from build_exams import ROOT, SRC, ACCENT, expand_question, norm, stable_id


def main():
    sys.path.insert(0, str(SRC))
    data = runpy.run_path(str(ROOT / 'Content/drills/focused.py'))
    output = ROOT / 'Web/server/content/banks'
    for name, specs in [('reading', data['READING']), ('listening', data['LISTENING'])]:
        result = []
        for index, spec in enumerate(specs, 1):
            eid = f'focus-{name}-{index:03d}'
            body = ' '.join(spec['paragraphs']) if name == 'reading' else ' '.join(t[2] for t in spec['script'])
            assert len(body.split()) >= 150, (eid, 'Source is too short')
            questions, groups = [], []
            for group in spec['groups']:
                start = len(questions) + 1
                for item in group['items']:
                    q = expand_question(eid, 'R' if name == 'reading' else 'L', len(questions) + 1, item, group)
                    assert norm(q['evidenceQuote']) in norm(body), (q['id'], 'Missing evidence')
                    assert q['evidenceQuote'].strip() and q['explanation'].strip()
                    if not q['options']:
                        assert norm(q['acceptedAnswers'][0]) in norm(q['evidenceQuote']), (q['id'], 'Unsupported answer')
                        assert len(q['acceptedAnswers'][0].split()) <= q['maxWordCount'], q['id']
                    questions.append(q)
                groups.append({'from': start, 'to': len(questions), 'instruction': group['instruction']})
            assert 2 <= len(questions) <= 4, eid
            unit = {'id': eid, 'title': spec['title'], 'questions': questions, 'groups': groups,
                    'practiceMode': 'focused', 'isOfficialIELTSMaterial': False,
                    'sourceNote': 'Original short skill drill. Not a complete IELTS test or an official past paper.'}
            if name == 'reading':
                unit.update(passageNumber=1, discipline=spec['discipline'], paragraphs=spec['paragraphs'], estimatedWordCount=len(body.split()))
            else:
                turns = [{'id': stable_id(eid, i), 'speaker': s, 'accent': ACCENT[a], 'text': t} for i, (s, a, t) in enumerate(spec['script'])]
                unit.update(partNumber=spec['part'], contextDescription=spec['context'], primaryAccent=turns[0]['accent'], dialogue=turns, keyVocabulary=spec.get('vocab', []))
            result.append(unit)
        (output / f'{name}.json').write_text(json.dumps(result, ensure_ascii=False, indent=1) + '\n')
        print(f'{name}: {len(result)} standalone source texts, {sum(len(u["questions"]) for u in result)} questions')


if __name__ == '__main__':
    main()
