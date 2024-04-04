const fs = require('fs');

const jsonData = fs.readFileSync('postgres/uoft_unavail_stations.json', 'utf8');
const stations = JSON.parse(jsonData);

function preprocessStreetName(name) {
    return name.replace(' - SMART', '');
}

const streetScores = {};
stations.forEach(station => {
    const streets = preprocessStreetName(station.name).split(' / ');
    const score = station.average_median_availability;
    streets.forEach(street => {
        if (!streetScores[street]) {
            streetScores[street] = {
                totalScore: score,
                count: 1
            };
        } else {
            streetScores[street].totalScore += score;
            streetScores[street].count++;
        }
    });
});

const streetAverages = {};
for (const street in streetScores) {
    streetAverages[street] = parseFloat((streetScores[street].totalScore / streetScores[street].count).toFixed(4));
}

const sortedStreets = Object.entries(streetAverages)
    .sort((a, b) => a[1] - b[1])
    .reduce((sortedObj, [street, score]) => {
        sortedObj[street] = score;
        return sortedObj;
    }, {});

const resultJson = JSON.stringify(sortedStreets, null, 2);
const outputFile = "postgres/street_averages.json"
fs.writeFileSync(outputFile, resultJson);

console.log(`Average scores for each street calculated and written to ${outputFile}`);
