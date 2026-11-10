#!/bin/sh
# File a results file from tests/run.sh into linux-phone-oco/docs as data: the test_results table
# (made the first time), one row per check, the evidence the support grid's verdicts can cite.
#   tests/to-docs.sh RESULTS.jsonl [DOCS_DIR]      DOCS_DIR: ~/Projects/linux-phone-oco/docs
# Uses the docs' own tool (its .tad, its DuckDB); commit and PR are left to the caller.
set -eu
R=$(cd "$(dirname "$1")" && pwd)/$(basename "$1"); DOCS=${2:-$HOME/Projects/linux-phone-oco/docs}
cd "$DOCS"
python3 .tad/tools/dc.py sql "
CREATE TABLE IF NOT EXISTS test_results(id VARCHAR PRIMARY KEY, run VARCHAR NOT NULL, device_id VARCHAR NOT NULL,
  component_id VARCHAR NOT NULL, test VARCHAR NOT NULL, outcome VARCHAR NOT NULL, detail VARCHAR, run_at TIMESTAMP NOT NULL,
  kernel VARCHAR, shell VARCHAR, CHECK(outcome IN ('pass', 'fail', 'skip')));
INSERT OR REPLACE INTO test_results
  SELECT run || '-' || component || '-' || test, run, device, component, test, outcome, detail, CAST(j.at AS TIMESTAMP), kernel, shell
  FROM read_json_auto('$R', format = 'newline_delimited') AS j;" >/dev/null
echo "filed $(wc -l < "$R") results into $DOCS/data"
