const express = require("express");
const axios = require('axios');
const app = express();
const port = process.env.PORT || 3000;

const options = {
    url: 'https://jsonplaceholder.typicode.com/posts',
    method: 'GET',
    headers: {
        'Accept': 'application/json',
        'Accept-Charset': 'utf-8',
        'User-Agent': 'my-reddit-client'
    }
};

app.get("/", (req, res) => {
    res.send("Welcome to Inchcape Digital Technical Test");
});

app.get("/api", async (req, res) => {
    try {
        const response = await axios.get(options.url, { headers: options.headers });
        res.json(response.data);
    } catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).send('Error fetching data');
    }
});

app.listen(port, () => {
    console.log(`My API is running on port ${port}...`);
});

module.exports = app;
