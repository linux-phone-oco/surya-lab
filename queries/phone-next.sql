-- What this device's keeper takes now: the top item of its phone queue that waits on nothing - no `waits` (outside
-- this base) and every item in `blocked_by` done - in one row: the item, the test that proves it, what it is
-- about and its note.
WITH w AS (
    SELECT b.id, (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split(b.blocked_by, ',')) AS t(x)
                  WHERE trim(t.x) <> '' AND NOT EXISTS (SELECT 1 FROM backlog d WHERE d.id = trim(t.x) AND d.status = 'done')) AS blocked_on
    FROM backlog b)
SELECT b.id, b.status, b.title, coalesce(b.proof, '') AS proof, coalesce(b.about, '') AS about, b.note
FROM backlog b JOIN w USING (id)
WHERE b.needs = 'phone' AND b.status <> 'done' AND b.waits IS NULL AND w.blocked_on IS NULL
ORDER BY b.status <> 'in-progress', b.rank IS NULL, b.rank, b.proof IS NULL, b.opened, b.id
LIMIT 1;
