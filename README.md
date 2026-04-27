# LimaLink 🚜

**An Uber-like Platform for Farm-Ploughing Tractors with Real-Time Tracking and Digital Payments**

LimaLink is a comprehensive, digital platform designed to bridge the gap between smallholder farmers and tractor operators in rural agricultural settings. By adapting the ride-hailing gig economy model to agriculture, LimaLink allows farmers to request mechanization services on-demand while enabling tractor owners to maximize their equipment utilization and profitability.

## 🌟 Key Features

### For Farmers
- **On-Demand Booking:** View available tractors in your vicinity and book ploughing services instantly.
- **Real-Time Tracking:** Track the live GPS location of your assigned tractor as it approaches your farm.
- **Transparent Pricing & Payments:** Predictable service costs with integrated, secure M-Pesa digital payments.
- **Review System:** Rate operators and provide feedback after job completion to ensure quality service.

### For Tractor Operators
- **Live Job Requests:** Receive instant notifications for nearby ploughing jobs.
- **Wallet & Earnings:** Track earnings seamlessly through an integrated digital wallet.
- **Location Broadcasting:** Broadcast your real-time GPS coordinates to assure farmers of your arrival.

### For Administrators
- **Command Center Dashboard:** A powerful web-based dashboard to oversee all active bookings.
- **Live Fleet Map:** View all active tractors on an interactive map using WebSockets.
- **User Verification:** Approve and manage registered farmers and operators.

---

## 🛠️ Technology Stack

LimaLink is built using a modern, scalable, full-stack architecture:

- **Mobile Application (Frontend):** Flutter & Dart (Cross-platform for Android & iOS)
- **Admin Dashboard (Web):** React, TypeScript, Tailwind CSS, Leaflet Maps
- **Backend API:** Node.js, Express, TypeScript
- **Database:** PostgreSQL (Relational data management)
- **Real-Time Communication:** Socket.io (WebSockets)
- **Payment Gateway:** Safaricom M-Pesa Daraja API
- **Containerization:** Docker & Docker Compose

---

## 🚀 Getting Started

To run the entire LimaLink ecosystem locally, ensure you have Docker and Docker Compose installed.

### 1. Clone the repository
```bash
git clone https://github.com/your-username/limalink.git
cd limalink
```

### 2. Configure Environment Variables
Ensure you have the required `.env` files in both the `tractor-backend/` and `tractor-admin/` directories. (Contact the administrator for API keys, including M-Pesa sandbox credentials).

### 3. Start the Services
Run the following command from the root directory to spin up the database, backend, and admin panel:
```bash
docker compose up -d
```

### 4. Access the Applications
- **Backend API:** `http://localhost:5000`
- **Admin Dashboard:** `http://localhost:5173`
- **Mobile App:** Navigate to `tractor_app/` and run `flutter run` on an emulator or physical device.

---

## 🏗️ Project Structure

- `/tractor-backend` - The Node.js Express server handling API requests, sockets, and DB connections.
- `/tractor-admin` - The React-based web dashboard for system administrators.
- `/tractor_app` - The Flutter mobile application for Farmers and Operators.
- `/docs` - Contains all academic documentation, concept papers, and project reports for this Final Year Project.

---

## 🎓 Academic Context

This system is developed as a Final Year Computer Science Project (COMP 413/424) at Laikipia University. All associated research proposals, concept papers, and final reports are located in the `docs/` directory.

**Developer:** Abednego Kaume (N11/3/0053/020)  
**Degree:** Bachelor of Computer Science  
**Institution:** Laikipia University  

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
