const { Client } = require("pg");
require("dotenv").config();

const cloudDbClient = new Client({
  connectionString: `postgres://${process.env.CLOUD_PSQL_USERNAME}:${process.env.CLOUD_PSQL_PASSWORD}@suleiman.db.elephantsql.com/${process.env.CLOUD_PSQL_USERNAME}`
});

const dockerDbClient = new Client({
  user: "postgres",
  host: "postgres-db",
  database: "mucp",
  password: "password",
  port: 5432,
});

async function copyData() {
  try {
    await cloudDbClient.connect();
    await dockerDbClient.connect();

    // Fetch data from the cloud database
    const fetchQuery = "SELECT * FROM station_emptiness"; // Fetch all data from station_emptiness table
    const { rows } = await cloudDbClient.query(fetchQuery);

    // Insert fetched data into the docker database
    for (let i = 0; i < rows.length; i++) {
      const rowData = [
        rows[i].station_id,
        rows[i].time_checked,
        rows[i].num_bikes_avail,
        rows[i].num_bikes_disabled,
        rows[i].num_docks_avail,
        rows[i].num_docks_disabled,
        rows[i].station_status
      ];

      const insertQuery = `
        INSERT INTO station_emptiness
        (station_id, time_checked, num_bikes_avail, num_bikes_disabled, num_docks_avail, num_docks_disabled, station_status)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
      `;

      await dockerDbClient.query(insertQuery, rowData);
    }

    console.log("Data copied successfully!");
  } catch (error) {
    console.error("Error:", error);
  } finally {
    await cloudDbClient.end();
    await dockerDbClient.end();
  }
}

copyData();
