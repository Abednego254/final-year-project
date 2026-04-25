import { query } from './src/config/db';
import dotenv from 'dotenv';
dotenv.config();

async function fix() {
    try {
        await query('ALTER TABLE payouts ALTER COLUMN booking_id DROP NOT NULL');
        console.log('SUCCESS: payouts.booking_id is now nullable.');
        process.exit(0);
    } catch (e) {
        console.error('FAILED:', e);
        process.exit(1);
    }
}
fix();
