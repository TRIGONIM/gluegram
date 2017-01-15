TLG = TLG or {}

local fol = "gluegram"

includeSV(fol .. "/dependencies/sv.lua")

includeSV(fol .. "/config.lua")
if SERVER then includeSV(fol .. "/languages/" .. TLG.Cfg.LangCode .. ".lua") end
includeSV(fol .. "/sv_methods.lua")
includeSV(fol .. "/sv_core.lua")
includeSV(fol .. "/sv_processor.lua")
includeSV(fol .. "/sv_commandprocessor.lua")
includeSV(fol .. "/sv_commands.lua")
includeSV(fol .. "/sv_groups.lua")

includeSH(fol .. "/sh_datatypesprocessors.lua")

for _,f in pairs(file.Find(fol .. "/objects/*","LUA")) do
	includeSV(fol .. "/objects/" .. f)
end

LoadModules(fol .. "/modules","TELEGRAM BOT")

hook.Call("onGluegramLoaded")
