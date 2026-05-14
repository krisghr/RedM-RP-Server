const state = {
    texts:          null,
    yersText:       null,
    hudConfig:      null,
    dateFmt:        { order: 'MM-DD', yearPosition: 'after' },
    currency:       '$',

    currentMode:       'read',
    currentBoardName:  '',
    currentTitle:      '',
    boardData:         [],
    currentEditIndex:  null,
    canEdit:           false,

};


const $ = (id) => document.getElementById(id);

const dom = {
    boardContainer:    $('boardContainer'),
    boardTitle:        $('boardTitle'),
    boardTable:          $('boardTable'),
    boardTableContainer: $('boardTableContainer'),
    boardBody:           $('boardBody'),
    emptyWatermark:    $('emptyWatermark'),
    editContainer:     $('editContainer'),
    closeButton:       $('closeButton'),
    addRowButton:      $('addRowButton'),
    editModeToggle:    $('editModeToggle'),

    editFormOverlay:   $('editFormOverlay'),
    closeEditButton:   $('closeEditButton'),
    editMonth:         $('editMonth'),
    editDay:           $('editDay'),
    dateSelects:       $('dateSelects'),
    editTime:          $('editTime'),
    editContent:       $('editContent'),
    editPrice:         $('editPrice'),
    repeatTime:        $('repeatTime'),
    repeatLabel:       $('repeatLabel'),
    saveButton:        $('saveButton'),

    hudOld:            $('hud-old'),
    tachometer:        $('tachometer'),
    needle:            document.querySelector('.needle'),
    pressureHudBar:    $('pressureHudBar'),
    coalBar:           $('coalBar'),
    coalHudBar:        $('coalHudBar'),
    coalHudGlow:       $('coalHudGlow'),
    coalHudText:       $('coalHudText'),
    textAboveNeedle:   $('textAboveNeedle'),

    nuiWrapper:        $('nui-wrapper'),
    trainName:         $('train-name'),
    trainPrice:        $('train-price'),
    trainSpeed:        $('train-speed'),
    trainStash:        $('train-stash'),
    trainSize:         $('train-size'),
    trainId:           $('train-id'),
    leftArrow:         $('left-arrow'),
    rightArrow:        $('right-arrow'),
    buyButton:         $('buy-button'),
    cameraButton:      $('camera-button'),
    exitButton:        $('exit-button'),

    inputContainer:    $('nui-input-container'),
    textInput:         $('nui-textInput'),
    sendButton:        $('nui-sendButton'),
    inputCloseButton:  $('nui-closeButton'),

    switchHud:         $('switch-hud'),
    switchLeftDest:    $('switch-left-dest'),
    switchRightDest:   $('switch-right-dest'),
    switchBtnLeft:     $('switch-btn-left'),
    switchBtnRight:    $('switch-btn-right'),
    switchCounters:    document.querySelectorAll('.switch-counter'),
};

function flashSwitchConfirm(side) {
    const btn = side === 'left' ? dom.switchBtnLeft : dom.switchBtnRight;
    if (!btn) return;
    btn.classList.remove('is-confirmed');
    void btn.offsetWidth;
    btn.classList.add('is-confirmed');
    setTimeout(() => btn.classList.remove('is-confirmed'), 750);
}

function setSwitchProgress(side, progress) {
    const btn = side === 'left' ? dom.switchBtnLeft : dom.switchBtnRight;
    if (!btn) return;
    btn.style.setProperty('--progress', Math.max(0, Math.min(progress, 1)));
}


function show(el)  { el && el.classList.remove('is-hidden'); }
function hide(el)  { el && el.classList.add('is-hidden');    }
function setDisplay(el, value) { if (el) el.style.display = value; }

function fetchNui(endpoint, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body:    JSON.stringify(data),
    })
    .then(r => r.json())
    .then(resp => {
        if (resp && resp.action) buyMenu(resp);
        return resp;
    })
    .catch(() => null);
}

