const axios = require('axios');

test('GET /posts', async () => {
  const response = await axios.get('http://localhost:3000/posts');
  expect(response.status).toBe(200);
  expect(response.data).toBeDefined();
  expect(Array.isArray(response.data)).toBe(true);
});

