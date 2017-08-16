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
WHERE ST.stop_id = 90508 AND T.service_id = 2 and T.direction_id = 0) Start

JOIN (SELECT
T.trip_id,
ST.arrival_time
FROM
stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
WHERE stop_id = 90713 AND T.service_id = 2 and T.direction_id = 0) Stop
ON start.trip_id = stop.trip_id
ORDER BY DepartureTime;

