local actualWeather = ""
local isRandomWeather = true

local function createWeatherButtons(menu)
    for _, weather in pairs(Config.Weathers) do
        local item = NativeUI.CreateItem(weather.name, weather.desc)
        if (weather.value == actualWeather) then
            item:SetRightBadge(BadgeStyle.Tick)
        end
        menu:AddItem(item)
    end
end

local function createMainMenuItems(menuPool, menu)
    local syncWeatherMenu = menuPool:AddSubMenu(menu, "Weather Menu", "~b~Control weather like a god!")
    createWeatherButtons(syncWeatherMenu)
    local weatherTransition = NativeUI.CreateCheckboxItem("Weather Transition", transition, "Wish you a smooth weather transition.")
    menu:AddItem(weatherTransition)

    local weatherRandom = NativeUI.CreateCheckboxItem("Random Weather", isRandomWeather, "Wish you a some random weather.")
    menu:AddItem(weatherRandom)

    return syncWeatherMenu, weatherTransition, weatherRandom
end

local function createMenu(menuPool)
    local syncMainMenu = NativeUI.CreateMenu("Sync Menu", "~b~Manage the weather and time!")
    menuPool:Add(syncMainMenu)

    local transition = true

    local syncWeatherMenu, weatherTransition, weatherRandom = createMainMenuItems(menuPool, syncMainMenu)

    syncWeatherMenu.OnItemSelect = function(sender, item, index)
        if (item.RightBadge.Badge == BadgeStyle.None) then
            local weatherName = item.Text:Text()
            for _, weather in pairs(Config.Weathers) do
                if (weather.name == weatherName) then
                    TriggerServerEvent("jph_sync:changeweather", weather.value, index - 1, transition)
                end
            end
        end
    end

    syncMainMenu.OnCheckboxChange = function(sender, item, checked)
        if (item == weatherTransition) then
            transition = checked
        end
        if (item == weatherRandom) then
            isRandomWeather = checked
            TriggerServerEvent("jph_sync:setrandomweatherstate", isRandomWeather)
        end
    end

    menuPool:RefreshIndex()

    return syncMainMenu, syncWeatherMenu
end

local function executeMenu()
    Citizen.CreateThread(function()
        local menuPool = NativeUI.CreatePool()

        local syncMainMenu, syncWeatherMenu = createMenu(menuPool)

        AddEventHandler("jph_sync:setweather", function(weather, index)
            actualWeather = weather
            syncWeatherMenu:Clear()
            createWeatherButtons(syncWeatherMenu)
            syncWeatherMenu:CurrentSelection(index)
        end)

        RegisterNetEvent("jph_sync:setrandomweatherstate")
        AddEventHandler("jph_sync:setrandomweatherstate", function(newState)
            isRandomWeather = newState
            syncMainMenu:Clear()
            createMainMenuItems(menuPool, syncMainMenu)
        end)

        menuPool:MouseControlsEnabled(false)
        menuPool:MouseEdgeEnabled(false)
        menuPool:ControlDisablingEnabled(false)

        while true do
            menuPool:ProcessMenus()
            if (IsControlJustPressed(1, 170)) then
                syncMainMenu:Visible(not syncMainMenu:Visible())
            end
            Citizen.Wait(0)
        end
    end)
end

executeMenu()