select service_id from stop_times_bus ST join trips_bus T where route_id = 'MFO' group by service_id
;