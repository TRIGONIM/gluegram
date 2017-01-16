--[[-------------------------------------------------------------------------
TODO СДЕЛАТЬ ПРИВЯЗКУ КОМАНД К БОТУ
Ибо не определить кто должен обрабатывать /login, например
---------------------------------------------------------------------------]]


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

function CMD:Call(MSG,tArgs)
	self.func(MSG,tArgs)
end

------------------------------------------------------------------------------------------------




local cusrs = {} -- connected users chat ids
function TLG.connect(iChatID)
	if !cusrs[iChatID] then
		cusrs[iChatID] = true
		TG.SendMessage(iChatID, string.format("Вы присоединились к %s.\nMOTD: %s",TLG.CFG.SVName,TLG.CFG.MOTD))
	else
		TG.SendMessage(iChatID, string.format("Сервер (%s) уже активен",TLG.CFG.SVNAME))
	end
end
function TLG.disconnect(iChatID)
	if cusrs[iChatID] then
		cusrs[iChatID] = nil
		TG.SendMessage(iChatID, string.format("Вы отключены от %s",TLG.CFG.SVNAME))
	else -- вы не авторизированы
		TG.SendMessage(iChatID, string.format("Соединение с (%s) не активно",TLG.CFG.SVNAME))
	end
end






local function processCommand(cmd,MSG,tArgs)
	local C = cmds[cmd]





	C:Call(MSG,tArgs)
	-- "testasdfjhk asdf asd" in tArgs
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
	if UPD["message"]["text"] and UPD["message"]["text"][1] == "/" then -- если команда

		-- Обработка нескольких команд в одном сообщении
		local parts = string.Explode(";",UPD["message"]["text"])
		for i = 1,math.Clamp(#parts,0,5) do -- ограничиваем для предотвращения абуза
			parts[i] = parts[i]:Trim() -- /cmd;  ; /cmd"
			if parts[i] == "" then continue end

			local pieces = parts[i]:Split(" ")
			local cmd = pieces[1]:Split("@")[1]:sub(2) -- /cmd@botname

			if cmds[cmd] then

				-- Игнорируем обработку, если нужен мастер сервер, а мы им не являемся
				if cmds[cmd]:ForMaster() and !TLG.CFG.isMasterServer then
					return
				end

				-- Нужна авторизация
				if !cmds[cmd]:IsPublic() then

				end


				processCommand(cmd,UPD:Message(), table_remove(pieces,1))

			else
				-- команды cmd не существует
			end
		end
	end
end)


TLG.NewCommand("login",function(MSG,args)
	if !args[1] then
		TG.SendMessage(chat, "Нужно ввести кодовое название сервера. Пример: /login prisma")
		return
	end

	if args[1]:lower() == TLG.CFG.SVNAME or args[1] == "*" then
		--TLG.connect(chat)
	end
end)
	:SetPublic(true)
	:SetHelp("/login *")
	:SetDescription("Авторизация на указанном в аргументах сервере. Список доступных серверов: /servers")