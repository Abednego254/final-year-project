import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../config/db';

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret';

export const register = async (req: Request, res: Response): Promise<void> => {
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
            'INSERT INTO users (name, email, phone, password, role) VALUES ($1, $2, $3, $4, $5) RETURNING id, name, email, role',
            [name, email, phone, hashedPassword, role || 'farmer']
        );

        const user = result.rows[0];
        const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });

        res.status(201).json({ token, user });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ message: 'Server error during registration.' });
    }
};

export const login = async (req: Request, res: Response): Promise<void> => {
    const { identifier, password } = req.body; // identifier can be email or phone

    try {
        const result = await query('SELECT * FROM users WHERE email = $1 OR phone = $1', [identifier]);
        const user = result.rows[0];

        if (!user) {
            res.status(404).json({ message: 'User not found.' });
            return;
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            res.status(400).json({ message: 'Invalid credentials.' });
            return;
        }

        const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });

        // Exclude password from the response
        const { password: _, ...userWithoutPassword } = user;
        res.json({ token, user: userWithoutPassword });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Server error during login.' });
    }
};
