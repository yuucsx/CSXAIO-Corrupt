--e só pegar o objeto que morreu
--e verificar c sua kill mudou =3
--ai se tiver 2 kill em X tempo, significa q foi double kill, ai manda a foto do double kill?
--mas tem q verificar se a kill for sua

local dead = graphics.createTexture("C:\\ProgramData\\2264419601716787603\\Scripts\\CSXAYAYA\\Pictures\\die.png")
local double_kill = graphics.createTexture("C:\\ProgramData\\2264419601716787603\\Scripts\\CSXAYAYA\\Pictures\\double_kill.png")
local triple_kill = graphics.createTexture("C:\\ProgramData\\2264419601716787603\\Scripts\\CSXAYAYA\\Pictures\\triple_kill.png")
local quadra_kill = graphics.createTexture("C:\\ProgramData\\2264419601716787603\\Scripts\\CSXAYAYA\\Pictures\\quadra_kill.png")
local penta_kill = graphics.createTexture("C:\\ProgramData\\2264419601716787603\\Scripts\\CSXAYAYA\\Pictures\\penta_kill.png")
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
    cb.add(cb.drawHUD, function() return self:OnDraw() end )
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
    if not menu.use_ayaya:get() then return end 
    
    if self.isDead ~= false and game.time < self.isDead + 5 then 
        graphics.drawTexture(dead, vec2(730, 150), vec2(500, 500))
    end


end


Menu = Menu()
AYAYA = AYAYA()
