local function createWeathersList()
    local weathersNames = {}

    for _, weather in pairs(Config.Weathers) do
        table.insert(weathersNames, weather.name)
    end

    local weathersList = NativeUI.CreateListItem("Weathers", weathersNames, 1)
    return weathersList
end

local function createMenu(menuPool)
    local weatherMenu = NativeUI.CreateMenu("Weather Menu", "~b~Control weather like a god!")
    menuPool:Add(weatherMenu)

    local weathersList = createWeathersList()
    weatherMenu:AddItem(weathersList)
    weatherMenu.OnListChange = function(sender, item, index)
        if (item == weathersList) then
            local weatherName = item:IndexToItem(index)
            TriggerServerEvent("jph_sync:changeweather", weatherName)
        end
    end

    _menuPool:RefreshIndex()
end