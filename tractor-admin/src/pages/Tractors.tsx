import React, { useEffect, useState } from 'react';
import { Tractor, Plus, MapPin, Loader2 } from 'lucide-react';
import api from '../lib/api';

const Tractors = () => {
    const [tractors, setTractors] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchTractors = async () => {
            try {
                const response = await api.get('/admin/tractors');
                setTractors(response.data.tractors);
            } catch (err) {
                setError('Failed to load tractors.');
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        fetchTractors();
    }, []);

    const getStatusColor = (status: string) => {
        switch (status) {
            case 'available': return 'bg-green-100 text-green-800';
            case 'busy': return 'bg-blue-100 text-blue-800';
            case 'maintenance': return 'bg-red-100 text-red-800';
            default: return 'bg-gray-100 text-gray-800';
        }
    };

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
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Registered Tractors</h1>
                    <p className="mt-2 text-sm text-gray-700">A list of all farm-ploughing tractors currently operating on the platform.</p>
                </div>
                <div className="mt-4 sm:mt-0 flex space-x-3">
                    <button className="inline-flex items-center px-4 py-2 bg-brand-600 border border-transparent rounded-md shadow-sm text-sm font-medium text-white hover:bg-brand-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-500">
                        <Plus className="-ml-1 mr-2 h-4 w-4" />
                        Add Tractor
                    </button>
                </div>
            </div>

            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
                {tractors.length === 0 ? (
                    <div className="col-span-full p-10 text-center text-gray-500 bg-white rounded-lg shadow border border-gray-200">
                        No tractors registered on the platform yet.
                    </div>
                ) : tractors.map((tractor) => (
                    <div key={tractor.id} className="bg-white rounded-lg shadow border border-gray-200 overflow-hidden hover:shadow-md transition-shadow">
                        <div className="p-6">
                            <div className="flex items-center justify-between">
                                <div className="flex items-center">
                                    <div className="p-2 bg-brand-50 rounded-lg">
                                        <Tractor className="h-6 w-6 text-brand-600" />
                                    </div>
                                    <div className="ml-4">
                                        <h3 className="text-lg font-medium text-gray-900">{tractor.license_plate}</h3>
                                        <p className="text-sm text-gray-500">{tractor.model}</p>
                                    </div>
                                </div>
                                <span className={`inline-flex items-center flex-shrink-0 ml-2 px-2.5 py-0.5 rounded-full text-xs font-medium capitalize ${getStatusColor(tractor.status)}`}>
                                    {tractor.status}
                                </span>
                            </div>

                            <div className="mt-6 border-t border-gray-100 pt-4">
                                <dl className="grid grid-cols-1 gap-x-4 gap-y-4 sm:grid-cols-2">
                                    <div className="sm:col-span-2">
                                        <dt className="text-sm font-medium text-gray-500">Operator</dt>
                                        <dd className="mt-1 text-sm text-gray-900 font-medium">{tractor.operator_name}</dd>
                                    </div>
                                    <div className="sm:col-span-2">
                                        <dt className="text-sm font-medium text-gray-500 flex items-center">
                                            <MapPin className="h-4 w-4 mr-1 text-gray-400" />
                                            Status Profile
                                        </dt>
                                        <dd className="mt-1 text-sm text-gray-900">Registered: {new Date(tractor.created_at).toLocaleDateString()}</dd>
                                    </div>
                                </dl>
                            </div>
                        </div>
                        <div className="bg-gray-50 px-6 py-3 border-t border-gray-100 text-center">
                            <a href="#" className="text-sm font-medium text-brand-600 hover:text-brand-900">
                                View tracking history
                            </a>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default Tractors;
