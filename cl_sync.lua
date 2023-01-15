local function synchronizeTime()
    Citizen.CreateThread(function()
        while true do
            local year, month, day, hour, minute, second = GetUtcTime()
            SetClockDate(day, month, year)
            NetworkOverrideClockTime(hour + 1, minute, second)

            Citizen.Wait(0)
        end
    end)
end

RegisterNetEvent("jph_sync:setweather")
AddEventHandler("jph_sync:setweather", function(weather)
    SetWeatherTypeOvertimePersist(weather, Config.TransitionTime)
end)

TriggerEvent('chat:addSuggestion', '/weather', 'Set weather', {{ name="weather", help="CLEAR/CLEARING/CLOUDS/EXTRASUNNY/FOGGY/NEUTRAL/OVERCAST/RAIN/SMOG/THUNDER"}})

synchronizeTime()
TriggerServerEvent("jph_sync:getweather")