function getCurrentDate() {
    const today = new Date();
    const mm = String(today.getMonth() + 1).padStart(2, '0');
    const dd = String(today.getDate()).padStart(2, '0');
    return `${mm}-${dd}`;
}

function populateDateSelects() {
    const pad = n => String(n).padStart(2, '0');
    const months = Array.from({ length: 12 }, (_, i) => pad(i + 1));
    const days   = Array.from({ length: 31 }, (_, i) => pad(i + 1));
    months.forEach(m => dom.editMonth.insertAdjacentHTML('beforeend', `<option value="${m}">${m}</option>`));
    days  .forEach(d => dom.editDay  .insertAdjacentHTML('beforeend', `<option value="${d}">${d}</option>`));
}
populateDateSelects();

function splitMmdd(mmdd) {
    if (!mmdd || mmdd === false || typeof mmdd !== 'string' || mmdd.length < 5) return ['', ''];
    return [mmdd.slice(0, 2), mmdd.slice(3, 5)];
}

function formatDisplayDate(mmdd) {
    const [mm, dd] = splitMmdd(mmdd);
    if (!mm || !dd) return '';
    const order = state.dateFmt.order === 'DD-MM' ? `${dd}-${mm}` : `${mm}-${dd}`;
    const year  = state.yersText || '';
    if (!year) return order;
    return state.dateFmt.yearPosition === 'before' ? `${year} ${order}` : `${order} ${year}`;
}

function applyDateFormatToForm() {
    if (!dom.dateSelects || !dom.editMonth || !dom.editDay) return;
    const first  = state.dateFmt.order === 'DD-MM' ? dom.editDay   : dom.editMonth;
    const second = state.dateFmt.order === 'DD-MM' ? dom.editMonth : dom.editDay;
    dom.dateSelects.insertBefore(first,  dom.dateSelects.firstChild);
    dom.dateSelects.insertBefore(second, first.nextSibling);
    const yearEl = document.getElementById('dateYear');
    if (yearEl) {
        if (state.dateFmt.yearPosition === 'before') dom.dateSelects.insertBefore(yearEl, dom.dateSelects.firstChild);
        else dom.dateSelects.appendChild(yearEl);
    }
}


function translatePage() {
    const t = state.texts.nui;

    dom.emptyWatermark.innerText = t.emptyWatermark;

    const headers = dom.boardTable.querySelectorAll('thead th');
    headers[0].innerText = t.date;
    headers[1].innerText = t.time;
    headers[2].innerText = t.content;
    headers[3].innerText = t.price;

    dom.addRowButton.innerText = t.addRow;

    const q = (sel) => document.querySelector(sel);
    const set = (sel, value) => { const el = q(sel); if (el && value != null) el.innerText = value; };

    set('#editForm h3', t.editRow);
    set('#dateLabel', t.date);
    set("#editForm label[for='editTime']",    t.time);
    set("#editForm label[for='editContent']", t.content);
    set("#editForm label[for='editPrice']",   t.price);

    if (dom.editContent) dom.editContent.placeholder = t.placeholderContent || '';
    if (dom.editPrice)   dom.editPrice.placeholder   = t.placeholderPrice   || '';
    if (dom.saveButton)  dom.saveButton.innerText    = t.save;
    if (dom.repeatLabel) dom.repeatLabel.innerText   = t.repeatDaily;

    const yearEl = document.getElementById('dateYear');
    if (yearEl) yearEl.innerText = state.yersText || '';

    const setLabel = (li, text) => {
        if (!li) return;
        const lbl = li.querySelector('label');
        if (lbl && text != null) lbl.innerText = `${text}:`;
    };
    setLabel(dom.trainPrice, t.trainPrice);
    setLabel(dom.trainSpeed, t.trainSpeed);
    setLabel(dom.trainStash, t.trainStash);
    setLabel(dom.trainSize,  t.trainSize);

    dom.buyButton.innerText = t.buyButton;

    dom.sendButton.innerText = t.sendButton;
}


