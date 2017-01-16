TLG.getDataFrom = {}
local pref = "[TLG] "

/*
 Функция возвращают данные в таблице, где индекс = нужный тип данных
 Примерный вид:
 table = {
 	[message] = messagetable,
 	[update_id] = 1337,
 	[username] = "noob"
 }

 Если таблица не вернулась, значит ее не удалось обработать
 В этом случае причина, вероятно, будет возвращена вторым аргументом функции

 Пример:
 local datatable,error = TLG.getDataFrom.Update(data, {"update_id"})
 if error then
 	print(error)
	return
 end
*/
function TLG.getData(data, needdata)

	if !(data or needdata) then
		return nil, pref .. "No input data"
	end

	if type(needdata) ~= "table" then needdata = {needdata} end
	if type(data) ~= "table" then data = util.JSONToTable(data) end

	if !data then
		return nil, pref .. "Invalid input data type. Need table or JSON"
	end

	local result = {}
	for i = 1, #needdata do
		result[needdata[i]] = data[needdata[i]]
	end

	return result
end

function TLG.getDataFrom.Update(data)

	if type(data) ~= "table" then data = util.JSONToTable(data) end

	if !data then
		return nil, pref .. "Invalid input data type. Need table or JSON"
	end

	if data.ok == false then -- при вебхуке nil
		return nil, pref .. string.format("Error recieving data: %s",data.description)
	end

	-- local result = {}
	-- for i = 1, #data["result"] do
	-- 	result[i] = TLG.getData(data["result"][i], {"update_id", "message", "inline_query", "chosen_inline_result"})
	-- end

	return data
end

