local activeWeather = ""

local function getRandomWeather(weathers)
    return weathers[math.random(1, #weathers)]
end

local function sendWeatherToClients(weather, index, transition)
    TriggerClientEvent("jph_sync:setweather", -1, weather, index, transition)
end

local function synchronizeWeather()
    local weathersValues = {}

    for _, weather in pairs(Config.RandomWeathers) do
        table.insert(weathersValues, weather.value)
    end
    activeWeather = getRandomWeather(weathersValues)
    sendWeatherToClients(activeWeather, 1, true)
end

local function randomWeather()
    Citizen.CreateThread(function()
        local randomWeather = true

        while randomWeather do
            synchronizeWeather()

            Citizen.Wait(math.random(Config.WeatherRandomTimeMin*100, Config.WeatherRandomTimeMax*100))
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
    sendWeatherToClients(activeWeather, index, transition)
end)

RegisterServerEvent("jph_sync:enablerandomweather")
AddEventHandler("jph_sync:enablerandomweather", function()
    randomWeather()
    TriggerClientEvent("jph_sync:staterandomweather", -1, true)
end)

randomWeather()