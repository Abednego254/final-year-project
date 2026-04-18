import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth';
import { query } from '../config/db';

export const checkMaintenanceMode = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const result = await query("SELECT value FROM system_settings WHERE key = 'maintenance_mode'");
        const isMaintenance = result.rows[0]?.value === 'true';

        // If maintenance is on and user is not an admin, block the request
        if (isMaintenance && req.user?.role !== 'admin') {
            return res.status(503).json({ 
                message: 'Platform is currently undergoing maintenance. Please try again later.',
                maintenance: true
            });
        }

        next();
    } catch (error) {
        console.error('Maintenance check error:', error);
        next(); // Fallback to allowing request if check fails
    }
};
