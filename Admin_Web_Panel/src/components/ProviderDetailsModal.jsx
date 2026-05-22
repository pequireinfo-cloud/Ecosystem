import React, { useState } from 'react';
import { X, User, FileText, CheckCircle, AlertCircle, MapPin, Phone } from 'lucide-react';
import api from '../utils/api';

const ProviderDetailsModal = ({ provider, onClose, onUpdate }) => {
  const [loading, setLoading] = useState(false);
  const [hoveredClose, setHoveredClose] = useState(false);
  const [hoveredDoc, setHoveredDoc] = useState(null);
  const [hoveredReject, setHoveredReject] = useState(false);
  const [hoveredApprove, setHoveredApprove] = useState(false);

  const handleKycAction = async (status) => {
    setLoading(true);
    try {
      let rejectionReason = null;
      if (status === 'Rejected') {
        rejectionReason = prompt('Please enter a rejection reason (sent to the provider):') || 'Documents are invalid or blurry. Please reupload.';
        if (!rejectionReason) {
          setLoading(false);
          return;
        }
      }
      await api.put(`/admin/providers/${provider._id}/kyc`, { kycStatus: status, rejectionReason });
      onUpdate();
      onClose();
    } catch (err) {
      console.error('KYC update error:', err);
    }
    setLoading(false);
  };

  if (!provider) return null;

  return (
    <div style={{
      position: 'fixed',
      inset: 0,
      zIndex: 1000,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '16px',
      backgroundColor: 'rgba(0, 0, 0, 0.7)',
      backdropFilter: 'blur(10px)',
      animation: 'fadeIn 0.2s ease-out'
    }}>
      <div style={{
        backgroundColor: '#0F172A',
        border: '1px solid rgba(255, 255, 255, 0.1)',
        width: '100%',
        maxWidth: '640px',
        borderRadius: '24px',
        overflow: 'hidden',
        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)',
        display: 'flex',
        flexDirection: 'column',
        fontFamily: "'Outfit', sans-serif",
        color: '#ffffff'
      }}>
        {/* Header */}
        <div style={{
          padding: '24px 32px',
          borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          background: 'linear-gradient(to right, rgba(2, 94, 243, 0.15), rgba(99, 102, 241, 0.15))'
        }}>
          <div style={{ display: 'flex', gap: '20px', alignItems: 'center' }}>
            <div style={{
              width: '64px',
              height: '64px',
              borderRadius: '16px',
              backgroundColor: 'rgba(255, 255, 255, 0.05)',
              border: '1px solid rgba(255, 255, 255, 0.1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}>
              <User size={32} style={{ color: '#025EF3' }} />
            </div>
            <div>
              <h2 style={{ fontSize: '22px', fontWeight: '800', margin: 0, color: '#ffffff' }}>
                {provider.fullName || 'Service Provider'}
              </h2>
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                color: 'rgba(255, 255, 255, 0.5)',
                fontSize: '13px',
                marginTop: '6px'
              }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <MapPin size={13} /> {provider.location?.address || 'Location N/A'}
                </span>
                <span style={{ width: '4px', height: '4px', borderRadius: '50%', backgroundColor: 'rgba(255, 255, 255, 0.3)' }} />
                <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Phone size={13} /> {provider.phoneNumber || 'No Phone'}
                </span>
              </div>
            </div>
          </div>
          <button 
            onClick={onClose} 
            onMouseEnter={() => setHoveredClose(true)}
            onMouseLeave={() => setHoveredClose(false)}
            style={{
              padding: '8px',
              backgroundColor: hoveredClose ? 'rgba(255, 255, 255, 0.1)' : 'transparent',
              border: 'none',
              borderRadius: '50%',
              color: hoveredClose ? '#ffffff' : 'rgba(255, 255, 255, 0.4)',
              transition: 'all 0.2s',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}
          >
            <X size={20} />
          </button>
        </div>

        {/* Content */}
        <div style={{
          padding: '32px',
          maxHeight: '55vh',
          overflowY: 'auto'
        }}>
          <div style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            gap: '20px',
            marginBottom: '28px'
          }}>
            <div style={{
              padding: '20px',
              borderRadius: '16px',
              backgroundColor: 'rgba(255, 255, 255, 0.03)',
              border: '1px solid rgba(255, 255, 255, 0.06)'
            }}>
              <span style={{ fontSize: '11px', fontWeight: '800', color: '#025EF3', uppercase: 'true', letterSpacing: '1px', display: 'block', marginBottom: '6px' }}>
                SERVICE CATEGORY
              </span>
              <p style={{ fontSize: '16px', color: '#ffffff', fontWeight: '600', margin: 0 }}>
                {provider.serviceType || 'Not Assigned'}
              </p>
            </div>
            <div style={{
              padding: '20px',
              borderRadius: '16px',
              backgroundColor: 'rgba(255, 255, 255, 0.03)',
              border: '1px solid rgba(255, 255, 255, 0.06)'
            }}>
              <span style={{ fontSize: '11px', fontWeight: '800', color: '#F59E0B', uppercase: 'true', letterSpacing: '1px', display: 'block', marginBottom: '6px' }}>
                CURRENT STATUS
              </span>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{
                  width: '8px',
                  height: '8px',
                  borderRadius: '50%',
                  backgroundColor: provider.status === 'Online' ? '#10B981' : '#EF4444'
                }} />
                <p style={{ fontSize: '16px', color: '#ffffff', fontWeight: '600', margin: 0 }}>
                  {provider.status || 'Offline'}
                </p>
              </div>
            </div>
          </div>

          <h3 style={{ fontSize: '12px', fontWeight: '800', color: 'rgba(255, 255, 255, 0.4)', letterSpacing: '2px', textTransform: 'uppercase', marginBottom: '16px', margin: 0 }}>
            KYC Documents for Review
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {[
              { key: 'aadharCard', label: 'Aadhar Card' },
              { key: 'panCard', label: 'PAN Card' },
              { key: 'drivingLicense', label: 'Driving License' }
            ].map((doc) => {
              const url = provider.documents?.[doc.key];
              const uploaded = !!url;
              const isHovered = hoveredDoc === doc.key;
              return (
                <div 
                  key={doc.key} 
                  onClick={() => uploaded && window.open(url, '_blank')}
                  onMouseEnter={() => uploaded && setHoveredDoc(doc.key)}
                  onMouseLeave={() => setHoveredDoc(null)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '16px 20px',
                    borderRadius: '16px',
                    border: '1px solid',
                    borderColor: uploaded 
                      ? (isHovered ? 'rgba(255,255,255,0.2)' : 'rgba(255,255,255,0.06)') 
                      : 'rgba(239, 68, 68, 0.1)',
                    backgroundColor: uploaded 
                      ? (isHovered ? 'rgba(255,255,255,0.05)' : 'rgba(255,255,255,0.02)') 
                      : 'rgba(239, 68, 68, 0.02)',
                    cursor: uploaded ? 'pointer' : 'not-allowed',
                    transition: 'all 0.2s ease'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                    <FileText size={22} style={{ color: uploaded ? '#10B981' : 'rgba(255, 255, 255, 0.2)' }} />
                    <div style={{ textAlign: 'left' }}>
                      <p style={{ color: '#ffffff', fontWeight: '600', fontSize: '14px', margin: 0 }}>
                        {doc.label}
                      </p>
                      <p style={{ 
                        fontSize: '11px', 
                        fontWeight: '500', 
                        color: uploaded ? 'rgba(255, 255, 255, 0.4)' : '#EF4444',
                        margin: '2px 0 0 0'
                      }}>
                        {uploaded ? 'Submitted (Click to View)' : 'Not Uploaded'}
                      </p>
                    </div>
                  </div>
                  {uploaded && (
                    <span style={{ 
                      fontSize: '12px', 
                      fontWeight: '700', 
                      color: '#025EF3',
                      opacity: isHovered ? 1 : 0,
                      transition: 'opacity 0.2s ease'
                    }}>
                      Open Preview →
                    </span>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Footer */}
        <div style={{
          padding: '24px 32px 32px 32px',
          backgroundColor: 'rgba(255, 255, 255, 0.01)',
          borderTop: '1px solid rgba(255, 255, 255, 0.06)',
          display: 'flex',
          gap: '16px'
        }}>
          <button 
            onClick={() => handleKycAction('Rejected')}
            disabled={loading}
            onMouseEnter={() => setHoveredReject(true)}
            onMouseLeave={() => setHoveredReject(false)}
            style={{
              flex: 1,
              padding: '14px 20px',
              borderRadius: '14px',
              backgroundColor: hoveredReject ? 'rgba(239, 68, 68, 0.2)' : 'rgba(239, 68, 68, 0.1)',
              border: '1px solid rgba(239, 68, 68, 0.2)',
              color: '#EF4444',
              fontWeight: '700',
              fontSize: '14px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              transition: 'all 0.2s',
              outline: 'none'
            }}
          >
            {loading ? 'Processing...' : <><AlertCircle size={16} /> Reject KYC</>}
          </button>
          <button 
            onClick={() => handleKycAction('Verified')}
            disabled={loading}
            onMouseEnter={() => setHoveredApprove(true)}
            onMouseLeave={() => setHoveredApprove(false)}
            style={{
              flex: 1,
              padding: '14px 20px',
              borderRadius: '14px',
              backgroundColor: hoveredApprove ? '#059669' : '#10B981',
              border: 'none',
              color: '#ffffff',
              fontWeight: '700',
              fontSize: '14px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              transition: 'all 0.2s',
              boxShadow: '0 4px 12px rgba(16, 185, 129, 0.15)',
              outline: 'none'
            }}
          >
            {loading ? 'Processing...' : <><CheckCircle size={16} /> Approve KYC</>}
          </button>
        </div>
      </div>
    </div>
  );
};

export default ProviderDetailsModal;

