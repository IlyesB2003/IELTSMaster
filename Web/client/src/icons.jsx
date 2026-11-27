import React from 'react';

const S = { width: 18, height: 18, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: 1.85, strokeLinecap: 'round', strokeLinejoin: 'round' };

export function NavIcon({ name, color, size = 18 }) {
  const props = { ...S, width: size, height: size, style: { color: color || 'currentColor', flexShrink: 0 } };
  switch (name) {
    case 'today':
      return <svg {...props}><circle cx="12" cy="12" r="4" /><path d="M12 2v2m0 16v2M4.93 4.93l1.41 1.41m11.32 11.32 1.41 1.41M2 12h2m16 0h2M4.93 19.07l1.41-1.41m11.32-11.32 1.41-1.41" /></svg>;
    case 'practice':
      return <svg {...props}><rect x="4" y="8" width="16" height="12" rx="2" /><path d="M7 5h10M9 2h6M12 11v6M9 14h6" /></svg>;
    case 'coach':
      return <svg {...props}><circle cx="12" cy="12" r="9" /><circle cx="12" cy="12" r="5" /><circle cx="12" cy="12" r="1.5" fill="currentColor" /></svg>;
    case 'plan':
      return <svg {...props}><rect x="3" y="5" width="18" height="16" rx="2" /><path d="M3 10h18M8 3v4M16 3v4M9 15l2 2 4-4" /></svg>;
    case 'exams':
      return <svg {...props}><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h7" /><path d="M8 8h6M8 12h4" /><circle cx="16.5" cy="16.5" r="3" /><path d="m19 19 2 2" /></svg>;
    case 'listening':
      return <svg {...props}><path d="M4 14v-2a8 8 0 0 1 16 0v2" /><rect x="3" y="13" width="4" height="7" rx="1.5" /><rect x="17" y="13" width="4" height="7" rx="1.5" /></svg>;
    case 'reading':
      return <svg {...props}><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H20v17H6.5A2.5 2.5 0 0 0 4 22V5.5Z" /><path d="M8 7h8M8 11h8M8 15h5" /></svg>;
    case 'writing':
      return <svg {...props}><circle cx="12" cy="12" r="9" /><path d="M15.5 8.5 10 14l-1.5 3 3-1.5 5.5-5.5-1.5-1.5Z" /></svg>;
    case 'speaking':
      return <svg {...props}><path d="M4 10v4M8 7v10M12 5v14M16 9v3" /><rect x="16" y="12" width="4" height="6" rx="2" /><path d="M18 18v3" /></svg>;
    case 'teacher':
      return <svg {...props}><path d="M21 15a2 2 0 0 1-2 2H8l-4 4V5a2 2 0 0 1 2-2h13a2 2 0 0 1 2 2Z" /><circle cx="12" cy="9" r="2" /><path d="M8.5 14a3.5 3.5 0 0 1 7 0" /></svg>;
    case 'grammar':
      return <svg {...props}><text x="2" y="17" fontSize="14" fontWeight="600" fill="currentColor" stroke="none" fontFamily="-apple-system, sans-serif">Aa</text></svg>;
    case 'vocabulary':
      return <svg {...props}><rect x="5" y="3" width="14" height="18" rx="2" /><path d="M9 15l3-7 3 7M10 13h4" /></svg>;
    case 'pronunciation':
      return <svg {...props}><path d="M4 10v4M8 6v12M12 3v18M16 7v10M20 10v4" /></svg>;
    case 'academic':
      return <svg {...props}><path d="M2 9 12 4l10 5-10 5L2 9Z" /><path d="M6 11v5c0 1.8 2.7 3 6 3s6-1.2 6-3v-5" /></svg>;
    case 'mistakes':
      return <svg {...props}><path d="M10.3 3.8 2.2 18a2 2 0 0 0 1.7 3h16.2a2 2 0 0 0 1.7-3L13.7 3.8a2 2 0 0 0-3.4 0Z" /><path d="M12 9v4M12 17h.01" /></svg>;
    case 'analytics':
      return <svg {...props}><path d="M3 3v18h18" /><path d="m7 15 4-4 3 3 5-6" /><circle cx="7" cy="15" r="1.2" fill="currentColor" /><circle cx="11" cy="11" r="1.2" fill="currentColor" /><circle cx="14" cy="14" r="1.2" fill="currentColor" /><circle cx="19" cy="8" r="1.2" fill="currentColor" /></svg>;
    case 'library':
      return <svg {...props}><path d="M4 19V5a2 2 0 0 1 2-2h2v18H6a2 2 0 0 1-2-2Z" /><path d="M10 3h4v18h-4V3Z" /><path d="M16 5l4 1v14l-4-1V5Z" /></svg>;
    case 'account':
      return <svg {...props}><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09a1.65 1.65 0 0 0-1-1.51 1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09a1.65 1.65 0 0 0 1.51-1 1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33h.08a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82v.08a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1Z" /></svg>;
    case 'admin':
      return <svg {...props}><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" /></svg>;
    default:
      return <svg {...props}><circle cx="12" cy="12" r="8" /></svg>;
  }
}

export const ICON_COLORS = {
  today: '#3B82F6',
  practice: '#2CC3A9',
  coach: '#EF4444',
  plan: '#9CA3AF',
  exams: '#3B82F6',
  listening: '#0EA5E9',
  reading: '#14B8A6',
  writing: '#8B5CF6',
  speaking: '#F59E0B',
  teacher: '#3B82F6',
  grammar: '#9CA3AF',
  vocabulary: '#9CA3AF',
  pronunciation: '#F59E0B',
  academic: '#9CA3AF',
  mistakes: '#F59E0B',
  analytics: '#9CA3AF',
  library: '#2CC3A9',
  account: '#9CA3AF',
  admin: '#9CA3AF',
};
