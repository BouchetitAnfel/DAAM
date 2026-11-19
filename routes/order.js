const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { verifyToken } = require('../middleware/auth');

// POST /api/orders (Exercise 04: Stock order from shopping cart)
// Expects JSON: { "items": [ { "product_id": 1, "quantity": 2 }, ... ] }
router.post('/', verifyToken, async (req, res) => {
    const { items } = req.body;
    const userId = req.user.id;

    if (!items || !Array.isArray(items) || items.length === 0) {
        return res.status(400).json({ error: 'Cart cannot be empty.' });
    }

    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        let totalPrice = 0;
        const validatedItems = [];

        // 1. Verify stock and calculate total server-side
        for (const item of items) {
            const [rows] = await connection.execute(
                'SELECT price, quantity FROM products WHERE id = ? FOR UPDATE',
                [item.product_id]
            );
            if (rows.length === 0) {
                throw new Error(`Product ID ${item.product_id} not found.`);
            }
            if (rows[0].quantity < item.quantity) {
                throw new Error(`Insufficient stock for product ID ${item.product_id}.`);
            }

            const unitPrice = parseFloat(rows[0].price);
            totalPrice += unitPrice * item.quantity;
            validatedItems.push({ ...item, unit_price: unitPrice });
        }

        // 2. Insert into orders table
        const [orderResult] = await connection.execute(
            'INSERT INTO orders (user_id, total_price, status) VALUES (?, ?, ?)',
            [userId, totalPrice.toFixed(2), 'confirmed']
        );
        const orderId = orderResult.insertId;

        // 3. Insert order items and deduct product stock
        for (const item of validatedItems) {
            await connection.execute(
                'INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)',
                [orderId, item.product_id, item.quantity, item.unit_price]
            );
            await connection.execute(
                'UPDATE products SET quantity = quantity - ? WHERE id = ?',
                [item.quantity, item.product_id]
            );
        }

        await connection.commit();
        res.status(201).json({
            message: 'Order placed successfully.',
            order_id: orderId,
            total_price: totalPrice.toFixed(2)
        });
    } catch (err) {
        await connection.rollback();
        res.status(400).json({ error: err.message });
    } finally {
        connection.release();
    }
});

// GET /api/orders (Exercise 05: Retrieve authenticated client's order history & details)
router.get('/', verifyToken, async (req, res) => {
    const userId = req.user.id;

    try {
        const [orders] = await db.execute(
            'SELECT id, total_price, status, order_date FROM orders WHERE user_id = ? ORDER BY order_date DESC',
            [userId]
        );

        // Attach ordered medicines and quantities to each order
        for (const order of orders) {
            const [items] = await db.execute(
                `SELECT oi.product_id, p.name, oi.quantity, oi.unit_price 
         FROM order_items oi 
         JOIN products p ON oi.product_id = p.id 
         WHERE oi.order_id = ?`,
                [order.id]
            );
            order.items = items;
        }

        res.json(orders);
    } catch (err) {
        res.status(500).json({ error: 'Failed to retrieve order history: ' + err.message });
    }
});

module.exports = router;