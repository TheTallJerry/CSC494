// To be run for local dev
const { Client } = require("pg");

const apiUrl = "https://tor.publicbikesystem.net/ube/gbfs/v1/en/station_status";
var uoftBikeStations = new Set([
  7002, 7008, 7023, 7058, 7063, 7066, 7078, 7155, 7170, 7190, 7191, 7195, 7250,
  7252, 7273, 7274, 7285, 7335, 7358, 7457, 7600, 7667, 7762,
]);

const client = new Client({
  user: "postgres",
  host: "postgres-db",
  database: "mucp",
  password: "password",
  port: "5432",
});
var lastUpdated = "";
async function fetchDataAndInsert() {
  try {
    // Connect to the PostgreSQL database
    await client.connect();
    console.log("Connected to PostgreSQL");

    // Fetch data from the API
    const res = await fetch(apiUrl);
    console.log("Fetched data from endpoint")
    if (res.ok) {
      const data = await res.json();
      lastUpdated = data.last_updated;
      
      // Filter out uoft stations
      const uoftStationsData = data.data.stations.filter((station) =>
        uoftBikeStations.has(Number(station.station_id))
      );

      // Load data into the PostgreSQL database
      for (const station of uoftStationsData) {
        await client.query(
          "insert into station_emptiness (station_id, time_checked, num_bikes_avail, num_docks_avail, num_bikes_disabled, num_docks_disabled, station_status) values ($1, to_timestamp($2), $3, $4, $5, $6, $7)",
          [
            Number(station.station_id),
            lastUpdated / 1000.0, 
            station.num_bikes_available,
            station.num_bikes_disabled, 
            station.num_docks_available,
            station.num_docks_disabled, 
            station.status, 
          ]
        );
        console.log(`Inserted ${station.station_id} into the database`);
      }
    } else {
      console.error("Failed to fetch data from the API");
    }
  } catch (error) {
    console.error("Error:", error);
  } finally {
    // Ensure the database connection is closed
    await client.end();
    console.log("Connection closed");
  }
}

// Call the fetchDataAndInsert function to start the process
fetchDataAndInsert();