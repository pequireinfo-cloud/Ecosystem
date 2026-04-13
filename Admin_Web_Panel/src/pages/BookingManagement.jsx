import React from 'react';
import { Download, Calendar, MapPin, MoreVertical } from 'lucide-react';

const BookingManagement = () => {
  const bookings = [
    { id: 'BK-5012', service: 'Electrician', address: '123 Tech Park, Bengaluru', status: 'pending', date: '2026-04-13' },
    { id: 'BK-5013', service: 'Cleaning', address: 'Whitefield Main Rd, Bengaluru', status: 'accepted', date: '2026-04-13' },
    { id: 'BK-5014', service: 'Plumbing', address: 'Indiranagar 12th Cross, Bengaluru', status: 'ongoing', date: '2026-04-12' },
    { id: 'BK-5015', service: 'Appliance', address: 'Koramangala 4th Block, Bengaluru', status: 'completed', date: '2026-04-11' },
  ];

  const getStatusColor = (status) => {
    switch (status) {
      case 'pending': return '#F59E0B';
      case 'accepted': return '#10B981';
      case 'ongoing': return '#3B82F6';
      case 'completed': return '#6366F1';
      default: return '#64748B';
    }
  };

  return (
    <div className="animate-fade-in">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
        <div>
          <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Booking Management</h1>
          <p style={{ color: 'var(--text-muted)' }}>Monitor real-time service requests and assignments.</p>
        </div>
        <button style={{
          backgroundColor: 'white',
          color: 'var(--text-muted)',
          border: '1px solid var(--border)',
          padding: '12px 24px',
          borderRadius: '10px',
          fontWeight: '600',
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          cursor: 'pointer'
        }}>
          <Download size={18} />
          Export CSV
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '20px', marginBottom: '32px' }}>
        {[
          { label: 'Total Bookings', value: '452', color: '#3B82F6' },
          { label: 'Pending Requests', value: '18', color: '#F59E0B' },
          { label: 'Live Jobs', value: '12', color: '#10B981' },
        ].map((stat, i) => (
          <div key={i} className="glass-card" style={{ padding: '20px' }}>
            <p style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '600', marginBottom: '4px' }}>{stat.label.toUpperCase()}</p>
            <p style={{ fontSize: '24px', fontWeight: '800', color: stat.color }}>{stat.value}</p>
          </div>
        ))}
      </div>

      <div className="glass-card">
        <div style={{ padding: '24px', borderBottom: '1px solid var(--border)' }}>
          <h3 style={{ fontSize: '18px', fontWeight: '800' }}>Real-time Bookings</h3>
        </div>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
          <thead>
            <tr style={{ backgroundColor: '#F8FAFC' }}>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>ID</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>SERVICE</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>ADDRESS</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>DATE</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>STATUS</th>
              <th style={{ padding: '16px 24px', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)' }}>ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            {bookings.map((b, i) => (
              <tr key={i} style={{ borderTop: '1px solid var(--border)' }}>
                <td style={{ padding: '16px 24px', fontWeight: '600', color: 'var(--primary)', fontSize: '14px' }}>#{b.id}</td>
                <td style={{ padding: '16px 24px', fontSize: '14px' }}>{b.service}</td>
                <td style={{ padding: '16px 24px', fontSize: '14px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <MapPin size={14} color="var(--text-muted)" />
                    {b.address}
                  </div>
                </td>
                <td style={{ padding: '16px 24px', fontSize: '14px' }}>
                   <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Calendar size={14} color="var(--text-muted)" />
                    {b.date}
                  </div>
                </td>
                <td style={{ padding: '16px 24px' }}>
                  <span style={{
                    padding: '4px 8px',
                    borderRadius: '6px',
                    fontSize: '11px',
                    fontWeight: '800',
                    backgroundColor: `${getStatusColor(b.status)}15`,
                    color: getStatusColor(b.status)
                  }}>{b.status.toUpperCase()}</span>
                </td>
                <td style={{ padding: '16px 24px' }}>
                  <button style={{ border: 'none', background: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                    <MoreVertical size={18} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default BookingManagement;
