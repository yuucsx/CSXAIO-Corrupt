local tx = graphics.createTexture("C:\\ProgramData\\2264419601716787603\\Scripts\\CSXAYAYA\\Pictures\\die.png")
-- AYAYA "class" constructor
local Menu = setmetatable({}, 
{
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)

        return result
    end
})

function Menu:init()
    menu = menu.create("csxayaya", "CSX ayaya")
    menu:spacer("header1", "Sex AYAYA")

    menu:boolean("use_ayaya", "PLS ENABLE ME", true)
end

-- AYAYA "class" constructor
local AYAYA = setmetatable({}, 
{
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)

        return result
    end
})

function AYAYA:init()
    self.isDead = false
    self:LoadEvents()
end

function AYAYA:LoadEvents()
    cb.add(cb.draw, function() return self:OnDraw() end )
    cb.add(cb.death, function(obj) return self:OnDeath(obj) end)
    cb.add(cb.unload, function() menu.delete('csxayaya') end)
end


function AYAYA:OnDeath(obj)
    if obj.skinName ~= myHero.skinName then return end
    self.isDead = game.time
end

function AYAYA:OnSpawn(obj)
    if obj ~= myHero then return end
    self.isDead = game.time
end

function AYAYA:OnTick()
end

function AYAYA:OnDraw()

    if self.isDead ~= false and game.time < self.isDead + 5 then 
        graphics.drawTexture(tx, vec2(730, 150), vec2(500, 500))
    end
end


Menu = Menu()
AYAYA = AYAYA()
