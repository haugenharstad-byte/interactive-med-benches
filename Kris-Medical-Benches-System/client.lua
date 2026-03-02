local isUsing = false
local currentEntity = nil

-- Lie down function
local function lieDown(entity, data)
    if isUsing then return end
    local ped = PlayerPedId()

    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity) + data.headingOffset
    local z = coords.z + (data.zOffset or 0.4)

    SetEntityCoords(ped, coords.x, coords.y, z)
    SetEntityHeading(ped, heading)
    FreezeEntityPosition(ped, true)

    TaskStartScenarioAtPosition(ped, data.anim, coords.x, coords.y, z, heading, 0, true, true)

    currentEntity = entity
    isUsing = true
end

-- Stand up function
local function standUp()
    if not isUsing then return end
    local ped = PlayerPedId()

    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)

    currentEntity = nil
    isUsing = false
end

-- Register ox_target for all objects
CreateThread(function()
    for _, obj in pairs(Config.Objects) do
        exports.ox_target:addModel(obj.model, {
            {
                name = 'lie_down',
                icon = 'fas fa-bed',
                label = 'Lie down',
                distance = Config.TargetDistance,
                canInteract = function() return not isUsing end,
                onSelect = function(data)
                    lieDown(data.entity, obj)
                end
            },
            {
                name = 'stand_up',
                icon = 'fas fa-person-walking',
                label = 'Stand up',
                distance = Config.TargetDistance,
                canInteract = function() return isUsing end,
                onSelect = function()
                    standUp()
                end
            }
        })
    end
end)

-- Press X to stand up
CreateThread(function()
    while true do
        if isUsing then
            Wait(0)
            if IsControlJustPressed(0, 73) then -- X key
                standUp()
            end
        else
            Wait(500)
        end
    end
end)