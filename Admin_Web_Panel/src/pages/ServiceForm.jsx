import React, { useState, useEffect } from 'react';
import { Plus, Trash2, Save, Image as ImageIcon } from 'lucide-react';
import axios from 'axios';

const ServiceForm = () => {
  const [formData, setFormData] = useState({
    name: '',
    providerId: '',
    categoryId: '',
    price: '',
    discount: '',
    imageUrl: '',
    coveragePoints: ['']
  });

  const [providers, setProviders] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  useEffect(() => {
    // Fetch providers and categories for dropdowns
    const fetchData = async () => {
      try {
        const [provRes, catRes] = await Promise.all([
          axios.get('http://localhost:3000/api/admin/providers'),
          axios.get('http://localhost:3000/api/categories')
        ]);
        setProviders(provRes.data);
        setCategories(catRes.data);
      } catch (err) {
        console.error('Error fetching data:', err);
      }
    };
    fetchData();
  }, []);

  const handleAddPoint = () => {
    setFormData({ ...formData, coveragePoints: [...formData.coveragePoints, ''] });
  };

  const handleRemovePoint = (index) => {
    const newPoints = formData.coveragePoints.filter((_, i) => i !== index);
    setFormData({ ...formData, coveragePoints: newPoints });
  };

  const handlePointChange = (index, value) => {
    const newPoints = [...formData.coveragePoints];
    newPoints[index] = value;
    setFormData({ ...formData, coveragePoints: newPoints });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await axios.post('http://localhost:3000/api/services', formData);
      setMessage('Service created successfully!');
      setFormData({
        name: '', providerId: '', categoryId: '', price: '', discount: '', imageUrl: '', coveragePoints: ['']
      });
    } catch (err) {
      setMessage('Error: ' + (err.response?.data?.error || err.message));
    }
    setLoading(false);
  };

  return (
    <div className="animate-fade-in" style={{ maxWidth: '800px' }}>
      <header style={{ marginBottom: '32px' }}>
        <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Add New Service</h1>
        <p style={{ color: 'var(--text-muted)' }}>Configure a service, assign a provider, and set coverage points.</p>
      </header>

      <form onSubmit={handleSubmit} className="glass-card" style={{ padding: '32px' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px', marginBottom: '24px' }}>
          {/* Basic Info */}
          <div style={{ gridColumn: 'span 2' }}>
            <label style={{ display: 'block', marginBottom: '8px', fontSize: '14px', fontWeight: '600' }}>Service Name</label>
            <input
              type="text"
              required
              className="form-input"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g. Deep House Cleaning"
              style={inputStyle}
            />
          </div>

          <div>
            <label style={{ display: 'block', marginBottom: '8px', fontSize: '14px', fontWeight: '600' }}>Select Provider</label>
            <select
              required
              className="form-input"
              value={formData.providerId}
              onChange={(e) => setFormData({ ...formData, providerId: e.target.value })}
              style={inputStyle}
            >
              <option value="">Select a provider</option>
              {providers.map(p => <option key={p._id} value={p._id}>{p.fullName} ({p.serviceType})</option>)}
            </select>
          </div>

          <div>
            <label style={{ display: 'block', marginBottom: '8px', fontSize: '14px', fontWeight: '600' }}>Category</label>
            <select
              required
              className="form-input"
              value={formData.categoryId}
              onChange={(e) => setFormData({ ...formData, categoryId: e.target.value })}
              style={inputStyle}
            >
              <option value="">Select a category</option>
              {categories.map(c => <option key={c._id} value={c._id}>{c.name}</option>)}
            </select>
          </div>

          <div>
            <label style={{ display: 'block', marginBottom: '8px', fontSize: '14px', fontWeight: '600' }}>Base Price (₹)</label>
            <input
              type="number"
              required
              value={formData.price}
              onChange={(e) => setFormData({ ...formData, price: e.target.value })}
              style={inputStyle}
              placeholder="0.00"
            />
          </div>

          <div>
            <label style={{ display: 'block', marginBottom: '8px', fontSize: '14px', fontWeight: '600' }}>Discount (%)</label>
            <input
              type="number"
              value={formData.discount}
              onChange={(e) => setFormData({ ...formData, discount: e.target.value })}
              style={inputStyle}
              placeholder="0"
            />
          </div>

          <div style={{ gridColumn: 'span 2' }}>
            <label style={{ display: 'block', marginBottom: '8px', fontSize: '14px', fontWeight: '600' }}>Image URL</label>
            <div style={{ display: 'flex', gap: '12px' }}>
              <input
                type="text"
                value={formData.imageUrl}
                onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
                style={inputStyle}
                placeholder="https://example.com/image.jpg"
              />
              <div style={{ width: '48px', height: '48px', backgroundColor: '#F1F5F9', borderRadius: '8px' }} className="flex-center">
                <ImageIcon size={20} color="#94A3B8" />
              </div>
            </div>
          </div>
        </div>

        {/* Coverage Points Section */}
        <div style={{ marginBottom: '32px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <label style={{ fontSize: '14px', fontWeight: '600' }}>Coverage Points</label>
            <button
              type="button"
              onClick={handleAddPoint}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                fontSize: '12px',
                color: 'var(--primary)',
                fontWeight: '700',
                border: 'none',
                background: 'none',
                cursor: 'pointer'
              }}
            >
              <Plus size={14} /> Add Point
            </button>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {formData.coveragePoints.map((point, index) => (
              <div key={index} style={{ display: 'flex', gap: '12px' }}>
                <input
                  type="text"
                  required
                  value={point}
                  onChange={(e) => handlePointChange(index, e.target.value)}
                  placeholder={`Point #${index + 1} (e.g. Wiring checking)`}
                  style={inputStyle}
                />
                {formData.coveragePoints.length > 1 && (
                  <button
                    type="button"
                    onClick={() => handleRemovePoint(index)}
                    style={{ color: '#EF4444', border: 'none', background: 'none', cursor: 'pointer' }}
                  >
                    <Trash2 size={18} />
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>

        <button
          type="submit"
          disabled={loading}
          style={{
            width: '100%',
            backgroundColor: 'var(--primary)',
            color: 'white',
            padding: '14px',
            borderRadius: '10px',
            border: 'none',
            fontWeight: '700',
            fontSize: '16px',
            cursor: loading ? 'not-allowed' : 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '10px'
          }}
        >
          <Save size={20} />
          {loading ? 'Creating...' : 'Create Service'}
        </button>

        {message && (
          <p style={{ 
            marginTop: '20px', 
            textAlign: 'center', 
            padding: '12px', 
            borderRadius: '8px', 
            backgroundColor: message.startsWith('Error') ? '#FDE8E8' : '#DEF7EC',
            color: message.startsWith('Error') ? '#9B1C1C' : '#03543F',
            fontSize: '14px',
            fontWeight: '600'
          }}>{message}</p>
        )}
      </form>
    </div>
  );
};

const inputStyle = {
  width: '100%',
  padding: '12px 16px',
  borderRadius: '8px',
  border: '1px solid var(--border)',
  outline: 'none',
  fontSize: '14px',
  backgroundColor: '#fff'
};

export default ServiceForm;
