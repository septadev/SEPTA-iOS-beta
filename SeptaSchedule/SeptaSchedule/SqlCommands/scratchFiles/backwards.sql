
select count( *) from (
SELECT
  S.stop_id,
  S.stop_name,
  max(S.stop_lat),
  max(S.stop_lon),
  MAX(CASE WHEN T.service_id = '1'
    THEN 'true' END) AS Weekday,
  MAX(CASE WHEN
    T.service_id = '2'
    THEN 'true' END) AS Saturday,
  MAX(CASE WHEN
    T.service_id = '3'
    THEN 'true' END) AS Sunday
FROM trips_bus T join stop_times_bus ST ON T.trip_id
  = ST.trip_id join stops_bus S on ST.stop_id = S.stop_id

WHERE T.route_id = '44' AND T.direction_id = '1'
GROUP BY S.stop_id, S.stop_name);

select sum(c) from (
select count (*) c from trips_bus T join stop_times_bus ST on T.trip_id = ST.trip_id
where T.route_id = 44 and T.direction_id = 1
group by ST.stop_id);