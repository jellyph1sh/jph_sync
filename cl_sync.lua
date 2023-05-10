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

RegisterNetEvent("jph_sync:setweather")
AddEventHandler("jph_sync:setweather", function(weather, _, transition)
    if (transition == nil or transition == false) then
        SetWeatherTypeNowPersist(weather)
    else
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypeOvertimePersist(weather, 30.0)
    end
end)

synchronizeTime()
TriggerServerEvent("jph_sync:getweather")
