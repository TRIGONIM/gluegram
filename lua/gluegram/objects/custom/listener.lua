-- Описание в gluegram_core.lua
local LST = TLG.NewObjectBase("LISTENER")

function LST:AddReceiver(sName,fReceiver)
	self.receivers[sName] = fReceiver

	if !self:IsActive() then
		self:Start()
	end
end

-- function LST:RemoveReceiver(sName)
-- 	self.receivers[sName] = nil
-- end

function LST:IsActive()
	return self.active
end

function LST:Callback(UPD)
	for name,func in pairs(self.receivers) do
		func(UPD)
	end
end

function LST:Start()
	self.handler(self)
	self.active = true
	return self
end

-- Хэндлер должен уметь обрабатывать
function LST:Stop()
	self.active = false
	return self
end
