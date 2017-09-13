SELECT *
FROM stops_rail;


SELECT
  S.stop_id                   stopId,
  S.stop_name                 stopName,
  cast(S.stop_lat AS DECIMAL) stopLatitude,
  cast(S.stop_lon AS DECIMAL) stopLongitude,
  CASE WHEN S.wheelchair_boarding = '1'
    THEN 1
  ELSE 0 END                  wheelchairBoarding,
  MAX(CASE WHEN T.service_id = '1'
    THEN 1
      ELSE 0 END)             weekdayService,
  MAX(CASE WHEN
    T.service_id = '2'
    THEN 1
      ELSE 0 END)             saturdayService,
  MAX(CASE WHEN
    T.service_id = '3'
    THEN 1
      ELSE 0 END) AS          sundayService
FROM trips_rail T
  JOIN routes_rail R
  ON T.route_id = R.route_id
  JOIN stop_times_rail ST
  ON T.trip_id = ST.trip_id
  JOIN stops_rail S
  ON ST.stop_id = S.Stop_id
  JOIN (SELECT
    T.trip_id,
    ST.stop_sequence
  FROM trips_rail T
    JOIN stop_times_rail ST
    ON T.trip_id = ST.trip_id
  WHERE route_id = ':route_id' AND T.direction_id = :direction_id AND ST.stop_id = :stop_id) Start
  ON T.trip_id = Start.trip_id AND ST.stop_sequence > Start.stop_sequence
WHERE T.route_id = ':route_id' AND direction_id = ':direction_id'
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;

SELECT
  S.stop_id                   stopId,
  S.stop_name                 stopName,
  cast(S.stop_lat AS DECIMAL) stopLatitude,
  cast(S.stop_lon AS DECIMAL) stopLongitude,
  CASE WHEN S.wheelchair_boarding = '1'
    THEN 1
  ELSE 0 END                  wheelchairBoarding,
  MAX(CASE WHEN T.service_id = '1'
    THEN 1
      ELSE 0 END)             weekdayService,
  MAX(CASE WHEN
    T.service_id = '2'
    THEN 1
      ELSE 0 END)             saturdayService,
  MAX(CASE WHEN
    T.service_id = '3'
    THEN 1
      ELSE 0 END) AS          sundayService
FROM
  stop_times_rail ST
  JOIN trips_rail T
  ON T.trip_id = ST.trip_id
  JOIN stops_rail S
  ON ST.stop_id = S.stop_id

GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;


;

SELECT *
FROM stops_rail
WHERE stop_name IN ('Gravers', 'Chestnut Hill East');

select max(stop_lat) maxLat, min(stop_lat) minLat, max(stop_lon) maxLon, min(stop_lon) minLon FROM (
SELECT
 cast ( S.stop_lat as decimal) stop_lat,
  cast (S.stop_lon as decimal) stop_lon
FROM routes_bus r
  JOIN trips_bus T
  ON r.route_id = t.route_id
  JOIN stop_times_bus
       ST
  ON T.trip_id = ST.trip_id
  JOIN stops_bus S
  ON ST.stop_id = S.stop_id
WHERE r.route_id = '44' AND direction_id = 0
GROUP BY S.stop_lat, S.stop_lon);

select * from routes_bus where route_id = 'R';

select * from stops_rail where stop_name = 'Ivy Ridge';  --90222
select * from stops_rail where stop_name = 'Angora'; --90313


SELECT
  cast(R.route_id AS TEXT) route_id,
  route_long_name route_short_name,
  'to ' || BSD.DirectionDescription route_long_name,
  BSD.dircode
FROM bus_stop_directions BSD
JOIN routes_bus R
ON BSD.Route = R.route_id;


SELECT
R.Route_id,
R.route_short_name route_short_name,
'to ' || S.stop_name route_long_name,
cast (T.direction_id  as TEXT )                            dircode

