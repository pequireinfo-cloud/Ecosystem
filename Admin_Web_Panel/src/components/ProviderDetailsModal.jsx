import React, { useState } from 'react';
import { X, User, FileText, CheckCircle, AlertCircle, MapPin, Phone, Star } from 'lucide-react';
import api from '../utils/api';

const ProviderDetailsModal = ({ provider, onClose, onUpdate }) => {
  const [loading, setLoading] = useState(false);

  const handleKycAction = async (status) => {
    setLoading(true);
    try {
      await api.put(`/admin/providers/${provider._id}/kyc`, { kycStatus: status });
      onUpdate();
      onClose();
    } catch (err) {
      console.error('KYC update error:', err);
    }
    setLoading(false);
  };

  if (!provider) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="bg-[#0A192F] border border-white/10 w-full max-w-2xl rounded-3xl overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="p-8 border-b border-white/5 flex justify-between items-start bg-gradient-to-r from-blue-500/10 to-purple-500/10">
          <div className="flex gap-6 items-center">
            <div className="w-20 h-20 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center">
              <User size={40} className="text-blue-400" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-white mb-1">{provider.fullName || 'Service Provider'}</h2>
              <div className="flex items-center gap-3 text-white/50 text-sm">
                <span className="flex items-center gap-1"><MapPin size={14} /> {provider.address || 'Location N/A'}</span>
                <span className="w-1 h-1 rounded-full bg-white/20" />
                <span className="flex items-center gap-1"><Phone size={14} /> {provider.phoneNumber || 'No Phone'}</span>
              </div>
            </div>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-white/5 rounded-full text-white/40 transition-colors">
            <X size={24} />
          </button>
        </div>

        {/* Content */}
        <div className="p-8 max-h-[60vh] overflow-y-auto custom-scrollbar">
          <div className="grid grid-cols-2 gap-8 mb-8">
            <div className="p-5 rounded-2xl bg-white/5 border border-white/5">
              <span className="text-xs font-bold text-blue-400 uppercase tracking-wider mb-2 block">Service Category</span>
              <p className="text-lg text-white font-semibold">{provider.serviceType || 'Not Assigned'}</p>
            </div>
            <div className="p-5 rounded-2xl bg-white/5 border border-white/5">
              <span className="text-xs font-bold text-yellow-400 uppercase tracking-wider mb-2 block">Current Status</span>
              <div className="flex items-center gap-2">
                <span className={`w-2 h-2 rounded-full ${provider.status === 'Online' ? 'bg-green-500' : 'bg-red-500'}`} />
                <p className="text-lg text-white font-semibold">{provider.status}</p>
              </div>
            </div>
          </div>

          <h3 className="text-sm font-bold text-white/40 uppercase tracking-[2px] mb-4">KYC Documents for Review</h3>
          <div className="space-y-3">
            {[
              { key: 'aadharCard', label: 'Aadhar Card' },
              { key: 'panCard', label: 'PAN Card' },
              { key: 'drivingLicense', label: 'Driving License' }
            ].map((doc) => {
              const url = provider.documents?.[doc.key];
              const uploaded = !!url;
              return (
                <div 
                  key={doc.key} 
                  onClick={() => uploaded && window.open(url, '_blank')}
                  className={`flex items-center justify-between p-4 rounded-xl border transition-colors ${
                    uploaded 
                      ? 'bg-white/5 border-white/5 hover:bg-white/[0.07] cursor-pointer group' 
                      : 'bg-red-500/5 border-red-500/10 cursor-not-allowed'
                  }`}
                >
                  <div className="flex items-center gap-4">
                    <FileText className={uploaded ? 'text-green-400' : 'text-white/20'} />
                    <div>
                      <p className="text-white font-medium">{doc.label}</p>
                      <p className={`text-xs ${uploaded ? 'text-white/40' : 'text-red-400'}`}>
                        {uploaded ? 'Submitted' : 'Not Uploaded'}
                      </p>
                    </div>
                  </div>
                  {uploaded && (
                    <div className="text-xs text-blue-400 opacity-0 group-hover:opacity-100 transition-opacity">
                      Preview Document
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Footer */}
        <div className="p-8 bg-white/5 border-t border-white/5 flex gap-4">
          <button 
            onClick={() => handleKycAction('Rejected')}
            disabled={loading}
            className="flex-1 py-4 px-6 rounded-2xl bg-red-500/10 border border-red-500/20 text-red-500 font-bold hover:bg-red-500/20 transition-all flex items-center justify-center gap-2"
          >
            {loading ? 'Processing...' : <><X size={18} /> Reject KYC</>}
          </button>
          <button 
            onClick={() => handleKycAction('Verified')}
            disabled={loading}
            className="flex-1 py-4 px-6 rounded-2xl bg-green-500 text-white font-bold hover:bg-green-600 transition-all shadow-lg shadow-green-500/20 flex items-center justify-center gap-2"
          >
            {loading ? 'Processing...' : <><CheckCircle size={18} /> Approve KYC</>}
          </button>
        </div>
      </div>
    </div>
  );
};

export default ProviderDetailsModal;
