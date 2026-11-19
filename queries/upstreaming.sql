-- Upstreaming at a glance: how far what we send has got, where it goes, and how long it has waited. Each item
-- stands at a stage read off its state: carried (draft, ready, held: ours, not sent), in review (sent, under
-- review, changes requested), accepted, landed, closed (rejected, withdrawn, not-needed, superseded). The
-- tag is the fork's commit-subject tag (see carried).
-- --upstream  string?  only what goes to this upstream
-- --about     string?  only what is about this subject (a word before a dash names a family)
WITH x AS (
    SELECT i.id, i.upstream, coalesce(u.kind, '') AS target_kind, i.form, i.state,
        CASE WHEN i.state = 'landed' OR i.applied_upstream IS NOT NULL THEN 'landed'
             WHEN i.state = 'accepted' THEN 'accepted'
             WHEN i.state IN ('sent', 'under-review', 'changes-requested') THEN 'in review'
             WHEN i.state IN ('rejected', 'withdrawn', 'not-needed', 'superseded') THEN 'closed'
             ELSE 'carried' END AS stage,
        CASE WHEN i.state = 'landed' OR i.applied_upstream IS NOT NULL THEN 'UPSTREAM'
             WHEN i.state = 'accepted' THEN 'FROMGIT'
             WHEN i.state IN ('sent', 'under-review', 'changes-requested') THEN 'FROMLIST'
             ELSE 'OURS' END AS tag,
        i.carried_in, i.version, i.reviewed_by,
        CASE WHEN i.sent_on IS NOT NULL THEN date_diff('day', CAST(i.sent_on AS DATE), current_date) END AS days_since_sent,
        coalesce(i.forwarded, i.bug, i.applied_upstream) AS link,
        coalesce(i.waits, i.note) AS why, i.last_update, i.title
    FROM upstream_items i LEFT JOIN upstreams u ON u.id = i.upstream
    WHERE ($upstream IS NULL OR i.upstream = $upstream)
      AND ($about IS NULL OR i.about = $about OR i.about LIKE $about || '-%'))
SELECT id, upstream, target_kind, form, state, stage, tag, carried_in, version, reviewed_by, days_since_sent, link, why, title
FROM x
ORDER BY CASE stage WHEN 'in review' THEN 0 WHEN 'accepted' THEN 1 WHEN 'carried' THEN 2 WHEN 'landed' THEN 3 ELSE 4 END, upstream, id;
