import React, { useState, useEffect } from 'react';
import { Search, UserPlus, Star, Eye, ShieldCheck, Clock, XCircle, ChevronLeft, ChevronRight } from 'lucide-react';
import api from '../utils/api';
import ProviderDetailsModal from '../components/ProviderDetailsModal';

const ProviderManagement = () => {
  const [providers, setProviders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedProvider, setSelectedProvider] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [filter, setFilter] = useState('All');

  // Pagination states
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalProvidersCount, setTotalProvidersCount] = useState(0);
  const limit = 20;

  const fetchProviders = async () => {
    setLoading(true);
    try {
      const response = await api.get('/admin/providers', {
        params: {
          page,
          limit,
          search: searchTerm,
          filter
        }
      });
      setProviders(response.data.providers || []);
      setTotalPages(response.data.totalPages || 1);
      setTotalProvidersCount(response.data.total || 0);
    } catch (error) {
      console.error('Error fetching providers:', error);
    } finally {
      setLoading(false);
    }
  };

  // Debounce effect for search and filter changes
  useEffect(() => {
    const handler = setTimeout(() => {
      fetchProviders();
    }, 300);
    return () => clearTimeout(handler);
  }, [page, searchTerm, filter]);

  const toggleStatus = async (id, currentStatus) => {
    const nextStatus = currentStatus === 'Blocked' ? 'Offline' : 'Blocked';
    try {
      await api.put(`/admin/providers/${id}/status`, { status: nextStatus });
      fetchProviders();
    } catch (err) {
      console.error('Error updating status:', err);
      alert('Error updating status');
    }
  };

  const getStatusStyle = (status) => {
    switch (status) {
      case 'Online': return { bg: '#DEF7EC', text: '#03543F' };
      case 'Offline': return { bg: '#F3F4F6', text: '#374151' };
      case 'Busy': return { bg: '#E1EFFE', text: '#1E429F' };
      case 'Blocked': return { bg: '#FDE8E8', text: '#9B1C1C' };
      default: return { bg: '#F3F4F6', text: '#374151' };
    }
  };

  const handleSearchChange = (e) => {
    setSearchTerm(e.target.value);
    setPage(1);
  };

  const handleFilterChange = (newFilter) => {
    setFilter(newFilter);
    setPage(1);
  };

  const renderPageNumbers = () => {
    const pages = [];
    const maxVisiblePages = 5;
    
    let startPage = Math.max(1, page - 2);
    let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
    
    if (endPage - startPage < maxVisiblePages - 1) {
      startPage = Math.max(1, endPage - maxVisiblePages + 1);
    }
    
    for (let i = startPage; i <= endPage; i++) {
      pages.push(
        <button
          key={i}
          onClick={() => setPage(i)}
          style={{
            width: '36px',
            height: '36px',
            borderRadius: '6px',
            border: '1px solid var(--border)',
            backgroundColor: page === i ? 'var(--primary)' : 'white',
            color: page === i ? 'white' : 'var(--text-main)',
            cursor: 'pointer',
            fontSize: '13px',
            fontWeight: '700',
            transition: 'all 0.2s'
          }}
        >
          {i}
        </button>
      );
    }
    return pages;
  };

  return (
    <div className="animate-fade-in">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
        <div>
          <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Provider Management</h1>
          <p style={{ color: 'var(--text-muted)' }}>Manage, verify, activate or block service providers in the ecosystem.</p>
        </div>
      </div>

      {/* Filter Bar */}
      <div className="glass-card" style={{ padding: '20px', marginBottom: '24px' }}>
        <div style={{ position: 'relative', maxWidth: '400px' }}>
          <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          <input
            type="text"
            placeholder="Search by name, phone or service..."
            value={searchTerm}
            onChange={handleSearchChange}
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
          {['All', 'Pending KYC', 'Active', 'Blocked'].map((label) => (
            <button 
              key={label} 
              onClick={() => handleFilterChange(label)}
              style={{
                padding: '6px 16px',
                borderRadius: '20px',
                border: '1px solid var(--border)',
                backgroundColor: filter === label ? 'rgba(2, 94, 243, 0.1)' : 'transparent',
                color: filter === label ? 'var(--primary)' : 'var(--text-muted)',
                fontSize: '13px',
                fontWeight: '600',
                cursor: 'pointer',
                transition: 'all 0.2s'
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
              Array.from({ length: 5 }).map((_, idx) => (
                <tr key={idx} style={{ borderTop: '1px solid var(--border)' }}>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div className="skeleton" style={{ width: '32px', height: '32px', borderRadius: '50%' }} />
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                        <div className="skeleton" style={{ width: '120px', height: '14px' }} />
                        <div className="skeleton" style={{ width: '80px', height: '11px' }} />
                      </div>
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div className="skeleton" style={{ width: '100px', height: '14px' }} />
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div className="skeleton" style={{ width: '70px', height: '20px', borderRadius: '6px' }} />
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <div className="skeleton" style={{ width: '16px', height: '16px', borderRadius: '50%' }} />
                      <div className="skeleton" style={{ width: '60px', height: '14px' }} />
                    </div>
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div className="skeleton" style={{ width: '50px', height: '14px' }} />
                  </td>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <div className="skeleton" style={{ width: '75px', height: '28px', borderRadius: '6px' }} />
                      <div className="skeleton" style={{ width: '32px', height: '28px', borderRadius: '6px' }} />
                    </div>
                  </td>
                </tr>
              ))
            ) : providers.length === 0 ? (
              <tr><td colSpan="6" style={{ padding: '40px', textAlign: 'center', color: 'var(--text-muted)' }}>No providers found.</td></tr>
            ) : providers.map((p, i) => {
              const statusStyle = getStatusStyle(p.status);
              return (
                <tr key={p._id || i} style={{ borderTop: '1px solid var(--border)', transition: 'background-color 0.2s' }}>
                  <td style={{ padding: '16px 24px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div style={{ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: '#F1F5F9', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: '700', fontSize: '12px', color: 'var(--primary)' }}>
                        {p.fullName?.charAt(0)}
                      </div>
                      <div>
                        <span style={{ fontWeight: '600', display: 'block' }}>{p.fullName}</span>
                        <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{p.phoneNumber}</span>
                      </div>
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
                      {p.rating?.toFixed(1) || '5.0'}
                      <span style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '400' }}>({p.reviewCount || 0})</span>
                    </div>
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
                          cursor: 'pointer',
                          transition: 'all 0.2s'
                        }}
                      >
                        {p.status === 'Blocked' ? 'Activate' : 'Block'}
                      </button>
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

        {/* Pagination Footer */}
        {!loading && totalPages > 1 && (
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '16px 24px',
            borderTop: '1px solid var(--border)',
            backgroundColor: '#F8FAFC'
          }}>
            <span style={{ fontSize: '14px', color: 'var(--text-muted)' }}>
              Showing <strong>{((page - 1) * limit) + 1}</strong> to <strong>{Math.min(page * limit, totalProvidersCount)}</strong> of <strong>{totalProvidersCount}</strong> providers
            </span>
            <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
              <button
                onClick={() => setPage(prev => Math.max(prev - 1, 1))}
                disabled={page === 1}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                  padding: '8px 12px',
                  borderRadius: '6px',
                  border: '1px solid var(--border)',
                  backgroundColor: page === 1 ? '#F1F5F9' : 'white',
                  color: page === 1 ? '#94A3B8' : 'var(--text-main)',
                  cursor: page === 1 ? 'not-allowed' : 'pointer',
                  fontSize: '13px',
                  fontWeight: '600',
                  transition: 'all 0.2s'
                }}
              >
                <ChevronLeft size={16} />
                Previous
              </button>
              {renderPageNumbers()}
              <button
                onClick={() => setPage(prev => Math.min(prev + 1, totalPages))}
                disabled={page === totalPages}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                  padding: '8px 12px',
                  borderRadius: '6px',
                  border: '1px solid var(--border)',
                  backgroundColor: page === totalPages ? '#F1F5F9' : 'white',
                  color: page === totalPages ? '#94A3B8' : 'var(--text-main)',
                  cursor: page === totalPages ? 'not-allowed' : 'pointer',
                  fontSize: '13px',
                  fontWeight: '600',
                  transition: 'all 0.2s'
                }}
              >
                Next
                <ChevronRight size={16} />
              </button>
            </div>
          </div>
        )}
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
