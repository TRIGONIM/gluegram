
local METHOD = {}
METHOD.__index = METHOD



TLG.METHODS = TLG.METHODS or {}
function TLG.RegisterMethod(sMethod,META,sCallbackObjectName_)
	--if TLG.METHODS[sMethod] then return TLG.METHODS[sMethod] end -- uncomment on debug
	META.__index = META

	TLG.METHODS[sMethod] = {
		meta = META,
		cb_object = sCallbackObjectName_
	}

	return TLG.METHODS[sMethod]
end


local function tableToString(t)
	local s = "\n\n\n"
	for k,v in pairs(t) do
		s = s .. " >> " .. k .. " <-> " .. v .. " <<\n"
	end

	return s .. "\n\n\n"
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

		SetParam = function(self,sParam,value)
			self.params[sParam] = value and tostring(value) or nil
			return self
		end,

		Send = function(self,fCallback)
			-- print("https://api.telegram.org/bot" .. self.token .. "/" .. sMethod)
			-- PrintTable(self)
			-- print("self, prt")

			http.Post(
				"https://api.telegram.org/bot" .. self.token .. "/" .. sMethod,
				self.params,function(dat)
					dat = util.JSONToTable(dat)

					if !dat.ok then
						TLG.LogError({
							dat.error_code,
							dat.description,
							sMethod,
							tableToString(self.params)
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