import { Request, Response } from 'express';
import axios from 'axios';
import { AuthRequest } from '../middleware/auth';
import { query } from '../config/db';

const getMpesaToken = async (): Promise<string> => {
    const key = process.env.MPESA_CONSUMER_KEY;
    const secret = process.env.MPESA_CONSUMER_SECRET;
    const credentials = Buffer.from(`${key}:${secret}`).toString('base64');
    const baseUrl =
        process.env.MPESA_ENVIRONMENT === 'production'
            ? 'https://api.safaricom.co.ke'
            : 'https://sandbox.safaricom.co.ke';

    const response = await axios.get(
        `${baseUrl}/oauth/v1/generate?grant_type=client_credentials`,
        { headers: { Authorization: `Basic ${credentials}` } }
    );
    return response.data.access_token;
};

// POST /api/payments/stk-push
// Farmer initiates M-Pesa STK Push payment for a booking
export const initiateStkPush = async (req: AuthRequest, res: Response): Promise<void> => {
    const { booking_id, phone } = req.body;
    const farmer_id = req.user?.id;

    try {
        // 1. Fetch the booking to get the price and verify ownership
        const bookingResult = await query(
            'SELECT * FROM bookings WHERE id = $1 AND farmer_id = $2',
            [booking_id, farmer_id]
        );
        if (bookingResult.rows.length === 0) {
            res.status(404).json({ message: 'Booking not found or unauthorized.' });
            return;
        }
        const booking = bookingResult.rows[0];
        if (booking.status !== 'accepted') {
            res.status(400).json({ message: 'Can only pay for an accepted booking.' });
            return;
        }

        // 2. Get M-Pesa access token
        const token = await getMpesaToken();
        const shortcode = process.env.MPESA_SHORTCODE || '174379';
        const passkey = process.env.MPESA_PASSKEY || '';
        const timestamp = new Date()
            .toISOString()
            .replace(/[-:T.Z]/g, '')
            .slice(0, 14);
        const password = Buffer.from(`${shortcode}${passkey}${timestamp}`).toString('base64');
        const baseUrl =
            process.env.MPESA_ENVIRONMENT === 'production'
                ? 'https://api.safaricom.co.ke'
                : 'https://sandbox.safaricom.co.ke';

        // 3. Call STK Push API
        const stkResponse = await axios.post(
            `${baseUrl}/mpesa/stkpush/v1/processrequest`,
            {
                BusinessShortCode: shortcode,
                Password: password,
                Timestamp: timestamp,
                TransactionType: 'CustomerPayBillOnline',
                Amount: Math.round(booking.price),
                PartyA: phone,
                PartyB: shortcode,
                PhoneNumber: phone,
                CallBackURL: `${process.env.API_BASE_URL || 'http://localhost:5000'}/api/payments/callback`,
                AccountReference: `BOOKING-${booking_id}`,
                TransactionDesc: `Payment for tractor booking #${booking_id}`,
            },
            { headers: { Authorization: `Bearer ${token}` } }
        );

        const checkoutRequestId = stkResponse.data.CheckoutRequestID;

        // 4. Save the pending payment record
        await query(
            `INSERT INTO payments (booking_id, phone, amount, mpesa_checkout_request_id, status)
       VALUES ($1, $2, $3, $4, 'pending')
       ON CONFLICT (booking_id) DO UPDATE SET mpesa_checkout_request_id = $4, status = 'pending'`,
            [booking_id, phone, booking.price, checkoutRequestId]
        );

        res.json({
            message: 'STK Push sent to your phone. Enter your M-Pesa PIN to complete.',
            checkoutRequestId,
        });
    } catch (error: any) {
        console.error('STK Push error:', error?.response?.data || error.message);
        res.status(500).json({ message: 'Payment initiation failed. Please try again.' });
    }
};

// POST /api/payments/callback  (called by Safaricom servers)
export const mpesaCallback = async (req: Request, res: Response): Promise<void> => {
    try {
        const callbackData = req.body?.Body?.stkCallback;
        if (!callbackData) {
            res.sendStatus(200);
            return;
        }

        const { CheckoutRequestID, ResultCode, CallbackMetadata } = callbackData;
        if (ResultCode !== 0) {
            // Payment failed or cancelled
            await query(
                `UPDATE payments SET status = 'failed' WHERE mpesa_checkout_request_id = $1`,
                [CheckoutRequestID]
            );
            res.sendStatus(200);
            return;
        }

        // Extract TransactionID from callback metadata
        const items: any[] = CallbackMetadata?.Item || [];
        const mpesaTransactionId = items.find((i: any) => i.Name === 'MpesaReceiptNumber')?.Value;

        // Mark payment as completed and booking as completed
        const paymentResult = await query(
            `UPDATE payments SET status = 'completed', mpesa_transaction_id = $1
       WHERE mpesa_checkout_request_id = $2 RETURNING booking_id`,
            [mpesaTransactionId, CheckoutRequestID]
        );

        if (paymentResult.rows.length > 0) {
            const { booking_id } = paymentResult.rows[0];
            await query(`UPDATE bookings SET status = 'completed' WHERE id = $1`, [booking_id]);
            // Free up the tractor
            const b = await query('SELECT tractor_id FROM bookings WHERE id = $1', [booking_id]);
            if (b.rows.length > 0)
                await query(`UPDATE tractors SET status = 'available' WHERE id = $1`, [b.rows[0].tractor_id]);
        }

        res.sendStatus(200);
    } catch (error) {
        console.error('M-Pesa callback error:', error);
        res.sendStatus(200); // Always respond 200 to Safaricom
    }
};

// GET /api/payments/status/:bookingId
export const getPaymentStatus = async (req: AuthRequest, res: Response): Promise<void> => {
    const { bookingId } = req.params;
    try {
        const result = await query(
            'SELECT status, mpesa_transaction_id, amount, created_at FROM payments WHERE booking_id = $1',
            [bookingId]
        );
        if (result.rows.length === 0) {
            res.status(404).json({ message: 'No payment record found for this booking.' });
            return;
        }
        res.json({ payment: result.rows[0] });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching payment status.' });
    }
};
