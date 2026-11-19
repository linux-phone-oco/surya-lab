-- An item of this device's work ahead, or done (an item of that id is replaced).
-- --id          string        a-short-name
-- --title       string        what it is
-- --status      string = open  open, in-progress, done, or dropped (closed without doing: the note says why, and whose word - the author's turn if he decided)
-- --note        string?       where it stands, and the next step
-- --waits       string?       what it waits on that is outside this base: the author, a SIM card, hardware (never an item: blocked-by)
-- --blocked-by  string?       the items of this base it waits on, ids comma-separated: it is clear once each is done
-- --hardware    string?       the hardware (ids of tad q hardware) it cannot be done without: it waits until each is owned and none refuted
-- --about       string?       what it is about: a part of the device or a backlog item (tad q about lists them)
-- --opened      date = today  when it was opened
-- --needs       string?       phone, research or build: the lane's queue of that kind (tad q phone-queue for the phone's)
-- --proof       string?       the test whose pass proves it done (a test id, or the test still to write)
-- --rank        integer?      where it stands in the queue, by the author's order: 1 first
-- --witness     string?       person: a step the author must see or hear - not ready for an unattended session unless a go is open (ikb backlog-go)
SELECT CASE WHEN $hardware IS NOT NULL AND EXISTS (SELECT 1 FROM unnest(string_split($hardware, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM hardware))
    THEN error('hardware names none of this base: ' || (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split($hardware, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM hardware)) || ' (ikb hardware records one)') END;
SELECT CASE WHEN $blocked_by IS NOT NULL AND EXISTS (SELECT 1 FROM unnest(string_split($blocked_by, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM backlog))
    THEN error('blocked-by names no item of this base: ' || (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split($blocked_by, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM backlog)) || ' (tad q next lists the items)') END;
SELECT CASE WHEN $status = 'dropped' AND $note IS NULL THEN error('a dropped item needs its note: why it was dropped, and whose word') END;
DELETE FROM backlog WHERE id = $id;
INSERT INTO backlog (id, title, status, note, waits, blocked_by, hardware, about, opened, needs, proof, rank, witness)
VALUES ($id, $title, $status, $note, $waits, $blocked_by, $hardware, $about, $opened, $needs, $proof, $rank, $witness);
