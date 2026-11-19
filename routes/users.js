const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const multer = require('multer');
const path = require('path');
const db = require('../config/db');
const { verifyToken } = require('../middleware/auth');

// Configure Multer for profile picture uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'public/uploads/'),
  filename: (req, file, cb) => {
    const uniqueName = `user_${req.user.id}_${Date.now()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});
const upload = multer({ storage });

// GET /api/users/profile (Fetch current user profile)
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
        'SELECT id, name, email, role, address, latitude, longitude, profile_picture FROM users WHERE id = ?',
        [req.user.id]
    );
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/users/profile (Modify name, password, and geo-location address)
router.put('/profile', verifyToken, async (req, res) => {
  const { name, password, address, latitude, longitude } = req.body;
  const userId = req.user.id;

  try {
    if (password && password.trim() !== '') {
      const passwordHash = await bcrypt.hash(password, 10);
      await db.execute(
          'UPDATE users SET name = ?, password_hash = ?, address = ?, latitude = ?, longitude = ? WHERE id = ?',
          [name, passwordHash, address || null, latitude || null, longitude || null, userId]
      );
    } else {
      await db.execute(
          'UPDATE users SET name = ?, address = ?, latitude = ?, longitude = ? WHERE id = ?',
          [name, address || null, latitude || null, longitude || null, userId]
      );
    }
    res.json({ message: 'Profile updated successfully.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update profile: ' + err.message });
  }
});

// POST /api/users/avatar (Upload/modify profile picture)
router.post('/avatar', verifyToken, upload.single('avatar'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No image file uploaded.' });
  }

  const imageUrl = `/uploads/${req.file.filename}`;
  try {
    await db.execute('UPDATE users SET profile_picture = ? WHERE id = ?', [imageUrl, req.user.id]);
    res.json({ message: 'Profile picture updated.', profile_picture: imageUrl });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;