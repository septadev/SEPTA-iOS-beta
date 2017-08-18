

SELECT
  cast(R.route_id AS TEXT)  route_id,
  'to ' || route_short_name route_short_name,
  R.route_long_name,
  cast( T.direction_id as text) direction_id
FROM routes_rail R
  JOIN trips_rail T
WHERE T.direction_id != ':direction_id' AND R.route_id = ':route_id'
GROUP BY R.route_id, R.route_short_name, r.route_long_name, T.direction_id;
