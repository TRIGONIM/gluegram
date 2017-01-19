TLG = TLG or {}

local fol = "gluegram"

includeSV(fol .. "/dependencies/sv.lua")

includeSV(fol .. "/config.lua")

for _,f in pairs(file.Find(fol .. "/objects/*","LUA")) do
	includeSV(fol .. "/objects/" .. f)
end
includeSV(fol .. "/objects/custom/bot.lua")
includeSV(fol .. "/objects/custom/command.lua")

includeSV(fol .. "/sv_methods.lua")
includeSV(fol .. "/sv_core.lua")
includeSV(fol .. "/sv_groups.lua")

for _,f in pairs(file.Find(fol .. "/methods/*","LUA")) do
	includeSV(fol .. "/methods/" .. f)
end

LoadModules(fol .. "/bots")
LoadModules(fol .. "/modules","TELEGRAM BOT")

hook.Call("onGluegramLoaded")
