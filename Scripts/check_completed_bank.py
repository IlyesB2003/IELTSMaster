#!/usr/bin/env python3
"""Validate deployable complete exam JSON without reading unfinished authoring files."""
import argparse
import json
from pathlib import Path
from build_exams import ROOT, cross_check, validate


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--content', type=Path, default=ROOT / 'Web/server/content')
    args = parser.parse_args()
    base = json.loads((args.content / 'content.json').read_text())
    exams = {e['id']: e for e in base['exams'] if e.get('provenance', {}).get('validationPassed') is not False}
    for path in sorted((args.content / 'exams').glob('*.json')):
        exam = json.loads(path.read_text())
        if exam.get('provenance', {}).get('validationPassed') is not False:
            exams.setdefault(exam['id'], exam)
    issues, warnings = {}, {}
    for exam in exams.values():
        errors = []
        validate(exam, errors)
        if exam['id'] in ('authored-01', 'authored-02'):
            # These published legacy originals predate the local 600-word guideline.
            warnings[exam['id']] = [e for e in errors if ': only ' in e and 'words (min 600)' in e]
            errors = [e for e in errors if e not in warnings[exam['id']]]
        if [len(p['questions']) for p in exam['readingPassages']] != [13, 13, 14]:
            errors.append('Reading distribution must be 13/13/14')
        if errors:
            issues[exam['id']] = errors
    cross_check(list(exams.values()), issues)
    if issues:
        print(json.dumps({'errors': issues}, ensure_ascii=False, indent=2))
        return 1
    mock_count = sum(e.get('pool', 'mock') == 'mock' for e in exams.values())
    print(f'PASS: {mock_count} complete mocks; all deployable exam/practice JSON passes structure and cross-bank similarity checks.')
    if any(warnings.values()):
        print(f'Compatibility notes: {sum(map(len, warnings.values()))} older listening scripts are below the newer local 600-word authoring guideline.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
