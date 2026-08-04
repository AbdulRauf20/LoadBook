/* ==========================================================================
   LoadBook — Shared prototype logic (data, utils, icons, modal system)
   One main notebook screen + a few small sheets/dialogs. Kept framework
   agnostic on purpose so it maps cleanly onto a future Flutter rebuild.
   ========================================================================== */

/* ---------------------------- Icon library ------------------------------ */
/* Every icon carries explicit width/height attributes so it renders at a
   sane default size even if injected into an unsized container. CSS on the
   wrapper always takes priority over these attributes when a different size
   is needed. */
const ICONS_RAW = {
  whatsapp: `<svg viewBox="0 0 32 32" fill="currentColor"><path d="M16.02 3C9.4 3 4 8.37 4 15c0 2.36.65 4.56 1.9 6.5L4 29l7.7-1.83A11.9 11.9 0 0 0 16.02 27C22.63 27 28 21.63 28 15S22.63 3 16.02 3Zm0 21.6c-2.02 0-3.9-.56-5.5-1.53l-.4-.24-4.6 1.1 1.14-4.5-.26-.42A9.53 9.53 0 0 1 6.4 15c0-5.3 4.32-9.6 9.62-9.6 5.3 0 9.6 4.3 9.6 9.6 0 5.3-4.3 9.6-9.6 9.6Zm5.28-7.2c-.29-.15-1.7-.84-1.96-.93-.26-.1-.46-.15-.65.14-.19.29-.75.93-.92 1.12-.17.19-.34.22-.63.07-.29-.14-1.22-.45-2.32-1.43-.86-.76-1.44-1.71-1.6-2-.17-.29-.02-.45.13-.6.13-.13.29-.34.44-.51.15-.17.19-.29.29-.48.1-.19.05-.36-.02-.5-.07-.15-.65-1.58-.9-2.16-.24-.57-.48-.5-.65-.5-.17-.01-.36-.01-.55-.01-.19 0-.5.07-.76.36-.26.29-1 1-1 2.42 0 1.43 1.03 2.82 1.18 3.01.14.19 2.03 3.1 4.92 4.35.69.3 1.22.48 1.64.61.69.22 1.31.19 1.81.11.55-.08 1.7-.7 1.94-1.37.24-.67.24-1.24.17-1.37-.07-.12-.26-.19-.55-.34Z"/></svg>`,
  phone: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.362 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.338 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>`,
  plus: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>`,
  check: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>`,
  checkCircle: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m8.5 12.5 2.5 2.5 5-5"/></svg>`,
  warning: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 9v4M12 17h.01"/><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L14.71 3.86a2 2 0 0 0-3.42 0Z"/></svg>`,
  calendar: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 10h18"/></svg>`,
  arrowLeft: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>`,
  arrowRight: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>`,
  chevronRight: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>`,
  chevronLeft: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>`,
  edit: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3a2.85 2.85 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/></svg>`,
  trash: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2m3 0-1 14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2L4 6h16Z"/></svg>`,
  close: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M18 6 6 18M6 6l12 12"/></svg>`,
  fileText: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z"/><path d="M14 2v6h6M8 13h8M8 17h8M8 9h2"/></svg>`,
  share: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="m8.6 10.5 6.8-3.9M8.6 13.5l6.8 3.9"/></svg>`,
  wifiOff: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 1l22 22M16.72 11.06A10.94 10.94 0 0 1 19 12.55M5 12.55a10.94 10.94 0 0 1 5.17-2.39M10.71 5.05A16 16 0 0 1 22.58 9M1.42 9a15.91 15.91 0 0 1 4.7-2.88M8.53 16.11a6 6 0 0 1 6.95 0M12 20h.01"/></svg>`,
  bell: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>`,
  shop: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9 4 4h16l1 5"/><path d="M4 9h16v10a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1Z"/><path d="M9 20v-6h6v6"/></svg>`,
  wallet: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-3"/><path d="M18 12h.01M14 12h5a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1h-5a2 2 0 0 1 0-4Z"/></svg>`,
  trend: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 17 9 11l4 4 8-8"/><path d="M15 7h6v6"/></svg>`,
};

/* Inject width="20" height="20" onto every <svg ...> tag so it always has a
   sane intrinsic size. CSS on the wrapper still overrides this whenever a
   different rendered size is needed. */
const ICONS = Object.fromEntries(
  Object.entries(ICONS_RAW).map(([key, svg]) => [key, svg.replace('<svg ', '<svg width="20" height="20" ')])
);

function icon(name, extraClass) {
  return `<span class="lb-icon ${extraClass || ''}" style="display:inline-flex;width:20px;height:20px;flex:none;">${ICONS[name] || ''}</span>`;
}

