local loadstring = function(...)
    local res, err = loadstring(...)
    if err and vape then vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert') end
    return res
end
local isfile = isfile or function(file)
    local suc, res = pcall(function() return readfile(file) end)
    return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
    if not isfile(path) then
        local suc, res = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/Ancient-Master/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true) end)
        if not suc or res == '404: Not Found' then error(res) end
        if path:find('.lua') then res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

local vape = shared.vape

local function startHitmanTargetSkipper(config)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    
    -- Default settings
    local TARGET_FILTER = {
        SkipIfLevelBelow = config.SkipIfLevelBelow or 0,
        DesiredPlayer = config.DesiredPlayer or nil
    }

    -- Find Hitman Remote
    local HitmanRemote = ReplicatedStorage:WaitForChild("Features"):WaitForChild("Hitman"):WaitForChild("CurrentTarget")
    local HitmanShared = require(ReplicatedStorage.Features.Hitman.HitmanShared)

    local function getCurrentTarget()
        local target = HitmanShared.getCurrentTarget()
        if target then
            return {
                player = target.player,
                level = target.level,
                credits = target.credits,
                exp = target.exp
            }
        end
        return nil
    end

    -- Auto-Skip Bad Targets
    local function shouldSkipTarget(target)
        if not target then return false end
        
        -- Skip if level too low
        if TARGET_FILTER.SkipIfLevelBelow > 0 and target.level < TARGET_FILTER.SkipIfLevelBelow then
            return true, "Low Level (" .. target.player.Name .. " | Lv. " .. target.level .. ")"
        end
        
        -- Skip if not desired player
        if TARGET_FILTER.DesiredPlayer and target.player.Name ~= TARGET_FILTER.DesiredPlayer then
            return true, "Not Desired Player (" .. target.player.Name .. ")"
        end
        
        return false
    end

    -- Main Loop
    task.spawn(function()
        while getgenv().HitmanTarget do
            -- Wait for a new target
            local target = getCurrentTarget()

            -- First check if target exists and has a player
            if not target or not target.player then
                vape:CreateNotification('Vape',"⚠️ No target available, waiting...",1, 'warning')
                HitmanShared.removeTarget()
                HitmanShared.findNewTarget()
                continue
            end

            -- Check if we should skip
            local skip, reason = shouldSkipTarget(target)
            if skip then
                vape:CreateNotification('Vape','⏩ Skipping Target: ' .. reason,1, 'warning')
                
                HitmanShared.removeTarget()
                HitmanShared.findNewTarget()
            else
                -- Safe to access player.Name since we checked above
                vape:CreateNotification('Vape','✅ Accepted Target: ' .. target.player.Name .. " (Lv. " .. target.level .. ")",3)
                break
            end
        end
    end)
end

local HitmanModule = vape.Categories.Combat:CreateModule({
    Name = 'Hitman Target Set',
    Function = function(callback)
		getgenv().HitmanTargetPlayer = callback
        if callback then
            startHitmanTargetSkipper({
                SkipIfLevelBelow = 0,
                DesiredPlayer = getgenv().HitmanTargetPlayer
            })
        else
            -- Add disable functionality here if needed
            vape:CreateNotification('Vape', "Hitman Target Skipper disabled", 5)
        end
    end,
    Tooltip = 'Automatically skips unwanted hitman targets'
})

local HitmanModuleTextbox = HitmanModule:CreateTextBox({
    Name = 'Target Player',
    Function = function(enter)
        getgenv().HitmanTargetPlayer = enter
    end,
    Placeholder = 'Player Name',
    Tooltip = 'Enter the name of the player you want as your target.'
})