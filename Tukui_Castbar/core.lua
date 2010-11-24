-- Standalone Castbar for Tukui by Krevlorne
-- All credits to Tukz and Syne. I just copied most of the stuff shamelessly

if ( TukuiUF ~= true and ( TukuiCF == nil or TukuiCF["unitframes"] == nil or not TukuiCF["unitframes"]["enable"] ) ) then return; end

local db = TukuiCF["unitframes"]
if (db.unitcastbar ~= true) then return; end

local function placeCastbar(unit)
    local font1 = TukuiCF["media"].uffont
    local castbar = nil
    
    if (unit == "player") then
        castbar = oUF_Tukz_player_Castbar
    else
        castbar = oUF_Tukz_target_Castbar
    end

    local castbarpanel = CreateFrame("Frame", nil, castbar)
    if unit == "player" then
        TukuiDB.CreatePanel(castbarpanel, 250, 21, "CENTER", UiParent, 0, -200)
    else
        TukuiDB.CreatePanel(castbarpanel, 250, 21, "CENTER", UiParent, 0, -150)
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
end

placeCastbar("player");
placeCastbar("target");
