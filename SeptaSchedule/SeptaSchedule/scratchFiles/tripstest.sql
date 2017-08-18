SELECT
Start.trip_id, stop.trip_id,
  start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime
FROM

(SELECT
T.trip_id,
ST.arrival_time,
 T.service_id,
  T.direction_id
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = 90518 AND T.service_id = 1 and T.direction_id = 0) Start

JOIN (SELECT
T.trip_id,
ST.arrival_time,
  T.service_id,
  T.direction_id
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE stop_id = 90521 AND T.service_id = 1 and T.direction_id = 0) Stop
ON start.trip_id = stop.trip_id and start.service_id = stop.service_id and start.direction_id = stop.direction_id;



SELECT
start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime
FROM

(SELECT
T.trip_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = 90522 AND T.service_id = 1 and T.direction_id = 0) Start

JOIN (SELECT
T.trip_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE stop_id = 90007 AND T.service_id = 1 and T.direction_id = 0) Stop
ON start.trip_id = stop.trip_id

group by start.arrival_time,Stop.arrival_time
ORDER BY DepartureTime;

select stop_id from stops_rail where stop_name = 'Overbrook';  -- 90522
select stop_id from stops_rail where stop_name = 'Temple University';  --90007
select stop_id from stops_rail where stop_name = 'Jefferson Station';  --90006

