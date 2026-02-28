import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { query } from './config/db';

dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST', 'PUT', 'DELETE']
    }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database Initialization (Auto-migrate basic tables for development)
const initDb = async () => {
    const tableQueries = `
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      phone VARCHAR(20) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL,
      role VARCHAR(20) DEFAULT 'farmer', -- farmer, operator, admin
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS tractors (
      id SERIAL PRIMARY KEY,
      owner_id INTEGER REFERENCES users(id),
      model VARCHAR(100),
      license_plate VARCHAR(50) UNIQUE NOT NULL,
      status VARCHAR(20) DEFAULT 'available', -- available, busy, maintenance
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS bookings (
      id SERIAL PRIMARY KEY,
      farmer_id INTEGER REFERENCES users(id),
      tractor_id INTEGER REFERENCES tractors(id),
      status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, completed, cancelled
      price DECIMAL(10, 2),
      scheduled_date TIMESTAMP,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS payments (
      id SERIAL PRIMARY KEY,
      booking_id INTEGER REFERENCES bookings(id) UNIQUE,
      phone VARCHAR(20) NOT NULL,
      amount DECIMAL(10, 2) NOT NULL,
      mpesa_checkout_request_id VARCHAR(100),
      mpesa_transaction_id VARCHAR(100),
      status VARCHAR(20) DEFAULT 'pending', -- pending, completed, failed
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS reviews (
      id SERIAL PRIMARY KEY,
      booking_id INTEGER REFERENCES bookings(id) UNIQUE,
      farmer_id INTEGER REFERENCES users(id),
      operator_id INTEGER REFERENCES users(id),
      rating INTEGER CHECK (rating >= 1 AND rating <= 5),
      comment TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;
    try {
        await query(tableQueries);
        console.log('Database tables successfully verified/created');
    } catch (err) {
        console.error('Error creating default tables:', err);
    }
};

initDb();

import apiRoutes from './routes/api';

// Initialize Routes
app.use('/api', apiRoutes);

app.get('/health', async (req, res) => {
    try {
        const result = await query('SELECT NOW()');
        res.json({ status: 'ok', db_time: result.rows[0].now, message: 'Tractor API is running' });
    } catch (error) {
        res.status(500).json({ status: 'error', message: 'Database connection failed' });
    }
});

// WebSockets Implementation
io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);

    // Operators emit their live location
    socket.on('update_location', (data) => {
        // data expected: { tractorId, latitude, longitude }
        // Broadcast location to farmers observing that tractor
        socket.broadcast.emit(`tractor_${data.tractorId}_location`, data);
    });

    socket.on('disconnect', () => {
        console.log('Client disconnected:', socket.id);
    });
});

const PORT = process.env.PORT || 5000;
httpServer.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
