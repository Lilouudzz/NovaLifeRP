// NovaLife — Owner Panel (owner.js)
const app = document.getElementById('app');
const pages = {}; document.querySelectorAll('.page').forEach(p => pages[p.id.replace('page-','')] = p);

window.addEventListener('message', e => { if (e.data.action === 'openOwner') { app.classList.remove('hidden'); loadAll(); } });

document.querySelectorAll('#nav button').forEach(b => b.onclick = () => {
    document.querySelectorAll('#nav button').forEach(x => x.classList.remove('active'));
    b.classList.add('active');
    for (const k in pages) pages[k].classList.toggle('hidden', k !== b.dataset.p);
    if (b.dataset.p === 'players') loadPlayers();
    if (b.dataset.p === 'properties') loadProps();
    if (b.dataset.p === 'logs') loadLogs();
    if (b.dataset.p === 'jobs') fillJobs();
});

document.getElementById('close').onclick = () => { app.classList.add('hidden'); post('closeOwner'); };

function post(action, data, cb) {
    fetch(`https://${GetParentResourceName()}/`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ action, data }) })
        .then(r => r.json()).then(cb).catch(() => cb && cb({}));
}
function esc(s) { return String(s==null?'':s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }

// ---- Joueurs ----
async function loadPlayers() {
    const list = await new Promise(r => post('getPlayers', {}, r));
    const tb = document.querySelector('#players-table tbody'); tb.innerHTML = '';
    (list || []).forEach(p => {
        const tr = document.createElement('tr');
        tr.innerHTML = `<td>${p.id}</td><td>${esc(p.name)}</td><td>${esc(p.citizenid)}</td><td>${esc(p.job)}</td><td>${p.grade}</td><td>${p.cash}$</td><td>${p.bank}$</td>`;
        const act = document.createElement('td');
        ['TP→','Ramener','Spec','Freeze','Revive','Heal','Kick','Ban'].forEach(a => {
            const b = document.createElement('button'); b.className='btn'; b.style.padding='4px 7px'; b.style.margin='2px'; b.textContent=a;
            b.onclick = () => {
                if (a==='TP→') post('srv', { e:'tp', action:'to', target:p.id });
                else if (a==='Ramener') post('srv', { e:'tp', action:'bring', target:p.id });
                else if (a==='Spec') post('srv', { e:'spectate', target:p.id });
                else if (a==='Freeze'||a==='Revive'||a==='Heal') post('srv', { e:'sanction', action:a.toLowerCase(), target:p.id });
                else if (a==='Kick') confirmAction('Kick '+p.name, () => post('srv', { e:'sanction', action:'kick', target:p.id, reason:'Owner' }));
                else if (a==='Ban') confirmAction('Ban '+p.name, () => post('srv', { e:'sanction', action:'ban', target:p.id, reason:'Owner' }));
            };
            act.appendChild(b);
        });
        tr.appendChild(act); tb.appendChild(tr);
    });
}

// ---- Argent ----
document.getElementById('m-go').onclick = () => {
    const target = +document.getElementById('m-target').value, amount = +document.getElementById('m-amount').value, action = document.getElementById('m-action').value;
    post('srv', { e:'money', action, target, amount, confirm:false });
};
// ---- Inventaire ----
document.getElementById('i-go').onclick = () => post('srv', { e:'item', action:document.getElementById('i-action').value, target:+document.getElementById('i-target').value, item:document.getElementById('i-item').value, count:+document.getElementById('i-count').value });
// ---- Jobs ----
async function fillJobs() {
    const jobs = await new Promise(r => post('getJobs', {}, r));
    const sel = document.getElementById('j-job'); sel.innerHTML = '';
    (jobs||[]).forEach(j => { const o=document.createElement('option'); o.value=j.name; o.textContent=j.name+' (grades: '+j.grades+')'; sel.appendChild(o); });
}
document.getElementById('j-go').onclick = () => post('srv', { e:'job', action:document.getElementById('j-action').value, target:+document.getElementById('j-target').value, job:document.getElementById('j-job').value, grade:+document.getElementById('j-grade').value });
// ---- Véhicules ----
document.querySelectorAll('[data-va]').forEach(b => b.onclick = () => post('srv', { e:'vehicle', action:b.dataset.va, target:+document.getElementById('v-target').value, model:prompt('Modèle ?'), plate:document.getElementById('v-plate').value, data:{} }));
document.getElementById('v-give').onclick = () => post('srv', { e:'vehicle', action:'give', target:+document.getElementById('v-target').value, plate:document.getElementById('v-plate').value });
document.getElementById('v-plate').onclick = () => post('srv', { e:'vehicle', action:'plate', plate:document.getElementById('v-plate').value, data:{ newplate:document.getElementById('v-newplate').value } });
// ---- Propriétés ----
async function loadProps() {
    const list = await new Promise(r => post('getProperties', {}, r));
    const tb = document.querySelector('#prop-table tbody'); tb.innerHTML = '';
    (list||[]).forEach(p => {
        const tr = document.createElement('tr');
        tr.innerHTML = `<td>${p.id}</td><td>${esc(p.name)}</td><td>${p.price}$</td><td>${esc(p.owner_cid||'-')}</td>`;
        const act = document.createElement('td');
        ['Clés','Donner','Suppr'].forEach(a => {
            const b=document.createElement('button'); b.className='btn'; b.style.padding='4px 7px'; b.style.margin='2px'; b.textContent=a;
            b.onclick = () => {
                if (a==='Clés') showKeys(p.id);
                else if (a==='Donner') { const cid=prompt('citizenid ?'); post('srv', { e:'property', action:'give', data:{ id:p.id, cid } }); }
                else if (a==='Suppr') confirmAction('Supprimer propriété '+p.name, () => post('srv', { e:'property', action:'delete', data:{ id:p.id } }));
            };
            act.appendChild(b);
        });
        tr.appendChild(act); tb.appendChild(tr);
    });
}
document.getElementById('p-create').onclick = () => post('startCreate', 'property');
async function showKeys(id) {
    document.getElementById('prop-keys').classList.remove('hidden');
    const keys = await new Promise(r => post('getPropertyKeys', id, r));
    document.getElementById('prop-keys-list').innerHTML = (keys||[]).map(k => `<div>${esc(k.citizenid)} <button class="btn" onclick="removeKey(${id},'${esc(k.citizenid)}')">Retirer</button></div>`).join('');
}
function removeKey(id, cid) { post('srv', { e:'property', action:'delkey', data:{ id, cid } }); }
document.getElementById('pk-add').onclick = () => { const id = prompt('ID propriété ?'); post('srv', { e:'property', action:'setkey', data:{ id:+id, cid:document.getElementById('pk-cid').value } }); };
// ---- Entreprises ----
document.getElementById('b-go').onclick = () => {
    const a = document.getElementById('b-action').value;
    const data = a==='balance' ? { name:document.getElementById('b-name').value, balance:+document.getElementById('b-cid').value }
        : { name:document.getElementById('b-name').value, label:document.getElementById('b-label').value, owner:document.getElementById('b-cid').value, cid:document.getElementById('b-cid').value };
    post('srv', { e:'business', action:a, data });
};
// ---- Téléport ----
document.getElementById('tp-to').onclick = () => post('srv', { e:'tp', action:'to', target:+document.getElementById('tp-target').value });
document.getElementById('tp-bring').onclick = () => post('srv', { e:'tp', action:'bring', target:+document.getElementById('tp-target').value });
document.getElementById('tp-coords').onclick = () => post('srv', { e:'tpcoords', x:+document.getElementById('tp-x').value, y:+document.getElementById('tp-y').value, z:+document.getElementById('tp-z').value });
document.getElementById('tp-spectate').onclick = () => post('srv', { e:'spectate', target:+document.getElementById('tp-target').value });
// ---- Sanctions ----
document.getElementById('s-go').onclick = () => {
    const a = document.getElementById('s-action').value;
    const fn = () => post('srv', { e:'sanction', action:a, target:+document.getElementById('s-target').value, reason:document.getElementById('s-reason').value });
    if (a==='kick'||a==='ban') confirmAction(a, fn); else fn();
};
// ---- Positions ----
document.querySelectorAll('.pos').forEach(b => b.onclick = () => post('startCreate', b.dataset.kind));
window.addEventListener('message', e => { if (e.data.action === 'createResult') document.getElementById('pos-result').textContent = JSON.stringify(e.data.data, null, 2); });
// ---- Config ----
document.getElementById('cj-go').onclick = () => post('srv', { e:'config', key:'job_payment', value:{ name:document.getElementById('cj-name').value, grade:+document.getElementById('cj-grade').value, payment:+document.getElementById('cj-pay').value } });
document.getElementById('cv-go').onclick = () => post('srv', { e:'config', key:'vehicle_price', value:{ model:document.getElementById('cv-model').value, price:+document.getElementById('cv-price').value } });
document.getElementById('ce-go').onclick = () => post('srv', { e:'config', key:'economy_start', value:{ cash:+document.getElementById('ce-cash').value, bank:+document.getElementById('ce-bank').value } });
document.getElementById('cf-go').onclick = () => post('srv', { e:'config', key:'fuel_price', value:{ type:document.getElementById('cf-type').value, price:+document.getElementById('cf-price').value } });
// ---- Logs ----
async function loadLogs() {
    const l = await new Promise(r => post('getLogs', {}, r));
    document.getElementById('logs-list').innerHTML = (l||[]).map(x => `<div class="log">[${esc(x.ts)}] ${esc(x.kind)} — ${esc(x.message)}</div>`).join('') || '<div class="hint">Aucun log.</div>';
}
// ---- Confirmation ----
function confirmAction(text, cb) { if (confirm(text + ' ?')) cb(); }
