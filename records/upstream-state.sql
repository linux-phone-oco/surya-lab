-- Where an upstream item stands now: its state, and what is known since (what is not given is kept as it was).
-- --id                string        the item
-- --state             string        draft, ready, sent, under-review, changes-requested, accepted, landed, held, rejected, superseded, not-needed or withdrawn
-- --note              string?       where it stands, and the next step
-- --waits             string?       what it waits on
-- --forwarded         string?       its address there (a link, a message id)
-- --sent-on           date?         when it was sent
-- --applied-upstream  string?       the version, commit or link where it landed
-- --bug               string?       the upstream report or thread
-- --last-update       date = today  when
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM upstream_items WHERE id = $id) THEN error('no upstream item ' || $id || ' (tad q upstream lists them)') ELSE true END;
UPDATE upstream_items SET state = $state, note = coalesce($note, note), waits = coalesce($waits, waits),
  forwarded = coalesce($forwarded, forwarded), sent_on = coalesce($sent_on, sent_on),
  applied_upstream = coalesce($applied_upstream, applied_upstream), bug = coalesce($bug, bug), last_update = $last_update
WHERE id = $id;
