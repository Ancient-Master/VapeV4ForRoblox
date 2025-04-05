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
local entitylib = vape.Libraries.entity
local spin
local username
local Targets
local notp
local TARGET_USERNAME
local originalPosition
local test
local Angle
local AttackRange

local function checkForTarget()
	if not spin.Enabled then return end

	HitmanShared.removeTarget()
	HitmanShared.findNewTarget()

	local target = HitmanShared.getCurrentTarget()
	if target then
		if string.lower(target.player.Name) == string.lower(TARGET_USERNAME) then
			vape:CreateNotification('Vape',"\n🎯 Successfully found target:", target.player.Name,5)
			spin:Toggle()
		else
			vape:CreateNotification('Vape',"Found wrong target:", target.player.Name,1,'warning')

			checkForTarget()
		end
	else
		vape:CreateNotification('Vape',"No target found, retrying...",1,'warning')

		checkForTarget()
	end
end

spin = vape.Categories.Combat:CreateModule({
    Name = 'Spin',
    Function = function(callback)
		if LocalPlayer.Team ~= "PATIENT" then
			vape:CreateNotification('Vape',"\n🚫 You are not in the Patient team!", 5, 'warning')
			return
		end
		if callback then

			if not notp.Enabled then
				originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(125.482315, 254.5, -749.594482, -0.00281787151, 1.3361479e-07, 0.999996006, 1.39850187e-10, 1, -1.33614932e-07, -0.999996006, -2.3666008e-10, -0.00281787151)
				task.wait(0.5)
			end

            checkForTarget()
        else
			            print("Spin disabled")
						if not notp.Enabled then
						LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
						end
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

notp = spin:CreateToggle({
    Name = 'No Teleport',
    Function = function(callback)
    end,
    Tooltip = 'Disables teleporting you have to stay near the bounty npc.'
})

test = vape.Categories.Combat:CreateModule({
    Name = 'test',
    Function = function(callback)
        if callback then
            repeat
                local plrs = entitylib.AllPosition({
                    Range = AttackRange.Value,
                    Wallcheck = Targets.Walls.Enabled or nil,
                    Part = 'RootPart',
                    Players = Targets.Players.Enabled
                })

                task.wait()
            until not test.Enabled
        end
    end,
    Tooltip = 'test module'
})
Targets = test:CreateTargets({
	Players = true,
    Function = function()

    end,
    Tooltip = 'Select targets to track.'
})
AttackRange = test:CreateSlider({
	Name = 'Attack range',
	Min = 1,
	Max = 8,
	Default = 8,
	Suffix = function(val) 
		return val == 1 and 'stud' or 'studs' 
	end
})
Angle = test:CreateSlider({
	Name = 'Max angle',
	Min = 1,
	Max = 360,
	Default = 360
})
