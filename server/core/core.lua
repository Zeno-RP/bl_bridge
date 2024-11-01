local Core = {}
local Utils = require 'utils'
local retreiveStringIndexedData = Utils.retreiveStringIndexedData
local merge = Utils.table_merge
local inventoryFunctions = Framework.inventory

RegisterNetEvent('zeno:server:player:load', function(source, character)
    TriggerEvent('bl_bridge:server:playerLoaded', source, character)
end)

AddEventHandler('core:Server:OnMoneyChange', function(src, moneyType, amount, operation, reason)
    TriggerEvent('bl_bridge:server:updateMoney', src, moneyType, amount, operation)
end)

-- local playerFunctionsOverride = {
--     Functions = {
--         getBalance = {
--             originalMethod = 'GetMoney',
--         },
--         removeBalance = {
--             originalMethod = 'RemoveMoney',
--         },
--         addBalance = {
--             originalMethod = 'AddMoney',
--         },
--         setBalance = {
--             originalMethod = 'SetMoney',
--         },
--         setJob = {
--             originalMethod = 'SetJob',
--         },
--     },
--     PlayerData = {
--         job = {
--             originalMethod = 'job',
--             modifier = {
--                 executeFunc = true,
--                 effect = function(originalFun)
--                     local job = originalFun
--                     return {
--                         name = state.job.slug,
--                         label = state.job.name,
--                         onDuty = true, -- Why does this need to be?
--                         isBoss = false, -- Why does this need this?
--                         type = job.type, 
--                         grade = { name = job.grade.level, label = job.grade.name, salary = job.payment } 
--                         }
--                 end
--             }
--         },
--         gang = {
--             originalMethod = 'gang',
--             modifier = {
--                 executeFunc = true,
--                 effect = function(data)
--                     local gang = data
--                     return {name = gang.name, label = gang.label, isBoss = gang.isboss, grade = {name = gang.grade.level, label = gang.grade.label}}
--                 end
--             }
--         },
--         charinfo = {
--             originalMethod = 'charinfo',
--             modifier = {
--                 executeFunc = true,
--                 effect = function(data)
--                     return {firstname = data.firstname, lastname = data.lastname}
--                 end
--             }
--         },
--         name = {
--             originalMethod = 'name',
--         },
--         id = {
--             originalMethod = 'citizenid',
--         },
--         gender = {
--             originalMethod = 'charinfo',
--             modifier = {
--                 executeFunc = true,
--                 effect = function(data)
--                     local gender = data.gender
--                     gender = gender == 1 and 'female' or 'male'
--                     return gender
--                 end
--             }
--         },
--         dob = {
--             originalMethod = 'charinfo',
--             modifier = {
--                 executeFunc = true,
--                 effect = function(data)
--                     local year, month, day = data.birthdate:match("(%d+)-(%d+)-(%d+)")
--                     return ('%s/%s/%s'):format(month, day, year) -- DD/MM/YYYY
--                 end
--             }
--         },
--         items = {
--             originalMethod = 'items',
--         },
--     }
-- }

function Core.players()
    local latch = promise.new()
    local data = {}

    exports.core:call(
        'getPlayerManager():getPlayers',
        function (players)
            print('players', json.encode(players))
            latch:resolve()
        end
    )

    -- for k, v in ipairs(shared.getPlayers()) do
    --     local jobInfo = v.jobInfo
    --     data[k] = {
    --         job = {
    --             name = jobInfo.name, 
    --             label = jobInfo.label, 
    --             onDuty = jobInfo.isJob, 
    --             isBoss = true, 
    --             grade = {name = jobInfo.rank, label = jobInfo.rankName, salary = 0}},
    --             charinfo = { firstname = v.firstname, lastname = v.lastname }
    --     }
    -- end

    Citizen.Await(latch)
    return data
end

function Core.CommandAdd(name, permission, cb, suggestion, flags)
    print('WHY????', 'Core.CommandAdd', name)
    -- RegisterCommand(name, cb, permission)
end

function Core.GetPlayer(src)
    local latch = promise.new()
    local data = {}

    exports.core:call(
        'getPlayerManager():getPlayer',
        function (player)
            local year, month, day = player.character.dateOfBirth:match("(%d+)-(%d+)-(%d+)")
            data = {
                charinfo = {
                    firstname = player.character.firstname,
                    lastname = player.character.lastname,
                },
                name = player.character.fullname,
                id = player.character.id,
                gender = player.character.gender == 1 and 'female' or 'male',
                dob = day .. '/' .. month .. '/' .. year,
            }

            -- TODO jobs and gangs????

            -- job = {
            --     originalMethod = 'getJob',
            --     modifier = {
            --         executeFunc = true,
            --         effect = function(originalFun)
            --             local _, jobInfo = originalFun()
            --             return {
            --                 name = jobInfo.name,
            --                 label = jobInfo.label,
            --                 onDuty = jobInfo.isJob,
            --                 isBoss = true,
            --                 grade = {name = jobInfo.rank, label = jobInfo.rankName, salary = 0}
            --             }
            --         end
            --     }
            -- },


            latch:resolve()
        end,
        src
    )

    return data
end

Core.RegisterUsableItem = Framework.inventory.registerUsableItem or function(name, cb)
    print('WHY????', 'Core.RegisterUsableItem', name)
end

function Core.hasPerms(...)
    return false
end

return Core