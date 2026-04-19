import React, { useState, useEffect } from 'react';
import api from '../utils/api';
import { 
  Layers, Star, IndianRupee, Tag, Trash2, Eye, Edit2, 
  Package, Wrench, Plus, X, Search, ChevronRight 
} from 'lucide-react';
import ServiceEditModal from '../components/ServiceEditModal';

const ServiceList = () => {
  const [activeTab, setActiveTab] = useState('listings'); // 'listings' or 'catalog'
  const [services, setServices] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedService, setSelectedService] = useState(null);
  
  // New State for Catalog Management
  const [newItemName, setNewItemName] = useState('');
  const [addingTo, setAddingTo] = useState(null); // { catId, type: 'problems' | 'appliances' }

  const fetchData = async () => {
    setLoading(true);
    try {
      const [servRes, catRes] = await Promise.all([
        api.get('/services'),
        api.get('/categories')
      ]);
      setServices(servRes.data);
      setCategories(catRes.data);
    } catch (err) {
      console.error(err);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleDeleteService = async (id) => {
    if (window.confirm('Are you sure you want to delete this listing?')) {
      try {
        await axios.delete(`http://localhost:3000/api/services/${id}`);
        fetchData();
      } catch (err) {
        alert('Error deleting service');
      }
    }
  };

  const handleAddItem = async (catId, type) => {
    if (!newItemName.trim()) return;
    
    const category = categories.find(c => c._id === catId);
    const updatedList = [...(category[type] || []), newItemName.trim()];
    
    try {
      await axios.put(`http://localhost:3000/api/categories/${catId}`, {
        [type]: updatedList
      });
      setNewItemName('');
      setAddingTo(null);
      fetchData();
    } catch (err) {
      alert('Failed to update catalog');
    }
  };

  const handleRemoveItem = async (catId, type, itemIndex) => {
    const category = categories.find(c => c._id === catId);
    const updatedList = category[type].filter((_, i) => i !== itemIndex);
    
    try {
      await axios.put(`http://localhost:3000/api/categories/${catId}`, {
        [type]: updatedList
      });
      fetchData();
    } catch (err) {
      alert('Failed to remove item');
    }
  };

  return (
    <div className="animate-fade-in">
      <header style={{ marginBottom: '32px' }}>
        <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Service Management</h1>
        <p style={{ color: 'var(--text-muted)' }}>Manage your global service catalog and active provider listings.</p>
      </header>

      {/* Tabs */}
      <div style={{ 
        display: 'flex', 
        gap: '8px', 
        marginBottom: '32px', 
        backgroundColor: '#F1F5F9', 
        padding: '6px', 
        borderRadius: '12px',
        width: 'fit-content'
      }}>
        <button 
          onClick={() => setActiveTab('listings')}
          style={{
            padding: '10px 20px',
            borderRadius: '8px',
            border: 'none',
            fontSize: '14px',
            fontWeight: '700',
            cursor: 'pointer',
            transition: 'all 0.2s',
            backgroundColor: activeTab === 'listings' ? 'white' : 'transparent',
            color: activeTab === 'listings' ? 'var(--primary)' : '#64748B',
            boxShadow: activeTab === 'listings' ? '0 4px 6px -1px rgba(0,0,0,0.1)' : 'none'
          }}
        >
          Active Listings
        </button>
        <button 
          onClick={() => setActiveTab('catalog')}
          style={{
            padding: '10px 20px',
            borderRadius: '8px',
            border: 'none',
            fontSize: '14px',
            fontWeight: '700',
            cursor: 'pointer',
            transition: 'all 0.2s',
            backgroundColor: activeTab === 'catalog' ? 'white' : 'transparent',
            color: activeTab === 'catalog' ? 'var(--primary)' : '#64748B',
            boxShadow: activeTab === 'catalog' ? '0 4px 6px -1px rgba(0,0,0,0.1)' : 'none'
          }}
        >
          Master Catalog & Appliances
        </button>
      </div>

      {loading ? (
        <div style={{ padding: '60px', textAlign: 'center' }}>
          <div className="loading-spinner" style={{ margin: '0 auto 20px' }}></div>
          <p style={{ color: 'var(--text-muted)', fontWeight: '600' }}>Synchronizing Catalog...</p>
        </div>
      ) : (
        <>
          {activeTab === 'listings' ? (
            /* Listings View */
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '24px' }}>
              {services.map((service) => (
                <div key={service._id} className="glass-card" style={{ padding: '0', overflow: 'hidden' }}>
                  <div style={{ height: '140px', backgroundColor: '#F1F5F9', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden', position: 'relative' }}>
                    {service.imageUrl ? (
                      <img src={service.imageUrl} alt={service.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    ) : <Layers size={40} color="#CBD5E1" />}
                    <div style={{ position: 'absolute', top: '12px', right: '12px', backgroundColor: 'rgba(255,255,255,0.9)', padding: '4px 8px', borderRadius: '6px', fontSize: '11px', fontWeight: '800', color: 'var(--primary)' }}>
                      {service.categoryId?.name?.toUpperCase() || 'GENERAL'}
                    </div>
                  </div>
                  
                  <div style={{ padding: '20px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '8px' }}>
                      <h3 style={{ fontSize: '17px', fontWeight: '800' }}>{service.name}</h3>
                      <span style={{ fontSize: '18px', fontWeight: '800' }}>₹{service.price}</span>
                    </div>
                    <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '16px' }}>
                      Provider: <span style={{ fontWeight: '600', color: 'var(--text-main)' }}>{service.providerId?.fullName || 'Internal'}</span>
                    </p>
                    <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', paddingTop: '12px', borderTop: '1px solid #F1F5F9' }}>
                      <button onClick={() => setSelectedService(service)} style={{ padding: '8px', borderRadius: '8px', border: '1px solid #E2E8F0', color: '#64748B' }}><Edit2 size={16} /></button>
                      <button onClick={() => handleDeleteService(service._id)} style={{ padding: '8px', borderRadius: '8px', border: '1px solid #E2E8F0', color: '#EF4444' }}><Trash2 size={16} /></button>
                    </div>
                  </div>
                </div>
              ))}
              {services.length === 0 && (
                <div style={{ gridColumn: 'span 3', padding: '100px 40px', textAlign: 'center', backgroundColor: 'white', borderRadius: '20px', border: '2px dashed #E2E8F0' }}>
                  <Package size={48} color="#CBD5E1" style={{ marginBottom: '16px' }} />
                  <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#64748B' }}>No Active Listings</h3>
                  <p style={{ color: '#94A3B8' }}>Services published by providers will appear here.</p>
                </div>
              )}
            </div>
          ) : (
            /* Catalog Management View */
            <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
              {categories.map((cat) => (
                <div key={cat._id} className="glass-card" style={{ padding: '32px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '24px' }}>
                    <div style={{ width: '48px', height: '48px', borderRadius: '14px', backgroundColor: 'var(--primary)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px' }}>
                      {cat.name.charAt(0)}
                    </div>
                    <div>
                      <h2 style={{ fontSize: '20px', fontWeight: '800' }}>{cat.name}</h2>
                      <p style={{ fontSize: '14px', color: 'var(--text-muted)' }}>{cat.description}</p>
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '40px' }}>
                    {/* Master Services (Problems) */}
                    <div>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                        <h4 style={{ fontSize: '15px', fontWeight: '800', color: 'var(--text-main)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                          <Wrench size={16} color="var(--primary)" /> Master Services (Problems)
                        </h4>
                        <button 
                          onClick={() => setAddingTo({ catId: cat._id, type: 'problems' })}
                          style={{ background: 'none', border: 'none', color: 'var(--primary)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px', fontWeight: '700' }}
                        >
                          <Plus size={14} /> Add New
                        </button>
                      </div>
                      
                      {addingTo?.catId === cat._id && addingTo?.type === 'problems' && (
                        <div style={{ display: 'flex', gap: '8px', marginBottom: '16px' }}>
                          <input 
                            autoFocus
                            className="form-input"
                            value={newItemName}
                            onChange={(e) => setNewItemName(e.target.value)}
                            onKeyPress={(e) => e.key === 'Enter' && handleAddItem(cat._id, 'problems')}
                            placeholder="Type service name..."
                            style={{ flex: 1, padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--primary)', outline: 'none' }}
                          />
                          <button onClick={() => handleAddItem(cat._id, 'problems')} style={{ padding: '8px 16px', backgroundColor: 'var(--primary)', color: 'white', border: 'none', borderRadius: '8px', fontWeight: '600', fontSize: '13px' }}>Add</button>
                          <button onClick={() => setAddingTo(null)} style={{ padding: '8px', color: '#64748B', background: 'none', border: 'none' }}><X size={18}/></button>
                        </div>
                      )}

                      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                        {(cat.problems || []).map((prob, idx) => (
                          <div key={idx} style={{ padding: '8px 12px', backgroundColor: '#F8FAFC', borderRadius: '8px', border: '1px solid #E2E8F0', fontSize: '13px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '10px' }}>
                            {prob}
                            <X size={14} color="#94A3B8" style={{ cursor: 'pointer' }} onClick={() => handleRemoveItem(cat._id, 'problems', idx)} />
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* Master Appliances */}
                    <div>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                        <h4 style={{ fontSize: '15px', fontWeight: '800', color: 'var(--text-main)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                          <Package size={16} color="#10B981" /> Associated Appliances
                        </h4>
                        <button 
                          onClick={() => setAddingTo({ catId: cat._id, type: 'appliances' })}
                          style={{ background: 'none', border: 'none', color: '#10B981', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px', fontWeight: '700' }}
                        >
                          <Plus size={14} /> Add New
                        </button>
                      </div>

                      {addingTo?.catId === cat._id && addingTo?.type === 'appliances' && (
                        <div style={{ display: 'flex', gap: '8px', marginBottom: '16px' }}>
                          <input 
                            autoFocus
                            className="form-input"
                            value={newItemName}
                            onChange={(e) => setNewItemName(e.target.value)}
                            onKeyPress={(e) => e.key === 'Enter' && handleAddItem(cat._id, 'appliances')}
                            placeholder="Type appliance name..."
                            style={{ flex: 1, padding: '8px 12px', borderRadius: '8px', border: '1px solid #10B981', outline: 'none' }}
                          />
                          <button onClick={() => handleAddItem(cat._id, 'appliances')} style={{ padding: '8px 16px', backgroundColor: '#10B981', color: 'white', border: 'none', borderRadius: '8px', fontWeight: '600', fontSize: '13px' }}>Add</button>
                          <button onClick={() => setAddingTo(null)} style={{ padding: '8px', color: '#64748B', background: 'none', border: 'none' }}><X size={18}/></button>
                        </div>
                      )}

                      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                        {(cat.appliances || []).map((app, idx) => (
                          <div key={idx} style={{ padding: '8px 12px', backgroundColor: '#F8FAFC', borderRadius: '8px', border: '1px solid #E2E8F0', fontSize: '13px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '10px' }}>
                            {app}
                            <X size={14} color="#94A3B8" style={{ cursor: 'pointer' }} onClick={() => handleRemoveItem(cat._id, 'appliances', idx)} />
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </>
      )}

      {selectedService && (
        <ServiceEditModal 
          service={selectedService} 
          onClose={() => setSelectedService(null)} 
          onUpdate={fetchData}
        />
      )}
    </div>
  );
};

export default ServiceList;
