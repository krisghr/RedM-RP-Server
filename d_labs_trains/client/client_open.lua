function openCustomNotif(t1, t2, dict, txtr, timer)
	print('Custom notif active' .. t1, t2, dict, txtr, timer)
end

-- stashInfo = { maxweight = number, slots = number }  (table from Config.Train[x].stash or Config.Upgrade[x].stash)
function openStashCustom(stashId,stashInfo)
	local slots = stashInfo.slots or 100
	local maxweight = stashInfo.maxweight or 100000
	print('openStashOpenCustom',stashId,slots,maxweight)

	-- put the call to your inventory system here, e.g. v-inventory:
	-- TriggerServerEvent('v-inventory:server:RegisterStash', stashId, slots, maxweight)
	-- Citizen.Wait(200)
	-- TriggerEvent('v-inventory:client:OpenInventory', 'stash', stashId)
end

local Targets = {'ox_target'}

local function targetResource()
	if Config.Server.MetaTarget ~= true then return nil end
	for _, name in ipairs(Targets) do
		if GetResourceState(name) == 'started' then
			return name
		end
	end
	return nil
end

function openTargetAddCoords(name, coords, radius, options)
	local res = targetResource()
	if not res then return end

	radius = radius or 1.5

	if res == 'ox_target' then
		local opts = {}
		for i, o in ipairs(options) do
			opts[i] = {
				name = name .. "_" .. i,
				label = o.label,
				icon = o.icon,
				distance = o.distance or 2.5,
				canInteract = o.canInteract,
				onSelect = o.action,
			}
		end
		exports.ox_target:addSphereZone({
			coords = vector3(coords.x, coords.y, coords.z),
			radius = radius,
			debug = false,
			name = name,
			options = opts,
		})
	end
end

function openTargetAddEntity(name, entity, options)
	local res = targetResource()
	if not res then return end

	if res == 'ox_target' then
		local opts = {}
		for i, o in ipairs(options) do
			opts[i] = {
				name = name .. "_" .. i,
				label = o.label,
				icon = o.icon,
				distance = o.distance or 2.5,
				canInteract = o.canInteract,
				onSelect = o.action,
			}
		end
		exports.ox_target:addLocalEntity(entity, opts)
	end
end

function openTargetRemove(name)
	local res = targetResource()
	if not res then return end

	if res == 'ox_target' then
		exports.ox_target:removeZone(name)
	end
end

function openTargetRemoveEntity(entity)
	local res = targetResource()
	if not res then return end

	if res == 'ox_target' then
		exports.ox_target:removeLocalEntity(entity)
	end
end
