-- Standalone Castbar for Tukui by Krevlorne @ EU-Ulduar
-- Credits to Tukz, Syne, Elv22 and all other great people of the Tukui community.

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

if ( TukuiUF ~= true and ( C == nil or C["unitframes"] == nil or not C["unitframes"]["enable"] ) ) then return; end

if (C["unitframes"].unitcastbar ~= true) then return; end

local addon, ns=...
config = ns.config

local player = TukuiPlayerCastBar
local target = TukuiTargetCastBar

local channelingTicks = {
	-- Deathknight
	[GetSpellInfo(42651)] = 8, 	-- Army of the Dead Ghoul
	-- Druid
	[GetSpellInfo(740)] = 5, 	-- Tranquility
	[GetSpellInfo(16914)] = 10,	-- Hurricane
	-- Mage
	[GetSpellInfo(5143)] = 5, 	-- Arcane Missiles
	[GetSpellInfo(10)] = 8, 	-- Blizzard
	[GetSpellInfo(12051)] = 4, 	-- Evocation
	-- Priest
	[GetSpellInfo(15407)] = 3, 	-- Mind Flay
	[GetSpellInfo(48045)] = 5, 	-- Mind Sear
	[GetSpellInfo(47540)] = 3, 	-- Penance
	[GetSpellInfo(64843)] = 3, 	-- Divine Hymn
	[GetSpellInfo(64904)] = 3, 	-- Hymn of Hope
	-- Warlock
	[GetSpellInfo(1120)] = 6, 	-- Drain Soul
	[GetSpellInfo(689)] = 3, 	-- Drain Life
	[GetSpellInfo(5740)] = 4, 	-- Rain of Fire
	[GetSpellInfo(79268)] = 3, 	-- Soul Harvest
}

local sparkfactory = {
	__index = function(t,k)
		local spark = player:CreateTexture(nil, 'OVERLAY')
		t[k] = spark
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		spark:SetBlendMode('ADD')
		spark:SetWidth(10)
		spark:SetHeight(26)
		return spark
	end
}

local barticks = setmetatable({}, sparkfactory)

local function setBarTicks(ticknum)
	if config.player["showticks"] ~= true then 
		return 
	end

	if( ticknum and ticknum > 0) then
		local delta = ( (config.player["width"]-4) / ticknum )
		for k = 1, ticknum - 1 do
			local t = barticks[k]
			t:ClearAllPoints()
			t:Point("CENTER", player, "LEFT", delta * k, 0 )
			t:Show()
		end
	else
		barticks[1].Hide = nil
		for i=1,#barticks do
			barticks[i]:Hide()
		end
	end
end

function iif(cond, a, b)
	if cond then
		return a
	end
	return b
end

