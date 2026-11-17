-- How the device stands, part by part: what is claimed, the evidence and when - what docs pulls. A part not
-- listed is not known yet.
-- --status  string?  only the parts with this status
SELECT component, status, coalesce(evidence, '') AS evidence, updated, coalesce(notes, '') AS notes
FROM parts WHERE $status IS NULL OR status = $status ORDER BY component;
