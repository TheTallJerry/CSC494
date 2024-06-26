# CSC494

## Disclaimer

The endpoints being queried in this project, as well as any usages of the data collected, commercial or otherwise, have been permitted as per City of Toronto's open data license at https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-licence/

## Overview

The project currently has 3 workflows, as illustrated under `.github/workflows`:

1. `cut_branch.yml`: This workflow cuts a daily branch where the data collection will occur.
2. `fetch_data.yml`: This workflow queries data about uoft bike stations and saves them into 2 places: a Postgres database on the cloud - currently on ElephantSQL - and as individual CSV files which are pushed onto the daily branch.
3. `clean_csv.yml`: This workflow collects the above individual CSV files on a daily basis, combines them into a single CSV named as `combined_daily_branch_${date_in_EST}` and removes the individual files afterwards, then pushes the combined CSV file onto the daily branch, then merges the daily branch into main and deletes the daily branch afterwards. The combined CSV is saved under `/collected_data`.

`cut_branch.yml` is run on 04:23. `fetch_data.yml` is run with a 5 minute segment, between minutes 10-59, on hours 08:00 to 10:00 and 16:00 to 18:00. `clean_csv.yml` is run on 22:17. All times here are in EST - GitHub Actions currently only accepts UTC for their CRON, so the times in the actual workflow files are in UTC.

## Development

Simple docker app with a NodeJS container and a PostgreSQL container. Use VSCode with dev containers and docker plugin. Recommend Rainbow CSV for highlighting csv files.

To start development, run `docker compose build nodejs-app` then `docker compose up -d`.

### NodeJS

1. Attach to the Node container
2. Open the `/app` folder
3. The image has `npm` and `node` installed, so you can just run for instance `node index.js`

### PostgreSQL

1. Attach to the PostgreSQL container
2. Open the `/mucp` folder (TBD: Better starter location?)
3. Currently this folder contains everything, including ridership data of all 12 months in 2022 and the first 3 months of 2023; `load.sql` for loading the csv files into Postgres and cleaning the resulting table(s), and `query.sql` to query the tables for analysis. `load.sql` is automatically run on container start up.
4. `cd` into `mucp`.
5. Run `psql -U postgres` to start the `psql` console.
6. Run `\c mucp` to connect to the `mucp` database (can skip if don't care about organization)
7. Run `\i [sql file]` to execute a `.sql` file.

**Note**: `git` is currently not loaded in this container, but shouldn't be a problem as all the setup are ready.

### Connecting NodeJS to PostgreSQL

Because the containers already live under the same network (as it is by default), connecting the two just requires the correct configuration. In our case, it'll be

```js
const client = new Client({
  user: "postgres",
  host: "postgres-db",
  database: "mucp",
  password: "password",
  port: "5432",
});
```

with `Client` being imported from `pg`.

If you'd like to connect to the ElephantSQL database instead, the configs are in project secrets, and you can also ask Jerry.
