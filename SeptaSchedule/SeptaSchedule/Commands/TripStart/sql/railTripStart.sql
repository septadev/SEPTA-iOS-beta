SELECT
  S.stop_id                   stopId,
  RRS.sequence                stop_sequence,
  S.stop_name                 stopName,
  cast(S.stop_lat AS DECIMAL) stopLatitude,
  cast(S.stop_lon AS DECIMAL) stopLongitude,
  CASE WHEN S.wheelchair_boarding = '1'
    THEN 1
  ELSE 0 END                  wheelchairBoarding,
  1           weekdayService,
  1 saturdayService,
  1 sundayService
FROM
  stops_rail S
JOIN routes_rail_stops RRS on S.stop_id = RRS.stop_id
WHERE RRS.route_id = ':route_id' AND RRS.direction_id = :direction_id


