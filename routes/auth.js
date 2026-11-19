const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const dbModule = require('../config/db');

// works whether config/db.js exports a normal pool or a promise pool
const db = typeof dbModule.promise === 'function' ? dbModule.promise() : dbModule;

// IMPORTANT: must be the SAME secret used in middleware/auth.js
const JWT_SECRET = process.env.JWT_SECRET || 'CHANGE_ME_same_as_middleware';

const router = express.Router();

function makeToken(user) {
    return jwt.sign(
        { id: user.id, name: user.name, role: user.role },
        JWT_SECRET,
        { expiresIn: '2h' }
    );
}

// POST /api/auth/register
router.post('/register', async (req, res) => {
    try {
        const { name, email, password, role } = req.body || {};
        if (!name || !email || !password) {
            return res.status(400).json({ message: 'Name, email and password are required.' });
        }
        const userRole = role === 'pharmacist' ? 'pharmacist' : 'client';

        const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(409).json({ message: 'Email already registered.' });
        }

        const hash = await bcrypt.hash(password, 10);
        const [result] = await db.query(
            'INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)',
            [name, email, hash, userRole]
        );

        const user = { id: result.insertId, name, role: userRole };
        res.status(201).json({ ...user, token: makeToken(user) });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error.' });
    }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body || {};
        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required.' });
        }

        const [rows] = await db.query(
            'SELECT id, name, role, password_hash FROM users WHERE email = ?',
            [email]
        );
        if (rows.length === 0) {
            return res.status(401).json({ message: 'Invalid email or password.' });
        }

        const u = rows[0];
        const ok = await bcrypt.compare(password, u.password_hash);
        if (!ok) {
            return res.status(401).json({ message: 'Invalid email or password.' });
        }

        const user = { id: u.id, name: u.name, role: u.role };
        res.json({ ...user, token: makeToken(user) });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error.' });
    }
});

// POST /api/auth/logout  (stateless JWT: the client deletes the token)
router.post('/logout', (req, res) => {
    res.json({ message: 'Logged out successfully.' });
});

module.exports = router;