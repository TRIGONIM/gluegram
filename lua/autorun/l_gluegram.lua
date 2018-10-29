-- Рефрешить МОЖНО
TLG = TLG or {}

if CLIENT then return end

function TLG.Include(path)
	include("gluegram/" .. path)
end

function TLG.LoadFolder(path, iDeep, fFilter) -- recoursive deeping
	iDeep = iDeep or 0
	-- print("path", path)

	local files,dirs = file.Find("gluegram/" .. path .. "/*","LUA")
	for _,f in ipairs(files) do
		-- print("f", iDeep, f)
		if not fFilter or fFilter(f) then
			TLG.Include(path .. "/" .. f)
		end
	end

	for _,d in ipairs(iDeep > 0 and dirs or {}) do
		-- print("d", iDeep, d)
		TLG.LoadFolder(path .. "/" .. d, iDeep - 1, fFilter)
	end
end



TLG.LoadFolder("dependencies")

TLG.Include("core.lua")

TLG.LoadFolder("objects")
TLG.LoadFolder("objects/custom")

TLG.Include("methods.lua")
TLG.LoadFolder("methods")
TLG.LoadFolder("methods/objects")

TLG.LoadFolder("modules", 1)

TLG.LoadFolder("bots", 1, function(f) return f == "_init.lua" end)
