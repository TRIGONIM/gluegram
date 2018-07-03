local INLINE_ANSWER = TLG.NewMethod("answerInlineQuery")


function INLINE_ANSWER:SetID(iID) -- !!!
	return self:SetParam("inline_query_id",iID)
end

function INLINE_ANSWER:SetResults(tRes) -- !!!
	return self:SetParam("results", util.TableToJSON(tRes))
end

function INLINE_ANSWER:SetCache(iSecTime, bPersonal)
	return self:SetParam("cache_time", iSecTime):SetParam("is_personal", tobool(bPersonal))
end


-- Создаем объект ответа
local BOT_MT = TLG.GetMeta("BOT")
function BOT_MT:InlineAnswer(iID, tRes)
	return self:Request(INLINE_ANSWER)
		:SetID(iID)
		:SetResults(tRes)
end
