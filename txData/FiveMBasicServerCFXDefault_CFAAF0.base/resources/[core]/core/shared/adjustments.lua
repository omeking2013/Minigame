Config.DisableHealthRegeneration = true -- Player will no longer regenerate health
Config.DisableVehicleRewards = true -- Disables Player Receiving weapons from vehicles
Config.DisableNPCDrops = true -- stops NPCs from dropping weapons on death
Config.DisableDispatchServices = true -- Disable Dispatch services
Config.DisableScenarios = true -- Disable Scenarios
Config.DisableAimAssist = true -- disables AIM assist (mainly on controllers)
Config.DisableVehicleSeatShuff = true -- Disables vehicle seat shuff
Config.DisableDisplayAmmo = false -- Disable ammunition display
Config.EnablePVP = true -- Allow Player to player combat
Config.EnableWantedLevel = false -- Use Normal GTA wanted Level?

Config.RemoveHudComponents = {
    [1] = false, --WANTED_STARS,
    [2] = false, --WEAPON_ICON
    [3] = false, --CASH
    [4] = false, --MP_CASH
    [5] = false, --MP_MESSAGE
    [6] = true, --VEHICLE_NAME
    [7] = true, -- AREA_NAME
    [8] = true, -- VEHICLE_CLASS
    [9] = true, --STREET_NAME
    [10] = false, --HELP_TEXT
    [11] = false, --FLOATING_HELP_TEXT_1
    [12] = false, --FLOATING_HELP_TEXT_2
    [13] = false, --CASH_CHANGE
    [14] = false, --RETICLE
    [15] = false, --SUBTITLE_TEXT
    [16] = false, --RADIO_STATIONS
    [17] = false, --SAVING_GAME,
    [18] = false, --GAME_STREAM
    [19] = false, --WEAPON_WHEEL
    [20] = false, --WEAPON_WHEEL_STATS
    [21] = false, --HUD_COMPONENTS
    [22] = false, --HUD_WEAPONS
}

Config.Multipliers = {
    pedDensity = 0.0,
    scenarioPedDensityInterior = 0.0,
    scenarioPedDensityExterior = 0.0,
    ambientVehicleRange = 0.0,
    parkedVehicleDensity = 0.0,
    randomVehicleDensity = 0.0,
    vehicleDensity = 0.0
}

Config.CustomAIPlates = "KOCOMP." -- Custom plates for AI vehicles