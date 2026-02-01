local addonName, ns = ...

-- Configuration
local BAR_WIDTH = 160
local BAR_HEIGHT = 11
local BAR_SPACING = 2
local BAR_OFFSET_Y = -145  -- below center of screen (player position)
local BG_ALPHA = 0.4
local BORDER_COLOR = { 0, 0, 0, 0.8 }

local HEALTH_COLOR = { 0.3, 0.7, 0.3 }
local MANA_COLOR = { 0.3, 0.45, 0.8 }
local BAR_ALPHA = 0.7

-- Utility: create a single resource bar
local function CreateBar(parent, yOffset, r, g, b)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetSize(BAR_WIDTH, BAR_HEIGHT)
    bar:SetPoint("TOP", parent, "TOP", 0, yOffset)
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar:SetStatusBarColor(r, g, b, BAR_ALPHA)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)

    -- Background
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, BG_ALPHA)

    -- Border
    local border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(unpack(BORDER_COLOR))

    -- Percentage text
    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER")
    text:SetFont(text:GetFont(), 11, "OUTLINE")
    text:SetTextColor(1, 1, 1, 0.9)
    bar.text = text

    return bar
end

-- Main anchor frame
local anchor = CreateFrame("Frame", "ResourceDisplayAnchor", UIParent)
anchor:SetSize(BAR_WIDTH, BAR_HEIGHT * 2 + BAR_SPACING)
anchor:SetPoint("CENTER", UIParent, "CENTER", 0, BAR_OFFSET_Y)
anchor:SetFrameStrata("LOW")

-- Create bars
local healthBar = CreateBar(anchor, 0, unpack(HEALTH_COLOR))
local manaBar = CreateBar(anchor, -(BAR_HEIGHT + BAR_SPACING), unpack(MANA_COLOR))

-- Update logic
local function UpdateHealth()
    local max = UnitHealthMax("player")
    if max == 0 then return end
    local cur = UnitHealth("player")
    healthBar:SetMinMaxValues(0, max)
    healthBar:SetValue(cur)
    healthBar.text:SetText(cur)
    if cur / max < 0.2 then
        healthBar.text:SetTextColor(1, 0.2, 0.2, 0.9)
    else
        healthBar.text:SetTextColor(1, 1, 1, 0.9)
    end
end

local function UpdateMana()
    local max = UnitPowerMax("player", 0)
    if max == 0 then
        manaBar:Hide()
        return
    end
    manaBar:Show()
    local cur = UnitPower("player", 0)
    manaBar:SetMinMaxValues(0, max)
    manaBar:SetValue(cur)
    manaBar.text:SetText(cur)
    if cur / max < 0.2 then
        manaBar.text:SetTextColor(1, 0.2, 0.2, 0.9)
    else
        manaBar.text:SetTextColor(1, 1, 1, 0.9)
    end
end

-- Event handling
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("UNIT_HEALTH")
events:RegisterEvent("UNIT_MAXHEALTH")
events:RegisterEvent("UNIT_POWER_UPDATE")
events:RegisterEvent("UNIT_MAXPOWER")
events:RegisterEvent("UNIT_DISPLAYPOWER")

events:SetScript("OnEvent", function(self, event, unit, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        UpdateHealth()
        UpdateMana()
        return
    end

    if unit and unit ~= "player" then return end

    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        UpdateHealth()
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        UpdateMana()
    end
end)
