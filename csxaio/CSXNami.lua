--[[   
Todo:
Blacklist ally
E se ally der spell
Q R for Anti-Gapclose
Q R to Interrupt
KS
castar Q na zonyas
--]]
-- Settings table, will use this instead of retrieving menu value using :get() 
local Settings = {} 

-- Utility "class" constructor
local Utility = {}

local priorityTable = {
    ["Aatrox"] =       3,
    ["Ahri"] =         4,
    ["Akali"] =        4,
    ["Akshan"] =       5,
    ["Alistar"] =      1,
    ["Amumu"] =        1,
    ["Anivia"] =       4,
    ["Annie"] =        4,
    ["Ashe"] =         5,
    ["AurelionSol"] =  4,
    ["Azir"] =         4,
    ["Bard"] =         1,
    ["BelVeth"]  =     3,
    ["Blitzcrank"] =   1,
    ["Brand"] =        4,
    ["Braum"] =        1,
    ["Caitlyn"] =      5,
    ["Camille"] =      1,
    ["Cassiopeia"] =   4,
    ["Chogath"] =      1,
    ["Corki"] =        5,
    ["Darius"] =       1,
    ["Diana"] =        4,
    ["DrMundo"] =      1,
    ["Draven"] =       5,
    ["Ekko"] =         4,
    ["Elise"] =        3,
    ["Evelynn"] =      4,
    ["Ezreal"] =       5,
    ["FiddleSticks"] = 4,
    ["Fiora"] =        3,
    ["Fizz"] =         4,
    ["Galio"] =        1,
    ["Gangplank"] =    3,
    ["Garen"] =        1,
    ["Gnar"] =         1,
    ["Gragas"] =       4,
    ["Graves"] =       1,
    ["Gwen"]   =       3,   
    ["Hecarim"] =      1,
    ["Heimerdinger"] = 4,
    ["Illaoi"] =       1,
    ["Irelia"] =       3,
    ["Ivern"] =        3,
    ["Janna"] =        3,
    ["JarvanIV"] =     1,
    ["Jax"] =          3,
    ["Jayce"] =        4,
    ["Jhin"] =         5,
    ["Jinx"] =         5,
    ["Kaisa"] =        5,
    ["Kalista"] =      5,
    ["Karma"] =        3,
    ["Karthus"] =      4,
    ["Kassadin"] =     4,
    ["Katarina"] =     4,
    ["Kayle"] =        4,
    ["Kayn"] =         3,
    ["Kindred"] =      5,
    ["Kennen"] =       4,
    ["Khazix"] =       3,
    ["Kled"] =         3,
    ["KogMaw"] =       5,
    ["Leblanc"] =      4,
    ["LeeSin"] =       3,
    ["Leona"] =        1,
    ["Lissandra"] =    4,
    ["Lucian"] =       5,
    ["Lulu"] =         3,
    ["Lux"] =          4,
    ["Malphite"] =     1,
    ["Malzahar"] =     4,
    ["Maokai"] =       1,
    ["MasterYi"] =     3,
    ["MissFortune"] =  5,
    ["MonkeyKing"] =   3,
    ["Mordekaiser"] =  4,
    ["Morgana"] =      4,
    ["Nami"] =         3,
    ["Nasus"] =        1,
    ["Nautilus"] =     1,
    ["Neeko"] =        4,
    ["Nidalee"] =      4,
    ["Nillah"] =       1,
    ["Nocturne"] =     3,
    ["Nunu"] =         1,
    ["Olaf"] =         3,
    ["Orianna"] =      4,
    ["Ornn"] =         1,
    ["Pantheon"] =     3,
    ["Poppy"] =        3,
    ["Pyke"] =         4,
    ["Qiyana"] =       3,
    ["Quinn"] =        5,
    ["Rakan"]=         1,
    ["Rammus"] =       1,
    ["RekSai"] =       4,
    ["Rell"] =         1,
    ["Renata"] =       2,
    ["Renekton"] =     1,
    ["Rengar"] =       3,
    ["Riven"] =        3,
    ["Rumble"] =       3,
    ["Ryze"] =         4,
    ["Samira"] =       5,
    ["Sejuani"] =      1,
    ["Senna"]   =      4,
    ["Seraphine"] =    3,
    ["Sett"]      =    3,
    ["Shaco"] =        4,
    ["Shen"] =         1,
    ["Shyvana"] =      1,
    ["Singed"] =       1,
    ["Sion"] =         4,
    ["Sivir"] =        5,
    ["Skarner"] =      1,
    ["Sona"] =         3,
    ["Soraka"] =       5,
    ["Swain"] =        4,
    ["Sylas"] =        4,
    ["Syndra"] =       4,
    ["TahmKench"] =    1,
    ["Taliyah"] =      4,
    ["Talon"] =        4,
    ["Taric"] =        1,
    ["Teemo"] =        4,
    ["Thresh"] =       1,
    ["Tristana"] =     5,
    ["Trundle"] =      1,
    ["Tryndamere"] =   3,
    ["TwistedFate"] =  4,
    ["Twitch"] =       5,
    ["Udyr"] =         1,
    ["Urgot"] =        5,
    ["Varus"] =        5,
    ["Vex"]   =        4,
    ["Vayne"] =        5,
    ["Veigar"] =       4,
    ["Velkoz"] =       4,
    ["Vi"] =           3,
    ["Viego"] =        3, 
    ["Viktor"] =       4,
    ["Vladimir"] =     4,
    ["Volibear"] =     1,
    ["Warwick"] =      1,
    ["Xerath"] =       4,
    ["Xayah"] =        5,
    ["XinZhao"] =      3,
    ["Yasuo"] =        4,
    ["Yorick"] =       1,
    ["Yuumi"] =        3,
    ["Zac"] =          1,
    ["Zed"] =          4,
    ["Zeri"] =         5, 
    ["Ziggs"] =        4,
    ["Zilean"] =       3,
    ["Zoe"] =          4,
    ["Zyra"] =         4,
}

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

