local BOT_T = TLG.NewBot("base")

-- Мб все это в MT?
-- function BOT_T:Initialize() end
function BOT_T:OnError(descr, code) end
function BOT_T:OnUpdate(UPD) end
function BOT_T:OnMessage(MSG) end
function BOT_T:OnCommand(MSG, cmd, argss_) end
function BOT_T:OnCBQ(CBQ, tData) end
