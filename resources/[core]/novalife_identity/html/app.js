// NovaLife RP — identité NUI (app.js)
const app = document.getElementById('app');
const screens = {
  select: document.getElementById('select-screen'),
  create: document.getElementById('create-screen'),
  id: document.getElementById('id-card'),
  lic: document.getElementById('lic-screen'),
};

function show(name) {
  app.classList.remove('hidden');
  for (const k in screens) screens[k].classList.toggle('hidden', k !== name);
}
function hideAll() { app.classList.add('hidden'); }

window.addEventListener('message', (e) => {
  const d = e.data;
  if (d.action === 'openIdentity') {
    if (d.mode === 'select') { renderChars(d.data || []); show('select'); }
    else { show('create'); }
  } else if (d.action === 'showId') {
    renderId(d.data); show('id');
  } else if (d.action === 'showLicenses') {
    renderLicenses(d.data); show('lic');
  }
});

function renderChars(chars) {
  const list = document.getElementById('char-list');
  list.innerHTML = '';
  chars.forEach((c) => {
    const el = document.createElement('div');
    el.className = 'char-card';
    el.innerHTML = `<div class="name">${esc(c.identity.firstname)} ${esc(c.identity.lastname)}</div>
      <div class="meta">${esc(c.identity.dob)} · ${c.identity.sex}</div>`;
    el.onclick = () => post('selectCharacter', c.charId);
    list.appendChild(el);
  });
  document.getElementById('btn-new').onclick = () => show('create');
}

function renderId(id) {
  document.getElementById('id-body').innerHTML = `
    <div><b>Nom</b><br>${esc(id.lastname)}</div>
    <div><b>Prénom</b><br>${esc(id.firstname)}</div>
    <div><b>Né(e) le</b><br>${esc(id.dob)}</div>
    <div><b>Sexe</b><br>${esc(id.sex)}</div>
    <div><b>Taille</b><br>${esc(id.height)} cm</div>
    <div><b>Nationalité</b><br>${esc(id.nationality)}</div>
    <div style="grid-column:1/3"><b>Citizen ID</b><br>${esc(id.citizenid)}</div>`;
}

function renderLicenses(lic) {
  const map = { car: 'Voiture', bike: 'Moto', truck: 'Poids lourd', weapon: 'Arme' };
  const list = document.getElementById('lic-list');
  list.innerHTML = '';
  for (const k in map) {
    const ok = lic[k];
    const el = document.createElement('div');
    el.className = 'lic-item';
    el.innerHTML = `<span>${map[k]}</span><span class="${ok ? 'ok' : 'no'}">${ok ? 'OBTENU' : 'ABSENT'}</span>`;
    list.appendChild(el);
  }
}

document.getElementById('btn-create').onclick = () => {
  const data = {
    firstname: document.getElementById('firstname').value.trim(),
    lastname: document.getElementById('lastname').value.trim(),
    dob: document.getElementById('dob').value,
    sex: document.getElementById('sex').value,
    height: document.getElementById('height').value,
    nationality: document.getElementById('nationality').value.trim(),
  };
  post('createCharacter', data, (res) => {
    if (!res.success) document.getElementById('create-error').textContent = msgFor(res.error);
  });
};

document.getElementById('btn-id-close').onclick = () => { hideAll(); post('closeIdentity'); };
document.getElementById('btn-lic-close').onclick = () => { hideAll(); post('closeIdentity'); };

function post(action, data, cb) {
  fetch(`https://${GetParentResourceName()}/`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ action, data })
  }).then(r => r.json()).then(r => cb && cb(r)).catch(() => cb && cb({}));
}
function esc(s) { return String(s || '').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
function msgFor(e) {
  return { format:'Champs invalides', prénom:'Prénom invalide', nom:'Nom invalide',
    'date de naissance':'Date invalide (AAAA-MM-JJ)', sexe:'Sexe invalide', taille:'Taille 120–220 cm',
    nationalité:'Nationalité invalide', max_persos:'Maximum de personnages atteint' }[e] || 'Erreur';
}
