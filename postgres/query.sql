-- distribution of num_bikes_avail
-- select 
--     station_id, 
--     num_bikes_avail,
--     count(num_bikes_avail)
-- from station_emptiness
-- where 
--     extract(hour from time_checked at time zone 'UTC' at time zone 'EST') >= 8 and 
--     extract(hour from time_checked at time zone 'UTC' at time zone 'EST') < 11 and 
--     extract(day from time_checked at time zone 'UTC' at time zone 'EST') > 19 and 
--     extract(day from time_checked at time zone 'UTC' at time zone 'EST') < 25
-- group by station_id, num_bikes_avail
-- order by station_id, num_bikes_avail; 

-- avg docks avail during morning
-- select 
--     station_id, 
--     round(avg(num_docks_avail), 3) as average_docks_avail
-- from station_emptiness
-- where 
--     extract(hour from time_checked at time zone 'UTC' at time zone 'EST') >= 8 and 
--     extract(hour from time_checked at time zone 'UTC' at time zone 'EST') < 11 and 
--     extract(day from time_checked at time zone 'UTC' at time zone 'EST') > 19 and 
--     extract(day from time_checked at time zone 'UTC' at time zone 'EST') < 25
-- group by station_id
-- order by average_docks_avail desc; 

-- median bikes avail during evening
drop table if exists median_bikes_avail;
create table median_bikes_avail as
select 
    station_id, 
    percentile_disc(0.5) within group(order by num_bikes_avail) as median_bikes_avail, 
    num_bikes_avail + num_bikes_disabled + num_docks_avail + num_docks_disabled as total_spots
from station_emptiness
where 
    extract(hour from time_checked at time zone 'UTC' at time zone 'EST') >= 16 and 
    extract(hour from time_checked at time zone 'UTC' at time zone 'EST') < 19 and 
    extract(day from time_checked at time zone 'UTC' at time zone 'EST') > 19 and 
    extract(day from time_checked at time zone 'UTC' at time zone 'EST') < 25
group by station_id, total_spots
order by median_bikes_avail desc; 

select station_id, round(median_bikes_avail / total_spots::numeric, 2) as median
from median_bikes_avail;

-- avg station emptiness during morning
-- select 
--     station_id, 
--     round(avg(num_docks_avail / (num_bikes_avail + num_bikes_disabled + num_docks_avail + num_docks_disabled)), 6) as average_emptiness
-- from station_emptiness
-- where 
--     extract(hour from time_checked at time zone 'UTC' at time zone 'EST') >= 8 and 
--     extract(hour from time_checked at time zone 'UTC' at time zone 'EST') < 11 and 
--     extract(day from time_checked at time zone 'UTC' at time zone 'EST') > 19 and 
--     extract(day from time_checked at time zone 'UTC' at time zone 'EST') < 25
-- group by station_id
-- order by average_emptiness desc; 

-- avg station accessibility during evening
-- select 
--     station_id, 
--     round(avg(num_bikes_avail / (num_bikes_avail + num_bikes_disabled + num_docks_avail + num_docks_disabled)), 6) as average_accessibility
-- from station_emptiness
-- where 
--     extract(hour from time_checked at time zone 'UTC' at time zone 'EST') >= 16 and 
--     extract(hour from time_checked at time zone 'UTC' at time zone 'EST') < 19 and 
--     extract(day from time_checked at time zone 'UTC' at time zone 'EST') > 19 and 
--     extract(day from time_checked at time zone 'UTC' at time zone 'EST') < 25
-- group by station_id
-- order by average_accessibility desc; 
