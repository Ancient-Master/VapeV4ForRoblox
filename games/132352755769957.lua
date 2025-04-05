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
local entitylib = vape.Libraries.entity
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local uipallet = vape.Libraries.uipallet
local tween = vape.Libraries.tween
local color = vape.Libraries.color
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local getcustomasset = vape.Libraries.getcustomasset
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HitmanShared = require(ReplicatedStorage.Features.Hitman.HitmanShared)
local entitylib = vape.Libraries.entity
local Namespaces = require(ReplicatedStorage.Service.Namespaces)
local healRemote = ReplicatedStorage.Remote.AttemptHeal
local VALID_TOOLS = {"Medical Kit", "Quick-Fix", "Large Medical Kit"}
local currentTool = nil
local SelfHeal
local backpack = LocalPlayer:FindFirstChild("Backpack")
local HealOthers
local spin
local HealAura
local username123
local Targets
local notp
local TARGET_USERNAME
local originalPosition
local test
local Angle
local AttackRange
local Max
local Killaura
local function notif(...)
	return vape:CreateNotification(...)
end

local function checkForTarget()
    if not spin.Enabled then return end

    HitmanShared.removeTarget()
    HitmanShared.findNewTarget()

    local target = HitmanShared.getCurrentTarget()
    if target then
        if string.lower(target.player.Name) == string.lower(TARGET_USERNAME) then
            notif('Vape', "Successfully found target: " .. target.player.Name, 5,'warning')
            spin:Toggle()
        else
            notif('Vape', "Found wrong target: " .. target.player.Name, 3, 'warning')
            checkForTarget()
        end
    else
        notif('Vape', "No target found, retrying...", 1, 'warning')
        checkForTarget()
    end
end



local function unequipTools()
    if currentTool and currentTool.Parent == localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:UnequipTools()
        end
        currentTool.Parent = localPlayer.Backpack
        currentTool = nil
    end
end

local function equipAvailableTool()
    -- Check equipped tools first
    local character = LocalPlayer.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if table.find(VALID_TOOLS, tool.Name) and tool:GetAttribute("Ready") then
                currentTool = tool
                return true
            end
        end
    end
end
        -- Target finding with validation
        local function findValidTarget()
            if not HealOthers.Enabled then return nil end
            
            if SelfHeal.Enabled then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health < humanoid.MaxHealth then
                    return LocalPlayer
                end
            end
        
            local myRoot = LocalPlayer.Character.HumanoidRootPart
            local closest = {player = nil, distance = math.huge}
        
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local targetChar = player.Character
                if targetChar then
                    local targetRoot = targetChar.HumanoidRootPart
                    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                    
                    if targetRoot and humanoid and humanoid.Health < humanoid.MaxHealth then
                        local distance = (myRoot.Position - targetRoot.Position).Magnitude
                        if distance <= 10 and distance < closest.distance then
                            closest = {player = player, distance = distance}
                        end
                    end
                end
            end
            
            return closest.player
        end

spin = vape.Categories.Combat:CreateModule({
    Name = 'Spin',
    Function = function(callback)
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

username123 = spin:CreateTextBox({
    Name = 'Set Target',
    Function = function(enter)
		TARGET_USERNAME = username123.Value
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
Killaura = vape.Categories.Combat:CreateModule({
    Name = 'Killaura',
    Function = function(callback)
        if callback then
            repeat
                local plrs = entitylib.AllPosition({
                    Range = AttackRange.Value,
                    Wallcheck = Targets.Walls.Enabled or nil,
                    Part = 'RootPart',
                    Players = Targets.Players.Enabled,
                })

                if #plrs > 0 then
                    local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)

                    for i, v in pairs(plrs) do
                        local delta = (v.RootPart.Position - entitylib.character.RootPart.Position)
                        local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
                        if angle > (math.rad(Angle.Value) / 2) then continue end
						if entitylib.isAlive then            
							if entitylib.isVulnerable then
							targetinfo.Targets[v] = tick() + 1
						for i = 1, 3 do
							coroutine.wrap(function()
							local args = {
                            v.Humanoid,
                            v.Head,
                            LocalPlayer.Character:FindFirstChildOfClass("Tool") or nil
                        }
                        Namespaces.MeleeReplication.packets.sendHit.send(args)
						end)()
					end
				end
				end
			end
		end
                task.wait()
            until not Killaura.Enabled
        end
    end,
    Tooltip = 'test module'
})

Targets = Killaura:CreateTargets({Players = true})
AttackRange = Killaura:CreateSlider({
    Name = 'Attack range',
    Min = 1,
    Max = 18,
    Default = 18,
    Suffix = function(val)
        return val == 1 and 'stud' or 'studs'
    end
})

Angle = Killaura:CreateSlider({
    Name = 'Max angle',
    Min = 1,
    Max = 360,
    Default = 360
})
HealAura = vape.Categories.Blatant:CreateModule({
    Name = 'HealAura',
    Function = function(callback)
if callback then
            if Backpack then
                for _, tool in ipairs(Backpack:GetChildren()) do
                    if table.find(VALID_TOOLS, tool.Name) and tool:GetAttribute("Ready") then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:EquipTool(tool)
                            currentTool = tool
                            return true
                        end
                    end
                end
            end
            
            unequipTools()
            return false
        end
        

        
        -- Main control system

        while HealAura.Enabled do
            local target = findValidTarget()
            if target then
                if equipAvailableTool() then
                    healRemote:FireServer(target)
                    print(`Healed {target.Name} with {currentTool.Name}`)
                    unequipTools()
                end
            else
                unequipTools()
            end
        end

    end,
    Tooltip = 'Heals yourself or players around you.'
})

SelfHeal = HealAura:CreateToggle({
    Name = 'Heal yourself.',
    Function = function(callback)
--equipAvailableTool() steht der check
    end,
    Tooltip = 'Heals yourself.'
})

HealOthers = HealAura:CreateToggle({
    Name = 'Heal others.',
    Function = function(callback)
        print(callback, 'toggle enabled!')
    end,
    Tooltip = 'Heal other players.'
})