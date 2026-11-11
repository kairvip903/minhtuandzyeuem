local env = (getgenv and getgenv()) or _G
local RAW = "https://raw.githubusercontent.com/kairvip903/minhtuandzyeuem/refs/heads/main/"
local FILE = "tuandz3639_yeube"
local API = "https://api.github.com/repos/kairvip903/minhtuandzyeuem/commits?path=" .. FILE .. "&per_page=1"
local CACHE, VER = "LuciousHub/build.lua", "LuciousHub/build.sha"
local DB_URL = "https://kggjpyyaeknodmfveeaq.supabase.co/rest/v1/rpc/lh_check_key"
local DB_KEY = "sb_publishable_Nc047R_WKcU2OobUUSE3bA_koga4ANo"

local function notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = 8})
	end)
	warn("[Lucious] " .. title .. ": " .. text)
end

local function checkKey(key)
	local HS = game:GetService("HttpService")
	local req = (syn and syn.request) or http_request or request or (http and http.request) or (fluxus and fluxus.request)
	if not req then return nil, "Executor has no HTTP request" end
	local LP = game:GetService("Players").LocalPlayer
	local hw = "N/A"
	pcall(function() hw = tostring(game:GetService("RbxAnalyticsService"):GetClientId()) end)
	local dv = "Executor"
	pcall(function() local n = (identifyexecutor or getexecutorname)() if n then dv = tostring(n) end end)
	pcall(function()
		local U = game:GetService("UserInputService")
		dv = dv .. " • " .. ((U.TouchEnabled and not U.KeyboardEnabled) and "Mobile" or "PC")
	end)
	local function call(args)
		return pcall(req, {Url = DB_URL, Method = "POST", Headers = {apikey = DB_KEY, ["Content-Type"] = "application/json"},
			Body = HS:JSONEncode(args)})
	end
	local ok, res = call({p_key = key, p_hwid = hw, p_user = LP and LP.Name or nil, p_device = dv})
	if ok and res and (res.StatusCode or res.status_code) == 404 then
		ok, res = call({p_key = key, p_hwid = hw, p_user = LP and LP.Name or nil})
	end
	local okj, d = pcall(HS.JSONDecode, HS, ok and res and (res.Body or res.body) or "")
	if not okj or type(d) ~= "table" then return nil, "Key server unreachable, try again" end
	if d.ok ~= true then
		if d.error == "expired" then return nil, "Key expired, get a new one" end
		return nil, tostring(d.msg or d.message or "Invalid key")
	end
	return d
end

local function latestSha()
	local req = (syn and syn.request) or http_request or request or (http and http.request) or (fluxus and fluxus.request)
	if not req then return nil end
	local ok, res = pcall(req, {Url = API, Method = "GET", Headers = {["User-Agent"] = "LuciousLoader", Accept = "application/vnd.github+json"}})
	local body = ok and res and (res.Body or res.body)
	local okj, d = pcall(function() return game:GetService("HttpService"):JSONDecode(body or "") end)
	return okj and type(d) == "table" and type(d[1]) == "table" and type(d[1].sha) == "string" and d[1].sha or nil
end
local function readCache()
	local ok, src = pcall(function() return isfile(CACHE) and readfile(CACHE) or nil end)
	return ok and type(src) == "string" and #src > 100 and src or nil
end

if env.LH_LoaderBusy then return end
env.LH_LoaderBusy = true
notify("Lucious Hub", "Starting...")
local t0 = os.clock()
local key = tostring(script_key or env.script_key or ""):gsub("%s", "")
local keyDone, keyInfo, keyWhy = key == "", nil, nil
if key ~= "" then
	task.spawn(function()
		keyInfo, keyWhy = checkKey(key)
		keyDone = true
	end)
end
local sha = latestSha()
local src, from
pcall(function()
	if sha and isfile(VER) and readfile(VER) == sha then
		src = readCache()
		from = src and "cache"
	end
end)
if not src then
	local ok, body = pcall(game.HttpGet, game, RAW .. FILE)
	if ok and type(body) == "string" and #body > 100 then
		src, from = body, "download"
		pcall(function()
			if makefolder and isfolder and not isfolder("LuciousHub") then makefolder("LuciousHub") end
			writefile(CACHE, body)
			writefile(VER, sha or "")
		end)
	else
		src = readCache()
		from = src and "old cache"
	end
end
local tGet = os.clock() - t0
while not keyDone do task.wait() end
env.LH_LoaderBusy = nil
if key ~= "" and not keyInfo then
	notify("Lucious Hub", keyWhy or "Invalid key")
	return
end
if not src then
	notify("Lucious Hub", "Could not download the script")
	return
end
local plan = "Free"
if keyInfo then
	plan = keyInfo.plan == "premium" and "Premium" or "Free"
	keyInfo._at = os.clock()
	env.LH_Key, env.LH_KeyInfo = key, keyInfo
	pcall(function()
		if makefolder and isfolder and not isfolder("LuciousHub") then makefolder("LuciousHub") end
		writefile("LuciousHub/key.txt", key)
	end)
end
notify("Lucious Hub", ("Loading %s... (%s %.1fs)"):format(plan, from, tGet))
task.wait()
local t1 = os.clock()
local fn, err = loadstring(src)
if not fn then
	notify("Lucious Hub", "Script error: " .. tostring(err))
	return
end
local tLoad = os.clock() - t1
env.LH_LoadTimes = {get = tGet, from = from, compile = tLoad}
warn(("[Lucious] %s %.1fs • compile %.1fs"):format(from, tGet, tLoad))
fn()
