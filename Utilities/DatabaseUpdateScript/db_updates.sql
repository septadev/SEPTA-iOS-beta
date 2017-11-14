CREATE TABLE routes_rail_boundaries
(
  route_id          TEXT,
  lineStart_stop_id INT,
  lineEnd_stop_id   INT,
  terminus_name     TEXT,
  direction_id      TEXT
);

INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('AIR', 90401, 90007, 'to Center City Philadelphia', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('AIR', 90007, 90401, 'to Philadelphia International Airport', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('CHE', 90004, 90720, 'to Chestnut Hill East', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id) 
VALUES ('CHE', 90720, 90004, 'to Center City Philadelphia', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('CHW', 90801, 90007, 'to Center City Philadelphia', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('CHW', 90007, 90801, 'to Chestnut Hill West', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('CYN', 90001, 90005, 'to Center City Philadelphia', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('CYN', 90005, 90001, 'to Cynwyd', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('FOX', 90004, 90815, 'to Fox Chase', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('FOX', 90815, 90004, 'to Center City Philadelphia', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('GC', 90406, 90538, 'to Glenside', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('GC', 90538, 90406, 'to Center City Philadelphia', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('LAN', 90004, 90538, 'to Doylestown', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('LAN', 90538, 90004, 'to Center City Philadelphia', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('NOR', 90406, 90228, 'to Norristown', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('NOR', 90228, 90406, 'to Center City Philadelphia', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('MED', 90301, 90007, 'to Center City Philadelphia', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('MED', 90007, 90301, 'to Elwyn', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('PAO', 90501, 90007, 'to Center City Philadelphia', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('PAO', 90007, 90501, 'to Thorndale', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('TRE', 90701, 90007, 'to Center City Philadelphia', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('TRE', 90007, 90701, 'to Trenton', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('WAR', 90406, 90417, 'to Warminster', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('WAR', 90417, 90406, 'to Center City Philadelphia', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('WTR', 90406, 90327, 'to West Trenton', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('WTR', 90327, 90406, 'to Center City Philadelphia', '1');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('WIL', 90201, 90007, 'to Center City Philadelphia', '0');
INSERT INTO routes_rail_boundaries (route_id, lineStart_stop_id, lineEnd_stop_id, terminus_name, direction_id)
VALUES ('WIL', 90007, 90201, 'to Wilmington & Newark, DE', '1');

--   stop_times_bus
DROP INDEX tripBUSIDX;
CREATE INDEX stop_id__index
  ON stop_times_bus (stop_id);
CREATE INDEX stop_times_bus_Reverse_index
  ON stop_times_bus (stop_id, trip_id);
CREATE INDEX tripBUSIDX
  ON stop_times_bus (trip_id, stop_id, stop_sequence);

-- drop unneeded tables
DROP TABLE stop_times_MFL;
DROP TABLE stop_times_NHSL;
DROP TABLE stop_times_BSL;
DROP TABLE trips_BSL;
DROP TABLE trips_MFL;
DROP TABLE trips_NHSL;

-- index trips by route

CREATE INDEX trips_bus_route_id_index
  ON trips_bus (route_id);

-- trips rail
CREATE INDEX trips_rail_route_id_trip_id_index
  ON trips_rail (route_id, trip_id);

CREATE INDEX trips_rail_trip_id_route_id_index 
  ON trips_rail (trip_id, route_id);

-- routes-bus

CREATE INDEX routes_bus_route_id_index
  ON routes_bus (route_id);

-- routes-rail

CREATE INDEX routes_rail_route_id_index
  ON routes_rail (route_id);

-- reverse Stop Search
CREATE INDEX reverseStopSearch_reverse_stop_id_stop_id_index
  ON reverseStopSearch (reverse_stop_id, stop_id);
CREATE INDEX reverseStopSearch_stop_id_reverse_stop_id_index
  ON reverseStopSearch (stop_id, reverse_stop_id);

-- bus stop directions

CREATE INDEX bus_stop_directions_Route_index
  ON bus_stop_directions (Route);

-- stop times rail

CREATE INDEX stop_times_rail_trip_id_stop_id_stop_sequence_index 
  ON stop_times_rail (trip_id, stop_id, stop_sequence);
CREATE INDEX stop_times_rail_stop_id_trip_id_index 
  ON stop_times_rail (stop_id, trip_id);

VACUUM;
