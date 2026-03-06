import { Router } from 'express';
import { register, login } from '../controllers/authController';
import { updateProfile } from '../controllers/userController';
import { registerTractor, getAvailableTractors, updateTractorStatus, getMyTractors } from '../controllers/tractorController';
import { createBooking, getFarmerBookings, getOperatorBookings, updateBookingStatus, updateBookingStartTime } from '../controllers/bookingController';
import { initiateStkPush, mpesaCallback, getPaymentStatus } from '../controllers/paymentController';
import { submitReview, getOperatorReviews } from '../controllers/reviewController';
import { getDashboardStats, getAllBookings, getAllUsers, getAllTractors } from '../controllers/adminController';
import { authenticateToken, requireRole } from '../middleware/auth';

const router = Router();

// ──────────────────────────────────────
// AUTH/USER ROUTES
// ──────────────────────────────────────
// POST   /api/auth/register   { name, email, phone, password, role }
// POST   /api/auth/login      { identifier (email or phone), password }
// PUT    /api/users/profile   { name, email, phone, currentPassword }
router.post('/auth/register', register);
router.post('/auth/login', login);
router.put('/users/profile', authenticateToken, updateProfile);

// ──────────────────────────────────────
// TRACTOR ROUTES
// ──────────────────────────────────────
// GET    /api/tractors/available    → any logged-in user
// GET    /api/tractors/my-tractors  → operator only: see own tractors
// POST   /api/tractors              → operator only: register a tractor
// PUT    /api/tractors/:id/status   → operator only: set status
router.get('/tractors/available', authenticateToken, getAvailableTractors);
router.get('/tractors/my-tractors', authenticateToken, requireRole('operator'), getMyTractors);
router.post('/tractors', authenticateToken, requireRole('operator'), registerTractor);
router.put('/tractors/:id/status', authenticateToken, requireRole('operator'), updateTractorStatus);

// ──────────────────────────────────────
// BOOKING ROUTES
// ──────────────────────────────────────
// POST   /api/bookings                  → farmer: create a booking
// GET    /api/bookings/my-bookings      → farmer: view own bookings
// PUT    /api/bookings/:id/status       → operator: accept / complete / cancel
// PUT    /api/bookings/:id/start-time   → operator: set estimated start time
router.post('/bookings', authenticateToken, requireRole('farmer'), createBooking);
router.get('/bookings/my-bookings', authenticateToken, requireRole('farmer'), getFarmerBookings);
router.get('/bookings/operator-bookings', authenticateToken, requireRole('operator'), getOperatorBookings);
router.put('/bookings/:id/status', authenticateToken, updateBookingStatus);
router.put('/bookings/:id/start-time', authenticateToken, requireRole('operator'), updateBookingStartTime);

// ──────────────────────────────────────
// PAYMENT ROUTES (M-Pesa Daraja)
// ──────────────────────────────────────
// POST   /api/payments/stk-push             → farmer: trigger STK push
// POST   /api/payments/callback             → Safaricom server callback (public)
// GET    /api/payments/status/:bookingId    → farmer: check payment status
router.post('/payments/stk-push', authenticateToken, requireRole('farmer'), initiateStkPush);
router.post('/payments/callback', mpesaCallback);                          // Safaricom hits this
router.get('/payments/status/:bookingId', authenticateToken, getPaymentStatus);

// ──────────────────────────────────────
// REVIEW ROUTES
// ──────────────────────────────────────
// POST   /api/reviews                         → farmer: leave a review after completion
// GET    /api/reviews/operator/:operatorId    → any user: read operator reviews
router.post('/reviews', authenticateToken, requireRole('farmer'), submitReview);
router.get('/reviews/operator/:operatorId', authenticateToken, getOperatorReviews);

// ──────────────────────────────────────
// ADMIN ROUTES
// ──────────────────────────────────────
// GET   /api/admin/stats    → admin: dashboard metrics
// GET   /api/admin/bookings → admin: all bookings (paginated)
// GET   /api/admin/users    → admin: all users (?role=operator to filter)
// GET   /api/admin/tractors → admin: all tractors
router.get('/admin/stats', authenticateToken, requireRole('admin'), getDashboardStats);
router.get('/admin/bookings', authenticateToken, requireRole('admin'), getAllBookings);
router.get('/admin/users', authenticateToken, requireRole('admin'), getAllUsers);
router.get('/admin/tractors', authenticateToken, requireRole('admin'), getAllTractors);

export default router;
