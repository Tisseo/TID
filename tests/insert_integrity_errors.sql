-- wrong datasource
SELECT insertline('line1', 3, '1', 999, 3);
-- nonexistent physical_mode
SELECT insertline('line1', 999, '1', 2, 3);