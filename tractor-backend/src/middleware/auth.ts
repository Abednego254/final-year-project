import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthRequest extends Request {
    user?: { id: number; role: string };
}

export const authenticateToken = (req: AuthRequest, res: Response, next: NextFunction) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        res.status(401).json({ message: 'Access denied: No token provided' });
        return;
    }

    jwt.verify(token, process.env.JWT_SECRET || 'super_secret', (err: any, user: any) => {
        if (err) {
            res.status(403).json({ message: 'Invalid token' });
            return;
        }
        req.user = user;
        next();
    });
};

export const requireRole = (role: string) => {
    return (req: AuthRequest, res: Response, next: NextFunction) => {
        if (req.user?.role !== role && req.user?.role !== 'admin') {
            res.status(403).json({ message: `Access denied: Requires ${role} role.` });
            return;
        }
        next();
    };
};
