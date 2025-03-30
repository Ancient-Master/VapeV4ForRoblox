local vape = shared.vape

local test = vape.Categories.Combat:CreateModule({
    Name = 'Test',
    Function = function(callback)
        print(callback, 'module enabled!')
    end,
    Tooltip = 'This is a test module'
})

local Affe
Affe = vape.Categories.Combat:CreateModule({
	Name = 'teststuff',
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