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
	if( ticknum and ticknum > 0) then
		local delta = ( (config.player["width"]-4) / ticknum )
		for k = 1,ticknum do
			local t = barticks[k]
			t:ClearAllPoints()
			t:SetPoint("CENTER", player, "LEFT", delta * k, 0 )
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

local playerAnchor = CreateFrame("Button", "TukuiCastbarPlayerAnchor", UIParent)
playerAnchor:Width(config.player["width"]) 
playerAnchor:Height(config.player["height"])
playerAnchor:SetBackdrop(backdrop)
playerAnchor:SetBackdropColor(0.25, 0.25, 0.25, 1)

local playerAnchorLabel = playerAnchor:CreateFontString(nil, "ARTWORK")
playerAnchorLabel:SetFont(C["media"].uffont, 12, "OUTLINE")
playerAnchorLabel:SetAllPoints(playerAnchor)
playerAnchorLabel:SetText("Player Castbar")
playerAnchor:SetMovable(true)
playerAnchor:SetTemplate("Default")
playerAnchor:SetAlpha(0)
playerAnchor:SetBackdropBorderColor(1, 0, 0, 1)

table.insert(T.MoverFrames, playerAnchor)
playerAnchor.text = {}
playerAnchor.text.Show = function() playerAnchor:SetAlpha(1) end
playerAnchor.text.Hide = function() playerAnchor:SetAlpha(0) end

playerAnchor:RegisterEvent("ADDON_LOADED")
playerAnchor:SetScript("OnEvent", function(frame, event, loadedAddon)
	if addon ~= loadedAddon then return end
	playerAnchor:UnregisterEvent("ADDON_LOADED")
	playerAnchor:Point("CENTER", UIParent, "CENTER", 0, config.player["yDistance"])
end)

local targetAnchor = CreateFrame("Button", "TukuiCastbarTargetAnchor", UIParent)
targetAnchor:Width(config.target["width"]) 
targetAnchor:Height(config.target["height"])
targetAnchor:SetBackdrop(backdrop)
targetAnchor:SetBackdropColor(0.25, 0.25, 0.25, 1)

local targetAnchorLabel = targetAnchor:CreateFontString(nil, "ARTWORK")
targetAnchorLabel:SetFont(C["media"].uffont, 12, "OUTLINE")
targetAnchorLabel:SetAllPoints(targetAnchor)
targetAnchorLabel:SetText("Target Castbar")
targetAnchor:SetMovable(true)
targetAnchor:SetTemplate("Default")
targetAnchor:SetAlpha(0)
targetAnchor:SetBackdropBorderColor(1, 0, 0, 1)

table.insert(T.MoverFrames, targetAnchor)
targetAnchor.text = {}
targetAnchor.text.Show = function() targetAnchor:SetAlpha(1) end
targetAnchor.text.Hide = function() targetAnchor:SetAlpha(0) end

targetAnchor:RegisterEvent("ADDON_LOADED")
targetAnchor:SetScript("OnEvent", function(frame, event, loadedAddon)
	if addon ~= loadedAddon then return end
	targetAnchor:UnregisterEvent("ADDON_LOADED")
	targetAnchor:Point("CENTER", UIParent, "CENTER", 0, config.target["yDistance"])
end)

local function placeCastbar(unit)
    local castbar = iif(unit == "player", player, target)
	local barconfig = iif(unit == "player", config.player, config.target)

    local panel = CreateFrame("Frame", castbar:GetName().."Panel", castbar)
	panel:CreatePanel(config["template"], barconfig["width"], barconfig["height"], "CENTER", iif(unit == "player", playerAnchor, targetAnchor), "CENTER", 0, 0)
    
    castbar:SetPoint("TOPLEFT", panel, T.Scale(2), T.Scale(-2))
    castbar:SetPoint("BOTTOMRIGHT", panel, T.Scale(-2), T.Scale(2))
	
    castbar.time = T.SetFontString(castbar, C.media.uffont, barconfig["fontsize"])
    castbar.time:SetPoint("RIGHT", panel, "RIGHT", T.Scale(-4), 0)
    castbar.time:SetTextColor(unpack(barconfig["fontcolor"]))
    castbar.time:SetJustifyH("RIGHT")

    castbar.Text = T.SetFontString(castbar, C.media.uffont, barconfig["fontsize"])
    castbar.Text:SetPoint("LEFT", panel, "LEFT", T.Scale(4), 0)
    castbar.Text:SetTextColor(unpack(barconfig["fontcolor"]))

    if C["unitframes"].cbicons == true then
		castbar.button:SetTemplate(config["template"])
		castbar.button:ClearAllPoints()

		if barconfig["iconright"] then
            castbar.button:SetPoint("RIGHT", T.Scale(40), 0)
        else
			castbar.button:SetPoint("LEFT", T.Scale(-40), 0)
        end
    end
	
    if (unit == "player") then
        player.Castbar = castbar    
        player.Castbar.Time = castbar.time
        player.Castbar.Icon = castbar.icon
		
		-- cast bar latency
		local normTex = TukuiCF["media"].normTex;
		if C["unitframes"].cblatency == true then
			castbar.safezone = castbar:CreateTexture(nil, "OVERLAY")
			castbar.safezone:SetTexture(normTex)
			castbar.safezone:SetVertexColor(unpack(barconfig["latencycolor"]))
			castbar.SafeZone = castbar.safezone
		end		

		panel.UNIT_SPELLCAST_START = function ()
			player:SetStatusBarColor(unpack(barconfig["castingcolor"]))
		end
		
		panel.UNIT_SPELLCAST_CHANNEL_START = function (unit, spell)
			local ticks = channelingTicks[spell] or 0
			setBarTicks(ticks)			
			
			player:SetStatusBarColor(unpack(barconfig["channelingcolor"]))
		end
		
		panel.UNIT_SPELLCAST_CHANNEL_STOP = function ()
			setBarTicks(0)			
		end
	else
        TukuiTargetCastBar.Castbar = castbar
        TukuiTargetCastBar.Castbar.Time = castbar.time
        TukuiTargetCastBar.Castbar.Icon = castbar.icon
		
		--[[
		panel.UNIT_SPELLCAST_START = function (unit, spell)
			-- print(UnitCastingInfo(unit))
			if select(9, UnitCastingInfo(unit)) == 1 then
				target:SetStatusBarColor(unpack(barconfig["noninterruptablecolor"]))
			else
				target:SetStatusBarColor(unpack(barconfig["interruptablecolor"]))
			end
		end
		
		panel.UNIT_SPELLCAST_CHANNEL_START = function (unit, spell)
			if select(8, UnitCastingInfo(unit)) == 1 then
				target:SetStatusBarColor(unpack(barconfig["noninterruptablecolor"]))
			else
				target:SetStatusBarColor(unpack(barconfig["interruptablecolor"]))
			end
		end		
		
		panel.UNIT_SPELLCAST_INTERRUPTIBLE = function (unit, spell)
			target:SetStatusBarColor(unpack(barconfig["interruptablecolor"]))
		end		

		panel.UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function (unit, spell)
			target:SetStatusBarColor(unpack(barconfig["noninterruptablecolor"]))
		end	]]	
    end

	panel:RegisterEvent("UNIT_SPELLCAST_START")
	panel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	panel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	panel:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	panel:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	panel:SetScript("OnEvent", function(self, event, ...) if self[event] then self[event](...) end end)
end

if (config.separateplayer) then
    placeCastbar("player")
end

if (config.separatetarget) then
    placeCastbar("target")
end