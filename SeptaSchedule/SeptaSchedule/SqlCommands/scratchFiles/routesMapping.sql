SELECT cast(route_id AS TEXT) route_id
FROM routes_bus
WHERE route_type = 3 AND route_id NOT IN ('BSO', 'BSL', 'MFL') order by cast(route_id AS TEXT);