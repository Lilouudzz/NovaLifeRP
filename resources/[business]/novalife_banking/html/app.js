// NovaLife Bank — app.js
const app = document.getElementById('app');
const fmt = (n) => Number(n).toLocaleString('fr-FR') + '$';

window.addEventListener('message', (e) => {
  const d = e.data;
  if (d.action === 'openBank') render(d.data);
});

function render(data) {
  app.classList.remove('hidden');
  document.getElementById('bank').textContent = fmt(data.balance);
  document.getElementById('cash').textContent = fmt(data.cash);
  renderBills(data.bills);
  renderHist(data.history);
}

function renderBills(bills) {
  const el = document.getElementById('bills'); el.innerHTML = '';
  if (!bills.length) el.innerHTML = '<div class="item"><span>Aucune facture</span></div>';
  bills.forEach(b => {
    const i = document.createElement('div'); i.className = 'item';
    i.innerHTML = `<div><b>${fmt(b.amount)}</b><div class="meta">${esc(b.reason)} · ${esc(b.sender)}</div></div>`;
    const btn = document.createElement('button'); btn.textContent = 'Payer';
    btn.onclick = () => post('payBill', b.id, (r) => { if (r.success) refresh(); else alert('Erreur: ' + (r.error||'')); });
    i.appendChild(btn); el.appendChild(i);
  });
}

function renderHist(h) {
  const el = document.getElementById('hist'); el.innerHTML = '';
  if (!h.length) el.innerHTML = '<div class="item"><span>Aucun mouvement</span></div>';
  h.forEach(t => {
    const i = document.createElement('div'); i.className = 'item';
    i.innerHTML = `<div><b>${fmt(t.amount)}</b><div class="meta">${esc(t.type)} ${t.counterparty?'→ '+esc(t.counterparty):''} · ${esc(t.ts)}</div></div>`;
    el.appendChild(i);
  });
}

function refresh() {
  // Demande au client de recharger les données et de renvoyer openBank
  post('refresh', {}, (data) => { if (data) render(data); });
}

document.getElementById('close').onclick = () => { app.classList.add('hidden'); post('closeBank'); };
document.getElementById('deposit').onclick = () => act('deposit', +document.getElementById('amount').value);
document.getElementById('withdraw').onclick = () => act('withdraw', +document.getElementById('amount').value);
document.getElementById('transfer').onclick = () => act('transfer', { target: document.getElementById('target').value, amount: +document.getElementById('amount').value });
document.querySelectorAll('.tab').forEach(t => t.onclick = () => {
  document.querySelectorAll('.tab').forEach(x => x.classList.remove('active'));
  t.classList.add('active');
  document.getElementById('bills').classList.toggle('hidden', t.dataset.t !== 'bills');
  document.getElementById('hist').classList.toggle('hidden', t.dataset.t !== 'hist');
});

function act(a, v) {
  post(a, v, (r) => { if (r && r.success) refresh(); else if (r && r.error) alert('Erreur: ' + r.error); });
}
function post(action, data, cb) {
  fetch(`https://${GetParentResourceName()}/`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ action, data }) })
    .then(r => r.json()).then(cb).catch(() => cb && cb({}));
}
function esc(s) { return String(s||'').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
