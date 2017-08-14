-- to get bus routes

-- this is the way I want to sell routes

-- 1	to Parx Casino	Parx Casino to 54th-City	0
-- 1	to 54th-City	Parx Casino to 54th-City	1
-- 2	to 20th-Johnston	20-Johnston to Pulaski-Hntg Park	0
-- 2	to Pulaski-Hunting Park	20-Johnston to Pulaski-Hntg Park	1
-- 3	to 33rd-Cecil B. Moore	33rd-Cecil B. Moore to FTC	0


SELECT
  cast(R.route_id AS TEXT) route_id,
  'to ' || BSD.DirectionDescription route_short_name,
  R.route_long_name,
  BSD.dircode
FROM bus_stop_directions BSD
JOIN routes_bus R
ON BSD.Route = R.route_id
WHERE R.route_id  in ( 'BSO', 'BSL', 'MFL')  ;
;

-- And I choose  Route 44 Westbound

SELECT
  R.route_id,
  BSD.Direction || ' to ' || BSD.DirectionDescription route_short_name,
  R.route_long_name,
  BSD.dircode                                         direction_id
FROM bus_stop_directions BSD
JOIN routes_bus R
ON BSD.Route = R.route_id
WHERE R.route_id == 44 AND direction_id = 1
ORDER BY BSD.route_id;

-- give me all the Westbound stops on route 44

SELECT
  S.stop_id,
  S.stop_name,
  S.stop_lat,
  S.stop_lon,
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

WHERE T.route_id = '44' AND direction_id = '1'
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;

-- now I pick stop 696 as my starting point

-- 696	Montgomery Av & Haverford Av - FS	40.008427	-75.252335	true	true	true


-- Now show me all the stops that are West of that.  On the same route


SELECT
  S.stop_id,
  S.stop_name,
  S.stop_lat,
  S.stop_lon,
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
        T.trip_id,
        ST.stop_sequence
      FROM trips_bus T
      JOIN stop_times_bus ST
      ON T.trip_id = ST.trip_id
      WHERE route_id = 44 AND T.direction_id = 0 AND ST.stop_id = 696) Start
ON T.trip_id = Start.trip_id AND ST.stop_sequence > Start.stop_sequence
WHERE T.route_id = '44' AND direction_id = '0'
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;

-- now I pick 638	5th St & Market St - FS	39.951047	-75.14876	true	true	true


-- show me the trips that I can take on Sundays

SELECT
  start.arrival_time DepartureTime,
  Stop.arrival_time  ArrivalTime
FROM

(SELECT
   T.trip_id,
   ST.arrival_time
 FROM
 stop_times_bus ST
 JOIN trips_bus T
 ON ST.trip_id = T.trip_id
 WHERE ST.stop_id = 696 AND T.service_id = 3) Start

JOIN (SELECT
        T.trip_id,
        ST.arrival_time
      FROM
      stop_times_bus ST
      JOIN trips_bus T
      ON ST.trip_id = T.trip_id
      WHERE stop_id = 638 AND T.service_id = 3) Stop
ON start.trip_id = stop.trip_id
ORDER BY DepartureTime;

-- Now the user presses reverse.  The old stops will do us no good.

SELECT
  'NewStart' endpoint,
  S.stop_id,
  stop_name,
  stop_lat,
  stop_lon,
  wheelchair_boarding
FROM reverseStopSearch RSS
JOIN stops_bus S
ON RSS.reverse_stop_id = S.stop_id
WHERE RSS.stop_id = 638
UNION

SELECT
  'NewEnd' endpoint,
  S.stop_id,
  stop_name,
  stop_lat,
  stop_lon,
  wheelchair_boarding
FROM reverseStopSearch RSS
JOIN stops_bus S
ON RSS.reverse_stop_id = S.stop_id
WHERE RSS.stop_id = 696;

-- now I can instantiate new stop objects
-- NewEnd	705	Montgomery Av & Haverford Av	40.008588	-75.252311
-- NewStart	638	5th St & Market St - FS	39.951047	-75.14876

-- run the trip query again


SELECT
  start.arrival_time DepartureTime,
  Stop.arrival_time  ArrivalTime
FROM

(SELECT
   T.trip_id,
   ST.arrival_time
 FROM
 stop_times_bus ST
 JOIN trips_bus T
 ON ST.trip_id = T.trip_id
 WHERE ST.stop_id = 638 AND T.service_id = 3) Start

JOIN (SELECT
        T.trip_id,
        ST.arrival_time
      FROM
      stop_times_bus ST
      JOIN trips_bus T
      ON ST.trip_id = T.trip_id
      WHERE stop_id = 705 AND T.service_id = 3) Stop
ON start.trip_id = stop.trip_id
ORDER BY DepartureTime;



