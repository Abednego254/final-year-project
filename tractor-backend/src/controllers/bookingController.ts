import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { query } from '../config/db';

export const createBooking = async (req: AuthRequest, res: Response): Promise<void> => {
    const { tractor_id, scheduled_date, price } = req.body;
    const farmer_id = req.user?.id;

    try {
        // Check if tractor is available
        const tractor = await query('SELECT status FROM tractors WHERE id = $1', [tractor_id]);
        if (tractor.rows.length === 0) {
            res.status(404).json({ message: 'Tractor not found.' });
            return;
        }
        if (tractor.rows[0].status !== 'available') {
            res.status(400).json({ message: 'Tractor is currently not available.' });
            return;
        }

        // Create booking
        const result = await query(
            'INSERT INTO bookings (farmer_id, tractor_id, status, price, scheduled_date) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [farmer_id, tractor_id, 'pending', price, scheduled_date]
        );

        // Update tractor status
        await query('UPDATE tractors SET status = $1 WHERE id = $2', ['busy', tractor_id]);

        res.status(201).json({ booking: result.rows[0] });
    } catch (error) {
        console.error('Create booking error:', error);
        res.status(500).json({ message: 'Server error creating booking.' });
    }
};

export const getFarmerBookings = async (req: AuthRequest, res: Response): Promise<void> => {
    const farmer_id = req.user?.id;
    try {
        const result = await query(`
      SELECT b.*, t.model, t.license_plate, u.name as operator_name, u.phone as operator_phone
      FROM bookings b
      JOIN tractors t ON b.tractor_id = t.id
      JOIN users u ON t.owner_id = u.id
      WHERE b.farmer_id = $1
      ORDER BY b.created_at DESC
    `, [farmer_id]);
        res.json({ bookings: result.rows });
    } catch (error) {
        console.error('Fetch farmer bookings error:', error);
        res.status(500).json({ message: 'Server error fetching bookings.' });
    }
};

export const updateBookingStatus = async (req: AuthRequest, res: Response): Promise<void> => {
    const { id } = req.params;
    const { status } = req.body; // 'accepted', 'completed', 'cancelled'
    const operator_id = req.user?.id;

    try {
        // Verify operator owns the tractor assigned to this booking
        const authCheck = await query(`
      SELECT b.* FROM bookings b 
      JOIN tractors t ON b.tractor_id = t.id 
      WHERE b.id = $1 AND t.owner_id = $2
    `, [id, operator_id]);

        if (authCheck.rows.length === 0) {
            res.status(403).json({ message: 'Unauthorized to update this booking.' });
            return;
        }

        const result = await query(
            'UPDATE bookings SET status = $1 WHERE id = $2 RETURNING *',
            [status, id]
        );

        // If completed or cancelled, free up the tractor
        if (status === 'completed' || status === 'cancelled') {
            const tractor_id = result.rows[0].tractor_id;
            await query('UPDATE tractors SET status = $1 WHERE id = $2', ['available', tractor_id]);
        }

        res.json({ booking: result.rows[0] });
    } catch (error) {
        console.error('Update booking error:', error);
        res.status(500).json({ message: 'Server error updating booking.' });
    }
};
