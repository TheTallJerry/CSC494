const { Client } = require("pg");
const fs = require("fs");
require("dotenv").config();

const dockerDbClient = new Client({
  user: "postgres",
  host: "postgres-db",
  database: "mucp",
  password: "password",
  port: 5432,
});

async function copyData() {
  try {
    await dockerDbClient.connect();

    // Fetch data from the docker database
    const querySQLFile = fs.readFileSync("./postgres/query.sql", "utf-8");
    await dockerDbClient.query(querySQLFile);
    const fetchQuery = "SELECT station_id FROM final_median_availability"; // Fetch all data from final_median_availability table
    const { rows } = await dockerDbClient.query(fetchQuery);

    fs.readFile("utils/station_information.json", "utf8", (err, data) => {
      if (err) {
        console.error(err);
        return;
      }

      jsonData = JSON.parse(data);
      console.log(rows);
      rows.forEach((row, i) => {
        rows[i] = rows[i].station_id;
      });
      uoftBikeStationsLocations = [];
      uoftBikeStationsRelevant = jsonData.data.stations.filter((station) =>
        rows.includes(Number(station.station_id))
      );
      uoftBikeStationsRelevant.forEach((station) => {
        uoftBikeStationsLocations.push({
          [station.station_id]: {
            lat: station.lat,
            lon: station.lon,
            name: station.name,
          },
        });
      });
      fs.writeFile(
        "postgres/uoft_unavail_stations.json",
        JSON.stringify(uoftBikeStationsLocations),
        (err) => {
          if (err) {
            console.error(err);
            return;
          }
        }
      );
    });
  } catch (error) {
    console.error("Error:", error);
  } finally {
    await dockerDbClient.end();
  }
}

copyData();
