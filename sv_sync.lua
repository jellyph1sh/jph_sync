local activeWeather = nil

local function synchronizeWeather()
    local weathersValues = {}
    local weathersNames = {}

    for _, weather in pairs(Config.RandomWeathers) do
        table.insert(weathersValues, weather.value)
        table.insert(weathersNames, weather.name)
    end
    local index = math.random(1, #weathersValues)
    activeWeather = weathersValues[index]
    print(activeWeather)
    TriggerClientEvent("jph_sync:setweather", -1, activeWeather, 1, false)
end

local function randomWeather()
    Citizen.CreateThread(function()

        local random = true

        RegisterServerEvent("jph_sync:disablerandomweather")
        AddEventHandler("jph_sync:disablerandomweather", function()
            random = false
            TriggerClientEvent("jph_sync:setweatherrandom", -1, false)
        end)
        
        if (activeWeather == nil) then
            synchronizeWeather()
        end

        local weathersValues = {}
        local weathersNames = {}

        for _, weather in pairs(Config.RandomWeathers) do
            table.insert(weathersValues, weather.value)
            table.insert(weathersNames, weather.name)
        end

        Wait(500)

        while random do
            local index = math.random(1, #weathersValues)
            local time = math.random(Config.WeatherRandomTimeMin, Config.WeatherRandomTimeMax)
            TriggerClientEvent("jph_sync:notifyweather", -1, weathersNames[index], math.floor(time / 60))
            Citizen.Wait(time * 1000)
            activeWeather = weathersValues[index]
            TriggerClientEvent("jph_sync:setweather", -1, activeWeather, 1, true)
        end
    end)
end

RegisterServerEvent("jph_sync:getweather", function()
    local src = source
    TriggerClientEvent("jph_sync:setweather", src, activeWeather)
end)

RegisterServerEvent("jph_sync:changeweather")
AddEventHandler("jph_sync:changeweather", function(weather, index, transition)
    activeWeather = weather
    TriggerClientEvent("jph_sync:setweather", -1, activeWeather, index, transition)
end)

RegisterServerEvent("jph_sync:enablerandomweather")
AddEventHandler("jph_sync:enablerandomweather", function()
    randomWeather()
    TriggerClientEvent("jph_sync:setweatherrandom", -1, true)
end)

randomWeather()