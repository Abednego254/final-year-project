import React, { useEffect, useState } from 'react';
import { Search, Filter, Loader2 } from 'lucide-react';
import api from '../lib/api';

const Bookings = () => {
    const [bookings, setBookings] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchBookings = async () => {
            try {
                const response = await api.get('/admin/bookings?limit=50');
                setBookings(response.data.bookings);
            } catch (err) {
                setError('Failed to load bookings.');
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        fetchBookings();
    }, []);

    if (loading) {
        return (
            <div className="flex justify-center items-center h-64">
                <Loader2 className="animate-spin h-8 w-8 text-brand-600" />
            </div>
        );
    }

    if (error) {
        return (
            <div className="bg-red-50 text-red-600 p-4 rounded-md border border-red-200">
                {error}
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <div className="sm:flex sm:items-center sm:justify-between">
                <h1 className="text-2xl font-bold text-gray-900">Bookings Management</h1>
                <div className="mt-4 sm:mt-0 flex space-x-3">
                    <div className="relative rounded-md shadow-sm">
                        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <Search className="h-4 w-4 text-gray-400" />
                        </div>
                        <input
                            type="text"
                            className="focus:ring-brand-500 focus:border-brand-500 block w-full pl-10 sm:text-sm border-gray-300 rounded-md py-2 px-3 border"
                            placeholder="Search bookings..."
                        />
                    </div>
                    <button className="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-500">
                        <Filter className="-ml-1 mr-2 h-4 w-4 text-gray-500" />
                        Filter
                    </button>
                </div>
            </div>

            <div className="bg-white shadow rounded-lg overflow-hidden border border-gray-200">
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Farmer</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tractor & Operator</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {bookings.length === 0 ? (
                            <tr>
                                <td colSpan={6} className="px-6 py-10 text-center text-gray-500">
                                    No bookings found in the system yet.
                                </td>
                            </tr>
                        ) : bookings.map((booking) => (
                            <tr key={booking.id} className="hover:bg-gray-50">
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <div className="text-sm font-medium text-gray-900">{booking.farmer_name}</div>
                                    <div className="text-sm text-gray-500">{booking.farmer_phone}</div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <div className="text-sm text-gray-900">{booking.tractor_model} ({booking.license_plate})</div>
                                    <div className="text-sm text-gray-500">Op: {booking.operator_name}</div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    {new Date(booking.scheduled_date).toLocaleDateString()}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium">
                                    KES {Number(booking.price).toLocaleString()}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium capitalize ${booking.status === 'completed' ? 'bg-green-100 text-green-800' :
                                            booking.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                                                booking.status === 'accepted' ? 'bg-blue-100 text-blue-800' :
                                                    'bg-red-100 text-red-800'
                                        }`}>
                                        {booking.status}
                                    </span>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                    <a href="#" className="text-brand-600 hover:text-brand-900">View</a>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Bookings;
