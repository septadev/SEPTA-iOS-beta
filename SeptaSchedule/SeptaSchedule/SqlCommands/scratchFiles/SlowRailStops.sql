SELECT

  start.arrival_time           DepartureTime,
  Stop.arrival_time            ArrivalTime,
  cast(start.block_id AS TEXT) block_id,
  start.trip_id
FROM

  (SELECT
     T.trip_id,
     T.route_id,
     ST.arrival_time,
     T.block_id
   FROM
     stop_times_rail ST
     JOIN trips_rail T
       ON ST.trip_id = T.trip_id
   WHERE ST.stop_id = 90403 AND T.direction_id = 1 AND T.service_id IN (SELECT service_id
                                                                        FROM calendar_rail C
                                                                        WHERE days & 32)) Start

  JOIN (SELECT
          T.trip_id,
          T.direction_id,
          T.service_id,
          ST.arrival_time
        FROM
          stop_times_rail ST
          JOIN trips_rail T
            ON ST.trip_id = T.trip_id
        WHERE stop_id = 90401 AND T.direction_id = 1 AND T.service_id IN (SELECT service_id
                                                                          FROM calendar_rail C
                                                                          WHERE days & 32)) Stop
    ON start.trip_id = stop.trip_id
GROUP BY start.arrival_time, stop.arrival_time;


SELECT
  start.arrival_time          DepartureTime,
  Stop.arrival_time           ArrivalTime,
  Start.block_id,
  cast(start.trip_id AS TEXT) trip_id
FROM

  (SELECT
     T.trip_id,
     ST.arrival_time,
     T.block_id
   FROM
     stop_times_bus ST
     JOIN trips_bus T
       ON ST.trip_id = T.trip_id
   WHERE ST.stop_id = 1923 AND T.service_id IN (SELECT service_id
                                                FROM calendar_bus C
                                                WHERE days & 32) AND T.direction_id = 0) Start

  JOIN (SELECT
          T.trip_id,
          T.direction_id,
          T.service_id,
          ST.arrival_time
        FROM
          stop_times_bus ST
          JOIN trips_bus T
            ON ST.trip_id = T.trip_id
        WHERE stop_id = 1935 AND T.service_id IN (SELECT service_id
                                                  FROM calendar_bus C
                                                  WHERE days & 32) AND T.direction_id = 0) Stop
    ON start.trip_id = stop.trip_id
GROUP BY start.arrival_time, Stop.arrival_time
ORDER BY DepartureTime;

