import React, { useState } from 'react';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import ProviderList from './pages/ProviderList';
import ServiceForm from './pages/ServiceForm';
import ServiceList from './pages/ServiceList';
import CategoryList from './pages/CategoryList';
import BookingManagement from './pages/BookingManagement';
import { UserPlus } from 'lucide-react';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard />;
      case 'providers-list':
        return <ProviderList />;
      case 'providers-add':
        return (
          <div className="flex-center" style={{ height: '60vh', flexDirection: 'column', gap: '20px' }}>
            <div style={{ padding: '24px', borderRadius: '50%', backgroundColor: 'rgba(2, 94, 243, 0.1)', color: 'var(--primary)' }}>
              <UserPlus size={48} />
            </div>
            <h2 style={{ fontSize: '24px', fontWeight: '800' }}>Add Provider Flow</h2>
            <p style={{ color: 'var(--text-muted)', maxWidth: '400px', textAlign: 'center' }}>
              Providers typically register via the Mobile App. Use this section to manually invite or onboard premium business partners.
            </p>
            <button style={{ 
              backgroundColor: 'var(--primary)', 
              color: 'white', 
              border: 'none', 
              padding: '12px 24px', 
              borderRadius: '10px', 
              fontWeight: '700' 
            }}>Launch Onboarding Wizard</button>
          </div>
        );
      case 'services-add':
        return <ServiceForm />;
      case 'services-list':
        return <ServiceList />;
      case 'categories-list':
        return <CategoryList />;
      case 'bookings':
        return <BookingManagement />;
      case 'live-map':
        return (
          <div className="flex-center" style={{ height: '70vh', backgroundColor: '#e2e8f0', borderRadius: '16px', color: '#64748b' }}>
            <p style={{ fontWeight: 'bold' }}>Live Provider Tracking Map (Interactive)</p>
          </div>
        );
      default:
        return <Dashboard />;
    }
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: 'var(--bg-main)' }}>
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />
      
      <main style={{ 
        marginLeft: '260px', 
        flex: 1, 
        padding: '32px',
        maxWidth: '1280px',
        margin: '0 auto 0 260px',
        width: 'calc(100% - 260px)'
      }}>
        {/* Top Navbar */}
        <div style={{ 
          display: 'flex', 
          justifyContent: 'flex-end', 
          alignItems: 'center', 
          marginBottom: '40px',
          gap: '24px'
        }}>
          <div style={{ 
            width: '40px', 
            height: '40px', 
            borderRadius: '12px', 
            backgroundColor: 'white',
            border: '1px solid var(--border)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'var(--text-muted)',
            cursor: 'pointer'
          }}>
            <span style={{ fontSize: '18px' }}>🔔</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ textAlign: 'right' }}>
              <p style={{ fontSize: '14px', fontWeight: '800' }}>Anurag Admin</p>
              <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>System Administrator</p>
            </div>
            <div style={{ 
              width: '44px', 
              height: '44px', 
              borderRadius: '14px', 
              backgroundColor: 'var(--primary)',
              color: 'white',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: '900',
              fontSize: '18px',
              boxShadow: '0 4px 12px rgba(2, 94, 243, 0.3)'
            }}>AA</div>
          </div>
        </div>

        {/* Dynamic Page Content */}
        <div className="page-container" style={{ minHeight: 'calc(100vh - 120px)' }}>
          {renderContent()}
        </div>
      </main>
    </div>
  );
}

export default App;
