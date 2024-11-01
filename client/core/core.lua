local coreName = 'core'
if GetResourceState(coreName) ~= 'started' then
    error('The imported file from the chosen framework isn\'t starting')
    return
end

local retreiveStringIndexedData = require 'utils'.retreiveStringIndexedData
local characterData = nil

RegisterNetEvent('zeno:client:player:load', function(character)
    characterData = {
        data = character,
        job = {},
        gang = {},
    }

    if character.job ~= nil then
        characterData.job.name = character.job.slug
        characterData.job.level = character.job.role.slug
    end

    if character.gang ~= nil then
        characterData.gang.name = character.gang.slug
        characterData.gang.level = character.gang.role.slug
    end

    TriggerEvent('bl_bridge:client:playerLoaded')
end)

RegisterNetEvent('zeno:client:player:unload', function(source)
    characterData = nil
    TriggerEvent('bl_bridge:client:playerUnloaded')
end)

AddEventHandler('zeno:client:regionManager:playerUpdate', function(isPlayer, ped, index, state)
    if state ~= nil and isPlayer and characterData ~= nil then
        if state.job ~= nil and (characterData.job.name ~= state.job.slug or characterData.job.level ~= state.job.role.slug) then
            characterData.job.name = state.job.slug
            characterData.job.level = state.job.role.slug
            TriggerEvent('bl_bridge:client:jobUpdated', {
                name = state.job.slug,
                label = state.job.name,
                onDuty = true, -- Why does this need to be?
                isBoss = false, -- Why does this need this?
                grade = {
                    name = state.job.role.slug,
                    label = state.job.role.name,
                    salary = state.job.role.salary,
                },
            })
        end
        if state.gang ~= nil and (characterData.gang.name ~= state.gang.slug or characterData.gang.level ~= state.gang.role.slug) then
            characterData.gang.name = state.gang.slug
            characterData.gang.level = state.gang.role.slug
            TriggerEvent('bl_bridge:client:gangUpdated', {
                name = state.gang.slug,
                label = state.gang.name,
                isBoss = false, -- Why does this need this?
                grade = {
                    name = state.gang.role.slug,
                    label = state.gang.role.name,
                },
            })
        end
    end
end)


local Core = {}

function Core.getPlayerData()
    if characterData == nil then
        error('We dont have the character data to process this yet!', 2)
    end

    local year, month, day = characterData.data.date_of_birth:match("(%d+)-(%d+)-(%d+)")

    local data =  {
        cid = characterData.data.id,
        money = characterData.data.money or 0, -- total amount in inventory?
        inventory = characterData.data.items or {}, -- Why does it need this?
        firstName = characterData.data.firstname,
        lastName = characterData.data.lastname,
        phone = '000yamum123', -- Why do we need this?
        gender = characterData.data.gender == 1 and 'female' or 'male',
        dob = day .. '/' .. month .. '/' .. year,
    }

    if characterData.data.job == nil then

    else
        data.job = {
            name = characterData.data.job.slug,
            label = characterData.data.job.name,
            onDuty = true, -- Why does this need to be?
            isBoss = false, -- Why does this need this?
            grade = {
                name = characterData.data.job.role.slug,
                label = characterData.data.job.role.name,
                salary = characterData.data.job.role.salary,
            },
        }
    end

    if characterData.data.gang == nil then

    else
        data.gang = {
            name = characterData.data.gang.slug,
            label = characterData.data.gang.name,
            isBoss = false, -- Why does this need this?
            grade = {
                name = characterData.data.gang.role.slug,
                label = characterData.data.gang.role.name,
            },
        }
    end

    return data
end

function Core.playerLoaded()
    return characterData ~= nil
end

return Core
