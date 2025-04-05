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
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local vape = shared.vape
local HitmanModule
local Hitmantextbox
local HitmanTargetEnabled = false
local HitmanTargetPlayer = nil
local originalPosition = nil
local activeThread = nil
local threadShouldStop = false

local function startHitmanTargetSkipper(config)
    -- Stop any existing thread
    if activeThread then
        threadShouldStop = true
        while activeThread do
            task.wait()
        end
    end

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

    local function shouldSkipTarget(target)
        -- [Previous implementation remains the same...]
    end

    -- Create a new thread
    threadShouldStop = false
    activeThread = task.spawn(function()
        while HitmanTargetEnabled and not threadShouldStop do
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end
            
            -- Store original position if not already stored
            if not originalPosition then
                originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
            
            -- Teleport to hitman location
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(125.482315, 254.5, -749.594482, -0.00281787151, 1.3361479e-07, 0.999996006, 1.39850187e-10, 1, -1.33614932e-07, -0.999996006, -2.3666008e-10, -0.00281787151)
            
            -- Get current target
            local target = getCurrentTarget()

            if not target or not target.player then
                vape:CreateNotification('Vape', "⚠️ No target available, waiting...", 1, 'alert')
                print("No target available, waiting...")
                HitmanShared.findNewTarget()
                task.wait(2) -- Increased delay
                continue
            end

            local skip, reason = shouldSkipTarget(target)
            if skip then
                vape:CreateNotification('Vape', '⏩ Skipping Target: ' .. reason, 1, 'alert')
                print("Skipping Target: " .. reason)
                
                HitmanShared.removeTarget()
                HitmanShared.findNewTarget()
                task.wait(2) -- Increased delay
            else
                vape:CreateNotification('Vape', '✅ Accepted Target: ' .. target.player.Name .. " (Lv. " .. target.level .. ")", 5, 'alert')
                print("Accepted Target: " .. target.player.Name .. " (Lv. " .. target.level .. ")")
                HitmanModule:Toggle()
                if originalPosition then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
                end
                break
            end
        end
        
        -- Clean up
        activeThread = nil
    end)
end

HitmanModule = vape.Categories.Combat:CreateModule({
    Name = 'Hitman Target Finder',
    Function = function(callback)
        HitmanTargetEnabled = callback
        if callback then
            startHitmanTargetSkipper({
                SkipIfLevelBelow = 0,
                DesiredPlayer = HitmanTargetPlayer
            })
        else
            -- Signal thread to stop
            threadShouldStop = true
            if originalPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
            end
            vape:CreateNotification('Vape', "Hitman Target Finder disabled", 5)
        end
    end,
    Tooltip = 'Automatically skips unwanted hitman targets'
})
Hitmantextbox = HitmanModule:CreateTextBox({
    Name = 'Target Player',
    Function = function(enter)
        HitmanTargetPlayer = Hitmantextbox.Value
        vape:CreateNotification('Vape',tostring(HitmanTargetPlayer), 5)
    end,
    Placeholder = 'Enter player name',
    Tooltip = 'Enter the player name you want to target',
})