/* ------------------------------ Utilities -------------------------------- */
const LB = (() => {
  const STORAGE_KEY = 'loadbook_v2';
  const AVAILABLE_BALANCE_BASE = 500000; // distributor's starting daily float

  const CUSTOMERS = [
    {"id":"c1","name":"ABC Mobile Shop","phone":"0300 1234500","monthlySales":420000},
    {"id":"c2","name":"XYZ Mobile Shop","phone":"0301 1288821","monthlySales":650000},
    {"id":"c3","name":"Ali Mobile","phone":"0302 1343142","monthlySales":280000},
    {"id":"c4","name":"Karim Telecom","phone":"0303 1397463","monthlySales":510000},
    {"id":"c5","name":"Faizan Communication","phone":"0304 1451784","monthlySales":395000},
    {"id":"c6","name":"Al-Madina Mobile Center","phone":"0305 1506105","monthlySales":720000},
    {"id":"c7","name":"Bilal Easyload Shop","phone":"0306 1560426","monthlySales":340000},
    {"id":"c8","name":"Cheema Mobile Point","phone":"0307 1614747","monthlySales":460000},
    {"id":"c9","name":"Danish Mobile Zone","phone":"0308 1669068","monthlySales":380000},
    {"id":"c10","name":"Elite Communication","phone":"0309 1723389","monthlySales":610000},
    {"id":"c11","name":"Faisal Mobile Corner","phone":"0310 1777710","monthlySales":295000},
    {"id":"c12","name":"Gulshan Mobile Shop","phone":"0321 1832031","monthlySales":530000},
    {"id":"c13","name":"Haris Telecom","phone":"0322 1886352","monthlySales":410000},
    {"id":"c14","name":"Iqbal Mobile Center","phone":"0323 1940673","monthlySales":360000},
    {"id":"c15","name":"Javed Communication","phone":"0324 1994994","monthlySales":480000},
    {"id":"c16","name":"Kamran Mobile Point","phone":"0331 2049315","monthlySales":325000},
    {"id":"c17","name":"Latif Easyload","phone":"0332 2103636","monthlySales":590000},
    {"id":"c18","name":"Malik Mobile Shop","phone":"0333 2157957","monthlySales":440000},
    {"id":"c19","name":"Noman Telecom","phone":"0334 2212278","monthlySales":370000},
    {"id":"c20","name":"Omar Mobile Zone","phone":"0335 2266599","monthlySales":505000},
    {"id":"c21","name":"Pervaiz Communication","phone":"0336 2320920","monthlySales":310000},
    {"id":"c22","name":"Qasim Mobile Corner","phone":"0340 2375241","monthlySales":475000},
    {"id":"c23","name":"Rashid Mobile Shop","phone":"0341 2429562","monthlySales":395000},
    {"id":"c24","name":"Sana Telecom Center","phone":"0342 2483883","monthlySales":660000},
    {"id":"c25","name":"Tariq Mobile Point","phone":"0343 2538204","monthlySales":340000},
    {"id":"c26","name":"Usman Easyload","phone":"0345 2592525","monthlySales":420000},
    {"id":"c27","name":"Waqas Mobile Shop","phone":"0346 2646846","monthlySales":385000},
    {"id":"c28","name":"Yasir Telecom","phone":"0347 2701167","monthlySales":540000},
    {"id":"c29","name":"Zubair Mobile Center","phone":"0348 2755488","monthlySales":300000},
    {"id":"c30","name":"Anwar Communication","phone":"0349 2809809","monthlySales":455000}
  ].map(c => ({ ...c, active: true }));

  // Fixed "today" load/receive figures for the reference date used across the prototype.
  const TODAY_ENTRIES = {
    c1:{load:5000,received:5000}, c2:{load:30000,received:20000}, c3:{load:15000,received:0},
    c4:{load:8000,received:8000}, c5:{load:10000,received:10000}, c6:{load:12000,received:12000},
    c7:{load:15000,received:15000}, c8:{load:6000,received:6000}, c9:{load:9000,received:9000},
    c10:{load:20000,received:12000}, c11:{load:11000,received:11000}, c12:{load:14000,received:14000},
    c13:{load:7000,received:7000}, c14:{load:13000,received:13000}, c15:{load:16000,received:16000},
    c16:{load:18000,received:18000}, c17:{load:10000,received:10000}, c18:{load:15000,received:9000},
    c19:{load:5000,received:5000}, c20:{load:9000,received:9000}, c21:{load:12000,received:12000},
    c22:{load:15000,received:15000}, c23:{load:8000,received:8000}, c24:{load:11000,received:11000},
    c25:{load:12000,received:6000}, c26:{load:6000,received:6000}, c27:{load:14000,received:14000},
    c28:{load:25000,received:0}, c29:{load:10000,received:10000}, c30:{load:9000,received:9000}
  };

  const REFERENCE_DATE = '2026-08-03'; // Monday, 3 August 2026 — the app's "today" in this prototype

  function seededRandom(seed) {
    let x = Math.sin(seed) * 10000;
    return x - Math.floor(x);
  }

  function dateKey(d) {
    if (typeof d === 'string') return d;
    return d.toISOString().slice(0, 10);
  }

  function parseDate(key) {
    const [y, m, d] = key.split('-').map(Number);
    return new Date(y, m - 1, d);
  }

  function addDays(key, n) {
    const d = parseDate(key);
    d.setDate(d.getDate() + n);
    return dateKey(d);
  }

  function humanDate(key) {
    const d = parseDate(key);
    const days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return `${days[d.getDay()]}, ${d.getDate()} ${months[d.getMonth()]}`;
  }

  function shortDate(key) {
    const d = parseDate(key);
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return `${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`;
  }

  function todayKey() {
    return REFERENCE_DATE;
  }

  function isToday(key) {
    return key === REFERENCE_DATE;
  }

  function isFuture(key) {
    return parseDate(key) > parseDate(REFERENCE_DATE);
  }

  function loadStore() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) return JSON.parse(raw);
    } catch (e) { /* ignore corrupt storage */ }
    return { customers: CUSTOMERS, entries: {} };
  }

  function saveStore(store) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
  }

  let store = loadStore();
  // Always trust the bundled roster for names/phones added in code, but keep any
  // customers the user added during this browser session, and respect deactivation.
  (function mergeCustomers() {
    const byId = {};
    CUSTOMERS.forEach(c => byId[c.id] = c);
    (store.customers || []).forEach(c => { if (!byId[c.id]) byId[c.id] = c; });
    store.customers = Object.values(byId);
    saveStore(store);
  })();

  function getCustomers({ includeInactive = false } = {}) {
    return store.customers.filter(c => includeInactive || c.active);
  }

  function getCustomer(id) {
    return store.customers.find(c => c.id === id);
  }

  function addCustomer({ name, phone, monthlySales }) {
    const id = 'c' + Date.now();
    store.customers.push({ id, name, phone, monthlySales: Number(monthlySales) || 0, active: true });
    saveStore(store);
    return id;
  }

  function updateCustomer(id, patch) {
    const c = getCustomer(id);
    if (c) { Object.assign(c, patch); saveStore(store); }
  }

  function setCustomerActive(id, active) {
    updateCustomer(id, { active });
  }

  function getEntry(customerId, dateKeyStr) {
    if (store.entries[dateKeyStr] && store.entries[dateKeyStr][customerId]) {
      return store.entries[dateKeyStr][customerId];
    }
    if (dateKeyStr === REFERENCE_DATE && TODAY_ENTRIES[customerId]) {
      return { ...TODAY_ENTRIES[customerId] };
    }
    if (isFuture(dateKeyStr)) {
      return { load: 0, received: 0 };
    }
    // Deterministic pseudo-history for past days so the calendar/history feel real.
    const d = parseDate(dateKeyStr);
    const seed = d.getFullYear() * 400 + d.getMonth() * 31 + d.getDate() + parseInt(customerId.replace(/\D/g, ''), 10) * 97;
    const base = TODAY_ENTRIES[customerId] || { load: 10000, received: 10000 };
    const variance = 0.6 + seededRandom(seed) * 0.8;
    const load = Math.round((base.load * variance) / 500) * 500;
    const payRoll = seededRandom(seed + 1);
    let received;
    if (payRoll < 0.72) received = load;
    else if (payRoll < 0.92) received = Math.round((load * (0.3 + seededRandom(seed + 2) * 0.5)) / 500) * 500;
    else received = 0;
    return { load, received: Math.min(received, load) };
  }

  function setEntry(customerId, dateKeyStr, patch) {
    if (!store.entries[dateKeyStr]) store.entries[dateKeyStr] = {};
    const current = store.entries[dateKeyStr][customerId] || getEntry(customerId, dateKeyStr);
    store.entries[dateKeyStr][customerId] = { ...current, ...patch };
    saveStore(store);
    return store.entries[dateKeyStr][customerId];
  }

  function addLoad(customerId, dateKeyStr, amount) {
    const current = getEntry(customerId, dateKeyStr);
    return setEntry(customerId, dateKeyStr, { load: current.load + Number(amount) });
  }

  function addReceived(customerId, dateKeyStr, amount) {
    const current = getEntry(customerId, dateKeyStr);
    const received = Math.min(current.received + Number(amount), current.load);
    return setEntry(customerId, dateKeyStr, { received });
  }

  function markFullyReceived(customerId, dateKeyStr) {
    const current = getEntry(customerId, dateKeyStr);
    return setEntry(customerId, dateKeyStr, { received: current.load });
  }

  function undoFullyReceived(customerId, dateKeyStr) {
    return setEntry(customerId, dateKeyStr, { received: 0 });
  }

  function statusFor(entry) {
    const remaining = entry.load - entry.received;
    if (entry.load <= 0) return 'PENDING';
    if (remaining <= 0) return 'PAID';
    if (entry.received > 0) return 'PARTIAL';
    return 'PENDING';
  }

  function dayData(dateKeyStr) {
    const customers = getCustomers();
    const rows = customers.map(c => {
      const entry = getEntry(c.id, dateKeyStr);
      const remaining = entry.load - entry.received;
      const status = statusFor(entry);
      return { ...c, load: entry.load, received: entry.received, remaining, status };
    });
    const totals = rows.reduce((acc, r) => {
      acc.load += r.load;
      acc.received += r.received;
      acc.remaining += r.remaining;
      if (r.status === 'PAID') acc.paid++;
      if (r.status === 'PARTIAL') acc.partial++;
      if (r.status === 'PENDING') acc.pending++;
      return acc;
    }, { load: 0, received: 0, remaining: 0, paid: 0, partial: 0, pending: 0 });
    return { rows, totals, count: rows.length };
  }

  function availableBalance(dateKeyStr) {
    const { totals } = dayData(dateKeyStr);
    return AVAILABLE_BALANCE_BASE - totals.load;
  }

  function formatCurrency(n) {
    const num = Math.round(Number(n) || 0);
    return 'Rs. ' + num.toLocaleString('en-IN');
  }

  function isOnline() {
    return typeof navigator !== 'undefined' ? navigator.onLine : true;
  }

  return {
    AVAILABLE_BALANCE_BASE,
    getCustomers, getCustomer, addCustomer, updateCustomer, setCustomerActive,
    getEntry, setEntry, addLoad, addReceived, markFullyReceived, undoFullyReceived,
    statusFor, dayData, availableBalance,
    dateKey, parseDate, addDays, humanDate, shortDate, todayKey, isToday, isFuture,
    formatCurrency, isOnline,
  };
})();

