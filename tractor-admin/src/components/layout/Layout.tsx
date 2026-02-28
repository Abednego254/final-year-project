import React, { useState } from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, CalendarDays, Tractor, Settings, Menu, Bell } from 'lucide-react';

const Layout = () => {
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const location = useLocation();

    const navigation = [
        { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
        { name: 'Bookings', href: '/bookings', icon: CalendarDays },
        { name: 'Tractors', href: '/tractors', icon: Tractor },
        { name: 'Settings', href: '/settings', icon: Settings },
    ];

    return (
        <div className="min-h-screen bg-gray-50 flex">
            {/* Mobile sidebar backdrop */}
            {sidebarOpen && (
                <div
                    className="fixed inset-0 z-20 bg-gray-900/50 lg:hidden"
                    onClick={() => setSidebarOpen(false)}
                />
            )}

            {/* Sidebar */}
            <div className={`
        fixed inset-y-0 left-0 z-30 w-64 bg-white border-r border-gray-200 transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0
        ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
      `}>
                <div className="h-16 flex items-center px-6 border-b border-gray-200">
                    <Tractor className="h-8 w-8 text-brand-600" />
                    <span className="ml-3 text-xl font-bold text-gray-900">TractorAdmin</span>
                </div>

                <nav className="p-4 space-y-1">
                    {navigation.map((item) => {
                        const isActive = location.pathname.startsWith(item.href);
                        const Icon = item.icon;
                        return (
                            <Link
                                key={item.name}
                                to={item.href}
                                className={`
                  flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors
                  ${isActive
                                        ? 'bg-brand-50 text-brand-700'
                                        : 'text-gray-700 hover:bg-gray-100'
                                    }
                `}
                            >
                                <Icon className={`mr-3 h-5 w-5 ${isActive ? 'text-brand-600' : 'text-gray-400'}`} />
                                {item.name}
                            </Link>
                        );
                    })}
                </nav>
            </div>

            {/* Main content */}
            <div className="flex-1 flex flex-col min-w-0">
                {/* Top Header */}
                <header className="bg-white shadow-sm border-b border-gray-200 h-16 flex items-center justify-between px-4 sm:px-6 lg:px-8">
                    <button
                        onClick={() => setSidebarOpen(true)}
                        className="lg:hidden p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100"
                    >
                        <Menu className="h-6 w-6" />
                    </button>

                    <div className="flex-1" />

                    <div className="flex items-center gap-4">
                        <button className="p-2 text-gray-400 hover:text-gray-500 bg-gray-50 rounded-full">
                            <span className="sr-only">View notifications</span>
                            <Bell className="h-5 w-5" />
                        </button>
                        <div className="flex items-center gap-3 pl-4 border-l border-gray-200">
                            <div className="h-8 w-8 rounded-full bg-brand-100 flex items-center justify-center text-brand-700 font-bold">
                                A
                            </div>
                            <span className="text-sm font-medium text-gray-700 hidden sm:block">Admin User</span>
                        </div>
                    </div>
                </header>

                {/* Page Content */}
                <main className="flex-1 overflow-y-auto">
                    <div className="py-6 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
                        <Outlet />
                    </div>
                </main>
            </div>
        </div>
    );
};

export default Layout;
