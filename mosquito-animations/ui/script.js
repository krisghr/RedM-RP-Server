var currentInteractions = 0;
var selectedIndex = 0;
var maxItems = 50;

function sendMessage(name, data) {
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
}

function setSelected() {
    var interactions = document.querySelectorAll('#interaction-picker-list .interaction');

    for (var i = 0; i < interactions.length; ++i) {
        if (i == selectedIndex) {
            interactions[i].className = 'interaction selected';
            // Scroll the selected item into view instantly
            interactions[i].scrollIntoView({ behavior: 'auto', block: 'nearest' });
        } else {
            interactions[i].className = 'interaction';
        }
    }

    var interaction = interactions[selectedIndex];

    if (interaction.hasAttribute('data-object')) {
        var entity = parseInt(interaction.getAttribute('data-object'));

        sendMessage('setInteractionMarker', {
            entity: entity
        });
    } else {
        var x = parseFloat(interaction.getAttribute('data-x'));
        var y = parseFloat(interaction.getAttribute('data-y'));
        var z = parseFloat(interaction.getAttribute('data-z'));

        sendMessage('setInteractionMarker', {
            x: x,
            y: y,
            z: z
        });
    }
}

function startInteraction() {
    var interaction = document.querySelectorAll('#interaction-picker-list .interaction')[selectedIndex];

    if (interaction.hasAttribute('data-cancel')) {
        sendMessage('stopInteraction', {});
    } else {
        if (interaction.hasAttribute('data-scenario')) {
            sendMessage('startInteraction', {
                x: parseFloat(interaction.getAttribute('data-x')),
                y: parseFloat(interaction.getAttribute('data-y')),
                z: parseFloat(interaction.getAttribute('data-z')),
                heading: parseFloat(interaction.getAttribute('data-heading')),
                scenario: interaction.getAttribute('data-scenario'),
                object: parseInt(interaction.getAttribute('data-object')),
                effect: interaction.getAttribute('data-effect')
            });
        } else {
            sendMessage('startInteraction', {
                x: parseFloat(interaction.getAttribute('data-x')),
                y: parseFloat(interaction.getAttribute('data-y')),
                z: parseFloat(interaction.getAttribute('data-z')),
                heading: parseFloat(interaction.getAttribute('data-heading')),
                animation: {
                    dict: interaction.getAttribute('data-animation-dict'),
                    name: interaction.getAttribute('data-animation-name')
                },
                object: parseInt(interaction.getAttribute('data-object')),
                effect: interaction.getAttribute('data-effect')
            });
        }
    }

    hideInteractionPicker();
}

function showInteractionPicker(data) {
    var interactions = JSON.parse(data.interactions);

    var list = document.querySelector('#interaction-picker-list');

    list.innerHTML = '';

    var max = interactions.length > maxItems ? maxItems : interactions.length;

    for (var i = 0; i < max; ++i) {
        var interaction = interactions[i];

        var div = document.createElement('div');
        div.className = 'interaction';

        // Custom scenario name mapping
        let scenarioDisplayName;

        if (interaction.label) {
            scenarioDisplayName = interaction.title;
        } else {
            scenarioDisplayName = interaction.scenario;
        }

        if (interaction.label) {
            if (interaction.modelName) {
                if (interaction.scenario === "PROP_HUMAN_SLEEP_BED_PILLOW" ||
                    interaction.scenario === "PROP_HUMAN_SLEEP_BED_PILLOW_HIGH" ||
                    interaction.scenario === "WORLD_HUMAN_SLEEP_GROUND_ARM" ||
                    interaction.scenario === "WORLD_HUMAN_SLEEP_GROUND_PILLOW" ||
                    interaction.scenario === "WORLD_HUMAN_SIT_FALL_ASLEEP" ||
                    interaction.scenario === "WORLD_PLAYER_SLEEP_BEDROLL"
                ) {
                    div.innerHTML = '<span style="color: powderblue;">Bed </span>' + scenarioDisplayName + ' [' + interaction.label + ']';
                } else {
                    div.innerHTML = '<span style="color: powderblue;">Bench </span>' + scenarioDisplayName + ' [' + `<span style="color: lemonchiffon;">${interaction.label}</span>` + ']';
                }
            } else {
                div.innerHTML = scenarioDisplayName + ' [' + interaction.label + ']';
            }
        } else {
            if (interaction.modelName) {
                if (interaction.scenario === "PROP_HUMAN_SLEEP_BED_PILLOW" ||
                    interaction.scenario === "PROP_HUMAN_SLEEP_BED_PILLOW_HIGH" ||
                    interaction.scenario === "WORLD_HUMAN_SLEEP_GROUND_ARM" ||
                    interaction.scenario === "WORLD_HUMAN_SLEEP_GROUND_PILLOW" ||
                    interaction.scenario === "WORLD_HUMAN_SIT_FALL_ASLEEP" ||
                    interaction.scenario === "WORLD_PLAYER_SLEEP_BEDROLL"
                ) {

                    div.innerHTML = '<span style="color: powderblue;">Bed </span>' + interaction.title;
                } else if (scenarioDisplayName === "Playing Piano") {
                    div.innerHTML = '<span style="color: powderblue;">Piano </span>' + interaction.title;
                } else {
                    div.innerHTML = '<span style="color: powderblue;">Seat </span>' + interaction.title;
                }
            } else {
                if (interaction.modelName) {
                    div.innerHTML = '<span style="color: powderblue;">Bath </span>' + interaction.animation.label;
                } else {
                    div.innerHTML = '<span style="color: powderblue;">Bath </span>' + interaction.animation.label;
                }
            }
        }

        div.setAttribute('data-x', interaction.x);
        div.setAttribute('data-y', interaction.y);
        div.setAttribute('data-z', interaction.z);
        div.setAttribute('data-heading', interaction.heading);

        if (interaction.scenario) {
            div.setAttribute('data-scenario', interaction.scenario);
        } else {
            div.setAttribute('data-animation-dict', interaction.animation.dict);
            div.setAttribute('data-animation-name', interaction.animation.name);
        }

        if (interaction.object) {
            div.setAttribute('data-object', interaction.object);
        }

        if (interaction.effect) {
            div.setAttribute('data-effect', interaction.effect);
        }

        list.appendChild(div);
    }

    var div = document.createElement('div');
    div.className = 'interaction';
    div.innerHTML = '<div class="end-interaction"><span>End Interaction</span></div>';
    div.setAttribute('data-cancel', '');
    list.appendChild(div);

    currentInteractions = max + 1;
    selectedIndex = 0;
    setSelected();

    document.querySelector('#interaction-picker').style.display = 'block';
}

function hideInteractionPicker() {
    document.querySelector('#interaction-picker').style.display = 'none';
}

function moveSelectionDown() {
    selectedIndex = (selectedIndex + 1) % currentInteractions;
    setSelected();
}

function moveSelectionUp() {
    selectedIndex = ((selectedIndex - 1) + currentInteractions) % currentInteractions;
    setSelected();
}

window.addEventListener('message', function (event) {
    switch (event.data.type) {
        case 'showInteractionPicker':
            showInteractionPicker(event.data);
            break;
        case 'hideInteractionPicker':
            hideInteractionPicker(event.data);
            break;
        case 'moveSelectionUp':
            moveSelectionUp();
            break;
        case 'moveSelectionDown':
            moveSelectionDown();
            break;
        case 'startInteraction':
            startInteraction();
            break;
    }
});
