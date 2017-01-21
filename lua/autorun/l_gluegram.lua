TLG = TLG or {}

local function include(path)
	includeSV("gluegram/" .. path)
end

local function addFolder(path)
	for _,f in pairs(file.Find("gluegram/" .. path .. "/*","LUA")) do
		include(path .. "/" .. f)
	end
end



include("dependencies/sv.lua")
include("config.lua")

addFolder("objects")
include("objects/custom/listener.lua")
include("objects/custom/command.lua")
include("objects/custom/bot.lua")

include("sv_methods.lua")
include("gluegram_core.lua")

addFolder("methods")
addFolder("listeners")

LoadModules("gluegram/bots")
LoadModules("gluegram/modules","TELEGRAM BOT")

hook.Call("onGluegramLoaded")
