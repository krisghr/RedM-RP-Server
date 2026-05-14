
data = {}
VorpCore = nil
VorpInv = nil
RSGCore = nil
qc = nil
QBRItems = nil
RSGItems = nil


----------------------------------------------------------------------------
--  bridge
----------------------------------------------------------------------------

if Config.Framework == "VORP" then 
    TriggerEvent("getCore",function(core)
        VorpCore = core
    end)
    VorpInv = exports.vorp_inventory:vorp_inventoryApi()
elseif Config.Framework == "RSG" then 
    qc = "rsg-core"
    RSGCore = exports[qc]:GetCoreObject()
    RSGItems = RSGCore.Shared.Items
elseif Config.Framework == "REDEMRP_2023" then 
    TriggerEvent("redemrp_inventory:getData",function(call)
        data = call
    end)
    RedEM = exports["redem_roleplay"]:RedEM()
elseif Config.Framework == "QBR" then 
   QBRItems = exports['qbr-core']:GetItems() 
end


----------------------------------------------------------------------------
--  function
----------------------------------------------------------------------------

function getJobInfo(src)
    local job = nil
    local grade = nil

    if Config.Framework == "VORP" then
        local Character = VorpCore.getUser(src).getUsedCharacter
        grade = Character.jobGrade
        job = Character.job
    elseif Config.Framework == "RSG" then 
        local Player = RSGCore.Functions.GetPlayer(src)
        job = Player.PlayerData.job.name
        grade = Player.PlayerData.job.grade.level
    elseif Config.Framework == "REDEMRP_2023" then 
        local player = RedEM.GetPlayer(src)
        job = player.job
        grade = player.jobgrade
    elseif Config.Framework == "QBR" then 
        local User = exports['qbr-core']:GetPlayer(src)
        job =  User.PlayerData.job.name
        grade = User.PlayerData.job.grade.level
    else
        job = OpenGetJob(src)
    end

    return {job = job, grade = grade}
end

function getItemLabel(src,item)
    local label = nil

    if Config.Framework == "VORP" then
        if VorpInv.getDBItem(src, item) then
           label = VorpInv.getDBItem(src, item).label
        end
    elseif Config.Framework == "RSG" then 
        if RSGItems[item] then
            label = RSGItems[item].label
        end
    elseif Config.Framework == "REDEMRP_2023" then 
        if data.getItemData(item) then
            label = data.getItemData(item).label
        end
    elseif Config.Framework == "QBR" then 
        if QBRItems[item] then
            label = QBRItems[item].label
        end
    else
        label = openGetItemLabel(src,item)
    end

    return label or item
end

function getMoneyAmount(_)
    local src = _
    local amount = nil
    
    if Config.Framework == "VORP" then
        local Character = VorpCore.getUser(src).getUsedCharacter
        amount = Character.money
    elseif Config.Framework == "RSG" then 
        local Player = RSGCore.Functions.GetPlayer(src)
        amount = Player.PlayerData.money.cash
    elseif Config.Framework == "REDEMRP_2023" then 
        local player = RedEM.GetPlayer(src)
        amount = player.money
    elseif Config.Framework == "QBR" then 
        local User = exports['qbr-core']:GetPlayer(src)
        amount = User.PlayerData.money.cash
    else
        amount = openGetMoneyAmount(src)
    end

    return amount
end


function removeMoney(_,amount)
    local src = _
    
    if Config.Framework == "VORP" then
        local Character = VorpCore.getUser(src).getUsedCharacter
        Character.removeCurrency(0 , tonumber(amount))
    elseif Config.Framework == "RSG" then 
        local Player = RSGCore.Functions.GetPlayer(src)
        Player.Functions.RemoveMoney('cash', amount)
    elseif Config.Framework == "REDEMRP_2023" then 
        local Player = RedEM.GetPlayer(src)
        Player.RemoveMoney(amount)
    elseif Config.Framework == "QBR" then 
        local User = exports['qbr-core']:GetPlayer(src)
        User.Functions.RemoveMoney("cash", amount, "Train script")
    else
        openRemoveMoney(src, amount)
    end
end

function addMoney(_,amount)
    local src = _

    if Config.Framework == "VORP" then
        local Character = VorpCore.getUser(src).getUsedCharacter
        Character.addCurrency(0 , tonumber(amount))
    elseif Config.Framework == "RSG" then    
        local Player = RSGCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney('cash', tonumber(amount))
    elseif Config.Framework == "REDEMRP_2023" then 
        local player = RedEM.GetPlayer(src)
        player.AddMoney(tonumber(amount))
    elseif Config.Framework == "QBR" then 
        local User = exports['qbr-core']:GetPlayer(src)
        User.Functions.AddMoney("cash", amount, "Train script")
    else
        OpenAddMoney(src, amount)
    end
end



