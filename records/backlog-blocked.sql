-- What an item waits on that is another item of this base: ids, comma-separated, or none (--blocked-by not given
-- takes the wait away). It is clear once each named item is done; the rest of the item is kept. What is outside this
-- base (the author, a SIM card) is its waits, set with ikb set.
-- --id          string   the item
-- --blocked-by  string?  the items, ids comma-separated
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM backlog WHERE id = $id) THEN error('no backlog item ' || $id || ' (tad q next lists them)') END;
SELECT CASE WHEN (SELECT count(*) FROM backlog WHERE id = $id) > 1 THEN error('the id ' || $id || ' names items of several places; change it with ikb set and both --key values') END;
SELECT CASE WHEN $blocked_by IS NOT NULL AND EXISTS (SELECT 1 FROM unnest(string_split($blocked_by, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM backlog))
    THEN error('blocked-by names no item of this base: ' || (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split($blocked_by, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM backlog)) || ' (tad q next lists the items)') END;
UPDATE backlog SET blocked_by = $blocked_by WHERE id = $id;
