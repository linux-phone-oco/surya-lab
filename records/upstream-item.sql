-- Something headed to an upstream: a patch, information, a correction, a question or a finding, linked to the
-- work here it comes from (an item of that id is replaced). A patch or a long message is a file: --file auto
-- makes upstream/UPSTREAM/ID/ to put it in. Move it on with upstream-state.
-- --id                string        a-short-name (made from the title when not given)
-- --upstream          string        where it goes (an upstreams id; the upstream record makes one)
-- --title             string        what it is, in one line
-- --form              string        patch, information, correction, question or finding
-- --from-work         string        the work here it comes from: a backlog item, decision or research id
-- --state             string = draft  draft, ready (the person said it may go), sent, under-review, changes-requested, accepted, landed, held, rejected, superseded, not-needed or withdrawn
-- --domain            string?       the field of work it belongs to
-- --tags              string?       facet tags, comma-separated
-- --about             string?       what it is about (tad q about lists the subjects)
-- --local-ref         string?       the branch, pull request or commit here it is made in
-- --file              string?       its folder or file, under upstream/ (auto makes upstream/UPSTREAM/ID/): the series, cover letter and send notes live there, not in research/
-- --sent-on           date?         when it was sent
-- --forwarded         string?       where it stands there: its address (a link, a message id), or not-needed
-- --bug               string?       the upstream report or thread it answers or opened
-- --version           string?       v2, v3 ... when sent again
-- --supersedes        string?       the item it is a later version of
-- --applied-upstream  string?       the version, commit or link where it landed
-- --carried-in        string?       the fork and branch that carries it until the upstream has it (an upstreams id of the fork, then a branch)
-- --reviewed-by       string?       who reviewed or acked it, as the replies name them
-- --waits             string?       what it waits on (a person's word, a reply)
-- --note              string?       where it stands, and the next step
-- --last-update       date = today  when
SELECT CASE WHEN $file IS NOT NULL AND $file NOT LIKE 'upstream/%' THEN error('--file ' || $file || ' is not under upstream/: an outgoing series, its cover letter and send notes go in upstream/DESTINATION/ITEM/ (--file auto); research keeps only the material behind it') END;
DELETE FROM upstream_items WHERE id = $id;
INSERT INTO upstream_items (id, upstream, title, form, state, from_work, domain, tags, about, local_ref, file, sent_on, forwarded, bug, version, supersedes, applied_upstream, waits, note, last_update, carried_in, reviewed_by)
SELECT $id, $upstream, $title, $form, $state, $from_work, $domain, $tags, $about, $local_ref, $file, $sent_on, $forwarded, $bug, $version, $supersedes, $applied_upstream, $waits, $note, $last_update, $carried_in, $reviewed_by
WHERE CASE WHEN NOT EXISTS (SELECT 1 FROM backlog WHERE id = $from_work) AND NOT EXISTS (SELECT 1 FROM decisions WHERE id = $from_work) AND NOT EXISTS (SELECT 1 FROM research WHERE id = $from_work)
      THEN error('from-work ' || $from_work || ' is no backlog item, decision or research of this base (tad q find --text finds one)') ELSE true END;
