--[[-------------------------------------------------------------------------
	Переватывает капчу и шлет ее в телегу для решения
---------------------------------------------------------------------------]]


local BOT = TLG_CORE_BOT
local function sendMessage(msg,cb)
	BOT:Message(TLG_CONF_MOD, msg):Send(cb)
end



local QUERY_CAPTCHA = {}
local captchas = {}

local function handleCaptcha(MSG,img,id,VKQUERY)
	captchas[MSG.message_id] = {
		captcha = {
			img = img,
			id  = id,
			VKQUERY = VKQUERY
		},

		TLG = MSG
	}

	QUERY_CAPTCHA[VKQUERY.method] = MSG
end
local function unhandleCaptcha(MSG,VKQUERY)
	captchas[MSG.message_id] = nil
	QUERY_CAPTCHA[VKQUERY.method] = nil
end
local function isMessageWithCaptcha(MSG)
	if captchas[MSG:ID()] then
		local c = captchas[MSG:ID()].captcha
		return c.img,c.id,c.VKQUERY
	end

	return false
end


BOT:HandleMessage(function(MSG)
	if !MSG.reply_to_message then return end -- https://img.qweqwe.ovh/1510157273789.png
	local CAPMSG = MSG:ReplyToMessage()

	local img,id,VKQUERY = isMessageWithCaptcha(CAPMSG)
	if img then -- сообщение, на которое ответили было с капчей
		local code = MSG:Text()

		VKQUERY:SetParam("captcha_sid",id)
		VKQUERY:SetParam("captcha_key",code)

		VKQUERY:Exec(function()
			unhandleCaptcha(CAPMSG,VKQUERY)
			sendMessage("Ну вроде правильно")
		end)
	end
end,"VKCaptcha")


local CAPTCHA_NEEDED = 14
hook.Add("VK.OnError." .. CAPTCHA_NEEDED,"HandleCaptchaError",function(VKQUERY,res)
	if !res.captcha_img then return end -- нет капчи

	local img,id = res.captcha_img, res.captcha_sid
	local function fallback(MSG)
		handleCaptcha(MSG,img,id,VKQUERY)
	end

	local txt = "Что на капче? (reply)\n" .. img
	local HANDED_CAP_MSG = QUERY_CAPTCHA[VKQUERY.method]
	if HANDED_CAP_MSG then
		BOT:EditMessage(HANDED_CAP_MSG,txt):Send(fallback)
	else
		sendMessage(txt,fallback)
	end
end)