local dead = graphics.createTexture("C:\\ProgramData\\1382341331797870047\\Scripts\\CSXAYAYA\\Pictures\\die.png")
local double_kill = graphics.createTexture("C:\\ProgramData\\1382341331797870047\\Scripts\\CSXAYAYA\\Pictures\\double_kill.png")
local triple_kill = graphics.createTexture("C:\\ProgramData\\1382341331797870047\\Scripts\\CSXAYAYA\\Pictures\\triple_kill.png")
local quadra_kill = graphics.createTexture("C:\\ProgramData\\1382341331797870047\\Scripts\\CSXAYAYA\\Pictures\\quadra_kill.png")
local penta_kill = graphics.createTexture("C:\\ProgramData\\1382341331797870047\\Scripts\\CSXAYAYA\\Pictures\\penta_kill.png")
-- AYAYA "class" constructor
local Menu = setmetatable({}, 
{
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)

        return result
    end
})

local delayedActions, delayedActionsExecuter = {}, nil
function DelayAction(func, delay, args)
    if not delayedActionsExecuter then
        function delayedActionsExecuter()
            for t, funcs in pairs(delayedActions) do
                if t <= os.clock() then
                    for i = 1, #funcs do
                        local f = funcs[i]
                        if f and f.func then
                            f.func(unpack(f.args or {}))
                        end
                    end
                    delayedActions[t] = nil
                end
            end
        end
        cb.add(cb.tick, delayedActionsExecuter)
    end
    local t = os.clock() + (delay or 0)
    if delayedActions[t] then
        delayedActions[t][#delayedActions[t] + 1] = {func = func, args = args}
    else
        delayedActions[t] = {{func = func, args = args}}
    end
end

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
    self.killTable = {}
    self.latestKills = myHero.asHero.kills
    self.lastKillTime = 0
    self.single = nil
    self.double = nil
    self.triple = nil
    self.quadra = nil
    self.penta  = nil
    self.candouble = false
    self.cantriple = false
    self.canquadra = false
    self.canPenta = false
end

function AYAYA:LoadEvents()
    cb.add(cb.drawHUD, function() return self:OnDraw() end )
    cb.add(cb.tick, function() return self:OnTick() end )
    cb.add(cb.death, function(obj) return self:OnDeath(obj) end)
    cb.add(cb.unload, function() menu.delete('csxayaya') end)
end


function AYAYA:OnDeath(obj)
    if obj.networkId ~= myHero.networkId and obj.isHero and self.latestKills ~= myHero.asHero.stats.kills then
        print(obj.name)
        table.insert(self.killTable, {killTime = game.time})

    end
end

function AYAYA:OnSpawn(obj)
    if obj ~= myHero then return end
    self.isDead = game.time
end

function AYAYA:Kills(obj)
    if obj.skinName ~= myHero.skinName then return end
    print(self.kills[1])
    if myHero.asHero.stats.kills < game.time + 5 then return end
end

function AYAYA:Dead(obj)
    if obj.skinName ~= myHero.skinName then return end
    self.isDead = game.time
end

function AYAYA:OnTick()

    if self.killTable ~= nil and #self.killTable ~= 0 then
        local pastKillCount = #self.killTable
        for _, kill in ipairs(self.killTable) do
            local time = kill.killTime
            if self.double == nil and #self.killTable == 2 then
                self.candouble = game.time
                self.double = game.time
            end
            if self.triple == nil and #self.killTable == 3 then
                self.cantriple = game.time
                self.triple = game.time
            end
            if self.quadra == nil and #self.killTable == 4 then
                self.canquadra = game.time
                self.quadra = game.time
            end
            if self.penta == nil and #self.killTable == 5 then
                self.canPenta = game.time
                self.killTable = {}
            end
        end 
    end 
    if self.double ~= nil then print(#self.killTable) return end
    if self.triple ~= nil then print(#self.killTable) return end
    if self.quadra ~= nil then print(#self.killTable) return end
    if self.penta ~= nil then print(#self.killTable) return end
end

function AYAYA:OnDraw()
    if not menu.use_ayaya:get() then return end 

    if self.candouble ~= false  and self.candouble + 5 > game.time then
        graphics.drawTexture(double_kill, vec2(730, 150), vec2(500, 500))
    end

    if self.cantriple ~= false  and self.cantriple + 5 > game.time then
        graphics.drawTexture(triple_kill, vec2(730, 150), vec2(500, 500))
    end

    if self.canquadra ~= false  and self.canquadra + 5 > game.time then
        graphics.drawTexture(quadra_kill, vec2(730, 150), vec2(500, 500))
    end

    if self.canPenta ~= false and self.canPenta + 5 > game.time then
        graphics.drawTexture(penta_kill, vec2(730, 150), vec2(500, 500))
        --sound.play("C:\\ProgramData\\2264419601716787603\\Scripts\\CSXAYAYA\\Pictures\\master_wet.wav")
    end
    if self.isDead ~= false and game.time < self.isDead + 5 then 
        graphics.drawTexture(dead, vec2(730, 150), vec2(500, 500))
    end

     --sound.play("C:\\ProgramData\\1382341331797870047\\Scripts\\CSXAYAYA\\Pictures\\master_wet.wav")



end


Menu = Menu()
AYAYA = AYAYA()
