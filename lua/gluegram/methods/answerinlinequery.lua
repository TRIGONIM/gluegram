local BOT_MT = TLG.GetBot("base")
local METHOD = TLG.NewMethod("answerInlineQuery")


function METHOD:SetCache(iSecTime, bPersonal)
	return self:SetParam("cache_time", iSecTime):SetParam("is_personal", tobool(bPersonal))
end


-- Создаем объект ответа
function BOT_MT:AnswerInline(iID, tRes)
	return self:Request(METHOD)
		:SetParam("inline_query_id", iID)
		:SetParam("results", util.TableToJSON(tRes))
end
