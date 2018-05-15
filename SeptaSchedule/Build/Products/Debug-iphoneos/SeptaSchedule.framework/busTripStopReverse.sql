

  SELECT
  (SELECT S.stop_id
  FROM reverseStopSearch RSS
    JOIN stops_bus S
    ON RSS.reverse_stop_id = S.stop_id
  WHERE RSS.stop_id = :end_stop_id) newStartId,


  (SELECT S.stop_id
  FROM reverseStopSearch RSS
    JOIN stops_bus S
    ON RSS.reverse_stop_id = S.stop_id
  WHERE RSS.stop_id = :start_stop_id) newEndId;

