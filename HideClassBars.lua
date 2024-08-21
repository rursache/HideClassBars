-- Hide Class Bars

local addonName, addon = ...

-- Configuration
local defaultConfig = {
    warrior_stance_bar_hide = true,
    priest_stance_bar_hide = true,
    rogue_stance_bar_hide = true,
    druid_stance_bar_hide = true,
    paladin_stance_bar_hide = true
}

-- Initialize saved variables
HideClassBarsDB = HideClassBarsDB or defaultConfig

-- Main functionality
function addon:UpdateVisibility()
    local playerClass = select(2, UnitClass("player"))
    
    if (HideClassBarsDB.warrior_stance_bar_hide and playerClass == "WARRIOR")
    or (HideClassBarsDB.priest_stance_bar_hide and playerClass == "PRIEST")
    or (HideClassBarsDB.rogue_stance_bar_hide and playerClass == "ROGUE")
    or (HideClassBarsDB.druid_stance_bar_hide and playerClass == "DRUID")
    or (HideClassBarsDB.paladin_stance_bar_hide and playerClass == "PALADIN") then
        RegisterStateDriver(StanceBar, "visibility", "hide")
    elseif playerClass == "WARRIOR"
    or playerClass == "PRIEST"
    or playerClass == "ROGUE"
    or playerClass == "DRUID"
    or playerClass == "PALADIN" then
        RegisterStateDriver(StanceBar, "visibility", "show")
    end
end

-- Create settings using the new Settings API
local function InitializeSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory("Hide Class Bars")

    local function OnSettingChanged(setting, value)
        addon:UpdateVisibility()
    end

    local function CreateCheckbox(name, label, tooltip)
        local variable = "HideClassBars_" .. name
        local setting = Settings.RegisterAddOnSetting(category, name, name, HideClassBarsDB, type(defaultConfig[name]), label, defaultConfig[name])
        setting:SetValueChangedCallback(OnSettingChanged)

        Settings.CreateCheckbox(category, setting, tooltip)
    end
    
    CreateCheckbox("warrior_stance_bar_hide", "Warrior Stance Bar", "Hides the warrior stance bar")
    CreateCheckbox("priest_stance_bar_hide", "Priest Shadow Form Bar", "Hides the shadowform bar")
    CreateCheckbox("rogue_stance_bar_hide", "Rogue Stealth Bar", "Hides the rogue stealth bar")
    CreateCheckbox("druid_stance_bar_hide", "Druid Shapeshift Bar", "Hides the druid shapeshift bar")
    CreateCheckbox("paladin_stance_bar_hide", "Paladin Aura Bar", "Hides the paladin aura bar")
	
	addon.settingsCategoryID = category.ID
    
    Settings.RegisterAddOnCategory(category)
end

-- Event handler
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        InitializeSettings()
    elseif event == "PLAYER_LOGIN" then
        addon:UpdateVisibility()
    end
end)

-- Slash command
SLASH_HIDECLASSBARS1 = "/hideclassbars"
SlashCmdList["HIDECLASSBARS"] = function(msg)
    if addon.settingsCategoryID then
        Settings.OpenToCategory(addon.settingsCategoryID)
    else
        print("Hide Class Bars: Settings not yet initialized. Please try again in a moment.")
    end
end