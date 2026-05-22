import React, { useState, useEffect } from 'react';
import { Search, UserPlus, Star, Eye, ShieldCheck, Clock, XCircle } from 'lucide-react';
import api from '../utils/api';
import ProviderDetailsModal from '../components/ProviderDetailsModal';

const ProviderManagement = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [providers, setProviders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedProvider, setSelectedProvider] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [filter, setFilter] = useState('All');

  useEffect(() => {
    fetchProviders();
  }, []);

  const fetchProviders = async () => {
    try {
      const response = await api.get('/admin/providers');
      setProviders(response.data);
    } catch (error) {
      console.error('Error fetching providers:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleVerify = async (id, status, reason = '') => {
    try {
      await api.put(`/admin/providers/${id}/kyc`, { kycStatus: status, rejectionReason: reason });
      fetchProviders();
      setShowModal(false);
    } catch (error) {
      console.error('Error updating KYC status:', error);
    }
  };

  const filteredProviders = providers.filter(p => {
    const matchesSearch = p.fullName?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                          p.serviceType?.toLowerCase().includes(searchTerm.toLowerCase());
    
    if (filter === 'All') return matchesSearch;
    if (filter === 'Pending KYC') return matchesSearch && (p.kycStatus === 'Pending' || p.kycStatus === 'In Review');
    if (filter === 'Online') return matchesSearch && p.status === 'Online';
    return matchesSearch;
  });

  const getStatusStyle = (status) => {
    switch (status) {
      case 'Online': return { bg: '#DEF7EC', text: '#03543F' };
      case 'Offline': return { bg: '#F3F4F6', text: '#374151' };
      case 'Busy': return { bg: '#E1EFFE', text: '#1E429F' };
      case 'Blocked': return { bg: '#FDE8E8', text: '#9B1C1C' };
      default: return { bg: '#F3F4F6', text: '#374151' };
    }
  };

  return (
    <div className="animate-fade-in">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
        <div>
          <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Provider Management</h1>
          <p style={{ color: 'var(--text-muted)' }}>Manage and verify service providers on the platform.</p>
        </div>
        <button style={{
          backgroundColor: 'var(--primary)',
          color: 'white',
          border: 'none',
          padding: '12px 24px',
          borderRadius: '10px',
          fontWeight: '600',
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          cursor: 'pointer'
        }}>
          <UserPlus size={18} />
          Add Provider
        </button>
      </div>

      {/* Filter Bar */}
      <div className="glass-card" style={{ padding: '20px', marginBottom: '24px' }}>
        <div style={{ position: 'relative', maxWidth: '400px' }}>
          <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          <input
            type="text"
            placeholder="Search by name, phone or service..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{
              width: '100%',
              padding: '12px 12px 12px 42px',
              borderRadius: '8px',
              border: '1px solid var(--border)',
              outline: 'none',
              fontSize: '14px'
            }}
          />
        </div>
        <div style={{ display: 'flex', gap: '8px', marginTop: '16px' }}>
          {['All', 'Pending KYC', 'Online'].map((label) => (
            <button 
              key={label} 
              onClick={() => setFilter(label)}
              style={{
                padding: '6px 16px',
                borderRadius: '20px',
                border: '1px solid var(--border)',
                backgroundColor: filter === label ? 'rgba(2, 94, 243, 0.1)' : 'transparent',
                color: filter === label ? 'var(--primary)' : 'var(--text-muted)',
                fontSize: '13px',
                fontWeight: '600',
                cursor: 'pointer'
              }}>{label}</button>
          ))}
        </div>
      </div>

      {/* Table */}
      <div className="glass-card" style={{ overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
          <thead style={{ backgroundColor: '#F8FAFC' }}>
            <tr>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>PROVIDER</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>SERVICE</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>STATUS</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>KYC</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>RATING</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="6" style={{ padding: '32px', textAlign: 'center', color: 'var(--text-muted)' }}>Loading providers...</td></tr>
            ) : filteredProviders.map((p, i) => {
              const statusStyle = getStatusStyle(p.status);
              return (
                <tr key={p._id || i} style={{ borderTop: '1px solid var(--border)', transition: 'background-color 0.2s' }}>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div style={{ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: '#F1F5F9', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: '700', fontSize: '12px', color: 'var(--primary)' }}>
                        {p.fullName?.charAt(0)}
                      </div>
                      <span style={{ fontWeight: '600' }}>{p.fullName}</span>
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px', fontSize: '14px' }}>{p.serviceType}</td>
                  <td style={{ padding: '16px 24px' }}>
                    <span style={{
                      padding: '4px 8px',
                      borderRadius: '6px',
                      fontSize: '11px',
                      fontWeight: '700',
                      backgroundColor: statusStyle.bg,
                      color: statusStyle.text
                    }}>{(p.status || 'Offline').toUpperCase()}</span>
                  </td>
                  <td style={{ padding: '16px 24px', fontSize: '14px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: p.kycStatus === 'Verified' ? '#059669' : (p.kycStatus === 'Rejected' ? '#DC2626' : '#D97706') }}>
                      {p.kycStatus === 'Verified' ? <ShieldCheck size={16} /> : (p.kycStatus === 'Rejected' ? <XCircle size={16} /> : <Clock size={16} />)}
                      <span style={{ fontWeight: '600' }}>{p.kycStatus || 'Pending'}</span>
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '14px', fontWeight: '600' }}>
                      <Star size={14} fill="#F59E0B" color="#F59E0B" />
                      {p.rating || '5.0'}
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button 
                        onClick={() => { setSelectedProvider(p); setShowModal(true); }}
                        style={{ padding: '6px', borderRadius: '6px', border: '1px solid var(--border)', color: 'var(--text-muted)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}
                      >
                        <Eye size={18} />
                        {p.kycStatus === 'In Review' && <span style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: 'var(--primary)' }} />}
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      {/* Verification / Details Modal */}
      {showModal && selectedProvider && (
        <ProviderDetailsModal 
          provider={selectedProvider} 
          onClose={() => { setSelectedProvider(null); setShowModal(false); }} 
          onUpdate={fetchProviders}
        />
      )}
    </div>
  );
};

export default ProviderManagement;
