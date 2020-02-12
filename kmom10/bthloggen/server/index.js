const express = require('express');
const app = express();
const port = 1337;

const jsonLog = require('./data/log.json');

const searchTerms = ["ip", "day", "month", "time", "url"];

app.set('json spaces', 4);

// Adding result to array
function addResult(arr, index) {
    arr.push(
        {
            ip: jsonLog[index].ip,
            day: jsonLog[index].day,
            month: jsonLog[index].month,
            time: jsonLog[index].time,
            url: jsonLog[index].url
        });
}

// Returns false if not all properties in given Array
// matches in current element (index)
function checkAllTrue(propArray, index) {
    let result = true;

    Object.keys(propArray).forEach(function(prop) {
        if (checkProp(prop, propArray[prop], index)) {
            result = false;
        }
    });
    return result;
}

// Check which the current prop is
// Compare the props differently depending on type.
function checkProp(prop, value, index) {
    switch (prop) {
        case 'time': {
            let timeLength = value.length;
            let end = timeLength + 1;

            return !jsonLog[index][prop].substring(0, end).includes(value);
        }
        case "day":
        case "month": {
            return value !== jsonLog[index][prop];
        }
        case "ip":
        case "url": {
            return !jsonLog[index][prop].includes(value);
        }
    }
}

const routeList =
[
    {
        route: "/",
        result: "Visa en lista av de routes som stöds."

    },
    {
        route: "/data",
        result: "Visa samtliga rader."
    },
    {
        route: "/data?ip=<ip>",
        result: "Visa raderna som innehåller <ip>."
    },
    {
        route: "/data?url=<url>",
        result: "Visa raderna som innehåller <url>."
    },
    {
        route: "/data?month=<month>",
        result: "Visa raderna från månaden <month>."
    },
    {
        route: "/data?day=<day>",
        result: "Visa raderna från dagen <day>."
    },
    {
        route: "/data?day=<time>",
        result: "Visa raderna från tiden <time>."
    },
    {
        route: "/data?day=<day>&time=<time>",
        result: "Visa raderna från tiden <time> på dagen <day>."
    },
    {
        route: "/data?month=<month>&day=<day>&time=<time>",
        result: "Visa raderna från tiden <time> på dagen <day> och månaden <month>."
    }
];

app.get('/', (req, res) => {
    return res.json(routeList);
});

app.get('/data', (req, res) => {
    let jsonObject = [];
    let propArray = [];

    if (req.query) {
        for (var prop in req.query) {
            if (searchTerms.includes(prop)) {
                propArray[prop] = req.query[prop];
            }
        }
        for (var i = 0; i < jsonLog.length; i++) {
            if (checkAllTrue(propArray, i)) {
                addResult(jsonObject, i);
            }
        }
        res.json(jsonObject);
    } else {
        res.json(jsonLog);
    }
});

app.listen(port, () => console.log(`Server listening on port ${port}!`));
