-- The work ahead: what is in progress, then what is open, the newest first - with what it is about and
-- what it waits on. Then row --id ID for an item whole.
-- --about  string?  only the work about this subject (a word before a dash names a family)
SELECT id, status, about, title, waits FROM backlog
WHERE status <> 'done' AND ($about IS NULL OR about = $about OR about LIKE $about || '-%' OR id = $about)
ORDER BY status = 'in-progress' DESC, opened DESC, id;
