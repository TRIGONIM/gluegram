local BOT_MT = TLG.GetMeta("BOT")
local METHOD = TLG.NewMethod("answerInlineQuery")


function METHOD:SetID(iID) -- !!!
	return self:SetParam("inline_query_id",iID)
end

function METHOD:SetResults(tRes) -- !!!
	return self:SetParam("results", util.TableToJSON(tRes))
end

function METHOD:SetCache(iSecTime, bPersonal)
	return self:SetParam("cache_time", iSecTime):SetParam("is_personal", tobool(bPersonal))
end


-- Создаем объект ответа
function BOT_MT:InlineAnswer(iID, tRes)
	return self:Request(METHOD)
		:SetID(iID)
		:SetResults(tRes)
end
