import React, { createContext, useCallback, useContext, useEffect, useState } from 'react';
import { api, fmtBand } from './lib.js';
import { Bar } from './components.jsx';
import { Today, Practice, Coach, Mistakes, Account, Admin } from './pages.jsx';
import { Exams, WritingPage, SpeakingPage, ListeningPage, ReadingPage } from './exam.jsx';
import { Teacher } from './teacher.jsx';
import { LearningPlan, GrammarPage, VocabularyPage, PronunciationPage, AcademicEnglishPage, AnalyticsPage, ResourceLibraryPage } from './modules.jsx';
import { NavIcon, ICON_COLORS } from './icons.jsx';

export const AppCtx = createContext(null);
export const useApp = () => useContext(AppCtx);

const NAV = [
  { group: null, items: [['today', 'Today'], ['practice', 'Smart Practice'], ['coach', 'Skills Coach'], ['plan', 'My Learning Plan']] },
  { group: 'Exam', items: [['exams', 'Full Mock Exams'], ['listening', 'Listening'], ['reading', 'Reading'], ['writing', 'Writing'], ['speaking', 'Speaking']] },
  { group: 'Learn', items: [['teacher', 'AI Teacher'], ['grammar', 'Grammar'], ['vocabulary', 'Vocabulary'], ['pronunciation', 'Pronunciation Lab'], ['academic', 'Academic English']] },
  { group: 'Review', items: [['mistakes', 'Mistake Notebook'], ['analytics', 'Progress & Analytics'], ['library', 'Resource Library']] },
  { group: 'Account', items: [['account', 'Account & Target']] },
];

const TABS = [['today', 'Today'], ['practice', 'Practice'], ['exams', 'Exams'], ['teacher', 'Teacher'], ['coach', 'Coach']];

