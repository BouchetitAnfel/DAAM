const express = require('express');
const path = require('path');
const logger = require('morgan');
const cors = require('cors');
const session = require('express-session');

const app = express();

var app = require('../app');
var debug = require('debug')('projet:server');
var http = require('http');
// Middleware
app.use(cors());
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use('/uploads', express.static(path.join(__dirname, 'public/uploads'))); // For profile pictures
app.use('/api/auth', require('./routes/auth'));
app.use('/api/products', require('./routes/products'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/users', require('./routes/users'));
// Session setup (Exercise 08)
app.use(session({
  secret: 'pharma_secret_key_2026',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false } // Set to true once HTTPS/SSL is enabled in Exercise 08
}));

// Test route to verify server + DB connection
const db = require('./config/db');
app.get('/api/test', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT 1 + 1 AS result');
    res.json({ message: 'Backend & XAMPP MySQL connected!', dbTest: rows[0].result });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Your TP routes will go here:
// app.use('/api/auth', require('./routes/auth'));
// app.use('/api/products', require('./routes/products'));
// app.use('/api/orders', require('./routes/orders'));

module.exports = app;
var server = http.createServer(app);