
local function addPlyInfoTypes()


	TLG.addPlyDataType("utime", function(clb, sid, ply, uid)

		if !Utime then clb("Utime не установлен") return end

		TLG.getMySQLInfo(
			function(t)
				local txt = type(t) == "table" and
					"\n" ..
					"🕔 Наиграно: " .. timeToStr(t.totaltime) .. "\n" ..
					"👁 Замечен: " .. os.date("%X - %d/%m/%Y", t.lastvisit) .. "\n" ..
					"🗓 Первый вход: " .. (t.firstauth == "0000-00-00 00:00:00" and "Раньше 06.11.15" or t.firstauth)
				or t

				clb( txt )
			end,
			"trigon_utime","uid",uid
		)

	end)


	TLG.addPlyDataType("darkrp", function(clb, sid, ply, uid)

		local basetxt = "\n" ..
			"👛 " .. (math.random(2) == 1 and "Кашыльок" or "Бапки") .. ": %s\n" ..
			"👤 Пазывной: %s"

		if ply then
			clb(string.format(basetxt, DarkRP.formatMoney(ply:GetNetVar("money")), ply:Nick())) -- getDarkRPVar
		else
			TLG.getMySQLInfo(
			function(t)
				local txt = type(t) == "table" and
					string.format(basetxt, DarkRP.formatMoney(t.wallet), t.rpname)
				or t

				clb( txt )
			end,
			"darkrp_player","uid",uid
		)
		end

	end)


	TLG.addPlyDataType("uniqueid", function(clb, sid, ply, uid)
		clb(uid)
	end)


	if ATM then
	TLG.addPlyDataType("atm", function(clb, sid, ply, uid)

		TLG.getMySQLInfo(
			function(t)
				local txt = type(t) == "table" and
					"\n" ..
					"🏧 ID: " .. t.id .. "\n" ..
					"💳 Баланс: " .. DarkRP.formatMoney(t.bal) .. "\n" ..
					"🗄 Активный: " .. (t.active == 1 and "✅" or "❎")
				or t

				clb( txt )
			end,
			"trigon_atm","unid",uid
		)
	end)
	end

	if TRIGON_SS then
	TLG.addPlyDataType("stats", function(clb, sid, ply, uid)

		TLG.getMySQLInfo(
			function(t)
				local txt = type(t) == "table" and
					"\n" ..
					"🔪 Киллы: " .. t["kills"] .. "\n" ..
					"☠ Смерти: " .. t["deaths"] .. "\n" ..
					"🚆 Коннекты: " .. t["joins"]
				or t

				clb( txt )
			end,
			"trigon_stats","uid",uid
		)
	end)
	end


	if RXCar_Provider_GetInventory then
	TLG.addPlyDataType("cars", function(clb, sid, ply, uid)

		RXCar_Provider_GetInventory(
			sid,
			function(carstbl)

				if table.Count(carstbl) == 0 then clb("🚗 Nonexistent account or player have no one car") return end

				local normtab = {}
				for i = 1, #D3DCarConfig.Car do
					normtab[D3DCarConfig.Car[i]["VehicleName"]] = {
						name = D3DCarConfig.Car[i]["CarName"],
						price = D3DCarConfig.Car[i]["CarPrice"]
					}
				end

				local cars = "NAME | PRICE or CLASS\n"
				for k,v in pairs(carstbl) do
					local car = normtab[v.VehicleName]

					cars = cars ..
					(car and car.name  or "Car already removed from server") .. " | " ..
					(car and DarkRP.formatMoney(car.price) or v.VehicleName) .. "\n"
				end

				clb("🚗 " .. string.sub( cars,1,#cars - 1 ))
			end
		)
	end)
	end


	if coffeeInventory then
	TLG.addPlyDataType("inventory", function(clb, sid, ply, uid)
		local q = sql.Query( "SELECT items FROM coffee_inventory WHERE id = " .. uid .. " LIMIT 1" )

		if !q then
			clb("Nonexistent account")
		else
			-- http://joxi.ru/Y2LqqyBh8djVA6
			local invt = util.JSONToTable( q[1].items )

			local inv = "\n🎒 NAME or class | AMOUNT\n"
			for line,sector in pairs(invt) do
				for sec,item in pairs(sector) do
					if type(item) ~= "table" then continue end

					inv = inv ..
					(coffeeInventory.config.language[ "weaponNames" ][ item["data"]["WeaponClass"] ] or item["data"]["WeaponClass"]) .. " | " ..
					item["amount"] .. "\n"
				end
			end

			clb(inv)
		end

	end)
	end

	if IGS then
	TLG.addPlyDataType("donate", function(clb, sid, ply, uid)
		if !IGS then clb("👑 IGS не установлен") return end

		IGS.getData(
			function(t)
				if !t then clb("👑 Player have not active donate") return end

				local don = "👑 TYPE | VAL | PRICE | PURCHASE | ACTIVE\n"
				for _, tab in pairs(t) do

					don = don ..
					--tab.server     .. " | " ..
					tab.type       .. " | " ..
					tab.value      .. " | " ..
					tab.price      .. " | " ..
					tab.purch_date .. " | " ..
					tab.active     .. "\n"

				end

				clb(string.sub( don,1,#don - 1 ))

			end, sid, IGS.server
		)
	end)

	TLG.addPlyDataType("donbal", function(clb, sid, ply, uid)
		if !IGS then clb("💰 IGS не установлен") return end

		if ply then
			clb("💰 " .. ply:GetNWFloat("IGS.Bal"))
		else
			IGS.getAccounts(sid, 1, nil,
				function(t)
					if !t then clb("💰 Player have not donate account") return end

					clb("💰 " .. t[1].bal)
				end
			)
		end
	end)
	end


	TLG.addPlyDataType("ip", function(clb, sid, ply, uid)
		if ply then
			clb("🚩 " .. string.match(ply:IPAddress(),"[^:]*"))
		else
			clb("🚩 Player offline")
		end
	end)


	print("[Gluegram] Base players data info types succesful loaded :|")
end



hook.Add("onGluegramLoaded","TLG.AddPlyDataTypes",addPlyInfoTypes)