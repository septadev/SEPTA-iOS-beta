


SELECT
R.Route_id,
R.route_short_name route_short_name,
'to ' || S.stop_name route_long_name,
cast (T.direction_id  as TEXT )                            dircode

FROM routes_rail R
JOIN trips_rail T ON R.route_id = T.route_id
JOIN stop_times_rail ST ON T.trip_id = ST.trip_id
JOIN stops_rail S ON ST.stop_id = S.stop_id
JOIN
(
SELECT
R.route_id,
T.direction_id,
max(ST.stop_sequence) max_stop_sequence

FROM routes_rail R
JOIN trips_rail T ON R.route_id = T.route_id
JOIN stop_times_rail ST ON T.trip_id = ST.trip_id
JOIN stops_rail S ON ST.stop_id = S.stop_id
GROUP BY R.route_id, T.direction_id) lastStop
ON R.route_id = lastStop.route_id AND T.direction_id = lastStop.direction_id AND
ST.stop_sequence = lastStop.max_stop_sequence
WHERE T.direction_id != ':direction_id' AND R.route_id = ':route_id'
GROUP BY R.Route_id,R.route_short_name, R.route_long_name,T.direction_id ,S.stop_name;
