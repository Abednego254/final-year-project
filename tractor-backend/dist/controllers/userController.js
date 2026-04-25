"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateSettings = exports.updateProfile = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const db_1 = require("../config/db");
const updateProfile = async (req, res) => {
    const { name, email, phone, currentPassword } = req.body;
    const userId = req.user?.id;
    if (!userId) {
        res.status(401).json({ message: 'Unauthorized.' });
        return;
    }
    if (!currentPassword) {
        res.status(400).json({ message: 'Current password is required to update profile.' });
        return;
    }
    try {
        // Fetch the user's current password hash
        const userResult = await (0, db_1.query)('SELECT password FROM users WHERE id = $1', [userId]);
        if (userResult.rows.length === 0) {
            res.status(404).json({ message: 'User not found.' });
            return;
        }
        const user = userResult.rows[0];
        // Verify the password
        const isMatch = await bcryptjs_1.default.compare(currentPassword, user.password);
        if (!isMatch) {
            res.status(400).json({ message: 'Incorrect current password.' });
            return;
        }
        // Check if the new email or phone is already taken by another user
        const existingResult = await (0, db_1.query)('SELECT id FROM users WHERE (email = $1 OR phone = $2) AND id != $3', [email, phone, userId]);
        if (existingResult.rows.length > 0) {
            res.status(400).json({ message: 'Email or phone number is already in use by another account.' });
            return;
        }
        // Update the user's profile
        const updateResult = await (0, db_1.query)('UPDATE users SET name = $1, email = $2, phone = $3 WHERE id = $4 RETURNING id, name, email, phone, role', [name, email, phone, userId]);
        res.json({ user: updateResult.rows[0], message: 'Profile updated successfully.' });
    }
    catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({ message: 'Server error updating profile.' });
    }
};
exports.updateProfile = updateProfile;
const updateSettings = async (req, res) => {
    const { push_notifications, sms_alerts, language, dark_mode } = req.body;
    const userId = req.user?.id;
    if (!userId) {
        res.status(401).json({ message: 'Unauthorized.' });
        return;
    }
    try {
        const result = await (0, db_1.query)('UPDATE users SET push_notifications = $1, sms_alerts = $2, language = $3, dark_mode = $4 WHERE id = $5 RETURNING push_notifications, sms_alerts, language, dark_mode', [push_notifications, sms_alerts, language, dark_mode, userId]);
        res.json({ settings: result.rows[0], message: 'Settings updated successfully.' });
    }
    catch (error) {
        console.error('Update settings error:', error);
        res.status(500).json({ message: 'Server error updating settings.' });
    }
};
exports.updateSettings = updateSettings;
