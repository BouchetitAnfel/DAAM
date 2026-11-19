const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config/jwt');
// Verify token (for any logged-in user)
function verifyToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Expects "Bearer <token>"

    if (!token) {
        return res.status(401).json({ error: 'Access denied. No token provided.' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded; // { id, role }
        next();
    } catch (err) {
        res.status(403).json({ error: 'Invalid or expired token.' });
    }
}

// Verify Pharmacist role (for Exercise 02)
function isPharmacist(req, res, next) {
    if (req.user.role !== 'pharmacist') {
        return res.status(403).json({ error: 'Access denied. Pharmacists only.' });
    }
    next();
}

module.exports = { verifyToken, isPharmacist };