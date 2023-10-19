-- Create table
drop table if exists uoft_stations, ridership_2023, ridership_2022, station_emptiness;
create table ridership_2023 (
  trip_id integer primary key, 
  trip_duration integer, 
  start_station_id_temp text, 
  start_time_temp text, 
  start_station_name text, 
  end_station_id_temp text, 
  end_time_temp text, 
  end_station_name text, 
  bike_id integer, 
  user_type text
);

create table ridership_2022 (
  trip_id integer primary key, 
  trip_duration integer, 
  start_station_id_temp text, 
  start_time_temp text, 
  start_station_name text, 
  end_station_id_temp text, 
  end_time_temp text, 
  end_station_name text, 
  bike_id integer, 
  user_type text
);

create table uoft_stations (
  station_id integer primary key
); 

create table station_emptiness (
  station_id integer, 
  time_checked timestamp,
  num_bikes_avail integer not null, 
  num_bikes_disabled integer not null, 
  num_docks_avail integer not null, 
  num_docks_disabled integer not null, 
  station_status text not null,  
  primary key (station_id, time_checked)
);

-- trips made to and from uoft stations during morning and afternoon (rush hours) and how fall compares to winter (how much winter impacts bike usage)
-- Copy data from the CSV file into riderships, uoft_stations
\copy ridership_2023 from '2023-01.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2023 from '2023-02.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2023 from '2023-03.csv' with CSV HEADER DELIMITER ',';

\copy ridership_2022 from '2022-01.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-02.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-03.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-04.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-05.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-06.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-07.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-08.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-09.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-10.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-11.csv' with CSV HEADER DELIMITER ',';
\copy ridership_2022 from '2022-12.csv' with CSV HEADER DELIMITER ',';

\copy uoft_stations from 'data.csv' with CSV HEADER DELIMITER ',';

-- Data cleaning
do $$ 
declare
  table_n text;
begin
  for table_n in 
    select table_name from information_schema.tables where table_name like 'ridership%'
  loop
    -- Delete rows with NULL values
    execute 'delete from ' || table_n ||
            ' where start_station_name = ''NULL'' or end_station_name = ''NULL'' or start_station_id_temp = ''NULL'' or end_station_id_temp = ''NULL''';

    -- Add columns
    execute 'alter table ' || table_n || ' add column start_time timestamp, add column end_time timestamp, add column start_station_id integer, add column end_station_id integer';

    -- Update columns
    execute 'update ' || table_n ||
            ' set start_time = to_timestamp(start_time_temp, ''MM/DD/YYYY HH24:MI''),' ||
            ' end_time = to_timestamp(end_time_temp, ''MM/DD/YYYY HH24:MI''),' ||
            ' start_station_id = cast(start_station_id_temp as integer),' ||
            ' end_station_id = cast(end_station_id_temp as integer)';

    -- Drop old columns
    execute 'alter table ' || table_n ||
            ' drop column start_time_temp, drop column end_time_temp,' ||
            ' drop column start_station_id_temp, drop column end_station_id_temp';
  end loop;
end $$;

-- Display some data for verification
select trip_id, start_time, start_station_name, end_time, end_station_name from ridership_2022 limit 20; 