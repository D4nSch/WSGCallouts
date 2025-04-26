-- SavedVariables setup
if not WSGCalloutsDB then WSGCalloutsDB = {} end
WSGCalloutsDB.locked = WSGCalloutsDB.locked ~= false -- default true
WSGCalloutsDB.posX = WSGCalloutsDB.posX or 400
WSGCalloutsDB.posY = WSGCalloutsDB.posY or 300

-- Clamp helper
local function ClampToScreen(x, y)
    local screenW = UIParent:GetWidth()
    local screenH = UIParent:GetHeight()

    x = math.max(0, math.min(x or 0, screenW - 220))
    y = math.max(0, math.min(y or 0, screenH - 160))

    return x, y
end

local function SaveFramePosition()
    local _, _, _, x, y = WSGCalloutsFrame:GetPoint()
    x, y = ClampToScreen(x, y)
    WSGCalloutsDB.posX = x
    WSGCalloutsDB.posY = y
end

local function ToggleLock()
    WSGCalloutsDB.locked = not WSGCalloutsDB.locked
    WSGCalloutsFrame:EnableMouse(not WSGCalloutsDB.locked)

    if WSGCalloutsDB.locked then
        WSGCalloutsFrame:SetBackdrop({
            tile = false,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF5733WSGCallouts|r locked")
    else
        WSGCalloutsFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = false,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        WSGCalloutsFrame:SetBackdropColor(0, 0, 0, 0.75)
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF5733WSGCallouts|r unlocked")
    end
end

-- constants
local wsgPositions = {"GY", "FENCE", "TOT", "RAMP", "CONN", "BALC", "ROOF", "TUNNEL", "FR", "LEAF", "ZERK"}
local numberWsgPositions = table.getn(wsgPositions)

-- Layout constants
local buttonWidth = 62
local buttonHeight = 22
local spacing = 2
local buttonsPerRow = 2
local totalWidth = buttonsPerRow * buttonWidth + (buttonsPerRow - 1) * spacing
local frameWidth = totalWidth + 10
local frameHeight = (numberWsgPositions+3) * buttonHeight + (numberWsgPositions+3) * spacing + 20

-- Create main frame
local WSGCalloutsFrame = CreateFrame("Frame", "WSGCalloutsFrame", UIParent)
WSGCalloutsFrame:SetClampedToScreen(true)
WSGCalloutsFrame:SetWidth(frameWidth)
WSGCalloutsFrame:SetHeight(frameHeight)

local x, y = ClampToScreen(WSGCalloutsDB.posX, WSGCalloutsDB.posY)
WSGCalloutsFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)

WSGCalloutsFrame:SetMovable(true)
WSGCalloutsFrame:RegisterForDrag("LeftButton")
WSGCalloutsFrame:SetScript("OnDragStart", function()
    if not WSGCalloutsDB.locked then WSGCalloutsFrame:StartMoving() end
end)
WSGCalloutsFrame:SetScript("OnDragStop", function()
    WSGCalloutsFrame:StopMovingOrSizing()
    SaveFramePosition()
end)

WSGCalloutsFrame:SetBackdrop({
    tile = false,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
WSGCalloutsFrame:SetBackdropColor(0, 0, 0, 0.0)

-- Title text
local title = WSGCalloutsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", WSGCalloutsFrame, "TOP", 0, 0)
title:SetText("EFC Callouts")
title:SetTextColor(1, 1, 1)

local function HandleCall(faction, position)
    local pos = ""

    if position == "GY" then
        pos = "GRAVEYARD"
    elseif position == "FENCE" then
        pos = "FENCE"
    elseif position == "TOT" then
        pos = "TOP OF TUNNEL (TOT)"
    elseif position == "RAMP" then
        pos = "RAMP"
    elseif position == "CONN" then
        pos = "CONNECTOR"
    elseif position == "BALC" then
        pos = "BALCONY"
    elseif position == "ROOF" then
        pos = "ROOF"
    elseif position == "TUNNEL" then
        pos = "TUNNEL"
    elseif position == "FR" then
        pos = "FLAG ROOM"
    elseif position == "LEAF" then
        pos = "LEAF HUT"
    elseif position == "ZERK" then
        pos = "ZERK HUT"
    elseif position == "WEST" then
        pos = "WEST"
    elseif position == "MID" then
        pos = "MID"
    elseif position == "EAST" then
        pos = "EAST"
    else
        pos = "UNKNOWN"
    end

    if position == "REPICK" or position == "CAP" then
        --DEFAULT_CHAT_FRAME:AddMessage(">>> "..position.." <<<")
        SendChatMessage(">>> "..position.." <<<", "BATTLEGROUND")
    else
        if faction ~= nil then
            --DEFAULT_CHAT_FRAME:AddMessage("Enemy flag carry (EFC) position: >>> "..tostring(faction).." "..pos.." <<<")
            SendChatMessage("EFC position: >>> "..tostring(faction).." "..pos.." <<<", "BATTLEGROUND")
        else
            --DEFAULT_CHAT_FRAME:AddMessage("Enemy flag carry (EFC) position: >>> "..pos.." <<<")
            SendChatMessage("EFC position: >>> "..pos.." <<<", "BATTLEGROUND")
        end
    end
end

local framePaddingX = (frameWidth - totalWidth) / 2
for _,faction in pairs({"ALLIANCE", "HORDE"}) do
    for i,position in pairs(wsgPositions) do
        local btn = CreateFrame("Button", "WSGCalloutsButtons"..faction..i, WSGCalloutsFrame, "UIPanelButtonTemplate")
        local buttonFaction = faction
        local buttonPostion = position
        btn:SetWidth(buttonWidth)
        btn:SetHeight(buttonHeight)
        btn:SetText(position)
        btn:GetFontString():SetPoint("LEFT", 4, 0)
        btn:GetFontString():SetPoint("RIGHT", -4, 0)

        if faction == "ALLIANCE" then
            btn:SetNormalTexture("Interface\\AddOns\\WSGCallouts\\assets\\normal_blue_texture.tga")
            btn:GetNormalTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
            btn:SetPushedTexture("Interface\\AddOns\\WSGCallouts\\assets\\pressed_blue_texture.tga")
            btn:GetPushedTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
            btn:SetHighlightTexture("Interface\\AddOns\\WSGCallouts\\assets\\hover_blue_texture.tga")
            btn:GetHighlightTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
        end

        -- Position buttons in columns based on faction
        local xOffset = 0
        local yOffset = 0
        if faction == "HORDE" then
            xOffset = buttonWidth + spacing -- Add extra spacing between columns

            -- Calculate how many rows the Alliance buttons take up
            local allianceRows = math.ceil(numberWsgPositions / buttonsPerRow)
            -- Add extra spacing between the Alliance and Horde sections
            yOffset = allianceRows * (buttonHeight + spacing) + 3
        end

        local x = framePaddingX + xOffset
        local y = -18 - (i - 1) * (buttonHeight + spacing)

        btn:SetPoint("TOPLEFT", WSGCalloutsFrame, "TOPLEFT", x, y)
        btn:SetScript("OnClick", (function()
            return function() HandleCall(buttonFaction, buttonPostion) end
        end)(i))
    end
end

-- WEST/MID/EAST button
local midPositions = {"WEST", "MID", "EAST"}
for i,position in pairs(midPositions) do
    local midBtn = CreateFrame("Button", "WSGCalloutsButtons"..position, WSGCalloutsFrame, "UIPanelButtonTemplate")
    local buttonPostion = position
    midBtn:SetWidth(totalWidth/3)
    midBtn:SetHeight(buttonHeight)
    midBtn:SetNormalTexture("Interface\\AddOns\\WSGCallouts\\assets\\normal_orange_texture.tga")
    midBtn:GetNormalTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
    midBtn:SetPushedTexture("Interface\\AddOns\\WSGCallouts\\assets\\pressed_orange_texture.tga")
    midBtn:GetPushedTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
    midBtn:SetHighlightTexture("Interface\\AddOns\\WSGCallouts\\assets\\hover_orange_texture.tga")
    midBtn:GetHighlightTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
    midBtn:SetText(position)
    midBtn:SetPoint("BOTTOM", WSGCalloutsFrame, "BOTTOM", (totalWidth/3)*(i-2), ((buttonHeight*2+spacing*4)))
    midBtn:SetScript("OnClick", (function()
        return function() HandleCall(nil, buttonPostion) end
    end)(i))
end

-- REPICK button
local repickBtn = CreateFrame("Button", "WSGCalloutsButtonsRepick", WSGCalloutsFrame, "UIPanelButtonTemplate")
repickBtn:SetWidth(totalWidth)
repickBtn:SetHeight(buttonHeight)
repickBtn:SetNormalTexture("Interface\\AddOns\\WSGCallouts\\assets\\normal_green_texture.tga")
repickBtn:GetNormalTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
repickBtn:SetPushedTexture("Interface\\AddOns\\WSGCallouts\\assets\\pressed_green_texture.tga")
repickBtn:GetPushedTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
repickBtn:SetHighlightTexture("Interface\\AddOns\\WSGCallouts\\assets\\hover_green_texture.tga")
repickBtn:GetHighlightTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
repickBtn:SetText("REPICK FLAG")
repickBtn:SetPoint("BOTTOM", WSGCalloutsFrame, "BOTTOM", 0, ((buttonHeight+spacing*3)))
repickBtn:SetScript("OnClick", (function()
   return function() HandleCall(nil, "REPICK") end
end)(i))

-- CAP button
local capBtn = CreateFrame("Button", "WSGCalloutsButtonsCap", WSGCalloutsFrame, "UIPanelButtonTemplate")
capBtn:SetWidth(totalWidth)
capBtn:SetHeight(buttonHeight)
capBtn:SetNormalTexture("Interface\\AddOns\\WSGCallouts\\assets\\normal_green_texture.tga")
capBtn:GetNormalTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
capBtn:SetPushedTexture("Interface\\AddOns\\WSGCallouts\\assets\\pressed_green_texture.tga")
capBtn:GetPushedTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
capBtn:SetHighlightTexture("Interface\\AddOns\\WSGCallouts\\assets\\hover_green_texture.tga")
capBtn:GetHighlightTexture():SetTexCoord( 0, 0.625, 0, 0.6875 )
capBtn:SetText("CAP FLAG")
capBtn:SetPoint("BOTTOM", WSGCalloutsFrame, "BOTTOM", 0, spacing*2)
capBtn:SetScript("OnClick", (function()
    return function() HandleCall(nil, "CAP") end
end)(i))

--Show/hide in Warsong Gulch
local function UpdateVisibility()
    local zoneName = GetRealZoneText()
    if zoneName == "Warsong Gulch" then
        WSGCalloutsFrame:Show()
    else
        WSGCalloutsFrame:Hide()
    end
end

local function initialText()
    DEFAULT_CHAT_FRAME:AddMessage("|cffFF5733WSGCallouts|r was initialized. /WSGCallouts or /wsgc for options. Have fun in WSG! - Urtica")
end


--Event handling (no more lock logic here — handled above)
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    initialText()
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    UpdateVisibility()
end)

-- Slash command
SLASH_WSGCallouts1 = "/WSGCallouts"
SLASH_WSGCallouts2 = "/wsgc"
SlashCmdList["WSGCallouts"] = function(arg)
    if arg == "show" then
        if WSGCalloutsFrame:IsShown() then
            WSGCalloutsFrame:Hide()
        else
            WSGCalloutsFrame:Show()
        end
    elseif arg == "lock" then
        ToggleLock()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF5733WSGCallouts|r commands: (e.g.: /wsgc show)")
        DEFAULT_CHAT_FRAME:AddMessage("'show' - Hide/Display the frame")
        DEFAULT_CHAT_FRAME:AddMessage("'lock' - Lock/Unlock the frame")
    end
end

WSGCalloutsFrame:Hide()