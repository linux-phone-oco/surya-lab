-- Where something is said: the id and brief of every record that says it, in any case, the latest first.
-- Then row --id ID for the one wanted, whole - only when the brief is not enough.
-- --text  string  the words, as they stand
WITH t AS (SELECT lower($text) AS w),
said AS (
    SELECT 'decision' AS kind, id, about, date AS day, coalesce(brief, CASE WHEN strpos(decision, '. ') > 0 THEN left(decision, strpos(decision, '. ')) ELSE decision END) AS line, concat_ws(' ', id, brief, decision, why, rejected) AS hay FROM decisions
    UNION ALL SELECT 'research', id, about, date, coalesce(brief, CASE WHEN strpos(found, '. ') > 0 THEN left(found, strpos(found, '. ')) ELSE found END), concat_ws(' ', id, brief, question, found) FROM research
    UNION ALL SELECT 'work', id, about, opened, title, concat_ws(' ', id, title, note, waits) FROM backlog
    UNION ALL SELECT 'log', id, about, entry_date, title, concat_ws(' ', id, title, done, considered, rejected) FROM session_log
    UNION ALL SELECT 'summary', about, about, date, says, concat_ws(' ', about, says) FROM summaries
    UNION ALL SELECT 'source', id, NULL, NULL, title, concat_ws(' ', id, title, url, takes) FROM sources
    UNION ALL SELECT 'upstream', id, about, last_update, title, concat_ws(' ', id, upstream, title, form, domain, tags, note, waits, forwarded, bug) FROM upstream_items
)
SELECT kind, id, about, day, left(line, 200) AS line FROM said, t
WHERE contains(lower(hay), t.w) ORDER BY day DESC NULLS LAST, kind, id;
