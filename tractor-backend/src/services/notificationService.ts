import { Server } from 'socket.io';

let io: Server;

export const initNotificationService = (socketIo: Server) => {
    io = socketIo;
    console.log('[NOTIFY] Notification service initialized.');
};

export const sendNotification = (event: string, data: any) => {
    if (io) {
        io.emit(event, data);
        console.log(`[NOTIFY] Emitted event: ${event}`);
    } else {
        console.warn('[NOTIFY] io not initialized. Event skipped:', event);
    }
};

export const notifyUser = (userId: number, title: string, message: string, type?: string, extraData?: any) => {
    const payload = {
        title,
        message,
        type,
        ...extraData
    };

    // Emit to both role-specific (legacy) and unified user channel
    sendNotification(`user_${userId}_notification`, payload);
    // Also emit to potential role-based listeners (backward compatibility)
    sendNotification(`farmer_${userId}_notification`, payload);
    sendNotification(`operator_${userId}_notification`, payload);
};
