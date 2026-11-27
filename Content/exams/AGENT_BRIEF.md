# Brief for exam-writing agents

You write ORIGINAL, high-quality IELTS Academic tests as Python files in
`/home/claude/proj/Content/exams/`. Read `README.md` here, then study `exam12.py`
and `practice11.py` closely — copy their exact structure, style, difficulty and length.

## What to produce
Each file is a complete 4-skill test: `listening` (4 parts), `reading` (3 passages),
`writing1`, `writing2`, `speaking`. File stem == `id`. Mock: `'id': 'examNN', 'number': NN`.
Practice: `'id': 'practiceNN', 'number': NN, 'pool': 'practice'`.
`level` is one of: foundation, standard, target, advanced.

## Real IELTS structure (follow it)
- Listening P1: everyday conversation, form/note completion (10 Qs, ONE WORD AND/OR A NUMBER), include a spelled name ("It's Name. N-A-M-E." — the evidence must contain the answer word), numbers/dates with a distractor (`trap=`).
- P2: monologue on a social topic (MCQ A–C and/or matching with group `opts=` and type `'match'`, or sentence/flow completion).
- P3: academic discussion of 2–3 speakers (MCQ + notes).
- P4: academic lecture, 10 note-completion Qs (ONE WORD ONLY).
- Each script ≥ 600 words — AIM FOR 680–750 so you don't fail. Accents allowed: GB, US, AU, CA, IE only.
- Reading: 3 passages, 8 paragraphs each, ≥ 700 words — AIM FOR 760–850. Questions 13/13/14:
  P1: TFNG (7) + note/sentence completion (6). P2: headings for B–H (7, roman numerals i–ix, 9 options) + MCQ A–D (3) + sentence completion (3).
  P3: features matching (5, letters, group opts) + YES/NO/NOT GIVEN (5, writer's opinion — include "In my view" sentences) + summary (4).
- TFNG/YNNG groups of ≥5 must use all three answers.
- writing1 visual: bar | line | pie | table | process | map | combined. Data format exactly as in existing files (see exam12 table, exam11 bar, practice10 pie, practice09 process 'steps', practice11 map 'steps' "MapName|zone|feature", zones NW N NE W C E SW S SE).
- writing2 type: opinion | discussion | advdis | problem | twopart.
- speaking: theme, part1 (5), cue, bullets (4), part3 (5).

## Hard validation rules (builder rejects otherwise)
- Every `ev` must be an EXACT verbatim substring of the script/passage (no "...", same apostrophes/quotes).
- Typed answers must appear inside their `ev`, and be within `max` words. For a list of accepted answers, the FIRST one must appear in the text.
- No question stem may closely resemble a stem in any other exam — write specific, content-based stems, never generic ones ("What is the main idea?").
- Never leave placeholders.

## Accuracy — this is critical
The user wants content that is "real and 100% correct". Use only well-established facts
(dates, names, places, figures) you are confident about. When unsure, verify with WebSearch, or
phrase it vaguely ("in the early twentieth century", "around a third"), or choose another fact.
Do not invent researchers or studies; if you cite one, it must be real and correctly described.
Fictional everyday details (names of people, shops, prices in Part 1/2 dialogues) are fine.

## Topics
Before writing, run `grep -h "'title'.*'discipline'" exam*.py practice*.py` and avoid any
reading topic already used. Stay inside your assigned theme.

## Workflow
1. Write the file (listening first is fine, then add the rest) — write long enough the first time.
2. Run from `/home/claude/proj`: `python3 Scripts/build_exams.py 2>&1 | grep -A12 "^<your id>"`
3. Fix every FAIL in YOUR files only (if a stem clashes with another exam, change yours). Repeat until OK.
4. Do NOT edit other exam files, scripts, or deploy anything. Other agents are writing in parallel.
5. Report: ids written, themes, word counts, and confirmation that each shows OK.
