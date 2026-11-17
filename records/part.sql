-- What is claimed of one part of this device, and the evidence (a part of that name is replaced). docs pulls
-- these and derives the device's support status; a part never declared is not known yet, never broken.
-- --component     string        the part: audio-mic, modem-data, charging ... (a name docs' components use)
-- --status        string        works, partial, broken, unknown or not-applicable
-- --evidence      string?       the run or link that shows it (a test_runs id, a commit, a page)
-- --notes         string?       what is known, in a line or two
-- --judged        string?       what a person judged, when it differs from what a run measured
-- --measured      string?       what the health suite measured: pass, fail or skip
-- --measured-run  string?       the test_runs id of that measurement
-- --updated       date = today  when
DELETE FROM parts WHERE component = $component;
INSERT INTO parts (component, status, evidence, notes, updated, judged, measured, measured_run)
VALUES ($component, $status, $evidence, $notes, $updated, $judged, $measured, $measured_run);
