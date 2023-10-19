-- create table ridership (
--   trip_id integer primary key, 
--   trip_duration integer, 
--   start_station_id integer, 
--   start_time timestamp, 
--   start_station_name text, 
--   end_station_id integer, 
--   end_time timestamp, 
--   end_station_name text, 
--   bike_id integer, 
--   user_type text
-- );

-- create table uoft_stations (
--   station integer primary key
-- ); 

select 
    extract(year from start_time) as trip_year, 
    extract(month from start_time) as trip_month, 
    extract(hour from start_time) as "trip_hour(24hr)", 
    count(*) as trip_count_on_campus
from 
    ridership_2022 join uoft_stations on ridership_2022.end_station_id = uoft_stations.station
where 
    extract(hour from start_time) between 18 and 20
group by 
    trip_year, 
    trip_month, 
    "trip_hour(24hr)"; 


-- select extract(year from start_time) as trip_year, extract(month from start_time) as trip_month, extract(hour from start_time) as "trip_hour(24hr)", count(*) as trip_count
-- from ridership
-- where extract(hour from start_time) between 18 and 20
-- group by trip_year, trip_month, "trip_hour(24hr)"; 

select
  start_station_name,
  end_station_name,
  count(*) as trip_count
from
  ridership_2022 join uoft_stations on ridership_2022.end_station_id = uoft_stations.station
where extract(year from start_time) = 2022
group by
  start_station_name, end_station_name
order by
  trip_count desc;




