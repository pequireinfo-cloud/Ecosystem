import React, { useState, useEffect } from 'react';
import { Search, UserPlus, Star, Eye, Edit2, ShieldCheck, Clock, XCircle, MoreVertical } from 'lucide-react';
import api from '../utils/api';
import ProviderDetailsModal from '../components/ProviderDetailsModal';

const ProviderList = () => {
  const [providers, setProviders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedProvider, setSelectedProvider] = useState(null);

  const fetchProviders = async () => {
    try {
      const res = await api.get('/admin/providers');
      setProviders(res.data);
    } catch (err) {
      console.error(err);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchProviders();
  }, []);

  const toggleStatus = async (id, currentStatus) => {
    const nextStatus = currentStatus === 'Blocked' ? 'Offline' : 'Blocked';
    try {
      await axios.put(`http://localhost:4000/api/admin/providers/${id}/status`, { status: nextStatus });
      fetchProviders();
    } catch (err) {
      alert('Error updating status');
    }
  };

  const filteredProviders = providers.filter(p => 
    p.fullName.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.serviceType.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="animate-fade-in">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
        <div>
          <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Providers List</h1>
          <p style={{ color: 'var(--text-muted)' }}>Manage and monitor service providers.</p>
        </div>
      </div>

      <div className="glass-card" style={{ padding: '20px', marginBottom: '24px' }}>
        <div style={{ position: 'relative', maxWidth: '400px' }}>
          <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          <input
            type="text"
            placeholder="Search by name or service..."
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
      </div>

      <div className="glass-card" style={{ overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
          <thead style={{ backgroundColor: '#F8FAFC' }}>
            <tr>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>PROVIDER</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>SERVICE</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>STATUS</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>RATING</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>KYC</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="6" style={{ padding: '40px', textAlign: 'center' }}>Loading...</td></tr>
            ) : filteredProviders.length === 0 ? (
              <tr><td colSpan="6" style={{ padding: '40px', textAlign: 'center' }}>No providers found.</td></tr>
            ) : filteredProviders.map((p) => (
                <tr key={p._id} style={{ borderTop: '1px solid var(--border)' }}>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                       <div style={{ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: '#F1F5F9', border: '1px solid var(--border)' }} />
                      <span style={{ fontWeight: '600' }}>{p.fullName}</span>
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px', fontSize: '14px' }}>{p.serviceType}</td>
                  <td style={{ padding: '16px 24px' }}>
                    <span style={{
                      padding: '4px 8px',
                      borderRadius: '6px',
                      fontSize: '11px',
                      fontWeight: '800',
                      backgroundColor: p.status === 'Blocked' ? '#FDE8E8' : (p.status === 'Online' ? '#DEF7EC' : '#F3F4F6'),
                      color: p.status === 'Blocked' ? '#9B1C1C' : (p.status === 'Online' ? '#03543F' : '#374151')
                    }}>{p.status?.toUpperCase() || 'OFFLINE'}</span>
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <Star size={14} fill="#F59E0B" color="#F59E0B" />
                      <span style={{ fontWeight: '700', fontSize: '14px' }}>{p.rating?.toFixed(1) || '5.0'}</span>
                      <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>({p.reviewCount || 0})</span>
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px', fontSize: '14px' }}>
                    <span style={{ fontWeight: '600', color: p.kycStatus === 'Verified' ? '#059669' : '#D97706' }}>{p.kycStatus}</span>
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button 
                        onClick={() => toggleStatus(p._id, p.status)}
                        style={{ 
                          padding: '6px 12px', 
                          borderRadius: '6px', 
                          border: '1px solid var(--border)', 
                          fontSize: '12px', 
                          fontWeight: '700',
                          backgroundColor: p.status === 'Blocked' ? '#05966910' : '#DC262610',
                          color: p.status === 'Blocked' ? '#059669' : '#DC2626',
                          cursor: 'pointer'
                        }}
                      >
                        {p.status === 'Blocked' ? 'Activate' : 'Block'}
                      </button>
                      <button 
                        onClick={() => setSelectedProvider(p)}
                        style={{ padding: '6px', borderRadius: '6px', border: '1px solid var(--border)', color: 'var(--text-muted)', cursor: 'pointer' }}
                      >
                        <Eye size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
            ))}
          </tbody>
        </table>
      </div>

      {selectedProvider && (
        <ProviderDetailsModal 
          provider={selectedProvider} 
          onClose={() => setSelectedProvider(null)} 
          onUpdate={fetchProviders}
        />
      )}
    </div>
  );
};

export default ProviderList;
