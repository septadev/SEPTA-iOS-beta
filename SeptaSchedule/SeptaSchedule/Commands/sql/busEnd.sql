-- once a route and service type are selected
-- and once the user can pick a start busstop
-- we are in a position to find all ending busstops that are on that same route.


SELECT
  S.stop_id, S.Stop_name
FROM stops_bus S
  JOIN stop_times_bus ST
    ON S.stop_id = ST.stop_id
WHERE S.stop_id <> 30 AND ST.trip_id IN (

  SELECT ST.trip_id
  FROM stop_times_bus ST
    JOIN trips_bus T
      ON ST.trip_id = T.trip_id
  WHERE ST.stop_id = 30 AND T.route_id == 2 AND T.service_id = 2)
      AND ST.trip_id <> 30
GROUP BY S.stop_id, S.Stop_name
ORDER BY S.stop_id, S.Stop_name;
