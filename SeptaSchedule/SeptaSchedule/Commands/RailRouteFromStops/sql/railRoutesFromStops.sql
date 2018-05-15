

-- MED    Media/Elwyn Line    to Center City Philadelphia    0



SELECT
  R.Route_id,
  R.route_short_name           route_short_name,
  B.terminus_name              route_long_name,
  cast(B.direction_id AS TEXT) dircode
FROM routes_rail R
    JOIN routes_rail_boundaries B
    ON R.route_id = B.route_id
    JOIN trips_rail T
    ON R.route_id = T.route_id and B.direction_id = T.direction_id
    JOIN stop_times_rail ST
    ON T.trip_id = St.trip_id
  JOIN (SELECT
    R.route_id,
    T.trip_Id,
    ST.stop_sequence
  FROM routes_rail R
    JOIN routes_rail_boundaries B
    ON R.route_id = B.route_id
    JOIN trips_rail T
    ON R.route_id = T.route_id
    JOIN stop_times_rail ST
    ON T.trip_id = St.trip_id
  WHERE ST.stop_id = :endStopId
       ) EndStop
  ON T.trip_id = EndStop.trip_id AND ST.stop_sequence < EndStop.stop_sequence
WHERE ST.stop_id = :startStopId AND T.route_id = ':route_id'
group by R.route_id
;
