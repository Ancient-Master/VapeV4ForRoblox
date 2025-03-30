local SilentAim
SilentAim = vape.Categories.Combat:CreateModule({
	Name = 'SilentAim',
	Function = function(callback)
		print(callback, 'module state')
		SilentAim:Clean(Instance.new('Part'))
		repeat
			print('repeat loop!')
			task.wait(1)
		until (not SilentAim.Enabled)
	end,
	ExtraText = function() return 'Test' end,
	Tooltip = 'This is a test module.'
})