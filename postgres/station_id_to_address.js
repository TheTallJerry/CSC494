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
    const fetchQuery =
      "select * from final_median_availability order by average_median_availability asc"; // Fetch all data from final_median_availability table
    const { rows } = await dockerDbClient.query(fetchQuery);

    fs.readFile("utils/station_information.json", "utf8", (err, data) => {
      if (err) {
        console.error(err);
        return;
      }

      jsonData = JSON.parse(data);
    //   console.log(rows);
      filtered_stations = [];

      let filteredStations = rows
        .filter((row) =>
          jsonData.data.stations.some(
            (station) => station.station_id == row.station_id
          )
        )
        .map((row) => {
          let matchingStation = jsonData.data.stations.find(
            (station) => station.station_id == row.station_id
          );
          return {
            station_id: row.station_id,
            average_median_availability: parseFloat(
              row.average_median_availability
            ),
            lat: matchingStation.lat,
            lon: matchingStation.lon,
            name: matchingStation.name,
          };
        });
      fs.writeFile(
        "postgres/uoft_unavail_stations.json",
        JSON.stringify(filteredStations),
        (err) => {
          if (err) {
            console.error(err);
            return;
          }
        }
      );
      console.log(`Wrote ${filteredStations.length} to file`)
    });
  } catch (error) {
    console.error("Error:", error);
  } finally {
    await dockerDbClient.end();
  }
}

copyData();
