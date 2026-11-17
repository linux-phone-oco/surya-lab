-- The phone's queue: the work that cannot be done without the phone, in the order its keeper takes it up -
-- what is in progress first, then the author's order (rank) - an item that waits keeps its place and says what on:
-- `waits` (outside this base) and `blocked_on` (items of this base not yet done; an item done clears itself). The
-- keeper takes the first that waits on nothing - then what names the test that proves it, then the oldest. One
-- change to the phone at a time (devlab holds it); other sessions put work here with backlog-needs (needs phone,
-- and the proof), never on the phone. The base is the device: no device option.
WITH w AS (
    SELECT b.id, (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split(b.blocked_by, ',')) AS t(x)
                  WHERE trim(t.x) <> '' AND NOT EXISTS (SELECT 1 FROM backlog d WHERE d.id = trim(t.x) AND d.status = 'done')) AS blocked_on
    FROM backlog b)
SELECT b.id, b.status, b.rank, b.title, coalesce(b.proof, '') AS proof, coalesce(b.waits, '') AS waits, coalesce(w.blocked_on, '') AS blocked_on, b.note
FROM backlog b JOIN w USING (id)
WHERE b.needs = 'phone' AND b.status <> 'done'
ORDER BY b.status <> 'in-progress', b.rank IS NULL, b.rank, (b.waits IS NOT NULL OR w.blocked_on IS NOT NULL), b.proof IS NULL, b.opened, b.id;
