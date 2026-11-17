-- The device this base is about: one row (a device of that id is replaced). docs' registry holds the same row.
-- --id        string   vendor-codename: xiaomi-surya, google-walleye
-- --name      string   what it is called
-- --codename  string   the codename
-- --soc       string   its system on a chip
-- --notes     string?  what is known of the device as a whole
DELETE FROM devices WHERE id = $id;
INSERT INTO devices (id, name, codename, soc, notes) VALUES ($id, $name, $codename, $soc, $notes);
