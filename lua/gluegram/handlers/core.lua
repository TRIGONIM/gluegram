local HANDLER = {}
HANDLER.__index = HANDLER

TLG.HANDLERS = TLG.HANDLERS or {}


-- 
function HANDLER:HandleUpdate(handler)
	self.handler = handler
	return self
end

-- fChecker должен возвращать true, если апдейт подходит под задачу
function TLG.AddHandler(sName,fChecker)
	local OBJ = setmetatable({
		checker = fChecker
	},HANDLER)

	TLG.HANDLERS[sName] = OBJ

	return OBJ
end



--------------------------------------


local BOT_MT = TLG.GetObject("BOT")

function BOT_MT:AddHandler(HANLER_OBJ)
	self:UpdatesHook(function(UPD)
		for name,OBJ in pairs(TLG.HANDLERS) do
			if OBJ["checker"](UPD) then
				return OBJ["handler"] and OBJ["handler"](UPD) or UPD
			end
		end
	end,self:Name() .. "_handler")
end