const HUD_POSITIONS = {
    'bottom-middle': { bottom:'2%', left:'50%',                transform: s => `translateX(-50%) scale(${s})`,   margins:['Bottom'] },
    'bottom-left':   { bottom:'5%', left:'5%',                 transform: s => `translate(-5%, -5%) scale(${s})`, margins:['Left','Bottom'] },
    'bottom-right':  { bottom:'4%', right:'2%',                transform: s => `translate(5%, 5%) scale(${s})`,   margins:['Bottom','Right'] },
    'middle-right':  { top:'50%',   right:'2%',                transform: s => `translateY(-50%) scale(${s})`,    margins:['Right'] },
    'top-right':     { top:'2%',    right:'2%',                transform: s => `translate(0%, 5%) scale(${s})`,   margins:['Top','Right'] },
    'top-middle':    { top:'2%',    left:'50%',                transform: s => `translateX(-50%) scale(${s})`,    margins:['Top'] },
    'top-left':      { top:'2%',    left:'2%',                 transform: s => `translate(0%, 5%) scale(${s})`,   margins:['Top','Left'] },
    'left-middle':   { top:'50%',   left:'2%',                 transform: s => `translateY(-50%) scale(${s})`,    margins:['Left'] },
};

function editHUD() {
    const cfg = state.hudConfig;
    const el  = dom.tachometer;
    if (!cfg || !el) return;

    dom.hudOld.classList.toggle('hud-wildwest', cfg.new === true);

    const scale       = cfg.trainHudScale / 100;
    const defaultSize = 360;
    const marginPx    = -((defaultSize - defaultSize * scale) / 2);

    el.style.opacity = cfg.opacity;

    ['top', 'bottom', 'left', 'right', 'transform', 'margin'].forEach(k => el.style[k] = '');

    const pos = HUD_POSITIONS[cfg.trainHUDposition] || HUD_POSITIONS['bottom-middle'];

    if (pos.top    !== undefined) el.style.top    = pos.top;
    if (pos.bottom !== undefined) el.style.bottom = pos.bottom;
    if (pos.left   !== undefined) el.style.left   = pos.left;
    if (pos.right  !== undefined) el.style.right  = pos.right;
    el.style.transform = pos.transform(scale);

    pos.margins.forEach(side => { el.style[`margin${side}`] = `${marginPx}px`; });
}


const NEEDLE = { min: -120, max: 120, maxSpeed: 120 };
let needleState = {
    current: -120,
    target:  0,
    rafId:   null,
};

function updateShowUI(payload) {
    if (!payload) return;
    smoothUpdateSpeed(payload.speed);
    updatePressureBar(payload.pressure);
    updateTextAboveNeedle(payload.text);
    updateCoalBar(payload.coal, payload.coalMax);
}

function updateCoalBar(coal, coalMax) {
    const bar = dom.coalBar;
    if (!bar) return;
    const max = Math.max(1, Number(coalMax) || 0);
    const cur = Math.max(0, Math.min(Number(coal) || 0, max));
    const ratio = cur / max;

    bar.style.setProperty('--coal-progress', ratio.toFixed(4));

    // colour shifts from amber → orange → red as the tank empties
    let color;
    if (ratio > 0.5)      color = '#ffb845';
    else if (ratio > 0.2) color = '#ff7a1f';
    else                  color = '#ff3a1a';
    bar.style.setProperty('--coal-color', color);

    bar.classList.toggle('is-low',   ratio > 0 && ratio <= 0.2);
    bar.classList.toggle('is-empty', ratio <= 0);
}

function showTachometerCustom(speed, pressure, text) {
    updateShowUI({ speed, pressure, text });
}

function smoothUpdateSpeed(targetSpeed) {
    const clamped = Math.min(Math.max(targetSpeed, 0), NEEDLE.maxSpeed);
    needleState.target = NEEDLE.min + (clamped / NEEDLE.maxSpeed) * (NEEDLE.max - NEEDLE.min);
    if (needleState.rafId === null) animateNeedle();
}

