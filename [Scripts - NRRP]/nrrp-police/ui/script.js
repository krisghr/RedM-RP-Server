const panel = document.getElementById('panel');
const targetInput = document.getElementById('target');
const locationSelect = document.getElementById('location');
const durationSlider = document.getElementById('duration');
const durationLabel = document.getElementById('durationLabel');
const reasonInput = document.getElementById('reason');
const submitBtn = document.getElementById('submit');
const cancelBtn = document.getElementById('cancel');

const durations = [
    { label: '30m', value: '30m' },
    ...Array.from({ length: 72 }, (_, i) => {
        const hour = i + 1;
        return { label: `${hour}h`, value: `${hour}h` };
    }),
    { label: 'Indefinite', value: 'indefinite' }
];

durationSlider.min = '0';
durationSlider.max = String(durations.length - 1);
durationSlider.value = '0';

function updateDurationLabel() {
    const index = Number(durationSlider.value) || 0;
    durationLabel.textContent = durations[index]?.label || '30m';
}

function openUi(payload) {
    const locations = payload?.locations || [];

    locationSelect.innerHTML = '';

    for (const location of locations) {
        const option = document.createElement('option');
        option.value = String(location.id);
        option.textContent = location.label || `Cell ${location.id}`;
        locationSelect.appendChild(option);
    }

    durationSlider.value = '0';
    updateDurationLabel();

    targetInput.value = '';
    reasonInput.value = '';

    panel.classList.remove('hidden');
    panel.style.display = 'block';

    setTimeout(() => targetInput.focus(), 50);
}

function closeUi() {
    panel.classList.add('hidden');
    panel.style.display = 'none';
}

async function post(endpoint, payload) {
    await fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload || {})
    });
}

window.addEventListener('message', (event) => {
    const data = event.data || {};

    if (data.action === 'openJailUi') {
        openUi(data.payload || {});
    }

    if (data.action === 'closeJailUi') {
        closeUi();
    }
});

durationSlider.addEventListener('input', updateDurationLabel);

submitBtn.addEventListener('click', async () => {
    const targetRaw = targetInput.value.trim();
    const targetId = targetRaw.split(/\s+/)[0];
    const durationIndex = Number(durationSlider.value) || 0;

    await post('submitJailForm', {
        targetId,
        targetName: targetRaw,
        cellId: Number(locationSelect.value),
        duration: durations[durationIndex]?.value || '30m',
        reason: reasonInput.value.trim()
    });
});

cancelBtn.addEventListener('click', async () => {
    await post('closeJailUi', {});
    closeUi();
});

document.addEventListener('keydown', async (e) => {
    if (e.key === 'Escape') {
        await post('closeJailUi', {});
        closeUi();
    }
});

updateDurationLabel();
closeUi();