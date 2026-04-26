import React, { useState, useEffect } from 'react';
import { Users, UserCheck, ShieldCheck, Clock, Search, Filter, MoreHorizontal, Mail, Phone, Calendar, Star } from 'lucide-react';
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

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const res = await api.get('/admin/users');
      setUsers(res.data.users);
      setStats(res.data.stats);
    } catch (err) {
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                          user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          user.phoneNumber.includes(searchTerm);
    const matchesFilter = filterStatus === 'all' || user.status === filterStatus || user.kycStatus === filterStatus;
    return matchesSearch && matchesFilter;
  });

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
      <div className="glass-card" style={{ padding: '24px', minHeight: '500px' }}>
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
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                width: '100%',
                padding: '10px 12px 10px 40px',
                borderRadius: '8px',
                border: '1px solid #E2E8F0',
                backgroundColor: '#F8FAFC',
                fontSize: '14px'
              }}
            />
          </div>
          
          <div style={{ display: 'flex', gap: '12px' }}>
            <select 
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              style={{
                padding: '10px 16px',
                borderRadius: '8px',
                border: '1px solid #E2E8F0',
                backgroundColor: 'white',
                fontSize: '14px',
                outline: 'none'
              }}
            >
              <option value="all">All Statuses</option>
              <option value="active">Active Only</option>
              <option value="verified">KYC Verified</option>
              <option value="pending">KYC Pending</option>
              <option value="inactive">Inactive</option>
            </select>
            
            <button style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '10px 16px',
              borderRadius: '8px',
              backgroundColor: 'var(--primary)',
              color: 'white',
              border: 'none',
              fontWeight: '600',
              fontSize: '14px',
              cursor: 'pointer'
            }}>
              <Filter size={18} />
              Advanced Filters
            </button>
          </div>
        </div>

        {/* Table */}
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #E2E8F0' }}>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>USER</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>CONTACT</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>STATUS</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>RATING</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>KYC VERIFICATION</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}>JOINED DATE</th>
                <th style={{ padding: '16px 12px', color: '#64748B', fontWeight: '600', fontSize: '13px' }}></th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: '#94A3B8' }}>Loading users...</td>
                </tr>
              ) : filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: '#94A3B8' }}>No users found matching your search.</td>
                </tr>
              ) : filteredUsers.map((user) => {
                const kyc = getKYCColor(user.kycStatus);
                return (
                  <tr key={user._id} style={{ borderBottom: '1px solid #F1F5F9', transition: 'background 0.2s' }} className="table-row-hover">
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
                          {user.name.charAt(0)}
                        </div>
                        <div>
                          <div style={{ fontWeight: '600', color: 'var(--text-main)' }}>{user.name}</div>
                          <div style={{ fontSize: '12px', color: '#94A3B8' }}>ID: {user._id.substring(0, 8)}</div>
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
                        <Calendar size={14} color="#94A3B8" /> {new Date(user.createdAt).toLocaleDateString()}
                      </div>
                    </td>
                    <td style={{ padding: '16px 12px', textAlign: 'right' }}>
                      <button style={{ border: 'none', background: 'none', cursor: 'pointer', color: '#94A3B8' }}>
                        <MoreHorizontal size={20} />
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default UserManagement;
