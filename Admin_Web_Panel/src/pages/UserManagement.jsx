import React, { useState, useEffect } from 'react';
import { Users, UserCheck, ShieldCheck, Clock, Search, Filter, MoreHorizontal, Mail, Phone, Calendar, Star, ChevronLeft, ChevronRight } from 'lucide-react';
import api from '../utils/api';

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [stats, setStats] = useState({
    total: 0,
    active: 0,
    verified: 0,
    pending: 0
  });
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');

  // Pagination states
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalUsersCount, setTotalUsersCount] = useState(0);
  const limit = 20;

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const res = await api.get('/admin/users', {
        params: {
          page,
          limit,
          search: searchTerm,
          filter: filterStatus
        }
      });
      setUsers(res.data.users || []);
      setStats(res.data.stats || { total: 0, active: 0, verified: 0, pending: 0 });
      setTotalPages(res.data.totalPages || 1);
      setTotalUsersCount(res.data.total || 0);
    } catch (err) {
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  // Debounced fetch for page, search, and filter status
  useEffect(() => {
    const handler = setTimeout(() => {
      fetchUsers();
    }, 300);
    return () => clearTimeout(handler);
  }, [page, searchTerm, filterStatus]);

  const handleSearchChange = (e) => {
    setSearchTerm(e.target.value);
    setPage(1); // Reset page on new search
  };

  const handleFilterChange = (e) => {
    setFilterStatus(e.target.value);
    setPage(1); // Reset page on new filter
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return '#10B981';
      case 'inactive': return '#94A3B8';
      case 'blocked': return '#EF4444';
      default: return '#94A3B8';
    }
  };

  const getKYCColor = (status) => {
    switch (status) {
      case 'verified': return { bg: '#DEF7EC', text: '#03543F', label: 'Verified' };
      case 'pending': return { bg: '#FEF3C7', text: '#92400E', label: 'Pending' };
      case 'rejected': return { bg: '#FDE8E8', text: '#9B1C1C', label: 'Rejected' };
      default: return { bg: '#F3F4F6', text: '#4B5563', label: 'Not Started' };
    }
  };

  const kycInfo = [
    { label: 'Total Users', value: stats.total, icon: Users, color: '#3B82F6' },
    { label: 'Active Users', value: stats.active, icon: UserCheck, color: '#10B981' },
    { label: 'KYC Verified', value: stats.verified, icon: ShieldCheck, color: '#8B5CF6' },
    { label: 'Pending KYC', value: stats.pending, icon: Clock, color: '#F59E0B' },
  ];

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
      <header style={{ marginBottom: '32px' }}>
        <h1 style={{ fontSize: '28px', fontWeight: '800', color: 'var(--text-main)' }}>User Management</h1>
        <p style={{ color: 'var(--text-muted)' }}>Monitor and manage all registered users across the Pequire ecosystem.</p>
      </header>

      {/* Stats Cards */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(4, 1fr)',
        gap: '20px',
        marginBottom: '32px'
      }}>
        {kycInfo.map((stat, i) => {
          const Icon = stat.icon;
          return (
            <div key={i} className="glass-card" style={{ padding: '20px', display: 'flex', alignItems: 'center', gap: '16px' }}>
              <div style={{
                padding: '12px',
                borderRadius: '12px',
                backgroundColor: `${stat.color}15`,
                color: stat.color
              }}>
                <Icon size={24} />
              </div>
              <div>
                <p style={{ color: 'var(--text-muted)', fontSize: '12px', fontWeight: '600', textTransform: 'uppercase', letterSpacing: '0.5px' }}>{stat.label}</p>
                <h3 style={{ fontSize: '24px', fontWeight: '800' }}>{stat.value}</h3>
              </div>
            </div>
          );
        })}
      </div>

      {/* Main Content Area */}
      <div className="glass-card" style={{ padding: '24px', minHeight: '500px', display: 'flex', flexDirection: 'column' }}>
        {/* Toolbar */}
        <div style={{ 
          display: 'flex', 
          justifyContent: 'space-between', 
          alignItems: 'center', 
          marginBottom: '24px',
          gap: '16px'
        }}>
          <div style={{ position: 'relative', flex: 1, maxWidth: '400px' }}>
            <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: '#94A3B8' }} />
            <input 
              type="text" 
              placeholder="Search by name, email or phone..." 
              value={searchTerm}
              onChange={handleSearchChange}
              style={{
                width: '100%',
                padding: '10px 12px 10px 40px',
                borderRadius: '8px',
                border: '1px solid #E2E8F0',
                backgroundColor: '#F8FAFC',
                fontSize: '14px',
                outline: 'none'
              }}
            />
          </div>
          
          <div style={{ display: 'flex', gap: '12px' }}>
            <select 
              value={filterStatus}
              onChange={handleFilterChange}
              style={{
                padding: '10px 16px',
                borderRadius: '8px',
                border: '1px solid #E2E8F0',
                backgroundColor: 'white',
                fontSize: '14px',
                outline: 'none',
                cursor: 'pointer'
              }}
            >
              <option value="all">All Statuses</option>
              <option value="active">Active Only</option>
              <option value="verified">KYC Verified</option>
              <option value="pending">KYC Pending</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
        </div>

        {/* Table */}
        <div style={{ overflowX: 'auto', flex: 1 }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #E2E8F0', backgroundColor: '#F8FAFC' }}>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>USER</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>CONTACT</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>STATUS</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>RATING</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>KYC VERIFICATION</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>JOINED DATE</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array.from({ length: 5 }).map((_, idx) => (
                  <tr key={idx} style={{ borderBottom: '1px solid #F1F5F9' }}>
                    <td style={{ padding: '16px 12px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <div className="skeleton" style={{ width: '40px', height: '40px', borderRadius: '50%' }} />
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                          <div className="skeleton" style={{ width: '120px', height: '14px' }} />
                          <div className="skeleton" style={{ width: '80px', height: '11px' }} />
                        </div>
                      </div>
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                        <div className="skeleton" style={{ width: '150px', height: '13px' }} />
                        <div className="skeleton" style={{ width: '100px', height: '13px' }} />
                      </div>
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <div className="skeleton" style={{ width: '8px', height: '8px', borderRadius: '50%' }} />
                        <div className="skeleton" style={{ width: '50px', height: '13px' }} />
                      </div>
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <div className="skeleton" style={{ width: '60px', height: '14px' }} />
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <div className="skeleton" style={{ width: '80px', height: '22px', borderRadius: '20px' }} />
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <div className="skeleton" style={{ width: '90px', height: '13px' }} />
                    </td>
                  </tr>
                ))
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: '#94A3B8' }}>No users found matching your search.</td>
                </tr>
              ) : users.map((user) => {
                const kyc = getKYCColor(user.kycStatus);
                return (
                  <tr key={user._id} style={{ borderBottom: '1px solid #F1F5F9', transition: 'background 0.2s' }}>
                    <td style={{ padding: '16px 12px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <div style={{
                          width: '40px',
                          height: '40px',
                          borderRadius: '50%',
                          backgroundColor: '#E2E8F0',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontWeight: 'bold',
                          color: '#475569'
                        }}>
                          {user.name?.charAt(0)}
                        </div>
                        <div>
                          <div style={{ fontWeight: '600', color: 'var(--text-main)' }}>{user.name}</div>
                          <div style={{ fontSize: '12px', color: '#94A3B8' }}>ID: {user._id?.substring(0, 8)}</div>
                        </div>
                      </div>
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '13px', color: '#475569' }}>
                          <Mail size={14} color="#94A3B8" /> {user.email}
                        </div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '13px', color: '#475569' }}>
                          <Phone size={14} color="#94A3B8" /> {user.phoneNumber}
                        </div>
                      </div>
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <div style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: getStatusColor(user.status) }}></div>
                        <span style={{ fontSize: '13px', fontWeight: '500', textTransform: 'capitalize' }}>{user.status}</span>
                      </div>
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                        <Star size={14} fill="#F59E0B" color="#F59E0B" />
                        <span style={{ fontWeight: '700', fontSize: '13px' }}>{user.rating?.toFixed(1) || '5.0'}</span>
                        <span style={{ fontSize: '11px', color: '#94A3B8' }}>({user.reviewCount || 0})</span>
                      </div>
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <span style={{
                        padding: '4px 10px',
                        borderRadius: '20px',
                        fontSize: '11px',
                        fontWeight: '700',
                        backgroundColor: kyc.bg,
                        color: kyc.text,
                        textTransform: 'uppercase'
                      }}>
                        {kyc.label}
                      </span>
                    </td>
                    <td style={{ padding: '16px 12px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '13px', color: '#475569' }}>
                        <Calendar size={14} color="#94A3B8" /> {user.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'N/A'}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Pagination Footer */}
        {!loading && totalPages > 1 && (
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '16px 24px',
            borderTop: '1px solid #E2E8F0',
            backgroundColor: '#F8FAFC',
            marginTop: '16px'
          }}>
            <span style={{ fontSize: '14px', color: 'var(--text-muted)' }}>
              Showing <strong>{((page - 1) * limit) + 1}</strong> to <strong>{Math.min(page * limit, totalUsersCount)}</strong> of <strong>{totalUsersCount}</strong> users
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
    </div>
  );
};

export default UserManagement;
