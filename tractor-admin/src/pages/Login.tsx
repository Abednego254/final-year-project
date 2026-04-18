import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Loader2, ShieldCheck, ShieldAlert } from 'lucide-react';
import { motion } from 'framer-motion';
import api from '../lib/api';
import { useAuth } from '../hooks/useAuth';

const Login = () => {
    const [identifier, setIdentifier] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        try {
            const response = await api.post('/auth/login', { identifier, password });
            const { token, user } = response.data;

            // We only want admins to access the dashboard
            if (user.role !== 'admin') {
                setError('Access denied: Admin credentials required.');
                setLoading(false);
                return;
            }

            login(token, user);
            navigate('/dashboard');
        } catch (err: any) {
            setError(err.response?.data?.message || 'Login failed. Please check your credentials.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex bg-white">
            {/* Left Side - Branding */}
            <div className="hidden lg:flex lg:w-1/2 relative bg-brand-900 items-center justify-center overflow-hidden">
                <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-brand-700 via-brand-900 to-black opacity-80" />
                <div className="relative z-10 flex flex-col items-center justify-center px-12 text-center">
                    <motion.div 
                        initial={{ scale: 0.5, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        transition={{ duration: 0.5, ease: "easeOut" }}
                        className="h-40 w-40 bg-white/10 backdrop-blur-md rounded-3xl flex items-center justify-center mb-8 border border-white/20 shadow-2xl p-2 overflow-hidden"
                    >
                        <img src="/logo.png" alt="TractorApp Logo" className="w-full h-full object-contain drop-shadow-md rounded-2xl" />
                    </motion.div>
                    <motion.h1 
                        initial={{ y: 20, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        transition={{ delay: 0.2, duration: 0.5 }}
                        className="text-4xl font-extrabold text-white tracking-tight"
                    >
                        TractorApp
                    </motion.h1>
                    <motion.p 
                        initial={{ y: 20, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        transition={{ delay: 0.3, duration: 0.5 }}
                        className="mt-4 text-brand-100 text-lg font-medium max-w-sm"
                    >
                        Centralized management for fleets, farmers, and administrative operations.
                    </motion.p>
                </div>
            </div>

            {/* Right Side - Login Form */}
            <div className="flex-1 flex flex-col justify-center py-12 px-4 sm:px-6 lg:px-20 xl:px-24 bg-gray-50">
                <div className="mx-auto w-full max-w-sm lg:w-96">
                    <div className="lg:hidden flex items-center gap-3 mb-8">
                        <div className="h-12 w-12 bg-white rounded-xl flex items-center justify-center shadow-lg shadow-brand-200 border border-gray-100 p-1 overflow-hidden">
                            <img src="/logo.png" alt="TractorApp Logo" className="w-full h-full object-contain rounded-lg" />
                        </div>
                        <span className="text-2xl font-extrabold text-gray-900 tracking-tight">TractorApp</span>
                    </div>

                    <div className="mb-10 lg:mb-12">
                        <h2 className="text-3xl font-extrabold text-gray-900 tracking-tight">
                            Admin Portal
                        </h2>
                        <p className="mt-2 text-sm text-gray-500 font-medium">
                            Please sign in to your administrative account.
                        </p>
                    </div>

                    <div className="mt-8">
                        <form className="space-y-6" onSubmit={handleSubmit}>
                            {error && (
                                <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className="bg-red-50 border border-red-100 text-red-600 px-4 py-3 rounded-xl text-sm font-bold flex items-center gap-2">
                                    <ShieldAlert className="h-5 w-5 shrink-0" />
                                    {error}
                                </motion.div>
                            )}

                            <div>
                                <label className="block text-sm font-bold text-gray-700 mb-1.5">
                                    Identifier (Email or Phone)
                                </label>
                                <div>
                                    <input
                                        type="text"
                                        required
                                        value={identifier}
                                        onChange={(e) => setIdentifier(e.target.value)}
                                        className="appearance-none block w-full px-4 py-3 bg-white border border-gray-200 rounded-xl shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent sm:text-sm font-medium transition-shadow"
                                        placeholder="admin@example.com"
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-bold text-gray-700 mb-1.5">
                                    Password
                                </label>
                                <div>
                                    <input
                                        type="password"
                                        required
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        className="appearance-none block w-full px-4 py-3 bg-white border border-gray-200 rounded-xl shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent sm:text-sm font-medium transition-shadow"
                                        placeholder="••••••••"
                                    />
                                </div>
                            </div>

                            <div className="pt-2">
                                <button
                                    type="submit"
                                    disabled={loading}
                                    className="w-full flex justify-center items-center py-3 px-4 border border-transparent rounded-xl shadow-sm text-sm font-bold text-white bg-brand-600 hover:bg-brand-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-500 disabled:opacity-50 transition-colors"
                                >
                                    {loading ? <Loader2 className="animate-spin h-5 w-5" /> : (
                                        <>
                                            <ShieldCheck className="h-5 w-5 mr-2" />
                                            Secure Login
                                        </>
                                    )}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Login;