/* ------------------------------ Modal system ------------------------------ */
const Modal = (() => {
  function ensureRoot() {
    let root = document.getElementById('lb-modal-root');
    if (!root) {
      root = document.createElement('div');
      root.id = 'lb-modal-root';
      document.querySelector('.lb-screen').appendChild(root);
    }
    return root;
  }

  function closeAll() {
    const root = ensureRoot();
    root.innerHTML = '';
  }

  function sheet(innerHtml, { onClose } = {}) {
    const root = ensureRoot();
    root.innerHTML = `
      <div class="lb-overlay" data-close="1">
        <div class="lb-sheet" role="dialog">
          <div class="lb-sheet-grabber"></div>
          ${innerHtml}
        </div>
      </div>`;
    root.querySelector('.lb-overlay').addEventListener('click', (e) => {
      if (e.target.dataset.close) { closeAll(); if (onClose) onClose(); }
    });
  }

  function dialog(innerHtml, { onClose } = {}) {
    const root = ensureRoot();
    root.innerHTML = `
      <div class="lb-overlay center" data-close="1">
        <div class="lb-dialog" role="dialog">${innerHtml}</div>
      </div>`;
    root.querySelector('.lb-overlay').addEventListener('click', (e) => {
      if (e.target.dataset.close) { closeAll(); if (onClose) onClose(); }
    });
  }

  function toast(message, iconName) {
    const screen = document.querySelector('.lb-screen');
    const el = document.createElement('div');
    el.className = 'lb-toast';
    el.innerHTML = `${iconName ? icon(iconName) : ''}<span>${message}</span>`;
    screen.appendChild(el);
    setTimeout(() => el.remove(), 2400);
  }

  return { closeAll, sheet, dialog, toast };
})();

