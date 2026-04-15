import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Layers, Star, IndianRupee, Tag, Trash2, Eye, Edit2 } from 'lucide-react';
import ServiceEditModal from '../components/ServiceEditModal';

const ServiceList = () => {
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedService, setSelectedService] = useState(null);

  const fetchServices = async () => {
    try {
      const res = await axios.get('http://localhost:3000/api/services');
      setServices(res.data);
    } catch (err) {
      console.error(err);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchServices();
  }, []);

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this service?')) {
      try {
        await axios.delete(`http://localhost:3000/api/services/${id}`);
        fetchServices();
      } catch (err) {
        alert('Error deleting service');
      }
    }
  };

  return (
    <div className="animate-fade-in">
       <header style={{ marginBottom: '32px' }}>
        <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Services List</h1>
        <p style={{ color: 'var(--text-muted)' }}>Overview of all published services and their providers.</p>
      </header>

      {loading ? (
        <div style={{ padding: '40px', textAlign: 'center' }}>Loading...</div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '24px' }}>
          {services.map((service) => (
            <div key={service._id} className="glass-card" style={{ padding: '0', overflow: 'hidden' }}>
               <div style={{ 
                height: '140px', 
                backgroundColor: '#F1F5F9',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                overflow: 'hidden',
                position: 'relative'
              }}>
                {service.imageUrl ? (
                  <img src={service.imageUrl} alt={service.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                ) : <Layers size={40} color="#CBD5E1" />}
                <div style={{
                    position: 'absolute',
                    top: '12px',
                    right: '12px',
                    backgroundColor: 'rgba(255,255,255,0.9)',
                    padding: '4px 8px',
                    borderRadius: '6px',
                    fontSize: '11px',
                    fontWeight: '800',
                    color: 'var(--primary)'
                }}>{service.categoryId?.name?.toUpperCase() || 'GENERAL'}</div>
              </div>
              
              <div style={{ padding: '20px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                  <h3 style={{ fontSize: '18px', fontWeight: '800' }}>{service.name}</h3>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '14px', fontWeight: '700', color: '#F59E0B' }}>
                    <Star size={14} fill="#F59E0B" />
                    4.5
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
                   <div style={{ width: '24px', height: '24px', borderRadius: '50%', backgroundColor: 'var(--primary)', color: 'white', fontSize: '10px' }} className="flex-center">
                    {service.providerId?.fullName?.charAt(0) || 'P'}
                   </div>
                   <span style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '500' }}>{service.providerId?.fullName || 'Unknown Provider'}</span>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0 0 0', borderTop: '1px solid #F1F5F9' }}>
                   <div>
                    <span style={{ fontSize: '18px', fontWeight: '800' }}>₹{service.price}</span>
                    {service.discount > 0 && <span style={{ fontSize: '12px', color: '#10B981', marginLeft: '8px', fontWeight: '700' }}>{service.discount}% OFF</span>}
                   </div>
                   <div style={{ display: 'flex', gap: '8px' }}>
                    <button 
                      onClick={() => setSelectedService(service)}
                      style={{ padding: '6px', borderRadius: '6px', border: '1px solid var(--border)', color: 'var(--text-muted)' }}
                    >
                      <Edit2 size={16} />
                    </button>
                    <button 
                      onClick={() => handleDelete(service._id)}
                      style={{ padding: '6px', borderRadius: '6px', border: '1px solid var(--border)', color: '#EF4444' }}
                    >
                      <Trash2 size={16} />
                    </button>
                   </div>
                </div>
              </div>
            </div>
          ))}
          {services.length === 0 && (
            <div style={{ gridColumn: 'span 3', padding: '60px', textAlign: 'center', color: 'var(--text-muted)' }}>
              No services published yet.
            </div>
          )}
        </div>
      )}

      {selectedService && (
        <ServiceEditModal 
          service={selectedService} 
          onClose={() => setSelectedService(null)} 
          onUpdate={fetchServices}
        />
      )}
    </div>
  );
};

export default ServiceList;
