import React, { useState, useEffect } from 'react';
import { X, Calendar, MapPin, User, CheckCircle2, Clock, Navigation, CheckSquare } from 'lucide-react';
import api from '../utils/api';

const BookingDetailsModal = ({ bookingId, onClose }) => {
  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDetails = async () => {
      try {
        const res = await axios.get(`http://localhost:3000/api/bookings/${bookingId}`);
        setBooking(res.data);
      } catch (err) {
        console.error('Error fetching booking details:', err);
      }
      setLoading(false);
    };
    if (bookingId) fetchDetails();
  }, [bookingId]);

  if (loading) return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="bg-[#0A192F] border border-white/10 w-full max-w-xl rounded-2xl p-8 flex justify-center">
        <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin" />
      </div>
    </div>
  );

  if (!booking) return null;

  const steps = [
    { status: 'pending', label: 'Requested', icon: Clock, color: 'text-yellow-400' },
    { status: 'accepted', label: 'Accepted', icon: CheckSquare, color: 'text-blue-400' },
    { status: 'ongoing', label: 'Working', icon: Navigation, color: 'text-purple-400' },
    { status: 'completed', label: 'Completed', icon: CheckCircle2, color: 'text-green-400' },
  ];

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="bg-[#0A192F] border border-white/10 w-full max-w-xl rounded-3xl overflow-hidden shadow-2xl">
        <div className="p-6 border-b border-white/5 flex justify-between items-center bg-gradient-to-r from-blue-500/5 to-purple-500/5">
          <div>
            <h2 className="text-xl font-bold text-white flex items-center gap-2">
              Booking Details
            </h2>
            <p className="text-xs text-white/40 mt-1">ID: #{booking._id.slice(-8).toUpperCase()}</p>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-white/5 rounded-full text-white/40"><X size={20} /></button>
        </div>

        <div className="p-8 space-y-8 max-h-[70vh] overflow-y-auto custom-scrollbar">
          {/* Timeline View */}
          <div>
            <h3 className="text-xs font-bold text-white/40 uppercase tracking-widest mb-6 px-1">Progress Timeline</h3>
            <div className="relative flex justify-between">
              <div className="absolute top-5 left-0 w-full h-0.5 bg-white/5 z-0" />
              {steps.map((step, i) => {
                const isCompleted = booking.timeline?.some(t => t.status.toLowerCase() === step.status) || 
                                   (booking.status.toLowerCase() === 'completed' && i < steps.length) ||
                                   (booking.status.toLowerCase() === step.status);
                return (
                  <div key={i} className="relative z-10 flex flex-col items-center gap-3">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 transition-all duration-500 ${isCompleted ? `${step.color} border-current bg-white/5` : 'text-white/10 border-white/5 bg-[#0A192F]'}`}>
                      <step.icon size={18} />
                    </div>
                    <span className={`text-[10px] font-bold uppercase tracking-wider ${isCompleted ? 'text-white' : 'text-white/20'}`}>{step.label}</span>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="p-4 rounded-2xl bg-white/5 border border-white/5 space-y-1">
              <div className="flex items-center gap-2 text-blue-400 text-xs font-bold uppercase">
                <Calendar size={12} /> Date
              </div>
              <p className="text-white text-sm font-medium">{new Date(booking.createdAt).toLocaleDateString()}</p>
            </div>
            <div className="p-4 rounded-2xl bg-white/5 border border-white/5 space-y-1">
              <div className="flex items-center gap-2 text-green-400 text-xs font-bold uppercase">
                <User size={12} /> Service
              </div>
              <p className="text-white text-sm font-medium">{booking.serviceType || 'N/A'}</p>
            </div>
          </div>

          <div className="p-5 rounded-2xl bg-white/5 border border-white/5 space-y-3">
            <div className="flex items-center gap-2 text-purple-400 text-xs font-bold uppercase">
              <MapPin size={12} /> Service Address
            </div>
            <p className="text-white text-sm leading-relaxed">{booking.location?.address || 'No address provided'}</p>
          </div>

          {booking.providerId && (
            <div className="p-5 rounded-2xl bg-blue-500/10 border border-blue-500/20 flex items-center gap-4">
              <div className="w-12 h-12 rounded-full bg-blue-500/20 flex items-center justify-center text-blue-400">
                <User size={24} />
              </div>
              <div>
                <p className="text-xs text-blue-400 font-bold uppercase">Assigned Provider</p>
                <p className="text-white font-bold">{booking.providerId.fullName}</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default BookingDetailsModal;
