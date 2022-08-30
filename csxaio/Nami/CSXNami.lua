-- Settings table, will use this instead of retrieving menu value using :get() 
local Settings = {} 

-- Utility "class" constructor
local Utility = {}
local function is_in_range(target, pos, range)
    return target.position:distanceSqr(pos) < range ^ 2
end

local function get_best_target_priority(target_list, priority_list, range)

end

local function get_min_dist_target(target_list, main_target, range)
    local min_dist = math.huge
    local min_target = nil

    if type(target_list[1]) == "table" then
        for _, list in ipairs(target_list) do
            for _, target in ipairs(list) do 
                if target.networkId ~= main_target.networkId and is_in_range(target, objManager.player.position, range) then
                    local curr_dist = target.position:distanceSqr(main_target.position)
                    if curr_dist < min_dist then
                        min_dist = curr_dist
                        min_target = target
                    end
                end
            end
        end
    else 
        for _, target in ipairs(target_list) do
            if target.networkId ~= main_target.networkId and is_in_range(target, objManager.player.position, range) then
                local curr_dist = target.position:distanceSqr(main_target.position)
                if curr_dist < min_dist then
                    min_dist = curr_dist
                    min_target = target
                end
            end
        end
    end

    return min_target
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
    if inputTable.speed == 0 then return end
    local prediction = pred.getPrediction(target, inputTable)
    if prediction and prediction.hitChance < 50 then return end
    return prediction
end

function Utility:CanCastSpell(spell)
    local time = myHero.asHero:getSpell(spell).readyTime
    return time < game.time + Utility:GetLatency()
end 

function Utility:IsCastingSpell()
    return myHero.activeSpell and myHero.activeSpell.castEndTime > game.time + Utility:GetLatency()
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

    menu.combo:spacer("headerE", "[W] Settings")
    menu.combo:boolean("use_w", "Use W", true)
    menu.combo:slider('heal_slider', "Don't W if my Health <=", 5, 100, 30, 5)

    menu.combo:spacer("headerW", "[E] Settings")
    menu.combo:boolean("use_e", "Use E", true)

    menu.combo:spacer("headerR", "[R] Settings")
    menu.combo:boolean("use_r", "Use R", true)

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
            delay = 0.5 ,
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
    local pred = pred.positionAfterTime(target, 0.9)
    if not pred then return 0 end
    local dist = Utility:GetDistance(myHero, pred)
    return Input:CastSpell(SpellSlot.Q, pred)

end

function Nami:CalculateReactionTime(target, windup)
    if not target then return end
    local TimeToCast = windup
    local MoveSpeed = target.characterIntermediate.moveSpeed
    local HalfRadius = 100
    local Latency = 0.04
    local CastTime = 0.20
    local InactiveTime = (HalfRadius / MoveSpeed) + TimeToCast + (Latency / 2)
    print(0.976 - InactiveTime)
    return 0.976 - InactiveTime
end

function Nami:OnBasicAttack(obj, attack)
    if obj.team == myHero.team then return end
    if not obj.isHero then return end
    if not attack then return end
    if attack.target and attack.target == myHero then return end
    if self:CalculateReactionTime(obj, attack.castDelay) < 0.39 then 
        self:UseQ(obj)
    end

end

function Nami:OnNewPath(obj, path, isDash, speed)
    if obj.team == myHero.team then return end
    if not obj.isHero then return end
    if not path then return end
    if not isDash then return end
    if not speed then return end
    if not path[2] then return end
    local Endpos = vec3(path[2].x,path[2].y,path[2].z)
    local Endtime = Utility:GetDistance(obj, path[2]) / speed
    if Endtime > 0.976 then 
        return Utility:DelayAction(
        function()
            if Utility:GetDistance(myHero, path[2]) <= self.Spells.Q.range + (self.Spells.Q.radius / 2) then 
            return Input:CastSpell(SpellSlot.Q, Endpos)
            end
        end, 0.976 - Endtime)
    end
    Input:CastSpell(SpellSlot.Q, Endpos) 
end

function Nami:OnProcessSpell(obj, spell)
    if obj.team == myHero.team then return end
    if not obj.isHero then return end
    if not spell then return end
    if spell.name:find("Summoner") then return end
    if self:CalculateReactionTime(obj, spell.castDelay) < 0.39 then 
        self:UseQ(obj)
    end

end

function Nami:OnBuff(obj, buff)
    if obj and obj.team ~= myHero.team and obj.type == myHero.type and buff then
        if  player.position:distance(obj.pos) < 900 then
     if obj:hasBuffOfType(BuffType.Snare) then --or BuffType.Silence or BuffType.Taunt or BuffType.Polymorph or BuffType.Fear or BuffType.Charm or BuffType.Suppression or BuffType.Knockup or BuffType.Knockback or BuffType.Asleep) then
        Input:CastSpell(SpellSlot.Q, obj.pos)
    end
    end
    end
end

function Nami:GetPercentHealth(obj)
    local obj = obj or myHero
    return (obj.health / obj.maxHealth) * 100
  end

function Nami:UseQ(target, prediction)
    if not prediction then return Input:CastSpell(SpellSlot.Q, target) end
    return Input:CastSpell(SpellSlot.Q, prediction.castPosition)

end

function Nami:UseW()
    local ally = nil
    if not ally then ally = get_min_dist_target(objManager.heroes.allies.list, player, 650) end

    if ally then
    if  self:GetPercentHealth(ally) <= menu.combo.heal_slider.value then
        print(menu.combo.heal_slider.value)
        print(self:GetPercentHealth(ally))
        --print(self:GetPercentHealth() >= menu.combo.heal_slider:get())
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
    local target = Utility:GetOrbwalkerTarget()
    if not target then return end
    --if self:IsSpellLocked() then return end

    if menu.combo.use_w:get() then
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
