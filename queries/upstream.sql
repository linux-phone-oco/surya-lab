-- What is headed upstream and where it stands: the items not yet landed, rejected, superseded, not-needed or
-- withdrawn, the longest-waiting first - each with where it goes, its form, state and what it waits on. Then
-- row --id ID for one whole; upstreams lists the places.
-- --upstream  string?  only what goes to this upstream
-- --state     string?  only items in this state (finished ones too)
-- --about     string?  only what is about this subject
SELECT i.id, i.upstream, i.form, i.state, i.from_work, i.last_update, i.waits, i.title
FROM upstream_items i
WHERE ($upstream IS NULL OR i.upstream = $upstream)
  AND ($about IS NULL OR i.about = $about OR i.about LIKE $about || '-%')
  AND (($state IS NULL AND i.state NOT IN ('landed', 'rejected', 'superseded', 'not-needed', 'withdrawn')) OR i.state = $state)
ORDER BY i.last_update, i.id;
