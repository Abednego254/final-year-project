import { useState, useRef, useEffect } from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { 
    LayoutDashboard, 
    CalendarDays, 
    Tractor, 
    Settings, 
    Menu, 
    Bell, 
    MessageSquare, 
    HandCoins,
    Users,
    LogOut,
    ChevronDown
} from 'lucide-react';
import { Toaster } from 'react-hot-toast';
import { useAuth } from '../../hooks/useAuth';

const Layout = () => {
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const [profileOpen, setProfileOpen] = useState(false);
    const location = useLocation();
    const { logout } = useAuth();
    const profileRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        function handleClickOutside(event: MouseEvent) {
            if (profileRef.current && !profileRef.current.contains(event.target as Node)) {
                setProfileOpen(false);
            }
        }
        document.addEventListener("mousedown", handleClickOutside);
        return () => document.removeEventListener("mousedown", handleClickOutside);
    }, []);

    const navigation = [
        { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
        { name: 'Bookings', href: '/bookings', icon: CalendarDays },
        { name: 'Tractors', href: '/tractors', icon: Tractor },
        { name: 'Users', href: '/users', icon: Users },
        { name: 'Transactions', href: '/transactions', icon: HandCoins },
        { name: 'Support', href: '/messages', icon: MessageSquare },
        { name: 'Settings', href: '/settings', icon: Settings },
    ];

    return (
        <div className="min-h-screen bg-gray-50 flex font-sans">
            <Toaster 
                position="top-right" 
                reverseOrder={false} 
                toastOptions={{
                    success: {
                        style: {
                            background: '#16a34a', // text-green-600
                            color: '#fff',
                        },
                        iconTheme: {
                            primary: '#fff',
                            secondary: '#16a34a',
                        },
                    },
                    error: {
                        style: {
                            background: '#dc2626', // text-red-600
                            color: '#fff',
                        },
                        iconTheme: {
                            primary: '#fff',
                            secondary: '#dc2626',
                        },
                    },
                }}
            />
            
            {/* Mobile sidebar backdrop */}
            {sidebarOpen && (
                <div
                    className="fixed inset-0 z-20 bg-gray-900/60 lg:hidden backdrop-blur-sm transition-opacity"
                    onClick={() => setSidebarOpen(false)}
                />
            )}

            {/* Sidebar */}
            <aside className={`
        fixed inset-y-0 left-0 z-30 w-64 bg-white border-r border-gray-200 transform transition-all duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0
        ${sidebarOpen ? 'translate-x-0 shadow-2xl' : '-translate-x-full shadow-none'}
      `}>
                <div className="h-16 flex items-center px-6 border-b border-gray-100 bg-white shadow-sm">
                    <img src="/logo.png" alt="TractorApp Logo" className="h-[28px] object-contain" />
                    <span className="ml-3 text-2xl font-bold text-gray-900 tracking-tight">Tractor<span className="font-medium text-brand-600">App</span></span>
                </div>

                <nav className="p-4 space-y-1.5 overflow-y-auto h-[calc(100vh-4rem-60px)]">
                    {navigation.map((item) => {
                        const isActive = location.pathname === item.href;
                        const Icon = item.icon;
                        return (
                            <Link
                                key={item.name}
                                to={item.href}
                                onClick={() => setSidebarOpen(false)}
                                className={`
                  flex items-center px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200
                  ${isActive
                                        ? 'bg-brand-50 text-brand-700 shadow-sm border border-brand-100'
                                        : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                                    }
                `}
                            >
                                <Icon className={`mr-3 h-5 w-5 ${isActive ? 'text-brand-600' : 'text-gray-400 group-hover:text-gray-600'}`} />
                                {item.name}
                            </Link>
                        );
                    })}
                </nav>

                <div className="absolute bottom-0 w-64 p-4 border-t border-gray-100 bg-gray-50/50">
                    <button 
                        onClick={() => logout()}
                        className="flex items-center w-full px-4 py-3 text-sm font-medium text-red-600 rounded-xl hover:bg-red-50 transition-colors"
                    >
                        <LogOut className="mr-3 h-5 w-5" />
                        Sign Out
                    </button>
                </div>
            </aside>

            {/* Main content */}
            <div className="flex-1 flex flex-col min-w-0 h-screen">
                {/* Top Header */}
                <header className="bg-white border-b border-gray-200 h-16 flex items-center justify-between px-4 sm:px-6 lg:px-8 z-10">
                    <button
                        onClick={() => setSidebarOpen(true)}
                        className="lg:hidden p-2 rounded-lg text-gray-500 hover:bg-gray-100 transition-colors"
                    >
                        <Menu className="h-6 w-6" />
                    </button>

                    <div className="flex-1" />

                    <div className="flex items-center gap-4">
                        <button className="p-2 text-gray-400 hover:text-brand-600 bg-gray-50 rounded-full transition-all hover:scale-110 relative">
                            <span className="sr-only">View notifications</span>
                            <Bell className="h-5 w-5" />
                            <span className="absolute top-2 right-2 h-2 w-2 bg-red-500 rounded-full border border-white"></span>
                        </button>
                        <div className="relative" ref={profileRef}>
                            <button 
                                onClick={() => setProfileOpen(!profileOpen)}
                                className="flex items-center gap-3 pl-4 border-l border-gray-200 focus:outline-none hover:bg-gray-50 rounded-lg p-1 pr-2 transition-colors cursor-pointer"
                            >
                                <div className="flex flex-col items-end hidden sm:flex">
                                    <span className="text-sm font-semibold text-gray-900 leading-none">Admin</span>
                                    <span className="text-xs text-gray-500 mt-1 uppercase tracking-wider font-bold">Manager</span>
                                </div>
                                <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-brand-500 to-brand-700 flex items-center justify-center text-white font-bold shadow-md relative overflow-hidden group">
                                    <div className="absolute inset-0 bg-black/10 group-hover:bg-transparent transition-colors"></div>
                                    A
                                </div>
                                <ChevronDown className={`h-4 w-4 text-gray-500 transition-transform duration-200 ${profileOpen ? 'rotate-180' : ''}`} />
                            </button>

                            {profileOpen && (
                                <div className="absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-lg border border-gray-200 py-1 z-50">
                                    <div className="px-4 py-3 border-b border-gray-100 sm:hidden">
                                        <p className="text-sm font-semibold text-gray-900">Admin</p>
                                        <p className="text-xs font-medium text-gray-500 truncate">Manager</p>
                                    </div>
                                    <button
                                        onClick={() => {
                                            setProfileOpen(false);
                                            logout();
                                        }}
                                        className="w-full text-left flex items-center px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors font-medium cursor-pointer"
                                    >
                                        <LogOut className="mr-3 h-4 w-4" />
                                        Sign Out
                                    </button>
                                </div>
                            )}
                        </div>
                    </div>
                </header>

                {/* Page Content */}
                <main className="flex-1 overflow-y-auto bg-gray-50 relative">
                    <div className="absolute inset-0 pointer-events-none overflow-hidden opacity-[0.03] flex items-center justify-center z-0">
                        <img src="/logo.png" alt="watermark" className="w-[80vw] max-w-[800px] grayscale mix-blend-multiply object-contain transform -rotate-12 scale-150" />
                    </div>
                    <div className="py-8 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto relative z-10">
                        <Outlet />
                    </div>
                </main>
            </div>
        </div>
    );
};

export default Layout;
