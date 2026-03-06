import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { query } from '../config/db';

export const registerTractor = async (req: AuthRequest, res: Response): Promise<void> => {
    const { model, license_plate } = req.body;
    const owner_id = req.user?.id;

    try {
        const existing = await query('SELECT * FROM tractors WHERE license_plate = $1', [license_plate]);
        if (existing.rows.length > 0) {
            res.status(400).json({ message: 'Tractor with this license plate already registered.' });
            return;
        }

        const result = await query(
            'INSERT INTO tractors (owner_id, model, license_plate, status) VALUES ($1, $2, $3, $4) RETURNING *',
            [owner_id, model, license_plate, 'available']
        );

        res.status(201).json({ tractor: result.rows[0] });
    } catch (error) {
        console.error('Tractor registration error:', error);
        res.status(500).json({ message: 'Server error registering tractor.' });
    }
};

export const getAvailableTractors = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const result = await query(`
      SELECT t.id, t.model, t.license_plate, t.status, u.id as owner_id, u.name as owner_name, u.phone as owner_phone 
      FROM tractors t 
      JOIN users u ON t.owner_id = u.id 
      WHERE t.status = 'available'
    `);

        res.json({ tractors: result.rows });
    } catch (error) {
        console.error('Fetch tractors error:', error);
        res.status(500).json({ message: 'Server error fetching tractors.' });
    }
};

export const getMyTractors = async (req: AuthRequest, res: Response): Promise<void> => {
    const owner_id = req.user?.id;

    if (!owner_id) {
        res.status(401).json({ message: 'Unauthorized.' });
        return;
    }

    try {
        const result = await query(
            'SELECT * FROM tractors WHERE owner_id = $1 ORDER BY id DESC',
            [owner_id]
        );
        res.json({ tractors: result.rows });
    } catch (error) {
        console.error('Fetch my tractors error:', error);
        res.status(500).json({ message: 'Server error fetching your tractors.' });
    }
};

export const updateTractorStatus = async (req: AuthRequest, res: Response): Promise<void> => {
    const { id } = req.params;
    const { status } = req.body; // 'available', 'busy', 'maintenance'
    const owner_id = req.user?.id;

    if (!['available', 'busy', 'maintenance'].includes(status)) {
        res.status(400).json({ message: 'Invalid status.' });
        return;
    }

    try {
        const tractor = await query('SELECT * FROM tractors WHERE id = $1 AND owner_id = $2', [id, owner_id]);
        if (tractor.rows.length === 0) {
            res.status(404).json({ message: 'Tractor not found or unauthorized.' });
            return;
        }

        const result = await query(
            'UPDATE tractors SET status = $1 WHERE id = $2 RETURNING *',
            [status, id]
        );

        res.json({ tractor: result.rows[0] });
    } catch (error) {
        console.error('Update tractor status error:', error);
        res.status(500).json({ message: 'Server error updating tractor.' });
    }
};
