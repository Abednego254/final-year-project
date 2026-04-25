"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.replyToMessage = exports.getMessages = exports.sendMessageToAdmin = void 0;
const db_1 = require("../config/db");
const sendMessageToAdmin = async (req, res) => {
    const { subject, content } = req.body;
    const user_id = req.user?.id;
    try {
        const result = await (0, db_1.query)('INSERT INTO messages (user_id, subject, content) VALUES ($1, $2, $3) RETURNING *', [user_id, subject, content]);
        res.status(201).json({ message: result.rows[0], success: true });
    }
    catch (error) {
        console.error('Send message error:', error);
        res.status(500).json({ message: 'Server error sending message.' });
    }
};
exports.sendMessageToAdmin = sendMessageToAdmin;
const getMessages = async (req, res) => {
    try {
        const result = await (0, db_1.query)(`
            SELECT m.*, u.name as user_name, u.email as user_email, u.role as user_role
            FROM messages m
            JOIN users u ON m.user_id = u.id
            ORDER BY m.created_at DESC
        `);
        res.json({ messages: result.rows });
    }
    catch (error) {
        console.error('Fetch messages error:', error);
        res.status(500).json({ message: 'Server error fetching messages.' });
    }
};
exports.getMessages = getMessages;
const replyToMessage = async (req, res) => {
    const { messageId, replyContent } = req.body;
    const admin_id = req.user?.id;
    try {
        // Find the original message to get the user_id
        const messageResult = await (0, db_1.query)('SELECT user_id, subject FROM messages WHERE id = $1', [messageId]);
        if (messageResult.rows.length === 0) {
            res.status(404).json({ message: 'Message not found.' });
            return;
        }
        const { user_id, subject } = messageResult.rows[0];
        // Insert the reply as a new message from admin to user
        const result = await (0, db_1.query)('INSERT INTO messages (user_id, admin_id, subject, content) VALUES ($1, $2, $3, $4) RETURNING *', [user_id, admin_id, `Re: ${subject}`, replyContent]);
        // Mark the original message as read
        await (0, db_1.query)('UPDATE messages SET is_read = true WHERE id = $1', [messageId]);
        // Notify user via Socket.IO
        try {
            await fetch(`${process.env.API_BASE_URL || 'http://localhost:5000'}/api/internal/notify`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    event: `user_${user_id}_notification`,
                    data: {
                        title: 'New Support Reply',
                        message: `Admin replied to your message: ${replyContent.substring(0, 50)}...`,
                        type: 'support_reply'
                    }
                })
            });
        }
        catch (e) {
            console.error('Socket notification error for support reply:', e);
        }
        res.status(201).json({ reply: result.rows[0], success: true });
    }
    catch (error) {
        console.error('Reply to message error:', error);
        res.status(500).json({ message: 'Server error replying to message.' });
    }
};
exports.replyToMessage = replyToMessage;
