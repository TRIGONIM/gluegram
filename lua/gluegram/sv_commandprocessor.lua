-- DO NOT REFRESH THE FILE
local cmds = {}

local CMD = {}
CMD.__index = CMD

function TLG.NewCommand(sCmd,fCallback)
	sCmd = string.lower(sCmd)

	local obj = setmetatable({
		func = fCallback,
		cmd  = sCmd
	},CMD)

	cmds[sCmd] = obj

	return obj
end

--------------------------------
function CMD:Description()
	return self.description
end

function CMD:Help()
	return self.help
end

function CMD:IsPublic()
	return self.public
end

function CMD:ForMaster()
	return self.master
end
--------------------------------
-- Будет отображаться в /cmd -- help или просто /help
function CMD:SetDescription(sDesc)
	self.description = sDesc
	return self
end

-- Пример использования команды
function CMD:SetHelp(sHelp) -- usage info
	self.help = sHelp
	return self
end

-- Может ли каждый желающий использовать команду
function CMD:SetPublic(bPublic)
	self.public = bPublic
	return self
end

-- Команда будет обрабатываться только мастер сервером
-- Полезно, если есть несколько гмод серверов, а управление через 1 бот
-- Позволяет обрабатывать такие команды как /help только 1 сервером, вместо всех сразу
function CMD:SetForMaster(bForMasterServer)
	self.master = bForMasterServer
	return self
end

--------------------------------

function CMD:Call(MSG)
	self.func(MSG)
end





local function table_remove(tab,index)
	local ntab = {}

	for i = 1,#tab do
		if i == index then continue end

		ntab[#ntab + 1] = tab[i]
	end

	return ntab
end

-- EXAMPLE: /login@my_info_bot testasdfjhk asdf asd
hook.Add("TLG.OnUpdate","CommandProcessor",function(UPD)
	if UPD["message"]["text"] and UPD["message"]["text"][1] == "/" then

		local parts = UPD["message"]["text"][1]:Split(" ") -- (/login@my_info_bot)[1]
		local cmd = parts[1]:Split("@")[1]:sub(2)
		if cmds[cmd] then
			local C = cmds[cmd]

			-- Игнорируем обработку, если нужен мастер сервер, а мы им не являемся
			if C:ForMaster() and !TLG.CFG.isMasterServer then
				return
			end

			-- Нужна авторизация
			if !C:IsPublic() then
				
			end

			C:Call(UPD:Message(), table_remove(parts,1))
			-- "testasdfjhk asdf asd" in args
		end
	end
end)