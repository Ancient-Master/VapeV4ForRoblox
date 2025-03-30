local vape = shared.vape

local test = vape.Categories.Combat:CreateModule({
    Name = 'Test',
    Function = function(callback)
        print(callback, 'module enabled!')
    end,
    Tooltip = 'This is a test module'
})