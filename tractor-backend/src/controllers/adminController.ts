import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { query } from '../config/db';
import bcrypt from 'bcryptjs';
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
            query(`SELECT 
                COALESCE((SELECT SUM(amount) FROM payments WHERE status = 'completed'), 0) as total_revenue,
                COALESCE((SELECT SUM(system_fee) FROM earnings), 0) as system_earnings
            `),
        ]);

        res.json({
            users: users.rows[0],
            tractors: tractors.rows[0],
            bookings: bookings.rows[0],
            revenue: revenue.rows[0],
            chartData: [
                { name: 'Jan', revenue: 4000 },
                { name: 'Feb', revenue: 3000 },
                { name: 'Mar', revenue: 5000 },
                { name: 'Apr', revenue: Number(revenue.rows[0].total_revenue) || 0 },
            ]
        });
    } catch (error) {
        console.error('Admin stats error:', error);
        res.status(500).json({ message: 'Error fetching dashboard stats.' });
    }
};

// GET /api/admin/bookings  — paginated list of all bookings for admin
export const getAllBookings = async (req: AuthRequest, res: Response): Promise<void> => {
    const { page, limit, search, status, startDate, endDate } = req.query;
    const p = parseInt(page as string) || 1;
    const l = parseInt(limit as string) || 20;
    const offset = (p - 1) * l;

    try {
        let sql = `
            SELECT b.id, b.status, b.price, b.scheduled_date, b.created_at,
              f.name as farmer_name, f.phone as farmer_phone,
              t.model as tractor_model, t.license_plate,
              o.name as operator_name,
              e.system_fee
            FROM bookings b
            JOIN users f ON b.farmer_id = f.id
            JOIN tractors t ON b.tractor_id = t.id
            JOIN users o ON t.owner_id = o.id
            LEFT JOIN earnings e ON b.id = e.booking_id
            WHERE 1=1
        `;
        const params: any[] = [];

        if (status) {
            params.push(status);
            sql += ` AND b.status = $${params.length}`;
        }

        if (search) {
            params.push(`%${search}%`);
            sql += ` AND (f.name ILIKE $${params.length} OR o.name ILIKE $${params.length} OR t.license_plate ILIKE $${params.length})`;
        }

        if (startDate && endDate) {
            params.push(startDate);
            params.push(endDate);
            sql += ` AND b.scheduled_date BETWEEN $${params.length - 1} AND $${params.length}`;
        }

        sql += ` ORDER BY b.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
        params.push(l, offset);

        const result = await query(sql, params);
        const countResult = await query('SELECT COUNT(*) FROM bookings');

        res.json({
            bookings: result.rows,
            pagination: {
                page: p,
                limit: l,
                total: parseInt(countResult.rows[0].count),
                totalPages: Math.ceil(parseInt(countResult.rows[0].count) / l),
            },
        });
    } catch (error) {
        console.error('Admin bookings error:', error);
        res.status(500).json({ message: 'Error fetching bookings.' });
    }
};

// GET /api/admin/users  — get all users with search and filter
export const getAllUsers = async (req: AuthRequest, res: Response): Promise<void> => {
    const { role, search } = req.query;
    try {
        let sql = 'SELECT id, name, email, phone, role, created_at FROM users WHERE 1=1';
        const params: any[] = [];

        if (role) {
            params.push(role);
            sql += ` AND role = $${params.length}`;
        }

        if (search) {
            params.push(`%${search}%`);
            sql += ` AND (name ILIKE $${params.length} OR email ILIKE $${params.length} OR phone ILIKE $${params.length})`;
        }

        sql += ' ORDER BY created_at DESC';
        const result = await query(sql, params);
        res.json({ users: result.rows });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching users.' });
    }
};

// POST /api/admin/users - Admin create user
export const createAdminUser = async (req: AuthRequest, res: Response): Promise<void> => {
    const { name, email, phone, password, role } = req.body;
    try {
        const existingUser = await query('SELECT * FROM users WHERE email = $1 OR phone = $2', [email, phone]);
        if (existingUser.rows.length > 0) {
            res.status(400).json({ message: 'User with that email or phone already exists.' });
            return;
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const result = await query(
            'INSERT INTO users (name, email, phone, password, role) VALUES ($1, $2, $3, $4, $5) RETURNING id, name, role',
            [name, email, phone, hashedPassword, role]
        );
        res.status(201).json({ user: result.rows[0], message: 'User created successfully' });
    } catch (error) {
        console.error('Create admin user error:', error);
        res.status(500).json({ message: 'Error creating user.' });
    }
};

// PUT /api/admin/users/:id - Admin update user
export const updateAdminUser = async (req: AuthRequest, res: Response): Promise<void> => {
    const { id } = req.params;
    const { name, email, phone, role } = req.body;
    try {
        await query(
            'UPDATE users SET name = $1, email = $2, phone = $3, role = $4 WHERE id = $5',
            [name, email, phone, role, id]
        );
        res.json({ message: 'User updated successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating user.' });
    }
};

// DELETE /api/admin/users/:id - Admin delete user
export const deleteAdminUser = async (req: AuthRequest, res: Response): Promise<void> => {
    const { id } = req.params;
    try {
        await query('DELETE FROM users WHERE id = $1', [id]);
        res.json({ message: 'User deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting user.' });
    }
};

// GET /api/admin/tractors - get all tractors with search/filter
export const getAllTractors = async (req: AuthRequest, res: Response): Promise<void> => {
    const { search, status } = req.query;
    try {
        let sql = `
            SELECT t.*, u.name as operator_name 
            FROM tractors t
            JOIN users u ON t.owner_id = u.id
            WHERE 1=1
        `;
        const params: any[] = [];

        if (status) {
            params.push(status);
            sql += ` AND t.status = $${params.length}`;
        }

        if (search) {
            params.push(`%${search}%`);
            sql += ` AND (t.license_plate ILIKE $${params.length} OR t.model ILIKE $${params.length} OR u.name ILIKE $${params.length})`;
        }

        sql += ' ORDER BY t.created_at DESC';
        const result = await query(sql, params);
        res.json({ tractors: result.rows });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching tractors.' });
    }
};

// GET /api/admin/tractors/:id/history - get tractor booking history
export const getTractorHistory = async (req: AuthRequest, res: Response): Promise<void> => {
    const { id } = req.params;
    try {
        const result = await query(
            `SELECT b.*, f.name as farmer_name 
             FROM bookings b
             JOIN users f ON b.farmer_id = f.id
             WHERE b.tractor_id = $1
             ORDER BY b.created_at DESC`,
            [id]
        );
        res.json({ history: result.rows });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching tractor history.' });
    }
};

// GET /api/admin/settings
export const getSystemSettings = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const result = await query('SELECT * FROM system_settings');
        const settings = result.rows.reduce((acc, curr) => ({ ...acc, [curr.key]: curr.value }), {});
        res.json({ settings });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching settings.' });
    }
};

// PUT /api/admin/settings
export const updateSystemSettings = async (req: AuthRequest, res: Response): Promise<void> => {
    const { settings } = req.body; // { maintenance_mode: 'true', ... }
    try {
        for (const [key, value] of Object.entries(settings)) {
            await query(
                'INSERT INTO system_settings (key, value, updated_at) VALUES ($1, $2, CURRENT_TIMESTAMP) ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = CURRENT_TIMESTAMP',
                [key, (value as string).toString()]
            );
        }
        res.json({ message: 'Settings updated successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating settings.' });
    }
};
