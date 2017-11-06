
SELECT
start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime,
Start.block_id,
cast (start.trip_id as TEXT) trip_id
FROM

(SELECT
T.trip_id,
ST.arrival_time,
T.block_id
FROM
stop_times_bus ST
JOIN trips_bus T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = 1923 ) Start

JOIN (SELECT
T.trip_id, T.direction_id, T.service_id,
ST.arrival_time
FROM
stop_times_bus  ST
JOIN trips_bus T
ON ST.trip_id = T.trip_id
WHERE  stop_id = 1919 ) Stop
ON start.trip_id = stop.trip_id
group by start.arrival_time, Stop.arrival_time
ORDER BY DepartureTime;


select * from stop_times_bus ST join trips_rail T on ST.trip_id = T.trip_id where  stop_id = 1919;
