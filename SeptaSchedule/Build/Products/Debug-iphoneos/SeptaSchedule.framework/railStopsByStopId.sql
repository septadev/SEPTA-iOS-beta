

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
FROM stops_rail S
  JOIN stop_times_rail St
  ON S.stop_id = ST.stop_id
  JOIN trips_rail T
  ON ST.trip_id = T.trip_id
WHERE s.stop_id IN (:start_stop_id, :end_stop_id)
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;
