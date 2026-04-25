import React, { useState, useEffect } from 'react';
import { X, Plus, Trash2, Save, Info } from 'lucide-react';
import api from '../utils/api';

const ServiceEditModal = ({ service, onClose, onUpdate }) => {
  const [formData, setFormData] = useState({
    name: '',
    category: '',
    price: '',
    description: '',
    coveragePoints: []
  });
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (service) {
      setFormData({
        name: service.name || '',
        category: service.categoryId?._id || service.categoryId || '',
        price: service.price || '',
        description: service.description || '',
        coveragePoints: service.coveragePoints || []
      });
    }
  }, [service]);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const res = await api.get('/categories');
        setCategories(res.data);
      } catch (err) {
        console.error('Error fetching categories:', err);
      }
    };
    fetchCategories();
  }, []);

  const handleAddPoint = () => {
    setFormData({ ...formData, coveragePoints: [...formData.coveragePoints, ''] });
  };

  const handleRemovePoint = (index) => {
    const points = [...formData.coveragePoints];
    points.splice(index, 1);
    setFormData({ ...formData, coveragePoints: points });
  };

  const handlePointChange = (index, value) => {
    const points = [...formData.coveragePoints];
    points[index] = value;
    setFormData({ ...formData, coveragePoints: points });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await axios.put(`http://localhost:4000/api/services/${service._id}`, {
        ...formData,
        price: Number(formData.price),
        categoryId: formData.category
      });
      onUpdate();
      onClose();
    } catch (err) {
      console.error('Update service error:', err);
    }
    setLoading(false);
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="bg-[#0A192F] border border-white/10 w-full max-w-2xl rounded-3xl overflow-hidden shadow-2xl">
        <div className="p-6 border-b border-white/5 flex justify-between items-center bg-gradient-to-r from-blue-500/5 to-purple-500/5">
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <Info className="text-blue-400" size={20} /> Edit Service
          </h2>
          <button onClick={onClose} className="p-2 hover:bg-white/5 rounded-full text-white/40"><X size={20} /></button>
        </div>

        <form onSubmit={handleSubmit} className="p-8 space-y-6 max-h-[70vh] overflow-y-auto custom-scrollbar">
          <div className="grid grid-cols-2 gap-6">
            <div className="space-y-2">
              <label className="text-xs font-bold text-white/40 uppercase tracking-wider">Service Name</label>
              <input 
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-blue-500 transition-colors"
                required
              />
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-white/40 uppercase tracking-wider">Base Price (₹)</label>
              <input 
                type="number"
                value={formData.price}
                onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-blue-500 transition-colors"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-bold text-white/40 uppercase tracking-wider">Category</label>
            <select 
              value={formData.category}
              onChange={(e) => setFormData({ ...formData, category: e.target.value })}
              className="w-full bg-[#0A192F] border border-white/10 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-blue-500 transition-colors"
              required
            >
              <option value="">Select Category</option>
              {categories.map(cat => (
                <option key={cat._id} value={cat._id}>{cat.name}</option>
              ))}
            </select>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-bold text-white/40 uppercase tracking-wider">Description</label>
            <textarea 
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white min-h-[100px] focus:outline-none focus:border-blue-500 transition-colors"
            />
          </div>

          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <label className="text-xs font-bold text-white/40 uppercase tracking-wider">Coverage Points</label>
              <button 
                type="button" 
                onClick={handleAddPoint}
                className="text-xs font-bold text-blue-400 hover:text-blue-300 flex items-center gap-1"
              >
                <Plus size={14} /> Add Point
              </button>
            </div>
            <div className="space-y-3">
              {formData.coveragePoints.map((point, index) => (
                <div key={index} className="flex gap-3">
                  <input 
                    value={point}
                    onChange={(e) => handlePointChange(index, e.target.value)}
                    placeholder="e.g. Up to 5 Liters cleaning"
                    className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-blue-500 transition-colors"
                  />
                  <button 
                    type="button" 
                    onClick={() => handleRemovePoint(index)}
                    className="p-2 hover:bg-red-500/10 text-red-400 transition-colors rounded-lg"
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              ))}
            </div>
          </div>
        </form>

        <div className="p-6 bg-white/5 border-t border-white/5">
          <button 
            onClick={handleSubmit}
            disabled={loading}
            className="w-full py-4 rounded-2xl bg-blue-500 text-white font-bold hover:bg-blue-600 transition-all flex items-center justify-center gap-2"
          >
            {loading ? 'Saving...' : <><Save size={18} /> Update Service</>}
          </button>
        </div>
      </div>
    </div>
  );
};

export default ServiceEditModal;
