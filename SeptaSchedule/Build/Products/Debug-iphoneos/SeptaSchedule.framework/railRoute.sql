
-- Rail Routes

-- AIR    Airport Line    Airport Line    0
-- CHE    Chestnut Hill East Line    Chestnut Hill East Line    0
-- CHW    Chestnut Hill West Line    Chestnut Hill West Line    0
-- LAN    Lansdale/Doylestown Line    Lansdale/Doylestown Line    0
-- MED    Media/Elwyn Line    Media/Elwyn Line    0
-- FOX    Fox Chase Line    Fox Chase Line    0


select
  cast(route_id AS TEXT) route_id, route_short_name, route_long_name, '0' dircode
from routes_rail;

