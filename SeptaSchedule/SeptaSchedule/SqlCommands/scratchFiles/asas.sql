SELECT
  S.stop_id                   stopId,
  S.stop_name                 stopName,
  cast(S.stop_lat AS DECIMAL) stopLatitude,
  cast(S.stop_lon AS DECIMAL) stopLongitude,
  CASE WHEN S.wheelchair_boarding = '1'
    THEN 1
  ELSE 0 END                  wheelchairBoarding



FROM trips_rail T
JOIN routes_rail R
ON T.route_id = R.route_id
JOIN stop_times_rail ST
ON T.trip_id = ST.trip_id
join stops_rail S
  on ST.stop_id = S.Stop_id
JOIN (SELECT
  T.trip_id,
  ST.stop_sequence
FROM trips_rail T
JOIN stop_times_rail ST
ON T.trip_id = ST.trip_id
WHERE route_id = 'CYN' AND T.direction_id = 0 AND ST.stop_id = 90005) Start
ON T.trip_id = Start.trip_id AND ST.stop_sequence > Start.stop_sequence
WHERE T.route_id = 'CYN' AND direction_id = '0'
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon;

select * from trips_rail


Select *  from routes_rail