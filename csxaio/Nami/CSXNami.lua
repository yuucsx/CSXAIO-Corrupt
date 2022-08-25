-- Settings table, will use this instead of retrieving menu value using :get() 
local Settings = {} 

-- Utility "class" constructor
local Utility = setmetatable({}, 
{
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)

        return result
    end
})

function Utility:init()
end

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
    return game.latency / 2
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
    local time = myHero:getSpell(spell).readyTime
    return time and (time > 0 and time <= Utility:GetLatency()) 
end

function Utility:IsCastingSpell()
    return myHero.activeSpell and myHero.activeSpell.castEndTime > game.time + Utility:GetLatency()
end

-- Input "class" constructor
local Input = setmetatable({}, 
{
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)

        return result
    end
})

function Input:init()
    self.last_q_cast = nil
    self.last_w_cast = nil
    self.last_e_cast = nil
    self.last_r_cast = nil
end

function Input:CastSpell(spell, pos)
    if not spell then return end
    if not pos then pos = myHero end

    if not Utility:CanCastSpell(spell) then return end
    if Utility:IsCastingSpell() then return end

    pos = pos ~= nil and (pos and pos.x or pos.pos)

    if spell == SpellSlot.W or spell == SpellSlot.E and pos.pos then
        return myHero:castSpell(spell, pos)
    end 
    return myHero:castSpell(spell, vec3(pos.x, 0, pos.z))
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

function Nami:Init()
    self.Spells = {
        Q = {
            delay = 0.25 + 0.726,
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
end

function Nami:UseQ(target, pred)
    if not pred then return Input:CastSpell(SpellSlot.Q, target.position) end

    return Input:CastSpell(SpellSlot.Q, pred.position)
end

function Nami:Combo()
    local target = Utility:GetOrbwalkerTarget()
    if not target then return end

    return self:UseQ(target, Utility:GetPrediction(target, self.Spells.Q))
end






