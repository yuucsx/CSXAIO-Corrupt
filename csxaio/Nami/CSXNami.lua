-- Settings table, will use this instead of retrieving menu value using :get() 
local Settings = {} 

-- Utility "class" constructor
local Utility = {}


function Utility:GetDistanceSqr(p1, p2)
    p1 = p1.x ~= nil and p1 or p1.pos
    p2 = p2.x ~= nil and p2 or p2.pos
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function Utility:GetDistance(p1, p2)
    p1 = p1.x ~= nil and p1 or p1.pos
    if not p2 then 
        p2 = myHero.position
    else
        p2 = p2.x ~= nil and p2 or p2.pos
    end
    
    return math.sqrt(self:GetDistanceSqr(p1, p2))
end

function Utility:GetLatency()
    return game.latency / 2000
end

function Utility:FilterEnemies(a,b)
    return a.health < b.health and a.characterIntermediate.armor < b.characterIntermediate.armor and a.spellBlock < b.spellBlock
end

function Utility:GetOrbwalkerTarget()
    return orb.comboTarget
end

function Utility:GetTarget(range)
    range = range or myHero.characterIntermediate.attackRange
    local enemies = ts.getResult(function(a, b) return self:GetDistance(myHero, a) <= range and self:FilterEnemies(a, b) end)
    return enemies[1]
end

function Utility:GetPrediction(target, inputTable)
    local prediction = pred.getPrediction(target, inputTable)
    return prediction
end

function Utility:CanCastSpell(spell)
    local time = myHero.asHero:getSpell(spell).readyTime
    return time < game.time + Utility:GetLatency()
end 

function Utility:IsCastingSpell()
    return myHero.activeSpell and myHero.activeSpell.castEndTime > game.time + Utility:GetLatency()
end

-- Input "class" constructor
local Input = {}


function Input:CastSpell(spell, castPos)

    if not spell then return end
    if not pos then pos = myHero end

    if Utility:IsCastingSpell() then return end
    if not Utility:CanCastSpell(spell) then return end
    pos = pos ~= nil and (castPos and castPos.x or pos.pos)

    if spell == SpellSlot.W or spell == SpellSlot.E and castPos.pos then
        return myHero:castSpell(spell, vec3(castPos.pos.x, 0, castPos.pos.z))
    end 
    return myHero:castSpell(spell, vec3(castPos.x, 0, castPos.z))
end

function Input:SendMove(pos)
    if not pos then return end

    return myHero:SendMove(pos)
end

function Input:SendAttack(unit)
    if not unit then return end

    return myHero:SendAttack(unit)
end

-- Nami "class" constructor
local Nami = setmetatable({}, 
{
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)

        return result
    end
})

function Nami:init()
    self.Spells = {
        Q = {
            delay = 0.25 ,
            speed = math.huge,
            range = 850,
            radius = 200,
            type = spellType.circular,
            collision = {
                hero = SpellCollisionType.None,
                minion = SpellCollisionType.None,
                tower = SpellCollisionType.None,

                flags = bit.bor(CollisionFlags.Windwall, CollisionFlags.Samira)
            }
        },
        R = {
            delay = 0.5,
            speed = 850,
            range = 2750,
            radius = 500,
            type = spellType.linear,
            collision = {
                hero = SpellCollisionType.None,
                minion = SpellCollisionType.None,
                tower = SpellCollisionType.None,

                flags = bit.bor(CollisionFlags.Windwall, CollisionFlags.Samira, CollisionFlags.Braum)
            }
        }
    }

    self:LoadEvents()
end

local function class()
    local cls = {}
    cls.__index = cls
    return setmetatable(cls, {__call = function (c, ...)
        local instance = setmetatable({}, cls)
        if cls.__init then
            cls.__init(instance, ...)
        end
        return instance
    end})
end

local _Menu = class()
Menu = nil

function _Menu:__init()
    menu = menu.create("csxaio", "CSX AIO")
    menu:spacer("header1", "Sex Nami")

    menu:header("combo", "Combo")
    menu.combo:spacer("headerQ", "[Q] Settings")
    menu.combo:boolean("use_q", "Use Q", true)

    menu.combo:spacer("headerE", "[W] Settings")
    menu.combo:boolean("use_w", "Use W", true)

    menu.combo:spacer("headerW", "[E] Settings")
    menu.combo:boolean("use_e", "Use E", true)

    menu.combo:spacer("headerR", "[R] Settings")
    menu.combo:boolean("use_r", "Use R", true)

    menu:header("drawings", "Drawings")
    menu.drawings:boolean("draw_q", "Draw Q", true)
    menu.drawings:color('color_q', 'Q Color', graphics.argb(255, 255, 0, 0))


    Menu = self
end

function Nami:LoadEvents()
    cb.add(cb.tick, function() return self:Combo() end )
    cb.add(cb.draw, function() return self:OnDraw() end )
    cb.add(cb.unload, function() menu.delete('csxaio') end)
end

function Nami:OnDraw()
    if menu.drawings.draw_q:get() then
        local alpha = player:spellSlot(SpellSlot.Q).state == 0 and 255 or 50
        graphics.drawCircle(player.pos, self.Spells.Q.range, 1, menu.drawings.color_q:get())
    end
    
end

function Nami:UseQ(target, prediction)
    if not prediction then return Input:CastSpell(SpellSlot.Q, target.pos) end
    return Input:CastSpell(SpellSlot.Q, prediction.castPosition)
end

function Nami:UseR(target, prediction)
    if not prediction then return Input:CastSpell(SpellSlot.R, target.pos) end
    return Input:CastSpell(SpellSlot.R, prediction.castPosition)
end

function Nami:Combo()
    local target = Utility:GetOrbwalkerTarget()
    if not target then return end
    
    if Orbwalker.isComboActive then

    if menu.combo.use_q:get() then
    self:UseQ(target, Utility:GetPrediction(target.asAIBase, self.Spells.Q))
    end
   -- self:UseW(target, Utility:GetPrediction(target.asAIBase, self.Spells.W))
    --self:UseE(myHero, Utility:GetPrediction(target.asAIBase, self.Spells.E))
    if menu.combo.use_r:get() then
    self:UseR(target, Utility:GetPrediction(target.asAIBase, self.Spells.R))
    end
end
end

Nami = Nami()
_Menu()