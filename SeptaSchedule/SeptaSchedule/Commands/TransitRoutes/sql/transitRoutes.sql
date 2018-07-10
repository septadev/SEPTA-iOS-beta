SELECT
       cast(R.route_id AS TEXT) route_id,
       cast(R.route_type AS TEXT) route_type,
       route_long_name route_short_name,
       'to ' || BSD.DirectionDescription route_long_name,
       BSD.dircode
  FROM bus_stop_directions BSD
  JOIN routes_bus R
    ON BSD.Route = R.route_id
 WHERE R.route_type != 1