function animateNeedle() {
    const ease = 0.1;
    const diff = needleState.target - needleState.current;
    needleState.current += diff * ease;

    dom.needle.style.transform = `rotate(${needleState.current}deg)`;

    if (Math.abs(diff) > 0.1) {
        needleState.rafId = requestAnimationFrame(animateNeedle);
    } else {
        needleState.current = needleState.target;
        dom.needle.style.transform = `rotate(${needleState.current}deg)`;
        needleState.rafId = null;
    }
}

function updatePressureBar(pressure) {
    const bar = dom.pressureHudBar;
    const p   = Math.min(pressure, 200);

    const t = Math.min(p / 100, 1);
    const GRAY = 150, RED_R = 235, RED_G = 30, RED_B = 30;
    const r = Math.round(GRAY + (RED_R - GRAY) * t);
    const g = Math.round(GRAY + (RED_G - GRAY) * t);
    const b = Math.round(GRAY + (RED_B - GRAY) * t);
    const color = `rgb(${r}, ${g}, ${b})`;
    bar.style.backgroundColor = color;

    dom.hudOld.style.setProperty('--liquid-color', color);
    dom.hudOld.style.setProperty('--pressure', Math.min(p / 100, 1.3).toFixed(2));

    const isPulsing = pressure > 100;
    if (isPulsing) {
        const s = Math.min((pressure - 100) / 100, 1) * 20;
        bar.style.boxShadow =
            `0 0 ${s * 2}px ${s}px rgba(255, 0, 0, 0.3), ` +
            `0 0 ${s * 4}px ${s * 2}px rgba(255, 0, 0, 0.2), ` +
            `0 0 ${s * 6}px ${s * 4}px rgba(255, 0, 0, 0.1)`;
        bar.classList.add('pulse');
    } else {
        bar.style.boxShadow = 'none';
        bar.classList.remove('pulse');
    }
    if (dom.tachometer) dom.tachometer.classList.toggle('is-pulsing', isPulsing);
}

function updateTextAboveNeedle(text) {
    dom.textAboveNeedle.innerText = text;
}


function openBoard(data) {
    state.currentMode      = 'read';
    state.canEdit          = !!data.canEdit;
    state.currentTitle     = data.title;
    state.currentBoardName = data.title;

    if (state.canEdit) {
        dom.editModeToggle.style.display = 'inline-block';
        dom.editModeToggle.classList.remove('active');
        const t = state.texts && state.texts.nui;
        dom.editModeToggle.innerText = (t && t.editMode) ? t.editMode : 'Edit';
    } else {
        dom.editModeToggle.style.display = 'none';
    }

    if (data.data && data.data.length > 0) {
        state.boardData = data.data.map(row => ({
            ...row,
            date: row.date === false ? getCurrentDate() : row.date,
        }));
        dom.emptyWatermark.style.display = 'none';
    } else {
        state.boardData = [];
        dom.emptyWatermark.style.display = 'block';
    }

    renderTable(state.currentTitle, state.boardData);
}

