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
        p2 = player.position
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
    range = range or player.characterIntermediate.attackRange
    local enemies = ts.getResult(function(a) return self:GetDistance(player, a) <= range end)
    if not enemies then return end
    return enemies
end

function Utility:GetPrediction(target, inputTable)
    if inputTable.speed == 0 then return end
    local prediction = pred.getPrediction(target, inputTable)
    if prediction  then return end
    return prediction
end

function Utility:CanCastSpell(spell)
    local time = player.asHero:getSpell(spell).readyTime
    return time < game.time + Utility:GetLatency()
end 

function Utility:IsCastingSpell()
    return player.activeSpell and player.activeSpell.castEndTime > game.time + Utility:GetLatency()
end

local delayedActions, delayedActionsExecuter = {}, nil
function Utility:DelayAction(func, delay, args)
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

-- Input "class" constructor
local Input = {}


function Input:CastSpell(spell, castPos)

    if not spell then return end
    if not pos then pos = player end

    if Utility:IsCastingSpell() then return end
    if not Utility:CanCastSpell(spell) then return end
    pos = pos ~= nil and (castPos and castPos.x or pos.pos)

    if spell == SpellSlot.W or spell == SpellSlot.E and castPos.pos then
        return player:castSpell(spell, vec3(castPos.pos.x, 0, castPos.pos.z))
    end 
    return player:castSpell(spell, vec3(castPos.x, 0, castPos.z))
end

function Input:SendMove(pos)
    if not pos then return end

    return player:SendMove(pos)
end

function Input:SendAttack(unit)
    if not unit then return end

    return player:SendAttack(unit)
end

-- Nami "class" constructor
local Menu = setmetatable({}, 
{
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)

        return result
    end
})

