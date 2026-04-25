"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkMaintenanceMode = void 0;
const db_1 = require("../config/db");
const checkMaintenanceMode = async (req, res, next) => {
    try {
        const result = await (0, db_1.query)("SELECT value FROM system_settings WHERE key = 'maintenance_mode'");
        const isMaintenance = result.rows[0]?.value === 'true';
        // If maintenance is on and user is not an admin, block the request
        if (isMaintenance && req.user?.role !== 'admin') {
            return res.status(503).json({
                message: 'Platform is currently undergoing maintenance. Please try again later.',
                maintenance: true
            });
        }
        next();
    }
    catch (error) {
        console.error('Maintenance check error:', error);
        next(); // Fallback to allowing request if check fails
    }
};
exports.checkMaintenanceMode = checkMaintenanceMode;
