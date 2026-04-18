import { useEffect, useState } from 'react';
import { Search, Loader2, Plus, Edit2, Trash2, X, ShieldAlert } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import toast from 'react-hot-toast';
import api from '../lib/api';

const Users = () => {
    const [users, setUsers] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [roleFilter, setRoleFilter] = useState('');
    
    // Modal states
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [modalMode, setModalMode] = useState<'add' | 'edit'>('add');
    const [selectedUser, setSelectedUser] = useState<any>(null);
    const [formData, setFormData] = useState({ name: '', email: '', phone: '', password: '', role: 'farmer' });
    const [submitting, setSubmitting] = useState(false);

    const fetchUsers = async () => {
        setLoading(true);
        try {
            const queryParams = new URLSearchParams();
            if (searchTerm) queryParams.append('search', searchTerm);
            if (roleFilter) queryParams.append('role', roleFilter);
            
            const response = await api.get(`/admin/users?${queryParams.toString()}`);
            setUsers(response.data.users);
        } catch (err) {
            toast.error('Failed to load users.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        const delayDebounceFn = setTimeout(() => {
            fetchUsers();
        }, 300);
        return () => clearTimeout(delayDebounceFn);
    }, [searchTerm, roleFilter]);

    const handleOpenModal = (mode: 'add' | 'edit', user: any = null) => {
        setModalMode(mode);
        setSelectedUser(user);
        if (mode === 'edit' && user) {
            setFormData({ name: user.name, email: user.email, phone: user.phone, password: '', role: user.role });
        } else {
            setFormData({ name: '', email: '', phone: '', password: '', role: 'farmer' });
        }
        setIsModalOpen(true);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            if (modalMode === 'add') {
                await api.post('/admin/users', formData);
                toast.success('User created successfully');
            } else {
                await api.put(`/admin/users/${selectedUser.id}`, formData);
                toast.success('User updated successfully');
            }
            setIsModalOpen(false);
            fetchUsers();
        } catch (error: any) {
            const msg = error.response?.data?.message || (modalMode === 'add' ? 'Failed to create user' : 'Failed to update user');
            toast.error(msg);
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id: number) => {
        if (window.confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
            try {
                await api.delete(`/admin/users/${id}`);
                toast.success('User deleted successfully');
                fetchUsers();
            } catch (error) {
                toast.error('Failed to delete user');
            }
        }
    };

    const getRoleColor = (role: string) => {
        switch (role) {
            case 'admin': return 'bg-purple-100 text-purple-800 border border-purple-200';
            case 'operator': return 'bg-blue-100 text-blue-800 border border-blue-200';
            case 'farmer': return 'bg-green-100 text-green-800 border border-green-200';
            default: return 'bg-gray-100 text-gray-800';
        }
    };

    return (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">System Users</h1>
                    <p className="text-gray-500 mt-1 font-medium">Manage farmers, operators, and administrators.</p>
                </div>
                <button 
                    onClick={() => handleOpenModal('add')}
                    className="inline-flex items-center px-4 py-2 bg-brand-600 text-white rounded-xl shadow-sm text-sm font-bold hover:bg-brand-700 transition-colors"
                >
                    <Plus className="mr-2 h-4 w-4" />
                    Add New User
                </button>
            </div>

            <div className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 flex flex-col sm:flex-row gap-4">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                    <input
                        type="text"
                        placeholder="Search by name, email, or phone..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-brand-500 focus:border-brand-500 font-medium text-sm"
                    />
                </div>
                <select
                    value={roleFilter}
                    onChange={(e) => setRoleFilter(e.target.value)}
                    className="border border-gray-200 rounded-xl px-4 py-2 focus:ring-2 focus:ring-brand-500 focus:border-brand-500 font-medium text-sm text-gray-700 bg-white"
                >
                    <option value="">All Roles</option>
                    <option value="farmer">Farmers</option>
                    <option value="operator">Operators</option>
                    <option value="admin">Admins</option>
                </select>
            </div>

            <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-100">
                        <thead className="bg-gray-50/50">
                            <tr>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">User</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Contact Details</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Role</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Joined</th>
                                <th className="px-6 py-4 text-right text-xs font-bold text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-50">
                            {loading ? (
                                <tr>
                                    <td colSpan={5} className="px-6 py-12 text-center">
                                        <Loader2 className="h-8 w-8 text-brand-600 animate-spin mx-auto" />
                                    </td>
                                </tr>
                            ) : users.length === 0 ? (
                                <tr>
                                    <td colSpan={5} className="px-6 py-12 text-center text-gray-500 font-medium">
                                        No users match your criteria.
                                    </td>
                                </tr>
                            ) : users.map((user) => (
                                <motion.tr initial={{ opacity: 0 }} animate={{ opacity: 1 }} key={user.id} className="hover:bg-brand-50/30 transition-colors">
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <div className="flex items-center">
                                            <div className="h-10 w-10 bg-gradient-to-br from-gray-100 to-gray-200 rounded-xl flex items-center justify-center border border-gray-200">
                                                <span className="font-bold text-gray-600">{user.name.charAt(0)}</span>
                                            </div>
                                            <div className="ml-4">
                                                <div className="text-sm font-bold text-gray-900">{user.name}</div>
                                                <div className="text-xs font-semibold text-gray-400">ID: #{user.id}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <div className="text-sm font-medium text-gray-900">{user.email}</div>
                                        <div className="text-sm font-medium text-gray-500">{user.phone}</div>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <span className={`inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-bold capitalize ${getRoleColor(user.role)}`}>
                                            {user.role}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                                        {new Date(user.created_at).toLocaleDateString()}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                        <div className="flex justify-end gap-2">
                                            <button onClick={() => handleOpenModal('edit', user)} className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                                                <Edit2 className="h-4 w-4" />
                                            </button>
                                            <button onClick={() => handleDelete(user.id)} className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors">
                                                <Trash2 className="h-4 w-4" />
                                            </button>
                                        </div>
                                    </td>
                                </motion.tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Modal */}
            <AnimatePresence>
                {isModalOpen && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
                        <motion.div 
                            initial={{ opacity: 0 }} 
                            animate={{ opacity: 1 }} 
                            exit={{ opacity: 0 }} 
                            className="fixed inset-0 bg-gray-900/40 backdrop-blur-sm"
                            onClick={() => setIsModalOpen(false)}
                        />
                        <motion.div 
                            initial={{ opacity: 0, scale: 0.95, y: 20 }} 
                            animate={{ opacity: 1, scale: 1, y: 0 }} 
                            exit={{ opacity: 0, scale: 0.95, y: 20 }} 
                            className="bg-white rounded-3xl shadow-2xl w-full max-w-md relative z-10 overflow-hidden"
                        >
                            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                                <h3 className="text-lg font-black text-gray-900">
                                    {modalMode === 'add' ? 'Add New User' : 'Edit User Profile'}
                                </h3>
                                <button onClick={() => setIsModalOpen(false)} className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full transition-colors">
                                    <X className="h-5 w-5" />
                                </button>
                            </div>
                            <form onSubmit={handleSubmit} className="p-6 space-y-4 text-sm font-medium">
                                <div>
                                    <label className="block text-gray-700 mb-1">Full Name</label>
                                    <input required type="text" value={formData.name} onChange={(e) => setFormData({...formData, name: e.target.value})} className="w-full border border-gray-200 rounded-xl px-4 py-2.5 focus:ring-2 focus:ring-brand-500 outline-none" />
                                </div>
                                <div>
                                    <label className="block text-gray-700 mb-1">Email Address</label>
                                    <input required type="email" value={formData.email} onChange={(e) => setFormData({...formData, email: e.target.value})} className="w-full border border-gray-200 rounded-xl px-4 py-2.5 focus:ring-2 focus:ring-brand-500 outline-none" />
                                </div>
                                <div>
                                    <label className="block text-gray-700 mb-1">Phone Number</label>
                                    <input required type="text" value={formData.phone} onChange={(e) => setFormData({...formData, phone: e.target.value})} className="w-full border border-gray-200 rounded-xl px-4 py-2.5 focus:ring-2 focus:ring-brand-500 outline-none" />
                                </div>
                                <div>
                                    <label className="block text-gray-700 mb-1">Role</label>
                                    <select value={formData.role} onChange={(e) => setFormData({...formData, role: e.target.value})} className="w-full border border-gray-200 rounded-xl px-4 py-2.5 focus:ring-2 focus:ring-brand-500 outline-none">
                                        <option value="farmer">Farmer</option>
                                        <option value="operator">Operator</option>
                                        <option value="admin">Administrator</option>
                                    </select>
                                </div>
                                {modalMode === 'add' && (
                                    <div>
                                        <label className="block text-gray-700 mb-1">Temporary Password</label>
                                        <input required type="password" value={formData.password} onChange={(e) => setFormData({...formData, password: e.target.value})} className="w-full border border-gray-200 rounded-xl px-4 py-2.5 focus:ring-2 focus:ring-brand-500 outline-none" />
                                    </div>
                                )}
                                {modalMode === 'add' && formData.role === 'admin' && (
                                    <div className="bg-red-50 p-3 rounded-xl flex items-start gap-3 border border-red-100">
                                        <ShieldAlert className="h-5 w-5 text-red-600 shrink-0 mt-0.5" />
                                        <p className="text-xs font-bold text-red-800 leading-tight">Warning: Giving this user Administrator rights allows them full control over the platform.</p>
                                    </div>
                                )}
                                <div className="pt-4 flex gap-3">
                                    <button type="button" onClick={() => setIsModalOpen(false)} className="flex-1 px-4 py-2.5 border border-gray-200 text-gray-700 font-bold rounded-xl hover:bg-gray-50 transition-colors">Cancel</button>
                                    <button type="submit" disabled={submitting} className="flex-1 px-4 py-2.5 bg-brand-600 text-white font-bold rounded-xl hover:bg-brand-700 transition-colors disabled:opacity-50">
                                        {submitting ? 'Saving...' : 'Save User'}
                                    </button>
                                </div>
                            </form>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>
        </motion.div>
    );
};

export default Users;
