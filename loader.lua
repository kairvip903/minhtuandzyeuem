local env = (getgenv and getgenv()) or _G
local RAW = "https://raw.githubusercontent.com/kairvip903/minhtuandzyeuem/refs/heads/main/"
local FILES = {free = "tuandz3639_yeube", premium = "tuandz3639_premium"}
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

if env.LH_LoaderBusy then return end
env.LH_LoaderBusy = true
local key = tostring(script_key or env.script_key or ""):gsub("%s", "")
local plan = "free"
if key ~= "" then
	local d, why = checkKey(key)
	if not d then
		env.LH_LoaderBusy = nil
		notify("Lucious Hub", why)
		return
	end
	plan = d.plan == "premium" and "premium" or "free"
	d._at = os.clock()
	env.LH_Key, env.LH_KeyInfo = key, d
	pcall(function()
		if makefolder and isfolder and not isfolder("LuciousHub") then makefolder("LuciousHub") end
		writefile("LuciousHub/key.txt", key)
	end)
end
notify("Lucious Hub", "Loading " .. (plan == "premium" and "Premium" or "Free") .. "...")
local ok, src = pcall(game.HttpGet, game, RAW .. FILES[plan])
env.LH_LoaderBusy = nil
if not ok or type(src) ~= "string" or #src < 100 then
	notify("Lucious Hub", "Could not download the " .. plan .. " script")
	return
end
local fn, err = loadstring(src)
if not fn then
	notify("Lucious Hub", "Script error: " .. tostring(err))
	return
end
fn()
