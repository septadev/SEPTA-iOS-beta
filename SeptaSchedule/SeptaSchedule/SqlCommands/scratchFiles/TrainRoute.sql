
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
select
  route_id,
  route_short_name,
  route_long_name,
  '0' dircode
from routes_rail;

-- AIR	Airport Line	Airport Line	0
-- CHE	Chestnut Hill East Line	Chestnut Hill East Line	0
-- CHW	Chestnut Hill West Line	Chestnut Hill West Line	0
-- LAN	Lansdale/Doylestown Line	Lansdale/Doylestown Line	0
-- MED	Media/Elwyn Line	Media/Elwyn Line	0
-- FOX	Fox Chase Line	Fox Chase Line	0
