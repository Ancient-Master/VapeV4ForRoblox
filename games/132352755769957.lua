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
local activeThread = nil -- Track the active loop thread

local function startHitmanTargetSkipper(config)
    -- Kill any existing loop first
    if activeThread then
        task.cancel(activeThread)
        activeThread = nil
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

    -- Auto-Skip Bad Targets
    local function shouldSkipTarget(target)
        if not target then return false end
        
        if TARGET_FILTER.SkipIfLevelBelow > 0 and target.level < TARGET_FILTER.SkipIfLevelBelow then
            return true, "Low Level (" .. target.player.Name .. " | Lv. " .. target.level .. ")"
        end
        
        if TARGET_FILTER.DesiredPlayer and target.player.Name ~= TARGET_FILTER.DesiredPlayer then
            return true, "Not Desired Player (" .. target.player.Name .. ")"
        end
        
        return false
    end

    -- Main Loop
    activeThread = task.spawn(function()
        while HitmanTargetEnabled do
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(125.482315, 254.5, -749.594482, -0.00281787151, 1.3361479e-07, 0.999996006, 1.39850187e-10, 1, -1.33614932e-07, -0.999996006, -2.3666008e-10, -0.00281787151)
            
            local target = getCurrentTarget()

            if not target or not target.player then
                vape:CreateNotification('Vape', "⚠️ No target available, waiting...", 1, 'alert')
				print("No target available, waiting...")
                HitmanShared.findNewTarget()
                continue
            end

            local skip, reason = shouldSkipTarget(target)
            if skip then
                vape:CreateNotification('Vape', '⏩ Skipping Target: ' .. reason, 1, 'alert')
				print("Skipping Target: " .. reason)
                HitmanShared.removeTarget()
                HitmanShared.findNewTarget()
            else
                vape:CreateNotification('Vape', '✅ Accepted Target: ' .. target.player.Name .. " (Lv. " .. target.level .. ")", 5, 'alert')
				print("Accepted Target: " .. target.player.Name .. " (Lv. " .. target.level .. ")")
                HitmanModule:Toggle()
                LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
                break
            end
        end
        activeThread = nil
    end)
end

HitmanModule = vape.Categories.Combat:CreateModule({
    Name = 'Hitman Target Finder',
    Function = function(callback)
        HitmanTargetEnabled = callback
        if callback then
            if not originalPosition and LocalPlayer.Character then
                originalPosition = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame
            end
            startHitmanTargetSkipper({
                SkipIfLevelBelow = 0,
                DesiredPlayer = HitmanTargetPlayer
            })
        else
            -- Clean up when disabling
            if activeThread then
                task.cancel(activeThread)
                activeThread = nil
            end
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
        vape:CreateNotification('Vape', tostring(HitmanTargetPlayer), 5)
        -- Restart the skipper if active
        if HitmanTargetEnabled then
            startHitmanTargetSkipper({
                SkipIfLevelBelow = 0,
                DesiredPlayer = HitmanTargetPlayer
            })
        end
    end,
    Placeholder = 'Enter player name',
    Tooltip = 'Enter the player name you want to target',
})