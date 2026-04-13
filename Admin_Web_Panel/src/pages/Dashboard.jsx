import React from 'react';
import { Users, BookOpen, IndianRupee, Clock, ArrowUpRight, ArrowDownRight } from 'lucide-react';

const Dashboard = () => {
  const stats = [
    { label: 'Total Providers', value: '1,284', trend: '+12%', icon: Users, color: '#3B82F6' },
    { label: 'Active Bookings', value: '45', trend: '+5%', icon: BookOpen, color: '#10B981' },
    { label: 'Revenue', value: '₹4.2L', trend: '+18%', icon: IndianRupee, color: '#F59E0B' },
    { label: 'Pending KYC', value: '12', trend: '-2%', icon: Clock, color: '#EF4444' },
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
