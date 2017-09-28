
-- CHE    Chestnut Hill East Line    to Center City Philadelphia    1
-- CHE    Chestnut Hill East Line    to Chestnut Hill East    0
-- CHW    Chestnut Hill West Line    to Center City Philadelphia    0
-- CHW    Chestnut Hill West Line    to Chestnut Hill West    1
-- LAN    Lansdale/Doylestown Line    to Center City Philadelphia    1
-- LAN    Lansdale/Doylestown Line    to Doylestown    0
-- MED    Media/Elwyn Line    to Center City Philadelphia    0
-- MED    Media/Elwyn Line    to Elwyn    1
-- FOX    Fox Chase Line    to Center City Philadelphia    1
-- FOX    Fox Chase Line    to Fox Chase    0


SELECT
R.Route_id,
R.route_short_name route_short_name,
B.terminus_name route_long_name,
cast (B.direction_id  as TEXT )                            dircode

FROM routes_rail R

join routes_rail_boundaries B on R.route_id = b.route_id
;
