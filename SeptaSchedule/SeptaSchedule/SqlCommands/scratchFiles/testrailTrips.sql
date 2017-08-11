
select
  route_id, route_short_name, route_long_name, route_type
from (
select
  route_id, route_short_name, route_long_name, route_type
from routes_bus
union all
select
  route_id, route_short_name, route_long_name, route_type
from routes_rail)

where route_id = 'NHSL';


