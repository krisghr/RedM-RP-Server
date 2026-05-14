const app = document.getElementById('app');
const title = document.getElementById('nameTitle');
const image = document.getElementById('charImage');
const ageLabel = document.getElementById('ageLabel');
const descView = document.getElementById('descView');
const setForm = document.getElementById('setForm');

const fields = {
  characterName: document.getElementById('characterName'),
  age: document.getElementById('age'),
  imageUrl: document.getElementById('imageUrl'),
  appearanceDescription: document.getElementById('appearanceDescription')
};

function close() {
  fetch(`https://${GetParentResourceName()}/close`, { method: 'POST', body: '{}' });
}

document.getElementById('closeBtn').addEventListener('click', close);

document.addEventListener('keydown', (e) => { if (e.key === 'Escape') close(); });

setForm.addEventListener('submit', (e) => {
  e.preventDefault();
  const payload = {
    characterName: fields.characterName.value,
    age: fields.age.value,
    imageUrl: fields.imageUrl.value,
    appearanceDescription: fields.appearanceDescription.value
  };

  fetch(`https://${GetParentResourceName()}/save`, { method: 'POST', body: JSON.stringify(payload) });
  close();
});

window.addEventListener('message', (event) => {
  const { action, mode, data } = event.data;
  if (action === 'close') {
    app.classList.add('hidden');
    return;
  }

  if (action !== 'open') return;

  app.classList.remove('hidden');
  title.textContent = data.characterName || 'Character';
  ageLabel.textContent = data.age || '-';
  image.src = data.imageUrl || 'https://via.placeholder.com/500x900?text=No+Image';
  descView.textContent = data.appearanceDescription || 'No description set.';

  const inSetMode = mode === 'set';
  setForm.classList.toggle('hidden', !inSetMode);
  descView.classList.toggle('hidden', inSetMode);

  if (inSetMode) {
    fields.characterName.value = data.characterName || '';
    fields.age.value = data.age || '';
    fields.imageUrl.value = data.imageUrl || '';
    fields.appearanceDescription.value = data.appearanceDescription || '';
  }
});
