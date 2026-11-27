#!/usr/bin/env python3
"""Builds and validates the hand-authored IELTS mock exams in Content/exams/*.py.

Each source file defines EXAM (a compact dict). This script expands it into the
MockExam JSON shape used by the Mac app and the web app, checks it against the
IELTS Academic format, and writes Web/server/content/exams/<id>.json.

  python3 Scripts/build_exams.py            # build + validate all
  python3 Scripts/build_exams.py exam07     # build one (still checks cross-exam duplicates)
Exit code 1 if any exam fails validation; failing exams are not written.
"""
import json, re, sys, runpy, pathlib, datetime, uuid, collections

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / 'Content' / 'exams'
OUT = ROOT / 'Web' / 'server' / 'content' / 'exams'
LEGACY = ROOT / 'Web' / 'server' / 'content' / 'content.json'

ACCENT = {'GB': 'en-GB', 'US': 'en-US', 'AU': 'en-AU', 'CA': 'en-CA', 'IE': 'en-IE'}
FORMAT = {
    'mcq': 'Multiple Choice', 'tfng': 'True / False / Not Given', 'ynng': 'Yes / No / Not Given',
    'headings': 'Matching Headings', 'info': 'Matching Information', 'features': 'Matching Features',
    'endings': 'Matching Sentence Endings', 'match': 'Matching', 'form': 'Form Completion',
    'note': 'Note Completion', 'table': 'Table Completion', 'flow': 'Flowchart Completion',
    'summary': 'Summary Completion', 'sentence': 'Sentence Completion', 'map': 'Map / Diagram Labeling',
    'short': 'Short Answer',
}
DEFAULT_SKILL = {
    'mcq': 'multiple_choice', 'tfng': 'tfng', 'ynng': 'ynng', 'headings': 'matching_headings',
    'info': 'matching_information', 'features': 'matching_features', 'endings': 'sentence_endings',
    'match': 'matching', 'form': 'detail', 'note': 'note_completion', 'table': 'note_completion',
    'flow': 'flowchart', 'summary': 'summary_completion', 'sentence': 'sentence_completion',
    'map': 'map_labelling', 'short': 'short_answer',
}
VISUALS = {'line': 'Line Chart', 'bar': 'Bar Chart', 'pie': 'Pie Chart', 'table': 'Table',
           'process': 'Process Diagram', 'map': 'Map Comparison', 'combined': 'Combined Visual Data'}
ESSAYS = {'opinion': 'Opinion (Agree / Disagree)', 'discussion': 'Discussion (Both Views + Opinion)',
          'advdis': 'Advantages & Disadvantages', 'problem': 'Problem & Solution', 'twopart': 'Two-Part Question'}
LEVELS = {'foundation': 'Foundation (Band 5.0 to 6.0)', 'standard': 'Standard Academic (Band 6.0 to 7.0)',
          'target': 'Target High Band (Band 7.0 to 8.0)', 'advanced': 'Advanced Academic (Band 8.0 to 9.0)'}
NOW = datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

def norm(s):
    s = s.replace('’', "'").replace('‘', "'").replace('“', '"').replace('”', '"').replace('–', '-').replace('—', '-')
    return re.sub(r'\s+', ' ', s).strip().lower()

def letters(n): return [chr(65 + i) for i in range(n)]

def stable_id(*parts): return str(uuid.uuid5(uuid.NAMESPACE_URL, 'ieltsmaster:' + ':'.join(map(str, parts)))).upper()

