-- Put an item of work on a lane's queue - what it needs (phone: this device's keeper; research or build: the
-- lane's launcher) - with the test whose pass proves it done and its place in the author's order. What is not
-- given is kept as it was: re-ranking an item is --rank alone and leaves what it needs alone; --needs none takes it
-- off every queue. Nothing to change, or an item that does not exist, is refused.
-- --id     string    the item
-- --needs  string?   phone, research or build; none takes it off the queues (not given: kept as it was)
-- --proof  string?   the test whose pass proves it done (kept as it was when not given)
-- --rank   integer?  where it stands in the queue, by the author's order: 1 first (kept as it was when not given)
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM backlog WHERE id = $id) THEN error('no backlog item ' || $id || ' (tad q next lists them)') END;
SELECT CASE WHEN $needs IS NULL AND $proof IS NULL AND $rank IS NULL THEN error('nothing to change: give --needs, --proof or --rank') END;
SELECT CASE WHEN $needs IS NOT NULL AND $needs NOT IN ('phone', 'research', 'build', 'none') THEN error('--needs is phone, research, build or none, not ' || $needs) END;
UPDATE backlog SET needs = CASE WHEN $needs = 'none' THEN NULL ELSE coalesce($needs, needs) END,
    proof = coalesce($proof, proof), rank = coalesce($rank, rank) WHERE id = $id;
