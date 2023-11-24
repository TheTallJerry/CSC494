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
drop table if exists station_stats;
create table station_stats as
-- (select 
--   station_id,
--   date_trunc('day', time_checked) as date,
--   round(avg(
--       num_bikes_avail /
--       nullif(num_docks_avail + num_bikes_avail + num_docks_disabled + num_bikes_disabled, 0)
--   ), 2) as avg_emptiness
-- from 
--   station_emptiness
-- where 
--   extract(hour from time_checked) = 13
--   and extract(minute from time_checked) >= 10
--   and extract(minute from time_checked) <= 59
-- group by 
--   station_id, date
-- );
select 
    to_char(date_trunc('hour', time_checked at time zone 'GMT' at time zone 'EST') +
    (((extract(minute from time_checked at time zone 'GMT' at time zone 'EST'))::int / 30)::int * interval '30 minutes'), 'HH24:MI') as interval_start_time,
    count(station_id) as station_count
from 
    station_emptiness
where 
    (extract(hour from time_checked at time zone 'GMT' at time zone 'EST') >= 8
    and extract(hour from time_checked at time zone 'GMT' at time zone 'EST') < 12)
    or
    (extract(hour from time_checked at time zone 'GMT' at time zone 'EST') >= 18
    and extract(hour from time_checked at time zone 'GMT' at time zone 'EST') < 20)
group by 
    interval_start_time
order by 
    interval_start_time;

select * from station_stats;

-- select 
--   date(time_checked) as utc_date,
--   count(date(time_checked)) as count
-- from 
--   station_emptiness
-- group by
--   date(time_checked);
-- order by
--   date(time_checked);






