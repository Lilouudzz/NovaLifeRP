// NovaLife Phone — phone.js
const phone = document.getElementById('phone');
const views = {};
document.querySelectorAll('.view').forEach(v => views[v.id.replace('view-','')] = v);

window.addEventListener('message', e => {
    if (e.data.action === 'openPhone') phone.classList.remove('hidden');
    if (e.data.action === 'closePhone') phone.classList.add('hidden');
});

document.querySelectorAll('.apps button').forEach(b => b.onclick = () => {
    for (const k in views) views[k].classList.toggle('hidden', k !== b.dataset.a);
    if (b.dataset.a === 'contacts') loadContacts();
    if (b.dataset.a === 'ads') loadAds();
    if (b.dataset.a === 'bank') loadBank();
});

setInterval(() => { document.getElementById('clock').textContent = new Date().toLocaleTimeString('fr-FR'); }, 1000);

function post(action, data, cb) {
    fetch(`https://${GetParentResourceName()}/`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ action, data }) })
        .then(r => r.json()).then(cb).catch(() => cb && cb({}));
}

async function loadContacts() {
    const c = await new Promise(res => post('getContacts', {}, res));
    views.contacts.innerHTML = '<h3>Contacts</h3>' + (c || []).map(x => `<div>${esc(x.name)} — ${esc(x.number)}</div>`).join('') +
        '<input class="input" id="cname" placeholder="Nom"><input class="input" id="cnum" placeholder="Numéro"><button class="btn" id="addc">Ajouter</button>';
    document.getElementById('addc').onclick = () => post('addContact', { name: document.getElementById('cname').value, number: document.getElementById('cnum').value }, () => loadContacts());
}

async function loadAds() {
    const a = await new Promise(res => post('getAnnounces', {}, res));
    views.ads.innerHTML = '<h3>Annonces</h3>' + (a || []).map(x => `<div><b>${esc(x.author)}</b>: ${esc(x.body)}</div>`).join('') +
        '<input class="input" id="adbody" placeholder="Votre annonce"><button class="btn" id="postad">Publier</button>';
    document.getElementById('postad').onclick = () => post('announce', { body: document.getElementById('adbody').value }, () => loadAds());
}

async function loadBank() {
    const b = await new Promise(res => post('bankInfo', {}, res));
    views.bank.innerHTML = '<h3>Banque</h3>' + (b ? `<div>Compte: ${b.balance}$</div>` : '<div>Indisponible</div>');
}

// SMS simple
views.sms.innerHTML = '<h3>SMS</h3><input class="input" id="snum" placeholder="Numéro"><input class="input" id="sbody" placeholder="Message"><button class="btn" id="sendsms">Envoyer</button>';
document.getElementById('sendsms').onclick = () => post('sendSMS', { number: document.getElementById('snum').value, body: document.getElementById('sbody').value }, () => {});

// Urgences
views.emerg.innerHTML = '<h3>Urgences</h3><button class="btn" id="em-p">Police 911</button><button class="btn" id="em-m">EMS 112</button>';
document.getElementById('em-p').onclick = () => { const m = prompt('Message'); if (m) post('emergency', { service: 'police', msg: m }); };
document.getElementById('em-m').onclick = () => { const m = prompt('Message'); if (m) post('emergency', { service: 'ems', msg: m }); };

function esc(s) { return String(s||'').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
