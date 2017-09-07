



SELECT
start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime,
start.block_id
FROM

(SELECT
T.trip_id,T.route_id,
ST.arrival_time,
T.block_id
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
ON start.trip_id = stop.trip_id
group by start.arrival_time, stop.arrival_time;

