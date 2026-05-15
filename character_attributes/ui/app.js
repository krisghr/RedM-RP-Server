const app = document.getElementById('app');
const title = document.getElementById('nameTitle');
const image = document.getElementById('charImage');
const ageLabel = document.getElementById('ageLabel');
const descView = document.getElementById('descView');
const setForm = document.getElementById('setForm');

const descriptorEls = {
  height: document.getElementById('heightValue'),
  build: document.getElementById('buildValue'),
  eyes: document.getElementById('eyesValue'),
  hair: document.getElementById('hairValue'),
  complexion: document.getElementById('complexionValue'),
  facialHair: document.getElementById('facialHairValue'),
  marks: document.getElementById('marksValue')
};

const fields = {
  age: document.getElementById('age'),
  imageUrl: document.getElementById('imageUrl'),
  height: document.getElementById('height'),
  build: document.getElementById('build'),
  eyes: document.getElementById('eyes'),
  hair: document.getElementById('hair'),
  complexion: document.getElementById('complexion'),
  facialHair: document.getElementById('facialHair'),
  marks: document.getElementById('marks'),
  appearanceDescription: document.getElementById('appearanceDescription')
};

function close() {
  fetch(`https://${GetParentResourceName()}/close`, { method: 'POST', body: '{}' });
}

document.getElementById('closeBtn').addEventListener('click', close);
document.getElementById('viewCloseBtn').addEventListener('click', close);
document.addEventListener('keydown', (e) => { if (e.key === 'Escape') close(); });

function packAppearance() {
  const meta = {
    height: fields.height.value,
    build: fields.build.value,
    eyes: fields.eyes.value,
    hair: fields.hair.value,
    complexion: fields.complexion.value,
    facialHair: fields.facialHair.value,
    marks: fields.marks.value,
    description: fields.appearanceDescription.value
  };

  return `[attrs]${JSON.stringify(meta)}[/attrs]`;
}

function unpackAppearance(raw) {
  const str = raw || '';
  const match = str.match(/^\[attrs\](.*)\[\/attrs\]$/s);
  if (!match) return { description: str };
  try {
    return JSON.parse(match[1]);
  } catch {
    return { description: str };
  }
}

setForm.addEventListener('submit', (e) => {
  e.preventDefault();
  const payload = {
    characterName: title.textContent || 'Character',
    age: fields.age.value,
    imageUrl: fields.imageUrl.value,
    appearanceDescription: packAppearance()
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

  const parsed = unpackAppearance(data.appearanceDescription);

  title.textContent = data.characterName || 'Character';
  ageLabel.textContent = data.age || '-';
  image.src = data.imageUrl || 'https://via.placeholder.com/500x900?text=No+Image';
  descView.textContent = parsed.description || 'No description set.';

  descriptorEls.height.textContent = parsed.height || '-';
  descriptorEls.build.textContent = parsed.build || '-';
  descriptorEls.eyes.textContent = parsed.eyes || '-';
  descriptorEls.hair.textContent = parsed.hair || '-';
  descriptorEls.complexion.textContent = parsed.complexion || '-';
  descriptorEls.facialHair.textContent = parsed.facialHair || '-';
  descriptorEls.marks.textContent = parsed.marks || '-';

  const inSetMode = mode === 'set';
  setForm.classList.toggle('hidden', !inSetMode);
  document.getElementById('viewCloseBtn').classList.toggle('hidden', inSetMode);

  if (inSetMode) {
    fields.age.value = data.age || '';
    fields.imageUrl.value = data.imageUrl || '';
    fields.height.value = parsed.height || '';
    fields.build.value = parsed.build || '';
    fields.eyes.value = parsed.eyes || '';
    fields.hair.value = parsed.hair || '';
    fields.complexion.value = parsed.complexion || '';
    fields.facialHair.value = parsed.facialHair || '';
    fields.marks.value = parsed.marks || '';
    fields.appearanceDescription.value = parsed.description || '';
  }
});
