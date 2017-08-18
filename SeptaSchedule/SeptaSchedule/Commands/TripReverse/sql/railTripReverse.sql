



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
    WHERE S.stop_id = :start_stop_id AND T.direction_id = 1 AND T.service_id = :service_id) NewStart
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
  WHERE S.stop_id = :end_stop_id AND T.direction_id = 1 AND T.service_id = :service_id) NewEnd
  ON NewStart.trip_id = NewEnd.trip_id;
