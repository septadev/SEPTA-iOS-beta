SELECT T.trip_id
FROM routes_rail_boundaries B
  JOIN trips_rail T
  ON B.route_id = T.route_id
  JOIN stop_times_rail ST
  ON T.trip_id = ST.trip_id
WHERE ST.stop_id = 90314 AND T.route_id = 'MED';

SELECT T.trip_id
FROM routes_rail_boundaries B
  JOIN trips_rail T
  ON B.route_id = T.route_id
  JOIN stop_times_rail ST
  ON T.trip_id = ST.trip_id
WHERE ST.stop_id = 90406 AND T.route_id = 'AIR';


SELECT
  R.Route_id,
  R.route_short_name           route_short_name,
  B.terminus_name              route_long_name,
  cast(B.direction_id AS TEXT) dircode
FROM routes_rail R
  JOIN routes_rail_boundaries B
  ON R.route_id = B.route_id
  JOIN trips_rail T
  ON B.route_id = T.route_id AND B.direction_id = T.direction_id
  JOIN stop_times_rail ST
  ON T.trip_id = ST.trip_id
  JOIN (SELECT
    T.trip_Id,
    ST.stop_sequence
  FROM routes_rail R
    JOIN routes_rail_boundaries B
    ON R.route_id = B.route_id
    JOIN trips_rail T
    ON R.route_id = T.route_id
    JOIN stop_times_rail ST
    ON T.trip_id = St.trip_id
  WHERE ST.stop_id = 90314 AND T.route_id = 'MED'
       ) StartStop
  ON T.trip_id = StartStop.trip_id
  JOIN (SELECT
    T.trip_Id,
    ST.stop_sequence
  FROM routes_rail R
    JOIN routes_rail_boundaries B
    ON R.route_id = B.route_id
    JOIN trips_rail T
    ON R.route_id = T.route_id
    JOIN stop_times_rail ST
    ON T.trip_id = St.trip_id
  WHERE ST.stop_id = 90406 AND T.route_id = 'MED'
       ) EndStop
  ON T.trip_id = EndStop.trip_id AND StartStop.stop_sequence < EndStop.stop_sequence

-- GROUP BY R.route_id, R.route_short_name, B.terminus_name, B.direction_id;
;
