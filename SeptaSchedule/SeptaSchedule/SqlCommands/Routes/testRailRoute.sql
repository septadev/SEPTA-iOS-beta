


-- Rail Routes

-- AIR	Airport Line	Airport Line	2
-- CHE	Chestnut Hill East Line	Chestnut Hill East Line	2
-- CHW	Chestnut Hill West Line	Chestnut Hill West Line	2
-- LAN	Lansdale/Doylestown Line	Lansdale/Doylestown Line	2


select
  route_id, route_short_name, route_long_name, route_type, 0 dircode
from routes_rail;