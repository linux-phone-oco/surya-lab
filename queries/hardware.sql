-- The hardware the work needs: what it is, whether the lab has it (status), whether it works on the machine
-- (fit: claimed is only a claim), its price and when that was quoted, and how many days ago its facts were checked -
-- the longest-unchecked first within what is not owned yet. Then row --id ID for one whole.
-- --status  string?  only this status (wanted, ordered, owned, lent, broken, retired)
-- --kind    string?  only this kind (cable, adapter, breakout, meter, tool, part, setup)
-- --about   string?  only what serves this part or item
SELECT id, kind, name, status, coalesce(fit, '') AS fit, coalesce(price, '') AS price, price_on,
       (current_date - checked_on) AS checked_days_ago, coalesce(serves, '') AS serves, coalesce(note, '') AS note
FROM hardware
WHERE ($status IS NULL OR status = $status) AND ($kind IS NULL OR kind = $kind) AND ($about IS NULL OR about = $about)
ORDER BY status = 'owned', checked_on, id;