function showNoInternetDialog() {
  Modal.dialog(`
    <div style="width:56px;height:56px;border-radius:999px;background:var(--lb-danger-bg);display:flex;align-items:center;justify-content:center;margin:0 auto 14px;color:var(--lb-danger)">
      ${icon('wifiOff')}
    </div>
    <div style="font-size:19px;font-weight:800;margin-bottom:8px;">No Internet</div>
    <div style="font-size:15px;color:var(--lb-ink-soft);line-height:1.5;margin-bottom:20px;">
      Please connect to the internet to send reminders.
    </div>
    <button class="lb-btn lb-btn-primary lb-btn-lg" onclick="Modal.closeAll()">OK</button>
  `);
}

/* ---------------- Quick amount picker (shared: Load + Received) ---------------- */
const QUICK_AMOUNTS = [5000, 10000, 15000, 20000, 25000];

function openLoadSheet(customerId, dateKeyStr, onDone) {
  const c = LB.getCustomer(customerId);
  const entry = LB.getEntry(customerId, dateKeyStr);
  Modal.sheet(`
    <div class="text-lg font-extrabold">${c.name}</div>
    <div class="text-sm text-ink-soft font-semibold mt-0.5">Load Sent so far: ${LB.formatCurrency(entry.load)}</div>
    <div class="lb-label mt-5">Add Load Sent</div>
    <div class="grid grid-cols-3 gap-2.5">
      ${QUICK_AMOUNTS.map(a => `<button class="lb-chip" data-amt="${a}">${a / 1000}K</button>`).join('')}
      <button class="lb-chip col-span-3" id="customLoadBtn">Custom Amount</button>
    </div>
    <div id="customLoadWrap" class="hidden mt-3.5">
      <input id="customLoadInput" class="lb-input" type="number" inputmode="numeric" placeholder="Enter amount">
    </div>
    <button id="saveLoadBtn" class="lb-btn lb-btn-primary lb-btn-lg mt-5" disabled>Add</button>
  `);
  let selected = null;
  document.querySelectorAll('#lb-modal-root [data-amt]').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('#lb-modal-root [data-amt]').forEach(b => b.classList.remove('selected'));
      btn.classList.add('selected');
      selected = Number(btn.dataset.amt);
      document.getElementById('customLoadWrap').classList.add('hidden');
      document.getElementById('saveLoadBtn').disabled = false;
    });
  });
  document.getElementById('customLoadBtn').addEventListener('click', () => {
    document.querySelectorAll('#lb-modal-root [data-amt]').forEach(b => b.classList.remove('selected'));
    document.getElementById('customLoadWrap').classList.remove('hidden');
    document.getElementById('customLoadInput').focus();
    selected = 'custom';
    document.getElementById('saveLoadBtn').disabled = false;
  });
  document.getElementById('saveLoadBtn').addEventListener('click', () => {
    let amt = selected === 'custom' ? Number(document.getElementById('customLoadInput').value) : selected;
    if (!amt || amt <= 0) return;
    LB.addLoad(customerId, dateKeyStr, amt);
    Modal.closeAll();
    Modal.toast(`Rs. ${amt.toLocaleString('en-IN')} load added for ${c.name}`, 'check');
    if (onDone) onDone();
  });
}

