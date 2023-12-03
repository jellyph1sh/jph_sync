local function synchronizeTime()
    Citizen.CreateThread(function()
        while true do
            local year, month, day, hour, minute, second = GetUtcTime()
            SetClockDate(day, month, year)
            NetworkOverrideClockTime(hour, minute, second)

            Citizen.Wait(0)
        end
    end)
end

local function loadTextureDict(textureDict)
    RequestStreamedTextureDict(textureDict, true)

    while (not HasStreamedTextureDictLoaded(textureDict)) do
        RequestStreamedTextureDict(textureDict, true)
        Wait(50)
    end
end

local function notify(textureDict, title, subtitle, icon, msg)
    loadTextureDict(textureDict)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, icon, title, subtitle)
    EndTextCommandThefeedPostTicker(true, true)
    SetStreamedTextureDictAsNoLongerNeeded(textureDict)
end

RegisterNetEvent("jph_sync:setweather")
AddEventHandler("jph_sync:setweather", function(weather, _, transition)
    if (transition == nil or transition == false) then
        SetWeatherTypeNowPersist(weather)
    else
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypeOvertimePersist(weather, Config.TransitionTime)
    end
end)

RegisterNetEvent("jph_sync:notifyweather")
AddEventHandler("jph_sync:notifyweather", function(weather, time)
    notify(Config.NotificationTexture, "Weather Report", "Event", 1, "The weather will turn " .. weather .. " in " .. time .. " minutes.")
end)

synchronizeTime()
TriggerServerEvent("jph_sync:getweather")
