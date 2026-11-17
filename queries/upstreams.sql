-- The places knowledge can flow to: what each is, its address and how contributions are made there, with how
-- many items are headed to it and how many are still open.
SELECT u.id, u.kind, u.name, u.address, u.how, u.contacts,
  count(i.id) AS items, count(i.id) FILTER (WHERE i.state NOT IN ('landed', 'rejected', 'superseded', 'not-needed', 'withdrawn')) AS open
FROM upstreams u LEFT JOIN upstream_items i ON i.upstream = u.id
GROUP BY ALL ORDER BY u.id;
