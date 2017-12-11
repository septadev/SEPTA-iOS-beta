SELECT
 S.stop_id                   stopId,
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
JOIN routes_rail_stops RRS2 on RRS2.sequence < RRS.sequence
WHERE RRS.route_id = 'GC' AND RRS.direction_id = '0' and RRS2.stop_id = '90410' and RRS2.route_id = 'GC' AND RRS2.direction_id = '0'