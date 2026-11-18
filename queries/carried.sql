-- What is carried: the patches kept in a fork until their upstream has them, with where each stands there
-- and what the fork does about it - keep (still open upstream), drop at the next rebase (landed, accepted
-- or applied upstream: it comes with the release), or ask why (rejected, withdrawn, superseded, not-needed:
-- carried by choice or by forgetting). Then row --id ID for one whole; upstream shows what is still open.
-- --upstream  string?  only what is carried for this upstream
-- --fork      string?  only what this fork carries (the start of carried_in)
SELECT i.id, i.upstream, i.carried_in, i.state, i.applied_upstream, i.last_update,
  CASE WHEN i.state IN ('landed') OR i.applied_upstream IS NOT NULL THEN 'drop at the next rebase'
       WHEN i.state IN ('rejected', 'withdrawn', 'superseded', 'not-needed') THEN 'ask why it is still carried'
       ELSE 'keep' END AS fork_does,
  i.title
FROM upstream_items i
WHERE i.carried_in IS NOT NULL
  AND ($upstream IS NULL OR i.upstream = $upstream)
  AND ($fork IS NULL OR i.carried_in = $fork OR i.carried_in LIKE $fork || '%')
ORDER BY fork_does, i.last_update, i.id;
