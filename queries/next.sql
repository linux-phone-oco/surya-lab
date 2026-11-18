-- The work ahead: what is in progress, then what is open, the newest first - with what it is about, what it
-- waits on outside this base (`waits`) and which items of this base it still waits on (`blocked_on`: those in
-- blocked_by not yet done - an item done clears itself). Then row --id ID for an item whole.
-- --about  string?  only the work about this subject (a word before a dash names a family)
SELECT b.id, b.status, b.about, b.title, b.waits,
       (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split(b.blocked_by, ',')) AS t(x)
        WHERE trim(t.x) <> '' AND NOT EXISTS (SELECT 1 FROM backlog d WHERE d.id = trim(t.x) AND d.status = 'done')) AS blocked_on
FROM backlog b
WHERE b.status <> 'done' AND ($about IS NULL OR b.about = $about OR b.about LIKE $about || '-%' OR b.id = $about)
ORDER BY b.status = 'in-progress' DESC, b.opened DESC, b.id;
