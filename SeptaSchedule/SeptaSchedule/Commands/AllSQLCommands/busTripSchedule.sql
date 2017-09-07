
SELECT
start.arrival_time DepartureTime,
Stop.arrival_time  ArrivalTime,
Start.block_id
FROM

(SELECT
T.trip_id,
ST.arrival_time,
T.block_id
FROM
stop_times_bus ST
JOIN trips_bus T
ON ST.trip_id = T.trip_id
WHERE ST.stop_id = :start_stop_id AND T.service_id = :service_id and T.direction_id = :direction_id) Start

JOIN (SELECT
T.trip_id, T.direction_id, T.service_id,
ST.arrival_time
FROM
stop_times_bus  ST
JOIN trips_bus T
ON ST.trip_id = T.trip_id
WHERE  stop_id = :end_stop_id AND T.service_id = :service_id and T.direction_id = :direction_id) Stop
ON start.trip_id = stop.trip_id
group by start.arrival_time, Stop.arrival_time
ORDER BY DepartureTime;