function Utility:GetTarget(validator, all)
    if not validator and not all then return ts.getTargets()[1] end

    local enemyTable = {}
    for _, enemy in ipairs(ts.getTargets()) do
        if validator(enemy) then
            table.insert(enemyTable, enemy)
        end
    end
    if not all then
        return enemyTable[1]
    end
    return enemyTable
end

function Utility:GetPrediction(target, inputTable)
    if inputTable.speed == 0 then return end
    local prediction = pred.getPrediction(target, inputTable)
    if prediction  then return end
    return prediction
end

function Utility:CanCastSpell(spell)
    local time = myHero.asHero:getSpell(spell).readyTime
    return time < game.time + Utility:GetLatency()
end 

function Utility:IsCastingSpell()
    return myHero.activeSpell and myHero.activeSpell.castEndTime > game.time + Utility:GetLatency()
end

function Utility:NearestAlly(position)
    local closest = nil
    local lowest  = 10000 

    if not closest then
        for _, ally in pairs(objManager.heroes.allies.list) do
            if not ally or ally.team ~= myHero.team or ally.isDead then return end
            local dist = Utility:GetDistance(ally, position)
            if ally ~= myHero and dist < 150 then
                if dist < lowest then
                    lowest = dist
                    closest = ally
                end
            end
        end
    end

    return closest
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

function Utility:Validate(enemy)
	return enemy
	and enemy.isValid
    and enemy.isVisible
	and not enemy.isDead
	and enemy.asAttackableUnit.isTargetable
	and enemy.maxHealth > 5
    and enemy.maxHealth < 10000
	and not enemy.isInvulnerable
	and enemy.type == myHero.type
end


function Utility:IsValidAlly(ally)
    return ally and not ally.isDead and ally.isHero and ally.isVisible and ally.asAttackableUnit.isTargetable
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

    menu.combo:spacer("headerR", "[R] Settings")
    menu.combo:boolean("use_r", "Use R", true)

    menu:header("harass", "Harass")
    menu.harass:spacer("headerQ", "[Q] Settings")
    menu.harass:boolean("use_q", "Use Q", true)

    menu.harass:spacer("headerW", "[W] Settings")
    menu.harass:boolean("use_w", "Use W", true)

    menu.harass:spacer("headerW", "[E] Settings")
    menu.harass:boolean("use_e", "Use E", true)

    menu:header("prio", "Priority")
        for _, obj in ipairs(objManager.heroes.list) do
            if obj and obj.team == myHero.team then
                local ally = obj
                local priority = priorityTable[ally.skinName] ~= nil and priorityTable[ally.skinName] or 1
                menu.prio:slider(ally.skinName .. "_prio", ally.skinName .. " Priority", 1, 5, priority, 1)
            end

        end
    menu:header("auto", "Automatic")
    menu.auto:spacer("headerQauto", "[Q] Settings")
    menu.auto:boolean("use_q_cc", "Use Q in CC", true)
    menu.auto:boolean("use_q_dash", "Use Q in Dash/Jumps", true)
    menu.auto:boolean("use_q_spells", "Use Q in Spells", true)
    menu.auto:boolean("use_q_aa", "Use Q in AA", true)

    menu.auto:spacer("headerWauto", "[W] Settings")
    menu.auto:boolean("use_w", "Use W", true)
    menu.auto:slider('heal_slider', "Don't W if Health <=", 5, 100, 30, 5)

    menu.auto:spacer("headerEauto", "[E] Settings")
    menu.auto:boolean("use_e_aa", "Use E in ally AA", true)


    menu:header("misc", "Misc")
    menu.misc:keybind('manual_q', 'Manual Q', 0x51, false, false)


    menu:header("drawings", "Drawings")
    menu.drawings:boolean("draw_q", "Draw Q", true)
    menu.drawings:color('color_q', 'Q Color', graphics.argb(255, 255, 0, 0))
    menu.drawings:boolean("draw_w", "Draw W", true)
    menu.drawings:color('color_w', 'W Color', graphics.argb(255, 255, 0, 0))
    menu.drawings:boolean("draw_e", "Draw E", true)
    menu.drawings:color('color_e', 'E Color', graphics.argb(255, 255, 0, 0))
    menu.drawings:boolean("draw_r", "Draw R", true)
    menu.drawings:color('color_r', 'R Color', graphics.argb(255, 255, 0, 0))

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

    self.selectedAlly = nil
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
    cb.add(cb.drawWorld, function() return self:OnDraw() end )
    cb.add(cb.glow, function() return self:OnGlow() end)
    cb.add(cb.basicAttack, function(...) return self:OnBasicAttack(...) end )
    cb.add(cb.processSpell, function(...) return self:OnProcessSpell(...) end )
    cb.add(cb.newPath, function(...) return self:OnNewPath(...) end )

    cb.add(cb.buff,function(...) self:OnBuff(...) end)


    cb.add(cb.unload, function() menu.delete('csxaio') end)
