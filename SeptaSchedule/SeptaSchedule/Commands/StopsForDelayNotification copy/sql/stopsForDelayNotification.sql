

-- 90701    Trenton    40.2177778    -74.755    1
-- 90004    30th Street Station    39.9566667    -75.1816667    1


-- EXAMPLE:  
-- SELECT
--   S.stop_id,
--   S.stop_name,
--   S.stop_lat,
--   S.stop_lon,
--   S.wheelchair_boarding
-- FROM (
--
--        SELECT
--          S.stop_id,
--          S.stop_name,
--          S.stop_lat,
--          S.stop_lon,
--          S.wheelchair_boarding
--        FROM trips_rail T
--          JOIN stop_times_rail ST
--          ON T.trip_id = ST.trip_id
--          JOIN calendar_rail C
--          ON T.service_id = C.service_id
--          JOIN stops_rail S
--          ON ST.stop_id = S.stop_id
--        WHERE block_id = '736' AND T.route_id = 'TRE' AND T.service_id IN (SELECT service_id
--        FROM calendar_rail
--        WHERE days & 2)
--        ORDER BY stop_sequence
--        LIMIT 1) S
--
--
-- UNION ALL
--
-- SELECT
--   S.stop_id,
--   S.stop_name,
--   S.stop_lat,
--   S.stop_lon,
--   S.wheelchair_boarding
-- FROM stops_rail S
-- WHERE S.stop_id = '90004';


SELECT
  S.stop_id,
  S.stop_name,
  cast(S.stop_lat AS DECIMAL) stop_lat,
  cast(S.stop_lon AS DECIMAL) stop_lon,
  S.wheelchair_boarding
FROM (

       SELECT
         S.stop_id,
         S.stop_name,
         S.stop_lat,
         S.stop_lon,
         S.wheelchair_boarding
       FROM trips_rail T
         JOIN stop_times_rail ST
         ON T.trip_id = ST.trip_id
         JOIN calendar_rail C
         ON T.service_id = C.service_id
         JOIN stops_rail S
         ON ST.stop_id = S.stop_id
       WHERE block_id = ':trip_id' AND T.route_id = ':route_id' AND T.service_id IN (SELECT service_id
       FROM calendar_rail
       WHERE days & :days)
       ORDER BY stop_sequence
       LIMIT 1) S


UNION ALL

SELECT
  S.stop_id,
  S.stop_name,
  cast(S.stop_lat AS DECIMAL) stop_lat,
  cast(S.stop_lon AS DECIMAL) stop_lon,
  S.wheelchair_boarding
FROM stops_rail S
WHERE S.stop_id = ':end_stop_id';

