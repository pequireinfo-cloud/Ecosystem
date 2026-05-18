import React, { useState } from 'react';
import api from '../utils/api';
import logo from '../assets/Logo.svg';
import wordmark from '../assets/Wordmark.svg';
import { Mail, Lock, LogIn, AlertCircle, Loader2 } from 'lucide-react';

const Login = ({ onLoginSuccess }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    
    try {
      const response = await api.post('/admin/auth/login', {
        email,
        password
      });
      
      const { token, user } = response.data;
      
      // Store in local storage
      localStorage.setItem('adminToken', token);
      localStorage.setItem('adminUser', JSON.stringify(user));
      
      // Update app state
      onLoginSuccess(user);
    } catch (err) {
      setError(err.response?.data?.error || 'Login failed. Please check your credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={containerStyle}>
      <div className="animate-fade-in" style={glassCardStyle}>
        {/* Logo Section */}
        <div style={{ textAlign: 'center', marginBottom: '40px' }}>
          <img src={logo} alt="Pequire" style={{ height: '64px', marginBottom: '12px' }} />
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px' }}>
            <img src={wordmark} alt="Pequire" style={{ height: '24px' }} />
            <span style={badgeStyle}>ADMIN</span>
          </div>
        </div>

        <header style={{ marginBottom: '32px', textAlign: 'center' }}>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--text-main)' }}>Welcome Back</h1>
          <p style={{ color: 'var(--text-muted)', marginTop: '8px' }}>Enter your credentials to access the portal</p>
        </header>

        {error && (
          <div style={errorContainerStyle}>
            <AlertCircle size={18} />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div>
            <label style={labelStyle}>Email Address</label>
            <div style={inputWrapperStyle}>
              <Mail size={18} style={iconStyle} />
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@pequire.com"
                style={inputStyle}
              />
            </div>
          </div>

          <div>
            <label style={labelStyle}>Password</label>
            <div style={inputWrapperStyle}>
              <Lock size={18} style={iconStyle} />
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                style={inputStyle}
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            style={{
              ...buttonStyle,
              backgroundColor: loading ? '#94A3B8' : 'var(--primary)',
              cursor: loading ? 'not-allowed' : 'pointer'
            }}
          >
            {loading ? <Loader2 className="spin" size={20} /> : <LogIn size={20} />}
            {loading ? 'Authenticating...' : 'Sign In'}
          </button>
        </form>

        <footer style={{ marginTop: '32px', textAlign: 'center' }}>
          <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
            System protected by Pequire Security Protocol
          </p>
        </footer>
      </div>
      
      {/* Background Decorative Elements */}
      <div style={blob1Style} />
      <div style={blob2Style} />
    </div>
  );
};

// Styles
const containerStyle = {
  width: '100%',
  height: '100vh',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  background: 'linear-gradient(135deg, #F8FAFC 0%, #E2E8F0 100%)',
  position: 'relative',
  overflow: 'hidden'
};

const glassCardStyle = {
  width: '100%',
  maxWidth: '440px',
  padding: '48px',
  borderRadius: '24px',
  backgroundColor: 'rgba(255, 255, 255, 0.8)',
  backdropFilter: 'blur(20px)',
  boxShadow: '0 20px 40px rgba(0, 0, 0, 0.05)',
  border: '1px solid rgba(255, 255, 255, 0.3)',
  zIndex: 10
};

const badgeStyle = {
  fontSize: '10px',
  fontWeight: '800',
  letterSpacing: '1.5px',
  color: 'white',
  backgroundColor: 'var(--primary)',
  padding: '2px 8px',
  borderRadius: '4px'
};

const labelStyle = {
  display: 'block',
  fontSize: '14px',
  fontWeight: '600',
  marginBottom: '8px',
  color: 'var(--text-main)'
};

const inputWrapperStyle = {
  position: 'relative',
  display: 'flex',
  alignItems: 'center'
};

const iconStyle = {
  position: 'absolute',
  left: '16px',
  color: '#94A3B8'
};

const inputStyle = {
  width: '100%',
  padding: '14px 16px 14px 48px',
  borderRadius: '12px',
  border: '1px solid #E2E8F0',
  backgroundColor: '#F8FAFC',
  fontSize: '16px',
  outline: 'none',
  transition: 'border-color 0.2s',
  ':focus': {
    borderColor: 'var(--primary)'
  }
};

const buttonStyle = {
  width: '100%',
  padding: '16px',
  borderRadius: '12px',
  border: 'none',
  color: 'white',
  fontWeight: '700',
  fontSize: '16px',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  gap: '12px',
  transition: 'all 0.2s'
};

const errorContainerStyle = {
  display: 'flex',
  alignItems: 'center',
  gap: '10px',
  padding: '12px 16px',
  backgroundColor: '#FEF2F2',
  color: '#EF4444',
  borderRadius: '12px',
  fontSize: '14px',
  fontWeight: '500',
  marginBottom: '24px'
};

const blob1Style = {
  position: 'absolute',
  top: '-10%',
  left: '-5%',
  width: '400px',
  height: '400px',
  background: 'radial-gradient(circle, rgba(2, 94, 243, 0.1) 0%, rgba(2, 94, 243, 0) 70%)',
  zIndex: 1
};

const blob2Style = {
  position: 'absolute',
  bottom: '-10%',
  right: '0%',
  width: '500px',
  height: '500px',
  background: 'radial-gradient(circle, rgba(99, 102, 241, 0.1) 0%, rgba(99, 102, 241, 0) 70%)',
  zIndex: 1
};

export default Login;