FROM routes_rail R
JOIN trips_rail T ON R.route_id = T.route_id
JOIN stop_times_rail ST ON T.trip_id = ST.trip_id
JOIN stops_rail S ON ST.stop_id = S.stop_id
JOIN
(
SELECT
R.route_id,
T.direction_id,
max(ST.stop_sequence) max_stop_sequence

FROM routes_rail R
JOIN trips_rail T ON R.route_id = T.route_id
JOIN stop_times_rail ST ON T.trip_id = ST.trip_id
JOIN stops_rail S ON ST.stop_id = S.stop_id
GROUP BY R.route_id, T.direction_id) lastStop
ON R.route_id = lastStop.route_id AND T.direction_id = lastStop.direction_id AND
ST.stop_sequence = lastStop.max_stop_sequence
GROUP BY R.Route_id,R.route_short_name, R.route_long_name,T.direction_id ,S.stop_name;


select * from stops_rail where stop_id = 90222;


select * from stops_rail where stop_id = 90313;



SELECT

start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime,
start.block_id,
start.trip_id
FROM

(SELECT
T.trip_id,T.route_id,
ST.arrival_time,
T.block_id
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = 90508 and T.direction_id = 0 and T.service_id in (select service_id from calendar_rail C where days & 32)) Start

JOIN (SELECT
T.trip_id, T.direction_id, T.service_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE  stop_id = 90719 and T.direction_id = 0  and T.service_id in (select service_id from calendar_rail  C where days & 32)) Stop
ON start.trip_id = stop.trip_id
group by start.arrival_time, stop.arrival_time;


SELECT

start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime,
start.block_id,
start.trip_id
FROM

(SELECT
T.trip_id,T.route_id,
ST.arrival_time,
T.block_id
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = 90502 and T.direction_id = 0 and T.service_id in (select service_id from calendar_rail C where days & 32)) Start

JOIN (SELECT
T.trip_id, T.direction_id, T.service_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE  stop_id = 90503 and T.direction_id = 0  and T.service_id in (select service_id from calendar_rail  C where days & 32)) Stop
ON start.trip_id = stop.trip_id
group by start.arrival_time, stop.arrival_time;

SELECT

start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime,
start.block_id,
start.trip_id
FROM

(SELECT
T.trip_id,T.route_id,
ST.arrival_time,
T.block_id
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = 90502 and T.direction_id = 0 and T.service_id in (select service_id from calendar_rail C where days & 32)) Start

JOIN (SELECT
T.trip_id, T.direction_id, T.service_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE  stop_id = 90503 and T.direction_id = 0  and T.service_id in (select service_id from calendar_rail  C where days & 32)) Stop
ON start.trip_id = stop.trip_id
group by start.arrival_time, stop.arrival_time;

select * from trips_rail;


SELECT
R.Route_id,
R.route_short_name route_short_name,
'to ' || S.stop_name route_long_name,
cast (T.direction_id  as TEXT )                            dircode

FROM routes_rail R
JOIN trips_rail T ON R.route_id = T.route_id
JOIN stop_times_rail ST ON T.trip_id = ST.trip_id
JOIN stops_rail S ON ST.stop_id = S.stop_id
JOIN
(
SELECT
R.route_id,
T.direction_id,
max(ST.stop_sequence) max_stop_sequence

FROM routes_rail R
JOIN trips_rail T ON R.route_id = T.route_id
JOIN stop_times_rail ST ON T.trip_id = ST.trip_id
JOIN stops_rail S ON ST.stop_id = S.stop_id
GROUP BY R.route_id, T.direction_id) lastStop
ON R.route_id = lastStop.route_id AND T.direction_id = lastStop.direction_id AND
ST.stop_sequence = lastStop.max_stop_sequence
GROUP BY R.Route_id,R.route_short_name, R.route_long_name,T.direction_id ,S.stop_name;



SELECT

start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime,
cast (start.block_id as TEXT) block_id,
start.trip_id
FROM

(SELECT
T.trip_id,T.route_id,
ST.arrival_time,
T.block_id
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = 90403 and T.direction_id = 1 and T.service_id in (select service_id from calendar_rail C where days & 32)) Start

JOIN (SELECT
T.trip_id, T.direction_id, T.service_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE  stop_id = 90401 and T.direction_id = 1  and T.service_id in (select service_id from calendar_rail  C where days & 32)) Stop
ON start.trip_id = stop.trip_id
group by start.arrival_time, stop.arrival_time;

