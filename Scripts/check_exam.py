#!/usr/bin/env python3
# Checks an AuthoredExamNN.swift file: word counts per part/passage, question numbering,
# and that every evidence quote appears verbatim in its passage or transcript.
# Usage: python3 Scripts/check_exam.py Sources/IELTSCore/Curriculum/AuthoredExams/AuthoredExam01.swift
import re,sys
src=open(sys.argv[1]).read()
def unesc(s): return s.replace('\\"','"')
# split into parts/passages by markers
blocks=re.split(r'// MARK: - ',src)
issues=0
for b in blocks:
    title=b.split('\n')[0]
    if not (title.startswith('Listening Part') or title.startswith('Reading Passage')): continue
    if title.startswith('Listening'):
        texts=[unesc(t) for t in re.findall(r'K\.turn\("[^"]*", \.\w+, "((?:[^"\\]|\\.)*)"\)',b)]
    else:
        m=re.search(r'paragraphs: \[(.*?)\n            \],',b,re.S)
        texts=[unesc(t) for t in re.findall(r'"((?:[^"\\]|\\.)*)"',m.group(1))]
    body=' '.join(texts)
    wc=len(body.split())
    qs=re.findall(r'K\.(mcq|match|tfng|ynng|gap)\((L|R), (\d+),(.*?)\),?\n',b)
    ev=re.findall(r'evidence: "((?:[^"\\]|\\.)*)"',b)
    nums=[int(q[2]) for q in qs]
    print(f"{title:60s} words={wc:5d} questions={len(qs)} nums={min(nums)}-{max(nums)}")
    for e in ev:
        if unesc(e).lower() not in body.lower():
            print("   MISSING evidence:",e); issues+=1
print("issues",issues)
