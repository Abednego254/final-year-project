"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateBookingStartTime = exports.updateBookingStatus = exports.getOperatorBookings = exports.getFarmerBookings = exports.createBooking = void 0;
const db_1 = require("../config/db");
const createBooking = async (req, res) => {
    const { tractor_id, scheduled_date, price } = req.body;
    const farmer_id = req.user?.id;
    try {
        // Prevent booking if farmer already has an active (pending, accepted, paid) booking
        const existingBookings = await (0, db_1.query)("SELECT id FROM bookings WHERE farmer_id = $1 AND status IN ('pending', 'accepted', 'paid')", [farmer_id]);
        if (existingBookings.rows.length > 0) {
            res.status(400).json({ message: 'You already have an active booking. Please complete or cancel it before booking again.' });
            return;
        }
        // Check if tractor is available
        const tractor = await (0, db_1.query)('SELECT status FROM tractors WHERE id = $1', [tractor_id]);
        if (tractor.rows.length === 0) {
            res.status(404).json({ message: 'Tractor not found.' });
            return;
        }
        if (tractor.rows[0].status !== 'available') {
            res.status(400).json({ message: 'Tractor is currently not available.' });
            return;
        }
        // Create booking
        const result = await (0, db_1.query)('INSERT INTO bookings (farmer_id, tractor_id, status, price, scheduled_date) VALUES ($1, $2, $3, $4, $5) RETURNING *', [farmer_id, tractor_id, 'pending', price, scheduled_date]);
        // Update tractor status
        await (0, db_1.query)('UPDATE tractors SET status = $1 WHERE id = $2', ['busy', tractor_id]);
        res.status(201).json({ booking: result.rows[0] });
    }
    catch (error) {
        console.error('Create booking error:', error);
        res.status(500).json({ message: 'Server error creating booking.' });
    }
};
exports.createBooking = createBooking;
const getFarmerBookings = async (req, res) => {
    const farmer_id = req.user?.id;
    try {
        const result = await (0, db_1.query)(`
      SELECT b.*, t.model, t.license_plate, u.name as operator_name, u.phone as operator_phone
      FROM bookings b
      JOIN tractors t ON b.tractor_id = t.id
      JOIN users u ON t.owner_id = u.id
      WHERE b.farmer_id = $1
      ORDER BY b.created_at DESC
    `, [farmer_id]);
        res.json({ bookings: result.rows });
    }
    catch (error) {
        console.error('Fetch farmer bookings error:', error);
        res.status(500).json({ message: 'Server error fetching bookings.' });
    }
};
exports.getFarmerBookings = getFarmerBookings;
const getOperatorBookings = async (req, res) => {
    const operator_id = req.user?.id;
    try {
        const result = await (0, db_1.query)(`
      SELECT b.*, f.name as farmer_name, f.phone as farmer_phone
      FROM bookings b
      JOIN tractors t ON b.tractor_id = t.id
      JOIN users f ON b.farmer_id = f.id
      WHERE t.owner_id = $1
      ORDER BY b.created_at DESC
    `, [operator_id]);
        res.json({ bookings: result.rows });
    }
    catch (error) {
        console.error('Fetch operator bookings error:', error);
        res.status(500).json({ message: 'Server error fetching operator bookings.' });
    }
};
exports.getOperatorBookings = getOperatorBookings;
const updateBookingStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body; // 'accepted', 'completed', 'cancelled'
    const user_id = req.user?.id;
    try {
        // Verify operator owns the tractor assigned to this booking
        const authCheck = await (0, db_1.query)(`
      SELECT b.* FROM bookings b 
      JOIN tractors t ON b.tractor_id = t.id 
      WHERE b.id = $1 AND (t.owner_id = $2 OR b.farmer_id = $2)
    `, [id, user_id]);
        if (authCheck.rows.length === 0) {
            res.status(403).json({ message: 'Unauthorized to update this booking.' });
            return;
        }
        const b = authCheck.rows[0];
        // Handle dual-completion logic
        if (status === 'completed') {
            const isOperator = b.operator_id === user_id; // NOTE: operator_id is technically t.owner_id but we verified access above.
            // To be precise on role
            const userRole = req.user?.role;
            let queryStr = '';
            if (userRole === 'farmer') {
                queryStr = 'UPDATE bookings SET farmer_completed = true WHERE id = $1 RETURNING *';
            }
            else if (userRole === 'operator') {
                queryStr = 'UPDATE bookings SET operator_completed = true WHERE id = $1 RETURNING *';
            }
            if (queryStr) {
                await (0, db_1.query)(queryStr, [id]);
            }
            // Check if both completed
            const updatedBooking = await (0, db_1.query)('SELECT farmer_completed, operator_completed, tractor_id FROM bookings WHERE id = $1', [id]);
            if (updatedBooking.rows[0].farmer_completed && updatedBooking.rows[0].operator_completed) {
                const finalResult = await (0, db_1.query)('UPDATE bookings SET status = $1 WHERE id = $2 RETURNING *', ['completed', id]);
                // Free up the tractor
                await (0, db_1.query)('UPDATE tractors SET status = $1 WHERE id = $2', ['available', updatedBooking.rows[0].tractor_id]);
                // Release the rest of the operator funds
                await (0, db_1.query)('UPDATE earnings SET second_half_paid = true WHERE booking_id = $1', [id]);
                // Trigger simulated B2C for the second half
                try {
                    const earningsResult = await (0, db_1.query)('SELECT operator_id, second_half FROM earnings WHERE booking_id = $1', [id]);
                    if (earningsResult.rows.length > 0) {
                        const { triggerB2CPayout } = require('./payoutController');
                        await triggerB2CPayout(id, earningsResult.rows[0].operator_id, earningsResult.rows[0].second_half, 'second_half');
                    }
                }
                catch (e) {
                    console.error('Failed to trigger second-half payout simulation:', e);
                }
                // Notify both parties that the job is fully complete
                try {
                    await fetch(`${process.env.API_BASE_URL || 'http://localhost:5000'}/api/internal/notify`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ event: `farmer_${finalResult.rows[0].farmer_id}_notification`, data: { title: 'Job Completed', message: `Job #${id} is now fully completed. You can leave a review.`, bookingId: id } }) });
                    await fetch(`${process.env.API_BASE_URL || 'http://localhost:5000'}/api/internal/notify`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ event: `operator_${authCheck.rows[0].owner_id}_notification`, data: { title: 'Job Completed', message: `Job #${id} is fully completed. Your second half payment has been cleared.`, bookingId: id } }) });
                }
                catch (e) { }
                res.json({ booking: finalResult.rows[0], fully_completed: true });
                return;
            }
            else {
                const current = await (0, db_1.query)('SELECT * FROM bookings WHERE id = $1', [id]);
                // Notify the OTHER party that one side has marked it complete
                try {
                    if (userRole === 'operator') {
                        await fetch(`${process.env.API_BASE_URL || 'http://localhost:5000'}/api/internal/notify`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ event: `farmer_${current.rows[0].farmer_id}_notification`, data: { title: 'Action Required', message: `The operator marked job #${id} as completed. Please confirm this in your bookings to release their final payment.`, bookingId: id } }) });
                    }
                    else if (userRole === 'farmer') {
                        await fetch(`${process.env.API_BASE_URL || 'http://localhost:5000'}/api/internal/notify`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ event: `operator_${authCheck.rows[0].owner_id}_notification`, data: { title: 'Job Acknowledged', message: `The farmer confirmed job #${id} is completed.`, bookingId: id } }) });
                    }
                }
                catch (e) { }
                res.json({ booking: current.rows[0], fully_completed: false });
                return;
            }
        }
        const result = await (0, db_1.query)('UPDATE bookings SET status = $1 WHERE id = $2 RETURNING *', [status, id]);
        // If status is 'ongoing', notify the farmer
        if (status === 'ongoing') {
            try {
                await fetch(`${process.env.API_BASE_URL || 'http://localhost:5000'}/api/internal/notify`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        event: `farmer_${result.rows[0].farmer_id}_notification`,
                        data: {
                            title: 'Job Started',
                            message: `The operator has started the job for booking #${id}.`,
                            bookingId: id
                        }
                    })
                });
            }
            catch (e) {
                console.error('Ongoing notification error:', e);
            }
        }
        // If cancelled, free up the tractor
        if (status === 'cancelled') {
            const tractor_id = result.rows[0].tractor_id;
            await (0, db_1.query)('UPDATE tractors SET status = $1 WHERE id = $2', ['available', tractor_id]);
            // Notify the other party about the cancellation
            try {
                if (req.user?.role === 'farmer') {
                    await fetch(`${process.env.API_BASE_URL || 'http://localhost:5000'}/api/internal/notify`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ event: `operator_${authCheck.rows[0].owner_id}_notification`, data: { title: 'Booking Cancelled', message: `The farmer has cancelled booking #${id}.`, bookingId: id } }) });
                }
                else if (req.user?.role === 'operator') {
                    await fetch(`${process.env.API_BASE_URL || 'http://localhost:5000'}/api/internal/notify`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ event: `farmer_${authCheck.rows[0].farmer_id}_notification`, data: { title: 'Booking Cancelled', message: `The operator has cancelled booking #${id}.`, bookingId: id } }) });
                }
            }
            catch (e) {
                console.error('Cancellation notification error:', e);
            }
        }
        res.json({ booking: result.rows[0] });
    }
    catch (error) {
        console.error('Update booking error:', error);
        res.status(500).json({ message: 'Server error updating booking.' });
    }
};
exports.updateBookingStatus = updateBookingStatus;
const updateBookingStartTime = async (req, res) => {
    const { id } = req.params;
    const { estimated_start_time } = req.body;
    const operator_id = req.user?.id;
    try {
        // Verify operator owns the tractor assigned to this booking
        const authCheck = await (0, db_1.query)(`
      SELECT b.* FROM bookings b 
      JOIN tractors t ON b.tractor_id = t.id 
      WHERE b.id = $1 AND t.owner_id = $2
    `, [id, operator_id]);
        if (authCheck.rows.length === 0) {
            res.status(403).json({ message: 'Unauthorized to update this booking.' });
            return;
        }
        const b = authCheck.rows[0];
        // It should ideally be in 'paid' status, which we use 'completed' for payment right now based on paymentController.ts
        // Let's just allow updating it.
        const result = await (0, db_1.query)('UPDATE bookings SET estimated_start_time = $1 WHERE id = $2 RETURNING *', [estimated_start_time, id]);
        res.json({ booking: result.rows[0] });
    }
    catch (error) {
        console.error('Update booking start time error:', error);
        res.status(500).json({ message: 'Server error updating booking start time.' });
    }
};
exports.updateBookingStartTime = updateBookingStartTime;
