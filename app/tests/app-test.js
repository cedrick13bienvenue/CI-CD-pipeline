'use strict';

const { expect } = require('chai');
const request = require('supertest');
const app = require('../src/app');

describe('GET /', () => {
  it('should return 200 with a welcome message', async () => {
    const res = await request(app).get('/');
    expect(res.status).to.equal(200);
    expect(res.body).to.have.property('message', 'Hello from the CI/CD Pipeline!');
    expect(res.body).to.have.property('version');
  });
});

describe('GET /health', () => {
  it('should return 200 with healthy status', async () => {
    const res = await request(app).get('/health');
    expect(res.status).to.equal(200);
    expect(res.body).to.have.property('status', 'healthy');
    expect(res.body).to.have.property('uptime');
    expect(res.body).to.have.property('timestamp');
  });
});

describe('GET /api/items', () => {
  it('should return 200 with an array of items', async () => {
    const res = await request(app).get('/api/items');
    expect(res.status).to.equal(200);
    expect(res.body).to.have.property('count');
    expect(res.body.items).to.be.an('array');
    expect(res.body.items).to.have.lengthOf(res.body.count);
  });

  it('each item should have id and name fields', async () => {
    const res = await request(app).get('/api/items');
    res.body.items.forEach((item) => {
      expect(item).to.have.property('id');
      expect(item).to.have.property('name');
    });
  });
});

describe('GET /undefined-route', () => {
  it('should return 404 for unknown routes', async () => {
    const res = await request(app).get('/undefined-route');
    expect(res.status).to.equal(404);
    expect(res.body).to.have.property('error', 'Route not found');
  });
});
