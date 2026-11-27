"""Tiny helpers so exam source files stay readable. Used by Scripts/build_exams.py."""

def Q(t, q, a, ev, why, **kw):
    """One question. t: mcq|tfng|ynng|headings|info|features|endings|match|form|note|table|flow|summary|sentence|map|short.
    a: answer letter (option types), TRUE/FALSE/NOT GIVEN, or the typed answer (str or list of accepted spellings).
    ev: exact words from the script/passage that justify the answer. why: the explanation shown after marking.
    kw: opts=[...] (mcq), skill='tag', trap='why the distractor is wrong', max=N (typed answers)."""
    d = {'t': t, 'q': q, 'a': a, 'ev': ev, 'why': why}
    d.update(kw)
    return d

def G(instruction, items, **kw):
    """A question group with the instruction shown above it, e.g. 'Write ONE WORD AND/OR A NUMBER for each answer.'
    kw: opts=[...] shared options for matching groups, max=N, map={...} for map labelling."""
    d = {'instruction': instruction, 'items': items}
    d.update(kw)
    return d
