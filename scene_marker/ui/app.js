const panel = document.getElementById('panel');
const color = document.getElementById('color');
const duration = document.getElementById('duration');
const text = document.getElementById('text');

document.getElementById('cancel').onclick = () => fetchNui('close', {});
document.getElementById('submit').onclick = () => {
  fetchNui('submit', {
    colorRgb: color.value,
    duration: parseInt(duration.value, 10),
    text: text.value
  });
};

window.addEventListener('message', (event) => {
  const data = event.data;
  if (data.action === 'open') {
    panel.classList.remove('hidden');
    color.innerHTML = '';

    Object.values(data.colors || {}).forEach((item, idx) => {
      const option = document.createElement('option');
      option.value = `${item.color[0]},${item.color[1]},${item.color[2]}`;
      option.textContent = item.label;
      color.appendChild(option);
    });
  }

  if (data.action === 'close') {
    panel.classList.add('hidden');
  }
});

function fetchNui(name, payload) {
  fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });
}
