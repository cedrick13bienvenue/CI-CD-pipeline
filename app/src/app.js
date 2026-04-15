'use strict';

const express = require('express');

const app = express();

app.use(express.json());

// Root route — basic identity response
app.get('/', (_req, res) => {
  res.status(200).json({
    message: 'Hello from the CI/CD Pipeline!',
    version: process.env.APP_VERSION || '1.0.0',
  });
});

// Health check — used by load balancers and monitoring tools
app.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

// Sample API endpoint
app.get('/api/items', (_req, res) => {
  const items = [
    { id: 1, name: 'Pipeline Stage: Checkout' },
    { id: 2, name: 'Pipeline Stage: Build' },
    { id: 3, name: 'Pipeline Stage: Test' },
    { id: 4, name: 'Pipeline Stage: Docker Build' },
    { id: 5, name: 'Pipeline Stage: Push Image' },
    { id: 6, name: 'Pipeline Stage: Deploy' },
  ];
  res.status(200).json({ count: items.length, items });
});

// 404 handler for undefined routes
app.use((_req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

module.exports = app;
