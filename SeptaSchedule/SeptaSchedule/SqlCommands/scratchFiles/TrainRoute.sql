
--All the routes available
select route_type from routes_bus group by route_type;

--MF Line.  Grouped with SUBway
select * from routes_bus where route_type = 1;

-- These are trollleys
Select * from routes_bus where route_type = 0;

-- These are buses
Select * from routes_bus where route_type = 3 ;

-- Broad Street Line
Select * from routes_bus where  route_id in ( 'BSO', 'BSL');

--So here is what the subway query will look like
Select * from routes_bus where  route_id in ( 'BSO', 'BSL', 'MFL');



-- Regional Rail
Select * from routes_rail;



--All the rail routes available  type 2
select route_type from routes_rail group by route_type;

-- this corresponds with the regional rail tab in the app
select * from routes_rail;

