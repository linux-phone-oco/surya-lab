-- How a subject stands, in short: written - or renewed in place - when tad q about shows it due. It
-- condenses every record about the subject as it stands when written (filled here, not typed), and names the
-- ones that carry it in its words. The earlier version stays in git; the records stay as they are.
-- --about  string        the subject (tad q about lists them, and which are due)
-- --says   string        how it stands, in at most 1500 characters, naming the records that carry it
-- --date   date = today  when
DELETE FROM summaries WHERE about = $about;
INSERT INTO summaries (about, date, says, condenses)
SELECT $about, $date, $says, string_agg(id, ', ' ORDER BY id) FROM (
    SELECT id FROM decisions WHERE about = $about UNION SELECT id FROM research WHERE about = $about
    UNION SELECT id FROM session_log WHERE about = $about);
