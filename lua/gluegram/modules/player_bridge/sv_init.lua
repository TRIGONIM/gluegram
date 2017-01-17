
--[[-------------------------------------------------------------------------
	Проверять забанен ли юзер на сервере при выполнении УЛХ команд
---------------------------------------------------------------------------]]

local function linkUser(sid64,iTlgchat,sTlglogin,cb)
	TLG.DBQ([[
		REPLACE INTO `tlg_playerbridge`(`s64`,`tlg_chatid`,`tlg_username`)
		VALUES (]] .. sid64 .. [[,]] .. iTlgchat .. [[,?)
	]],sTlglogin,cb)
end

local function unlinkUser(sid64,cb)
	TLG.DBQ("DELETE FROM `tlg_playerbridge` WHERE `s64` = ?",sid64,cb)
end

-- s64 > iChatid
-- iChatid > s64
TLG.PLAYERACCOUNTS = TLG.PLAYERACCOUNTS or {}


local function updateCache()
	TLG.DBQ("SELECT * FROM `tlg_playerbridge`",function(dat)
		for _,row in ipairs(dat) do
			TLG.PLAYERACCOUNTS[ row["s64"] ] = row["tlg_chatid"]
			TLG.PLAYERACCOUNTS[ row["tlg_chatid"] ] = row["s64"]
		end
	end)

	linkUser(76561198071463189,TLG_AMD,"amd_nick")
end

local function createTables(cb)
	TLG.DBQ([[
		CREATE TABLE IF NOT EXISTS `tlg_playerbridge` (
			`s64` bigint(20) UNSIGNED NOT NULL,
			`tlg_username` varchar(32) NOT NULL,
			`tlg_chatid` bigint(20) NOT NULL,

			PRIMARY KEY (`s64`),
			KEY `tlg_chatid` (`tlg_chatid`)
		) DEFAULT CHARSET=utf8;
	]],cb)
end

-- Antiluarefresh
hook.Add("Initialize","TLG.PlayerBridge",function()
	createTables(updateCache)
end)

--createTables(updateCache)