def expand_question(eid, mod, n, spec, shared):
    """spec: dict with key 't' (type) or tuple forms; see Content/exams/README.md."""
    t = spec['t']
    q = {'id': f'{eid}-{mod}{n}', 'number': n, 'format': FORMAT[t], 'prompt': spec['q'],
         'explanation': spec['why'], 'evidenceQuote': spec['ev'], 'skillTag': spec.get('skill', DEFAULT_SKILL[t])}
    if spec.get('trap'): q['distractorNote'] = spec['trap']
    if spec.get('ar'): q['arabicExplanation'] = spec['ar']
    if t in ('tfng', 'ynng'):
        q['options'] = ['TRUE', 'FALSE', 'NOT GIVEN'] if t == 'tfng' else ['YES', 'NO', 'NOT GIVEN']
        q['acceptedAnswers'] = [spec['a']]
    elif t in ('mcq', 'headings', 'info', 'features', 'endings', 'match') or (t == 'map' and ('opts' in spec or 'opts' in shared)):
        opts = spec.get('opts') or shared.get('opts')
        labelled = [o if re.match(r'^[A-Z]{1,4}\. ', o) else f'{L}. {o}' for L, o in zip(letters(len(opts)) if t != 'headings' else roman(len(opts)), opts)]
        q['options'] = labelled
        a = spec['a']
        full = next((o for o in labelled if o.startswith(a + '. ')), None)
        if not full: raise ValueError(f'{q["id"]}: answer {a} not among options')
        q['acceptedAnswers'] = [a, full, full[len(a) + 2:]]
    else:
        ans = spec['a'] if isinstance(spec['a'], list) else [spec['a']]
        q['options'] = []
        q['acceptedAnswers'] = ans
        q['maxWordCount'] = spec.get('max', shared.get('max', 2))
    return q

def roman(n):
    r = ['i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix', 'x', 'xi', 'xii']
    return r[:n]