end

function Nami:OnDraw()
    if menu.drawings.draw_q:get() then
        local alpha = myHero:spellSlot(SpellSlot.Q).state == 0 and 255 or 50
        graphics.drawCircle(myHero.pos, self.Spells.Q.range, 1, menu.drawings.color_q:get())
    end
    
    if menu.drawings.draw_w:get() then
        local alpha = myHero:spellSlot(SpellSlot.W).state == 0 and 255 or 50
        graphics.drawCircle(myHero.pos, self.Spells.W.range, 1, menu.drawings.color_w:get())
    end

    if menu.drawings.draw_e:get() then
        local alpha = myHero:spellSlot(SpellSlot.E).state == 0 and 255 or 50
        graphics.drawCircle(myHero.pos, self.Spells.E.range, 1, menu.drawings.color_e:get())
    end
    
    if menu.drawings.draw_r:get() then
        local alpha = myHero:spellSlot(SpellSlot.R).state == 0 and 255 or 50
        graphics.drawCircle(myHero.pos, self.Spells.R.range, 1, menu.drawings.color_r:get())
    end

    if self.selectedAlly then

        graphics.drawCircleFilled(self.selectedAlly.pos, 400, graphics.argb(140, 0, 255, 120))
    end
end

function Nami:OnGlow()
    if self.selectedAlly then
        self.selectedAlly:addGlow(graphics.argb(140, 0, 255, 120), 3, 5)
    end
end

function Nami:GetQSpeed(target)
    if not Utility:Validate(target) then return end
    local pred = pred.positionAfterTime(target, 0.976)
    local points = self:GetMECPoints()
    if points and #points >= 2 then 
        pred = mec.find(points).center
    else
        return Input:CastSpell(SpellSlot.Q, pred)
    end
    if Utility:GetDistance(pred, myHero) <= self.Spells.Q.range + self.Spells.Q.radius / 2 then
        return Input:CastSpell(SpellSlot.Q, pred)
    end

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
    self:QAA(obj, attack)
    self:useE(obj, attack)
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
    if not menu.auto.use_q_dash:get() then return end
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
    if not menu.auto.use_q_spells:get() then return end 
    if obj.team == myHero.team then return end
    if not obj.isHero then return end
    if not spell then return end
    --print(self:CalculateEscapeTime(obj, spell.castDelay))
    if spell.name:find("Summoner") then return end
    if self:CalculateCastToLand() - self:CalculateEscapeTime(obj, spell.castDelay) <= 0.15 then 
        self:UseQ(obj)
    end

end

function Nami:OnBuff(obj, buff)

    if not obj or
    not buff or
    obj.team == myHero.team or 
    obj.type ~= myHero.type or
    not obj.isHero then
        return
    end
    if Utility:GetDistance(obj, myHero) > (self.Spells.Q.range + self.Spells.Q.radius / 2) or
    not menu.auto.use_q_cc:get() then 
        return 
    end

    local ccedTime = pred.getCrowdControlledTime(obj.asAIBase)
    local ping = Utility:GetLatency()
    local castTime = self:CalculateCastToLand()
    local totalTime = ccedTime - castTime + ping + 0.4366
    if totalTime >= self:CalculateEscapeTime(obj, 0) then return end
    if totalTime < 0 then return end

    return Input:CastSpell(SpellSlot.Q, obj.pos)
