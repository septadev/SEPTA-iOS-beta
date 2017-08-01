
-- sql for the the user is selecting the starting point of a bus route
-- take two parameters: route_id and service_id

SELECT
  S.stop_id, S.Stop_name
FROM stops_bus S
WHERE S.stop_id IN (
  SELECT ST.stop_id
  FROM trips_bus T
    JOIN stop_times_bus ST
      ON T.trip_id = ST.trip_id WHERE
    T.route_id == :route_id AND T.service_id = :service_id)
ORDER BY S.stop_name;
