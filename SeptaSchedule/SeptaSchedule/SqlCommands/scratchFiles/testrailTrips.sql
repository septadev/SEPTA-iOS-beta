
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
FROM stop_times_rail ST
JOIN trips_rail T
ON ST.trip_id = T.trip_id
JOIN stops_rail S
ON ST.stop_id = S.stop_ID
JOIN (SELECT
  T.trip_id,
  ST.stop_sequence
FROM trips_bus T
JOIN stop_times_bus ST
ON T.trip_id = ST.trip_id
WHERE route_id = ':route_id' AND T.direction_id = :direction_id AND ST.stop_id = :stop_id) Start
ON T.trip_id = Start.trip_id AND ST.stop_sequence > Start.stop_sequence
WHERE T.route_id = ':route_id' AND direction_id = ':direction_id'
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;
