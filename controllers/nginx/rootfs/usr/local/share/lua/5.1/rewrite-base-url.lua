local socketUrl = require "socket.url"
local gumbo = require "gumbo"
local rex = require "rex_pcre" 
local slash = "/"

local function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local atomsToAttrs = {
    ["a"] = Set{"href",},
    ["applet"] = Set{"codebase",},
    ["area"] = Set{"href",},
    ["audio"] = Set{"src",},
    ["base"] = Set{"href",},
    ["blockquote"] = Set{"cite",},
    ["body"] = Set{"background",},
    ["button"] = Set{"formaction",},
    ["command"] = Set{"icon",},
    ["del"] = Set{"cite",},
    ["embed"] = Set{"src",},
    ["form"] = Set{"action",},
    ["frame"] = Set{"longdesc", "src",},
    ["head"] = Set{"profile",},
    ["html"] = Set{"manifest",},
    ["iframe"] = Set{"longdesc", "src",},
    ["img"] = Set{"longdesc", "src", "usemap",},
    ["input"] = Set{"src", "usemap", "formaction",},
    ["ins"] = Set{"cite",},
    ["link"] = Set{"href",},
    ["object"] = Set{"classid", "codebase", "data", "usemap",},
    ["q"] = Set{"cite",},
    ["script"] = Set{"src",},
    ["source"] = Set{"src",},
    ["video"] = Set{"poster", "src",},
}

local function rewriteURL(url, origBasePath, newBasePath, hostname, rewriteExcludePattern)
    assert(type(url) == "string", "url expects a string") 
    assert(type(origBasePath) == "string", "origBasePath expects a atring")
    assert(type(newBasePath) == "string", "newBasePath expects a atring")
    assert(type(hostname) == "string", "hostname expects a atring")
    assert(type(rewriteExcludePattern) == "string", "rewriteExcludePattern expects a atring")
    if not url then
        return ""
    end

    --make sure complete match
    if rewriteExcludePattern ~= nil and rewriteExcludePattern ~= "" and rex.match(url, "(" .. rewriteExcludePattern .. ")") == url then
        return url
    end

    local parsed_url = socketUrl.parse(url)
    local isHostDifferent = parsed_url.host and parsed_url.host ~= hostname
    local isRelative = (not parsed_url.host and not parsed_url.path) or (parsed_url.path and string.sub(parsed_url.path,1,string.len(slash)) ~= slash)
    if isHostDifferent or isRelative then
        return url
    end

    if not parsed_url.path then
        parsed_url.path = slash
    end

    if origBasePath ~= slash and string.sub(origBasePath,1,string.len(slash)) ~= slash then
        origBasePath = slash .. origBasePath
    end
    if origBasePath ~= slash and string.sub(origBasePath,-string.len(slash)) ~= slash then
        origBasePath = origBasePath .. slash
    end
    if newBasePath ~= slash and string.sub(newBasePath,1,string.len(slash)) ~= slash then
        newBasePath = slash .. newBasePath
    end
    if newBasePath ~= slash and string.sub(newBasePath,-string.len(slash)) ~= slash then
        newBasePath = newBasePath .. slash
    end

    if string.sub(parsed_url.path,1,string.len(origBasePath)) == (origBasePath) then
        parsed_url.path = newBasePath .. string.sub(parsed_url.path,string.len(origBasePath)+1)
    end
    if parsed_url.path .. slash == origBasePath then
        if newBasePath == slash then
            parsed_url.path = slash
        else
            parsed_url.path = string.sub(newBasePath, 1, -string.len(slash))
        end
    end

    return socketUrl.build(parsed_url)
end

local function rewriteHTML(html, origBasePath, newBasePath, hostname, rewriteExcludePattern)
    assert(type(html) == "string", "html expects a string")
    assert(type(origBasePath) == "string", "origBasePath expects a atring")
    assert(type(newBasePath) == "string", "newBasePath expects a atring")
    assert(type(hostname) == "string", "hostname expects a atring")
    assert(type(rewriteExcludePattern) == "string", "rewriteExcludePattern expects a atring")
    local document = gumbo.parse(html)
    local root = document.documentElement
    if root then
        for node in root:walk() do
            if node.type == "element" and atomsToAttrs[node.localName] then
                if node.attributes then
                    for key, value in pairs(node.attributes) do
                        if atomsToAttrs[node.localName][key] then
                            node:setAttribute(key, rewriteURL(node:getAttribute(key), origBasePath, newBasePath, hostname, rewriteExcludePattern))
                        end
                    end
                end
            end
        end
    end
    return document:serialize()
end

return {
    rewriteURL = rewriteURL,
    rewriteHTML = rewriteHTML
}
