local activeWeather = ""

local function isInWeathersList(weathers, arg)
    for idx, weather in pairs(weathers) do
        if weather == arg then
            return true
        end
    end
    return false
end

local function getRandomWeather(weathers)
    return weathers[math.random(1, #weathers)]
end

local function sendWeatherToClients(weather)
    TriggerClientEvent("jph_sync:setweather", -1, weather)
end

local function synchronizeWeather()
    Citizen.CreateThread(function()
        while true do
            activeWeather = getRandomWeather(Config.Weathers)
            sendWeatherToClients(activeWeather)
            Config.WeatherUpdate = math.random(600, 1200)

            Citizen.Wait(Config.WeatherUpdate * 1000)
        end
    end)
    print("~g~JPH_SYNC INITIALIZED!")
end

local function sendChatMessage(src, prefix, msg, choosenColor)
    TriggerClientEvent("chat:addMessage", src, {
        args = {
            prefix,
            msg
        },
        color = choosenColor
    })
end

RegisterServerEvent("jph_sync:getweather", function()
    local src = source
    TriggerClientEvent("jph_sync:setweather", src, activeWeather)
end)

RegisterServerEvent("jph_sync:changeweather")
AddEventHandler("jph_sync:changeweather", function(weather)
    
end)

RegisterCommand("weather", function(src, args)
    if #args == 0 or #args > 1 then
        sendChatMessage(src, "[ERROR]", "Bad arguments!", {255, 0, 0})
        return
    end
    if not isInWeathersList(Config.Weathers, args[1]) then
        sendChatMessage(src, "[ERROR]", "Unknow weather!", {255, 0, 0})
        return
    end

    activeWeather = args[1]
    sendWeatherToClients(activeWeather)
end, true)

synchronizeWeather()
