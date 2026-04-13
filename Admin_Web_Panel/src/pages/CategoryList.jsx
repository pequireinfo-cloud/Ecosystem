import React, { useState, useEffect } from 'react';
import axios from 'axios';
import CategoryForm from './CategoryForm';
import { Layers, Plus, Tag } from 'lucide-react';

const CategoryList = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);

  const fetchCategories = async () => {
    try {
      const res = await axios.get('http://localhost:3000/api/categories');
      setCategories(res.data);
    } catch (err) {
      console.error(err);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  return (
    <div className="animate-fade-in">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
        <div>
          <h1 style={{ fontSize: '28px', fontWeight: '800' }}>Service Categories</h1>
          <p style={{ color: 'var(--text-muted)' }}>Classify your services for easier management and user discovery.</p>
        </div>
        <button 
          onClick={() => setShowAdd(!showAdd)}
          style={{
            backgroundColor: showAdd ? '#64748B' : 'var(--primary)',
            color: 'white',
            border: 'none',
            padding: '12px 24px',
            borderRadius: '10px',
            fontWeight: '600',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            cursor: 'pointer'
          }}
        >
          {showAdd ? 'Cancel' : (
            <>
              <Plus size={18} />
              Add Category
            </>
          )}
        </button>
      </div>

      {showAdd && <CategoryForm onCategoryAdded={() => { fetchCategories(); setShowAdd(false); }} />}

      {loading ? (
        <div style={{ padding: '40px', textAlign: 'center' }}>Loading...</div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '24px' }}>
          {categories.map((cat) => (
            <div key={cat._id} className="glass-card" style={{ padding: '24px', display: 'flex', alignItems: 'center', gap: '20px' }}>
              <div style={{ 
                width: '60px', 
                height: '60px', 
                borderRadius: '12px', 
                backgroundColor: '#F1F5F9',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                overflow: 'hidden'
              }}>
                {cat.imageUrl ? (
                  <img src={cat.imageUrl} alt={cat.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                ) : <Layers color="var(--primary)" />}
              </div>
              <div style={{ flex: 1 }}>
                <h3 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '4px' }}>{cat.name}</h3>
                <p style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Tag size={12} />
                  {cat.status}
                </p>
              </div>
            </div>
          ))}
          {categories.length === 0 && (
            <div style={{ gridColumn: 'span 3', padding: '60px', textAlign: 'center', color: 'var(--text-muted)' }}>
              No categories created yet. Click "Add Category" to get started.
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default CategoryList;
