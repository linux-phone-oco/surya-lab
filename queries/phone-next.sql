-- What this device's keeper takes now: the top item of its phone queue that waits on nothing - no `waits` (outside
-- this base), every item in `blocked_by` done, every piece of `hardware` owned and not refuted - in one row: the
-- item, the test that proves it, what it is about and its note.
WITH w AS (
    SELECT b.id,
        (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split(b.blocked_by, ',')) AS t(x)
         WHERE trim(t.x) <> '' AND NOT EXISTS (SELECT 1 FROM backlog d WHERE d.id = trim(t.x) AND d.status = 'done')) AS blocked_on,
        (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split(b.hardware, ',')) AS t(x)
         WHERE trim(t.x) <> '' AND NOT EXISTS (SELECT 1 FROM hardware h WHERE h.id = trim(t.x) AND h.status = 'owned' AND coalesce(h.fit, '') <> 'refuted')) AS awaits_hardware
    FROM backlog b)
SELECT b.id, b.status, b.title, coalesce(b.proof, '') AS proof, coalesce(b.about, '') AS about, b.note
FROM backlog b JOIN w USING (id)
WHERE b.needs = 'phone' AND b.status <> 'done' AND b.waits IS NULL AND w.blocked_on IS NULL AND w.awaits_hardware IS NULL
ORDER BY b.status <> 'in-progress', b.rank IS NULL, b.rank, b.proof IS NULL, b.opened, b.id
LIMIT 1;
