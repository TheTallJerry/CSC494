// To be run by github actions
const fs = require("fs");
const apiUrl = "https://tor.publicbikesystem.net/ube/gbfs/v1/en/station_status";

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
const uoftBikeStations = new Set([
  7002, 7008, 7023, 7058, 7063, 7066, 7078, 7155, 7170, 7190, 7191, 7195, 7250,
  7252, 7273, 7274, 7285, 7335, 7358, 7457, 7600, 7667, 7762,
]);
async function fetchDataAndPush() {
  try {
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

      // Load data into csv array
      for (const station of uoftStationsData) {
        csvArray.push([
          Number(station.station_id),
          lastUpdated / 1000.0,
          station.num_bikes_available,
          station.num_bikes_disabled,
          station.num_docks_available,
          station.num_docks_disabled,
          station.status,
        ]);
      }
    } else {
      console.error("Failed to fetch data from the API");
    }
  } catch (error) {
    console.error("Error:", error);
  } finally {
    for (const row of csvArray) {
      csvData += row.join(",") + "\n";
    }
    fs.writeFileSync(`${lastUpdated}.csv`, csvData);
  }
}

fetchDataAndPush();