function openReceivedSheet(customerId, dateKeyStr, onDone) {
  const c = LB.getCustomer(customerId);
  const entry = LB.getEntry(customerId, dateKeyStr);
  const remaining = entry.load - entry.received;
  if (entry.load <= 0) {
    Modal.dialog(`
      <div class="w-14 h-14 rounded-full bg-warning-bg flex items-center justify-center mx-auto mb-3.5 text-warning">${ICONS.warning}</div>
      <div class="text-lg font-extrabold">No Load Sent Yet</div>
      <div class="text-sm text-ink-soft mt-2">Send load to ${c.name} first, then record what you receive.</div>
      <button class="lb-btn lb-btn-primary lb-btn-lg mt-5" onclick="Modal.closeAll()">OK</button>
    `);
    return;
  }
  if (remaining <= 0) {
    Modal.dialog(`
      <div class="w-14 h-14 rounded-full bg-success-bg flex items-center justify-center mx-auto mb-3.5 text-success">${ICONS.checkCircle}</div>
      <div class="text-lg font-extrabold">Already Fully Paid</div>
      <div class="text-sm text-ink-soft mt-2">${c.name} has no remaining balance today.</div>
      <button class="lb-btn lb-btn-outline lb-btn-lg mt-5" id="undoPaidBtn">Undo (received by mistake)</button>
      <button class="lb-btn lb-btn-primary lb-btn-lg mt-2.5" onclick="Modal.closeAll()">OK</button>
    `);
    document.getElementById('undoPaidBtn').addEventListener('click', () => {
      LB.undoFullyReceived(customerId, dateKeyStr);
      Modal.closeAll();
      Modal.toast(`Reset ${c.name}'s received amount`, 'check');
      if (onDone) onDone();
    });
    return;
  }
  const quick = QUICK_AMOUNTS.filter(a => a <= remaining);
  Modal.sheet(`
    <div class="text-lg font-extrabold">${c.name}</div>
    <div class="lb-card p-3 mt-3.5 bg-surface-alt !border-0">
      <div class="grid grid-cols-3 gap-1.5 text-center">
        <div><div class="lb-figure-label">Load Sent</div><div class="lb-figure-value">${LB.formatCurrency(entry.load)}</div></div>
        <div><div class="lb-figure-label">Received</div><div class="lb-figure-value text-success">${LB.formatCurrency(entry.received)}</div></div>
        <div><div class="lb-figure-label">Remaining</div><div class="lb-figure-value text-danger">${LB.formatCurrency(remaining)}</div></div>
      </div>
    </div>
    <div class="lb-label mt-5">Amount Received</div>
    <div class="grid grid-cols-3 gap-2.5">
      ${quick.map(a => `<button class="lb-chip" data-amt="${a}">${a / 1000}K</button>`).join('')}
      <button class="lb-chip ${quick.length % 3 === 0 ? 'col-span-3' : ''}" data-amt="${remaining}">Full (${LB.formatCurrency(remaining)})</button>
      <button class="lb-chip col-span-3" id="customPayBtn">Custom Amount</button>
    </div>
    <div id="customPayWrap" class="hidden mt-3.5">
      <input id="customPayInput" class="lb-input" type="number" inputmode="numeric" placeholder="Enter amount" max="${remaining}">
    </div>
    <button id="savePayBtn" class="lb-btn lb-btn-success lb-btn-lg mt-5" disabled>Save Received Amount</button>
  `);
  let selected = null;
  document.querySelectorAll('#lb-modal-root [data-amt]').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('#lb-modal-root [data-amt]').forEach(b => b.classList.remove('selected'));
      btn.classList.add('selected');
      selected = Number(btn.dataset.amt);
      document.getElementById('customPayWrap').classList.add('hidden');
      document.getElementById('savePayBtn').disabled = false;
    });
  });
  document.getElementById('customPayBtn').addEventListener('click', () => {
    document.querySelectorAll('#lb-modal-root [data-amt]').forEach(b => b.classList.remove('selected'));
    document.getElementById('customPayWrap').classList.remove('hidden');
    document.getElementById('customPayInput').focus();
    selected = 'custom';
    document.getElementById('savePayBtn').disabled = false;
  });
  document.getElementById('savePayBtn').addEventListener('click', () => {
    let amt = selected === 'custom' ? Number(document.getElementById('customPayInput').value) : selected;
    if (!amt || amt <= 0) return;
    if (amt > remaining) amt = remaining;
    LB.addReceived(customerId, dateKeyStr, amt);
    Modal.closeAll();
    const nowRemaining = remaining - amt;
    Modal.toast(nowRemaining <= 0 ? `${c.name} is now fully paid` : `Rs. ${amt.toLocaleString('en-IN')} received recorded`, 'check');
    if (onDone) onDone();
  });
}

