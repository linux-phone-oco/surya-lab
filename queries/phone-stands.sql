-- How the phone stands: the latest hand-over its keeper left (a log entry whose id ends in -how-the-phone-stands), for
-- the next keeper to start from. Written with:
--   ikb session-log --id YYYY-MM-DD-HHMM-how-the-phone-stands --title "How the phone stands" --done "..." --considered "next: ..."
SELECT id, entry_date, done AS how_it_stands, coalesce(considered, '') AS next_steps
FROM session_log
WHERE id LIKE '%-how-the-phone-stands'
ORDER BY id DESC LIMIT 1;
