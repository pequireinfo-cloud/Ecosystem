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

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [currentUser, setCurrentUser] = useState(null);
  const [isInitialized, setIsInitialized] = useState(false);

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
    </div>
  );
}

export default App;
