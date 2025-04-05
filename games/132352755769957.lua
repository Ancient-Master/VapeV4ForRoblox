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
local username
local TARGET_USERNAME
local isRunning = false -- Flag to prevent multiple executions

spin = vape.Categories.Combat:CreateModule({
    Name = 'Spin',
    Function = function(callback)
        if callback then
            if isRunning then return end -- Prevent multiple executions
            isRunning = true
            
            -- Check if character exists
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                vape:CreateNotification('Vape', 'Character not fully loaded', 5, 'alert')
                spin:Toggle(false)
                isRunning = false
                return
            end
            
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(125.482315, 254.5, -749.594482, -0.00281787151, 1.3361479e-07, 0.999996006, 1.39850187e-10, 1, -1.33614932e-07, -0.999996006, -2.3666008e-10, -0.00281787151)

            local function checkForTarget()
                if not spin.Enabled then 
                    isRunning = false
                    return 
                end
                
                -- Remove current target
                HitmanShared.removeTarget()
                
                -- Find new target
                HitmanShared.findNewTarget()

                local target = HitmanShared.getCurrentTarget()
                if target then
                    if string.lower(target.player.Name) == string.lower(TARGET_USERNAME) then
                        print("\n🎯 Successfully found target:", target.player.Name)
                        spin:Toggle()
                        isRunning = false
                    else
                        print("Found wrong target:", target.player.Name)
                        checkForTarget() -- Recursively keep searching
                    end
                else
                    print("No target found, retrying...")
                    checkForTarget() -- Recursively keep searching
                end
            end
            
            -- Start the target finding process
            checkForTarget()
        else
            print("Spin disabled")
            isRunning = false
            -- Clean up when disabled if needed
        end
    end,
    Tooltip = 'Automatically finds and locks onto specified target.'
})

username = spin:CreateTextBox({
    Name = 'Set Target',
    Function = function(enter)
        TARGET_USERNAME = username.Value
    end,
    Placeholder = 'Enter target username',
    Tooltip = 'Enter the username of the target you want to find.'
})