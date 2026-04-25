import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { query } from '../config/db';
import { getOrCreateWallet, debitWallet } from '../services/walletService';
import { triggerB2CPayout } from './payoutController';
import bcrypt from 'bcryptjs';

export const getWalletData = async (req: AuthRequest, res: Response): Promise<void> => {
    const userId = req.user?.id;
    if (!userId) {
        res.status(401).json({ message: 'Unauthorized' });
        return;
    }

    try {
        const wallet = await getOrCreateWallet(userId);
        
        // Fetch last 10 transactions
        const transactions = await query(
            'SELECT * FROM wallet_transactions WHERE wallet_id = $1 ORDER BY created_at DESC LIMIT 10',
            [wallet.id]
        );

        res.json({ 
            wallet: {
                balance: wallet.balance,
                updated_at: wallet.updated_at
            },
            transactions: transactions.rows 
        });
    } catch (error) {
        console.error('Get wallet data error:', error);
        res.status(500).json({ message: 'Server error fetching wallet data.' });
    }
};

export const getFullHistory = async (req: AuthRequest, res: Response): Promise<void> => {
    const userId = req.user?.id;
    if (!userId) {
        res.status(401).json({ message: 'Unauthorized' });
        return;
    }

    try {
        const wallet = await getOrCreateWallet(userId);
        const transactions = await query(
            'SELECT * FROM wallet_transactions WHERE wallet_id = $1 ORDER BY created_at DESC',
            [wallet.id]
        );
        res.json({ transactions: transactions.rows });
    } catch (error) {
        res.status(500).json({ message: 'Server error fetching transaction history.' });
    }
};

export const withdrawFunds = async (req: AuthRequest, res: Response): Promise<void> => {
    const { amount, phone, password } = req.body;
    const userId = req.user?.id;
    if (!userId) {
        res.status(401).json({ message: 'Unauthorized' });
        return;
    }

    if (!amount || amount <= 0) {
        res.status(400).json({ message: 'Invalid withdrawal amount.' });
        return;
    }

    if (!phone || !password) {
        res.status(400).json({ message: 'Phone and Password are required for withdrawal.' });
        return;
    }

    try {
        // 1. Verify Password
        const userResult = await query('SELECT password FROM users WHERE id = $1', [userId]);
        if (userResult.rows.length === 0) {
            res.status(404).json({ message: 'User not found.' });
            return;
        }

        const isMatch = await bcrypt.compare(password, userResult.rows[0].password);
        if (!isMatch) {
            res.status(401).json({ message: 'Incorrect password. Withdrawal unauthorized.' });
            return;
        }

        const wallet = await getOrCreateWallet(userId);
        if (parseFloat(wallet.balance) < amount) {
            res.status(400).json({ message: 'Insufficient wallet balance.' });
            return;
        }

        // 2. Process B2C Simulation (passing the custom phone)
        const transactionId = await triggerB2CPayout(null as any, userId, amount, 'withdrawal', phone);

        // 3. Debit Wallet
        await debitWallet(userId, amount, `Withdrawal to M-Pesa (${phone})`, transactionId);

        res.json({ 
            message: `Withdrawal successful! KES ${amount} sent to ${phone}.`,
            transactionId 
        });
    } catch (error: any) {
        console.error('Withdrawal error:', error);
        res.status(500).json({ message: error.message || 'Server error processing withdrawal.' });
    }
};
