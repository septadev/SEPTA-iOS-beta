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
T.trip_id,T.route_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = :start_stop_id and T.direction_id = :direction_id and T.service_id in (select service_id from calendar_rail C where days & :day_id)) Start

JOIN (SELECT
T.trip_id, T.direction_id, T.service_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE  stop_id = :end_stop_id and T.direction_id = :direction_id  and T.service_id in (select service_id from calendar_rail C where days & :day_id)) Stop
ON start.trip_id = stop.trip_id;



select stop_id from stops_rail where stop_name = 'Overbrook';  -- 90522
select stop_id from stops_rail where stop_name = 'Temple University';  --90007
select stop_id from stops_rail where stop_name = 'Jefferson Station';  --90006

select service_id  from calendar_rail where days = 62;

select * from calendar_bus


SELECT
start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime
FROM

(SELECT
T.trip_id,T.route_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = :start_stop_id and T.direction_id = :direction_id and T.service_id in (select service_id from calendar_rail C where days & :service_id)) Start

JOIN (SELECT
T.trip_id, T.direction_id, T.service_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE  stop_id = :end_stop_id and T.direction_id = :direction_id  and T.service_id in (select service_id from calendar_rail  C where days & :service_id)) Stop
ON start.trip_id = stop.trip_id;
group by start.arrival_time, stop.arrival_time