function readRoute() {
  const [page, ...rest] = location.hash.replace(/^#\/?/, '').split('/');
  return { page: page || 'today', arg: rest.join('/') || null };
}

export default function App() {
  const [me, setMe] = useState(undefined);
  const [route, setRoute] = useState(readRoute());
  const [menuOpen, setMenuOpen] = useState(false);
  const [focus, setFocus] = useState(null);
  const [teacherSeed, setTeacherSeed] = useState(null);

  const refresh = useCallback(async () => {
    try { setMe(await api('/api/me')); } catch (e) { if (e.status === 401) setMe(null); }
  }, []);
  useEffect(() => { refresh(); }, [refresh]);
  useEffect(() => { const f = () => { setRoute(readRoute()); setMenuOpen(false); }; addEventListener('hashchange', f); return () => removeEventListener('hashchange', f); }, []);

  const go = (page, arg) => { location.hash = `/${page}${arg ? `/${arg}` : ''}`; document.querySelector('.main')?.scrollTo(0, 0); };

  if (me === undefined) return <div className="login"><div className="muted">Loading…</div></div>;
  if (me === null) return <Login onDone={refresh} />;

  const ctx = { me, refresh, go, route, focus, setFocus, teacherSeed, setTeacherSeed };
  const nav = me.user.role === 'admin' ? [...NAV, { group: 'Admin', items: [['admin', 'Users']] }] : NAV;
  const unseenTotal = (me.unseen?.reading || 0) + (me.unseen?.listening || 0) + (me.unseen?.writing || 0) + (me.unseen?.speaking || 0);
  const badge = (id) => (
    id === 'practice' && unseenTotal > 0 ? { text: `${unseenTotal} new`, cls: '' }
      : id === 'vocabulary' && me.dueVocab > 0 ? { text: `${me.dueVocab}`, cls: 'blue' }
        : id === 'mistakes' && me.openMistakes ? { text: `${me.openMistakes}`, cls: 'warn' }
          : id === 'coach' && me.weak.length ? { text: `${me.weak.length}`, cls: 'warn' }
            : null
  );

  const pages = {
    today: Today, practice: Practice, coach: Coach, plan: LearningPlan,
    exams: Exams, listening: ListeningPage, reading: ReadingPage, writing: WritingPage, speaking: SpeakingPage,
    teacher: Teacher, grammar: GrammarPage, vocabulary: VocabularyPage, pronunciation: PronunciationPage, academic: AcademicEnglishPage,
    mistakes: Mistakes, analytics: AnalyticsPage, library: ResourceLibraryPage, account: Account,
    admin: me.user.role === 'admin' ? Admin : Today,
  };
  const Page = pages[route.page] || Today;
  const ratio = me.bands.partial != null ? me.bands.partial / Math.max(me.targetBand, 1) : 0;

  return (
    <AppCtx.Provider value={ctx}>
      <div className="app">
        {menuOpen && <div className="scrim" onClick={() => setMenuOpen(false)} />}
        <aside className={`sidebar ${menuOpen ? 'open' : ''}`}>
          <div className="brand"><img src="/icon-192.png" alt="IELTS Master" style={{ borderRadius: 9 }} /><div><div style={{ fontWeight: 700 }}>IELTS Master</div><div className="tiny muted">Academic</div></div></div>
          {nav.map((g, gi) => (
            <div key={gi}>
              {g.group && <div className="nav-group">{g.group}</div>}
              {g.items.map(([id, label]) => {
                const b = badge(id);
                const active = route.page === id;
                return (
                  <button key={id} className={`nav-item ${active ? 'active' : ''}`} onClick={() => go(id)}>
                    <NavIcon name={id} color={active ? '#fff' : ICON_COLORS[id]} />
                    <span>{label}</span>
                    {b && <span className={`nav-badge ${b.cls}`}>{b.text}</span>}
                  </button>
                );
              })}
            </div>
          ))}
          <div className="side-foot stack" style={{ gap: 6 }}>
            <div className="row" style={{ gap: 6 }}>
              <strong className="small">Band {fmtBand(me.bands.partial)}</strong><span className="spacer" />
              <button className="btn link tiny" style={{ color: 'var(--gold)', fontWeight: 700 }} onClick={() => go('account')}>Target {fmtBand(me.targetBand)}</button>
            </div>
            <Bar value={ratio} height={5} />
            <div className="tiny muted">{me.user.firstName} {me.user.lastName} {me.user.role === 'admin' ? '· Admin' : ''}</div>
          </div>
        </aside>
        <main className="main">
          <div className="topbar">
            <button className="btn sm" onClick={() => setMenuOpen(true)} aria-label="Menu">☰</button>
            <img src="/icon-192.png" alt="IELTS Master" style={{ borderRadius: 7 }} /><strong>IELTS Master</strong><span className="spacer" />
            <span className="badge gold" onClick={() => go('account')}>Target {fmtBand(me.targetBand)}</span>
          </div>
          <Page key={route.page + (route.arg || '')} arg={route.arg} />
          <nav className="tabbar">
            {TABS.map(([id, label]) => (
              <button key={id} className={route.page === id ? 'active' : ''} onClick={() => go(id)}>
                <NavIcon name={id} size={20} color={route.page === id ? 'var(--primary)' : 'var(--muted)'} />
                <span>{label}</span>
              </button>
            ))}
          </nav>
        </main>
      </div>
    </AppCtx.Provider>
  );
}

function Login({ onDone }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const submit = async (e) => {
    e.preventDefault(); setBusy(true); setError('');
    try { await api('/api/login', { method: 'POST', body: { email, password } }); await onDone(); }
    catch (err) { setError(err.message); } finally { setBusy(false); }
  };
  return (
    <div className="login">
      <form className="card stack fade-in" style={{ gap: 14 }} onSubmit={submit}>
        <div className="stack" style={{ alignItems: 'center', gap: 6, marginBottom: 6 }}>
          <img src="/icon-512.png" alt="IELTS Master" style={{ borderRadius: 16 }} />
          <h2>IELTS Master</h2>
          <div className="small muted">Sign in to continue your preparation</div>
        </div>
        <label className="field">Email<input className="input" type="email" autoComplete="username" value={email} onChange={(e) => setEmail(e.target.value)} required /></label>
        <label className="field">Password<input className="input" type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} required /></label>
        {error && <div className="notice">{error}</div>}
        <button className="btn primary lg" disabled={busy}>{busy ? 'Signing in…' : 'Sign in'}</button>
        <div className="tiny muted" style={{ textAlign: 'center' }}>You stay signed in on this device until you sign out.</div>
      </form>
    </div>
  );
}
