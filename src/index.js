const express = require('express');
const axios = require('axios');

const app = express();
const port = process.env.PORT || 3000;

app.get('/posts', async (req, res) => {
    try {
        const { data } = await axios.get('https://jsonplaceholder.typicode.com/posts');
        res.json(data);
    } catch (error) {
        res.status(500).send('Error fetching posts');
    }
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});

