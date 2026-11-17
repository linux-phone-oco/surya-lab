-- Put an item of work on a lane's queue - what it needs (phone: this device's keeper; research or build: the
-- lane's launcher) - with the test whose pass proves it done and its place in the author's order; or take it
-- off (--needs not given). The rest of the item is kept.
-- --id     string    the item
-- --needs  string?   phone, research or build (not given: it needs nothing shared)
-- --proof  string?   the test whose pass proves it done (kept as it was when not given)
-- --rank   integer?  where it stands in the queue, by the author's order: 1 first (kept as it was when not given)
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM backlog WHERE id = $id) THEN error('no backlog item ' || $id || ' (tad q next lists them)') END;
UPDATE backlog SET needs = $needs, proof = coalesce($proof, proof), rank = coalesce($rank, rank) WHERE id = $id;
