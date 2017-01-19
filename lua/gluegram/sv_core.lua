-- Отправляет сообщение группе людей
-- Принимает строку с названией группы или таблицу с идшниками
-- Вторым параметром принимает сообщение. Если не передать message, то передаст трэйсбэк
function TLG.notifyGroup(groupname_or_ids,message)
	message = "[" .. TLG.Cfg.SVName .. "] > " .. (message or debug.traceback())

	-- Если список айдишников в таблице
	if istable(groupname_or_ids) then
		for i = 1,#groupname_or_ids do
			TG.SendMessage(groupname_or_ids[i],message)
		end

	-- Если строка-название группы
	else
		for id,dat in pairs(TLG.Cfg.Users) do
			if dat.group == groupname_or_ids then
				TG.SendMessage(id,message)
			end
		end
	end
end




setmetatable(TLG, {
	__call = function(self,...)
		return self.NewBot(...)
	end
})


function TLG.LogError(err)
	local sErr = isstring(err) and err
	if !sErr then
		sErr = "==== " .. TL.getDatetime() .. " ===="
		for typ,val in pairs(err) do
			sErr = sErr .. "\n" .. typ .. ": " .. val
		end
		sErr = sErr .. "\n========= [TLG ERR] =========\n\n"
	else
		sErr = "[TLG ERR] " .. sErr
	end

	print("\n\n\n" .. sErr)
	file.Append("telegram_errors.txt",sErr)
end
