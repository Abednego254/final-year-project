import { useEffect, useState } from 'react';
import { 
    Tractor, 
    CalendarCheck, 
    TrendingUp, 
    Loader2, 
    ArrowUpRight, 
    DollarSign,
    Activity
} from 'lucide-react';
import { 
    AreaChart, 
    Area, 
    XAxis, 
    YAxis, 
    CartesianGrid, 
    Tooltip, 
    ResponsiveContainer,
    PieChart,
    Pie,
    Cell,
    Legend
} from 'recharts';
import { motion } from 'framer-motion';
import api from '../lib/api';
import toast from 'react-hot-toast';

const Dashboard = () => {
    const [stats, setStats] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const response = await api.get('/admin/stats');
                setStats(response.data);
            } catch (err) {
                toast.error('Failed to load dashboard statistics.');
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        fetchStats();
    }, []);

    if (loading) {
        return (
            <div className="flex justify-center items-center h-[60vh]">
                <div className="relative">
                    <Loader2 className="animate-spin h-12 w-12 text-brand-600" />
                    <div className="absolute inset-0 blur-xl bg-brand-400/20 animate-pulse rounded-full"></div>
                </div>
            </div>
        );
    }

    const COLORS = ['#10b981', '#ef4444', '#f59e0b'];
    
    const tractorStatusData = [
        { name: 'Available', value: parseInt(stats.tractors.available) },
        { name: 'Busy', value: parseInt(stats.tractors.busy) },
    ];

    const container = {
        hidden: { opacity: 0 },
        show: {
            opacity: 1,
            transition: {
                staggerChildren: 0.1
            }
        }
    };

    const item = {
        hidden: { y: 20, opacity: 0 },
        show: { y: 0, opacity: 1 }
    };

    return (
        <motion.div 
            variants={container}
            initial="hidden"
            animate="show"
            className="space-y-8"
        >
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Executive Overview</h1>
                    <p className="text-gray-500 mt-1 font-medium">Monitoring platform performance and logistics.</p>
                </div>
                <div className="flex items-center gap-3">
                    <div className="px-4 py-2 bg-white rounded-xl shadow-sm border border-gray-200 flex items-center text-sm font-semibold text-gray-700">
                        <Activity className="h-4 w-4 mr-2 text-brand-600" />
                        Live Status: <span className="text-green-600 ml-1">Optimal</span>
                    </div>
                </div>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
                <motion.div variants={item} className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow relative overflow-hidden group">
                    <div className="absolute -right-4 -top-4 bg-brand-50 w-24 h-24 rounded-full group-hover:scale-110 transition-transform duration-500"></div>
                    <div className="relative">
                        <div className="p-3 bg-brand-100 rounded-xl w-fit">
                            <TrendingUp className="h-6 w-6 text-brand-600" />
                        </div>
                        <div className="mt-4">
                            <p className="text-sm font-bold text-gray-500 uppercase tracking-wider">Total Revenue</p>
                            <h3 className="text-2xl font-black text-gray-900 mt-1">KES {Number(stats.revenue.total_revenue).toLocaleString()}</h3>
                            <p className="text-xs font-semibold text-green-600 mt-2 flex items-center">
                                <ArrowUpRight className="h-3 w-3 mr-1" /> +12.5% vs last month
                            </p>
                        </div>
                    </div>
                </motion.div>

                <motion.div variants={item} className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow relative overflow-hidden group">
                    <div className="absolute -right-4 -top-4 bg-blue-50 w-24 h-24 rounded-full group-hover:scale-110 transition-transform duration-500"></div>
                    <div className="relative">
                        <div className="p-3 bg-blue-100 rounded-xl w-fit">
                            <CalendarCheck className="h-6 w-6 text-blue-600" />
                        </div>
                        <div className="mt-4">
                            <p className="text-sm font-bold text-gray-500 uppercase tracking-wider">Active Bookings</p>
                            <h3 className="text-2xl font-black text-gray-900 mt-1">{stats.bookings.pending}</h3>
                            <p className="text-xs font-semibold text-gray-500 mt-2 flex items-center">
                                High demand cycle active
                            </p>
                        </div>
                    </div>
                </motion.div>

                <motion.div variants={item} className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow relative overflow-hidden group">
                    <div className="absolute -right-4 -top-4 bg-indigo-50 w-24 h-24 rounded-full group-hover:scale-110 transition-transform duration-500"></div>
                    <div className="relative">
                        <div className="p-3 bg-indigo-100 rounded-xl w-fit">
                            <Tractor className="h-6 w-6 text-indigo-600" />
                        </div>
                        <div className="mt-4">
                            <p className="text-sm font-bold text-gray-500 uppercase tracking-wider">Total Fleet</p>
                            <h3 className="text-2xl font-black text-gray-900 mt-1">{stats.tractors.total}</h3>
                            <p className="text-xs font-semibold text-brand-600 mt-2">
                                {stats.tractors.available} units available now
                            </p>
                        </div>
                    </div>
                </motion.div>

                <motion.div variants={item} className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow relative overflow-hidden group">
                    <div className="absolute -right-4 -top-4 bg-emerald-50 w-24 h-24 rounded-full group-hover:scale-110 transition-transform duration-500"></div>
                    <div className="relative">
                        <div className="p-3 bg-emerald-100 rounded-xl w-fit">
                            <DollarSign className="h-6 w-6 text-emerald-600" />
                        </div>
                        <div className="mt-4">
                            <p className="text-sm font-bold text-gray-500 uppercase tracking-wider">System Earnings</p>
                            <h3 className="text-2xl font-black text-gray-900 mt-1">KES {Number(stats.revenue.system_earnings).toLocaleString()}</h3>
                            <p className="text-xs font-semibold text-emerald-600 mt-2 flex items-center">
                                Net platform profit (10%)
                            </p>
                        </div>
                    </div>
                </motion.div>
            </div>

            {/* Charts Section */}
            <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
                {/* Revenue Chart */}
                <motion.div variants={item} className="lg:col-span-2 bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                    <div className="flex items-center justify-between mb-8">
                        <div>
                            <h2 className="text-xl font-black text-gray-900">Revenue Growth</h2>
                            <p className="text-sm text-gray-500 font-medium">Monthly transactional volume</p>
                        </div>
                        <select className="text-sm border-none bg-gray-50 rounded-lg p-2 font-bold focus:ring-0">
                            <option>Last 6 Months</option>
                            <option>Last Year</option>
                        </select>
                    </div>
                    <div className="h-80 w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={stats.chartData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                                <defs>
                                    <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#22c55e" stopOpacity={0.1}/>
                                        <stop offset="95%" stopColor="#22c55e" stopOpacity={0}/>
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#94a3b8', fontSize: 12, fontWeight: 600}} />
                                <YAxis axisLine={false} tickLine={false} tick={{fill: '#94a3b8', fontSize: 12, fontWeight: 600}} />
                                <Tooltip 
                                    contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                                    cursor={{ stroke: '#22c55e', strokeWidth: 2 }}
                                />
                                <Area type="monotone" dataKey="revenue" stroke="#22c55e" strokeWidth={3} fillOpacity={1} fill="url(#colorRev)" />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </motion.div>

                {/* Status Distribution */}
                <motion.div variants={item} className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                    <h2 className="text-xl font-black text-gray-900 mb-2">Fleet Status</h2>
                    <p className="text-sm text-gray-500 font-medium mb-8">Real-time unit availability</p>
                    <div className="h-64 relative">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={tractorStatusData}
                                    cx="50%"
                                    cy="50%"
                                    innerRadius={60}
                                    outerRadius={80}
                                    paddingAngle={8}
                                    dataKey="value"
                                >
                                    {tractorStatusData.map((_, index) => (
                                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                    ))}
                                </Pie>
                                <Tooltip />
                                <Legend verticalAlign="bottom" height={36}/>
                            </PieChart>
                        </ResponsiveContainer>
                        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-center pointer-events-none">
                            <span className="block text-3xl font-black text-gray-900">{stats.tractors.total}</span>
                            <span className="text-xs text-gray-400 font-bold uppercase">Units</span>
                        </div>
                    </div>
                    <div className="mt-8 space-y-4">
                        <div className="flex items-center justify-between p-3 bg-green-50 rounded-xl">
                            <span className="text-sm font-bold text-green-700">Available</span>
                            <span className="text-sm font-black text-green-700">{Math.round((stats.tractors.available / stats.tractors.total) * 100)}%</span>
                        </div>
                        <div className="flex items-center justify-between p-3 bg-red-50 rounded-xl">
                            <span className="text-sm font-bold text-red-700">In Operation</span>
                            <span className="text-sm font-black text-red-700">{Math.round((stats.tractors.busy / stats.tractors.total) * 100)}%</span>
                        </div>
                    </div>
                </motion.div>
            </div>

            {/* Quick Insights */}
            <motion.div variants={item} className="bg-brand-600 rounded-3xl p-8 text-white relative overflow-hidden shadow-xl shadow-brand-200">
                <div className="absolute right-0 top-0 opacity-10 scale-150">
                    <Tractor className="h-64 w-64" />
                </div>
                <div className="relative max-w-2xl">
                    <h2 className="text-2xl font-black">Performance Insight</h2>
                    <p className="mt-4 text-brand-50 font-medium leading-relaxed">
                        Tractor utilization is up by <span className="underline decoration-2 underline-offset-4">15%</span> compared to last month. Consider verifying and onboarding more operators in the South Rift region to meet growing farmer demand during the planting season.
                    </p>
                    <button className="mt-6 px-6 py-2 bg-white text-brand-600 rounded-xl text-sm font-bold hover:bg-brand-50 transition-colors shadow-lg">
                        View Detailed Report
                    </button>
                </div>
            </motion.div>
        </motion.div>
    );
};

export default Dashboard;
