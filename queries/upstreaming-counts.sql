-- How many items stand at each stage of upstreaming, per upstream or per stage totals (see upstreaming for the
-- stages): one line per upstream with a count in each column, and a last line of totals. For the page's summary.
-- --upstream  string?  only what goes to this upstream
WITH x AS (
    SELECT i.upstream,
        CASE WHEN i.state = 'landed' OR i.applied_upstream IS NOT NULL THEN 'landed'
             WHEN i.state = 'accepted' THEN 'accepted'
             WHEN i.state IN ('sent', 'under-review', 'changes-requested') THEN 'in review'
             WHEN i.state IN ('rejected', 'withdrawn', 'not-needed', 'superseded') THEN 'closed'
             ELSE 'carried' END AS stage
    FROM upstream_items i
    WHERE $upstream IS NULL OR i.upstream = $upstream)
SELECT coalesce(upstream, 'all') AS upstream, count(*) AS items,
    count(*) FILTER (WHERE stage = 'carried') AS carried,
    count(*) FILTER (WHERE stage = 'in review') AS in_review,
    count(*) FILTER (WHERE stage = 'accepted') AS accepted,
    count(*) FILTER (WHERE stage = 'landed') AS landed,
    count(*) FILTER (WHERE stage = 'closed') AS closed
FROM x GROUP BY ROLLUP(upstream) ORDER BY upstream IS NULL, upstream;
