const panel = document.getElementById('panel');
const targetInput = document.getElementById('target');
const locationSelect = document.getElementById('location');
const durationSlider = document.getElementById('duration');
const durationLabel = document.getElementById('durationLabel');
const reasonInput = document.getElementById('reason');

const durations = [
    { label: '30m', value: '30m' },
    ...Array.from({ length: 72 }, (_, i) => {
        const hour = i + 1;
        return { label: `${hour}h`, value: `${hour}h` };
    }),
    { label: 'Indefinite', value: 'indefinite' }
];

function updateDurationLabel() {
    const index = Number(durationSlider.value) || 0;
    durationLabel.textContent = durations[index].label;
}

async function post(endpoint, payload) {
    await fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload || {})
    });
}

window.addEventListener('message', (event) => {
    if (event.data.action === 'openJailUi') {
        const payload = event.data.payload || {};
        const locations = payload.locations || [];

        locationSelect.innerHTML = '';
        for (const location of locations) {
            const option = document.createElement('option');
            option.value = String(location.id);
            option.textContent = location.label;
            locationSelect.appendChild(option);
        }

        durationSlider.value = '0';
        updateDurationLabel();
        targetInput.value = '';
        reasonInput.value = '';

        panel.classList.remove('hidden');
        targetInput.focus();
    }

    if (event.data.action === 'closeJailUi') {
        panel.classList.add('hidden');
    }
});

durationSlider.addEventListener('input', updateDurationLabel);

document.getElementById('submit').addEventListener('click', async () => {
    const targetRaw = targetInput.value.trim();
    const targetId = targetRaw.split(/\s+/)[0];
    const durationIndex = Number(durationSlider.value) || 0;

    await post('submitJailForm', {
        targetId,
        targetName: targetRaw,
        cellId: Number(locationSelect.value),
        duration: durations[durationIndex].value,
        reason: reasonInput.value.trim()
    });
});

document.getElementById('cancel').addEventListener('click', async () => {
    await post('closeJailUi', {});
});

document.getElementById('xCancel').addEventListener('click', async () => {
    await post('closeJailUi', {});
});

document.addEventListener('keydown', async (e) => {
    if (e.key === 'Escape') {
        await post('closeJailUi', {});
    }
});