def build(src):
    if str(SRC) not in sys.path: sys.path.insert(0, str(SRC))
    E = runpy.run_path(str(src))['EXAM']
    eid = E['id']
    issues = []
    if eid != src.stem: raise ValueError(f'id {eid} must match file name {src.stem}')
    pool = E.get('pool', 'mock')
    exam = {'id': eid, 'examNumber': E['number'], 'pool': pool,
            'title': f"{'Practice Test' if pool == 'practice' else 'Mock Exam'} {E['number']}: {E['theme']}",
            'difficulty': LEVELS[E.get('level', 'standard')], 'theme': E['theme']}
    # ---------------- listening
    parts, n = [], 1
    for pi, P in enumerate(E['listening'], 1):
        turns = [{'id': stable_id(eid, 'lp', pi, ti), 'speaker': s, 'accent': ACCENT[a], 'text': txt}
                 for ti, (s, a, txt) in enumerate(P['script'])]
        qs, groups = [], []
        for G in P['groups']:
            start = n
            for spec in G['items']:
                qs.append(expand_question(eid, 'L', n, spec, G)); n += 1
            g = {'from': start, 'to': n - 1, 'instruction': G['instruction']}
            if G.get('opts') and G.get('showOpts', True): g['options'] = qs[-1]['options']
            if G.get('table'): g['table'] = G['table']
            if G.get('map'): g['map'] = G['map']
            groups.append(g)
        accents = collections.Counter(t['accent'] for t in turns)
        parts.append({'id': f'{eid}-lp{pi}', 'partNumber': pi, 'title': P['title'], 'contextDescription': P['context'],
                      'primaryAccent': accents.most_common(1)[0][0], 'dialogue': turns, 'questions': qs,
                      'keyVocabulary': P.get('vocab', []), 'groups': groups})
    exam['listeningParts'] = parts
    # ---------------- reading
    passages, n = [], 1
    for ri, R in enumerate(E['reading'], 1):
        qs, groups = [], []
        for G in R['groups']:
            start = n
            for spec in G['items']:
                qs.append(expand_question(eid, 'R', n, spec, G)); n += 1
            g = {'from': start, 'to': n - 1, 'instruction': G['instruction']}
            if G.get('opts') and G.get('showOpts', True): g['options'] = qs[-1]['options']
            groups.append(g)
        wc = len(' '.join(R['paragraphs']).split())
        passages.append({'id': f'{eid}-rp{ri}', 'passageNumber': ri, 'title': R['title'], 'discipline': R['discipline'],
                         'paragraphs': R['paragraphs'], 'questions': qs, 'estimatedWordCount': wc, 'groups': groups,
                         **({'subtitle': R['subtitle']} if R.get('subtitle') else {}),
                         **({'labelled': R['labelled']} if 'labelled' in R else {})})
    exam['readingPassages'] = passages
    # ---------------- writing
    W1 = E['writing1']
    exam['writingTask1'] = {
        'id': f'{eid}-w1', 'title': W1['title'], 'visualType': VISUALS[W1['visual']], 'instructions': W1['instructions'],
        'minimumWords': 150,
        'dataPoints': [{'id': stable_id(eid, 'w1', i), 'series': s, 'category': c, 'value': float(v), 'unit': W1.get('unit', '')}
                       for i, (s, c, v) in enumerate(W1.get('data', []))],
        'processSteps': W1.get('steps', []), 'keyOverviewPoints': W1['overview']}
    W2 = E['writing2']
    exam['writingTask2'] = {'id': f'{eid}-w2', 'title': W2['title'], 'essayType': ESSAYS[W2['type']],
                            'topicDomain': W2['domain'], 'promptText': W2['prompt'], 'minimumWords': 250}
    S = E['speaking']
    exam['speakingSet'] = {'id': f'{eid}-spk', 'theme': S['theme'], 'part1Questions': S['part1'],
                           'part2CueCard': {'topic': S['cue'], 'bulletPoints': S['bullets'], 'prepSeconds': 60, 'speakSeconds': 120},
                           'part3Questions': S['part3']}
    notes = list(E.get('notes', []))
    exam['provenance'] = {
        'origin': 'Original IELTS-Style Practice', 'isOfficialIELTSMaterial': False,
        'generatorModel': E.get('generatorModel', 'Hand-authored (Claude) — original IELTS-style text'), 'validatedAt': NOW, 'validationPassed': True,
        'validationNotes': ['Passed build_exams.py: 4 Listening parts / 40 questions, 3 Reading passages / 40 questions, every evidence quote found verbatim, no cross-exam duplicates.'] + notes + [
            'Original practice material written to the public IELTS Academic format. Not an official or past IELTS paper.',
            'People and organisations named in passages and scripts are fictional unless the text states otherwise.'],
        'sourceReferenceIDs': ['src-ielts-org', 'src-british-council', 'src-idp-ielts']}
    validate(exam, issues)
    return exam, issues

