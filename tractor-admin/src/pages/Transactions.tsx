import { useEffect, useState } from 'react';
import { Loader2, ArrowUpRight, DollarSign, Wallet } from 'lucide-react';
import { motion } from 'framer-motion';
import api from '../lib/api';
import toast from 'react-hot-toast';

const Transactions = () => {
    const [payouts, setPayouts] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchPayouts = async () => {
            try {
                const response = await api.get('/admin/payouts');
                setPayouts(response.data.payouts);
            } catch (err) {
                toast.error('Failed to load payout history');
            } finally {
                setLoading(false);
            }
        };
        fetchPayouts();
    }, []);

    return (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Financial Transactions</h1>
                    <p className="text-gray-500 mt-1 font-medium">Monitor payouts to operators and system earnings from completed operations.</p>
                </div>
                <div className="bg-brand-50 text-brand-700 px-4 py-2.5 rounded-xl border border-brand-100 flex items-center shadow-sm w-fit">
                    <DollarSign className="h-5 w-5 mr-2" />
                    <span className="font-bold text-sm">Automated Settlements Active</span>
                </div>
            </div>

            <div className="bg-white shadow-sm overflow-hidden rounded-2xl border border-gray-100">
                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-100">
                        <thead className="bg-gray-50/50">
                            <tr>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Transaction ID</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Operator</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Payout Amount</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">System Earning</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Type</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Date</th>
                                <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-50">
                            {loading ? (
                                <tr>
                                    <td colSpan={7} className="px-6 py-12 text-center">
                                        <Loader2 className="animate-spin h-8 w-8 text-brand-600 mx-auto" />
                                    </td>
                                </tr>
                            ) : payouts.length === 0 ? (
                               <tr>
                                 <td colSpan={7} className="px-6 py-12 text-center text-gray-500 font-medium">No transaction records found.</td>
                               </tr>
                            ) : (
                              payouts.map((p) => (
                                <motion.tr initial={{ opacity: 0 }} animate={{ opacity: 1 }} key={p.id} className="hover:bg-brand-50/30 transition-colors">
                                    <td className="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-600 font-mono tracking-wider">#{p.transaction_id}</td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <div className="text-sm font-bold text-gray-900">{p.operator_name}</div>
                                        <div className="text-xs font-medium text-gray-500 mt-0.5">{p.operator_phone}</div>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <div className="text-sm font-black text-gray-900">KES {Number(p.amount).toLocaleString()}</div>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        {p.system_fee ? (
                                            <div className="flex items-center text-sm font-bold text-green-700 bg-green-50 px-2.5 py-1 rounded-lg w-fit border border-green-100">
                                                <Wallet className="h-3.5 w-3.5 mr-1.5" />
                                                KES {Number(p.system_fee).toLocaleString()}
                                            </div>
                                        ) : (
                                            <span className="text-gray-400 text-sm font-medium ml-2">-</span>
                                        )}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <span className={`px-3 py-1.5 inline-flex text-xs font-bold rounded-xl border ${p.payout_type === 'first_half' ? 'bg-blue-50 text-blue-700 border-blue-100' : 'bg-purple-50 text-purple-700 border-purple-100'}`}>
                                            {p.payout_type === 'first_half' ? 'Advance' : 'Final Balance'}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                                        {new Date(p.created_at).toLocaleString()}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <span className="flex items-center text-green-600 text-sm font-bold">
                                            <ArrowUpRight className="h-4 w-4 mr-1" />
                                            Success
                                        </span>
                                    </td>
                                </motion.tr>
                              ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </motion.div>
    );
};

export default Transactions;
