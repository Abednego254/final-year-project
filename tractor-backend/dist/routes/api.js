"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const authController_1 = require("../controllers/authController");
const userController_1 = require("../controllers/userController");
const tractorController_1 = require("../controllers/tractorController");
const bookingController_1 = require("../controllers/bookingController");
const paymentController_1 = require("../controllers/paymentController");
const reviewController_1 = require("../controllers/reviewController");
const adminController_1 = require("../controllers/adminController");
const supportController_1 = require("../controllers/supportController");
const payoutController_1 = require("../controllers/payoutController");
const auth_1 = require("../middleware/auth");
const maintenance_1 = require("../middleware/maintenance");
const router = (0, express_1.Router)();
// ──────────────────────────────────────
// AUTH/USER ROUTES
// ──────────────────────────────────────
// POST   /api/auth/register   { name, email, phone, password, role }
// POST   /api/auth/login      { identifier (email or phone), password }
// PUT    /api/users/profile   { name, email, phone, currentPassword }
router.post('/auth/register', authController_1.register);
router.post('/auth/login', authController_1.login);
router.put('/users/profile', auth_1.authenticateToken, userController_1.updateProfile);
router.put('/users/settings', auth_1.authenticateToken, userController_1.updateSettings);
router.post('/support/message', auth_1.authenticateToken, supportController_1.sendMessageToAdmin);
// ──────────────────────────────────────
// TRACTOR ROUTES
// ──────────────────────────────────────
// GET    /api/tractors/available    → any logged-in user
// GET    /api/tractors/my-tractors  → operator only: see own tractors
// POST   /api/tractors              → operator only: register a tractor
// PUT    /api/tractors/:id/status   → operator only: set status
router.get('/tractors/available', auth_1.authenticateToken, maintenance_1.checkMaintenanceMode, tractorController_1.getAvailableTractors);
router.get('/tractors/my-tractors', auth_1.authenticateToken, maintenance_1.checkMaintenanceMode, (0, auth_1.requireRole)('operator'), tractorController_1.getMyTractors);
router.post('/tractors', auth_1.authenticateToken, maintenance_1.checkMaintenanceMode, (0, auth_1.requireRole)('operator'), tractorController_1.registerTractor);
router.put('/tractors/:id/status', auth_1.authenticateToken, maintenance_1.checkMaintenanceMode, (0, auth_1.requireRole)('operator'), tractorController_1.updateTractorStatus);
// ──────────────────────────────────────
// BOOKING ROUTES
// ──────────────────────────────────────
// POST   /api/bookings                  → farmer: create a booking
// GET    /api/bookings/my-bookings      → farmer: view own bookings
// PUT    /api/bookings/:id/status       → operator: accept / complete / cancel
// PUT    /api/bookings/:id/start-time   → operator: set estimated start time
router.post('/bookings', auth_1.authenticateToken, maintenance_1.checkMaintenanceMode, (0, auth_1.requireRole)('farmer'), bookingController_1.createBooking);
router.get('/bookings/my-bookings', auth_1.authenticateToken, maintenance_1.checkMaintenanceMode, (0, auth_1.requireRole)('farmer'), bookingController_1.getFarmerBookings);
router.get('/bookings/operator-bookings', auth_1.authenticateToken, maintenance_1.checkMaintenanceMode, (0, auth_1.requireRole)('operator'), bookingController_1.getOperatorBookings);
router.put('/bookings/:id/status', auth_1.authenticateToken, maintenance_1.checkMaintenanceMode, bookingController_1.updateBookingStatus);
router.put('/bookings/:id/start-time', auth_1.authenticateToken, maintenance_1.checkMaintenanceMode, (0, auth_1.requireRole)('operator'), bookingController_1.updateBookingStartTime);
// ──────────────────────────────────────
// PAYMENT ROUTES (M-Pesa Daraja)
// ──────────────────────────────────────
// POST   /api/payments/stk-push             → farmer: trigger STK push
// POST   /api/payments/callback             → Safaricom server callback (public)
// GET    /api/payments/status/:bookingId    → farmer: check payment status
router.post('/payments/stk-push', auth_1.authenticateToken, (0, auth_1.requireRole)('farmer'), paymentController_1.initiateStkPush);
router.post('/payments/callback', paymentController_1.mpesaCallback); // Safaricom hits this
router.post('/mpesa/callbacks', paymentController_1.mpesaCallback); // Alias for flexibility
router.get('/payments/status/:bookingId', auth_1.authenticateToken, paymentController_1.getPaymentStatus);
router.get('/payments/verify/:bookingId', auth_1.authenticateToken, paymentController_1.verifyPayment);
// ──────────────────────────────────────
// REVIEW ROUTES
// ──────────────────────────────────────
// POST   /api/reviews                         → farmer: leave a review after completion
// GET    /api/reviews/operator/:operatorId    → any user: read operator reviews
router.post('/reviews', auth_1.authenticateToken, (0, auth_1.requireRole)('farmer'), reviewController_1.submitReview);
router.get('/reviews/operator/:operatorId', auth_1.authenticateToken, reviewController_1.getOperatorReviews);
// ──────────────────────────────────────
// ADMIN ROUTES
// ──────────────────────────────────────
// GET   /api/admin/stats    → admin: dashboard metrics
// GET   /api/admin/bookings → admin: all bookings (paginated)
// GET   /api/admin/users    → admin: all users (?role=operator to filter)
// GET   /api/admin/tractors → admin: all tractors
router.get('/admin/stats', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.getDashboardStats);
router.get('/admin/bookings', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.getAllBookings);
router.get('/admin/users', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.getAllUsers);
router.post('/admin/users', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.createAdminUser);
router.put('/admin/users/:id', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.updateAdminUser);
router.delete('/admin/users/:id', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.deleteAdminUser);
router.get('/admin/tractors', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.getAllTractors);
router.get('/admin/tractors/:id/history', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.getTractorHistory);
router.get('/admin/messages', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), supportController_1.getMessages);
router.post('/admin/reply', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), supportController_1.replyToMessage);
router.get('/admin/payouts', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), payoutController_1.getPayoutHistory);
router.get('/admin/settings', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.getSystemSettings);
router.put('/admin/settings', auth_1.authenticateToken, (0, auth_1.requireRole)('admin'), adminController_1.updateSystemSettings);
exports.default = router;
