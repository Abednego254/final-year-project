import React, { useEffect, useState } from 'react';
import { Users, Tractor, CalendarCheck, TrendingUp, Loader2 } from 'lucide-react';
import api from '../lib/api';

const Dashboard = () => {
    const [stats, setStats] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const response = await api.get('/admin/stats');
                setStats(response.data);
            } catch (err) {
                setError('Failed to load dashboard statistics.');
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        fetchStats();
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

    const statCards = [
        { name: 'Total Revenue', value: `KES ${Number(stats.revenue.total_revenue).toLocaleString()}`, icon: TrendingUp },
        { name: 'Active Bookings', value: stats.bookings.pending, icon: CalendarCheck },
        { name: 'Registered Tractors', value: stats.tractors.total, icon: Tractor },
        { name: 'Active Farmers', value: stats.users.farmers, icon: Users },
    ];

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-900">Dashboard Overview</h1>
                <div className="flex space-x-3">
                    <button className="px-4 py-2 bg-white border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50">
                        Export Report
                    </button>
                </div>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
                {statCards.map((stat) => {
                    const Icon = stat.icon;
                    return (
                        <div key={stat.name} className="relative bg-white pt-5 px-4 pb-12 sm:pt-6 sm:px-6 shadow rounded-lg overflow-hidden border border-gray-100">
                            <dt>
                                <div className="absolute bg-brand-500 rounded-md p-3">
                                    <Icon className="h-6 w-6 text-white" aria-hidden="true" />
                                </div>
                                <p className="ml-16 text-sm font-medium text-gray-500 truncate">{stat.name}</p>
                            </dt>
                            <dd className="ml-16 pb-6 flex items-baseline sm:pb-7">
                                <p className="text-2xl font-semibold text-gray-900">{stat.value}</p>
                                <div className="absolute bottom-0 inset-x-0 bg-gray-50 px-4 py-4 sm:px-6">
                                    <div className="text-sm">
                                        <a href="#" className="font-medium text-brand-600 hover:text-brand-500">
                                            View all<span className="sr-only"> {stat.name} stats</span>
                                        </a>
                                    </div>
                                </div>
                            </dd>
                        </div>
                    );
                })}
            </div>

            {/* Main Content Area */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                <div className="bg-white rounded-lg shadow p-6 border border-gray-100">
                    <h2 className="text-lg font-medium text-gray-900 mb-4">Platform Growth</h2>
                    <div className="space-y-4">
                        <p className="text-gray-600">Total Users: {stats.users.total}</p>
                        <p className="text-gray-600">Total Operators: {stats.users.operators}</p>
                        <p className="text-gray-600">Total Bookings: {stats.bookings.total}</p>
                        <p className="text-gray-600">Completed Jobs: {stats.bookings.completed}</p>
                    </div>
                </div>

                <div className="bg-white rounded-lg shadow p-6 border border-gray-100">
                    <h2 className="text-lg font-medium text-gray-900 mb-4">Tractor Availability Status</h2>
                    <div className="space-y-4">
                        <p className="text-gray-600">Currently Available: {stats.tractors.available}</p>
                        <p className="text-gray-600">Currently Busy: {stats.tractors.busy}</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
