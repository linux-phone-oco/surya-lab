-- What changed about a piece of hardware: it arrived (status), it was tried on this phone (fit, with the evidence), how
-- many there are, a note; what is not given is kept as it was, and the day it was checked is today.
-- --id       string   the hardware
-- --status   string?  wanted, ordered, owned, lent, broken or retired
-- --fit      string?  claimed, confirmed or refuted on this phone; confirmed needs evidence (--fit-ref, or one already there)
-- --fit-ref  string?  the evidence: a run id, a log, a link
-- --qty      integer?  how many the lab has
-- --note     string?  what else is known (replaces the note)
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM hardware WHERE id = $id) THEN error('no hardware ' || $id || ' (tad q hardware lists them)') END;
SELECT CASE WHEN $status IS NULL AND $fit IS NULL AND $fit_ref IS NULL AND $qty IS NULL AND $note IS NULL THEN error('nothing to change: give --status, --fit, --fit-ref, --qty or --note') END;
SELECT CASE WHEN $fit = 'confirmed' AND $fit_ref IS NULL AND (SELECT fit_ref FROM hardware WHERE id = $id) IS NULL
    THEN error('a fit is confirmed by evidence: give --fit-ref (a run id, a log, a link); until then it is claimed') END;
UPDATE hardware SET status = coalesce($status, status), fit = coalesce($fit, fit), fit_ref = coalesce($fit_ref, fit_ref),
    qty = coalesce($qty, qty), note = coalesce($note, note), checked_on = current_date
WHERE id = $id;
