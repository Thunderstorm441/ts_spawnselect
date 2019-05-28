--[[
    Author: Thunderstorm441
    https://github.com/Thunderstorm441/ts_spawnselect
]]--
--CONFIG
-- spawnX, spawnY, spawnZ are the coordinates at which the player will spawn. camX, camY, camZ are the coordinates at which the camera will be. 
local spawnPoints = {
    {name="Airport", spawnX=-1041.62,spawnY=-2737.6,spawnZ=13.8371,camX=-943.909,camY=-2709.79,camZ=51.3575},
    {name="Pier", spawnX=-1845.17,spawnY=-1195.38,spawnZ=19.18,camX=-1959.24,camY=-1289.54,camZ=74.8558},
    {name="Tequi-la-la", spawnX=-566.2,spawnY=295.83,spawnZ=83.03,camX=-521.855,camY=222.185,camZ=98.2189},
    {name="Legion Square", spawnX=178.1,spawnY=-940.43,spawnZ=30.1,camX=80.1,camY=-1019.57,camZ=92.1},
    {name="Sandy Shores", spawnX=1860.68,spawnY=3851.2,spawnZ=32.99,camX=1939.992,camY=3842.664,camZ=68.86},
    {name="Paleto Bay", spawnX=-150.53,spawnY=6416.903,spawnZ=31.91,camX=-222.438,camY=6429.05,camZ=65.16},
}
--END OF CONFIG

local selectedSpawnPoint = 1
local spawnPointNames = {}

_menuPool = MenuPool.New()
spawnSelectMenu = UIMenu.New("Spawn", "~b~Select a spawnpoint", 1350, 0)
_menuPool:Add(spawnSelectMenu)
_menuPool:ControlDisablingEnabled(true)
_menuPool:MouseControlsEnabled(false)

function createLocationList(data)
    for k, v in pairs(data) do
        table.insert(spawnPointNames, v.name)
    end
end

function addLocations(menu)
    local locationItem = UIMenuListItem.New("Location", spawnPointNames, 1)
    menu:AddItem(locationItem)
    menu.OnListChange = function(sender, item, index)
        if locationItem == item then
            selectedSpawnPoint = index
            drawCam(index)
        end
    end
end

function addSpawnButton(menu)
    local spawnButton = UIMenuItem.New("Spawn", "Confirm Location Selection And Spawn.")
    menu:AddItem(spawnButton)
    menu.OnItemSelect = function(sender, item, index)
        if item == spawnButton then
            spawnPlayer()
        end
    end
end

function drawCam(index)
    local playerPed = GetPlayerPed(-1)
    local spawnCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamFov(spawnCam, 90.0)
    RenderScriptCams(true, true, 3, 1, 0)
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do
        Citizen.Wait(100)
    end
    SetEntityCoords(playerPed, spawnPoints[index].spawnX, spawnPoints[index].spawnY, spawnPoints[index].spawnZ)
    SetCamCoord(spawnCam, spawnPoints[index].camX, spawnPoints[index].camY, spawnPoints[index].camZ)
    PointCamAtCoord(spawnCam, spawnPoints[index].spawnX, spawnPoints[index].spawnY, spawnPoints[index].spawnZ)
    DoScreenFadeIn(800)
end

function setupPlayer()
    SetEntityVisible(GetPlayerPed(-1), false)
    SetPlayerInvincible(PlayerId(), true)
    FreezeEntityPosition(GetPlayerPed(-1), true) 
    spawnSelectMenu:Visible(true)
end

function spawnPlayer()
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do
        Citizen.Wait(100)
    end
    SetEntityVisible(GetPlayerPed(-1), true)
    SetPlayerInvincible(PlayerId(), false)
    FreezeEntityPosition(GetPlayerPed(-1), false) 
    RenderScriptCams(false, false, 3, 1, 0)
    DestroyAllCams(true)
    spawnSelectMenu:Visible(false)
    DoScreenFadeIn(800)
end

AddEventHandler('playerSpawned', function(spawn)
    createLocationList(spawnPoints)
    addLocations(spawnSelectMenu)
    addSpawnButton(spawnSelectMenu)
    _menuPool:RefreshIndex()
    setupPlayer()
    drawCam(1)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
    end
end)