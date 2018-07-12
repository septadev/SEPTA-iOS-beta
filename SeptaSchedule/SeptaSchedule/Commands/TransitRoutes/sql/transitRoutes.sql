SELECT
       cast(R.route_id AS TEXT) route_id,
       cast(R.route_type AS TEXT) route_type,
       route_long_name route_name
  FROM routes_bus R
 WHERE R.route_type != 1
