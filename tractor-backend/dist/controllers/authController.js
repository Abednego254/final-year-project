"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.login = exports.register = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const db_1 = require("../config/db");
const JWT_SECRET = process.env.JWT_SECRET || 'super_secret';
const register = async (req, res) => {
    const { name, email, phone, password, role } = req.body;
    try {
        const existingUser = await (0, db_1.query)('SELECT * FROM users WHERE email = $1 OR phone = $2', [email, phone]);
        if (existingUser.rows.length > 0) {
            res.status(400).json({ message: 'User with that email or phone already exists.' });
            return;
        }
        const salt = await bcryptjs_1.default.genSalt(10);
        const hashedPassword = await bcryptjs_1.default.hash(password, salt);
        const result = await (0, db_1.query)('INSERT INTO users (name, email, phone, password, role) VALUES ($1, $2, $3, $4, $5) RETURNING id, name, email, role', [name, email, phone, hashedPassword, role || 'farmer']);
        const user = result.rows[0];
        const token = jsonwebtoken_1.default.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
        res.status(201).json({ token, user });
    }
    catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ message: 'Server error during registration.' });
    }
};
exports.register = register;
const login = async (req, res) => {
    const { identifier, password } = req.body; // identifier can be email or phone
    try {
        const result = await (0, db_1.query)('SELECT * FROM users WHERE email = $1 OR phone = $1', [identifier]);
        const user = result.rows[0];
        if (!user) {
            res.status(404).json({ message: 'User not found.' });
            return;
        }
        const isMatch = await bcryptjs_1.default.compare(password, user.password);
        if (!isMatch) {
            res.status(400).json({ message: 'Invalid credentials.' });
            return;
        }
        const token = jsonwebtoken_1.default.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
        // Exclude password from the response
        const { password: _, ...userWithoutPassword } = user;
        res.json({ token, user: userWithoutPassword });
    }
    catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Server error during login.' });
    }
};
exports.login = login;
