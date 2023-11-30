const { Client } = require("pg");
const fs = require("fs");
require("dotenv").config();

var dbClient;
if (process.argv.length < 3) {
  console.error(
    'No argument provided. Please specify either "cloud" or "docker".'
  );
  process.exit(1);
} else {
  const arg = process.argv[2];
  if (arg === "cloud") {
    dbClient = new Client(
      `postgres://${process.env.CLOUD_PSQL_USERNAME}:${process.env.CLOUD_PSQL_PASSWORD}@suleiman.db.elephantsql.com/${process.env.CLOUD_PSQL_USERNAME}`
    );
  } else if (arg === "docker") {
    dbClient = new Client({
      user: "postgres",
      host: "postgres-db",
      database: "mucp",
      password: "password",
      port: "5432",
    });
  } else {
    console.error(
      'Invalid argument. Please specify either "cloud" or "docker".'
    );
    process.exit(1);
  }
}

const apiUrl = "https://tor.publicbikesystem.net/ube/gbfs/v1/en/station_status";
var uoftBikeStations = new Set([
  7002, 7008, 7023, 7058, 7063, 7066, 7078, 7155, 7170, 7190, 7191, 7195, 7250,
  7252, 7273, 7274, 7285, 7335, 7358, 7457, 7600, 7667, 7762,
]);

// [
//   "station_id",
//   "time_checked",
//   "num_bikes_avail",
//   "num_bikes_disabled",
//   "num_docks_avail",
//   "num_docks_disabled",
//   "station_status",
// ]
const csvArray = [];
var csvData = "";
var lastUpdated = "";
async function fetchDataAndInsert() {
  try {
    // Connect to the PostgreSQL database
    await dbClient.connect();
    console.log("Connected to PostgreSQL");

    // Fetch data from the API
    const res = await fetch(apiUrl);
    console.log("Fetched data from endpoint");
    if (res.ok) {
      const data = await res.json();
      lastUpdated = data.last_updated;

      // Filter out uoft stations
      const uoftStationsData = data.data.stations.filter((station) =>
        uoftBikeStations.has(Number(station.station_id))
      );

      // Load data into the PostgreSQL database
      // and save data into csv file
      for (const station of uoftStationsData) {
        var dataArr = [
          Number(station.station_id),
          lastUpdated,
          station.num_bikes_available,
          station.num_bikes_disabled,
          station.num_docks_available,
          station.num_docks_disabled,
          station.status,
        ];
        await dbClient.query(
          "insert into station_emptiness (station_id, time_checked, num_bikes_avail, num_docks_avail, num_bikes_disabled, num_docks_disabled, station_status) values ($1, to_timestamp($2), $3, $4, $5, $6, $7)",
          dataArr
        );
        console.log(`Inserted ${station.station_id} into the database`);
        csvArray.push(dataArr);
      }
    } else {
      console.error("Failed to fetch data from the API");
    }
  } catch (error) {
    console.error("Error:", error);
  } finally {
    // Ensure the database connection is closed
    await dbClient.end();
    console.log("Connection closed");
    // Create CSV file
    for (const row of csvArray) {
      csvData += row.join(",") + "\n";
    }
    fs.writeFileSync(`${lastUpdated}.csv`, csvData);
    console.log(`Created ${lastUpdated}.csv`);
  }
}

fetchDataAndInsert();
