

-- these are trolly routes
--
-- BSL	BSL	ATT Station to Fern Rock TC	1
-- MFL	MFL	Frankford TC to 69th St TC	1


SELECT route_id, route_short_name, route_long_name, route_type
FROM routes_bus WHERE route_type = 1;