/* ---------------- Add / Edit shop ---------------- */
function openAddShopSheet(onDone) {
  Modal.sheet(`
    <div class="text-lg font-extrabold">Add Shop</div>
    <div class="text-sm text-ink-soft font-semibold mt-0.5">This shop will appear in your daily list from now on.</div>
    <div class="mt-5">
      <label class="lb-label">Shop Name</label>
      <input id="shopNameInput" class="lb-input" type="text" placeholder="e.g. Ali Mobile Shop">
    </div>
    <div class="mt-3.5">
      <label class="lb-label">Mobile Number</label>
      <input id="shopPhoneInput" class="lb-input" type="tel" inputmode="numeric" placeholder="03xx xxxxxxx">
    </div>
    <div class="mt-3.5">
      <label class="lb-label">Monthly Sales (approx.)</label>
      <input id="shopSalesInput" class="lb-input" type="number" inputmode="numeric" placeholder="e.g. 400000">
    </div>
    <button id="addShopSaveBtn" class="lb-btn lb-btn-primary lb-btn-lg mt-6">Add Shop</button>
  `);
  document.getElementById('addShopSaveBtn').addEventListener('click', () => {
    const name = document.getElementById('shopNameInput').value.trim();
    const phone = document.getElementById('shopPhoneInput').value.trim();
    const monthlySales = document.getElementById('shopSalesInput').value;
    if (!name || !phone) {
      Modal.toast('Please enter shop name and mobile number', 'warning');
      return;
    }
    LB.addCustomer({ name, phone, monthlySales });
    Modal.closeAll();
    Modal.toast(`${name} added to your list`, 'check');
    if (onDone) onDone();
  });
}

function openEditShopSheet(customerId, onDone) {
  const c = LB.getCustomer(customerId);
  Modal.sheet(`
    <div class="text-lg font-extrabold">Edit Shop</div>
    <div class="mt-5">
      <label class="lb-label">Shop Name</label>
      <input id="shopNameInput" class="lb-input" type="text" value="${c.name}">
    </div>
    <div class="mt-3.5">
      <label class="lb-label">Mobile Number</label>
      <input id="shopPhoneInput" class="lb-input" type="tel" inputmode="numeric" value="${c.phone}">
    </div>
    <div class="mt-3.5">
      <label class="lb-label">Monthly Sales (approx.)</label>
      <input id="shopSalesInput" class="lb-input" type="number" inputmode="numeric" value="${c.monthlySales || ''}">
    </div>
    <button id="editShopSaveBtn" class="lb-btn lb-btn-primary lb-btn-lg mt-6">Save Changes</button>
    <button id="editShopRemoveBtn" class="lb-btn lb-btn-danger-outline lb-btn-lg mt-2.5">${ICONS.trash} Remove Shop</button>
  `);
  document.getElementById('editShopSaveBtn').addEventListener('click', () => {
    const name = document.getElementById('shopNameInput').value.trim();
    const phone = document.getElementById('shopPhoneInput').value.trim();
    const monthlySales = document.getElementById('shopSalesInput').value;
    if (!name || !phone) {
      Modal.toast('Please enter shop name and mobile number', 'warning');
      return;
    }
    LB.updateCustomer(customerId, { name, phone, monthlySales: Number(monthlySales) || 0 });
    Modal.closeAll();
    Modal.toast('Shop details updated', 'check');
    if (onDone) onDone();
  });
  document.getElementById('editShopRemoveBtn').addEventListener('click', () => {
    Modal.dialog(`
      <div class="w-14 h-14 rounded-full bg-danger-bg flex items-center justify-center mx-auto mb-3.5 text-danger">${ICONS.trash}</div>
      <div class="text-lg font-extrabold">Remove ${c.name}?</div>
      <div class="text-sm text-ink-soft mt-2">This shop will stop appearing in your daily list. Past records are kept safely.</div>
      <div class="flex flex-col gap-2.5 mt-5">
        <button class="lb-btn lb-btn-danger-outline lb-btn-lg" id="confirmRemoveBtn">Yes, Remove Shop</button>
        <button class="lb-btn lb-btn-outline lb-btn-lg" id="cancelRemoveBtn">Cancel</button>
      </div>
    `);
    document.getElementById('cancelRemoveBtn').addEventListener('click', () => openEditShopSheet(customerId, onDone));
    document.getElementById('confirmRemoveBtn').addEventListener('click', () => {
      LB.setCustomerActive(customerId, false);
      Modal.closeAll();
      Modal.toast(`${c.name} removed from daily list`, 'check');
      if (onDone) onDone();
    });
  });
}

