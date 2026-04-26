import React, { useState } from 'react';
import logo from '../assets/logo.webp';
import wordmark from '../assets/wordmark.webp';
import { 
  LayoutDashboard, 
  Users, 
  Map as MapIcon, 
  BookOpen, 
  BarChart3, 
  Settings, 
  LogOut,
  ChevronDown,
  ChevronRight,
  PlusCircle,
  List,
  Layers
} from 'lucide-react';

const Sidebar = ({ activeTab, setActiveTab, onLogout }) => {
  const [expandedMenus, setExpandedMenus] = useState({
    providers: true,
    services: true,
    categories: false
  });

  const toggleMenu = (menu) => {
    setExpandedMenus(prev => ({ ...prev, [menu]: !prev[menu] }));
  };

  const menuItems = [
    { id: 'dashboard', icon: LayoutDashboard, label: 'Dashboard', type: 'link' },
    { 
      id: 'providers', 
      icon: Users, 
      label: 'Providers', 
      type: 'menu',
      subItems: [
        { id: 'providers-add', label: 'Add Provider', icon: PlusCircle },
        { id: 'providers-list', label: 'Providers List', icon: List },
      ]
    },
    { 
      id: 'services', 
      icon: Layers, 
      label: 'Services', 
      type: 'menu',
      subItems: [
        { id: 'services-add', label: 'Add Service', icon: PlusCircle },
        { id: 'services-list', label: 'Services List', icon: List },
      ]
    },
    { 
      id: 'categories', 
      icon: BookOpen, 
      label: 'Categories', 
      type: 'menu',
      subItems: [
        { id: 'categories-list', label: 'Categories List', icon: List },
      ]
    },
    { id: 'bookings', icon: BookOpen, label: 'Bookings', type: 'link' },
    { id: 'users', icon: Users, label: 'Users', type: 'link' },
  ];

  const isActive = (id) => activeTab === id || activeTab.startsWith(id + '-');

  return (
    <div className="sidebar" style={{
      width: '260px',
      height: '100vh',
      backgroundColor: 'var(--bg-sidebar)',
      color: 'white',
      display: 'flex',
      flexDirection: 'column',
      padding: '24px 16px',
      position: 'fixed',
      left: 0,
      top: 0,
      overflowY: 'auto'
    }}>
      {/* Logo Section */}
      <div className="logo-container" style={{
        display: 'flex',
        alignItems: 'center',
        padding: '0 8px 32px 8px',
        gap: '12px'
      }}>
        <img src={logo} alt="Pequire Logo" style={{ height: '32px', width: 'auto', filter: 'brightness(0) invert(1)' }} />
        <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
          <img src={wordmark} alt="Pequire" style={{ height: '18px', width: 'auto', filter: 'brightness(0) invert(1)' }} />
          <span style={{ 
            fontSize: '10px', 
            fontWeight: '800', 
            letterSpacing: '1.5px', 
            color: '#60A5FA',
            backgroundColor: 'rgba(30, 64, 175, 0.3)',
            padding: '2px 6px',
            borderRadius: '4px',
            width: 'fit-content'
          }}>ADMIN</span>
        </div>
      </div>

      {/* Navigation Links */}
      <nav style={{ flex: 1 }}>
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isLink = item.type === 'link';
          const isMenuExpanded = expandedMenus[item.id];
          const itemActive = isActive(item.id);

          return (
            <div key={item.id} style={{ marginBottom: '4px' }}>
              {/* Main Item */}
              <div
                onClick={() => isLink ? setActiveTab(item.id) : toggleMenu(item.id)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  padding: '12px 16px',
                  borderRadius: '10px',
                  cursor: 'pointer',
                  transition: 'all 0.2s',
                  backgroundColor: (isLink && itemActive) ? 'rgba(59, 130, 246, 0.15)' : 'transparent',
                  color: (isLink && itemActive) ? 'white' : '#94A3B8'
                }}
              >
                <Icon size={20} style={{ 
                  marginRight: '16px', 
                  color: (isLink && itemActive) ? 'var(--primary)' : '#94A3B8' 
                }} />
                <span style={{ fontWeight: (isLink && itemActive) ? '600' : '400', flex: 1 }}>{item.label}</span>
                {!isLink && (
                  isMenuExpanded ? <ChevronDown size={14} /> : <ChevronRight size={14} />
                )}
              </div>

              {/* Sub Items */}
              {!isLink && isMenuExpanded && (
                <div style={{ marginLeft: '12px', borderLeft: '1px solid rgba(255,255,255,0.05)', marginTop: '4px' }}>
                  {item.subItems.map((sub) => {
                    const SubIcon = sub.icon;
                    const isSubActive = activeTab === sub.id;
                    return (
                      <div
                        key={sub.id}
                        onClick={() => setActiveTab(sub.id)}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          padding: '10px 16px 10px 24px',
                          borderRadius: '8px',
                          cursor: 'pointer',
                          fontSize: '13px',
                          color: isSubActive ? 'white' : '#64748B',
                          backgroundColor: isSubActive ? 'rgba(59, 130, 246, 0.05)' : 'transparent'
                        }}
                      >
                        <SubIcon size={14} style={{ marginRight: '12px' }} />
                        <span style={{ fontWeight: isSubActive ? '600' : '400' }}>{sub.label}</span>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </nav>

      {/* Footer Section */}
      <div style={{ borderTop: '1px solid rgba(255,255,255,0.05)', paddingTop: '16px' }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          padding: '12px 16px',
          color: '#94A3B8',
          cursor: 'pointer',
          borderRadius: '10px'
        }}>
          <Settings size={20} style={{ marginRight: '16px' }} />
          <span>Settings</span>
        </div>
        <div 
          onClick={onLogout}
          style={{
            display: 'flex',
            alignItems: 'center',
            padding: '12px 16px',
            color: '#F87171',
            cursor: 'pointer',
            borderRadius: '10px',
            marginTop: '4px'
          }}
        >
          <LogOut size={20} style={{ marginRight: '16px' }} />
          <span>Logout</span>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;


