# CSC494

Simple docker app with a NodeJS container and a PostgreSQL container. Use VSCode with dev containers and docker plugin. Recommend Rainbow CSV for highlighting csv files. 

To start development, run `docker compose build nodejs-app` then `docker compose up --force-recreate -d` (detached so you don't lose your current terminal). 

## NodeJS

1. Attach to the Node container
2. Open the `/app` folder
3. The image has `npm` and `node` installed, so you can just run for instance `node index.js`

## PostgreSQL

1. Attach to the PostgreSQL container
2. Open the `/mucp` folder (TBD: Better starter location?)
3. Currently this folder contains everything, including ridership data of all 12 months in 2022 and the first 3 months of 2023; `load.sql` for loading the csv files into Postgres and cleaning the resulting table(s), and `query.sql` to query the tables for analysis. `load.sql` is automatically run on container startup.
4. `cd` into `mucp`. 
5. Run `psql -U postgres` to start the `psql` console. 
6. Run `\c mucp` to connect to the `mucp` database (can skip if don't care about organization)
7. Run `\i [sql file]` to execute a `.sql` file. 

**Note**: `git` is currently not loaded in this container, but shouldn't be a problem as all the setup are ready. 

## Connect NodeJS to Postgresql

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

If you'd like to connect to the elephantSQL database instead, the configs are in project secrets, and you can also ask Jerry. 
