#!/usr/bin/env python3
"""Read-only content audit. Writes only the requested report, never rebuilds banks.

Usage: python3 Scripts/audit_content.py --output Docs/content-audit.json
Structural checks are NOT an editorial, factual or audio-quality certification.
"""
import argparse
import collections
import json
import pathlib
import sys
import subprocess

from build_exams import ROOT, SRC, build, cross_check, validate, norm


def audit():
    base = json.loads((ROOT / 'Web/server/content/content.json').read_text())
    loaded = {e['id']: e for e in base['exams']
              if e.get('provenance', {}).get('validationPassed') is not False}
    for path in sorted((ROOT / 'Web/server/content/exams').glob('*.json')):
        e = json.loads(path.read_text())
        loaded.setdefault(e['id'], e)  # Same precedence as the web loader.
    issues = {}
    source_issues = {}
    for path in sorted(SRC.glob('*.py')):
        if not path.stem.startswith(('exam', 'practice')):
            continue
        try:
            expected, errors = build(path)
            if errors:
                source_issues[path.stem] = errors
            actual = loaded.get(path.stem)
            if actual is None:
                source_issues.setdefault(path.stem, []).append('Missing served JSON')
            elif {k: v for k, v in expected.items() if k != 'provenance'} != {
                    k: v for k, v in actual.items() if k != 'provenance'}:
                source_issues.setdefault(path.stem, []).append('Source / served JSON mismatch')
        except Exception as error:
            source_issues[path.stem] = [str(error)]
    counts = collections.Counter()
    question_types = collections.Counter()
    rows = []
    seen_ids = set()
    duplicate_ids = []
    for e in loaded.values():
        errors = []
        validate(e, errors)
        if errors:
            issues[e['id']] = errors
        practice = e.get('pool') == 'practice'
        counts['practice_sets' if practice else 'mock_exams'] += 1
        lw = [sum(len(t['text'].split()) for t in p['dialogue']) for p in e['listeningParts']]
        rw = [len(' '.join(p['paragraphs']).split()) for p in e['readingPassages']]
        for kind, units in [('listening', e['listeningParts']), ('reading', e['readingPassages'])]:
            if practice:
                counts[kind] += len(units)
            for u in units:
                for q in u['questions']:
                    question_types[f'{kind}: {q["format"]}'] += 1
                    if q['id'] in seen_ids:
                        duplicate_ids.append(q['id'])
                    seen_ids.add(q['id'])
        if practice:
            counts['writing_task1'] += 1
            counts['writing_task2'] += 1
            counts['speaking'] += 1
        rows.append({'id': e['id'], 'title': e['title'], 'pool': e.get('pool', 'mock'),
                     'listening_words': lw, 'reading_words': rw,
                     'official': e.get('provenance', {}).get('isOfficialIELTSMaterial', False)})
    cross_check(list(loaded.values()), issues)
    repeated_bank_prompts = {}
    for name, field in [('writing1', 'instructions'), ('writing2', 'promptText'), ('speaking', 'part2CueCard')]:
        bank = json.loads((ROOT / f'Web/server/content/banks/{name}.json').read_text())
        key = {'writing1': 'writing_task1', 'writing2': 'writing_task2', 'speaking': 'speaking'}[name]
        counts[key] += len(bank)
        prompts = collections.defaultdict(list)
        # Include practice sets: the same prompt must not be counted twice.
        exam_key = {'writing1': 'writingTask1', 'writing2': 'writingTask2', 'speaking': 'speakingSet'}[name]
        items = bank + [e[exam_key] for e in loaded.values() if e.get('pool') == 'practice']
        for item in items:
            value = item[field]
            if isinstance(value, dict):
                value = value['topic']
            prompts[norm(value)].append(item['id'])
        repeated_bank_prompts[name] = [ids for ids in prompts.values() if len(ids) > 1]
    for name in ('reading', 'listening'):
        path = ROOT / f'Web/server/content/banks/{name}.json'
        standalone = json.loads(path.read_text()) if path.exists() else []
        counts[name] += len(standalone)
        for unit in standalone:
            for q in unit['questions']:
                question_types[f'{name}: {q["format"]}'] += 1
                if q['id'] in seen_ids:
                    duplicate_ids.append(q['id'])
                seen_ids.add(q['id'])
    counts['writing'] = counts['writing_task1'] + counts['writing_task2']
    source_counts = dict(counts)
    runtime = json.loads(subprocess.run(
        ['node', str(ROOT / 'Scripts/audit_runtime_content.mjs')],
        capture_output=True, text=True, check=True).stdout)
    for name, number in runtime['counts'].items():
        counts[name] = number
    targets = {'mock_exams': 100, 'listening': 200, 'reading': 200, 'writing': 200, 'speaking': 200}
    return {
        'scope': 'All JSON served by the web content loader, plus all Python exam sources.',
        'limitations': ['Automated structural checks only; answers and factual claims need editorial review.',
                       'The 600-word listening minimum is a local authoring guideline, not an official IELTS word-count requirement.',
                       'Counts are inventory counts, not a certification of distinct, reviewed exercises.',
                       'Targets interpret 200 exercises as 200 per skill; writing counts Task 1 and Task 2 separately.',
                       'Listening and reading counts are focused sessions sharing practice-only source texts; see source_counts.',
                       'Regenerate the native resource with node Scripts/sync_native_content.mjs after editing content.',
                       'Listening audio delivery uses browser speech synthesis; recordings were not assessed.'],
        'counts': dict(counts), 'source_counts': source_counts, 'targets': targets,
        'practice_separation': runtime,
        'remaining': {k: max(0, v - counts[k]) for k, v in targets.items()},
        'structural_issues': issues, 'source_issues': source_issues,
        'duplicate_question_ids': duplicate_ids, 'duplicate_practice_prompts': repeated_bank_prompts,
        'question_types': dict(question_types), 'exams': rows,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=pathlib.Path)
    args = parser.parse_args()
    report = audit()
    if args.output:
        args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({k: report[k] for k in ('counts', 'remaining')}, indent=2))
    failed = bool(report['structural_issues'] or report['source_issues'] or report['duplicate_question_ids']
                  or any(report['duplicate_practice_prompts'].values())
                  or any(report['practice_separation'][k] for k in (
                      'cross_pool_content_overlap', 'cross_pool_question_overlap', 'repeated_drill_question_ids')))
    print('Automated checks:', 'FAIL — inspect report' if failed else 'PASS (editorial review still required)')
    return int(failed)


if __name__ == '__main__':
    sys.exit(main())
