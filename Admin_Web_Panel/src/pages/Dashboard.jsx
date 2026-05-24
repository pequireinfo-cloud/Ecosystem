import React, { useState, useEffect } from 'react';
import { Users, BookOpen, Clock, TrendingUp, ArrowUpRight, ArrowDownRight, IndianRupee, UserCheck } from 'lucide-react';
import api from '../utils/api';
import socket from '../utils/socket';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalProviders: 0,
    totalUsers: 0,
    totalBookings: 0,
    revenue: 0
  });

  const fetchStats = async () => {
    try {
      const [provs, usersData, books] = await Promise.all([
        api.get('/admin/providers'),
        api.get('/admin/users'),
        api.get('/bookings')
      ]);
      
      setStats({
        totalProviders: provs.data.providers ? provs.data.providers.length : (provs.data.length || 0),
        totalUsers: usersData.data.users ? usersData.data.users.length : (usersData.data.stats?.total || usersData.data.length || 0),
        totalBookings: books.data.length || 0,
        revenue: books.data.reduce((acc, curr) => acc + (curr.estimatedPrice || 0), 0)
      });
    } catch (err) {
      console.error('Error fetching stats:', err);
    }
  };

  useEffect(() => {
    fetchStats();

    // Listen for real-time updates
    socket.on('new_booking', (data) => {
      console.log('Real-time: New booking received', data);
      fetchStats();
    });

    socket.on('booking_status_update', (data) => {
      console.log('Real-time: Status updated', data);
      fetchStats();
    });

    return () => {
      socket.off('new_booking');
      socket.off('booking_status_update');
    };
  }, []);

  const statsData = [
    { label: 'Total Providers', value: stats.totalProviders.toLocaleString(), icon: UserCheck, color: '#3B82F6', change: '+12%' },
    { label: 'Total Users', value: stats.totalUsers.toLocaleString(), icon: Users, color: '#10B981', change: '+8%' },
    { label: 'Total Bookings', value: stats.totalBookings.toLocaleString(), icon: BookOpen, color: '#F59E0B', change: '+15%' },
    { label: 'Total Revenue', value: `₹${stats.revenue.toLocaleString()}`, icon: IndianRupee, color: '#EF4444', change: '+20%' },
  ];

  return (
    <div className="animate-fade-in">
      <header style={{ marginBottom: '32px' }}>
        <h1 style={{ fontSize: '28px', fontWeight: '800', color: 'var(--text-main)' }}>Dashboard Overview</h1>
        <p style={{ color: 'var(--text-muted)' }}>Welcome back, Admin. Here's what's happening today.</p>
      </header>

      {/* Stats Grid */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(4, 1fr)',
        gap: '24px',
        marginBottom: '42px'
      }}>
        {statsData.map((stat, i) => {
          const Icon = stat.icon;
          const isUp = stat.change.startsWith('+');
          return (
            <div key={i} className="glass-card" style={{ padding: '24px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
                <div style={{
                  padding: '10px',
                  borderRadius: '12px',
                  backgroundColor: `${stat.color}15`,
                  color: stat.color
                }}>
                  <Icon size={24} />
                </div>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  fontSize: '12px',
                  fontWeight: 'bold',
                  padding: '4px 8px',
                  borderRadius: '20px',
                  backgroundColor: isUp ? '#DEF7EC' : '#FDE8E8',
                  color: isUp ? '#03543F' : '#9B1C1C'
                }}>
                  {isUp ? <ArrowUpRight size={14} /> : <ArrowDownRight size={14} />}
                  {stat.change}
                </div>
              </div>
              <p style={{ color: 'var(--text-muted)', fontSize: '14px', fontWeight: '500' }}>{stat.label}</p>
              <h3 style={{ fontSize: '28px', fontWeight: '800', marginTop: '4px' }}>{stat.value}</h3>
            </div>
          );
        })}
      </div>

      {/* System Monitoring */}
      <div className="glass-card" style={{ padding: '24px' }}>
        <h3 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '20px' }}>Live Systems Monitoring</h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {[
            { msg: 'Provider "Amit Kumar" updated location', time: 'Just now' },
            { msg: 'New booking request #4521 created', time: '2 mins ago' },
            { msg: 'KYC submission pending for "Suresh P."', time: '15 mins ago' },
          ].map((item, i) => (
            <div key={i} style={{
              display: 'flex',
              alignItems: 'center',
              padding: '12px',
              borderRadius: '8px',
              backgroundColor: '#F8FAFC'
            }}>
              <div style={{ 
                width: '8px', 
                height: '8px', 
                borderRadius: '50%', 
                backgroundColor: 'var(--primary)',
                marginRight: '16px'
              }} />
              <span style={{ fontSize: '14px', color: 'var(--text-main)' }}>{item.msg}</span>
              <span style={{ marginLeft: 'auto', fontSize: '12px', color: 'var(--text-muted)' }}>{item.time}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