end

function Nami:GetPercentHealth(obj)
    local obj = obj or myHero
    return (obj.health / obj.maxHealth) * 100
end

function Nami:UseQ(target, prediction)
    if not prediction then return Input:CastSpell(SpellSlot.Q, target) end

    return Input:CastSpell(SpellSlot.Q, prediction.castPosition)
end

function Nami:GetPriority(unit)
    return menu.prio[unit.skinName .. "_prio"] and 6 + menu.prio[unit.skinName .. "_prio"]:get() or 3
end

 
function Nami:SelectAlly()

    if self.selectedAlly and Utility:GetDistance(self.selectedAlly, game.cursorPos) > 120 and keyboard.isKeyDown(0x01) then
        --print(self.selectedAlly.skinName .. " top")
        self.selectedAlly = nil
    end

    local obj = Utility:NearestAlly(game.cursorPos)
    if not obj or obj.team ~= myHero.team or not keyboard.isKeyDown(0x01) then return end

    if obj ~= myHero then
    
        if Utility:GetDistance(obj, game.cursorPos) < 120 then
            self.selectedAlly = obj
            --print(self.selectedAlly.skinName .. " aids")
        end
        
    end
end

function Nami:GetAlly(range)

    if self.selectedAlly ~= nil and Utility:IsValidAlly(self.selectedAlly) and Utility:GetDistance(myHero, self.selectedAlly) < range  then
        return self.selectedAlly
    end

    local attackCount = math.huge
    local healAlly = nil 
    for _, ally in ipairs(objManager.heroes.allies.list) do
      --  print(ally.skinName)
        if not ally or ally.team ~= myHero.team then return end
        if ally ~= myHero and Utility:IsValidAlly(ally) and Utility:GetDistance(myHero, ally) <= range then
            local myDmg = myHero.asAIBase.totalAttackDamage
            local attackNeeded = math.ceil(ally.health / myDmg)
            local compare = (attackNeeded / self:GetPriority(ally))
            if compare < attackCount  then
                attackCount = compare
                healAlly = ally
            end
        end
    end
    return healAlly
end 

function Nami:UseW()
    local ally = self:GetAlly(self.Spells.W.range)
    if ally and ally.healthPercent ~= 100 then
        if ally.healthPercent <= menu.auto.heal_slider.value then
            myHero:castSpell(SpellSlot.W, ally)
        end
    end
end

function Nami:QAA(obj, attack)
    if not menu.auto.use_q_aa:get() then return end 
    if obj.team == myHero.team then return end
    if not obj.isHero then return end
    if not attack then return end
    if attack.target and attack.target == myHero then return end
    if self:CalculateCastToLand() - self:CalculateEscapeTime(obj, attack.castDelay) <= 0.25 then 
        self:UseQ(obj)
    end
end

function Nami:useE(obj, attack)
    if not menu.auto.use_e_aa:get() then return end 
    if obj.team == myHero.team and obj.networkId ~= myHero.networkId and Utility:GetDistance(obj, myHero) < 800 and attack.hasTarget and attack.target.isHero then
        myHero:castSpell(SpellSlot.E, obj)
    end
end

function Nami:UseR(target, prediction)
    if not prediction then return Input:CastSpell(SpellSlot.R, target.pos) end
    return Input:CastSpell(SpellSlot.R, prediction.castPosition)
end

function Nami:GetMECPoints()
    local points = {}
    for _, obj in ipairs(ts.getTargets()) do
        if obj and obj.team ~= myHero.team and Utility:Validate(obj) and Utility:GetDistance(obj, myHero) < self.Spells.Q.range + self.Spells.Q.radius / 2 then
            local pred = pred.positionAfterTime(obj, 0.976)
            if not pred then return end
            table.insert(points, obj)
        end
    end
    return points
end

function Nami:IsSpellLocked()
    return self.spellLocked > game.time
end

function Nami:Combo()
    self:SelectAlly()


    local UseW = menu.auto.use_w:get()
    if UseW then
        self:UseW()
    end


    local target = Utility:GetTarget(function (a) return Utility:GetDistance(a, myHero) < self.Spells.Q.range end) 
    if not target then return end

    --if self:IsSpellLocked() then return end

    local ComboActive = orb.isComboActive
    local HarassActive = orb.harassKeyDown
    local UseQ = menu.combo.use_q:get()
    local UseW = menu.auto.use_w:get()
    --local UseE = menu.auto.use_e:get()
    local UseR = menu.combo.use_r:get()

    local ManualQ = menu.misc.manual_q:get()
    

    if UseW then
        self:UseW()
    end

    if UseQ and ComboActive or ManualQ then
        self:GetQSpeed(target.asAIBase)
    end
end

Menu = Menu()
Nami = Nami()
