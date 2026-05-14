local isOpen = false
local requestCounter = 0
local pendingRequests = {}

local function isSafeUrl(url)
    if type(url) ~= 'string' then return false end
    if #url < 12 or #url > 2048 then return false end
    if not url:match('^https?://') then return false end
    if url:find('[\r\n]') then return false end
    return true
end

local function closePopup()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openResolved(finalUrl, title)
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', title = title or 'Image Preview', url = finalUrl })
end

local function showImage(url, title)
    if not isSafeUrl(url) then
        return false, 'Invalid image URL. Use an http(s) direct image or supported host link.'
    end

    -- Show original URL immediately (restores old Discord behavior).
    openResolved(url, title or 'Image Preview')

    -- Resolve in background for hosted page links (imgur/imgbb etc.) and swap if needed.
    requestCounter = requestCounter + 1
    local requestId = requestCounter
    pendingRequests[requestId] = { sourceUrl = url, title = title or 'Image Preview' }
    TriggerServerEvent('image_popup:resolveUrl', requestId, url)

    return true
end

RegisterNetEvent('image_popup:resolvedUrl', function(requestId, finalUrl)
    local pending = pendingRequests[requestId]
    if not pending then return end
    pendingRequests[requestId] = nil

    if not isSafeUrl(finalUrl) then
        -- Keep original image displayed; resolution is optional enhancement.
        return
    end

    if finalUrl ~= pending.sourceUrl then
        openResolved(finalUrl, pending.title)
    end
end)

-- Public API for dependency use
exports('ShowImage', function(url, title)
    return showImage(url, title)
end)

exports('HideImage', function()
    if isOpen then
        closePopup()
        return true
    end

    return false
end)

RegisterNetEvent('image_popup:show', function(url, title)
    local ok, err = showImage(url, title)
    if not ok and err then
        TriggerEvent('chat:addMessage', {
            color = { 255, 80, 80 },
            args = { ('^1%s'):format(err) }
        })
    end
end)

RegisterNetEvent('image_popup:hide', function()
    if isOpen then closePopup() end
end)

-- Debug/testing commands
RegisterCommand('showimg', function(_, args)
    local url = args[1]
    local title = table.concat(args, ' ', 2)

    if not url then
        TriggerEvent('chat:addMessage', {
            color = { 255, 200, 80 },
            args = { '^3Usage:^7 /showimg <http(s)://image-or-host-link> [title]' }
        })
        return
    end

    local ok, err = showImage(url, title ~= '' and title or nil)
    if not ok and err then
        TriggerEvent('chat:addMessage', {
            color = { 255, 80, 80 },
            args = { ('^1%s'):format(err) }
        })
    end
end, false)

RegisterCommand('hideimg', function()
    if isOpen then closePopup() end
end, false)

RegisterNUICallback('close', function(_, cb)
    closePopup()
    cb({ ok = true })
end)
