import { useEffect, useState } from 'react';
import { Mail, Loader2, MessageSquare, Inbox, ExternalLink } from 'lucide-react';
import { motion } from 'framer-motion';
import api from '../lib/api';
import toast from 'react-hot-toast';

const SupportMessages = () => {
    const [messages, setMessages] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [replyingTo, setReplyingTo] = useState<number | null>(null);
    const [replyContent, setReplyContent] = useState('');
    const [submitting, setSubmitting] = useState(false);

    useEffect(() => {
        fetchMessages();
    }, []);

    const fetchMessages = async () => {
        try {
            const response = await api.get('/admin/messages');
            setMessages(response.data.messages);
        } catch (err) {
            toast.error('Failed to load support messages');
        } finally {
            setLoading(false);
        }
    };

    const submitReply = async (messageId: number) => {
        if (!replyContent.trim()) {
            toast.error('Please enter a response');
            return;
        }

        setSubmitting(true);
        try {
            await api.post('/admin/reply', { messageId, replyContent });
            toast.success('Response sent successfully');
            setReplyingTo(null);
            setReplyContent('');
            fetchMessages();
        } catch (err) {
            toast.error('Failed to send response');
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Support Inbox</h1>
                    <p className="text-gray-500 mt-1 font-medium">Read and respond to messages from farmers and operators on the platform.</p>
                </div>
            </div>

            <div className="bg-white shadow-sm overflow-hidden rounded-2xl border border-gray-100">
                <ul className="divide-y divide-gray-50">
                    {loading ? (
                        <li className="px-6 py-16 flex justify-center">
                            <Loader2 className="animate-spin h-10 w-10 text-brand-600" />
                        </li>
                    ) : messages.length === 0 ? (
                        <li className="px-6 py-16 text-center flex flex-col items-center">
                            <Inbox className="h-12 w-12 text-gray-300 mb-3" />
                            <p className="text-lg font-bold text-gray-900">Inbox Empty</p>
                            <p className="text-sm font-medium text-gray-500 mt-1">No support requests at the moment.</p>
                        </li>
                    ) : (
                        messages.map((message) => (
                            <motion.li initial={{ opacity: 0 }} animate={{ opacity: 1 }} key={message.id} className="hover:bg-brand-50/30 transition-colors">
                                <div className="p-6">
                                    <div className="flex items-start justify-between">
                                        <div className="flex flex-col">
                                            <p className="text-lg font-black text-gray-900">{message.subject}</p>
                                            <div className="flex items-center gap-2 mt-1">
                                                <Mail className="flex-shrink-0 h-4 w-4 text-brand-600" />
                                                <span className="text-sm font-medium text-gray-500">
                                                    From <span className="font-bold text-gray-900">{message.user_name}</span> 
                                                    <span className="px-2 py-0.5 ml-2 bg-gray-100 rounded-md text-xs font-bold capitalize text-gray-600">{message.user_role}</span>
                                                </span>
                                            </div>
                                        </div>
                                        <div className="flex flex-col items-end gap-2">
                                            <p className={`px-3 py-1 inline-flex text-xs font-bold rounded-xl border ${message.is_read ? 'bg-green-50 text-green-700 border-green-200' : 'bg-yellow-50 text-yellow-700 border-yellow-200'}`}>
                                                {message.is_read ? 'Resolved' : 'Requires Attention'}
                                            </p>
                                            <p className="text-xs font-medium text-gray-400">
                                                {new Date(message.created_at).toLocaleString()}
                                            </p>
                                        </div>
                                    </div>
                                    
                                    <div className="mt-5 text-sm text-gray-700 bg-gray-50 p-4 rounded-xl border border-gray-100 leading-relaxed font-medium">
                                        {message.content}
                                    </div>
                                    
                                    {!message.admin_id ? (
                                        <div className="mt-5">
                                            {replyingTo === message.id ? (
                                                <div className="bg-white border border-brand-200 rounded-xl p-4 shadow-sm">
                                                    <label htmlFor={`reply-${message.id}`} className="block text-sm font-semibold text-gray-700 mb-2">Your Response</label>
                                                    <textarea
                                                        id={`reply-${message.id}`}
                                                        rows={3}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-brand-500 focus:ring-brand-500 sm:text-sm p-3 border"
                                                        placeholder="Type your reply here..."
                                                        value={replyContent}
                                                        onChange={(e) => setReplyContent(e.target.value)}
                                                    />
                                                    <div className="mt-3 flex justify-end gap-3">
                                                        <button
                                                            onClick={() => {
                                                                setReplyingTo(null);
                                                                setReplyContent('');
                                                            }}
                                                            className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 focus:outline-none transition-colors"
                                                        >
                                                            Cancel
                                                        </button>
                                                        <button
                                                            onClick={() => submitReply(message.id)}
                                                            disabled={submitting}
                                                            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-brand-600 hover:bg-brand-700 focus:outline-none transition-colors disabled:opacity-50"
                                                        >
                                                            {submitting ? <Loader2 className="animate-spin mr-2 h-4 w-4" /> : <MessageSquare className="mr-2 h-4 w-4" />}
                                                            Send Reply
                                                        </button>
                                                    </div>
                                                </div>
                                            ) : (
                                                <div className="flex justify-end">
                                                    <button 
                                                        onClick={() => {
                                                            setReplyingTo(message.id);
                                                            setReplyContent('');
                                                        }}
                                                        className="inline-flex items-center px-5 py-2.5 border border-transparent text-sm font-bold rounded-xl shadow-sm text-white bg-brand-600 hover:bg-brand-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-500 transition-colors"
                                                    >
                                                        <MessageSquare className="mr-2 h-4 w-4" />
                                                        Reply to User
                                                    </button>
                                                </div>
                                            )}
                                        </div>
                                    ) : (
                                        <div className="mt-5 flex justify-end">
                                            <div className="inline-flex items-center text-sm font-bold text-gray-500 px-4 py-2 border border-gray-100 rounded-xl bg-gray-50">
                                                <ExternalLink className="mr-2 h-4 w-4 text-gray-400" />
                                                Administrator Responded
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </motion.li>
                        ))
                    )}
                </ul>
            </div>
        </motion.div>
    );
};

export default SupportMessages;
