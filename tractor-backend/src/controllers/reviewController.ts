import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { query } from '../config/db';

// POST /api/reviews  — farmer submits a review after booking completion
export const submitReview = async (req: AuthRequest, res: Response): Promise<void> => {
    const { booking_id, rating, comment } = req.body;
    const farmer_id = req.user?.id;

    try {
        // Verify the booking was completed and belongs to this farmer
        const bookingResult = await query(
            `SELECT b.id, t.owner_id as operator_id FROM bookings b
       JOIN tractors t ON b.tractor_id = t.id
       WHERE b.id = $1 AND b.farmer_id = $2 AND b.status = 'completed'`,
            [booking_id, farmer_id]
        );
        if (bookingResult.rows.length === 0) {
            res.status(404).json({ message: 'Completed booking not found or unauthorized.' });
            return;
        }
        const { operator_id } = bookingResult.rows[0];

        const result = await query(
            `INSERT INTO reviews (booking_id, farmer_id, operator_id, rating, comment)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (booking_id) DO NOTHING
       RETURNING *`,
            [booking_id, farmer_id, operator_id, rating, comment]
        );

        if (result.rows.length === 0) {
            res.status(409).json({ message: 'Review already submitted for this booking.' });
            return;
        }

        res.status(201).json({ review: result.rows[0] });
    } catch (error) {
        console.error('Submit review error:', error);
        res.status(500).json({ message: 'Server error submitting review.' });
    }
};

// GET /api/reviews/operator/:operatorId  — get all reviews for a specific operator
export const getOperatorReviews = async (req: AuthRequest, res: Response): Promise<void> => {
    const { operatorId } = req.params;
    try {
        const result = await query(
            `SELECT r.rating, r.comment, r.created_at, u.name as farmer_name
       FROM reviews r
       JOIN users u ON r.farmer_id = u.id
       WHERE r.operator_id = $1
       ORDER BY r.created_at DESC`,
            [operatorId]
        );

        const avgResult = await query(
            'SELECT ROUND(AVG(rating), 1) as average_rating, COUNT(*) as total_reviews FROM reviews WHERE operator_id = $1',
            [operatorId]
        );

        res.json({
            reviews: result.rows,
            stats: avgResult.rows[0],
        });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching reviews.' });
    }
};
