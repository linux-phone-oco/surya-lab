-- A place knowledge can flow to - a project, a list, a tracker, a wiki, a standard, a person or team, another
-- knowledge base's instance (an upstream of that id is replaced). Record it once; upstream-item heads work to it.
-- --id        string        a-short-name
-- --kind      string        code-project, list, tracker, wiki, standard, person-team, kb-instance or distro
-- --name      string        what it is called
-- --address   string        its URL, list address or contact
-- --how       string        how contributions are made there (git send-email to the list; a merge request; a comment on the page; ask the maintainer)
-- --contacts  string?       maintainers or contacts
-- --notes     string?       what else a sender needs: rules, habits, where its rules are written
-- --fork-of   string?       the upstream this one is a fork of (an upstreams id): its patches are carried here until it takes them
DELETE FROM upstreams WHERE id = $id;
INSERT INTO upstreams (id, kind, name, address, how, contacts, notes, fork_of)
SELECT $id, $kind, $name, $address, $how, $contacts, $notes, $fork_of
WHERE CASE WHEN $fork_of IS NOT NULL AND NOT EXISTS (SELECT 1 FROM upstreams WHERE id = $fork_of)
      THEN error('fork-of ' || $fork_of || ' is no upstream (tad q upstreams lists them; the upstream record makes one)') ELSE true END;
