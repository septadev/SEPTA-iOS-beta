-- to get all the bus routes, route type must be 3
-- when route_type = 3
-- should return 127 rows including: 108    108    UPS or Airport to 69th St TC

-- route_type = 3 for buses


SELECT route_id, route_short_name, route_long_name
FROM routes_bus WHERE route_type = 3;
