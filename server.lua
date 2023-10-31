local participants = {}  -- Table to track players participating in the delivery race
local cooldownEndTime = 0  -- Timestamp for when the cooldown will end
local missionStartTime = nil

-- Function to check if the delivery job is available
function isDeliveryAvailable()
    local currentTime = os.time()
    if #participants >= 8 and currentTime < cooldownEndTime then
        return false  -- Job is on cooldown
    end
    return true  -- Job is available
end

-- Function to calculate remaining time
function calculateRemainingTime()
    if not missionStartTime then
        return 900  -- 15 minutes in seconds
    end
    local elapsedTime = os.time() - missionStartTime
    return 900 - elapsedTime
end

-- Function to calculate reward based on finishing position
function calculateReward(position, isLate)
    local baseReward = 50000
    local reward = baseReward

    if position == 1 then
        reward = baseReward * 2
    elseif position == 2 then
        reward = baseReward * 1.5
    elseif position == 3 then
        reward = baseReward * 1.25
    end

    if isLate then
        reward = reward * 0.9  -- Reduce the reward by 10% if the delivery was late
    end

    return reward
end

function startDeliveryMission(source)
    if not isDeliveryAvailable() then
        TriggerClientEvent('kotr:jobUnavailable', source)
        return
    end

    -- Set the mission start time if this is the first participant
    if #participants == 0 then
        missionStartTime = os.time()
    end

    -- Calculate the remaining time
    local remainingTime = calculateRemainingTime()

    -- Randomly select a drop-off location
    local dropoff = {x = 2023.3757324219, y = 4972.2622070313, z = 41.225715637207}
    TriggerClientEvent('kotr:markDropoff', source, dropoff, remainingTime)
    TriggerClientEvent('kotr:updateParticipantsCount', -1, #participants)
    RegisterNetEvent('kotr:updateParticipantsCount')



    table.insert(participants, source)

    -- If 8 players have taken the job, initiate the cooldown
    if #participants == 8 then
        cooldownEndTime = os.time() + (30 * 60)  -- Set the cooldown end time to 30 minutes from now
    end
end

function completeDelivery(source, position, isLate)
    local reward = calculateReward(position, isLate)

    -- Award the player with the calculated reward
    -- vRP.giveMoney({source, reward})  -- Example: Adjust based on your VRP version and functions

    -- Remove the player from the participants list
    for i, playerId in ipairs(participants) do
        if playerId == source then
            table.remove(participants, i)
			print("gata treaba sefu")
            break
        end
    end
end

RegisterNetEvent('kotr:startDeliveryJob')
AddEventHandler('kotr:startDeliveryJob', function()
    isInDeliveryJob = true
	startDeliveryMission(source)
    print("Job started:", isInDeliveryJob)  -- This should print "Job started: true"
end)

RegisterNetEvent('kotr:requestDelivery')
AddEventHandler('kotr:requestDelivery', function()
    startDeliveryMission(source)
end)

RegisterNetEvent('kotr:completeDelivery')
AddEventHandler('kotr:completeDelivery', function(position, isLate)
    completeDelivery(source, position, isLate)
end)

RegisterNetEvent('kotr:forfeitDelivery')
AddEventHandler('kotr:forfeitDelivery', function()
    for i, playerId in ipairs(participants) do
        if playerId == source then
            table.remove(participants, i)
            break
        end
    end
end)

RegisterNetEvent('kotr:requestRemainingTime')
AddEventHandler('kotr:requestRemainingTime', function()
    local remainingTime = calculateRemainingTime()
    TriggerClientEvent('kotr:showRemainingTime', source, remainingTime)
end)
