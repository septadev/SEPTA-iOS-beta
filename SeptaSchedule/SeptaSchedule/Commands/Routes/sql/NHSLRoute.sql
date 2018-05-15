
-- NHSL Route.  Returns 1 record

-- NHSL	NHSL	Norristown TC to 69th St TC	0


select
  route_id, route_short_name, route_long_name, route_type
from routes_bus
where route_id = 'NHSL';



