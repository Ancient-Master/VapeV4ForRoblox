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
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HitmanShared = require(ReplicatedStorage.Features.Hitman.HitmanShared)
local spin
local textbox
local TARGET_USERNAME = "SwiftUser_com" -- Default target
local originalPosition = nil

spin = vape.Categories.Combat:CreateModule({
    Name = 'Spin',
    Function = function(callback)
        if callback then
            -- Store original position before starting
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
            
            local function checkForTarget()
                if not spin.Enabled then return end
                
                -- Remove current target
                HitmanShared.removeTarget()
                
                -- Find new target
                HitmanShared.findNewTarget()

                local target = HitmanShared.getCurrentTarget()
                if target then
                    if string.lower(target.player.Name) == string.lower(TARGET_USERNAME) then
                        print("\n🎯 Successfully found target:", target.player.Name)
                        end
                        
                        spin:Toggle() -- Disable the module after successful find
                    else
                        print("Found wrong target:", target.player.Name)
                        checkForTarget() -- Keep searching
                    end
                else
                    print("No target found, retrying...")
                    checkForTarget() -- Keep searching
                end
            end
            
            -- Start the target finding process
            checkForTarget()
        else
            print("Spin disabled")
			if originalPosition then
				LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
			end
            -- Clean up when disabled if needed
        end
    end,
    Tooltip = 'Finds target and teleports to them temporarily'
})

-- Textbox to set target username
textbox = spin:CreateTextBox({
    Name = 'Set Target',
    Function = function(enter)
        TARGET_USERNAME = textbox.Value
        print("Target set to:", TARGET_USERNAME)
    end,
    Placeholder = 'Enter target username',
    Tooltip = 'Enter the username of the target you want to find.'
})