
SELECT
  S.stop_id, s.stop_name,
  s.stop_lat,
  s.stop_lon,
  s.wheelchair_boarding,
  T.direction_id,
  BSD.Direction

FROM trips_bus T
JOIN stop_times_bus ST
ON T.trip_id = ST.trip_id
JOIN stops_bus S
ON ST.stop_id = S.stop_id
JOIN bus_stop_directions BSD
ON T.route_id = BSD.Route AND T.direction_id = BSD.dircode
WHERE T.route_id = :route_id
GROUP BY S.stop_id, s.stop_name, s.stop_lat, s.stop_lon, s.wheelchair_boarding, T.direction_id, BSD.Direction;
