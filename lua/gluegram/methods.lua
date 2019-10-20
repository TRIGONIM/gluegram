-- При обновлении этого файла надо обновить файл с самим методом для применения изменений


local METHOD_MT = {}
METHOD_MT.__index = METHOD_MT

-- Сюда вешаются всякие :SetCaption,
-- а потом используются в TLG.Request(METH)
function TLG.NewMethod(sMethod)
	return setmetatable({
		method = sMethod,
	}, METHOD_MT)
end



local REQUEST_MT = {}
REQUEST_MT.__index = REQUEST_MT

function REQUEST_MT:Send(fOnFinish_)
	local cb_type = self.cb_type -- опционально. Возвращаемый объект, чтобы сразу был в каллбэке

	-- Стукнет во все нужные каллбэки
	-- #todo засунуть в TLG.SendRequest fOnFinish просто
	local fS = (self.onsuccess and fOnFinish_) and function(dat)
		self.onsuccess(dat)
		fOnFinish_(dat)
	end or self.onsuccess or fOnFinish_

	local fE = (self.onerror and fOnFinish_) and function(code, descr)
		self.onerror(code, descr)
		fOnFinish_(nil, code, descr) -- смещение
	end or self.onerror or (fOnFinish_ and function(code, descr) fOnFinish_(nil, code, descr) end)

	TLG.SendRequest(self.token, self.method, self.params, cb_type, fS, fE)
end

function REQUEST_MT:OnSuccess(fCb)
	self.onsuccess = fCb
	return self
end

function REQUEST_MT:OnError(fCb)
	self.onerror = fCb
	return self
end

-- function REQUEST_MT:OnFinish(fCb) -- для общих каллбэков (думаю, наверное засуну в Send)
-- 	self.onfinish = fCb -- ok_dat, err_code, err_descr
-- 	return self
-- end

function REQUEST_MT:SetParam(k, v)
	self.params[k] = v and tostring(v) or nil
	return self
end

function REQUEST_MT:SetToken(token)
	self.token = token
	return self
end

function REQUEST_MT:SetCallbackType(type)
	self.cb_type = type
	return self
end


-- BOT:Photo() в BOT (Возвращает этот REQ)
-- METH:SetCaption() в METH (Добавляет параметр в этот instance)
-- REQ:Send() вообще в REQUEST_MT (Отправляет этот REQ, извлекая с него данные)
function TLG.Request(METH)
	local INSTANCE_MT = {}
	INSTANCE_MT.__index = function(_, k) -- прокси
		-- print("k", k) https://img.qweqwe.ovh/1563652660117.png
		return METH[k] or REQUEST_MT[k] -- :SetCaption or :Send
	end

	return setmetatable({
		params  = {},
		-- тут и токен и каллбэки еще навешиваются
	}, INSTANCE_MT)
end



local function pushif(f_, ...)
	if f_ then f_(...) end
end

function TLG.SendRequest(token, method, params, cb_obj_, fOnSuccess_, fOnError_)
	http.Post(
		"https://api.telegram.org/bot" .. token .. "/" .. method, params,function(dat)
			dat = assert(util.JSONToTable(dat), "Телега прислала мусор: " .. tostring(dat))

			if dat.ok then
				pushif(fOnSuccess_, cb_obj_ and TLG.SetMeta(dat.result,cb_obj_) or dat.result)
			else
				local sErr = string.format("%s %i\n%s\n\n%s",
					method, dat.error_code, dat.description,
					util.TableToJSON(params))

				TLG.LogError(sErr)
				pushif(fOnError_, dat.error_code, dat.description)
			end
		end
	)
end

/*
local BOT_T  = TLG.GetBot("base")
local METHOD = TLG.NewMethod("getChat")

function METHOD:SetID(chat_id)
	return self:SetParam("chat_id", chat_id)
end

function BOT_T:GetChat()
	return TLG.Request(METHOD):SetToken( self.token )
end

TLG_BOT():GetChat():SetID(TLG_AMD):OnError(print):Send(prt)
--*/
