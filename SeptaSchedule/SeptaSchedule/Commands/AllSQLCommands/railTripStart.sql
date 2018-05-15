SELECT
  S.stop_id                   stopId,
  S.stop_name                 stopName,
  cast(S.stop_lat AS DECIMAL) stopLatitude,
  cast(S.stop_lon AS DECIMAL) stopLongitude,
  CASE WHEN S.wheelchair_boarding = '1'
    THEN 1
  ELSE 0 END                  wheelchairBoarding,
  MAX(CASE WHEN T.service_id = '1'
    THEN 1
      ELSE 0 END)             weekdayService,
  MAX(CASE WHEN
    T.service_id = '2'
    THEN 1
      ELSE 0 END)             saturdayService,
  MAX(CASE WHEN
    T.service_id = '3'
    THEN 1
      ELSE 0 END) AS          sundayService
FROM
  stop_times_rail ST
  JOIN trips_rail T ON T.trip_id = ST.trip_id
  JOIN stops_rail S ON ST.stop_id = S.stop_id

  JOIN (SELECT
          ST.stop_sequence,
          T.trip_id
        FROM routes_rail_boundaries B
          JOIN trips_rail T ON B.route_id = T.route_id
          JOIN stop_times_rail ST ON T.trip_id = ST.trip_id
        WHERE B.route_id = ':route_id' AND B.direction_id = ':direction_id' AND ST.stop_id = B.lineStart_stop_id
       ) LineStart
    ON ST.stop_sequence >= LineStart.stop_sequence AND ST.trip_id = LineStart.trip_id


  JOIN (SELECT
          ST.stop_sequence,
          T.trip_id
        FROM routes_rail_boundaries B
          JOIN trips_rail T ON B.route_id = T.route_id
          JOIN stop_times_rail ST ON T.trip_id = ST.trip_id
        WHERE B.route_id = ':route_id' AND B.direction_id = ':direction_id' AND ST.stop_id = B.lineEnd_stop_id
       ) LineEnd
    ON ST.stop_sequence <= LineEnd.stop_sequence AND ST.trip_id = LineEnd.trip_id

WHERE T.route_id = ':route_id' AND T.direction_id = ':direction_id'
GROUP BY S.stop_id, S.stop_name, S.stop_lat, S.stop_lon
ORDER BY ST.stop_sequence;
