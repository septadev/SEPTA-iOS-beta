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
WHERE ST.stop_id = 28699 AND T.service_id = 1 and T.direction_id = 0) Start

JOIN (SELECT
  T.trip_id,
  ST.arrival_time
FROM
stop_times_bus ST
JOIN trips_bus T
ON ST.trip_id = T.trip_id
WHERE stop_id = 16053 AND T.service_id = 1 and T.direction_id = 0) Stop
ON start.trip_id = stop.trip_id
ORDER BY DepartureTime;


SELECT
  S.stop_id stopId,
  S.stop_name stopName,
  cast (S.stop_lat as decimal) stopLatitude,
  cast (S.stop_lon as decimal) stopLongitude,
  case when S.wheelchair_boarding = '1' then 1 else 0  end wheelchairBoarding,
  MAX(CASE WHEN T.service_id = '1'
    THEN 1 else 0 END) weekdayService,
  MAX(CASE WHEN
    T.service_id = '2'
    THEN 1  else 0 END) saturdayService,
  MAX(CASE WHEN
    T.service_id = '3'
    THEN 1  else 0 END) AS sundayService
FROM trips_bus T join stop_times_bus ST ON T.trip_id
  = ST.trip_id join stops_bus S on ST.stop_id = S.stop_id

WHERE T.route_id = '44' AND direction_id = '1'
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon ;

Select* from reverseStopSearch;

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
WHERE ST.stop_id = 341 AND T.service_id = 1 and T.direction_id = 0) Start

JOIN (SELECT
  T.trip_id,
  ST.arrival_time
FROM
stop_times_bus ST
JOIN trips_bus T
ON ST.trip_id = T.trip_id
WHERE stop_id = 21044 AND T.service_id = 1 and T.direction_id = 0 ) Stop
ON start.trip_id = stop.trip_id
ORDER BY DepartureTime;


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
WHERE ST.stop_id = 20965 AND T.service_id = 1 and T.direction_id = 0) Start

JOIN (SELECT
  T.trip_id,
  ST.arrival_time
FROM
stop_times_bus ST
JOIN trips_bus T
ON ST.trip_id = T.trip_id
WHERE stop_id = 21531 AND T.service_id = 1 and T.direction_id = 0) Stop
ON start.trip_id = stop.trip_id
ORDER BY DepartureTime;


select * from stop_times_bus where arrival_time = 545 and stop_id = 20965;
select * from stop_times_bus where arrival_time = 542 and stop_id = 21531;

689964