// NovaLife Radio — radio.js
const radio = document.getElementById('radio');
window.addEventListener('message', e => {
    if (e.data.action === 'openRadio') radio.classList.remove('hidden');
    if (e.data.action === 'closeRadio') radio.classList.add('hidden');
    if (e.data.action === 'setFreq') {
        document.getElementById('freq').textContent = e.data.freq || '—';
        document.getElementById('status').textContent = (e.data.freq && e.data.freq !== 0) ? 'EN SERVICE' : 'ÉTEINTE';
    }
});
document.getElementById('power').onclick = () => post('radioPower');
document.getElementById('set').onclick = () => post('setChannel', document.getElementById('channel').value);
function post(a, v) { fetch('https://' + (window.GetParentResourceName ? GetParentResourceName() : 'novalife_voice') + '/', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ action:a, value:v }) }).catch(()=>{}); }
