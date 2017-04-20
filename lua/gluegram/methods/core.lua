
local METHOD = {}
METHOD.__index = METHOD


-- fProc форматирует параметр перед выполнением запроса
function METHOD:AddParam(sParam,fProc)
	self.needparams[#self.needparams + 1] = {
		name = sParam,
		proc = fProc
	}

	return self
end

-- Если не указать, то вернется просто таблица
function METHOD:CallbackObject(sObjectName)
	self.cb_object = sObjectName
	return self
end






TLG.METHODS = TLG.METHODS or {}
function TLG.RegisterMethod(sMethod,META)
	--if TLG.METHODS[sMethod] then return TLG.METHODS[sMethod] end -- uncomment on debug
	META.__index = META

	local METH = setmetatable({
		method = sMethod,
		meta   = META,

		needparams = {},
	},METHOD)

	TLG.METHODS[sMethod] = METH

	return METH
end



--[[-------------------------------------------------------------------------
Все реально очень плохо
Нужно было создатьь 2 метаобъекта, а потом играться с наследованием,
но я так и не умею и пришлось потратить кучу времени, чтобы сделать хотя бы это говнище
---------------------------------------------------------------------------]]
function TLG.Request(sMethod,sToken)
	local METH = TLG.METHODS[sMethod]

	local REQ = setmetatable({
		token = sToken,
		params = {},

		-- Заполняет обязательные параметры в порядке добавления METH:AddParam
		BindParams = function(self,...)
			local args = {...}

			for i,param in ipairs(METH.needparams) do
				self.params[param["name"]] = param["proc"] and param["proc"](args[i]) or args[i]
			end

			return self
		end,

		Param = function(self,sParam,sValue)
			self["params"][sParam] = sValue
			return self
		end,

		Send = function(self,fCallback)
			-- print("https://api.telegram.org/bot" .. self.token .. "/" .. METH.method)
			-- PrintTable(self)
			-- print("self, prt")

			http.Post(
				"https://api.telegram.org/bot" .. self.token .. "/" .. METH.method,
				self.params,function(dat)
					dat = util.JSONToTable(dat)

					if !dat.ok then
						TLG.LogError({
							dat.error_code,
							dat.description,
							METH.method,
							string.Implode("\n",self.params)
						})



						return
					end


					if fCallback then
						fCallback(METH.cb_object and TLG.SetMeta(dat.result,METH.cb_object) or dat)
					end
				end
			)
		end
	},METH["meta"])

	--METH["meta"].__index = REQ["params"]

	return REQ
end