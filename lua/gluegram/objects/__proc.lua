TLG.OBJECTS = TLG.OBJECTS or {}

function TLG.AddObject(id,tInf)
	TLG.OBJECTS[id] = tInf
end

-- id это название объекта, как указано в документации
function TLG.GetObject(id)
	return TLG.OBJECTS[id]
end

local setmetatable = setmetatable
function TLG.SetMeta(tab,sObjectName)
	return setmetatable(tab,TLG.GetObject(sObjectName))
end

function TLG.GetMeta(sObjectName)
	return FindMetaTable("TLG." .. sObjectName)
end

function TLG.NewObjectBase(sType)
	local OBJ = {}
	OBJ.__index = OBJ

	debug.getregistry()["TLG." .. sType] = OBJ

	TLG.AddObject(sType,OBJ)

	return OBJ
end