function renderTable(title, data) {
    dom.boardTitle.innerText = title;

    const t = (state.texts && state.texts.nui) || {
        date: 'Date', time: 'Time', content: 'Content', price: 'Price', actions: 'Actions',
    };
    const isEdit = state.currentMode === 'edit';

    const header = `
        <tr>
            <th>${t.date}</th>
            <th>${t.time}</th>
            <th>${t.content}</th>
            <th>${t.price}</th>
        </tr>`;

    let body = '';
    data.forEach((row, index) => {
        const rawDate  = (row.date === false || row.date === '0') ? getCurrentDate() : row.date;
        const dateCell = formatDisplayDate(rawDate);

        const pending = !row.id;
        const disabled = pending ? 'disabled' : '';
        const actions = isEdit ? `
            <span class="row-actions">
                <button class="row-action" data-action="edit"   data-index="${index}" ${disabled} title="Edit">
                    <svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
                </button>
                <button class="row-action row-action--danger" data-action="delete" data-index="${index}" ${disabled} title="Delete">
                    <svg viewBox="0 0 24 24"><path d="M6 19a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>
                </button>
            </span>` : '';

        body += `<tr id="row-${index}" class="${pending ? 'row-pending' : ''}">
            <td><span>${dateCell}</span></td>
            <td><span>${row.time}</span></td>
            <td><span>${row.content}</span></td>
            <td class="price-cell"><span>${row.price}${state.currency}</span>${actions}</td>
        </tr>`;
    });

    if (isEdit) {
        body += `<tr class="add-row"><td colspan="4">
            <button class="table-add-button" data-action="add" title="Add">+</button>
        </td></tr>`;
    }

    dom.emptyWatermark.style.display = data.length > 0 ? 'none' : 'block';

    dom.boardBody.innerHTML = body;
    dom.boardTable.querySelector('thead').innerHTML = header;

    dom.boardContainer.style.display = 'block';
    dom.editContainer.style.display  = 'none';

    const hasRows = data.length > 0 || isEdit;
    dom.boardTableContainer.style.overflowY = hasRows ? 'auto' : 'hidden';
}

let tempRowCounter = 0;
function makeTempId() { return `tmp_${Date.now()}_${++tempRowCounter}`; }

function rowAdd(row) {
    const tempId = makeTempId();
    row._tempId = tempId;
    fetch(`https://${GetParentResourceName()}/timetableAdd`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body:    JSON.stringify({
            boardName: state.currentBoardName,
            tempId:    tempId,
            row: {
                date:    row.date,
                time:    row.time,
                content: row.content,
                price:   row.price,
            },
        }),
    }).catch(() => null);
}

function rowUpdate(row) {
    if (!row || !row.id) return;
    fetch(`https://${GetParentResourceName()}/timetableUpdate`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body:    JSON.stringify({
            id: row.id,
            row: {
                date:    row.date,
                time:    row.time,
                content: row.content,
                price:   row.price,
            },
        }),
    }).catch(() => null);
}

function rowDelete(id) {
    if (!id) return;
    fetch(`https://${GetParentResourceName()}/timetableDelete`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body:    JSON.stringify({ id }),
    }).catch(() => null);
}

function applyRowAdded(payload) {
    if (!payload) return;
    const row = state.boardData.find(r => r._tempId === payload.tempId);
    if (!row) return;
    row.id = payload.id;
    delete row._tempId;
    renderTable(state.currentTitle, state.boardData);
}

function closeBoard() {
    fetchNui('closeBoard').then(() => {
        dom.boardContainer.style.display = 'none';
    });
}

function deleteRow(index) {
    const row = state.boardData[index];
    if (!row) return;
    if (!row.id) return;
    rowDelete(row.id);
    state.boardData.splice(index, 1);
    renderTable(state.currentTitle, state.boardData);
}


function openEditForm(index = null) {
    state.currentEditIndex = index;

    if (index !== null) {
        const row = state.boardData[index];
        const [mm, dd] = splitMmdd(row.date === false ? '' : row.date);
        dom.editMonth.value   = mm;
        dom.editDay.value     = dd;
        dom.editTime.value    = row.time    || '';
        dom.editContent.value = row.content || '';
        dom.editPrice.value   = row.price   || '';
        dom.repeatTime.checked = row.date === false;
    } else {
        dom.editMonth.value   = '';
        dom.editDay.value     = '';
        dom.editTime.value    = '';
        dom.editContent.value = '';
        dom.editPrice.value   = '';
        dom.repeatTime.checked = false;
    }

    toggleDateInput();
    dom.editFormOverlay.style.display = 'flex';
}

function cancelEdit() {
    dom.editFormOverlay.style.display = 'none';
}

function toggleDateInput() {
    const checked = dom.repeatTime.checked;
    if (checked) {
        dom.editMonth.value = '';
        dom.editDay.value   = '';
    }
    dom.dateSelects.style.display = checked ? 'none' : 'flex';
    validateForm();
}

