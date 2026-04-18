import { useState, useEffect } from 'react';
import { Save, User, Shield, Loader2, AlertTriangle, MonitorPlay } from 'lucide-react';
import { motion } from 'framer-motion';
import toast from 'react-hot-toast';
import api from '../lib/api';

const Settings = () => {
    const [loading, setLoading] = useState(false);
    const [fetching, setFetching] = useState(true);
    const [adminName, setAdminName] = useState('');
    const [adminEmail, setAdminEmail] = useState('');
    
    // System Settings State
    const [maintenanceMode, setMaintenanceMode] = useState(false);
    const [twoFactorAuth, setTwoFactorAuth] = useState(false);

    useEffect(() => {
        const fetchSettings = async () => {
            try {
                // We'd ideally have an endpoint to get the current user's profile info
                // For now, we'll fetch the system settings
                const response = await api.get('/admin/settings');
                const settings = response.data.settings;
                
                settings.forEach((setting: any) => {
                    if (setting.key === 'maintenance_mode') {
                        setMaintenanceMode(setting.value === 'true');
                    }
                    if (setting.key === 'two_factor_auth') {
                        setTwoFactorAuth(setting.value === 'true');
                    }
                });
            } catch (error) {
                toast.error('Failed to load system settings');
            } finally {
                setFetching(false);
            }
        };

        fetchSettings();
    }, []);

    const handleSave = async () => {
        setLoading(true);
        try {
            // Update System Settings
            await api.put('/admin/settings', {
                settings: [
                    { key: 'maintenance_mode', value: maintenanceMode ? 'true' : 'false' },
                    { key: 'two_factor_auth', value: twoFactorAuth ? 'true' : 'false' }
                ]
            });
            
            // Note: If profile update endpoint exists (/users/profile), we'd call it here
            
            toast.success('System configurations updated successfully');
        } catch (error) {
            toast.error('Failed to save settings');
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    if (fetching) {
        return (
            <div className="flex justify-center items-center h-[60vh]">
                <Loader2 className="animate-spin h-10 w-10 text-brand-600" />
            </div>
        );
    }

    return (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-8 max-w-4xl mx-auto">
            <div>
                <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">System Configuration</h1>
                <p className="text-gray-500 mt-1 font-medium">Manage platform parameters, your profile, and security preferences.</p>
            </div>

            <div className="bg-white shadow-sm rounded-3xl border border-gray-100 overflow-hidden">
                <div className="p-6 border-b border-gray-100 flex items-center bg-gray-50/50">
                    <User className="h-6 w-6 text-brand-600 mr-3" />
                    <h2 className="text-xl font-bold text-gray-900">Admin Profile Details</h2>
                </div>
                <div className="p-8 space-y-6">
                    <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-2">Display Name</label>
                            <input 
                                type="text" 
                                value={adminName}
                                placeholder="Admin Name"
                                onChange={(e) => setAdminName(e.target.value)}
                                className="w-full border border-gray-200 rounded-xl px-4 py-3 focus:ring-2 focus:ring-brand-500 focus:border-brand-500 font-medium transition-colors outline-none" 
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-2">Email Address</label>
                            <input 
                                type="email" 
                                value={adminEmail}
                                placeholder="admin@tractorapp.com"
                                onChange={(e) => setAdminEmail(e.target.value)}
                                className="w-full border border-gray-200 rounded-xl px-4 py-3 focus:ring-2 focus:ring-brand-500 focus:border-brand-500 font-medium transition-colors outline-none" 
                            />
                        </div>
                    </div>
                </div>
            </div>

            <div className="bg-white shadow-sm rounded-3xl border border-gray-100 overflow-hidden relative">
                <div className="p-6 border-b border-gray-100 flex items-center bg-gray-50/50">
                    <Shield className="h-6 w-6 text-brand-600 mr-3" />
                    <h2 className="text-xl font-bold text-gray-900">Security & Platform Controls</h2>
                </div>
                <div className="p-8 space-y-8">
                    
                    {/* Toggle Template */}
                    <div className="flex items-center justify-between p-4 bg-gray-50 rounded-2xl border border-gray-100 hover:border-gray-200 transition-colors">
                        <div className="flex gap-4 items-start">
                            <div className="p-3 bg-white rounded-xl shadow-sm border border-gray-100">
                                <Shield className="h-6 w-6 text-blue-600" />
                            </div>
                            <div>
                                <p className="text-base font-bold text-gray-900">Two-Factor Authentication (2FA)</p>
                                <p className="text-sm font-medium text-gray-500 mt-1 max-w-sm">Require a secondary verification code for all administrative logins to ensure maximum security.</p>
                            </div>
                        </div>
                        <button 
                            onClick={() => setTwoFactorAuth(!twoFactorAuth)}
                            className={`relative inline-flex h-7 w-14 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-brand-500 focus:ring-offset-2 ${twoFactorAuth ? 'bg-brand-600' : 'bg-gray-300'}`}
                        >
                            <span className="sr-only">Enable 2FA</span>
                            <span className={`inline-block h-5 w-5 transform rounded-full bg-white transition-transform ${twoFactorAuth ? 'translate-x-8' : 'translate-x-1'}`} />
                        </button>
                    </div>

                    <div className={`flex items-center justify-between p-4 rounded-2xl border transition-colors ${maintenanceMode ? 'bg-red-50 border-red-200' : 'bg-gray-50 border-gray-100'}`}>
                        <div className="flex gap-4 items-start">
                            <div className={`p-3 bg-white rounded-xl shadow-sm border ${maintenanceMode ? 'border-red-200' : 'border-gray-100'}`}>
                                {maintenanceMode ? <AlertTriangle className="h-6 w-6 text-red-600" /> : <MonitorPlay className="h-6 w-6 text-brand-600" />}
                            </div>
                            <div>
                                <p className={`text-base font-bold ${maintenanceMode ? 'text-red-900' : 'text-gray-900'}`}>Global Maintenance Mode</p>
                                <p className={`text-sm font-medium mt-1 max-w-sm ${maintenanceMode ? 'text-red-700' : 'text-gray-500'}`}>
                                    Temporarily disable the mobile platform for farmers and operators. Use this during major upgrades or critical issues.
                                </p>
                            </div>
                        </div>
                        <button 
                            onClick={() => setMaintenanceMode(!maintenanceMode)}
                            className={`relative inline-flex h-7 w-14 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 ${maintenanceMode ? 'bg-red-600' : 'bg-gray-300'}`}
                        >
                            <span className="sr-only">Enable Maintenance Mode</span>
                            <span className={`inline-block h-5 w-5 transform rounded-full bg-white transition-transform ${maintenanceMode ? 'translate-x-8' : 'translate-x-1'}`} />
                        </button>
                    </div>

                </div>
            </div>

            <div className="flex justify-end pt-4">
                <button
                    onClick={handleSave}
                    disabled={loading}
                    className="inline-flex items-center px-8 py-3.5 border border-transparent text-sm font-bold rounded-xl shadow-md text-white bg-brand-600 hover:bg-brand-700 transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-500 disabled:opacity-50"
                >
                    {loading ? <Loader2 className="animate-spin h-5 w-5 mr-3" /> : <Save className="h-5 w-5 mr-3" />}
                    Save All Configurations
                </button>
            </div>
        </motion.div>
    );
};

export default Settings;

