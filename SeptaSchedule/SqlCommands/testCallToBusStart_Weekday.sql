

-- search for all bus stops that run on weekdays on Route 44

-- returns 184 rows

-- including 21893	Essex Av & Woodbine Av


SELECT
  S.stop_id, S.Stop_name, S.stop_lat, S.stop_lon, s.wheelchair_boarding
FROM stops_bus S
WHERE S.stop_id IN (
  SELECT ST.stop_id
  FROM trips_bus T
    JOIN stop_times_bus ST
      ON T.trip_id = ST.trip_id WHERE
    T.route_id == 44 AND T.service_id = 1)
ORDER BY S.stop_name;