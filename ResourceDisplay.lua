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

local TICK_INTERVAL = 2.0
local DRINK_TICK_INTERVAL = 2.0
local TICK_SPARK_COLOR = { 1, 1, 1, 0.7 }
local DRINK_SPARK_COLOR = { 0.4, 0.8, 1, 0.8 }

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

-- Overlay frame for sparks (not clipped by StatusBar fill)
local sparkOverlay = CreateFrame("Frame", nil, manaBar)
sparkOverlay:SetAllPoints(manaBar)
sparkOverlay:SetFrameLevel(manaBar:GetFrameLevel() + 2)

-- Tick spark (MP5 regen)
local tickSpark = sparkOverlay:CreateTexture(nil, "OVERLAY")
tickSpark:SetSize(2, BAR_HEIGHT)
tickSpark:SetColorTexture(unpack(TICK_SPARK_COLOR))
tickSpark:Hide()

-- Drink spark
local drinkSpark = sparkOverlay:CreateTexture(nil, "OVERLAY")
drinkSpark:SetSize(2, BAR_HEIGHT)
drinkSpark:SetColorTexture(unpack(DRINK_SPARK_COLOR))
drinkSpark:Hide()

-- Tick tracking state: two independent clocks
local lastRegenTick = nil  -- global server tick (spirit/MP5 regen)
local lastDrinkTick = nil  -- per-buff timer (drinking)
local lastMana = 0
local isDrinking = false


local function IsDrinking()
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        if not name then break end
        if name == "Drink" or name == "Food & Drink" then
            return true
        end
    end
    return false
end

local function UpdateSpark(spark, progress)
    local xOffset = math.min(math.max(progress, 0), 1) * BAR_WIDTH
    spark:ClearAllPoints()
    spark:SetPoint("LEFT", sparkOverlay, "LEFT", xOffset - 1, 0)
end

manaBar:SetScript("OnUpdate", function(self, elapsed)
    local now = GetTime()
    local cur = UnitPower("player", 0)
    local max = UnitPowerMax("player", 0)

    -- Regen spark: visible when not drinking, mana not full, and clock is fresh
    if lastRegenTick and not isDrinking and max > 0 and cur < max
       and (now - lastRegenTick) < (TICK_INTERVAL * 2 + 0.5) then
        local progress = ((now - lastRegenTick) / TICK_INTERVAL) % 1
        UpdateSpark(tickSpark, progress)
        tickSpark:Show()
    else
        tickSpark:Hide()
    end

    -- Drink spark: visible when drinking and clock is fresh
    if lastDrinkTick and isDrinking
       and (now - lastDrinkTick) < (DRINK_TICK_INTERVAL * 2 + 0.5) then
        local progress = ((now - lastDrinkTick) / DRINK_TICK_INTERVAL) % 1
        UpdateSpark(drinkSpark, progress)
        drinkSpark:Show()
    else
        drinkSpark:Hide()
    end
end)

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

events:RegisterEvent("UNIT_AURA")

events:SetScript("OnEvent", function(self, event, unit, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        UpdateHealth()
        UpdateMana()
        lastMana = UnitPower("player", 0)
        isDrinking = IsDrinking()
        return
    end

    if unit and unit ~= "player" then return end

    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        UpdateHealth()
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        local curMana = UnitPower("player", 0)
        local wasDrinkingPower = isDrinking
        isDrinking = IsDrinking()
        -- Handle drink transitions here (UNIT_POWER_UPDATE fires before UNIT_AURA)
        if not wasDrinkingPower and isDrinking then
            if not lastDrinkTick then
                lastDrinkTick = GetTime()
            end
        elseif wasDrinkingPower and not isDrinking then
            local now = GetTime()
            if lastRegenTick then
                -- Fast-forward regen clock to preserve phase through drinking
                local elapsed = now - lastRegenTick
                local ticksPassed = math.floor(elapsed / TICK_INTERVAL)
                lastRegenTick = lastRegenTick + ticksPassed * TICK_INTERVAL
            else
                lastRegenTick = lastDrinkTick or now
            end
            lastDrinkTick = nil
        end
        if curMana > lastMana then
            local now = GetTime()
            local delta = curMana - lastMana

            if isDrinking then
                lastDrinkTick = now
            else
                lastRegenTick = now
            end
        end
        lastMana = curMana
        UpdateMana()
    elseif event == "UNIT_AURA" then
        local wasDrinking = isDrinking
        isDrinking = IsDrinking()
        if not wasDrinking and isDrinking then
            lastDrinkTick = GetTime()
        elseif wasDrinking and not isDrinking then
            local now = GetTime()
            if lastRegenTick then
                local elapsed = now - lastRegenTick
                local ticksPassed = math.floor(elapsed / TICK_INTERVAL)
                lastRegenTick = lastRegenTick + ticksPassed * TICK_INTERVAL
            else
                lastRegenTick = lastDrinkTick or now
            end
            lastDrinkTick = nil
        end
    end
end)
