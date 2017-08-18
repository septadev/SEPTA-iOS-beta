SELECT
  NewStart.arrival_time,
  NewEnd.arrival_time
FROM

  (
    SELECT
      S.stop_id,
      T.trip_id,
      ST.arrival_time
    FROM stops_rail S
      JOIN stop_times_rail ST
      ON S.stop_id = ST.stop_id
      JOIN trips_rail T
      ON ST.trip_id = T.trip_id
    WHERE S.stop_id = 90007 AND T.direction_id = 1 AND T.service_id = 1) NewStart
  JOIN
  (SELECT
    S.stop_id,
    T.trip_id,
    ST.arrival_time
  FROM stops_rail S
    JOIN stop_times_rail ST
    ON S.stop_id = ST.stop_id
    JOIN trips_rail T
    ON ST.trip_id = T.trip_id
  WHERE S.stop_id = 90401 AND T.direction_id = 1 AND T.service_id = 1) NewEnd
  ON NewStart.trip_id = NewEnd.trip_id;



SELECT
  cast(R.route_id AS TEXT)  route_id,
  'to ' || route_short_name route_short_name,
  R.route_long_name,
  cast( T.direction_id as text) direction_id
FROM routes_rail R
  JOIN trips_rail T
WHERE T.direction_id != '0' AND R.route_id = 'AIR'
GROUP BY R.route_id, R.route_short_name, r.route_long_name, T.direction_id;