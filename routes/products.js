const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { verifyToken, isPharmacist } = require('../middleware/auth');

// GET /api/products (Exercise 02, 03 & 08: List & Search with row limit)
router.get('/', verifyToken, async (req, res) => {
    const search = req.query.search || '';
    const limit = 20; // Exercise 08: Search row limit

    try {
        if (search.trim() !== '') {
            const searchPattern = `%${search}%`;
            const [rows] = await db.execute(
                'SELECT id, name, description, price, quantity FROM products WHERE name LIKE ? OR description LIKE ? LIMIT ?',
                [searchPattern, searchPattern, String(limit)]
            );
            return res.json(rows);
        }

        const [rows] = await db.execute(
            'SELECT id, name, description, price, quantity FROM products LIMIT ?',
            [String(limit)]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: 'Failed to retrieve products: ' + err.message });
    }
});

// GET /api/products/:id (Exercise 03: Product Details Page)
router.get('/:id', verifyToken, async (req, res) => {
    try {
        const [rows] = await db.execute(
            'SELECT id, name, description, price, quantity FROM products WHERE id = ?',
            [req.params.id]
        );
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Product not found.' });
        }
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error retrieving product: ' + err.message });
    }
});

// POST /api/products (Exercise 02: Pharmacist adds a new product)
router.post('/', verifyToken, isPharmacist, async (req, res) => {
    const { name, description, price, quantity } = req.body;

    if (!name || price == null || quantity == null) {
        return res.status(400).json({ error: 'Name, price, and quantity are required.' });
    }

    try {
        const [result] = await db.execute(
            'INSERT INTO products (name, description, price, quantity) VALUES (?, ?, ?, ?)',
            [name, description || '', price, quantity]
        );
        res.status(201).json({
            id: result.insertId,
            name,
            description: description || '',
            price,
            quantity
        });
    } catch (err) {
        res.status(500).json({ error: 'Failed to add product: ' + err.message });
    }
});

// PUT /api/products/:id (Exercise 02: Pharmacist edits a product)
router.put('/:id', verifyToken, isPharmacist, async (req, res) => {
    const { name, description, price, quantity } = req.body;

    try {
        const [result] = await db.execute(
            'UPDATE products SET name = ?, description = ?, price = ?, quantity = ? WHERE id = ?',
            [name, description || '', price, quantity, req.params.id]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Product not found.' });
        }
        res.json({ message: 'Product updated successfully.' });
    } catch (err) {
        res.status(500).json({ error: 'Failed to update product: ' + err.message });
    }
});

// DELETE /api/products/:id (Exercise 02: Pharmacist deletes a product)
router.delete('/:id', verifyToken, isPharmacist, async (req, res) => {
    try {
        const [result] = await db.execute('DELETE FROM products WHERE id = ?', [req.params.id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Product not found.' });
        }
        res.json({ message: 'Product deleted successfully.' });
    } catch (err) {
        res.status(500).json({ error: 'Failed to delete product: ' + err.message });
    }
});

module.exports = router;