local startPoint = {x = 2055.9204101563, y = 4996.7216796875, z = 40.669498443604}
local deliveryStartTime = nil
local playerBlips = {}
local isInDeliveryJob = false
local startCheckpoint = nil
local deliveryCheckpoint = nil
local remainingTime = 15 * 60  -- 15 minutes in seconds
local availableTime = remainingTime
local participantsCount = 0

local allowedVehicles = {
    "phantom",
    "packer",
    "tanker",
    -- ... other allowed vehicles
}

function IsPlayerInAllowedVehicle()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model)

    for _, allowedModel in ipairs(allowedVehicles) do
        if modelName == allowedModel then
            return true
        end
    end

    return false
end

function setupStartCheckpoint()
    local startBlip = AddBlipForCoord(startPoint.x, startPoint.y, startPoint.z)
    SetBlipSprite(startBlip, 1)  -- Change the number for a different icon
    SetBlipColour(startBlip, 2)  -- Change the number for a different color
    SetBlipAsShortRange(startBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery Start")
    EndTextCommandSetBlipName(startBlip)

    startCheckpoint = CreateCheckpoint(1, startPoint.x, startPoint.y, startPoint.z, 0.0, 0.0, 0.0, 2.0, 0, 255, 0, 255, 0)
    SetCheckpointCylinderHeight(startCheckpoint, 3.0, 3.0, 2.0)
end

function displayTimer()
    local minutes = math.floor(remainingTime / 60)
    local seconds = remainingTime % 60

    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.5)
    SetTextColour(128, 128, 255, 255)  -- RGB + Alpha
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(string.format("Time left: %02d:%02d", minutes, seconds))
    DrawText(0.4, 0.05)  -- Adjust these values to change the position of the timer on the screen
end

function displayJobTime(remainingTime)
    if remainingTime then
        local minutes = math.floor(remainingTime / 60)
        local seconds = remainingTime % 60

        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.0, 0.5)
        SetTextColour(255, 255, 255, 255)  -- RGB + Alpha
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(string.format("Available Time for Job: %02d:%02d", minutes, seconds))
        DrawText(0.4, 0.05)  -- Adjust these values to change the position of the timer on the screen
    end
end

function displayParticipantsCount()
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 255)  -- RGB + Alpha
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(string.format("Participants: %d", participantsCount))
    DrawText(0.4, 0.1)  -- Adjust these values to change the position on the screen
end

RegisterNetEvent('kotr:markDropoff')
AddEventHandler('kotr:markDropoff', function(dropoff, timeLeft)
    -- Blip for the end location
    local endBlip = AddBlipForCoord(dropoff.x, dropoff.y, dropoff.z)
    SetBlipSprite(endBlip, 1)  -- Change the number for a different icon
    SetBlipColour(endBlip, 1)  -- Change the number for a different color
    SetBlipAsShortRange(endBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery End")
    EndTextCommandSetBlipName(endBlip)

    DeleteCheckpoint(startCheckpoint)

    deliveryCheckpoint = CreateCheckpoint(3, dropoff.x, dropoff.y, dropoff.z, 0.0, 0.0, 0.0, 2.0, 255, 0, 0, 255, 0)
    SetCheckpointCylinderHeight(deliveryCheckpoint, 3.0, 3.0, 2.0)

    deliveryStartTime = GetGameTimer()  -- Get the current game time in milliseconds
    remainingTime = timeLeft

    Citizen.CreateThread(function()
        while isInDeliveryJob do
            Citizen.Wait(1000)  -- Wait for 1 second
            
            remainingTime = remainingTime - 1  -- Deduct one second from the remaining time
            
            if remainingTime <= 0 then
                TriggerServerEvent('kotr:completeDelivery', position, true)  -- Inform the server that the delivery was late because time ran out
                DeleteCheckpoint(deliveryCheckpoint)
                deliveryCheckpoint = nil
                isInDeliveryJob = false
                remainingTime = 15 * 60  -- Reset the timer for future deliveries
            end
        end
    end)
end)

Citizen.CreateThread(function()
    setupStartCheckpoint()  -- Set up the start checkpoint when the script loads

    while true do
        Citizen.Wait(0)  -- Wait for each frame
        
        local playerPos = GetEntityCoords(PlayerPedId())
        local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, startPoint.x, startPoint.y, startPoint.z)

        if distance < 5.0 and not isInDeliveryJob then
            DisplayHelpText("Press ~INPUT_CONTEXT~ to start the King of the Road job.")  -- This displays a hint to press E

            if IsControlJustPressed(0, 38) then  -- 38 is the key code for the "E" key (INPUT_CONTEXT)
                TriggerServerEvent('kotr:requestRemainingTime')
                TriggerServerEvent('kotr:startDeliveryJob', source)
                print(isInDeliveryJob)
            end

            if dropoff then
                local playerPos = GetEntityCoords(PlayerPedId())
                local distanceToDropoff = Vdist(playerPos.x, playerPos.y, playerPos.z, dropoff.x, dropoff.y, dropoff.z)
                
                if distanceToDropoff < 5.0 and isInDeliveryJob then
                    TriggerServerEvent('kotr:completeDelivery', source)
                end
            end

            displayAvailableTime = true
        else
            displayAvailableTime = false
        end

        if isInDeliveryJob then
            displayParticipantsCount()
            displayTimer()
        elseif displayAvailableTime then
            displayJobTime(availableTime)
        end
    end
end)

RegisterNetEvent('kotr:jobUnavailable')
AddEventHandler('kotr:jobUnavailable', function()
    ShowNotification("The delivery job is currently unavailable. Please try again later.")
end)

RegisterNetEvent('kotr:showRemainingTime')
AddEventHandler('kotr:showRemainingTime', function(timeLeft)
    availableTime = timeLeft
end)

RegisterNetEvent('kotr:updateParticipantsCount')
AddEventHandler('kotr:updateParticipantsCount', function(count)
    participantsCount = count
end)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function DisplayHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end
