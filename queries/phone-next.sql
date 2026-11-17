-- What this device's keeper takes now: the top item of its phone queue that waits on nothing, in one row -
-- the item, the test that proves it, what it is about and its note.
SELECT id, status, title, coalesce(proof, '') AS proof, coalesce(about, '') AS about, note
FROM backlog
WHERE needs = 'phone' AND status <> 'done' AND waits IS NULL
ORDER BY status <> 'in-progress', rank IS NULL, rank, proof IS NULL, opened, id
LIMIT 1;
