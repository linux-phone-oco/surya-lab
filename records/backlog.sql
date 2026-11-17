-- An item of this device's work ahead, or done (an item of that id is replaced).
-- --id          string        a-short-name
-- --title       string        what it is
-- --status      string = open  open, in-progress or done
-- --note        string?       where it stands, and the next step
-- --waits       string?       what it waits on that is outside this base: the author, a SIM card, hardware (never an item: blocked-by)
-- --blocked-by  string?       the items of this base it waits on, ids comma-separated: it is clear once each is done
-- --about       string?       what it is about: a part of the device or a backlog item (tad q about lists them)
-- --opened      date = today  when it was opened
-- --needs       string?       phone, research or build: the lane's queue of that kind (tad q phone-queue for the phone's)
-- --proof       string?       the test whose pass proves it done (a test id, or the test still to write)
-- --rank        integer?      where it stands in the queue, by the author's order: 1 first
SELECT CASE WHEN $blocked_by IS NOT NULL AND EXISTS (SELECT 1 FROM unnest(string_split($blocked_by, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM backlog))
    THEN error('blocked-by names no item of this base: ' || (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split($blocked_by, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM backlog)) || ' (tad q next lists the items)') END;
DELETE FROM backlog WHERE id = $id;
INSERT INTO backlog (id, title, status, note, waits, blocked_by, about, opened, needs, proof, rank)
VALUES ($id, $title, $status, $note, $waits, $blocked_by, $about, $opened, $needs, $proof, $rank);
