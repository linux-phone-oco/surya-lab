-- What a session may take now, and why the rest may not: every item not done, ready or skipped, the ready ones
-- first in the queue's order - in progress, the author's rank, a proof named, oldest. An item is ready when it
-- waits on nothing outside this base (no `waits`), every item in `blocked_by` is done (a done blocker is clear),
-- and every piece of `hardware` is owned and not refuted. An item that needs a witness (`witness`)
-- is ready only while a person's go is open (`go_until` still ahead). A blocker this base no longer holds is not clear: the
-- item is skipped and says so. Each skipped item names why. The one query every base shares: a brief names it
-- and carries no picking SQL of its own.
-- An item that needs a witness shows `witness` (person) and, while a person's go is open, `go_until` - when it ends;
-- ready with a witness and no go_until cannot be (the go is read here, not from the note).
-- --for    string?          keeper (needs phone), builder (needs build) or research (needs research); every lane when not given
-- --about  string?          only the work about this subject (a word before a dash names a family)
-- --show   string = all     ready, skipped or all
WITH w AS (
    SELECT b.id,
        concat_ws('; ',
            CASE WHEN b.waits IS NOT NULL THEN 'waits: ' || b.waits END,
            CASE WHEN b.witness IS NOT NULL AND NOT coalesce(try_cast(b.go_until AS TIMESTAMPTZ) > now(), false) THEN 'needs a witness (no go open: a person says go, then ikb backlog-go)' END,
            (SELECT 'blocked by ' || string_agg(trim(t.x) || CASE WHEN NOT EXISTS (SELECT 1 FROM backlog d WHERE d.id = trim(t.x)) THEN ' (not in this base)' ELSE ' (' || (SELECT status FROM backlog d WHERE d.id = trim(t.x)) || ')' END, ', ')
               FROM unnest(string_split(b.blocked_by, ',')) AS t(x)
              WHERE trim(t.x) <> '' AND NOT EXISTS (SELECT 1 FROM backlog d WHERE d.id = trim(t.x) AND d.status = 'done')),
            (SELECT 'hardware ' || string_agg(trim(t.x) || ' (' || coalesce((SELECT h.status || coalesce(', fit ' || h.fit, '') FROM hardware h WHERE h.id = trim(t.x)), 'not in this base') || ')', ', ')
               FROM unnest(string_split(b.hardware, ',')) AS t(x)
              WHERE trim(t.x) <> '' AND NOT EXISTS (SELECT 1 FROM hardware h WHERE h.id = trim(t.x) AND h.status = 'owned' AND coalesce(h.fit, '') <> 'refuted'))
        ) AS why
    FROM backlog b)
SELECT b.id, CASE WHEN w.why = '' THEN 'ready' ELSE 'skipped' END AS stands, w.why, b.witness,
       CASE WHEN b.witness IS NOT NULL AND try_cast(b.go_until AS TIMESTAMPTZ) > now() THEN b.go_until END AS go_until,
       b.status, b.rank, coalesce(b.proof, '') AS proof, coalesce(b.about, '') AS about, b.title, b.note
FROM backlog b JOIN w USING (id)
WHERE b.status NOT IN ('done', 'dropped')
  AND ($for IS NULL OR b.needs = CASE $for WHEN 'keeper' THEN 'phone' WHEN 'builder' THEN 'build' WHEN 'research' THEN 'research' ELSE $for END)
  AND ($about IS NULL OR b.about = $about OR b.about LIKE $about || '-%' OR b.id = $about)
  AND ($show = 'all' OR ($show = 'ready' AND w.why = '') OR ($show = 'skipped' AND w.why <> ''))
ORDER BY w.why <> '', b.status <> 'in-progress', b.rank IS NULL, b.rank, b.proof IS NULL, b.opened, b.id;