/* ---------------- Bulk WhatsApp reminder ---------------- */
function confirmBulkReminder(pendingCustomers, dateKeyStr) {
  if (pendingCustomers.length === 0) {
    Modal.dialog(`
      <div class="w-14 h-14 rounded-full bg-success-bg flex items-center justify-center mx-auto mb-3.5 text-success">${ICONS.checkCircle}</div>
      <div class="text-lg font-extrabold">All Paid Up</div>
      <div class="text-sm text-ink-soft mt-2">No shop has a pending balance today.</div>
      <button class="lb-btn lb-btn-primary lb-btn-lg mt-5" onclick="Modal.closeAll()">OK</button>
    `);
    return;
  }
  Modal.dialog(`
    <div class="w-14 h-14 rounded-full bg-warning-bg flex items-center justify-center mx-auto mb-3.5 text-warning">${ICONS.bell}</div>
    <div class="text-lg font-extrabold">${pendingCustomers.length} ${pendingCustomers.length === 1 ? 'customer has' : 'customers have'} pending payments.</div>
    <div class="text-sm text-ink-soft mt-2">A WhatsApp reminder will be sent to each of them.</div>
    <div class="flex flex-col gap-2.5 mt-5">
      <button class="lb-btn lb-btn-whatsapp lb-btn-lg" id="confirmSendAll">${ICONS.whatsapp} Send Reminders</button>
      <button class="lb-btn lb-btn-outline lb-btn-lg" onclick="Modal.closeAll()">Cancel</button>
    </div>
  `);
  document.getElementById('confirmSendAll').addEventListener('click', () => {
    if (!LB.isOnline()) { showNoInternetDialog(); return; }
    Modal.dialog(`
      <div class="w-14 h-14 rounded-full bg-success-bg flex items-center justify-center mx-auto mb-3.5 text-success">${ICONS.checkCircle}</div>
      <div class="text-lg font-extrabold">Reminders Sent</div>
      <div class="text-sm text-ink-soft mt-2">${pendingCustomers.length} ${pendingCustomers.length === 1 ? 'shop was' : 'shops were'} notified on WhatsApp.</div>
      <button class="lb-btn lb-btn-primary lb-btn-lg mt-5" onclick="Modal.closeAll()">OK</button>
    `);
  });
}

/* ---------------- Daily report: preview, print (PDF), share ---------------- */
function buildReportHtml(dateKeyStr) {
  const { rows, totals, count } = LB.dayData(dateKeyStr);
  return `
    <div style="font-family:'Inter',-apple-system,sans-serif;color:#17202a;padding:4px;">
      <div style="font-size:22px;font-weight:800;">LoadBook — Daily Report</div>
      <div style="font-size:15px;color:#51606e;font-weight:600;margin-top:2px;">${LB.humanDate(dateKeyStr)}, ${LB.parseDate(dateKeyStr).getFullYear()}</div>
      <div style="display:flex;gap:10px;margin-top:16px;flex-wrap:wrap;">
        ${[
          ['Total Shops', count],
          ['Total Load Sent', LB.formatCurrency(totals.load)],
          ['Total Received', LB.formatCurrency(totals.received)],
          ['Total Remaining', LB.formatCurrency(totals.remaining)],
          ['Paid', totals.paid],
          ['Pending', totals.partial + totals.pending],
        ].map(([label, val]) => `
          <div style="border:1px solid #e3e7eb;border-radius:10px;padding:8px 12px;min-width:110px;">
            <div style="font-size:10.5px;font-weight:700;color:#8a97a3;text-transform:uppercase;">${label}</div>
            <div style="font-size:16px;font-weight:800;margin-top:2px;">${val}</div>
          </div>`).join('')}
      </div>
      <table style="width:100%;border-collapse:collapse;margin-top:18px;font-size:13px;">
        <thead>
          <tr style="text-align:left;border-bottom:2px solid #17202a;">
            <th style="padding:6px 4px;">Shop</th>
            <th style="padding:6px 4px;">Number</th>
            <th style="padding:6px 4px;text-align:right;">Load Sent</th>
            <th style="padding:6px 4px;text-align:right;">Received</th>
            <th style="padding:6px 4px;text-align:right;">Remaining</th>
          </tr>
        </thead>
        <tbody>
          ${rows.map(r => `
            <tr style="border-bottom:1px solid #e3e7eb;">
              <td style="padding:6px 4px;font-weight:700;">${r.name}</td>
              <td style="padding:6px 4px;color:#51606e;">${r.phone}</td>
              <td style="padding:6px 4px;text-align:right;">${LB.formatCurrency(r.load)}</td>
              <td style="padding:6px 4px;text-align:right;">${LB.formatCurrency(r.received)}</td>
              <td style="padding:6px 4px;text-align:right;color:${r.remaining > 0 ? '#dc2626' : '#16a34a'};">${LB.formatCurrency(r.remaining)}</td>
            </tr>`).join('')}
        </tbody>
      </table>
    </div>
  `;
}

function buildReportText(dateKeyStr) {
  const { rows, totals, count } = LB.dayData(dateKeyStr);
  const lines = [
    `LoadBook — Daily Report`,
    `${LB.humanDate(dateKeyStr)}, ${LB.parseDate(dateKeyStr).getFullYear()}`,
    ``,
    `Total Shops: ${count}`,
    `Total Load Sent: ${LB.formatCurrency(totals.load)}`,
    `Total Received: ${LB.formatCurrency(totals.received)}`,
    `Total Remaining: ${LB.formatCurrency(totals.remaining)}`,
    `Paid: ${totals.paid}   Pending: ${totals.partial + totals.pending}`,
    ``,
    ...rows.map(r => `${r.name} (${r.phone}) — Sent ${LB.formatCurrency(r.load)}, Received ${LB.formatCurrency(r.received)}, Remaining ${LB.formatCurrency(r.remaining)}`),
  ];
  return lines.join('\n');
}

