-- T.route_id = '2' AND direction_id = '0' T.service_id = 1
SELECT
  (SELECT S.stop_id
  FROM reverseStopSearch RSS
    JOIN stops_bus S
    ON RSS.reverse_stop_id = S.stop_id
  WHERE RSS.stop_id = 2673) newStartId,


  (SELECT S.stop_id
  FROM reverseStopSearch RSS
    JOIN stops_bus S
    ON RSS.reverse_stop_id = S.stop_id
  WHERE RSS.stop_id = 3076) newEndId;

-- NewStart	3029
-- NewEnd	3024



SELECT
  NewStart.arrival_time,
  NewEnd.arrival_time
FROM

  (
    SELECT
      S.stop_id,
      T.trip_id,
      ST.arrival_time
    FROM stops_bus S
      JOIN stop_times_bus ST
      ON S.stop_id = ST.stop_id
      JOIN trips_bus T
      ON ST.trip_id = T.trip_id
    WHERE S.stop_id = 3029 AND T.direction_id = 1 AND T.service_id = 1) NewStart
  JOIN
  (SELECT
    S.stop_id,
    T.trip_id,
    ST.arrival_time
  FROM stops_bus S
    JOIN stop_times_bus ST
    ON S.stop_id = ST.stop_id
    JOIN trips_bus T
    ON ST.trip_id = T.trip_id
  WHERE S.stop_id = 3024 AND T.direction_id = 1 AND T.service_id = 1) NewEnd
  ON NewStart.trip_id = NewEnd.trip_id;

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
FROM stops_bus S
  JOIN stop_times_bus St
  ON S.stop_id = ST.stop_id
  JOIN trips_bus T
  ON ST.trip_id = T.trip_id
WHERE s.stop_id IN (3029, 3024)
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;

-- Now we need to reverse the route


SELECT
  cast(R.route_id AS TEXT) route_id,
  'to ' || BSD.DirectionDescription route_short_name,
  R.route_long_name,
  BSD.dircode
FROM bus_stop_directions BSD
JOIN routes_bus R
ON BSD.Route = R.route_id
where BSD.dircode != 1 and R.route_id = 1;

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
FROM trips_bus T
JOIN routes_bus R
ON T.route_id = R.route_id
JOIN stop_times_bus ST
ON T.trip_id = ST.trip_id
join stops_bus S
  on ST.stop_id = S.Stop_id
JOIN (SELECT
  T.trip_id,
  ST.stop_sequence
FROM trips_bus T
JOIN stop_times_bus ST
ON T.trip_id = ST.trip_id
WHERE route_id = '44' AND T.direction_id = 0 AND ST.stop_id = 638) Start
ON T.trip_id = Start.trip_id AND ST.stop_sequence < Start.stop_sequence
WHERE T.route_id = '44' AND direction_id = '0'
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;

select * from stopNameLookUpTable where stop_id = 23427;


SELECT (SELECT 1) START, (SELECT 2) AS FINISH;






