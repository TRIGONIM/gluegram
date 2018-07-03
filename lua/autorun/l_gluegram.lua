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


TLG.Include("dependencies.lua")

TLG.Include("core.lua")

TLG.LoadFolder("objects")
TLG.LoadFolder("objects/custom")

TLG.LoadFolder("methods")
TLG.LoadFolder("methods/objects")

TLG.LoadFolder("modules")

LoadModules("gluegram/bots")
