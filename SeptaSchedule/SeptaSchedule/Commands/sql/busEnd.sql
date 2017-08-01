-- once a route and service type are selected
-- and once the user can pick a start busstop
-- we are in a position to find all ending busstops that are on that same route
-- excluding the original stop that was selected


SELECT
  S.stop_id, S.Stop_name
FROM stops_bus S
  JOIN stop_times_bus ST
    ON S.stop_id = ST.stop_id
WHERE
  -- don't include the original stop id
  S.stop_id <> :start_stop_id
  -- make sure the selected stop ids have trips that match what the user originaly selected
  AND ST.trip_id IN (
    -- get all the trips that hit :start_stop_id
    SELECT ST.trip_id
    FROM stop_times_bus ST
      JOIN trips_bus T
        ON ST.trip_id = T.trip_id
    WHERE ST.stop_id = :start_stop_id AND T.route_id == :route_id AND T.service_id = :service_id)
-- group and sort them
GROUP BY S.stop_id, S.Stop_name
ORDER BY S.stop_id, S.Stop_name;
