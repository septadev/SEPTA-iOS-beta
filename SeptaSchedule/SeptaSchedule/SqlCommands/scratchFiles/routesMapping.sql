SELECT cast(route_id AS TEXT) routeId, route_type
FROM routes_bus
WHERE route_type = 0

AND route_id NOT IN ('NHSL')

order by cast(route_id AS TEXT);

select * from routes_bus where route_type = 3 order by route_id;

select * from routes_bus where route_id = 'BSO';