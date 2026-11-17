-- What was learned, and from where (a research of that id is replaced). Its finding is the row; its own
-- material - notes, excerpts, measurements - goes in a dated folder the row names, read only when needed.
-- Research redone is a new row that supersedes the old: the old stays, reachable, and leaves about's answer.
-- --id          string        a-short-name
-- --brief       string        what was found, in one line of at most 200 characters: what answers show
-- --question    string        what was asked
-- --found       string        what was found, condensed
-- --sources     string?       the sources' ids, comma-separated (tad r source records each)
-- --about       string?       what it is about (tad q about lists the subjects)
-- --material    string?       its folder, research/SUBJECT/YYYY-MM-DD/
-- --supersedes  string?       the research it is a later version of (its id)
-- --date        date = today  when
DELETE FROM research WHERE id = $id;
INSERT INTO research (id, date, brief, question, found, sources, about, material, supersedes)
SELECT $id, $date, $brief, $question, $found, $sources, $about, $material, $supersedes
WHERE CASE WHEN length($brief) > 200 THEN error('the brief is ' || length($brief) || ' characters; at most 200') ELSE true END;
