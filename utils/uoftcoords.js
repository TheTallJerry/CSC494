const polygon = require("polygon");
const fs = require("fs");
const Vec2 = require("vec2");
const GeoJSON = require("geojson");

// Graphed with Google Earth
const uoftLatiLong = [
  // college / bay
  [43.66081506329436, -79.38585416461086],
  // bloor / bay
  [43.66975282777428, -79.3894591776988],
  // bloor / bathurst
  [43.66512013466625, -79.41120947380301],
  // college / bathurst
  [43.65643797773195, -79.40779103895261],
];

const p = new polygon(uoftLatiLong.map((points) => Vec2(points[0], points[1])));

fs.readFile("station_information.json", "utf8", (err, data) => {
  if (err) {
    console.error(err);
    return;
  }

  jsonData = JSON.parse(data);
  uoftBikeStations = jsonData.data.stations
    .filter((station) => p.containsPoint(Vec2(station.lat, station.lon)))
    .map((station) => ({
      name: station.name,
      lon: station.lon,
      lat: station.lat,
    }));
  console.log(uoftBikeStations);

  fs.writeFile(
    "./stations/out.geojson",
    JSON.stringify(GeoJSON.parse(uoftBikeStations, { Point: ["lat", "lon"] })),
    (err) => {}
  );
});
