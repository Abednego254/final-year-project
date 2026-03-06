import axios from 'axios';
import * as dotenv from 'dotenv';
dotenv.config();

const getMpesaToken = async () => {
    const key = process.env.MPESA_CONSUMER_KEY;
    const secret = process.env.MPESA_CONSUMER_SECRET;
    const credentials = Buffer.from(`${key}:${secret}`).toString('base64');
    const baseUrl = 'https://sandbox.safaricom.co.ke';

    console.log('Fetching token...');
    const response = await axios.get(
        `${baseUrl}/oauth/v1/generate?grant_type=client_credentials`,
        { headers: { Authorization: `Basic ${credentials}` } }
    );
    return response.data.access_token;
};

const testStkPush = async () => {
    try {
        const token = await getMpesaToken();
        console.log('Token acquired:', token);
        const shortcode = process.env.MPESA_SHORTCODE || '174379';
        const passkey = process.env.MPESA_PASSKEY || '';
        const timestamp = new Date().toISOString().replace(/[-:T.Z]/g, '').slice(0, 14);
        const password = Buffer.from(`${shortcode}${passkey}${timestamp}`).toString('base64');
        const baseUrl = 'https://sandbox.safaricom.co.ke';
        const phone = '254708374149'; // Test phone

        console.log('Initiating STK Push...');
        const stkResponse = await axios.post(
            `${baseUrl}/mpesa/stkpush/v1/processrequest`,
            {
                BusinessShortCode: shortcode,
                Password: password,
                Timestamp: timestamp,
                TransactionType: 'CustomerPayBillOnline',
                Amount: 1,
                PartyA: phone,
                PartyB: shortcode,
                PhoneNumber: phone,
                CallBackURL: `https://earnest-unfelled-carlene.ngrok-free.dev/api/payments/callback`,
                AccountReference: `BOOKING-1`,
                TransactionDesc: `Test Payment`,
            },
            { headers: { Authorization: `Bearer ${token}` } }
        );

        console.log('Success:', stkResponse.data);
    } catch (error: any) {
        console.error('Error in Daraja:', error?.response?.data || error.message);
    }
};

testStkPush();
