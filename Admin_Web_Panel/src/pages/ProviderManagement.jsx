import React, { useState } from 'react';
import { Search, UserPlus, Star, Eye, Edit2, ShieldCheck, Clock, XCircle } from 'lucide-react';

const ProviderManagement = () => {
  const [searchTerm, setSearchTerm] = useState('');

  const providers = [
    { name: 'Amit Kumar', service: 'Electrician', status: 'Online', kyc: 'Verified', rating: '4.8' },
    { name: 'Suresh Patel', service: 'Plumber', status: 'Offline', kyc: 'Pending', rating: '4.5' },
    { name: 'Rahul Sharma', service: 'Appliance Repair', status: 'On Job', kyc: 'Verified', rating: '4.9' },
    { name: 'Vikram Singh', service: 'Carpenter', status: 'Banned', kyc: 'Rejected', rating: '3.2' },
  ];

  const getStatusStyle = (status) => {
    switch (status) {
      case 'Online': return { bg: '#DEF7EC', text: '#03543F' };
      case 'On Job': return { bg: '#E1EFFE', text: '#1E429F' };
      case 'Banned': return { bg: '#FDE8E8', text: '#9B1C1C' };
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
          {['All', 'Pending KYC', 'Online', 'Suspended'].map((label) => (
            <button key={label} style={{
              padding: '6px 16px',
              borderRadius: '20px',
              border: '1px solid var(--border)',
              backgroundColor: label === 'All' ? 'rgba(2, 94, 243, 0.1)' : 'transparent',
              color: label === 'All' ? 'var(--primary)' : 'var(--text-muted)',
              fontSize: '13px',
              fontWeight: '600'
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
            {providers.map((p, i) => {
              const statusStyle = getStatusStyle(p.status);
              return (
                <tr key={i} style={{ borderTop: '1px solid var(--border)', transition: 'background-color 0.2s' }}>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div style={{ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: '#F1F5F9', border: '1px solid var(--border)' }} />
                      <span style={{ fontWeight: '600' }}>{p.name}</span>
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px', fontSize: '14px' }}>{p.service}</td>
                  <td style={{ padding: '16px 24px' }}>
                    <span style={{
                      padding: '4px 8px',
                      borderRadius: '6px',
                      fontSize: '11px',
                      fontWeight: '700',
                      backgroundColor: statusStyle.bg,
                      color: statusStyle.text
                    }}>{p.status.toUpperCase()}</span>
                  </td>
                  <td style={{ padding: '16px 24px', fontSize: '14px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: p.kyc === 'Verified' ? '#059669' : (p.kyc === 'Pending' ? '#D97706' : '#DC2626') }}>
                      {p.kyc === 'Verified' ? <ShieldCheck size={16} /> : (p.kyc === 'Pending' ? <Clock size={16} /> : <XCircle size={16} />)}
                      <span style={{ fontWeight: '600' }}>{p.kyc}</span>
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '14px', fontWeight: '600' }}>
                      <Star size={14} fill="#F59E0B" color="#F59E0B" />
                      {p.rating}
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button style={{ padding: '6px', borderRadius: '6px', border: '1px solid var(--border)', color: 'var(--text-muted)', cursor: 'pointer' }}><Eye size={18} /></button>
                      <button style={{ padding: '6px', borderRadius: '6px', border: '1px solid var(--border)', color: 'var(--text-muted)', cursor: 'pointer' }}><Edit2 size={16} /></button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ProviderManagement;
