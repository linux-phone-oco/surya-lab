-- One run of a phone's health suite, filed: every line of its report a test_results row, and the run's
-- test_runs row counted from them - a failure in one of the phone's known gaps (its manifest's [health]
-- gaps: parts it never had working) counted apart from the failures, as the phone's own verdict counts
-- it. devlab files each report it gathers with this record; tad keeps it only if every rule holds.
-- --run     string  the run, as the phone names its report: YYYYMMDD-HHMMSS
-- --report  string  the report: a file of one JSON object per test
-- --gaps    list?   the phone's known gaps, comma-separated components
INSERT INTO test_results
SELECT $run || '-' || component || '-' || test, $run, device, component, test,
       outcome, detail, CAST("at" AS TIMESTAMP), kernel, shell
FROM read_json_auto($report, format = 'newline_delimited');
INSERT INTO test_runs (id, device_id, run_at, kernel, shell, passed, failed, gaps, skipped)
SELECT run, any_value(device_id), min(run_at), any_value(kernel), any_value(shell),
       count_if(outcome = 'pass'),
       count_if(outcome = 'fail' AND NOT list_contains(coalesce($gaps, []::VARCHAR[]), component_id)),
       count_if(outcome = 'fail' AND list_contains(coalesce($gaps, []::VARCHAR[]), component_id)),
       count_if(outcome = 'skip')
FROM test_results WHERE run = $run GROUP BY run;
