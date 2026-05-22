import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { X, User, FileText, CheckCircle, AlertCircle, MapPin, Phone } from 'lucide-react';
import api from '../utils/api';

const getDocumentUrl = (url) => {
  if (!url) return '';
  // Normalize windows backslashes to forward slashes if any
  let normalized = url.replace(/\\/g, '/');
  
  // If it starts with /uploads, prepend the backend base URL (removing /api from baseURL if present)
  if (normalized.startsWith('/uploads')) {
    const apiBase = import.meta.env.VITE_API_BASE_URL || 'https://api.pequire.com/api';
    const host = apiBase.replace('/api', '');
    return `${host}${normalized}`;
  }
  
  // If it contains localhost/127.0.0.1, check if the current browser window is NOT running on localhost.
  // If we're on a production/staging domain, replace the localhost origin with the actual backend host.
  if (normalized.includes('localhost:') || normalized.includes('127.0.0.1:')) {
    const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
    if (!isLocalhost) {
      const apiBase = import.meta.env.VITE_API_BASE_URL || 'https://api.pequire.com/api';
      const host = apiBase.replace('/api', '');
      const uploadIndex = normalized.indexOf('/uploads/');
      if (uploadIndex !== -1) {
        return `${host}${normalized.substring(uploadIndex)}`;
      }
    }
  }
  return normalized;
};

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

  const hasAnyDoc = provider.documents && Object.values(provider.documents).some(url => !!url);

  return createPortal(
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      zIndex: 1000,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '16px',
      backgroundColor: 'rgba(15, 23, 42, 0.5)',
      backdropFilter: 'blur(12px)',
      animation: 'fadeIn 0.25s ease-out'
    }}>
      <style>{`
        .no-scrollbar::-webkit-scrollbar {
          display: none;
        }
        .no-scrollbar {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
      <div style={{
        backgroundColor: '#ffffff',
        border: '1px solid #e2e8f0',
        width: '100%',
        maxWidth: '720px',
        maxHeight: '90vh',
        borderRadius: '28px',
        overflow: 'hidden',
        boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.08), 0 10px 10px -5px rgba(0, 0, 0, 0.03)',
        display: 'flex',
        flexDirection: 'column',
        fontFamily: "'Outfit', sans-serif",
        color: '#1e293b'
      }}>
        {/* Header */}
        <div style={{
          padding: '28px 36px',
          borderBottom: '1px solid #e2e8f0',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          background: 'linear-gradient(135deg, rgba(2, 94, 243, 0.05) 0%, rgba(99, 102, 241, 0.05) 100%)'
        }}>
          <div style={{ display: 'flex', gap: '20px', alignItems: 'center' }}>
            <div style={{
              width: '68px',
              height: '68px',
              borderRadius: '20px',
              backgroundColor: 'rgba(2, 94, 243, 0.06)',
              border: '1px solid rgba(2, 94, 243, 0.12)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}>
              <User size={36} style={{ color: '#025EF3' }} />
            </div>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <h2 style={{ fontSize: '24px', fontWeight: '800', margin: 0, color: '#1e293b', letterSpacing: '-0.5px' }}>
                  {provider.fullName || 'Service Provider'}
                </h2>
                <span style={{
                  padding: '4px 10px',
                  borderRadius: '99px',
                  fontSize: '11px',
                  fontWeight: '800',
                  letterSpacing: '0.5px',
                  backgroundColor: provider.status === 'Online' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(220, 38, 38, 0.08)',
                  color: provider.status === 'Online' ? '#059669' : '#DC2626',
                  border: provider.status === 'Online' ? '1px solid rgba(16, 185, 129, 0.2)' : '1px solid rgba(220, 38, 38, 0.15)'
                }}>{provider.status?.toUpperCase() || 'OFFLINE'}</span>
              </div>
              <div style={{
                display: 'flex',
                flexWrap: 'wrap',
                alignItems: 'center',
                gap: '12px',
                color: '#64748b',
                fontSize: '13px',
                marginTop: '8px'
              }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <MapPin size={14} style={{ color: '#025EF3' }} /> {provider.location?.address || (provider.location?.latitude !== undefined ? `${provider.location.latitude.toFixed(4)}, ${provider.location.longitude.toFixed(4)}` : 'Location N/A')}
                </span>
                <span style={{ width: '4px', height: '4px', borderRadius: '50%', backgroundColor: '#cbd5e1' }} />
                <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <Phone size={14} style={{ color: '#025EF3' }} /> {provider.phoneNumber || 'No Phone/ID'}
                </span>
              </div>
            </div>
          </div>
          <button 
            onClick={onClose} 
            onMouseEnter={() => setHoveredClose(true)}
            onMouseLeave={() => setHoveredClose(false)}
            style={{
              padding: '10px',
              backgroundColor: hoveredClose ? 'rgba(0, 0, 0, 0.05)' : 'transparent',
              border: 'none',
              borderRadius: '50%',
              color: hoveredClose ? '#1e293b' : '#64748b',
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
        <div 
          className="no-scrollbar"
          style={{
            padding: '36px',
            overflowY: 'auto',
            flex: 1,
            minHeight: 0,
            display: 'flex',
            flexDirection: 'column',
            gap: '28px'
          }}
        >
          {/* Stats Overview */}
          <div>
            <h3 style={{ fontSize: '12px', fontWeight: '800', color: '#025EF3', letterSpacing: '1.5px', textTransform: 'uppercase', marginBottom: '14px', marginTop: 0 }}>
              Profile details & Configuration
            </h3>
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(3, 1fr)',
              gap: '16px'
            }}>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: '#f8fafc', border: '1px solid #e2e8f0' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>SERVICE CATEGORY</span>
                <span style={{ fontSize: '15px', fontWeight: '700', color: '#1e293b' }}>{provider.serviceType || 'Not Assigned'}</span>
              </div>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: '#f8fafc', border: '1px solid #e2e8f0' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>PRICE LEVEL</span>
                <span style={{ fontSize: '15px', fontWeight: '700', color: '#025EF3' }}>{provider.priceLevel ? provider.priceLevel.toUpperCase() : 'STANDARD'}</span>
              </div>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: '#f8fafc', border: '1px solid #e2e8f0' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>SERVICE RADIUS</span>
                <span style={{ fontSize: '15px', fontWeight: '700', color: '#1e293b' }}>{provider.serviceRadiusKm || 15} km</span>
              </div>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: '#f8fafc', border: '1px solid #e2e8f0' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>EMAIL ADDRESS</span>
                <span style={{ fontSize: '14px', fontWeight: '600', color: '#1e293b', wordBreak: 'break-all' }}>{provider.email || 'N/A'}</span>
              </div>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: '#f8fafc', border: '1px solid #e2e8f0' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>EXPERIENCE</span>
                <span style={{ fontSize: '15px', fontWeight: '700', color: '#1e293b' }}>{provider.experienceYears || 0} Years</span>
              </div>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: '#f8fafc', border: '1px solid #e2e8f0' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>RATING</span>
                <span style={{ fontSize: '15px', fontWeight: '700', color: '#d97706' }}>
                  ★ {provider.rating?.toFixed(1) || '5.0'} <span style={{ fontSize: '12px', fontWeight: '500', color: '#64748b' }}>({provider.reviewCount || 0})</span>
                </span>
              </div>
            </div>
          </div>

          {/* Job Performance & Earnings */}
          <div>
            <h3 style={{ fontSize: '12px', fontWeight: '800', color: '#059669', letterSpacing: '1.5px', textTransform: 'uppercase', marginBottom: '14px', marginTop: 0 }}>
              Business performance
            </h3>
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(3, 1fr)',
              gap: '16px'
            }}>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: 'rgba(16, 185, 129, 0.03)', border: '1px solid rgba(16, 185, 129, 0.1)' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>JOBS COMPLETED</span>
                <span style={{ fontSize: '16px', fontWeight: '800', color: '#1e293b' }}>{provider.totalJobsCompleted || 0} Jobs</span>
              </div>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: 'rgba(16, 185, 129, 0.03)', border: '1px solid rgba(16, 185, 129, 0.1)' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>TOTAL EARNINGS</span>
                <span style={{ fontSize: '16px', fontWeight: '800', color: '#059669' }}>₹{provider.earnings?.total || 0}</span>
              </div>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: 'rgba(16, 185, 129, 0.03)', border: '1px solid rgba(16, 185, 129, 0.1)' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>PENDING PAYMENTS</span>
                <span style={{ fontSize: '16px', fontWeight: '800', color: '#d97706' }}>₹{provider.earnings?.pending || 0}</span>
              </div>
            </div>
          </div>

          {/* Gamification Stats */}
          <div>
            <h3 style={{ fontSize: '12px', fontWeight: '800', color: '#b45309', letterSpacing: '1.5px', textTransform: 'uppercase', marginBottom: '14px', marginTop: 0 }}>
              Activity & Gamification
            </h3>
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(3, 1fr)',
              gap: '16px'
            }}>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: 'rgba(245, 158, 11, 0.03)', border: '1px solid rgba(245, 158, 11, 0.1)' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>CURRENT STREAK</span>
                <span style={{ fontSize: '15px', fontWeight: '700', color: '#1e293b' }}>🔥 {provider.currentStreak || 0} Days</span>
              </div>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: 'rgba(245, 158, 11, 0.03)', border: '1px solid rgba(245, 158, 11, 0.1)' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>HIGHEST STREAK</span>
                <span style={{ fontSize: '15px', fontWeight: '700', color: '#1e293b' }}>🏆 {provider.highestStreak || 0} Days</span>
              </div>
              <div style={{ padding: '16px', borderRadius: '16px', backgroundColor: 'rgba(245, 158, 11, 0.03)', border: '1px solid rgba(245, 158, 11, 0.1)' }}>
                <span style={{ fontSize: '10px', fontWeight: '700', color: '#64748b', display: 'block', marginBottom: '4px' }}>REWARD POINTS</span>
                <span style={{ fontSize: '15px', fontWeight: '700', color: '#d97706' }}>✨ {provider.rewardPoints || 0} Pts</span>
              </div>
            </div>
          </div>

          {/* Expertise/Skills */}
          {provider.expertise && provider.expertise.length > 0 && (
            <div>
              <h3 style={{ fontSize: '12px', fontWeight: '800', color: '#64748b', letterSpacing: '1.5px', textTransform: 'uppercase', marginBottom: '10px', marginTop: 0 }}>
                Specialized Expertise
              </h3>
              <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                {provider.expertise.map((skill, idx) => (
                  <span key={idx} style={{
                    padding: '6px 12px',
                    borderRadius: '8px',
                    backgroundColor: 'rgba(2, 94, 243, 0.06)',
                    border: '1px solid rgba(2, 94, 243, 0.15)',
                    color: '#025EF3',
                    fontSize: '13px',
                    fontWeight: '600'
                  }}>{skill}</span>
                ))}
              </div>
            </div>
          )}

          {/* Rejection Alert Banner if Rejected */}
          {provider.kycStatus === 'Rejected' && provider.rejectionReason && (
            <div style={{
              padding: '16px 20px',
              borderRadius: '16px',
              backgroundColor: 'rgba(220, 38, 38, 0.05)',
              border: '1px solid rgba(220, 38, 38, 0.15)',
              display: 'flex',
              gap: '12px',
              alignItems: 'flex-start'
            }}>
              <AlertCircle size={20} style={{ color: '#DC2626', flexShrink: 0, marginTop: '2px' }} />
              <div>
                <h4 style={{ margin: 0, fontSize: '14px', fontWeight: '700', color: '#DC2626' }}>KYC Rejected</h4>
                <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: '#1e293b', lineHeight: '1.4' }}>
                  Reason: "{provider.rejectionReason}"
                </p>
              </div>
            </div>
          )}

          {/* KYC Documents */}
          <div>
            <h3 style={{ fontSize: '12px', fontWeight: '800', color: '#64748b', letterSpacing: '1.5px', textTransform: 'uppercase', marginBottom: '14px', marginTop: 0 }}>
              KYC Documents Review
            </h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {[
                { key: 'aadharCard', label: 'Aadhar Card' },
                { key: 'panCard', label: 'PAN Card' },
                { key: 'drivingLicense', label: 'Driving License' }
              ].map((doc) => {
                const rawUrl = provider.documents?.[doc.key];
                const url = getDocumentUrl(rawUrl);
                const uploaded = !!rawUrl;
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
                        ? (isHovered ? '#025EF3' : '#e2e8f0') 
                        : 'rgba(220, 38, 38, 0.15)',
                      backgroundColor: uploaded 
                        ? (isHovered ? 'rgba(2, 94, 243, 0.03)' : '#ffffff') 
                        : 'rgba(220, 38, 38, 0.02)',
                      cursor: uploaded ? 'pointer' : 'not-allowed',
                      transition: 'all 0.25s ease'
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                      <FileText size={24} style={{ color: uploaded ? '#059669' : '#94a3b8' }} />
                      <div style={{ textAlign: 'left' }}>
                        <p style={{ color: '#1e293b', fontWeight: '700', fontSize: '15px', margin: 0 }}>
                          {doc.label}
                        </p>
                        <p style={{ 
                          fontSize: '12px', 
                          fontWeight: '600', 
                          color: uploaded ? '#059669' : '#DC2626',
                          margin: '3px 0 0 0'
                        }}>
                          {uploaded ? 'Submitted (Click to Preview)' : 'Not Uploaded'}
                        </p>
                      </div>
                    </div>
                    {uploaded && (
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <img 
                          src={url} 
                          alt={doc.label}
                          style={{
                            width: '48px',
                            height: '48px',
                            borderRadius: '8px',
                            objectFit: 'cover',
                            border: '1px solid #e2e8f0',
                            backgroundColor: 'rgba(0,0,0,0.04)'
                          }}
                        />
                        <span style={{ 
                          fontSize: '13px', 
                          fontWeight: '700', 
                          color: '#025EF3',
                          opacity: isHovered ? 1 : 0.6,
                          transition: 'opacity 0.2s ease',
                          display: 'flex',
                          alignItems: 'center',
                          gap: '4px'
                        }}>
                          Open Preview →
                        </span>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
            {!hasAnyDoc && (
              <p style={{ margin: '12px 0 0 0', fontSize: '13px', color: '#DC2626', textAlign: 'center', fontWeight: '600' }}>
                ⚠️ No documents have been uploaded by this provider yet.
              </p>
            )}
          </div>

          {/* Metadata details */}
          <div style={{
            padding: '16px 20px',
            borderRadius: '16px',
            backgroundColor: '#f8fafc',
            border: '1px solid #e2e8f0',
            display: 'flex',
            justifyContent: 'space-between',
            fontSize: '12px',
            color: '#64748b'
          }}>
            <span>Joined On: <strong style={{ color: '#1e293b' }}>{provider.createdAt ? new Date(provider.createdAt).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' }) : 'N/A'}</strong></span>
            <span>Last Active: <strong style={{ color: '#1e293b' }}>{provider.lastActive ? new Date(provider.lastActive).toLocaleString(undefined, { dateStyle: 'medium', timeStyle: 'short' }) : (provider.updatedAt ? new Date(provider.updatedAt).toLocaleString(undefined, { dateStyle: 'medium', timeStyle: 'short' }) : 'N/A')}</strong></span>
          </div>
        </div>

        {/* Footer */}
        <div style={{
          padding: '24px 36px 36px 36px',
          backgroundColor: '#f8fafc',
          borderTop: '1px solid #e2e8f0',
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
              padding: '16px 20px',
              borderRadius: '16px',
              backgroundColor: hoveredReject ? 'rgba(220, 38, 38, 0.1)' : 'rgba(220, 38, 38, 0.04)',
              border: '1px solid rgba(220, 38, 38, 0.15)',
              color: '#DC2626',
              fontWeight: '700',
              fontSize: '14px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              transition: 'all 0.25s',
              outline: 'none'
            }}
          >
            {loading ? 'Processing...' : <><AlertCircle size={16} /> Reject KYC</>}
          </button>
          <button 
            onClick={() => handleKycAction('Verified')}
            disabled={loading || !hasAnyDoc}
            onMouseEnter={() => setHoveredApprove(true)}
            onMouseLeave={() => setHoveredApprove(false)}
            style={{
              flex: 1,
              padding: '16px 20px',
              borderRadius: '16px',
              backgroundColor: !hasAnyDoc ? '#cbd5e1' : (hoveredApprove ? '#047857' : '#059669'),
              border: 'none',
              color: !hasAnyDoc ? '#94a3b8' : '#ffffff',
              fontWeight: '700',
              fontSize: '14px',
              cursor: !hasAnyDoc ? 'not-allowed' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              transition: 'all 0.25s',
              boxShadow: !hasAnyDoc ? 'none' : '0 4px 14px rgba(16, 185, 129, 0.25)',
              outline: 'none'
            }}
          >
            {loading ? 'Processing...' : <><CheckCircle size={16} /> Approve KYC</>}
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
};

export default ProviderDetailsModal;

