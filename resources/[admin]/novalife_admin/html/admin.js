// NovaLife Admin — admin.js
const app = document.getElementById('app');
const actions = [
    { label: 'Kick', cmd: 'kick' }, { label: 'Ban', cmd: 'ban' },
    { label: 'Freeze', cmd: 'freeze' }, { label: 'Goto', cmd: 'goto' },
    { label: 'Bring', cmd: 'bring' }, { label: 'Revive', cmd: 'revive' },
    { label: 'Heal', cmd: 'heal' }, { label: 'TP Waypoint', cmd: 'tpm' },
    { label: 'Give Item', cmd: 'giveitem' }, { label: 'Give Money', cmd: 'givemoney' },
    { label: 'Set Job', cmd: 'setjob' }, { label: 'Set Grade', cmd: 'setgrade' },
    { label: 'Spawn Car', cmd: 'car' }, { label: 'Delete Veh', cmd: 'dv' },
];

window.addEventListener('message', e => { if (e.data.action === 'openAdmin') { app.classList.remove('hidden'); render(); } });

function render() {
    const g = document.getElementById('grid'); g.innerHTML = '';
    actions.forEach(a => {
        const b = document.createElement('button'); b.className = 'btn'; b.textContent = a.label;
        b.onclick = () => {
            const args = prompt(a.label + ' — arguments (ex: id [montant])');
            if (args !== null) post('action', { cmd: a.cmd, args });
        };
        g.appendChild(b);
    });
}
document.getElementById('close').onclick = () => { app.classList.add('hidden'); post('closeAdmin'); };
function post(action, data) {
    fetch(`https://${GetParentResourceName()}/`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ action, data }) })
        .then(r => r.json()).catch(() => {});
}
