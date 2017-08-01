


-- once a route and service type are selected
-- and once the user can pick a start busstop
-- we are in a position to find all ending busstops that are on that same route
-- that have a later arrival time than the starting stop that was selected
-- excluding the original stop that was selected

--In this case, find stops on route 44, on Saturday, given that the user has already selected
-- stop id 694, Coulter Av & Saint Georges Rd

-- returns 58 rows, including 30592    Old Lancaster Rd & City Line Av    -75.235548    -75.235548    0



SELECT DestinationStops.stop_id, DestinationStops.Stop_name, DestinationStops.stop_lon, DestinationStops.stop_lon, DestinationStops.wheelchair_boarding
  from
  -- all the trips that hit that stop on Saturdays on that same route
    (SELECT T.trip_id, ST.arrival_time
     FROM stop_times_bus ST
       JOIN trips_bus T
         ON ST.trip_id = T.trip_id
     WHERE ST.stop_id = :start_stop_id AND T.service_id = :service_id and T.route_id == :route_id
     ) StartingTrips
  Join
  -- all stops on that same trip with a later arrival time
  (SELECT T.trip_id, ST.arrival_time, S.stop_id, S.Stop_name, S.stop_lon, S.stop_lon, s.wheelchair_boarding
     FROM stop_times_bus ST
       JOIN trips_bus T
         ON ST.trip_id = T.trip_id
      JOIN stops_bus S on ST.stop_id = S.stop_id
     WHERE ST.stop_id <> :start_stop_id AND T.service_id = :service_id ) DestinationStops
  on StartingTrips.trip_id = DestinationStops.trip_id
 where StartingTrips.arrival_time < DestinationStops.arrival_time
group by DestinationStops.stop_id, DestinationStops.Stop_name, DestinationStops.stop_lon, DestinationStops.stop_lon, DestinationStops.wheelchair_boarding
order by DestinationStops.stop_name;



