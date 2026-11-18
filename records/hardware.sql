-- A piece of hardware the work needs - a cable, an adapter, a breakout, a meter, a setup made of them (a
-- hardware of that id is replaced): what it is, whether this lab wants, has or lacks it, and whether it is CONFIRMED to
-- work on the machine or only claimed (a retailer's page, a blog). Facts go stale: give the day a price was quoted
-- and the day the sources were read.
-- --id          string        a-short-name
-- --kind        string        cable, adapter, breakout, meter, tool, part or setup
-- --name        string        what it is called, with the chip or conductors that tell variants apart
-- --status      string = wanted  wanted, ordered, owned, lent, broken or retired (general: the docs catalogue only)
-- --fit         string?       claimed, confirmed or refuted - on THIS machine; confirmed needs --fit-ref
-- --fit-ref     string?       the evidence of the fit: a run id, a log, a link
-- --spec        string?       one line: chip, logic level, connector
-- --wiring      string?       pins, voltage, baud, orientation, the commands on the phone - what this phone needs
-- --serves      string?       the phones or parts it serves, where known
-- --about       string?       the part of the phone or the work item it serves (tad q about lists them)
-- --general     string?       the docs catalogue entry this is an instance of (docs:ID)
-- --qty         integer?      how many the lab has
-- --price       string?       as quoted, with its currency; needs --price-on
-- --price-on    date?         the day the price was quoted
-- --sources     string?       ids of this base's sources, comma-separated (tad r source records each)
-- --file        string?       its folder, hardware/ID/ (notes, photos)
-- --note        string?       what else is known
-- --checked-on  date = today  the day its facts were last checked
SELECT CASE WHEN $fit = 'confirmed' AND $fit_ref IS NULL THEN error('a fit is confirmed by evidence: give --fit-ref (a run id, a log, a link); until then it is claimed') END;
SELECT CASE WHEN $sources IS NOT NULL AND EXISTS (SELECT 1 FROM unnest(string_split($sources, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM sources))
    THEN error('sources names no source of this base: ' || (SELECT string_agg(trim(t.x), ', ') FROM unnest(string_split($sources, ',')) AS t(x) WHERE trim(t.x) NOT IN (SELECT id FROM sources)) || ' (tad r source records one)') END;
DELETE FROM hardware WHERE id = $id;
INSERT INTO hardware (id, kind, name, status, fit, fit_ref, spec, wiring, serves, about, general, qty, price, price_on, sources, file, note, checked_on)
VALUES ($id, $kind, $name, $status, $fit, $fit_ref, $spec, $wiring, $serves, $about, $general, $qty, $price, $price_on, $sources, $file, $note, $checked_on);
