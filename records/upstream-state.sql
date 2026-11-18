-- Where an upstream item stands now: its state, and what is known since (what is not given is kept as it was).
-- --id                string        the item
-- --state             string        draft, ready, sent, under-review, changes-requested, accepted, landed, held, rejected, superseded, not-needed or withdrawn
-- --note              string?       where it stands, and the next step
-- --waits             string?       what it waits on
-- --forwarded         string?       its address there (a link, a message id)
-- --sent-on           date?         when it was sent
-- --applied-upstream  string?       the version, commit or link where it landed
-- --bug               string?       the upstream report or thread
-- --carried-in        string?       the fork and branch that carries it; none when it is no longer carried (the upstream has it, or it was dropped)
-- --reviewed-by       string?       who reviewed or acked it, as the replies name them (added to those kept)
-- --last-update       date = today  when
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM upstream_items WHERE id = $id) THEN error('no upstream item ' || $id || ' (tad q upstream lists them)') ELSE true END;
UPDATE upstream_items SET state = $state, note = coalesce($note, note), waits = coalesce($waits, waits),
  forwarded = coalesce($forwarded, forwarded), sent_on = coalesce($sent_on, sent_on),
  applied_upstream = coalesce($applied_upstream, applied_upstream), bug = coalesce($bug, bug),
  carried_in = CASE WHEN $carried_in = 'none' THEN NULL ELSE coalesce($carried_in, carried_in) END,
  reviewed_by = CASE WHEN $reviewed_by IS NULL THEN reviewed_by WHEN reviewed_by IS NULL THEN $reviewed_by ELSE reviewed_by || '; ' || $reviewed_by END,
  last_update = $last_update
WHERE id = $id;
