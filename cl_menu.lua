local function createWeatherItems(menu, actualWeather)
    for _, weather in pairs(Config.Weathers) do
        local item = NativeUI.CreateItem(weather.name, weather.desc)
        if (weather.value == actualWeather) then
            item:SetRightBadge(BadgeStyle.Tick)
        end
        menu:AddItem(item)
    end
end

local function createMainItems(menuPool, menu, transition, state)
    local syncWeatherMenu = menuPool:AddSubMenu(menu, "Weather Menu", "~b~Control weather like a god!")

    local weatherTransition = NativeUI.CreateCheckboxItem("Weather Transition", transition, "Wish you a smooth weather transition.")
    menu:AddItem(weatherTransition)

    menuPool:MouseControlsEnabled(false)
    menuPool:MouseEdgeEnabled(false)
    menuPool:ControlDisablingEnabled(false)

    return syncWeatherMenu, weatherTransition
end

local function createMainMenu(menuPool, transition)
    local syncMainMenu = NativeUI.CreateMenu("Sync Menu", "~b~Manage the weather and time!")
    menuPool:Add(syncMainMenu)

    local syncWeatherMenu, weatherTransition = createMainItems(menuPool, syncMainMenu, transition)

    syncMainMenu.OnCheckboxChange = function(sender, item, checked)
        if (item == weatherTransition) then
            transition = checked
        end

        if (item == weatherRandom) then
            if (checked) then
                TriggerServerEvent("jph_sync:enablerandomweather")
            else
                TriggerServerEvent("jph_sync:disablerandomweather")
            end
        end
    end

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

    menuPool:RefreshIndex()

    return syncMainMenu, syncWeatherMenu
end

local function executeMainMenu()
    Citizen.CreateThread(function()
        local menuPool = NativeUI.CreatePool()
        local transition = true

        local syncMainMenu, syncWeatherMenu = createMainMenu(menuPool, transition)

        AddEventHandler("jph_sync:setweather", function(weather, index)
            syncWeatherMenu:Clear()
            createWeatherItems(syncWeatherMenu, weather)
            syncWeatherMenu:CurrentSelection(index)
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