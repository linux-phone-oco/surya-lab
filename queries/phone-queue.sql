-- The phone's queue: the work that cannot be done without the phone, in the order its keeper takes it up -
-- what is in progress first, then the author's order (rank) - an item that waits (on research, on the author)
-- keeps its place and says what it waits on; the keeper takes the first that waits on nothing - then what names the
-- test that proves it, then the oldest. One change to the phone at a time (devlab holds it); other sessions put
-- work here (backlog-needs --needs phone --proof TEST), never on the phone. The base is the device: no --device.
SELECT id, status, rank, title, coalesce(proof, '') AS proof, coalesce(waits, '') AS waits, note
FROM backlog
WHERE needs = 'phone' AND status <> 'done'
ORDER BY status <> 'in-progress', rank IS NULL, rank, waits IS NOT NULL, proof IS NULL, opened, id;
