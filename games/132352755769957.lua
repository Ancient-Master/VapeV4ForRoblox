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
local Affe

local test = vape.Categories.Combat:CreateModule({
    Name = 'Test',
    Function = function(callback)
        print(callback, 'module enabled!')
        Affe:Toggle()
    end,
    Tooltip = 'This is a test module'
})
toggle = test:CreateToggle({
    Name = 'Custom Properties',
    Function = function(callback)
        print(callback, 'toggle enabled!')
    end,
    Tooltip = 'This is a test toggle.'
})

Affe = vape.Categories.Combat:CreateModule({
	Name = 'teststuff',
    Tooltip = 'Hi! This is a tooltip.',
	Function = function(callback)
		print(callback, 'module state')
		Affe:Clean(Instance.new('Part'))
		repeat
			print('repeat loop!')
			task.wait(1)
		until (not Affe.Enabled)
	end,
	ExtraText = function() return 'Test' end,
	Tooltip = 'This is a test module.'
})



