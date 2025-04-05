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



spin = vape.Categories.Combat:CreateModule({
    Name = 'Spin',
    Function = function(callback)
        
        if callback then
            -- Set the username of the player you want to target here
            local TARGET_USERNAME = "SwiftUser_com" -- Change this
            
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
						spin:Toggle()
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
            -- Clean up when disabled if needed
        end
    end,
    Tooltip = 'Automatically finds and locks onto specified target.'
})

textbox = spin:CreateTextBox({
    Name = 'Set Target',
    Function = function(enter)
		TARGET_USERNAME = textbox.Value
    end,
    Placeholder = 'Enter target username',
    Tooltip = 'Enter the username of the target you want to find.'
})