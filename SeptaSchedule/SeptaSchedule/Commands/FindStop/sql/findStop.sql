
--- 90004    30th Street Station    39.9566667    -75.1816667    1    1    1    1


SELECT
  S.stop_id                   stopId,
  S.stop_name                 stopName,
  cast(S.stop_lat AS DECIMAL) stopLatitude,
  cast(S.stop_lon AS DECIMAL) stopLongitude,
  CASE WHEN S.wheelchair_boarding = '1'
    THEN 1
  ELSE 0 END                  wheelchairBoarding,
  1                           weekdayService,
  1                           saturdayService,
  1                           sundayService

FROM :table_name S
WHERE S.stop_id = :stop_id;
