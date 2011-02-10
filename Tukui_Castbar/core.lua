-- Standalone Castbar for Tukui by Krevlorne @ EU-Ulduar
-- Credits to Tukz, Syne, Elv22 and all other great people of the Tukui community.

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

if ( TukuiUF ~= true and ( C == nil or C["unitframes"] == nil or not C["unitframes"]["enable"] ) ) then return; end

if (C["unitframes"].unitcastbar ~= true) then return; end

local _, ns=...
config = ns.config

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
}

local sparkfactory = {
	__index = function(t,k)
		local spark = TukuiPlayerCastBar:CreateTexture(nil, 'OVERLAY')
		t[k] = spark
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		spark:SetBlendMode('ADD')
		spark:SetWidth(15)
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
			t:SetPoint("CENTER", TukuiPlayerCastBar, "LEFT", delta * k, 0 )
			t:Show()
		end
	else
		barticks[1].Hide = nil
		for i=1,#barticks do
			barticks[i]:Hide()
		end
	end
end

local function placeCastbar(unit)
    local font1 = TukuiCF["media"].uffont
    local castbar = nil
    local castbarpanel = nil
    
    if (unit == "player") then
        castbar = TukuiPlayerCastBar
    else
        castbar = TukuiTargetCastBar
     end

    local castbarpanel = CreateFrame("Frame", castbar:GetName().."_Panel", castbar)
    if unit == "player" then
        TukuiDB.CreatePanel(castbarpanel, config.player["width"], config.player["height"], "CENTER", UIParent, 0, config.player["yDistance"])
    else
        TukuiDB.CreatePanel(castbarpanel, config.target["width"], config.target["height"], "CENTER", UIParent, 0, config.target["height"])
    end
    
    castbar:SetPoint("TOPLEFT", castbarpanel, TukuiDB.Scale(2), TukuiDB.Scale(-2))
    castbar:SetPoint("BOTTOMRIGHT", castbarpanel, TukuiDB.Scale(-2), TukuiDB.Scale(2))

    castbar.time = TukuiDB.SetFontString(castbar, font1, 12)
    castbar.time:SetPoint("RIGHT", castbarpanel, "RIGHT", TukuiDB.Scale(-4), 0)
    castbar.time:SetTextColor(0.84, 0.75, 0.65)
    castbar.time:SetJustifyH("RIGHT")

    castbar.Text = TukuiDB.SetFontString(castbar, font1, 12)
    castbar.Text:SetPoint("LEFT", castbarpanel, "LEFT", TukuiDB.Scale(4), 0)
    castbar.Text:SetTextColor(0.84, 0.75, 0.65)

    if C["unitframes"].cbicons == true then
        if unit == "player" then
            castbar.button:SetPoint("LEFT", TukuiDB.Scale(-40), 0)
        elseif unit == "target" then
            castbar.button:SetPoint("RIGHT", TukuiDB.Scale(40), 0)
        end
    end
	
    if (unit == "player") then
        TukuiPlayerCastBar.Castbar = castbar    
        TukuiPlayerCastBar.Castbar.Time = castbar.time
        TukuiPlayerCastBar.Castbar.Icon = castbar.icon
		
		castbarpanel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		castbarpanel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		castbarpanel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	
		-- cast bar latency
		local normTex = TukuiCF["media"].normTex;
		if C["unitframes"].cblatency == true then
			castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
			castbar.safezone:SetTexture(normTex)
			--castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
			castbar.safezone:SetVertexColor(1, 0, 0, 0.50)
			castbar.SafeZone = castbar.safezone
		end		
    else
        TukuiTargetCastBar.Castbar = castbar
        TukuiTargetCastBar.Castbar.Time = castbar.time
        TukuiTargetCastBar.Castbar.Icon = castbar.icon
    end

    castbarpanel:RegisterEvent("ADDON_LOADED")
    castbarpanel:SetScript("OnEvent", function(self, event, ...)
		if (event == "ADDON_LOADED") then
			self:UnregisterEvent("ADDON_LOADED")
			
			castbarpanel:SetMovable(true)
			castbarpanel:EnableMouse(true)
			castbarpanel:SetScript("OnMouseDown", function(self)
				if button == "LeftButton" and not self.isMoving then
					self:StartMoving();
					self.isMoving = true;
				end
			end)
			castbarpanel:SetScript("OnMouseUp", function(self)
				if button == "LeftButton" and self.isMoving then
					self:StopMovingOrSizing();
					self.isMoving = false;
				end
			end)
			castbarpanel:SetScript("OnHide", function(self)
				if self.isMoving then
					self:StopMovingOrSizing();
					self.isMoving = false;
				end
			end)
		end
		
		if event == "UNIT_SPELLCAST_CHANNEL_START" then
			spell = select(2, ...)
			
			local ticks = channelingTicks[spell] or 0
			
			setBarTicks(ticks)			
		end		
		
		if (event == "UNIT_SPELLCAST_CHANNEL_STOP") then
			setBarTicks(0)
		end		
		
		if (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then
			setBarTicks(0)
		end		
    end)
end


if (config.separateplayer) then
    placeCastbar("player")
end

if (config.separatetarget) then
    placeCastbar("target")
end


do
    local castbarsUnlocked = false
    
    local function getPanelsForUnit(unit)
        local castbarpanel, castbar = nil
        
        if unit == "player" then
            castbarpanel = TukuiTargetCastBar_Panel
            castbar      = TukuiPlayerCastBar.Castbar
        elseif unit == "target" then
            castbarpanel = TukuiTargetCastBar_Panel
            castbar      = TukuiTargetCastBar.Castbar
        else
            print("Cannot get panels for unit: " .. unit)
            return;
        end
        
        return castbarpanel, castbar
    end
    
    local function unlockCastbarForUnit(unit)
        local castbarpanel, castbar = getPanelsForUnit(unit)
        
        castbarpanel:Show()
        castbar.Castbar.casting = true
        castbar.Castbar.max = 1000
        castbar.Castbar.duration = 1
        castbar.Castbar.delay = 0
        castbar.Castbar.Text:SetText(unit)
        castbar.Castbar:Show()
        
        castbarpanel:RegisterForDrag("LeftButton");
        castbarpanel:SetScript("OnDragStart", castbarpanel.StartMoving);
        castbarpanel:SetScript("OnDragStop", castbarpanel.StopMovingOrSizing);
    end
    
    local function lockCastbarForUnit(unit)
        local castbarpanel, castbar = getPanelsForUnit(unit)
        
        castbar.Castbar.casting = false
        castbarpanel:EnableMouse(false);
    end
    
    local function resetCastbars()
        local castbarpanel, _ = getPanelsForUnit("player")
        castbarpanel:SetPoint("CENTER", UIParent, 0, -200)
        castbarpanel, _ = getPanelsForUnit("target")
        castbarpanel:SetPoint("CENTER", UIParent, 0, -150)
        return
    end
    
    local function TUKUICASTBARLOCK(param)
        if param == "reset" then
            resetCastbars()
            return
        end
        
        if castbarsUnlocked == false then
            castbarsUnlocked = true
            
            if config.separateplayer then
                unlockCastbarForUnit("player")
            end
            
            if config.separatetarget then
                unlockCastbarForUnit("target")
            end
            
            print("Tukui castbar unlock")
        elseif castbarsUnlocked == true then
            if config.separateplayer then
                lockCastbarForUnit("player")
            end
            
            if config.separatetarget then
                lockCastbarForUnit("target")
            end
            
            castbarsUnlocked = false
            print("Tukui castbar lock")
        end
    end
    
    SLASH_TUKUICASTBAR1 = "/tcb"
    SlashCmdList["TUKUICASTBAR"] = TUKUICASTBARLOCK
end
