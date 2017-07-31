SELECT
S.stop_id, S.Stop_name
FROM stops_bus S
WHERE S.stop_id IN (
SELECT ST.stop_id
FROM trips_bus T
JOIN stop_times_bus ST
ON T.trip_id = ST.trip_id WHERE
T.route_id == 44 AND T.service_id = 2)
ORDER BY S.stop_name;

