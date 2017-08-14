-- to get bus routes

-- this is the way I want to sell routes
SELECT
  route_id, route_short_name, route_long_name, route_type
FROM routes_bus R
WHERE route_type = 3;

-- 33	33	Penns Landing to 23rd-Venango	3


SELECT
  S.stop_id, s.stop_name || ' - ' || BSD.Direction stopName,
  s.stop_lat,
  s.stop_lon,
  s.wheelchair_boarding,
  T.direction_id

FROM trips_bus T
JOIN stop_times_bus ST
ON T.trip_id = ST.trip_id
JOIN stops_bus S
ON ST.stop_id = S.stop_id
JOIN bus_stop_directions BSD
ON T.route_id = BSD.Route AND T.direction_id = BSD.dircode
WHERE T.route_id = 33
GROUP BY S.stop_id, s.stop_name, s.stop_lat, s.stop_lon, s.wheelchair_boarding, T.direction_id;

SELECT
  S.stop_id,
  s.stop_name,
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
WHERE T.route_id = 33
GROUP BY S.stop_id, s.stop_name, s.stop_lat, s.stop_lon, s.wheelchair_boarding, T.direction_id, BSD.Direction;

-- now I choose stop 13905 as my starting location
-- 13905	23rd St & Venango St Loop - Southbound	40.009811	-75.166068	0	0


SELECT
  S.stop_id, S.stop_name, S.stop_lat, S.stop_lon,
  MAX(CASE WHEN T.service_id = '1'
    THEN 'true' END) AS Weekday,
  MAX(CASE WHEN
    T.service_id = '2'
    THEN 'true' END) AS Saturday,
  MAX(CASE WHEN
    T.service_id = '3'
    THEN 'true' END) AS Sunday
FROM trips_bus T
JOIN routes_bus R
ON T.route_id = R.route_id
JOIN stops_bus S
ON R.route_id = T.route_id
JOIN stop_times_bus ST
ON T.trip_id = ST.trip_id AND S.stop_id = ST.stop_id
JOIN (SELECT
        T.trip_id, ST.stop_sequence
      FROM trips_bus T
      JOIN stop_times_bus ST
      ON T.trip_id = ST.trip_id
      WHERE route_id = 33 AND T.direction_id = 0 AND ST.stop_id = 13905) Start
ON T.trip_id = Start.trip_id AND ST.stop_sequence > Start.stop_sequence
WHERE T.route_id = '33' AND direction_id = '0'
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;

-- 593	Penn's Landing - 1	39.948716	-75.140231	true	true	true


-- show me the trips that I can take on Sundays

SELECT
  start.arrival_time DepartureTime, Stop.arrival_time ArrivalTime
FROM

(SELECT
   T.trip_id, ST.arrival_time
 FROM
 stop_times_bus ST
 JOIN trips_bus T
 ON ST.trip_id = T.trip_id
 WHERE ST.stop_id = 13905 AND T.service_id = 3) Start

JOIN (SELECT
        T.trip_id, ST.arrival_time
      FROM
      stop_times_bus ST
      JOIN trips_bus T
      ON ST.trip_id = T.trip_id
      WHERE stop_id = 593 AND T.service_id = 3) Stop
ON start.trip_id = stop.trip_id
ORDER BY DepartureTime;

-- Now the user presses reverse.  The old stops will do us no good.

SELECT
  'NewStart'                                               endpoint, S.stop_id,
  stop_name || ' - ' || (SELECT direction
                         FROM bus_stop_directions
                         WHERE Route = 33 AND dircode = 1) stopName,
  stop_lat, stop_lon, wheelchair_boarding
FROM reverseStopSearch RSS
JOIN stops_bus S
ON RSS.reverse_stop_id = S.stop_id
WHERE RSS.stop_id = 593
UNION

SELECT
  'NewEnd' endpoint, S.stop_id, stop_name, stop_lat,
  stop_lon, wheelchair_boarding
FROM reverseStopSearch RSS
JOIN stops_bus S
ON RSS.reverse_stop_id = S.stop_id
WHERE RSS.stop_id = 13905;

-- now I can instantiate new stop objects
-- NewEnd	13905	23rd St & Venango St Loop	40.009811	-75.166068	0
-- NewStart	593	Penn's Landing - 1	39.948716	-75.140231	0

-- run the trip query again


SELECT
  start.arrival_time DepartureTime, Stop.arrival_time ArrivalTime
FROM

(SELECT
   T.trip_id, ST.arrival_time
 FROM
 stop_times_bus ST
 JOIN trips_bus T

 ON ST.trip_id = T.trip_id
 WHERE ST.stop_id = 593 AND T.service_id = 3 AND T.direction_id = 1) Start

JOIN (SELECT
        T.trip_id, ST.arrival_time
      FROM
      stop_times_bus ST
      JOIN trips_bus T
      ON ST.trip_id = T.trip_id
      WHERE stop_id = 13905 AND T.service_id = 3) Stop
ON start.trip_id = stop.trip_id
ORDER BY DepartureTime;



