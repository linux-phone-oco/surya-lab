-- A person's go on an item that needs a witness: it is ready, for an unattended session, until the moment given
-- (--until not given closes the go). Say it when the person says go, and what they were told to expect in the
-- item's note; the window is what tad q ready reads.
-- --id     string   the item (one with --witness person)
-- --until  string?  when the go ends, with its offset: date -Is, or "2026-11-18T19:30:00+01:00"
-- --outcomes string? one line per outcome, "if X then it proves Y"; required when a go is opened (--until given); kept in the item's note
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM backlog WHERE id = $id) THEN error('no backlog item ' || $id || ' (tad q next lists them)') END;
SELECT CASE WHEN (SELECT count(*) FROM backlog WHERE id = $id) > 1 THEN error('the id ' || $id || ' names items of several places; change it with ikb set and both --key values') END;
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM backlog WHERE id = $id AND witness IS NOT NULL) THEN error($id || ' needs no witness (ikb backlog --witness person says it does)') END;
SELECT CASE WHEN $until IS NOT NULL AND try_cast($until AS TIMESTAMPTZ) IS NULL THEN error('until is not a time with an offset: ' || $until || ' (date -Is gives one)') END;
SELECT CASE WHEN $until IS NOT NULL AND coalesce(trim($outcomes), '') = '' THEN error('a go lists its outcomes: --outcomes "if X then it proves Y" (one line each)') END;
UPDATE backlog SET go_until = $until, note = CASE WHEN $until IS NOT NULL THEN concat_ws(E'\n', note, 'go until ' || $until || ', outcomes: ' || $outcomes) ELSE note END WHERE id = $id;
