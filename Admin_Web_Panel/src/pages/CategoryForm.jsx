import React, { useState } from 'react';
import { Save, Image as ImageIcon } from 'lucide-react';
import api from '../utils/api';

const CategoryForm = ({ onCategoryAdded }) => {
  const [formData, setFormData] = useState({ name: '', description: '', imageUrl: '' });
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await api.post('/categories', formData);
      setMessage('Category added successfully!');
      setFormData({ name: '', description: '', imageUrl: '' });
      if (onCategoryAdded) onCategoryAdded();
    } catch (err) {
      setMessage('Error: ' + (err.response?.data?.error || err.message));
    }
    setLoading(false);
  };

  return (
    <div className="glass-card" style={{ padding: '24px', marginBottom: '32px' }}>
      <h3 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '20px' }}>Add New Category</h3>
      <form onSubmit={handleSubmit}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', marginBottom: '20px' }}>
          <div>
            <label style={{ display: 'block', marginBottom: '8px', fontSize: '13px', fontWeight: '600' }}>Category Name</label>
            <input
              type="text"
              required
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              style={inputStyle}
              placeholder="e.g. Electrical"
            />
          </div>
          <div>
            <label style={{ display: 'block', marginBottom: '8px', fontSize: '13px', fontWeight: '600' }}>Image URL</label>
            <input
              type="text"
              value={formData.imageUrl}
              onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
              style={inputStyle}
              placeholder="https://icon-url.com/icon.png"
            />
          </div>
          <div style={{ gridColumn: 'span 2' }}>
            <label style={{ display: 'block', marginBottom: '8px', fontSize: '13px', fontWeight: '600' }}>Description</label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              style={{ ...inputStyle, minHeight: '80px', resize: 'vertical' }}
              placeholder="Brief description of the category..."
            />
          </div>
        </div>

        <button
          type="submit"
          disabled={loading}
          style={{
            backgroundColor: 'var(--primary)',
            color: 'white',
            border: 'none',
            padding: '12px 24px',
            borderRadius: '10px',
            fontWeight: '700',
            cursor: loading ? 'not-allowed' : 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '8px'
          }}
        >
          <Save size={18} />
          {loading ? 'Adding...' : 'Add Category'}
        </button>

        {message && (
          <p style={{ marginTop: '16px', fontSize: '13px', fontWeight: '600', color: message.startsWith('Error') ? '#EF4444' : '#10B981' }}>{message}</p>
        )}
      </form>
    </div>
  );
};

const inputStyle = {
  width: '100%',
  padding: '10px 14px',
  borderRadius: '8px',
  border: '1px solid var(--border)',
  outline: 'none',
  fontSize: '14px'
};

export default CategoryForm;
