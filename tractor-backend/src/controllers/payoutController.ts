import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { query } from '../config/db';

export const getPayoutHistory = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const result = await query(`
            SELECT p.*, u.name as operator_name, u.phone as operator_phone, b.price as booking_price, e.system_fee
            FROM payouts p
            JOIN users u ON p.operator_id = u.id
            JOIN bookings b ON p.booking_id = b.id
            LEFT JOIN earnings e ON p.booking_id = e.booking_id
            ORDER BY p.created_at DESC
        `);
        res.json({ payouts: result.rows });
    } catch (error) {
        console.error('Fetch payout history error:', error);
        res.status(500).json({ message: 'Server error fetching payout history.' });
    }
};

export const triggerB2CPayout = async (booking_id: number, operator_id: number, amount: number, type: string, phone?: string) => {
    try {
        const transaction_id = `B2C${Math.random().toString(36).substring(2, 10).toUpperCase()}`;
        
        await query(
            'INSERT INTO payouts (booking_id, operator_id, amount, payout_type, transaction_id, status) VALUES ($1, $2, $3, $4, $5, $6)',
            [booking_id, operator_id, amount, type, transaction_id, 'completed']
        );

        console.log(`[SIMULATED B2C] Sent KES ${amount} to ${phone || `Operator #${operator_id}`} for Booking #${booking_id} (${type}). Transaction: ${transaction_id}`);
        
        return transaction_id;
    } catch (error) {
        console.error('Trigger B2C payout error:', error);
        throw error;
    }
};
