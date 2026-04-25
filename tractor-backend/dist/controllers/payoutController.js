"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.triggerB2CPayout = exports.getPayoutHistory = void 0;
const db_1 = require("../config/db");
const getPayoutHistory = async (req, res) => {
    try {
        const result = await (0, db_1.query)(`
            SELECT p.*, u.name as operator_name, u.phone as operator_phone, b.price as booking_price, e.system_fee
            FROM payouts p
            JOIN users u ON p.operator_id = u.id
            JOIN bookings b ON p.booking_id = b.id
            LEFT JOIN earnings e ON p.booking_id = e.booking_id
            ORDER BY p.created_at DESC
        `);
        res.json({ payouts: result.rows });
    }
    catch (error) {
        console.error('Fetch payout history error:', error);
        res.status(500).json({ message: 'Server error fetching payout history.' });
    }
};
exports.getPayoutHistory = getPayoutHistory;
const triggerB2CPayout = async (booking_id, operator_id, amount, type) => {
    try {
        const transaction_id = `B2C${Math.random().toString(36).substring(2, 10).toUpperCase()}`;
        await (0, db_1.query)('INSERT INTO payouts (booking_id, operator_id, amount, payout_type, transaction_id, status) VALUES ($1, $2, $3, $4, $5, $6)', [booking_id, operator_id, amount, type, transaction_id, 'completed']);
        console.log(`[SIMULATED B2C] Sent KES ${amount} to Operator #${operator_id} for Booking #${booking_id} (${type}). Transaction: ${transaction_id}`);
        return transaction_id;
    }
    catch (error) {
        console.error('Trigger B2C payout error:', error);
        throw error;
    }
};
exports.triggerB2CPayout = triggerB2CPayout;
