-- What this device's base claims of one bring-up step (a step of that id is replaced). The steps are docs' (tad q
-- bringup-chain names them, generic for every machine); this base says where this device stands on each, with the
-- check that proved it and where it ran. docs pulls these (data/steps.json) into step_status; a step never claimed
-- is unknown, "not known yet", never failing. A claim of done carries its proof and its run: without them it is a
-- claim, say partial or open; not-needed carries why (the class the step does not apply to).
-- --step       string        the step (a bringup_steps id of docs: shell-on-console, kernel-reaches-init ...)
-- --status     string        done, partial, failing, open, not-needed or unknown
-- --proof      string?       the check that proved it here: a tests id, or this base's own script
-- --run        string?       where the proof ran: a test_runs id, a record of this base, a research row, a pull request
-- --proven-on  string?       what it was proven on: the image, kernel or dtb hash, so a later change can be told from it
-- --notes      string?       what is known, in a line or two
-- --updated    date = today  when
DELETE FROM steps WHERE step = $step;
-- the evidence rules sit in the inserted values so a refusal says why and a success prints nothing
INSERT INTO steps (step, status, proof, run, proven_on, notes, updated)
VALUES ($step, $status,
    CASE WHEN $status = 'done' AND (nullif(trim($proof), '') IS NULL OR nullif(trim($run), '') IS NULL)
         THEN error('a done step carries its proof and its run (--proof, --run); without them say partial or open') ELSE $proof END,
    $run, $proven_on,
    CASE WHEN $status = 'not-needed' AND nullif(trim($notes), '') IS NULL THEN error('a not-needed step says why (--notes)') ELSE $notes END,
    $updated);
