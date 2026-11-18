-- Everything known of one subject, the short answer first: how it stands (its summary, dated), then what was
-- recorded since - each record by its brief, its one line - the work open and the sources, and the records the
-- summary condenses by id only. --whole gives every record in full; row --id one. Read deeper only when the
-- task needs it. Research or a decision a later one supersedes leaves the answer; find and row reach it.
-- A word before a dash names a family (modem: modem-data, modem-calls). Without a subject: every subject,
-- with how many records it has, what they weigh, its summary's date and whether a summary is due - when
-- they weigh over 8 KB with none, or over 4 KB were recorded since it (open work is never condensed).
-- --subject  string?          the subject (every subject when not given)
-- --whole    boolean = false  every record in full, the condensed ones too
WITH s AS (SELECT $subject AS w, $whole AS whole),
-- a record's brief is its one line; where none was written, the first sentence of what it says
rec AS (
    SELECT 'research' AS kind, id, about, date AS day, question || ' - ' || found || coalesce(' Material: ' || material, '') AS says,
           coalesce(brief, CASE WHEN strpos(found, '. ') > 0 THEN left(found, strpos(found, '. ')) ELSE found END) AS brief
      FROM research WHERE id NOT IN (SELECT supersedes FROM research WHERE supersedes IS NOT NULL)
    UNION ALL SELECT 'decision', id, about, date, decision || coalesce(' Rejected: ' || rejected, ''),
           coalesce(brief, CASE WHEN strpos(decision, '. ') > 0 THEN left(decision, strpos(decision, '. ')) ELSE decision END) FROM decisions
      WHERE id NOT IN (SELECT supersedes FROM decisions WHERE supersedes IS NOT NULL)
    UNION ALL SELECT 'log', id, about, entry_date, title || ' - ' || done, title FROM session_log
),
hit AS (SELECT a FROM (SELECT about AS a FROM rec UNION SELECT about FROM backlog UNION SELECT about FROM summaries), s
        WHERE a IS NOT NULL AND (a = s.w OR a LIKE s.w || '-%')),
sm AS (SELECT * FROM summaries WHERE about IN (SELECT a FROM hit)),
cond AS (SELECT about, trim(unnest(string_split(condenses, ','))) AS id FROM sm),
shown AS (SELECT r.* FROM rec r, s WHERE r.about IN (SELECT a FROM hit)
          AND (s.whole OR NOT EXISTS (SELECT 1 FROM cond c WHERE c.id = r.id AND c.about = r.about))),
known AS (
    SELECT 0 AS o, 'summary' AS kind, about AS id, about, 'condenses ' || (length(condenses) - length(replace(condenses, ',', '')) + 1)::VARCHAR AS state,
           date AS day, says FROM sm
    UNION ALL SELECT CASE kind WHEN 'research' THEN 1 WHEN 'decision' THEN 2 ELSE 4 END, kind, id, about, NULL, day,
           CASE WHEN s.whole THEN says ELSE brief END FROM shown, s
    UNION ALL SELECT 3, 'work', id, about, status, opened,
           CASE WHEN s.whole THEN title || coalesce(' - ' || note, '') || coalesce(' Waits: ' || waits, '') ELSE title || coalesce(' Waits: ' || waits, '') END
      FROM backlog, s WHERE status <> 'done' AND (about IN (SELECT a FROM hit) OR id IN (SELECT a FROM hit))
    UNION ALL SELECT DISTINCT 5, 'source', id, NULL, NULL, NULL, title || ' <' || url || '>'
      FROM sources WHERE id IN (SELECT trim(unnest(string_split(r.sources, ','))) FROM research r WHERE r.id IN (SELECT id FROM shown))
    UNION ALL SELECT 6, 'condensed', c.about, c.about, count(*)::VARCHAR, NULL, string_agg(c.id, ', ' ORDER BY c.id)
      FROM cond c, s WHERE NOT s.whole AND c.id IN (SELECT id FROM rec) GROUP BY c.about
),
cond_all AS (SELECT about, trim(unnest(string_split(condenses, ','))) AS id FROM summaries),
subjects AS (
    SELECT r.about AS a, count(*) AS n, sum(length(r.says)) AS weight,
           sum(CASE WHEN c.id IS NULL AND r.kind <> 'work' THEN length(r.says) ELSE 0 END) AS since
      FROM (SELECT kind, id, about, says FROM rec
            UNION ALL SELECT 'work', id, about, title || coalesce(' - ' || note, '') FROM backlog WHERE status <> 'done') r
      LEFT JOIN cond_all c ON c.id = r.id AND c.about = r.about
     WHERE r.about IS NOT NULL GROUP BY r.about
)
SELECT kind, id, about, state, day, says FROM (
SELECT o, kind, id, about, state, day, says FROM known, s WHERE s.w IS NOT NULL
UNION ALL
SELECT 7, 'subject', x.a, NULL,
       CASE WHEN m.about IS NULL AND x.weight > 8000 THEN 'summary due'
            WHEN m.about IS NOT NULL AND x.since > 4000 THEN 'summary due'
            WHEN m.about IS NOT NULL THEN 'summarised' END,
       m.date,
       x.n::VARCHAR || ' records, ' || round(x.weight / 1000.0, 1)::VARCHAR || ' KB'
         || CASE WHEN m.about IS NOT NULL THEN ', ' || round(x.since / 1000.0, 1)::VARCHAR || ' KB since its summary' ELSE '' END
  FROM subjects x LEFT JOIN summaries m ON m.about = x.a, s WHERE s.w IS NULL
) ORDER BY o, day DESC NULLS LAST, id;
