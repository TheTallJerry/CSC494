-- cleanup
delete from station_emptiness where (num_docks_avail + num_docks_disabled + num_bikes_avail + num_bikes_disabled) = 0;

-- Create a temporary table for median docks availability during morning
drop table if exists temp_median_docks_avail_morning;
create temporary table temp_median_docks_avail_morning as
select
  station_id,
  round(percentile_disc(0.5) within group (order by (num_docks_avail::numeric / (num_docks_avail + num_docks_disabled + num_bikes_avail + num_bikes_disabled))), 4) as median_docks_avail
from
  station_emptiness
where
  extract(hour from time_checked at time zone 'UTC' at time zone 'EST') >= 8
  and extract(hour from time_checked at time zone 'UTC' at time zone 'EST') < 11
group by
  station_id;

-- Create a temporary table for median bikes availability during evening
drop table if exists temp_median_bikes_avail_evening;
create temporary table temp_median_bikes_avail_evening as
select
  station_id,
  round(percentile_disc(0.5) within group (order by (num_bikes_avail::numeric / (num_docks_avail + num_docks_disabled + num_bikes_avail + num_bikes_disabled))), 4) as median_bikes_avail
from
  station_emptiness
where
  extract(hour from time_checked at time zone 'UTC' at time zone 'EST') >= 16
  and extract(hour from time_checked at time zone 'UTC' at time zone 'EST') < 19
group by
  station_id;

-- Create a table for station_id, (median_docks_avail + median_bikes_avail) / 2
drop table if exists final_median_availability;
create table final_median_availability as
select
  d.station_id,
  round((d.median_docks_avail + b.median_bikes_avail) / 2, 4) as average_median_availability
from
  temp_median_docks_avail_morning d
join
  temp_median_bikes_avail_evening b on d.station_id = b.station_id;

-- lowest overall
select * from final_median_availability
order by average_median_availability asc
limit 8;

-- lowest docks avail morning
select * from temp_median_docks_avail_morning
order by median_docks_avail asc
limit 8;

-- lowest bikes avail evening
select * from temp_median_bikes_avail_evening
order by median_bikes_avail asc
limit 8;