local BOT_MT = TLG.GetBot("base")
local METHOD = TLG.NewMethod("answerCallbackQuery")


function METHOD:SetText(sText) -- 0-200 chars
	return self:SetParam("text", sText)
end

-- https://img.qweqwe.ovh/1549992613802.png
function METHOD:ShowAlert(bShowAlert)
	return self:SetParam("show_alert", bShowAlert)
end

-- Кеширует ответ и не будет отправлять запрос при повторном нажатии
function METHOD:SetCache(iSecTime)
	return self:SetParam("cache_time", iSecTime)
end


-- Создаем объект ответа
function BOT_MT:AnswerCallback(iID)
	return self:Request(METHOD)
		:SetParam("callback_query_id", iID)
end
