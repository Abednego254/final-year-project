import { query } from '../config/db';

export const getOrCreateWallet = async (userId: number) => {
    const result = await query('SELECT * FROM wallets WHERE user_id = $1', [userId]);
    if (result.rows.length > 0) {
        return result.rows[0];
    }

    const newWallet = await query(
        'INSERT INTO wallets (user_id, balance) VALUES ($1, 0) RETURNING *',
        [userId]
    );
    return newWallet.rows[0];
};

export const creditWallet = async (userId: number, amount: number, description: string, referenceId: string) => {
    const wallet = await getOrCreateWallet(userId);
    
    // Update balance
    await query(
        'UPDATE wallets SET balance = balance + $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
        [amount, wallet.id]
    );

    // Record transaction
    await query(
        'INSERT INTO wallet_transactions (wallet_id, amount, type, description, reference_id) VALUES ($1, $2, $3, $4, $5)',
        [wallet.id, amount, 'credit', description, referenceId]
    );
    
    console.log(`[WALLET] Credited KES ${amount} to User #${userId}. New balance pending fetch.`);
};

export const debitWallet = async (userId: number, amount: number, description: string, referenceId: string) => {
    const wallet = await getOrCreateWallet(userId);
    
    const MINIMUM_BALANCE = 200;
    
    if (wallet.balance - amount < MINIMUM_BALANCE) {
        throw new Error(`Minimum balance of KES ${MINIMUM_BALANCE} must be maintained.`);
    }

    if (wallet.balance < amount) {
        throw new Error('Insufficient wallet balance');
    }

    // Update balance
    await query(
        'UPDATE wallets SET balance = balance - $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
        [amount, wallet.id]
    );

    // Record transaction
    await query(
        'INSERT INTO wallet_transactions (wallet_id, amount, type, description, reference_id) VALUES ($1, $2, $3, $4, $5)',
        [wallet.id, amount, 'debit', description, referenceId]
    );
    
    console.log(`[WALLET] Debited KES ${amount} from User #${userId}.`);
};
