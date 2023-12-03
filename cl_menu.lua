local transition = true
local random = true

local function createWeatherItems(menu, actualWeather)
    for _, weather in pairs(Config.Weathers) do
        local item = NativeUI.CreateItem(weather.name, weather.desc)
        if (weather.value == actualWeather) then
            item:SetRightBadge(BadgeStyle.Tick)
        end
        menu:AddItem(item)
    end
end

local function createCheckboxItems(menu)
    local weatherTransition = NativeUI.CreateCheckboxItem("Weather Transition", transition, "Wish you a smooth weather transition.")
    menu:AddItem(weatherTransition)

    local weatherRandom = NativeUI.CreateCheckboxItem("Weather Random", random, "Wish you disable weather random.")
    menu:AddItem(weatherRandom)

    return weatherTransition, weatherRandom
end

local function createMainItems(menuPool, menu)
    local syncWeatherMenu = menuPool:AddSubMenu(menu, "Weather Menu", "~b~Control weather like a god!")

    local weatherTransition, weatherRandom = createCheckboxItems(menu)

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

    menu.OnCheckboxChange = function(sender, item, checked)
        if (item == weatherTransition) then
            transition = checked
        end

        if (item == weatherRandom) then
            random = checked
            if (random) then
                TriggerServerEvent("jph_sync:enablerandomweather")
            else
                TriggerServerEvent("jph_sync:disablerandomweather")
            end
        end
    end

    menuPool:MouseControlsEnabled(false)
    menuPool:MouseEdgeEnabled(false)
    menuPool:ControlDisablingEnabled(false)

    return syncWeatherMenu, weatherTransition, weatherRandom
end

local function createMainMenu(menuPool)
    local syncMainMenu = NativeUI.CreateMenu("Sync Menu", "~b~Manage the weather and time!")
    menuPool:Add(syncMainMenu)

    local syncWeatherMenu, weatherTransition, weatherRandom = createMainItems(menuPool, syncMainMenu)

    menuPool:RefreshIndex()

    return syncMainMenu, syncWeatherMenu
end

local function executeMainMenu()
    Citizen.CreateThread(function()
        local menuPool = NativeUI.CreatePool()

        local syncMainMenu, syncWeatherMenu = createMainMenu(menuPool)

        AddEventHandler("jph_sync:setweather", function(weather, index)
            syncWeatherMenu:Clear()
            createWeatherItems(syncWeatherMenu, weather)
            syncWeatherMenu:CurrentSelection(index)
        end)

        RegisterNetEvent("jph_sync:setweatherrandom")
        AddEventHandler("jph_sync:setweatherrandom", function(state)
            random = state
            syncMainMenu:Clear()
            syncWeatherMenu = createMainItems(menuPool, syncMainMenu)
            TriggerServerEvent("jph_sync:getweather")
        end)

        while true do
            menuPool:ProcessMenus()
            if (IsControlJustPressed(1, 170)) then
                syncMainMenu:Visible(not syncMainMenu:Visible())
            end
            Citizen.Wait(0)
        end
    end)
end

executeMainMenu()