function removeItem(src,name,amount)
    if Config.Framework == "VORP" then
        VorpInv.subItem(src,name, amount)
    elseif Config.Framework == "RSG" then 
        local Player = RSGCore.Functions.GetPlayer(src)
        Player.Functions.RemoveItem(name, amount)        
    elseif Config.Framework == "REDEMRP_2023" then 
        local player = RedEM.GetPlayer(src)
        local itemData = data.getItem(src, name)
        itemData.RemoveItem(amount)
    elseif Config.Framework == "QBR" then 
        local User = exports['qbr-core']:GetPlayer(src)
        User.Functions.RemoveItem(name,amount)
    else
        OpenRemoveItem(src,name,amount)
    end
end

function getPlayer(src)    
    local player = {}

    if Config.Framework == "VORP" then
        local data = VorpCore.getUser(src).getUsedCharacter       
        player = {firstname = data.firstname, lastname = data.lastname}
    elseif Config.Framework == "RSG" then 
        local data = RSGCore.Functions.GetPlayer(src).PlayerData.charinfo
        player = {firstname = data.firstname, lastname = data.lastname}
    elseif Config.Framework == "REDEMRP_2023" then 
        local data = RedEM.GetPlayer(src)
        player = {firstname = data.firstname, lastname = data.lastname}
    elseif Config.Framework == "QBR" then 
        local data = exports['qbr-core']:GetPlayer(src)
        player = {firstname =  data.PlayerData.charinfo.firstname, lastname = data.PlayerData.charinfo.lastname}
    else
        player = openGetPlayer(src)
    end

    if not player.firstname or not player.lastname then 
        player = {firstname = 'N/A', lastname = 'N/A'}
    end
    
    return player 
end

function getItemCount(src,name)
    local item = false

    if Config.Framework == "VORP" then
        local itemName = VorpInv.getItemCount(src, name)

        if not itemName then 
            item = 0
        else 
            item = itemName
        end 

    elseif Config.Framework == "RSG" then 

        local Player = RSGCore.Functions.GetPlayer(src)
        local itemName = Player.Functions.GetItemByName(name)
    
        if itemName == nil then 
            item = 0
        else 
            item = itemName.amount
        end 
                
    elseif Config.Framework == "REDEMRP_2023" then 
        local player = RedEM.GetPlayer(src)
        local itemName = data.getItem(src, name)

        if itemName == nil then 
            item = 0
        else 
            item = itemName.ItemAmount 
        end 

    elseif Config.Framework == "QBR" then 
        local User = exports['qbr-core']:GetPlayer(src)
        local itemName = User.Functions.GetItemByName(v.itemname)
        
        if itemName == nil then 
            item = 0
        else 
            item = itemName.amount
        end 

    else
        item = OpenGetItem(_,name)
    end
    
    return item
end
--------------------------------------------
-- Auto insert MySQL
--------------------------------------------

if Config.Server.AutoInsertSQL then
    MySQL.ready(function ()
        MySQL.Async.fetchScalar('SHOW TABLES LIKE ?', {'d_labs_trains_train'}, function(result)
            if result == nil then
                MySQL.Async.execute('CREATE TABLE `d_labs_trains_train` (' ..
                    '`id` int(11) NOT NULL AUTO_INCREMENT,' ..
                    '`idname` varchar(60) NOT NULL,' ..
                    '`label` varchar(50) NOT NULL,' ..
                    '`model` varchar(60) NOT NULL,' ..
                    '`hash` BIGINT UNSIGNED NOT NULL,' ..
                    '`status` varchar(60) NOT NULL,' ..
                    '`damage` int(11) NOT NULL,' ..
                    '`stash` varchar(50) NOT NULL,' ..
                    '`upgrade` varchar(50) NOT NULL,' ..
                    '`price` int(20) NOT NULL DEFAULT 0,' ..
                    '`coal` int(11) NOT NULL DEFAULT 0,' ..
                    'PRIMARY KEY (`id`)' ..
                    ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;', {}, function(rowsChanged)

                    printDebug('Table d_labs_trains_train has been created successfully.')
                end)
            else
                MySQL.Async.fetchScalar(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'd_labs_trains_train' AND COLUMN_NAME = 'coal'",
                    {},
                    function(hasCoal)
                        if tonumber(hasCoal or 0) == 0 then
                            MySQL.Async.execute(
                                'ALTER TABLE `d_labs_trains_train` ADD COLUMN `coal` INT(11) NOT NULL DEFAULT 0',
                                {},
                                function(_)
                                    printDebug("Column 'coal' added to d_labs_trains_train.")
                                end
                            )
                        end
                    end
                )
            end
        end)

        MySQL.Async.fetchScalar('SHOW TABLES LIKE ?', {'d_labs_train_timetable'}, function(result)
            if result == nil then
                MySQL.Async.execute('CREATE TABLE `d_labs_train_timetable` (' ..
                    '`id` int(11) NOT NULL AUTO_INCREMENT,' ..
                    '`board_name` varchar(255) NOT NULL,' ..
                    '`date` varchar(10) DEFAULT NULL,' .. 
                    '`time` varchar(255) DEFAULT NULL,' .. 
                    '`content` varchar(255) DEFAULT NULL,' ..
                    '`price` varchar(10) DEFAULT NULL,' .. 
                    'PRIMARY KEY (`id`)' ..
                    ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;', {}, function(rowsChanged)

                    printDebug('Table d_labs_train_timetable has been created successfully.')
                end)
            end
        end)

        MySQL.Async.fetchScalar('SHOW TABLES LIKE ?', {'d_labs_train_boss'}, function(result)
            if result == nil then
                MySQL.Async.execute('CREATE TABLE `d_labs_train_boss` (' ..
                    '`id` INT(11) NOT NULL AUTO_INCREMENT,' ..
                    '`money` DECIMAL(10,2) NOT NULL DEFAULT 0.0,' .. 
                    'PRIMARY KEY (`id`)' ..
                    ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;', {}, function(rowsChanged)
                                
                    Citizen.Wait(200)
                
                    MySQL.Async.execute('INSERT INTO `d_labs_train_boss` (`money`) VALUES (0.0);', {}, function(insertRowsChanged)
                    end)

                    printDebug('Table d_labs_train_boss has been created successfully.')
                end)
            end
        end)
        
        
    end)

    Citizen.Wait(300)
