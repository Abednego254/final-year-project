import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { query } from '../config/db';
import { notifyUser } from '../services/notificationService';

export const sendMessageToAdmin = async (req: AuthRequest, res: Response): Promise<void> => {
    const { subject, content } = req.body;
    const user_id = req.user?.id;

    try {
        const result = await query(
            'INSERT INTO messages (user_id, subject, content) VALUES ($1, $2, $3) RETURNING *',
            [user_id, subject, content]
        );
        res.status(201).json({ message: result.rows[0], success: true });
    } catch (error) {
        console.error('Send message error:', error);
        res.status(500).json({ message: 'Server error sending message.' });
    }
};

export const getMyMessages = async (req: AuthRequest, res: Response): Promise<void> => {
    const user_id = req.user?.id;
    try {
        const result = await query(`
            SELECT * FROM messages 
            WHERE user_id = $1 
            ORDER BY created_at DESC
        `, [user_id]);
        res.json({ messages: result.rows });
    } catch (error) {
        console.error('Fetch my messages error:', error);
        res.status(500).json({ message: 'Server error fetching your messages.' });
    }
};

export const getMessages = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const result = await query(`
            SELECT m.*, u.name as user_name, u.email as user_email, u.role as user_role
            FROM messages m
            JOIN users u ON m.user_id = u.id
            ORDER BY m.created_at DESC
        `);
        res.json({ messages: result.rows });
    } catch (error) {
        console.error('Fetch messages error:', error);
        res.status(500).json({ message: 'Server error fetching messages.' });
    }
};

export const replyToMessage = async (req: AuthRequest, res: Response): Promise<void> => {
    const { messageId, replyContent } = req.body;
    const admin_id = req.user?.id;

    try {
        // Find the original message to get the user_id
        const messageResult = await query('SELECT user_id, subject FROM messages WHERE id = $1', [messageId]);
        if (messageResult.rows.length === 0) {
            res.status(404).json({ message: 'Message not found.' });
            return;
        }

        const { user_id, subject } = messageResult.rows[0];

        // Insert the reply as a new message from admin to user
        const result = await query(
            'INSERT INTO messages (user_id, admin_id, subject, content) VALUES ($1, $2, $3, $4) RETURNING *',
            [user_id, admin_id, `Re: ${subject}`, replyContent]
        );

        // Mark the original message as read
        await query('UPDATE messages SET is_read = true WHERE id = $1', [messageId]);

        // Notify user via Socket.IO
        notifyUser(
            user_id,
            'New Support Reply',
            `Admin replied to your message: ${replyContent.substring(0, 50)}...`,
            'support_reply'
        );

        res.status(201).json({ reply: result.rows[0], success: true });
    } catch (error) {
        console.error('Reply to message error:', error);
        res.status(500).json({ message: 'Server error replying to message.' });
    }
};
