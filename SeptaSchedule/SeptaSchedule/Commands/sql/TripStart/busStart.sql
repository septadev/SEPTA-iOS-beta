
-- search for all bus stops that run on Saturday on Route 44

-- returns 122 rows

-- including 20589    54th St & City Av

SELECT
  S.stop_id, S.Stop_name, S.stop_lat, S.stop_lon, s.wheelchair_boarding
FROM stops_bus S
WHERE S.stop_id IN (
  SELECT ST.stop_id
  FROM trips_bus T
    JOIN stop_times_bus ST
      ON T.trip_id = ST.trip_id WHERE
    T.route_id == :route_id AND T.service_id = :service_id)
ORDER BY S.stop_name;

