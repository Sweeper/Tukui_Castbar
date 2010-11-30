-- Standalone Castbar for Tukui by Krevlorne @ EU-Ulduar
-- Credits to Tukz, Syne, Elv22 and all other great people of the Tukui community.

if ( TukuiUF ~= true and ( TukuiCF == nil or TukuiCF["unitframes"] == nil or not TukuiCF["unitframes"]["enable"] ) ) then return; end

local db = TukuiCF["unitframes"]
if (db.unitcastbar ~= true) then return; end

local addon, ns=...
config = ns.config

local function placeCastbar(unit)
    local font1 = TukuiCF["media"].uffont
    local castbar = nil
    local castbarpanel = nil
    
    if (unit == "player") then
        castbar = oUF_Tukz_player_Castbar
    else
        castbar = oUF_Tukz_target_Castbar
     end

    local castbarpanel = CreateFrame("Frame", castbar:GetName().."_Panel", castbar)
    if unit == "player" then
        TukuiDB.CreatePanel(castbarpanel, 250, 21, "CENTER", UIParent, 0, -200)
    else
        TukuiDB.CreatePanel(castbarpanel, 250, 21, "CENTER", UIParent, 0, -150)
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

    if db.cbicons == true then
        if unit == "player" then
            castbar.button:SetPoint("LEFT", TukuiDB.Scale(-40), 0)
        elseif unit == "target" then
            castbar.button:SetPoint("RIGHT", TukuiDB.Scale(40), 0)
        end
    end
    
    -- cast bar latency
    local normTex = TukuiCF["media"].normTex;
    if db.cblatency == true then
        castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
        castbar.safezone:SetTexture(normTex)
        castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
        castbar.SafeZone = castbar.safezone
    end

    if (unit == "player") then
        oUF_Tukz_player_Castbar.Castbar = castbar    
        oUF_Tukz_player_Castbar.Castbar.Time = castbar.time
        oUF_Tukz_player_Castbar.Castbar.Icon = castbar.icon
    else
        oUF_Tukz_target_Castbar.Castbar = castbar
        oUF_Tukz_target_Castbar.Castbar.Time = castbar.time
        oUF_Tukz_target_Castbar.Castbar.Icon = castbar.icon
    end

    castbarpanel:RegisterEvent("ADDON_LOADED")
    castbarpanel:SetScript("OnEvent", function(self, event, addon)
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
            castbarpanel = oUF_Tukz_player_Castbar_Panel
            castbar      = oUF_Tukz_player_Castbar.Castbar
        elseif unit == "target" then
            castbarpanel = oUF_Tukz_target_Castbar_Panel
            castbar      = oUF_Tukz_target_Castbar.Castbar
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
