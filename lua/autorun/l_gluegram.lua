-- Рефрешить МОЖНО
TLG = TLG or {}

function TLG.Include(path)
	includeSV("gluegram/" .. path)
end

function TLG.LoadFolder(path)
	for _,f in pairs(file.Find("gluegram/" .. path .. "/*","LUA")) do
		TLG.Include(path .. "/" .. f)
	end
end

local include   = TLG.Include
local addFolder = TLG.LoadFolder

include("dependencies/sv.lua")
include("config.lua")

addFolder("objects")
include("objects/custom/command.lua")
include("objects/custom/bot.lua")

include("sv_methods.lua")
include("gluegram_core.lua")

addFolder("methods")
addFolder("listeners")

LoadModules("gluegram/bots")

hook.Call("onGluegramLoaded")
