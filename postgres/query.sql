select 
    extract(day from time_checked at time zone 'UTC' at time zone 'EST') as "day", 
    extract(hour from time_checked at time zone 'UTC' at time zone 'EST') as "hour", 
    count(station_id)
from station_emptiness
group by 
    extract(day from time_checked at time zone 'UTC' at time zone 'EST'), 
    extract(hour from time_checked at time zone 'UTC' at time zone 'EST')
order by 
    extract(day from time_checked at time zone 'UTC' at time zone 'EST'), 
    extract(hour from time_checked at time zone 'UTC' at time zone 'EST');

-- select extract(hour from timezone('UTC', time_checked)), count(extract(hour from timezone('UTC', time_checked)))
-- from station_emptiness
-- group by extract(hour from timezone('UTC', time_checked))
-- order by extract(hour from timezone('UTC', time_checked))
-- limit 100; 





