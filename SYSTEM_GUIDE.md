# Tractor Platform System Guide

This guide provides instructions on how to set up, clean, and run the Tractor Platform (Uber-like platform for farm-ploughing tractors).

## System Architecture

- **Backend**: Node.js/Express, PostgreSQL, Socket.io (Real-time tracking), M-Pesa Daraja API (Payments).
- **Mobile App**: Flutter (Farmer and Operator modules).
- **Admin Dashboard**: React + Vite (Administrative oversight).

---

## 1. Prerequisites

- **Node.js**: v18+
- **PostgreSQL**: v14+ (Running on port 5433 by default in this setup)
- **Flutter SDK**: For the mobile application
- **ADB**: For running the app on Android (Emulator or Physical device)

---

## 2. Database Cleanup & Setup

The database has been cleaned. All previous data (bookings, tractors, payments) has been removed, and only a default admin user remains.

### Default Admin Credentials
- **Email**: `admin@tractor.com`
- **Password**: `password123`
- **Role**: `admin`

If you need to manually clean the database again, run:
```bash
cd tractor-backend
PGPASSWORD=paygate_password psql -h localhost -p 5433 -U paygate_user -d tractor_db -c "TRUNCATE TABLE payouts, earnings, reviews, payments, bookings, tractors, messages, users CASCADE; INSERT INTO users (name, email, phone, password, role) VALUES ('Admin User', 'admin@tractor.com', '0000000000', '\$2b\$10\$hvVmALuJKmBxMNs4NicsGOI9p/.ybXgDs98aYVnnUoV3hyMTQ6AEy', 'admin');"
```

---

## 3. Running the System

Follow these steps in order:

### A. Start the Backend
1. Open a terminal in `tractor-backend`.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the server in development mode:
   ```bash
   npm run dev
   ```
   *The server will be running at `http://localhost:5000`.*

### B. Start the Admin Dashboard
1. Open a new terminal in `tractor-admin`.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the dashboard:
   ```bash
   npm run dev
   ```
   *The dashboard will be available at the URL shown in the terminal (usually `http://localhost:5173`).*

### C. Run the Tractor App (Mobile)
1. Open a new terminal in `tractor_app`.
2. Get Flutter packages:
   ```bash
   flutter pub get
   ```
3. **If using an Emulator**:
   - Ensure the emulator is running.
   - Run the app:
     ```bash
     flutter run
     ```
4. **If using a Physical Device**:
   - Connect the device via USB and enable USB Debugging.
   - Run ADB reverse to allow the phone to talk to your local backend:
     ```bash
     adb reverse tcp:5000 tcp:5000
     ```
   - Run the app:
     ```bash
     flutter run
     ```

---

## 4. Key Configuration Files

- **Backend Env**: `tractor-backend/.env` (Contains DB credentials and M-Pesa keys).
- **App API Constants**: `tractor_app/lib/services/api_constants.dart` (Contains the `baseUrl`).
  - Use `10.0.2.2` for Android Emulator.
  - Use `localhost` or your machine's IP for physical devices (with `adb reverse`).

---

## 5. Troubleshooting

- **Connection Refused**: Ensure the backend is running and `adb reverse` is executed if using a physical device.
- **Cleartext Traffic**: The `AndroidManifest.xml` has been updated to allow HTTP traffic to the backend.
- **ADB Protocol Fault**: Restart the ADB server:
  ```bash
  adb kill-server
  adb start-server
  ```
