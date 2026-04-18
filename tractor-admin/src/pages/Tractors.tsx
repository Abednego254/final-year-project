import { useEffect, useState } from 'react';
import { Tractor, Search, Loader2, History, MapPin, Calendar, Clock, X, ChevronDown } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import api from '../lib/api';
import toast from 'react-hot-toast';

const Tractors = () => {
    const [tractors, setTractors] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [statusFilter, setStatusFilter] = useState('');

    // History Modal States
    const [historyModalOpen, setHistoryModalOpen] = useState(false);
    const [historyLoading, setHistoryLoading] = useState(false);
    const [tractorHistory, setTractorHistory] = useState<any[]>([]);
    const [selectedTractor, setSelectedTractor] = useState<any>(null);
    const [showAllHistory, setShowAllHistory] = useState(false);

    const fetchTractors = async () => {
        setLoading(true);
        try {
            const queryParams = new URLSearchParams();
            if (searchTerm) queryParams.append('search', searchTerm);
            if (statusFilter) queryParams.append('status', statusFilter);

            const response = await api.get(`/admin/tractors?${queryParams.toString()}`);
            setTractors(response.data.tractors);
        } catch (err) {
            toast.error('Failed to load tractors.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        const delayDebounceFn = setTimeout(() => {
            fetchTractors();
        }, 300);
        return () => clearTimeout(delayDebounceFn);
    }, [searchTerm, statusFilter]);

    const handleViewHistory = async (tractor: any) => {
        setSelectedTractor(tractor);
        setHistoryModalOpen(true);
        setHistoryLoading(true);
        setShowAllHistory(false);
        try {
            const response = await api.get(`/admin/tractors/${tractor.id}/history`);
            setTractorHistory(response.data.history);
        } catch (err) {
            toast.error('Failed to load tractor tracking history.');
        } finally {
            setHistoryLoading(false);
        }
    };

    const getStatusColor = (status: string) => {
        switch (status) {
            case 'available': return 'bg-green-100 text-green-800 border-green-200';
            case 'busy': return 'bg-blue-100 text-blue-800 border-blue-200';
            case 'maintenance': return 'bg-red-100 text-red-800 border-red-200';
            default: return 'bg-gray-100 text-gray-800 border-gray-200';
        }
    };

    const getBookingStatusColor = (status: string) => {
        switch (status) {
            case 'completed': return 'text-green-600 bg-green-50';
            case 'pending': return 'text-yellow-600 bg-yellow-50';
            case 'accepted': return 'text-blue-600 bg-blue-50';
            case 'cancelled': return 'text-red-600 bg-red-50';
            default: return 'text-gray-600 bg-gray-50';
        }
    };

    const displayedHistory = showAllHistory ? tractorHistory : tractorHistory.slice(0, 10);

    return (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-6 relative">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Active Fleet</h1>
                    <p className="text-gray-500 mt-1 font-medium">Monitor all farm-ploughing units and their designated operators.</p>
                </div>
            </div>

            <div className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 flex flex-col sm:flex-row gap-4">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                    <input
                        type="text"
                        placeholder="Search by license plate, model, or operator name..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-brand-500 focus:border-brand-500 font-medium text-sm"
                    />
                </div>
                <select
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="border border-gray-200 rounded-xl px-4 py-2 focus:ring-2 focus:ring-brand-500 focus:border-brand-500 font-medium text-sm text-gray-700 bg-white"
                >
                    <option value="">All Statuses</option>
                    <option value="available">Available</option>
                    <option value="busy">In Operation</option>
                    <option value="maintenance">Maintenance</option>
                </select>
            </div>

            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                {loading ? (
                    <div className="col-span-full py-12 flex justify-center">
                        <Loader2 className="h-10 w-10 text-brand-600 animate-spin" />
                    </div>
                ) : tractors.length === 0 ? (
                    <div className="col-span-full py-16 text-center bg-white rounded-2xl shadow-sm border border-gray-100">
                        <Tractor className="h-12 w-12 text-gray-300 mx-auto mb-4" />
                        <h3 className="text-lg font-bold text-gray-900">No Fleet Found</h3>
                        <p className="text-gray-500 text-sm mt-1">No operational units match your criteria.</p>
                    </div>
                ) : tractors.map((tractor) => (
                    <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} key={tractor.id} className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-lg transition-all group flex flex-col">
                        <div className="p-6 flex-1">
                            <div className="flex items-start justify-between mb-4">
                                <div className="p-3 bg-brand-50 rounded-xl group-hover:bg-brand-600 group-hover:text-white transition-colors duration-300">
                                    <Tractor className="h-6 w-6 text-brand-600 group-hover:text-white transition-colors" />
                                </div>
                                <span className={`border px-2.5 py-1 rounded-lg text-xs font-bold capitalize ${getStatusColor(tractor.status)}`}>
                                    {tractor.status}
                                </span>
                            </div>
                            <h3 className="text-xl font-black text-gray-900">{tractor.license_plate}</h3>
                            <p className="text-sm font-medium text-gray-500 uppercase tracking-wide mt-1">{tractor.model}</p>
                            
                            <div className="mt-6 space-y-3">
                                <div className="flex items-center text-sm font-medium text-gray-700 bg-gray-50 p-2 rounded-lg">
                                    <span className="text-gray-400 w-20">Operator:</span>
                                    <span className="truncate">{tractor.operator_name}</span>
                                </div>
                                <div className="flex items-center text-xs font-semibold text-gray-500 pl-2">
                                    <Calendar className="h-3.5 w-3.5 mr-1.5" />
                                    Registered: {new Date(tractor.created_at).toLocaleDateString()}
                                </div>
                            </div>
                        </div>
                        <button 
                            onClick={() => handleViewHistory(tractor)}
                            className="w-full bg-gray-50 px-6 py-4 border-t border-gray-100 text-sm font-bold text-brand-600 hover:text-brand-800 hover:bg-brand-50 transition-colors flex items-center justify-center gap-2"
                        >
                            <History className="h-4 w-4" />
                            View Tracking History
                        </button>
                    </motion.div>
                ))}
            </div>

            {/* History Modal */}
            <AnimatePresence>
                {historyModalOpen && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
                        <motion.div 
                            initial={{ opacity: 0 }} 
                            animate={{ opacity: 1 }} 
                            exit={{ opacity: 0 }} 
                            className="fixed inset-0 bg-gray-900/60 backdrop-blur-sm"
                            onClick={() => setHistoryModalOpen(false)}
                        />
                        <motion.div 
                            initial={{ opacity: 0, scale: 0.95, y: 20 }} 
                            animate={{ opacity: 1, scale: 1, y: 0 }} 
                            exit={{ opacity: 0, scale: 0.95, y: 20 }} 
                            className="bg-white rounded-3xl shadow-2xl w-full max-w-4xl relative z-10 flex flex-col max-h-[90vh] overflow-hidden"
                        >
                            <div className="px-6 py-5 border-b border-gray-100 flex items-center justify-between bg-gray-50/80">
                                <div>
                                    <h3 className="text-xl font-black text-gray-900 flex items-center gap-2">
                                        <History className="h-5 w-5 text-brand-600" />
                                        Operational History
                                    </h3>
                                    <p className="text-sm font-medium text-gray-500 mt-1">
                                        {selectedTractor?.license_plate} - {selectedTractor?.model}
                                    </p>
                                </div>
                                <button onClick={() => setHistoryModalOpen(false)} className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-200 rounded-full transition-colors">
                                    <X className="h-6 w-6" />
                                </button>
                            </div>
                            
                            <div className="p-6 overflow-y-auto flex-1 bg-gray-50/30">
                                {historyLoading ? (
                                    <div className="flex justify-center py-12">
                                        <Loader2 className="h-8 w-8 text-brand-600 animate-spin" />
                                    </div>
                                ) : tractorHistory.length === 0 ? (
                                    <div className="text-center py-12 text-gray-500 font-medium">
                                        No operational history found for this unit.
                                    </div>
                                ) : (
                                    <div className="space-y-4">
                                        {displayedHistory.map((booking) => (
                                            <div key={booking.id} className="bg-white border border-gray-200 rounded-2xl p-5 shadow-sm hover:border-brand-200 transition-colors">
                                                <div className="flex flex-col sm:flex-row justify-between sm:items-start gap-4">
                                                    <div>
                                                        <div className="flex items-center gap-3 mb-2">
                                                            <span className="text-sm font-black text-gray-900">ID: #{booking.id}</span>
                                                            <span className={`px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider ${getBookingStatusColor(booking.status)}`}>
                                                                {booking.status}
                                                            </span>
                                                        </div>
                                                        <div className="flex items-center gap-2 text-sm text-gray-600 font-medium">
                                                            <MapPin className="h-4 w-4 text-gray-400" />
                                                            Location details provided by: <span className="text-gray-900 font-bold">{booking.farmer_name}</span>
                                                        </div>
                                                    </div>
                                                    <div className="flex flex-col sm:items-end gap-1">
                                                        <div className="text-sm font-black text-gray-900">KES {Number(booking.price).toLocaleString()}</div>
                                                        <div className="flex items-center text-xs font-medium text-gray-500">
                                                            <Clock className="h-3.5 w-3.5 mr-1" />
                                                            {new Date(booking.scheduled_date).toLocaleDateString()}
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        ))}

                                        {tractorHistory.length > 10 && (
                                            <button 
                                                onClick={() => setShowAllHistory(!showAllHistory)}
                                                className="w-full py-3 mt-4 text-sm font-bold text-brand-600 bg-brand-50 hover:bg-brand-100 rounded-xl transition-colors flex items-center justify-center gap-2"
                                            >
                                                {showAllHistory ? 'Show Less' : `View All ${tractorHistory.length} Records`}
                                                <ChevronDown className={`h-4 w-4 transform transition-transform ${showAllHistory ? 'rotate-180' : ''}`} />
                                            </button>
                                        )}
                                    </div>
                                )}
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>
        </motion.div>
    );
};

export default Tractors;