local function placeCastbar(unit)
	local castbar = iif(unit == "player", player, target)
	local barconfig = iif(unit == "player", config.player, config.target)
	
	local anchor = CreateFrame("Button", castbar:GetName().."PanelAnchor", UIParent)
	anchor:Width(barconfig["width"]) 
	anchor:Height(barconfig["height"])
	anchor:SetBackdrop(backdrop)
	anchor:SetBackdropColor(0.25, 0.25, 0.25, 1)

	local anchorLabel = anchor:CreateFontString(nil, "ARTWORK")
	anchorLabel:SetFont(C["media"].uffont, 12, "OUTLINE")
	anchorLabel:SetAllPoints(anchor)
	anchorLabel:SetText(iif(unit == "player", "Player Castbar", "Target Castbar"))
	anchor:SetMovable(true)
	anchor:SetTemplate("Default")
	anchor:SetBackdropBorderColor(1, 0, 0, 1)
	anchor:Hide()

	table.insert(T.MoverFrames, anchor)
	anchor.text = {}
	anchor.text.Show = function() anchor:Show() end
	anchor.text.Hide = function() anchor:Hide() end

	anchor:RegisterEvent("ADDON_LOADED")
	anchor:SetScript("OnEvent", function(frame, event, loadedAddon)
		if addon ~= loadedAddon then return end
		anchor:UnregisterEvent("ADDON_LOADED")
		anchor:Point("CENTER", UIParent, "CENTER", 0, barconfig["yDistance"])
	end)

	local panel = CreateFrame("Frame", castbar:GetName().."Panel", castbar)
	panel:CreatePanel(config["template"], barconfig["width"], barconfig["height"], "CENTER", anchor, "CENTER", 0, 0)

	castbar:Point("TOPLEFT", panel, 2, -2)
	castbar:Point("BOTTOMRIGHT", panel, -2, 2)

	castbar.time = T.SetFontString(castbar, C.media.uffont, barconfig["fontsize"])
	castbar.time:Point("RIGHT", panel, "RIGHT", -4, 0)
	castbar.time:SetTextColor(unpack(barconfig["fontcolor"]))
	castbar.time:SetJustifyH("RIGHT")

	castbar.Text = T.SetFontString(castbar, C.media.uffont, barconfig["fontsize"])
	castbar.Text:Point("LEFT", panel, "LEFT", 4, 0)
	castbar.Text:SetTextColor(unpack(barconfig["fontcolor"]))

	if C["unitframes"].cbicons == true then
		castbar.button:SetTemplate(config["template"])
		castbar.button:ClearAllPoints()

		if barconfig["iconright"] then
			castbar.button:Point("RIGHT", 40, 0)
		else
			castbar.button:Point("LEFT", -40, 0)
		end
	end

	if (unit == "player") then
		player.Castbar = castbar    
		player.Castbar.Time = castbar.time
		player.Castbar.Icon = castbar.icon

		-- cast bar latency
		local normTex = C["media"].normTex;
		if C["unitframes"].cblatency == true then
			castbar.safezone = castbar:CreateTexture(nil, "OVERLAY")
			castbar.safezone:SetTexture(normTex)
			castbar.safezone:SetVertexColor(unpack(barconfig["latencycolor"]))
			castbar.SafeZone = castbar.safezone
		end

		panel.UNIT_SPELLCAST_START = function (unit)
			if unit ~= "player" and unit ~= "vehicle" then return end 
			player:SetStatusBarColor(unpack(barconfig["castingcolor"]))
			setBarTicks(0)
		end

		panel.UNIT_SPELLCAST_CHANNEL_START = function (unit, spell)
			if unit ~= "player" and unit ~= "vehicle" then return end 
			player:SetStatusBarColor(unpack(barconfig["channelingcolor"]))
			setBarTicks(channelingTicks[spell] or 0)
		end
	else
		TukuiTargetCastBar.Castbar = castbar
		TukuiTargetCastBar.Castbar.Time = castbar.time
		TukuiTargetCastBar.Castbar.Icon = castbar.icon

		panel.UNIT_SPELLCAST_START = function (unit)
			if unit ~= "target" then return end 
			if select(9, UnitCastingInfo(unit)) == 1 then
				target:SetStatusBarColor(unpack(barconfig["noninterruptablecolor"]))
			else
				target:SetStatusBarColor(unpack(barconfig["interruptablecolor"]))
			end
		end

		panel.UNIT_SPELLCAST_CHANNEL_START = function (unit)
			if unit ~= "target" then return end 
			if select(8, UnitChannelInfo(unit)) == 1 then
				target:SetStatusBarColor(unpack(barconfig["noninterruptablecolor"]))
			else
				target:SetStatusBarColor(unpack(barconfig["interruptablecolor"]))
			end
		end

		panel.UNIT_SPELLCAST_INTERRUPTIBLE = function (unit)
			if unit ~= "target" then return end 
			target:SetStatusBarColor(unpack(barconfig["interruptablecolor"]))
		end

		panel.UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function (unit)
			if unit ~= "target" then return end 
			target:SetStatusBarColor(unpack(barconfig["noninterruptablecolor"]))
		end

		panel.PLAYER_TARGET_CHANGED = function (unit)
			if UnitCastingInfo("target") ~= nil then
				panel.UNIT_SPELLCAST_START("target")
			elseif UnitChannelInfo("target") ~= nil then
				panel.UNIT_SPELLCAST_CHANNEL_START("target")
			else
				target:SetStatusBarColor(unpack(barconfig["fontcolor"]))
			end
		end
    end

	panel:RegisterEvent("UNIT_SPELLCAST_START")
	panel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	panel:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	panel:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	panel:RegisterEvent("PLAYER_TARGET_CHANGED")
	panel:SetScript("OnEvent", function(self, event, ...) if self[event] then self[event](...) end end)
end

if (config.separateplayer) then
	placeCastbar("player")
end

if (config.separatetarget) then
	placeCastbar("target")
end
