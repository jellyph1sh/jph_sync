local activeWeather = ""
local isRandomWeather = true

local function getRandomWeather(weathers)
    return weathers[math.random(1, #weathers)]
end

local function sendWeatherToClients(weather, index, transition)
    TriggerClientEvent("jph_sync:setweather", -1, weather, index, transition)
end

local function synchronizeWeather()
    local weathersValues = {}

    for _, weather in pairs(Config.Weathers) do
        table.insert(weathersValues, weather.value)
    end
    activeWeather = getRandomWeather(weathersValues)
    sendWeatherToClients(activeWeather, 1, false)
end

local function randomWeather()
    Citizen.CreateThread(function()
        while isRandomWeather do
            synchronizeWeather()

            Citizen.Wait(math.random(10000, 20000))
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

RegisterServerEvent("jph_sync:setrandomweatherstate")
AddEventHandler("jph_sync:setrandomweatherstate", function(newState)
    isRandomWeather = newState
    TriggerClientEvent("jph_sync:setrandomweatherstate", -1, newState)
end)

randomWeather()