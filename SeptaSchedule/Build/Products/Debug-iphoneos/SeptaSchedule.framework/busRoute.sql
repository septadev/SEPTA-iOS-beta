

--BusRoute


-- 1    to Parx Casino    Parx Casino to 54th-City    0
-- 1    to 54th-City    Parx Casino to 54th-City    1
-- 2    to 20th-Johnston    20-Johnston to Pulaski-Hntg Park    0
-- 2    to Pulaski-Hunting Park    20-Johnston to Pulaski-Hntg Park    1
-- 3    to 33rd-Cecil B. Moore    33rd-Cecil B. Moore to FTC    0



SELECT
  cast(R.route_id AS TEXT) route_id,
  'to ' || BSD.DirectionDescription route_short_name,
  R.route_long_name,
  BSD.dircode
FROM bus_stop_directions BSD
JOIN routes_bus R
ON BSD.Route = R.route_id
WHERE :route_type
and :route_id


