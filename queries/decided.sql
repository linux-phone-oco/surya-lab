-- Where each decision stands, read off the work and never typed: superseded (by a later decision - left out
-- unless --all), carried out (the backlog item named in tracked_by is done), in work (that item is open or in
-- progress), or no item named (nothing says what carries it out: shown as not known, not as undone). With who it binds (scope), what it amends and what amends
-- it. Then row --id ID for one whole.
-- --about  string?          only the decisions about this subject (a word before a dash names a family)
-- --all    boolean = false  superseded ones too
SELECT d.id, d.date,
  CASE WHEN s.id IS NOT NULL THEN 'superseded by ' || s.id
       WHEN b.status = 'done' THEN 'carried out'
       WHEN b.status = 'dropped' THEN 'dropped, not carried out'
       WHEN b.id IS NOT NULL THEN 'in work'
       ELSE 'no item named' END AS stands,
  d.scope, d.amends, (SELECT string_agg(a.id, ', ' ORDER BY a.id) FROM decisions a WHERE a.amends = d.id) AS amended_by,
  d.tracked_by, d.brief
FROM decisions d
LEFT JOIN decisions s ON s.supersedes = d.id
LEFT JOIN backlog b ON b.id = d.tracked_by
WHERE ($about IS NULL OR d.about = $about OR d.about LIKE $about || '-%')
  AND ($all OR s.id IS NULL)
ORDER BY d.date DESC, d.id;
