import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import ProviderList from './pages/ProviderList';
import ProviderManagement from './pages/ProviderManagement';
import ServiceList from './pages/ServiceList';
import ServiceForm from './pages/ServiceForm';
import CategoryList from './pages/CategoryList';
import BookingManagement from './pages/BookingManagement';
import UserManagement from './pages/UserManagement';
import Login from './pages/Login';
import { io } from 'socket.io-client';
import { Bell, X, ShieldCheck } from 'lucide-react';

const SOCKET_URL = 'http://localhost:4000'; // Backend URL

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [currentUser, setCurrentUser] = useState(null);
  const [isInitialized, setIsInitialized] = useState(false);
  const [notification, setNotification] = useState(null);

  // Socket logic
  useEffect(() => {
    if (!currentUser) return;

    const socket = io(SOCKET_URL);

    socket.on('kyc_submitted', (data) => {
      console.log('New KYC submission:', data);
      setNotification({
        id: data.id,
        title: 'New KYC Submission',
        message: `${data.fullName} has uploaded documents for verification.`,
        type: 'kyc'
      });

      // Auto-hide after 10 seconds
      setTimeout(() => setNotification(null), 10000);
    });

    return () => socket.disconnect();
  }, [currentUser]);

  // Check for existing session
  useEffect(() => {
    const storedUser = localStorage.getItem('adminUser');
    const token = localStorage.getItem('adminToken');
    
    if (storedUser && token) {
      setCurrentUser(JSON.parse(storedUser));
    }
    setIsInitialized(true);
  }, []);

  const handleLoginSuccess = (user) => {
    setCurrentUser(user);
    setActiveTab('dashboard');
  };

  const handleLogout = () => {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
    setCurrentUser(null);
    setActiveTab('dashboard'); // Reset to default state
  };

  // While checking for session, show nothing or a spinner
  if (!isInitialized) return null;

  // Render Login if not authenticated
  if (!currentUser) {
    return <Login onLoginSuccess={handleLoginSuccess} />;
  }

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard': return <Dashboard />;
      case 'providers-list': return <ProviderList />;
      case 'providers-add': return <ProviderManagement onUpdate={() => setActiveTab('providers-list')} />;
      case 'services-list': return <ServiceList />;
      case 'services-add': return <ServiceForm onUpdate={() => setActiveTab('services-list')} />;
      case 'categories-list': return <CategoryList />;
      case 'bookings': return <BookingManagement />;
      case 'users': return <UserManagement />;
      default: return <Dashboard />;
    }
  };

  return (
    <div className="flex">
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} onLogout={handleLogout} />
      <main style={{ 
        flex: 1, 
        marginLeft: '260px', 
        padding: '40px',
        backgroundColor: 'var(--bg-main)',
        minHeight: '100vh'
      }}>
        {renderContent()}
      </main>
      {/* Notification Toast */}
      {notification && (
        <div 
          className="animate-slide-in"
          style={{
            position: 'fixed',
            bottom: '24px',
            right: '24px',
            width: '320px',
            backgroundColor: 'white',
            borderRadius: '12px',
            boxShadow: '0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)',
            borderLeft: '4px solid var(--primary)',
            padding: '16px',
            zIndex: 9999,
            display: 'flex',
            gap: '12px'
          }}
        >
          <div style={{ 
            backgroundColor: 'rgba(2, 94, 243, 0.1)', 
            padding: '8px', 
            borderRadius: '8px',
            height: 'fit-content'
          }}>
            <ShieldCheck size={20} color="var(--primary)" />
          </div>
          <div style={{ flex: 1 }}>
            <h4 style={{ fontSize: '14px', fontWeight: '700', marginBottom: '4px' }}>{notification.title}</h4>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)', lineHeight: '1.4' }}>{notification.message}</p>
            <button 
              onClick={() => {
                setActiveTab('providers-add');
                setNotification(null);
              }}
              style={{
                marginTop: '10px',
                padding: '4px 0',
                backgroundColor: 'transparent',
                border: 'none',
                color: 'var(--primary)',
                fontSize: '12px',
                fontWeight: '700',
                cursor: 'pointer'
              }}
            >
              REVIEW NOW →
            </button>
          </div>
          <button 
            onClick={() => setNotification(null)}
            style={{ backgroundColor: 'transparent', border: 'none', cursor: 'pointer', height: 'fit-content', color: '#94A3B8' }}
          >
            <X size={16} />
          </button>
        </div>
      )}
    </div>
  );
}

export default App;