def validate(exam, issues):
    lp, rp = exam['listeningParts'], exam['readingPassages']
    if len(lp) != 4: issues.append(f'{len(lp)} listening parts (need 4)')
    if len(rp) != 3: issues.append(f'{len(rp)} reading passages (need 3)')
    for mod, units, textf, minw in (('L', lp, lambda u: ' '.join(t['text'] for t in u['dialogue']), 600),
                                    ('R', rp, lambda u: ' '.join(u['paragraphs']), 700)):
        qs = [q for u in units for q in u['questions']]
        if len(qs) != 40: issues.append(f'{mod}: {len(qs)} questions (need 40)')
        if [q['number'] for q in qs] != list(range(1, len(qs) + 1)): issues.append(f'{mod}: numbering not 1..N')
        for u in units:
            body = norm(textf(u)); wc = len(textf(u).split())
            if wc < minw: issues.append(f'{u["id"]}: only {wc} words (min {minw})')
            if mod == 'L' and len(u['questions']) != 10: issues.append(f'{u["id"]}: {len(u["questions"])} questions (need 10)')
            for q in u['questions']:
                ev = norm(q['evidenceQuote'])
                if not ev or ev not in body: issues.append(f'{q["id"]}: evidence not found verbatim: "{q["evidenceQuote"][:70]}"')
                if not q['options']:
                    a = q['acceptedAnswers'][0]
                    if len(a.split()) > q['maxWordCount']: issues.append(f'{q["id"]}: answer "{a}" longer than {q["maxWordCount"]} words')
                    if norm(a) not in body and not re.fullmatch(r'[\d.,£$€%/:]+', a): issues.append(f'{q["id"]}: answer "{a}" not found in text')
                    if norm(a) not in ev and not re.fullmatch(r'[\d.,£$€%/:]+', a): issues.append(f'{q["id"]}: answer "{a}" not inside its evidence quote')
        # answer balance for TFNG / options
        dist = collections.Counter(q['acceptedAnswers'][0] for q in qs if q['format'] in ('True / False / Not Given', 'Yes / No / Not Given'))
        if dist and len(dist) < 3 and sum(dist.values()) >= 5: issues.append(f'{mod}: TF/NG answers only use {sorted(dist)}')
    w1 = exam['writingTask1']
    if w1['visualType'] in ('Line Chart', 'Bar Chart', 'Pie Chart', 'Table', 'Combined Visual Data') and len(w1['dataPoints']) < 4:
        issues.append('writing1: chart needs data points')
    if w1['visualType'] in ('Process Diagram', 'Map Comparison') and len(w1['processSteps']) < 5:
        issues.append('writing1: process/map needs steps')
    sp = exam['speakingSet']
    if len(sp['part1Questions']) < 4 or len(sp['part3Questions']) < 4 or len(sp['part2CueCard']['bulletPoints']) < 3:
        issues.append('speaking set too short')

def trigrams(s):
    w = re.findall(r'[a-z0-9]+', s.lower())
    return {tuple(w[i:i + 3]) for i in range(len(w) - 2)}

def cross_check(exams, issues_by):
    stems, paras, transcripts = [], [], []
    for e in exams:
        for u in e['listeningParts'] + e['readingPassages']:
            for q in u['questions']:
                tg = trigrams(q['prompt'])
                if len(tg) >= 3: stems.append((e['id'], q['id'], tg))
            for p in u.get('paragraphs', []):
                paras.append((e['id'], u['id'], trigrams(p)))
            if u.get('dialogue'):
                transcripts.append((e['id'], u['id'], trigrams(' '.join(t['text'] for t in u['dialogue']))))
    def scan(items, what, thr):
        # Only pairs sharing a trigram can pass a positive Jaccard threshold.
        # Count shared trigrams through postings instead of intersecting every pair.
        postings = collections.defaultdict(list)
        matches = []
        for j, b in enumerate(items):
            intersections = collections.Counter()
            for trigram in b[2]:
                for i in postings[trigram]:
                    if items[i][0] != b[0]: intersections[i] += 1
            for i, inter in intersections.items():
                a = items[i]
                if inter / (len(a[2]) + len(b[2]) - inter) >= thr:
                    matches.append((i, j))
            for trigram in b[2]: postings[trigram].append(j)
        # Keep the original pair order so reports remain deterministic.
        for i, j in sorted(matches):
            a, b = items[i], items[j]
            issues_by.setdefault(a[0], []).append(f'{what} {a[1]} near-duplicates {b[1]}')
    scan(stems, 'stem', 0.6); scan(paras, 'paragraph', 0.3); scan(transcripts, 'transcript', 0.3)

