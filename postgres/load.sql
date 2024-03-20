drop table if exists station_accessibility, station_averages;

create table station_accessibility (
    station_name varchar(100),
    average_accessibility numeric
);

\copy station_accessibility from 'uoft_unavail_stations.csv' delimiter ',' csv header;

update station_accessibility
set average_accessibility = round(average_accessibility, 4);

-- Create the table
create table station_averages (
    station_group varchar(50),
    average_accessibility numeric
);

-- Insert data for stations containing specified keywords
insert into station_averages (station_group, average_accessibility)
select 
    case 
        when lower(station_name) like '%st. george%' then 'St. George'
        when lower(station_name) like '%huron%' then 'Huron'
        when lower(station_name) like '%bay%' then 'Bay'
        when lower(station_name) like '%bathurst%' then 'Bathurst'
        when lower(station_name) like '%queen''s park%' then 'Queen''s Park'
        when lower(station_name) like '%spadina%' then 'Spadina'
    end as station_group,
    avg(average_accessibility) as average_accessibility
from 
    station_accessibility
where 
    lower(station_name) like any(array['%st. george%', '%huron%', '%bay%', '%bathurst%', '%queen''s park%', '%spadina%'])
group by 
    case 
        when lower(station_name) like '%st. george%' then 'St. George'
        when lower(station_name) like '%huron%' then 'Huron'
        when lower(station_name) like '%bay%' then 'Bay'
        when lower(station_name) like '%bathurst%' then 'Bathurst'
        when lower(station_name) like '%queen''s park%' then 'Queen''s Park'
        when lower(station_name) like '%spadina%' then 'Spadina'
    end;


select station_group as "Street", round(average_accessibility, 4) as "Accessibility" from station_averages
where average_accessibility > 0.1
order by average_accessibility asc;