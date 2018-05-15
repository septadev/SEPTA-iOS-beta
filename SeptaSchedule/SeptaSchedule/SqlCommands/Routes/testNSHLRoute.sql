

-- Norristown High Speed Line
--
-- Will return one row
--
-- NHSL	NHSL	Norristown TC to 69th St TC	0
--


select *
from routes_bus
where route_type = 0;


select * from routes_bus where route_id in ('BSO') and route_type = route_type


parameterizedSqlString	String	"\n\n--BusRoute\n\n\n-- 1    to Parx Casino    Parx Casino to 54th-City    0\n-- 1    to 54th-City    Parx Casino to 54th-City    1\n-- 2    to 20th-Johnston    20-Johnston to Pulaski-Hntg Park    0\n-- 2    to Pulaski-Hunting Park    20-Johnston to Pulaski-Hntg Park    1\n-- 3    to 33rd-Cecil B. Moore    33rd-Cecil B. Moore to FTC    0\n\n\n\nSELECT\n  cast(R.route_id AS TEXT) route_id,\n  \'to \' || BSD.DirectionDescription route_short_name,\n  R.route_long_name,\n  BSD.dircode\nFROM bus_stop_directions BSD\nJOIN routes_bus R\nON BSD.Route = R.route_id\nWHERE route_type  = 3\nand route_id  = route_id\n\n\n"