function printReport(dateKeyStr) {
  let printRoot = document.getElementById('lb-print-root');
  if (!printRoot) {
    printRoot = document.createElement('div');
    printRoot.id = 'lb-print-root';
    document.body.appendChild(printRoot);
  }
  printRoot.innerHTML = buildReportHtml(dateKeyStr);
  document.body.classList.add('lb-printing');
  window.print();
  setTimeout(() => document.body.classList.remove('lb-printing'), 300);
}

function shareReport(dateKeyStr) {
  const text = buildReportText(dateKeyStr);
  if (navigator.share) {
    navigator.share({ title: 'LoadBook Daily Report', text }).catch(() => {});
    return;
  }
  if (navigator.clipboard) {
    navigator.clipboard.writeText(text).then(() => {
      Modal.toast('Report copied — paste it in WhatsApp', 'share');
    }).catch(() => {
      Modal.toast('Could not copy report', 'warning');
    });
  }
}

function openReportPreview(dateKeyStr) {
  const { totals, count } = LB.dayData(dateKeyStr);
  Modal.sheet(`
    <div class="text-lg font-extrabold">Daily Report</div>
    <div class="text-sm text-ink-soft font-semibold mt-0.5">${LB.humanDate(dateKeyStr)}</div>
    <div class="lb-card p-4 mt-4 bg-surface-alt !border-0">
      <div class="grid grid-cols-2 gap-3">
        <div><div class="lb-figure-label">Total Shops</div><div class="lb-figure-value">${count}</div></div>
        <div><div class="lb-figure-label">Total Load Sent</div><div class="lb-figure-value">${LB.formatCurrency(totals.load)}</div></div>
        <div><div class="lb-figure-label">Total Received</div><div class="lb-figure-value text-success">${LB.formatCurrency(totals.received)}</div></div>
        <div><div class="lb-figure-label">Total Remaining</div><div class="lb-figure-value text-danger">${LB.formatCurrency(totals.remaining)}</div></div>
        <div><div class="lb-figure-label">Paid</div><div class="lb-figure-value text-success">${totals.paid}</div></div>
        <div><div class="lb-figure-label">Pending</div><div class="lb-figure-value text-danger">${totals.partial + totals.pending}</div></div>
      </div>
    </div>
    <div class="flex flex-col gap-2.5 mt-5">
      <button class="lb-btn lb-btn-primary lb-btn-lg" id="downloadPdfBtn">${ICONS.fileText} Download PDF</button>
      <button class="lb-btn lb-btn-outline lb-btn-lg" id="shareReportBtn">${ICONS.share} Share Report</button>
    </div>
  `);
  document.getElementById('downloadPdfBtn').addEventListener('click', () => printReport(dateKeyStr));
  document.getElementById('shareReportBtn').addEventListener('click', () => shareReport(dateKeyStr));
}

/* ---------------- Calendar / previous day picker ---------------- */
function openCalendarSheet(currentDateKey, onPick) {
  let view = LB.parseDate(currentDateKey);
  view = new Date(view.getFullYear(), view.getMonth(), 1);

  function render() {
    const monthNames = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    const year = view.getFullYear();
    const month = view.getMonth();
    const first = new Date(year, month, 1);
    const startDow = first.getDay();
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const todayKey = LB.todayKey();

    let cells = '';
    for (let i = 0; i < startDow; i++) cells += `<div></div>`;
    for (let d = 1; d <= daysInMonth; d++) {
      const key = `${year}-${String(month + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      const isSel = key === currentDateKey;
      const isToday = key === todayKey;
      const future = LB.isFuture(key);
      cells += `<button class="lb-cal-cell ${isSel ? 'selected' : ''} ${isToday && !isSel ? 'today' : ''}" ${future ? 'disabled' : ''} data-date="${key}">${d}</button>`;
    }

    Modal.sheet(`
      <div class="flex items-center justify-between">
        <button class="lb-icon-btn" id="calPrevMonth">${icon('chevronLeft')}</button>
        <div class="text-base font-extrabold">${monthNames[month]} ${year}</div>
        <button class="lb-icon-btn" id="calNextMonth">${icon('chevronRight')}</button>
      </div>
      <div class="lb-cal-grid lb-cal-dow mt-4">
        ${['S','M','T','W','T','F','S'].map(d => `<div>${d}</div>`).join('')}
      </div>
      <div class="lb-cal-grid mt-1">${cells}</div>
      <button class="lb-btn lb-btn-outline lb-btn-lg mt-5" id="calGoToday">Go to Today</button>
    `);

    document.getElementById('calPrevMonth').addEventListener('click', () => {
      view = new Date(year, month - 1, 1);
      render();
    });
    document.getElementById('calNextMonth').addEventListener('click', () => {
      view = new Date(year, month + 1, 1);
      render();
    });
    document.getElementById('calGoToday').addEventListener('click', () => onPick(todayKey));
    document.querySelectorAll('.lb-cal-cell[data-date]').forEach(btn => {
      btn.addEventListener('click', () => onPick(btn.dataset.date));
    });
  }

  render();
}
