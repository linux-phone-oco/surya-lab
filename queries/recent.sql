-- What was recorded lately, the newest first: decisions, research, work opened and the log, each by its
-- id and brief. Then row --id ID for one whole - only when the brief is not enough.
-- --days  integer = 7  how many days back
SELECT kind, id, about, day, left(line, 200) AS line FROM (
    SELECT 'decision' AS kind, id, about, date AS day, coalesce(brief, CASE WHEN strpos(decision, '. ') > 0 THEN left(decision, strpos(decision, '. ')) ELSE decision END) AS line FROM decisions
    UNION ALL SELECT 'research', id, about, date, coalesce(brief, CASE WHEN strpos(found, '. ') > 0 THEN left(found, strpos(found, '. ')) ELSE found END) FROM research
    UNION ALL SELECT 'work', id, about, opened, title FROM backlog
    UNION ALL SELECT 'log', id, about, entry_date, title FROM session_log
    UNION ALL SELECT 'summary', about, about, date, says FROM summaries
    UNION ALL SELECT 'upstream', id, about, last_update, title FROM upstream_items
) WHERE day >= current_date - $days ORDER BY day DESC, kind, id;
