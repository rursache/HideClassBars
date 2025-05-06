-- Hide Class Bars and Extras

local addonName, addon = ...

-- Configuration
local defaultConfig = {
    warrior_stance_bar_hide         = true,
    priest_stance_bar_hide          = true,
    rogue_stance_bar_hide           = true,
    druid_stance_bar_hide           = true,
    paladin_stance_bar_hide         = true,
	
    vehicle_seats_frame_hide        = true,
}

-- Initialize saved variables
HideClassBarsDB = HideClassBarsDB or defaultConfig

-- Main functionality
function addon:UpdateVisibility()
    local playerClass = select(2, UnitClass("player"))

    -- Class Stance Bars
    if (HideClassBarsDB.warrior_stance_bar_hide and playerClass == "WARRIOR")
    or (HideClassBarsDB.priest_stance_bar_hide  and playerClass == "PRIEST")
    or (HideClassBarsDB.rogue_stance_bar_hide   and playerClass == "ROGUE")
    or (HideClassBarsDB.druid_stance_bar_hide   and playerClass == "DRUID")
    or (HideClassBarsDB.paladin_stance_bar_hide and playerClass == "PALADIN") then
        RegisterStateDriver(StanceBar, "visibility", "hide")
    elseif playerClass == "WARRIOR"
        or playerClass == "PRIEST"
        or playerClass == "ROGUE"
        or playerClass == "DRUID"
        or playerClass == "PALADIN" then
        RegisterStateDriver(StanceBar, "visibility", "show")
    end

    -- Vehicle Seats Frame
    if HideClassBarsDB.vehicle_seats_frame_hide then
        RegisterStateDriver(VehicleSeatIndicator, "visibility", "hide")
    else
        RegisterStateDriver(VehicleSeatIndicator, "visibility", "show")
    end
end

-- Create settings using the new Settings API
local function InitializeSettings()
    -- Main category
    local category, layout = Settings.RegisterVerticalLayoutCategory("Hide Class Bars")

    local function OnSettingChanged(setting, value)
        addon:UpdateVisibility()
    end

    local function CreateCheckboxOn(cat, name, label, tooltip)
        local setting = Settings.RegisterAddOnSetting(
            cat,
            name,
            name,
            HideClassBarsDB,
            type(defaultConfig[name]),
            label,
            defaultConfig[name]
        )
        setting:SetValueChangedCallback(OnSettingChanged)
        Settings.CreateCheckbox(cat, setting, tooltip)
    end

    -- Class Bars group
    CreateCheckboxOn(category, "warrior_stance_bar_hide", "Warrior Stance Bar",    "Hides the warrior stance bar when checked")
    CreateCheckboxOn(category, "priest_stance_bar_hide",  "Priest Shadow Form Bar","Hides the shadowform bar when checked")
    CreateCheckboxOn(category, "rogue_stance_bar_hide",   "Rogue Stealth Bar",     "Hides the rogue stealth bar when checked")
    CreateCheckboxOn(category, "druid_stance_bar_hide",   "Druid Shapeshift Bar",  "Hides the druid shapeshift bar when checked")
    CreateCheckboxOn(category, "paladin_stance_bar_hide", "Paladin Aura Bar",      "Hides the paladin aura bar when checked")

    -- Extras Options subcategory
    local extraCat, extraLayout = Settings.RegisterVerticalLayoutSubcategory(
        category,
        "Extras",
        "extra_options"
    )
    CreateCheckboxOn(extraCat, "vehicle_seats_frame_hide", "Vehicle Seats Frame", "Hides the vehicle seats frame when checked")

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

-- Slash command to open settings
SLASH_HIDECLASSBARS1 = "/hideclassbars"
SlashCmdList["HIDECLASSBARS"] = function(msg)
    if addon.settingsCategoryID then
        Settings.OpenToCategory(addon.settingsCategoryID)
    else
        print("Hide Class Bars: Settings not yet initialized. Please try again in a moment.")
    end
end