end

MySQL.Async.execute("UPDATE d_labs_trains_train SET status = 'onTow' WHERE status = 'inWorld'", {}, function(affectedRows)
    if affectedRows and affectedRows > 0 then
        printDebug("Vehicle status updated to 'inTow' for all vehicles currently 'inWorld'")
    else
        printDebug("No vehicle status was updated.")
    end
end)

--------------------------------------------
-- Logs
--------------------------------------------

local colorLog = {
    ['blue'] = 3447003,
    ['green'] = 5763719,
    ['red'] = 15548997,
    ['orange'] = 15105570,
}

function sendLog(color, title, logData, src)
    if Config.Server.logs then
        local playerName = getPlayer(src)
        local licenseID = nil
        local license2ID = nil
        local rockstarID = nil

        for i = 0, GetNumPlayerIdentifiers(src) - 1 do
            local identifier = GetPlayerIdentifier(src, i)
            if string.find(identifier, "license:") then
                if not licenseID then
                    licenseID = identifier
                else
                    license2ID = identifier
                end
            elseif string.find(identifier, "fivem:") then
                rockstarID = identifier
            end
        end

        local playerPed = GetPlayerPed(src)
        local playerCoords = GetEntityCoords(playerPed) 
        local posX, posY, posZ = table.unpack(playerCoords)

        local descriptionScriptData = "\n**INFO**\n"
        for k, v in pairs(logData) do
            descriptionScriptData = descriptionScriptData .. string.format("%-20s : %s\n", '**'..k..'**', v)
        end

        local descriptionUserData = "\n**USER DATA**\n"
        descriptionUserData = descriptionUserData .. string.format("%-20s : %s\n", '**Name**', GetPlayerName(src))
        descriptionUserData = descriptionUserData .. string.format("%-20s : %s\n", '**Char Name**', playerName.firstname..' '..playerName.lastname)
        
        if licenseID then
            descriptionUserData = descriptionUserData .. string.format("%-20s : %s\n", '**License ID**', licenseID)
        end
        if license2ID then
            descriptionUserData = descriptionUserData .. string.format("%-20s : %s\n", '**License2 ID**', license2ID)
        end
        if rockstarID then
            descriptionUserData = descriptionUserData .. string.format("%-20s : %s\n", '**Rockstar ID**', rockstarID)
        end

        descriptionUserData = descriptionUserData .. string.format("%-20s : %.2f, %.2f, %.2f\n", '**Coords**', posX, posY, posZ)

        local description = descriptionScriptData .. descriptionUserData
        local embed = {
            {
                ["color"] = colorLog[color],
                ["title"] = '**' .. title .. '**',
                ["description"] = description,
                ["footer"] = {
                    ["text"] = "by D-Labs ("..GetCurrentResourceName()..')',
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
            }
        }

        local payload = json.encode({embeds = embed})
        local headers = { ['Content-Type'] = 'application/json' }
        local webhooks = type(Config.Server.logs) == 'table' and Config.Server.logs or { Config.Server.logs }

        for _, url in ipairs(webhooks) do
            if type(url) == 'string' and url ~= '' then
                PerformHttpRequest(url, function(err, text, resHeaders) end, 'POST', payload, headers)
            end
        end
    end
end


RegisterServerEvent(GetCurrentResourceName()..':sendLog')
AddEventHandler(GetCurrentResourceName()..':sendLog', function(color, title, logData)
    local src = source
    sendLog(color, title, logData, src)
end)


-- server

-- local logData = {
--     ["Train ID"] = idname,
-- }
-- sendLog('green', texts.log.tow, logData, src)

-- client 

-- local logData = {
--     ["Train ID"] = idname,
-- }
-- TriggerServerEvent(GetCurrentResourceName()..':sendLog','green', texts.log.tow, logData)