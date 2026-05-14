local SERVER = IsDuplicityVersion()
local CLIENT = not IsDuplicityVersion()

Config.Framework = false
local manually = false
local findFramework = false

MenuSystem = nil

if Config.Server.CustomFramework == true or Config.Server.CustomFramework == false then
	if GetResourceState('rsg-core') == 'started' then
		Config.Framework = 'RSG'
		findFramework = true
	elseif GetResourceState('vorp_core') == 'started' then
		Config.Framework = 'VORP'
		findFramework = true
	elseif GetResourceState('redem_roleplay') == 'started' then
		Config.Framework = 'REDEMRP_2023'
		findFramework = true
	elseif GetResourceState('qbr-core') == 'started' then
		Config.Framework = 'QBR'
		findFramework = true
	end
elseif Config.Server.CustomFramework == true then
	Config.Framework = 'custom'
else 
	manually = true
	Config.Framework = Config.Server.CustomFramework
	printInfo('Framework','set manually to ' .. Config.Framework)
end

if SERVER then
	if Config.Framework ~= false and Config.Framework ~= 'custom' and not manually and not findFramework then
		printInfo('Framework','not found')
	elseif Config.Framework == 'custom' then
		printInfo('Framework','set to custom')
	elseif not manually then
		printInfo('Framework','Found ' .. Config.Framework)
	end
end

if GetResourceState('vorp_menu') == 'started' then
    MenuSystem = 'vorp'
elseif GetResourceState('rsg-menubase') == 'started' then
    MenuSystem = 'rsg'
else
    MenuSystem = 'redem'
end

if SERVER then
	if MenuSystem then
		printInfo('MENU', MenuSystem)
	else
		print('^1[MENU BRIDGE] No supported menu found^0')
	end
end


if SERVER then
	local resourceName   = GetCurrentResourceName() or "unknown"
	local currentVersion = GetResourceMetadata(resourceName, "version", 0)

	local fileName       = ("%s.md"):format(resourceName)
	local url            = ("https://raw.githubusercontent.com/RealDubi/d_labs_api_version/main/version/%s"):format(fileName)

	local colors = {
		green     = "^2",
		red       = "^1",
		cyan      = "^5",  
		reset     = "^0"
	}

	local function printUpdateInfo(latest)
		print(colors.cyan .. "┌───────────────────────────────────────────────────────────────────┐" .. colors.reset)
		print("")

		local resName = resourceName:gsub("^%s*(.-)%s*$", "%1")
		print(colors.cyan .. " Resource: " .. colors.reset .. resName)

		print("")
		print(colors.cyan .. " Update found: " .. colors.green .. "v" .. latest .. colors.reset)
		print(colors.cyan .. " Your Version: " .. colors.red .. "v" .. currentVersion .. colors.reset)
		print("")
		print(colors.cyan .. " Download: " .. colors.reset .. "https://portal.cfx.re/assets/granted-assets")
		print(colors.cyan .. " Details:  " .. colors.reset .. "https://www.d-labs.site")
		print(colors.cyan .. " Support:  " .. colors.reset .. "https://discord.gg/zKBgmBPmyd")
		print("")
		print(colors.cyan .. "└───────────────────────────── D-Labs ──────────────────────────────┘" .. colors.reset)
	end

	local function printUpToDate()
		print(colors.green ..
			("[D-LABS] %s v%s is up to date."):format(resourceName, currentVersion) ..
			colors.reset
		)
	end

	local function compareVersions(a, b)
		local aParts, bParts = {}, {}
		for num in a:gmatch("%d+") do table.insert(aParts, tonumber(num)) end
		for num in b:gmatch("%d+") do table.insert(bParts, tonumber(num)) end
		local len = math.max(#aParts, #bParts)
		for i = 1, len do
			local av, bv = aParts[i] or 0, bParts[i] or 0
			if av < bv then return -1 end
			if av > bv then return 1 end
		end
		return 0
	end

	local function firstNonEmptyTrimmedLine(text)
		for line in text:gmatch("[^\r\n]+") do
			local s = line
				:gsub("^%s*#+%s*", "")
				:gsub("^%s*[vV]%s*", "")
				:gsub("%s+$", "")
				:gsub("^%s+", "")
			if s ~= "" then return s end
		end
		return nil
	end

	local function checkVersion()
		if not currentVersion or currentVersion == "" then
			print(colors.red ..
				"[D-LABS] Unable to determine current version from fxmanifest.lua" ..
				colors.reset
			)
			return
		end

		PerformHttpRequest(url, function(status, body)
			if status == 200 and body and body ~= "" then
				local latest = firstNonEmptyTrimmedLine(body)
				if latest and latest ~= "" then
					latest = latest:gsub("%s+", "")

					local cmp = compareVersions(currentVersion, latest)
					if cmp == 0 or cmp == 1 then
						printUpToDate()
					else
						printUpdateInfo(latest)
					end
				else
					print(colors.red .. "[D-LABS] Unable to read latest version." .. colors.reset)
				end
			else
				print(colors.red ..
					("[D-LABS] HTTP error while fetching version (status %s)"):format(tostring(status)) ..
					colors.reset
				)
			end
		end, "GET")
	end

	CreateThread(function()
		Wait(800)
		checkVersion()
	end)
end