function Menu:init()
    menu = menu.create("csxaio", "CSX AIO")
    menu:spacer("header1", "Sex Nami")

    menu:header("combo", "Combo")
    menu.combo:spacer("headerQ", "[Q] Settings")
    menu.combo:boolean("use_q", "Use Q", true)

    menu.combo:spacer("headerW", "[E] Settings")
    menu.combo:boolean("use_e", "Use E", true)

    menu.combo:spacer("headerR", "[R] Settings")
    menu.combo:boolean("use_r", "Use R", true)

    menu:header("auto", "Automatic")
    menu.auto:spacer("headerQauto", "[Q] Settings")
    menu.auto:boolean("use_q_cc", "Use Q in CC", true)
    menu.auto:boolean("use_q_dash", "Use Q in Dash/Jumps", true)
    menu.auto:boolean("use_q_spells", "Use Q in Spells", true)
    menu.auto:boolean("use_q_aa", "Use Q in AA", true)

    menu.auto:spacer("headerWauto", "[W] Settings")
    menu.auto:boolean("use_w", "Use W", true)
    menu.auto:slider('heal_slider', "Don't W if Health <=", 5, 100, 30, 5)

    menu:header("drawings", "Drawings")
    menu.drawings:boolean("draw_q", "Draw Q", true)
    menu.drawings:color('color_q', 'Q Color', graphics.argb(255, 255, 0, 0))

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

    self.castTime = {0,0,0,0}

    self.Spells = {

        Q = {
            delay = 1 ,
            speed = math.huge,
            range = 840,
            radius = 125,
            type = spellType.circular,
            collision = {
                hero = SpellCollisionType.None,
                minion = SpellCollisionType.None,
                tower = SpellCollisionType.None,

                flags = bit.bor(CollisionFlags.Windwall, CollisionFlags.Samira)
            }
        },

        W = {
            range = 725
        },
        
        E = {
            range = 800
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
    self.heroes = {}
    self.allyHeroes = {}
    self.enemyHeroes = {}
    self:LoadEvents()
end

function Nami:LoadEvents()
    cb.add(cb.tick, function() return self:Combo() end )
    cb.add(cb.draw, function() return self:OnDraw() end )
    cb.add(cb.basicAttack, function(...) return self:OnBasicAttack(...) end )
    cb.add(cb.processSpell, function(...) return self:OnProcessSpell(...) end )
    cb.add(cb.newPath, function(...) return self:OnNewPath(...) end )
    cb.add(cb.buff,function(...) self:OnBuff(...) end)


    cb.add(cb.unload, function() menu.delete('csxaio') end)
end

function Nami:OnDraw()
    if menu.drawings.draw_q:get() then
        local alpha = player:spellSlot(SpellSlot.Q).state == 0 and 255 or 50
        graphics.drawCircle(player.pos, self.Spells.Q.range, 1, menu.drawings.color_q:get())
    end
    
end

function Nami:GetQSpeed(target)
    local pred = pred.positionAfterTime(target, 0.976)
    if not pred then return 0 end
    local dist = Utility:GetDistance(player, pred)
    return Input:CastSpell(SpellSlot.Q, pred)

end

function Nami:CalculateEscapeTime(target, windup)
    if not target then return end
    local TimeToCast = windup
    local MoveSpeed = target.characterIntermediate.moveSpeed
    local HalfRadius = 100
    local Latency = Utility:GetLatency()
    local CastTime = 0.25
    local InactiveTime = (HalfRadius / MoveSpeed) + Latency + TimeToCast
    return InactiveTime
end

function Nami:CalculateCastToLand()
    return 0.25 + 0.726 - Utility:GetLatency()
end

function Nami:OnBasicAttack(obj, attack)
    if obj.team == player.team then return end
    if not obj.isHero then return end
    if not attack then return end
    if attack.target and attack.target == player then return end
    if self:CalculateCastToLand() - self:CalculateEscapeTime(obj, attack.castDelay) <= 0.25 then 
        self:UseQ(obj)
    end
end

function Nami:OnNewPath(obj, path, isDash, speed)
    if obj.team == player.team then return end
    if not obj.isHero then return end
    if not path then return end
    if not isDash then return end
    if not speed then return end
    if not path[2] then return end
    local Endpos = vec3(path[2].x,path[2].y,path[2].z)
    local Endtime = Utility:GetDistance(obj, path[2]) / speed
    if not menu.auto.use_q_dash:get() then return end
    if Endtime > 0.976 then 
        return Utility:DelayAction(
        function()
            if Utility:GetDistance(player, path[2]) <= self.Spells.Q.range + (self.Spells.Q.radius / 2) then
            return Input:CastSpell(SpellSlot.Q, Endpos)
            end
        end, 0.976 - Endtime)
    end
        Input:CastSpell(SpellSlot.Q, Endpos) 
end

function Nami:OnProcessSpell(obj, spell)
    if obj.team == player.team then return end
    if not obj.isHero then return end
    if not spell then return end
    --print(self:CalculateEscapeTime(obj, spell.castDelay))
    if spell.name:find("Summoner") then return end
    if self:CalculateCastToLand() - self:CalculateEscapeTime(obj, spell.castDelay) <= 0.15 then 
        self:UseQ(obj)
    end

end

function Nami:OnBuff(obj, buff)
    if obj and obj.team ~= player.team and obj.type == player.type and buff then
        if player.position:distance(obj.pos) < 900 and menu.auto.use_q_cc:get() then
            if pred.getCrowdControlledTime(obj.asAIBase) > 0 then
                Input:CastSpell(SpellSlot.Q, obj.pos)
            end
        end
    end
end

function Nami:GetPercentHealth(obj)
    local obj = obj or player
    return (obj.health / obj.maxHealth) * 100
end

function Nami:UseQ(target, prediction)
    if not prediction then return Input:CastSpell(SpellSlot.Q, target) end

    return Input:CastSpell(SpellSlot.Q, prediction.castPosition)
end


function Nami:GetClosestAlly(range)
    local allyHeroes = {}

    for _, obj in ipairs(objManager.heroes.list) do
        if obj and obj ~= myHero and obj.team == myHero.team and Utility:GetDistance(obj, myHero) < range then 
            allyHeroes[#allyHeroes + 1] = obj
        end
    end
    if #allyHeroes == 1 then return allyHeroes[1] end
    table.sort(allyHeroes, function(a, b) return Utility:GetDistance(a, player) < range and Utility:GetDistance(a, player) < Utility:GetDistance(b, player) end)
    return allyHeroes[1]
end

function Nami:UseW()
    local ally = self:GetClosestAlly(725)
    if ally then
        if self:GetPercentHealth(ally) <= menu.auto.heal_slider.value then
            player:castSpell(SpellSlot.W, ally, false, true)
        end
    end
end

function Nami:UseR(target, prediction)
    if not prediction then return Input:CastSpell(SpellSlot.R, target.pos) end
    return Input:CastSpell(SpellSlot.R, prediction.castPosition)
end

function Nami:IsSpellLocked()
    return self.spellLocked > game.time
end

function Nami:Combo()
    local target = Utility:GetTarget(self.Spells.Q.range)
    if not target then return end

    --if self:IsSpellLocked() then return end

    if menu.auto.use_w:get() then
        self:UseW()
    end

    if orb.isComboActive then

        if menu.combo.use_q:get() then
            self:GetQSpeed(target.asAIBase)
        end

        if menu.combo.use_r:get() then
            self:UseR(target, Utility:GetPrediction(target.asAIBase, self.Spells.R))
        end
    end
end

Menu = Menu()
Nami = Nami()
