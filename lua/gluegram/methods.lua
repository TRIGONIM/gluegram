-- При обновлении этого файла надо обновить файл с самим методом для применения изменений. Наверное

local METHOD_MT = {}
METHOD_MT.__index = METHOD_MT

function METHOD_MT:Send(fCallback)
	local cb_type = self.cb_type -- опционально. Возвращаемый объект, чтобы сразу был в каллбэке
	TLG.SendRequest(fCallback, self.token, self.method, self.params, cb_type)
end

function METHOD_MT:SetParam(k, v)
	self.params[k] = v and tostring(v) or nil
	return self
end

function METHOD_MT:SetToken(token)
	self.token = token
	return self
end

function METHOD_MT:SetCallbackType(type)
	self.cb_type = type
	return self
end

function TLG.NewMethod(sMethod)
	return setmetatable({
		method = sMethod,
	}, METHOD_MT)
end




function TLG.Request(METH)
	local INSTANCE_MT = {}
	INSTANCE_MT.__index = METH
	INSTANCE_MT.__call = function(self, BOT, cb_typ)
		-- local MT = getmetatable(self)
		-- prt({METH = self, METHOD_MT = MT, meta = MT})

		return self:SetToken( BOT:GetToken() ):SetCallbackType(cb_typ)
	end

	return setmetatable({
		params  = {},
		token   = nil,
		cb_type = nil,
	}, INSTANCE_MT)
end


-- local CHAT = TLG.NewMethod("getChat")

-- local BOT_MT = TLG.GetObject("BOT")
-- function BOT_MT:Request(METH, cb_typ)
-- 	return TLG.Request(METH):SetToken( self:GetToken() ):SetCallbackType(cb_typ)
-- end

-- function BOT_MT:GetChat(cb, chat_id)
-- 	-- local REQ = TLG.Request(CHAT):SetParam("chat_id", chat_id)
-- 	-- prt({REQ = REQ, MT = getmetatable(REQ)})
-- 	-- REQ(self, "Chat"):Send(cb)

-- 	self:Request(CHAT, "Chat")
-- 		:SetParam("chat_id", chat_id)
-- 		:Send(cb)
-- end

-- TLG_CORE_BOT:GetChat(prt, TLG_AMD)








local function tableToString(t)
	local s = "\n\n\n"
	for k,v in pairs(t) do
		s = s .. " >> " .. k .. " <-> " .. v .. " <<\n"
	end

	return s .. "\n\n\n"
end


function TLG.SendRequest(fCallback, token, method, params, cb_obj_)
	http.Post(
		"https://api.telegram.org/bot" .. token .. "/" .. method, params,function(dat)
			dat = assert(util.JSONToTable(dat), "Телега прислала мусор: " .. tostring(dat))

			if !dat.ok then
				TLG.LogError({
					dat.error_code,
					dat.description,
					method,
					tableToString(params)
				})

				-- return
			end

			if fCallback then
				if dat.ok then
					fCallback(cb_obj_ and TLG.SetMeta(dat.result,cb_obj_) or dat.result)
				else
					fCallback(nil, dat.description, dat.error_code)
				end
			end
		end
	)
end
