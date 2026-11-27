// Account management from the command line (the admin page does the same in the browser).
//   node server/users.js add "First" "LAST" email password [admin]
//   node server/users.js list
//   node server/users.js remove email
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Store, hashPassword, newId, normalizeEmail } from './lib.js';
const ROOT = path.dirname(fileURLToPath(import.meta.url));
const store = new Store(process.env.IELTS_DATA || path.join(ROOT, '..', 'data', 'db.json'));
const [cmd, ...a] = process.argv.slice(2);
if (cmd === 'add') {
  const [firstName, lastName, email, password, role] = a;
  const e = normalizeEmail(email);
  if (!firstName || !lastName || !e || !password) { console.error('usage: add First LAST email password [admin]'); process.exit(1); }
  if (store.data.users.some((u) => u.email === e)) { console.error('exists:', e); process.exit(1); }
  const { salt, hash } = hashPassword(password);
  store.data.users.push({ id: newId(), firstName, lastName, email: e, role: role === 'admin' ? 'admin' : 'user', salt, passwordHash: hash, createdAt: new Date().toISOString() });
  store.flush(); console.log('added', e, role === 'admin' ? '(admin)' : '');
} else if (cmd === 'remove') {
  const e = normalizeEmail(a[0]); const u = store.data.users.find((x) => x.email === e);
  if (!u) { console.error('not found'); process.exit(1); }
  store.data.users = store.data.users.filter((x) => x !== u);
  store.data.sessions = store.data.sessions.filter((s) => s.userId !== u.id);
  delete store.data.progress[u.id]; store.flush(); console.log('removed', e);
} else {
  for (const u of store.data.users) console.log(u.role.padEnd(5), u.email, '-', u.firstName, u.lastName);
}
