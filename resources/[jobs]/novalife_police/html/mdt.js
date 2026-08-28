// NovaLife — MDT police (app.js)
const app = document.getElementById('app');
const pages = {};
document.querySelectorAll('.page').forEach(p => pages[p.id.replace('page-','')] = p);

window.addEventListener('message', e => { if (e.data.action === 'openMDT') { app.classList.remove('hidden'); } });

document.querySelectorAll('.nav').forEach(n => n.onclick = () => {
    document.querySelectorAll('.nav').forEach(x => x.classList.remove('active'));
    n.classList.add('active');
    for (const k in pages) pages[k].classList.toggle('hidden', k !== n.dataset.p);
});

function post(action, data, cb) {
    fetch(`https://${GetParentResourceName()}/`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ action, data }) })
        .then(r => r.json()).then(cb).catch(() => cb && cb({}));
}

document.getElementById('search').addEventListener('keydown', e => {
    if (e.key !== 'Enter') return;
    const q = e.target.value.trim();
    if (!q) return;
    // plaque ou citizenid ?
    if (/^[A-Z0-9]{3,8}$/i.test(q)) {
        post('plate', q, r => {
            if (r && r.found) pages.plate.innerHTML = `<div class="card"><b>${esc(r.vehicle)}</b> — Propriétaire: ${esc(r.owner)}<br>CitizenID: ${esc(r.citizenid)}<br>Volé: ${r.stolen?'OUI':'non'}</div>`;
            else pages.plate.innerHTML = '<div class="card lst">Aucun résultat.</div>';
        });
    } else {
        post('records', q, r => {
            if (r && r.length) {
                pages.records.innerHTML = r.map(x => `<div class="card"><b>${esc(x.charges)}</b><br>Officier: ${esc(x.officer)}<br>${esc(x.date)}</div>`).join('');
            } else pages.records.innerHTML = '<div class="card lst">Casier vierge.</div>';
        });
    }
});

function esc(s) { return String(s==null?'':s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
