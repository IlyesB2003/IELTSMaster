# Hand-authored IELTS exams

Each `examNN.py` (Full Mock Exams) or `practiceNN.py` (practice pool) defines `EXAM` using
`Q()` / `G()` from `_kit.py`. Build and validate everything with:

    python3 Scripts/build_exams.py

Rules enforced by the builder (an exam that breaks any rule is not written):
- 4 Listening parts × 10 questions, each script >= 600 words (aim 650–750)
- 3 Reading passages, 40 questions total (13/13/14), each passage >= 700 words (aim 750–900)
- every `ev` (evidence) quote appears verbatim in the script/passage; typed answers appear inside their evidence
- TRUE/FALSE/NOT GIVEN groups use all three answers; no stem near-duplicates another exam's stem
- Writing Task 1 has data (charts/tables) or >= 5 steps (process/map: "Label|zone|feature")

Output: `Web/server/content/exams/<id>.json` (loaded by the web server next to content.json).
Banks in `Content/banks/` build to `Web/server/content/banks/*.json` (Writing/Speaking practice).