function isFormValid() {
    const month   = dom.editMonth.value;
    const day     = dom.editDay.value;
    const time    = dom.editTime.value;
    const content = dom.editContent.value;
    const price   = dom.editPrice.value;
    const repeat  = dom.repeatTime.checked;

    if (!repeat && (month === '' || day === '')) return false;
    if (time === '' || content === '' || price === '') return false;
    return true;
}

function validateForm() {
    dom.saveButton.classList.toggle('active', isFormValid());
}

function validateAndSave() {
    if (!dom.saveButton.classList.contains('active')) return;
    if (!isFormValid()) {
        alert('Please fill out all fields.');
        return;
    }

    const repeat = dom.repeatTime.checked;
    const entry = {
        date:    repeat ? false : `${dom.editMonth.value}-${dom.editDay.value}`,
        time:    dom.editTime.value,
        content: dom.editContent.value,
        price:   dom.editPrice.value,
    };

    if (state.currentEditIndex === null) {
        state.boardData.push(entry);
        rowAdd(entry);
    } else {
        const existing = state.boardData[state.currentEditIndex];
        if (!existing || !existing.id) return;
        Object.assign(existing, entry);
        rowUpdate(existing);
    }

    dom.editFormOverlay.style.display = 'none';
    renderTable(state.currentTitle, state.boardData);
}


function buyMenu(data) {
    switch (data.action) {
        case 'display':
            if (data.show) showNUI(); else hideNUI();
            updateTrainInfo(data);
            break;
        case 'updateTrainInfo':
            updateTrainInfo(data);
            break;
        default:
            console.error('Received unknown action:', data.action);
    }
}

function updateTrainInfo(data) {
    dom.trainName.textContent                        = data.name  || 'Neznámý';
    dom.trainPrice.querySelector('span').textContent = `${data.price || 0}${state.currency}`;
    dom.trainSpeed.querySelector('span').textContent = data.speed || 0;
    dom.trainStash.querySelector('span').textContent = data.stash || 0;
    dom.trainSize.querySelector('span').textContent  = data.size  || 0;
    dom.trainId.value                                = data.id    || '';
}

function showNUI() {
    dom.nuiWrapper.style.display = 'block';
    dom.nuiWrapper.classList.add('visibleSlideRight');
    dom.nuiWrapper.addEventListener('animationend', () => {
        dom.nuiWrapper.classList.remove('visibleSlideRight');
    }, { once: true });
}

function hideNUI() {
    dom.nuiWrapper.classList.add('hiddenSlideRight');
    dom.nuiWrapper.addEventListener('animationend', () => {
        dom.nuiWrapper.style.display = 'none';
        dom.nuiWrapper.classList.remove('hiddenSlideRight');
    }, { once: true });
}

function debounceButton(button, callback, cooldown = 1000) {
    let locked = false;
    button.addEventListener('click', () => {
        if (locked) return;
        locked = true;
        callback();
        button.disabled = true;
        setTimeout(() => {
            locked = false;
            button.disabled = false;
        }, cooldown);
    });
}

function collectTrainData() {
    return {
        name:  dom.trainName.textContent,
        price: dom.trainPrice.querySelector('span').textContent,
        speed: dom.trainSpeed.querySelector('span').textContent,
        stash: dom.trainStash.querySelector('span').textContent,
        size:  dom.trainSize.querySelector('span').textContent,
        id:    dom.trainId.value,
    };
}


function openInputPrompt(placeholder) {
    dom.inputContainer.style.display = 'block';
    dom.textInput.value = '';
    dom.textInput.placeholder = placeholder || 'Insert Text';
}

function submitInputPrompt() {
    fetchNui('sendText', { text: dom.textInput.value });
    dom.inputContainer.style.display = 'none';
}

