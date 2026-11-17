-- An item of this device's work ahead, or done (an item of that id is replaced).
-- --id       string        a-short-name
-- --title    string        what it is
-- --status   string = open  open, in-progress or done
-- --note     string?       where it stands, and the next step
-- --waits    string?       what it waits on, if anything (the author, a SIM card)
-- --about    string?       what it is about: a part of the device or a backlog item (tad q about lists them)
-- --opened   date = today  when it was opened
-- --needs    string?       phone, research or build: the lane's queue of that kind (tad q phone-queue for the phone's)
-- --proof    string?       the test whose pass proves it done (a test id, or the test still to write)
-- --rank     integer?      where it stands in the queue, by the author's order: 1 first
DELETE FROM backlog WHERE id = $id;
INSERT INTO backlog (id, title, status, note, waits, about, opened, needs, proof, rank)
VALUES ($id, $title, $status, $note, $waits, $about, $opened, $needs, $proof, $rank);
