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
WHERE ST.stop_id = 28699 AND T.service_id = 1) Start

JOIN (SELECT
  T.trip_id,
  ST.arrival_time
FROM
stop_times_bus ST
JOIN trips_bus T
ON ST.trip_id = T.trip_id
WHERE stop_id = 16053 AND T.service_id = 1) Stop
ON start.trip_id = stop.trip_id
ORDER BY DepartureTime;