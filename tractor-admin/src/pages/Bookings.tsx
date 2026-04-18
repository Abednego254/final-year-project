import { useEffect, useState } from 'react';
import { Search, Loader2, Calendar as CalendarIcon, MapPin, CheckCircle2, XCircle, Clock } from 'lucide-react';
import { motion } from 'framer-motion';
import api from '../lib/api';
import toast from 'react-hot-toast';

const Bookings = () => {
    const [bookings, setBookings] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    
    // Filters and Search
    const [searchTerm, setSearchTerm] = useState('');
    const [statusFilter, setStatusFilter] = useState('');
    const [dateRange, setDateRange] = useState({ start: '', end: '' });
    
    // Pagination
    const [pagination, setPagination] = useState({ page: 1, limit: 20, total: 0, totalPages: 0 });

    const fetchBookings = async (page = 1) => {
        setLoading(true);
        try {
            const queryParams = new URLSearchParams({
                page: page.toString(),
                limit: pagination.limit.toString()
            });
            if (searchTerm) queryParams.append('search', searchTerm);
            if (statusFilter) queryParams.append('status', statusFilter);
            if (dateRange.start && dateRange.end) {
                queryParams.append('startDate', dateRange.start);
                queryParams.append('endDate', dateRange.end);
            }

            const response = await api.get(`/admin/bookings?${queryParams.toString()}`);
            setBookings(response.data.bookings);
            setPagination(response.data.pagination);
        } catch (err) {
            toast.error('Failed to load bookings.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        const delayDebounceFn = setTimeout(() => {
            fetchBookings(1);
        }, 400);
        return () => clearTimeout(delayDebounceFn);
    }, [searchTerm, statusFilter, dateRange.start, dateRange.end]);

    const getStatusUI = (status: string) => {
        switch (status) {
            case 'completed': return { color: 'bg-green-100 text-green-800 border-green-200', icon: CheckCircle2 };
            case 'pending': return { color: 'bg-yellow-100 text-yellow-800 border-yellow-200', icon: Clock };
            case 'accepted': return { color: 'bg-blue-100 text-blue-800 border-blue-200', icon: MapPin };
            case 'cancelled': return { color: 'bg-red-100 text-red-800 border-red-200', icon: XCircle };
            default: return { color: 'bg-gray-100 text-gray-800', icon: Clock };
        }
    };

    return (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Booking Operations</h1>
                    <p className="text-gray-500 mt-1 font-medium">Tracking all agricultural service requests and platform earnings.</p>
                </div>
            </div>

            <div className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 flex flex-col lg:flex-row gap-4">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                    <input
                        type="text"
                        placeholder="Search by farmer, operator, or tractor license..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-brand-500 focus:border-brand-500 font-medium text-sm transition-colors outline-none"
                    />
                </div>
                
                <div className="flex flex-col sm:flex-row gap-4">
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        className="border border-gray-200 rounded-xl px-4 py-2.5 focus:ring-2 focus:ring-brand-500 focus:border-brand-500 font-medium text-sm text-gray-700 bg-white transition-colors outline-none min-w-[150px]"
                    >
                        <option value="">All Statuses</option>
                        <option value="pending">Pending</option>
                        <option value="accepted">Accepted</option>
                        <option value="completed">Completed</option>
                        <option value="cancelled">Cancelled</option>
                    </select>

                    <div className="flex items-center gap-2">
                        <input
                            type="date"
                            value={dateRange.start}
                            onChange={(e) => setDateRange({ ...dateRange, start: e.target.value })}
                            className="border border-gray-200 rounded-xl px-4 py-2.5 focus:ring-2 focus:ring-brand-500 font-medium text-sm text-gray-700 outline-none"
                        />
                        <span className="text-gray-400 font-medium">to</span>
                        <input
                            type="date"
                            value={dateRange.end}
                            onChange={(e) => setDateRange({ ...dateRange, end: e.target.value })}
                            className="border border-gray-200 rounded-xl px-4 py-2.5 focus:ring-2 focus:ring-brand-500 font-medium text-sm text-gray-700 outline-none"
                        />
                    </div>
                </div>
            </div>

            <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-100">
                        <thead className="bg-gray-50/50">
                            <tr>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider border-b border-gray-100">Farmer Info</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider border-b border-gray-100">Service Details</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider border-b border-gray-100">Schedule</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider border-b border-gray-100">Financials</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider border-b border-gray-100">Status</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-50">
                            {loading ? (
                                <tr>
                                    <td colSpan={5} className="px-6 py-12 text-center">
                                        <Loader2 className="h-8 w-8 text-brand-600 animate-spin mx-auto" />
                                    </td>
                                </tr>
                            ) : bookings.length === 0 ? (
                                <tr>
                                    <td colSpan={5} className="px-6 py-12 text-center text-gray-500 font-medium">
                                        No bookings match your selected criteria.
                                    </td>
                                </tr>
                            ) : bookings.map((booking) => {
                                const StatusUI = getStatusUI(booking.status);
                                const StatusIcon = StatusUI.icon;
                                
                                return (
                                    <motion.tr initial={{ opacity: 0 }} animate={{ opacity: 1 }} key={booking.id} className="hover:bg-brand-50/40 transition-colors">
                                        <td className="px-6 py-5 whitespace-nowrap">
                                            <div className="flex flex-col">
                                                <span className="text-sm font-bold text-gray-900">{booking.farmer_name}</span>
                                                <span className="text-xs font-medium text-gray-500 mt-0.5">{booking.farmer_phone}</span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-5 whitespace-nowrap">
                                            <div className="flex flex-col gap-1">
                                                <div className="flex items-center text-sm font-bold text-gray-900">
                                                    {booking.tractor_model} 
                                                    <span className="ml-2 px-2 py-0.5 bg-gray-100 rounded text-xs text-gray-600 font-bold">{booking.license_plate}</span>
                                                </div>
                                                <div className="text-xs font-medium text-gray-500 flex items-center">
                                                    Op: <span className="text-gray-700 ml-1 font-semibold">{booking.operator_name}</span>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-5 whitespace-nowrap">
                                            <div className="flex items-center text-sm font-medium text-gray-600">
                                                <CalendarIcon className="h-4 w-4 mr-2 text-brand-500" />
                                                {new Date(booking.scheduled_date).toLocaleDateString()}
                                            </div>
                                            <div className="text-xs text-gray-400 mt-1 ml-6">
                                                Created: {new Date(booking.created_at).toLocaleDateString()}
                                            </div>
                                        </td>
                                        <td className="px-6 py-5 whitespace-nowrap">
                                            <div className="flex flex-col gap-1">
                                                <span className="text-sm font-black text-gray-900 border-b border-gray-100 pb-1 inline-block w-fit">
                                                    KES {Number(booking.price).toLocaleString()}
                                                </span>
                                                <span className="text-xs font-bold text-brand-600 flex items-center pt-1">
                                                    Platform Fee: {booking.system_fee ? `KES ${Number(booking.system_fee).toLocaleString()}` : '-'}
                                                </span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-5 whitespace-nowrap">
                                            <span className={`inline-flex items-center px-3 py-1.5 rounded-xl text-xs font-bold capitalize border ${StatusUI.color}`}>
                                                <StatusIcon className="h-3.5 w-3.5 mr-1.5" />
                                                {booking.status}
                                            </span>
                                        </td>
                                    </motion.tr>
                                );
                            })}
                        </tbody>
                    </table>
                </div>
                
                {/* Pagination Controls */}
                {!loading && bookings.length > 0 && pagination.totalPages > 1 && (
                    <div className="px-6 py-4 border-t border-gray-100 bg-gray-50 flex items-center justify-between">
                        <span className="text-sm text-gray-500 font-medium">
                            Showing page <span className="font-bold text-gray-900">{pagination.page}</span> of <span className="font-bold text-gray-900">{pagination.totalPages}</span>
                        </span>
                        <div className="flex gap-2">
                            <button 
                                onClick={() => fetchBookings(pagination.page - 1)}
                                disabled={pagination.page === 1}
                                className="px-4 py-2 border border-gray-200 rounded-lg text-sm font-bold text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                            >
                                Previous
                            </button>
                            <button 
                                onClick={() => fetchBookings(pagination.page + 1)}
                                disabled={pagination.page === pagination.totalPages}
                                className="px-4 py-2 border border-gray-200 rounded-lg text-sm font-bold text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                            >
                                Next
                            </button>
                        </div>
                    </div>
                )}
            </div>
        </motion.div>
    );
};

export default Bookings;

