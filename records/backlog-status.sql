-- Where an item of work stands now: its status, and its note and what it waits on when given (the rest is kept).
-- --id      string   the item
-- --status  string   open, in-progress or done
-- --note    string?  where it stands, and the next step (kept as it was when not given)
-- --waits   string?  what it waits on (kept as it was when not given)
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM backlog WHERE id = $id) THEN error('no backlog item ' || $id || ' (tad q next lists them)') END;
UPDATE backlog SET status = $status, note = coalesce($note, note), waits = coalesce($waits, waits) WHERE id = $id;
