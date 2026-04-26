import { useEffect, useRef, useState } from 'react';
import { io, Socket } from 'socket.io-client';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Fix default Leaflet marker icon paths (broken by Vite bundler)
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
    iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

interface TractorMarkerState {
    tractorId: number;
    lat: number;
    lng: number;
    lastSeen: Date;
    marker: L.Marker;
}

const BACKEND_URL = import.meta.env.VITE_API_URL
    ? import.meta.env.VITE_API_URL.replace('/api', '')
    : 'http://localhost:5000';

const LiveMap = () => {
    const mapContainerRef = useRef<HTMLDivElement>(null);
    const mapRef = useRef<L.Map | null>(null);
    const socketRef = useRef<Socket | null>(null);
    const tractorMarkersRef = useRef<Map<number, TractorMarkerState>>(new Map());

    const [activeTractors, setActiveTractors] = useState<
        { tractorId: number; lat: number; lng: number; lastSeen: Date }[]
    >([]);
    const [isConnected, setIsConnected] = useState(false);

    // ------------------------------------------------------------------
    // Map initialisation (runs once)
    // ------------------------------------------------------------------
    useEffect(() => {
        if (!mapContainerRef.current || mapRef.current) return;

        mapRef.current = L.map(mapContainerRef.current, {
            center: [-1.286389, 36.817223], // Nairobi, Kenya default
            zoom: 10,
            zoomControl: true,
        });

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors',
            maxZoom: 19,
        }).addTo(mapRef.current);

        return () => {
            mapRef.current?.remove();
            mapRef.current = null;
        };
    }, []);

    // ------------------------------------------------------------------
    // Socket connection (runs once)
    // ------------------------------------------------------------------
    useEffect(() => {
        const token = localStorage.getItem('token');

        const socket = io(BACKEND_URL, {
            transports: ['websocket'],
            auth: { token },
        });

        socketRef.current = socket;

        socket.on('connect', () => setIsConnected(true));
        socket.on('disconnect', () => setIsConnected(false));

        // Listen for any tractor emitting its location
        socket.onAny((event: string, data: any) => {
            // Backend emits: `tractor_${tractorId}_location` with { tractorId, latitude, longitude }
            const match = event.match(/^tractor_(\d+)_location$/);
            if (!match || !data?.latitude || !data?.longitude) return;

            const tractorId = parseInt(match[1]);
            const lat = parseFloat(data.latitude);
            const lng = parseFloat(data.longitude);
            const now = new Date();

            if (!mapRef.current) return;

            const existing = tractorMarkersRef.current.get(tractorId);

            if (existing) {
                // Move existing marker
                existing.marker.setLatLng([lat, lng]);
                existing.lat = lat;
                existing.lng = lng;
                existing.lastSeen = now;
            } else {
                // Create new marker
                const marker = L.marker([lat, lng])
                    .addTo(mapRef.current!)
                    .bindPopup(`<b>Tractor #${tractorId}</b><br/>Live Position`);

                tractorMarkersRef.current.set(tractorId, {
                    tractorId,
                    lat,
                    lng,
                    lastSeen: now,
                    marker,
                });
            }

            // Update sidebar list
            setActiveTractors(
                Array.from(tractorMarkersRef.current.values()).map((t) => ({
                    tractorId: t.tractorId,
                    lat: t.lat,
                    lng: t.lng,
                    lastSeen: t.lastSeen,
                }))
            );
        });

        return () => {
            socket.disconnect();
        };
    }, []);

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------
    const focusTractor = (tractorId: number) => {
        const state = tractorMarkersRef.current.get(tractorId);
        if (state && mapRef.current) {
            mapRef.current.setView([state.lat, state.lng], 16);
            state.marker.openPopup();
        }
    };

    const secondsAgo = (date: Date) => {
        const diff = Math.floor((Date.now() - date.getTime()) / 1000);
        if (diff < 5) return 'just now';
        return `${diff}s ago`;
    };

    // ------------------------------------------------------------------
    // Render
    // ------------------------------------------------------------------
    return (
        <div className="flex flex-col gap-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Live Tractor Map</h1>
                    <p className="text-sm text-gray-500 mt-1">
                        Real-time GPS positions of all active tractors
                    </p>
                </div>
                <span
                    className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-bold ${
                        isConnected
                            ? 'bg-green-100 text-green-700'
                            : 'bg-gray-100 text-gray-500'
                    }`}
                >
                    <span
                        className={`h-2 w-2 rounded-full ${
                            isConnected ? 'bg-green-500 animate-pulse' : 'bg-gray-400'
                        }`}
                    />
                    {isConnected ? 'CONNECTED' : 'CONNECTING…'}
                </span>
            </div>

            <div className="flex gap-4" style={{ height: '70vh' }}>
                {/* Map */}
                <div
                    ref={mapContainerRef}
                    className="flex-1 rounded-2xl overflow-hidden border border-gray-200 shadow-sm z-0"
                />

                {/* Sidebar */}
                <div className="w-64 flex flex-col gap-3 overflow-y-auto">
                    <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">
                        Active Tractors ({activeTractors.length})
                    </p>

                    {activeTractors.length === 0 ? (
                        <div className="flex flex-col items-center justify-center h-full text-center px-4 py-12 bg-white rounded-xl border border-gray-100">
                            <span className="text-4xl mb-3">🚜</span>
                            <p className="text-sm text-gray-500">
                                No tractors broadcasting yet.
                            </p>
                            <p className="text-xs text-gray-400 mt-1">
                                Markers will appear as operators go live.
                            </p>
                        </div>
                    ) : (
                        activeTractors.map((t) => (
                            <button
                                key={t.tractorId}
                                onClick={() => focusTractor(t.tractorId)}
                                className="w-full text-left bg-white rounded-xl border border-gray-100 hover:border-green-300 hover:shadow-md p-4 transition-all group"
                            >
                                <div className="flex items-center gap-3 mb-2">
                                    <div className="h-8 w-8 rounded-full bg-green-100 flex items-center justify-center">
                                        <span className="text-green-700 text-lg">🚜</span>
                                    </div>
                                    <div>
                                        <p className="text-sm font-semibold text-gray-900 group-hover:text-green-700">
                                            Tractor #{t.tractorId}
                                        </p>
                                        <p className="text-xs text-gray-400">
                                            Updated {secondsAgo(t.lastSeen)}
                                        </p>
                                    </div>
                                </div>
                                <p className="text-xs text-gray-500 font-mono">
                                    {t.lat.toFixed(5)}, {t.lng.toFixed(5)}
                                </p>
                            </button>
                        ))
                    )}
                </div>
            </div>
        </div>
    );
};

export default LiveMap;
