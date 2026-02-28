import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { query } from '../config/db';

// GET /api/admin/stats  — overview for the Admin Dashboard
export const getDashboardStats = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const [users, tractors, bookings, revenue] = await Promise.all([
            query(`SELECT COUNT(*) as total,
               COUNT(*) FILTER (WHERE role = 'farmer') as farmers,
               COUNT(*) FILTER (WHERE role = 'operator') as operators
             FROM users`),
            query(`SELECT COUNT(*) as total,
               COUNT(*) FILTER (WHERE status = 'available') as available,
               COUNT(*) FILTER (WHERE status = 'busy') as busy
             FROM tractors`),
            query(`SELECT COUNT(*) as total,
               COUNT(*) FILTER (WHERE status = 'pending') as pending,
               COUNT(*) FILTER (WHERE status = 'completed') as completed
             FROM bookings`),
            query(`SELECT COALESCE(SUM(amount), 0) as total_revenue
             FROM payments WHERE status = 'completed'`),
        ]);

        res.json({
            users: users.rows[0],
            tractors: tractors.rows[0],
            bookings: bookings.rows[0],
            revenue: revenue.rows[0],
        });
    } catch (error) {
        console.error('Admin stats error:', error);
        res.status(500).json({ message: 'Error fetching dashboard stats.' });
    }
};

// GET /api/admin/bookings  — paginated list of all bookings for admin
export const getAllBookings = async (req: AuthRequest, res: Response): Promise<void> => {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = (page - 1) * limit;

    try {
        const result = await query(
            `SELECT b.id, b.status, b.price, b.scheduled_date, b.created_at,
              f.name as farmer_name, f.phone as farmer_phone,
              t.model as tractor_model, t.license_plate,
              o.name as operator_name
       FROM bookings b
       JOIN users f ON b.farmer_id = f.id
       JOIN tractors t ON b.tractor_id = t.id
       JOIN users o ON t.owner_id = o.id
       ORDER BY b.created_at DESC
       LIMIT $1 OFFSET $2`,
            [limit, offset]
        );

        const countResult = await query('SELECT COUNT(*) FROM bookings');

        res.json({
            bookings: result.rows,
            pagination: {
                page,
                limit,
                total: parseInt(countResult.rows[0].count),
                totalPages: Math.ceil(parseInt(countResult.rows[0].count) / limit),
            },
        });
    } catch (error) {
        console.error('Admin bookings error:', error);
        res.status(500).json({ message: 'Error fetching bookings.' });
    }
};

// GET /api/admin/users  — get all users for operator verification
export const getAllUsers = async (req: AuthRequest, res: Response): Promise<void> => {
    const { role } = req.query; // optional filter: ?role=operator
    try {
        const result = role
            ? await query(
                'SELECT id, name, email, phone, role, created_at FROM users WHERE role = $1 ORDER BY created_at DESC',
                [role]
            )
            : await query('SELECT id, name, email, phone, role, created_at FROM users ORDER BY created_at DESC');

        res.json({ users: result.rows });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching users.' });
    }
};

// GET /api/admin/tractors  — get all tractors for the admin dashboard
export const getAllTractors = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const result = await query(`
      SELECT t.*, u.name as operator_name 
      FROM tractors t
      JOIN users u ON t.owner_id = u.id
      ORDER BY t.created_at DESC
    `);

        res.json({ tractors: result.rows });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching tractors.' });
    }
};