def main():
    only = set(sys.argv[1:])
    files = sorted(SRC.glob('exam*.py')) + sorted(SRC.glob('practice*.py'))
    built, issues_by = [], {}
    for f in files:
        try:
            ex, iss = build(f)
        except Exception as err:
            issues_by[f.stem] = [f'build error: {err!r}']; continue
        built.append(ex)
        if iss: issues_by[ex['id']] = iss
    legacy = [e for e in json.loads(LEGACY.read_text())['exams'] if e.get('provenance', {}).get('validationPassed') is not False] if LEGACY.exists() else []
    cross_check(built + legacy, issues_by)
    OUT.mkdir(parents=True, exist_ok=True)
    ok = 0
    for ex in built:
        if only and not any(o in ex['id'] for o in only): continue
        iss = issues_by.get(ex['id'], [])
        lw = [sum(len(t['text'].split()) for t in p['dialogue']) for p in ex['listeningParts']]
        rw = [p['estimatedWordCount'] for p in ex['readingPassages']]
        print(f"{ex['id']:10s} L words {lw}  R words {rw}  W1 {ex['writingTask1']['visualType']:16s} W2 {ex['writingTask2']['essayType'][:12]:12s} {'OK' if not iss else 'FAIL'}")
        for i in iss: print('   -', i)
        if not iss:
            (OUT / f"{ex['id']}.json").write_text(json.dumps(ex, ensure_ascii=False, indent=1)); ok += 1
    for k, v in issues_by.items():
        if k.startswith(('exam', 'practice')) and not any(e['id'] == k for e in built): print(k, 'FAIL'); [print('   -', i) for i in v]
    print(f'{ok} exam(s) written to {OUT.relative_to(ROOT)}')
    sys.exit(1 if any(issues_by.get(e['id']) for e in built) or any(k not in {e['id'] for e in built} for k in issues_by if k.startswith(('exam', 'practice'))) else 0)

def build_banks():
    bsrc = ROOT / 'Content' / 'banks'; bout = OUT.parent / 'banks'
    if not bsrc.exists(): return
    bout.mkdir(parents=True, exist_ok=True)
    END = ' Summarise the information by selecting and reporting the main features, and make comparisons where relevant. Write at least 150 words.'
    w1 = runpy.run_path(str(bsrc / 'writing1.py'))['W1']
    out1 = []
    for i, t in enumerate(w1, 1):
        tid = f'bank-w1-{i:03d}'
        item = {'id': tid, 'title': t['title'], 'visualType': VISUALS[t['visual']], 'instructions': t['desc'] + END, 'minimumWords': 150,
                'dataPoints': [{'id': stable_id(tid, j), 'series': a, 'category': b, 'value': float(c), 'unit': t.get('unit', '')} for j, (a, b, c) in enumerate(t.get('data', []))],
                'processSteps': t.get('steps', []), 'keyOverviewPoints': t['overview']}
        if item['visualType'] in ('Process Diagram', 'Map Comparison'): assert len(item['processSteps']) >= 5, tid
        else: assert len(item['dataPoints']) >= 4, tid
        out1.append(item)
    w2 = runpy.run_path(str(bsrc / 'writing2.py'))['W2']
    out2 = [{'id': f'bank-w2-{i:03d}', 'title': title, 'essayType': ESSAYS[ty], 'topicDomain': dom, 'promptText': prompt, 'minimumWords': 250}
            for i, (ty, dom, title, prompt) in enumerate(w2, 1)]
    sp = runpy.run_path(str(bsrc / 'speaking.py'))['SP']
    if (bsrc / 'speaking_expansion.py').exists():
        sp = sp + runpy.run_path(str(bsrc / 'speaking_expansion.py'))['SP']
    out3 = []
    for i, (theme, p1, cue, bullets, p3) in enumerate(sp, 1):
        assert len(p1) >= 4 and len(bullets) >= 3 and len(p3) >= 4, theme
        out3.append({'id': f'bank-sp-{i:03d}', 'theme': theme, 'part1Questions': p1,
                     'part2CueCard': {'topic': cue, 'bulletPoints': bullets, 'prepSeconds': 60, 'speakSeconds': 120}, 'part3Questions': p3})
    for name, data in (('writing1', out1), ('writing2', out2), ('speaking', out3)):
        (bout / f'{name}.json').write_text(json.dumps(data, ensure_ascii=False, indent=1))
    print(f'banks: {len(out1)} Task 1 visuals, {len(out2)} Task 2 prompts, {len(out3)} speaking topics')

if __name__ == '__main__':
    build_banks()
    main()
