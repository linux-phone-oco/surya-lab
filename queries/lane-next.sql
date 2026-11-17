-- What a lane's session takes now: the top item of the queue of that kind (phone: the keeper's; research or build)
-- that waits on nothing, in one row - the item, the test that proves it, what it is about and its note. For the
-- phone, phone-next says the same.
-- --needs  string  phone, research or build
SELECT id, status, title, coalesce(proof, '') AS proof, coalesce(about, '') AS about, note
FROM backlog
WHERE needs = $needs AND status <> 'done' AND waits IS NULL
ORDER BY status <> 'in-progress', rank IS NULL, rank, proof IS NULL, opened, id
LIMIT 1;
