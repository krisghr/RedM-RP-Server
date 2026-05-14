local CACHE_TTL_MS = 10 * 60 * 1000
local urlCache = {}

local function nowMs()
    return GetGameTimer()
end

local function getCached(url)
    local hit = urlCache[url]
    if not hit then return nil end
    if hit.expiresAt <= nowMs() then
        urlCache[url] = nil
        return nil
    end
    return hit.value
end

local function setCached(url, value)
    urlCache[url] = {
        value = value,
        expiresAt = nowMs() + CACHE_TTL_MS
    }
end

local function htmlEntityDecode(s)
    if type(s) ~= 'string' then return s end
    s = s:gsub('&amp;', '&')
    s = s:gsub('&quot;', '"')
    s = s:gsub('&#39;', "'")
    s = s:gsub('&lt;', '<')
    s = s:gsub('&gt;', '>')
    return s
end

local function tryExtractOgImage(body)
    if type(body) ~= 'string' then return nil end

    local patterns = {
        '<meta%s+property=["\']og:image["\']%s+content=["\']([^"\']+)["\']',
        '<meta%s+content=["\']([^"\']+)["\']%s+property=["\']og:image["\']',
        '<meta%s+name=["\']twitter:image["\']%s+content=["\']([^"\']+)["\']',
    }

    for _, p in ipairs(patterns) do
        local hit = body:match(p)
        if hit and hit:match('^https?://') then
            return htmlEntityDecode(hit)
        end
    end

    return nil
end

local function isDirectImageLike(url)
    if type(url) ~= 'string' then return false end
    if url:match('%.jpe?g([%?&#].*)?$') or url:match('%.png([%?&#].*)?$') or url:match('%.webp([%?&#].*)?$') or url:match('%.gif([%?&#].*)?$') or url:match('%.bmp([%?&#].*)?$') then
        return true
    end

    if url:match('^https?://cdn%.discordapp%.com/attachments/') or url:match('^https?://media%.discordapp%.net/attachments/') then
        return true
    end

    return false
end

local function resolveImgur(url)
    local id = url:match('^https?://imgur%.com/([%w]+)$') or url:match('^https?://m%.imgur%.com/([%w]+)$')
    if id then
        return ('https://i.imgur.com/%s.jpg'):format(id)
    end

    local albumId = url:match('^https?://imgur%.com/a/([%w]+)')
    if albumId then
        return nil
    end

    return nil
end

RegisterNetEvent('image_popup:resolveUrl', function(requestId, inputUrl)
    local src = source
    if type(requestId) ~= 'number' or type(inputUrl) ~= 'string' then
        TriggerClientEvent('image_popup:resolvedUrl', src, requestId, inputUrl)
        return
    end

    local cached = getCached(inputUrl)
    if cached then
        TriggerClientEvent('image_popup:resolvedUrl', src, requestId, cached)
        return
    end

    local resolved = resolveImgur(inputUrl) or inputUrl

    if isDirectImageLike(resolved) then
        setCached(inputUrl, resolved)
        TriggerClientEvent('image_popup:resolvedUrl', src, requestId, resolved)
        return
    end

    PerformHttpRequest(resolved, function(statusCode, body)
        local finalUrl = resolved

        if statusCode and statusCode >= 200 and statusCode < 400 and type(body) == 'string' then
            if body:find('<html', 1, true) or body:find('<meta', 1, true) then
                local og = tryExtractOgImage(body)
                if og then finalUrl = og end
            end
        end

        setCached(inputUrl, finalUrl)
        TriggerClientEvent('image_popup:resolvedUrl', src, requestId, finalUrl)
    end, 'GET', '', {
        ['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36',
        ['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    })
end)
