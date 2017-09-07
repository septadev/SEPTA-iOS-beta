
SELECT
cast(R.route_id AS TEXT) route_id,
route_long_name route_short_name,
'to ' || BSD.DirectionDescription route_long_name,
BSD.dircode

FROM bus_stop_directions BSD
JOIN routes_bus R
ON BSD.Route = R.route_id
where BSD.dircode != ':direction_id' and R.route_id = ':route_id';