function closeInputPrompt() {
    dom.inputContainer.style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeNUI`, { method: 'POST' });
}


window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'texts_send') {
        state.texts     = data.text;
        state.yersText  = data.inform;
        state.hudConfig = data.hud;
        if (data.dateFmt) state.dateFmt = {
            order:        data.dateFmt.order        || 'MM-DD',
            yearPosition: data.dateFmt.yearPosition || 'after',
        };
        if (data.currency) state.currency = data.currency;
        translatePage();
        applyDateFormatToForm();
        if (dom.editPrice) dom.editPrice.placeholder = state.currency;
        editHUD();

        if (dom.boardContainer.style.display === 'block') {
            renderTable(state.currentTitle, state.boardData);
        }
        return;
    }

    if (data.action === 'input') {
        openInputPrompt(data.placeholderText);
        return;
    }

    if (data.buy) {
        buyMenu(data);
        return;
    }

    if (data.showNUI) {
        dom.hudOld.style.display = 'block';
        updateShowUI(data.showNUI);
        return;
    }

    if (data.showNUI === false) {
        dom.hudOld.style.display = 'none';
        return;
    }

    if (data.action === 'switch_toggle') {
        if (data.left  != null) dom.switchLeftDest.innerText  = data.left;
        if (data.right != null) dom.switchRightDest.innerText = data.right;
        dom.switchHud.style.display = data.show ? 'flex' : 'none';
        return;
    }

    if (data.action === 'switch_progress') {
        setSwitchProgress(data.side, data.progress);
        return;
    }

    if (data.action === 'switch_confirm') {
        flashSwitchConfirm(data.side);
        return;
    }

    if (data.action === 'switch_counter') {
        const visible = data.total > 1;
        const text = visible ? `${data.index}/${data.total}` : '';
        dom.switchCounters.forEach(el => {
            el.innerText = text;
            el.style.display = visible ? 'inline-block' : 'none';
        });
        return;
    }

    if (data.action === 'open_board') {
        openBoard(data);
        return;
    }

    if (data.action === 'row_added') {
        applyRowAdded(data.data);
        return;
    }
});


dom.closeButton    .addEventListener('click', closeBoard);
dom.addRowButton   .addEventListener('click', () => openEditForm());
dom.editModeToggle .addEventListener('click', toggleEditMode);

function toggleEditMode() {
    if (!state.canEdit) return;
    state.currentMode = (state.currentMode === 'edit') ? 'read' : 'edit';
    const active = state.currentMode === 'edit';
    dom.editModeToggle.classList.toggle('active', active);
    const t = state.texts && state.texts.nui;
    dom.editModeToggle.innerText = active
        ? ((t && t.viewMode) ? t.viewMode : 'View')
        : ((t && t.editMode) ? t.editMode : 'Edit');
    renderTable(state.currentTitle, state.boardData);
}

dom.boardBody.addEventListener('click', (e) => {
    const btn = e.target.closest('.row-action, .table-add-button');
    if (!btn || btn.disabled) return;
    if (btn.dataset.action === 'add') { openEditForm(); return; }
    const index = parseInt(btn.dataset.index, 10);
    if      (btn.dataset.action === 'edit')   openEditForm(index);
    else if (btn.dataset.action === 'delete') deleteRow(index);
});

dom.closeEditButton.addEventListener('click', cancelEdit);
dom.saveButton     .addEventListener('click', validateAndSave);
dom.repeatTime     .addEventListener('click', toggleDateInput);

[dom.editTime, dom.editContent, dom.editPrice]
    .forEach(el => el.addEventListener('input', validateForm));
[dom.editMonth, dom.editDay]
    .forEach(el => el.addEventListener('change', validateForm));

debounceButton(dom.leftArrow,  () => fetchNui('left'));
debounceButton(dom.rightArrow, () => fetchNui('right'));

dom.exitButton  .addEventListener('click', () => { hideNUI(); fetchNui('exit'); });
dom.cameraButton.addEventListener('click', () => fetchNui('camera'));
dom.buyButton   .addEventListener('click', () => { fetchNui('buy', collectTrainData()); hideNUI(); });

dom.sendButton      .addEventListener('click', submitInputPrompt);
dom.inputCloseButton.addEventListener('click', closeInputPrompt);
