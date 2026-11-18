-- A decision, with what was rejected and why (a decision of that id is replaced). One that replaces an older
-- decision whole says --supersedes: the old stays, reachable, and leaves about and decided; one that changes
-- it in part says --amends: the old stays in force. Neither is edited in place.
-- --id          string        YYYY-MM-DD-what-was-decided
-- --brief       string        the decision in one line, at most 200 characters: what answers show
-- --decision    string        what was decided
-- --why         string        why: the evidence, whose words
-- --rejected    string?       what was weighed and not chosen, and why not
-- --about       string?       what it is about (tad q about lists the subjects)
-- --research    string?       the research it rests on (its id)
-- --supersedes  string?       the decision it replaces whole (its id)
-- --amends      string?       the decision it changes in part (its id)
-- --scope       string?       who it binds or touches: bases, roles, tools, people
-- --tracked-by  string?       the backlog item that carries it out (its id; tad q decided reads where it stands)
-- --date        date = today  when
DELETE FROM decisions WHERE id = $id;
INSERT INTO decisions (id, date, brief, decision, why, rejected, about, research, supersedes, amends, scope, tracked_by)
SELECT $id, $date, $brief, $decision, $why, $rejected, $about, $research, $supersedes, $amends, $scope, $tracked_by
WHERE CASE WHEN length($brief) > 200 THEN error('the brief is ' || length($brief) || ' characters; at most 200') ELSE true END
  AND CASE WHEN $supersedes IS NOT NULL AND ($supersedes = $id OR NOT EXISTS (SELECT 1 FROM decisions WHERE id = $supersedes))
      THEN error('supersedes ' || $supersedes || ' is no other decision of this base (tad q find --text finds one)') ELSE true END
  AND CASE WHEN $amends IS NOT NULL AND ($amends = $id OR NOT EXISTS (SELECT 1 FROM decisions WHERE id = $amends))
      THEN error('amends ' || $amends || ' is no other decision of this base (tad q find --text finds one)') ELSE true END
  AND CASE WHEN $tracked_by IS NOT NULL AND NOT EXISTS (SELECT 1 FROM backlog WHERE id = $tracked_by)
      THEN error('tracked-by ' || $tracked_by || ' is no backlog item of this base (tad q next lists them)') ELSE true END;
