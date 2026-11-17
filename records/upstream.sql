-- A place knowledge can flow to - a project, a list, a tracker, a wiki, a standard, a person or team, another
-- knowledge base's instance (an upstream of that id is replaced). Record it once; upstream-item heads work to it.
-- --id        string        a-short-name
-- --kind      string        code-project, list, tracker, wiki, standard, person-team, kb-instance or distro
-- --name      string        what it is called
-- --address   string        its URL, list address or contact
-- --how       string        how contributions are made there (git send-email to the list; a merge request; a comment on the page; ask the maintainer)
-- --contacts  string?       maintainers or contacts
-- --notes     string?       what else a sender needs: rules, habits, where its rules are written
DELETE FROM upstreams WHERE id = $id;
INSERT INTO upstreams (id, kind, name, address, how, contacts, notes)
VALUES ($id, $kind, $name, $address, $how, $contacts, $notes);
