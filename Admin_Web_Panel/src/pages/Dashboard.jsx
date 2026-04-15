import React, { useState, useEffect } from 'react';
import { Users, BookOpen, Clock, TrendingUp, ArrowUpRight, ArrowDownRight } from 'lucide-react';
import axios from 'axios';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalProviders: 0,
    totalServices: 0,
    activeBookings: 0,
    revenue: 0
  });

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [provs, servs, books] = await Promise.all([
          axios.get('http://localhost:3000/api/admin/providers'),
          axios.get('http://localhost:3000/api/services'),
          axios.get('http://localhost:3000/api/bookings')
        ]);
        
        setStats({
          totalProviders: provs.data.length,
          totalServices: servs.data.length,
          activeBookings: books.data.filter(b => b.status === 'pending' || b.status === 'accepted').length,
          revenue: books.data.reduce((acc, curr) => acc + (curr.estimatedPrice || 0), 0)
        });
      } catch (err) {
        console.error('Error fetching stats:', err);
      }
    };
    fetchStats();
  }, []);

  const statsData = [
    { label: 'Total Providers', value: stats.totalProviders.toString(), icon: Users, color: '#3B82F6', change: '+12%' },
    { label: 'Total Services', value: stats.totalServices.toString(), icon: BookOpen, color: '#10B981', change: '+5%' },
    { label: 'Active Bookings', value: stats.activeBookings.toString(), icon: Clock, color: '#F59E0B', change: '+18%' },
    { label: 'Total Revenue', value: `₹${stats.revenue.toLocaleString()}`, icon: TrendingUp, color: '#6366F1', change: '+25%' },
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
        {stats.map((stat, i) => {
          const Icon = stat.icon;
          const isUp = stat.trend.startsWith('+');
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
                  {stat.trend}
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
