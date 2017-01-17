TLG = TLG or {}

local fol = "gluegram"

includeSV(fol .. "/dependencies/sv.lua")

includeSV(fol .. "/config.lua")

-- if SERVER нужен, чтобы не было ошибки на клиенте. TLG.CFG = nil
if SERVER then includeSV(fol .. "/languages/" .. TLG.CFG.LangCode .. ".lua") end

for _,f in pairs(file.Find(fol .. "/objects/*","LUA")) do
	includeSV(fol .. "/objects/" .. f)
end
includeSV(fol .. "/objects/custom/bot.lua")
includeSV(fol .. "/objects/custom/command.lua")

includeSV(fol .. "/sv_methods.lua")
includeSV(fol .. "/sv_core.lua")
includeSV(fol .. "/sv_processor.lua")
includeSV(fol .. "/sv_commands.lua")
includeSV(fol .. "/sv_groups.lua")

LoadModules(fol .. "/modules","TELEGRAM BOT")
LoadModules(fol .. "/bots")

hook.Call("onGluegramLoaded")
