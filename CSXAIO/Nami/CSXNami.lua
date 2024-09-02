--[[   
To-Do:
- Implement blacklist for allies' W and E abilities.
- Add functionality to cast Q on targets in Zhonya's Hourglass.
--]]

local Settings = {} 

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
    p1 = p1.x and p1 or p1.pos
    p2 = p2 and (p2.x and p2 or p2.pos) or myHero.position
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function Utility:GetDistance(p1, p2)
    return math.sqrt(self:GetDistanceSqr(p1, p2))
end

function Utility:GetLatency()
    return game.latency / 2000
end

function Utility:FilterEnemies(a, b)
    return a.health < b.health and a.characterIntermediate.armor < b.characterIntermediate.armor and a.spellBlock < b.spellBlock
end

function Utility:GetOrbwalkerTarget()
    return orb.comboTarget
end

function Utility:GetTarget(validator, all)
    local targets = ts.getTargets()
    if not validator and not all then
        return targets[1]
    end

    local validTargets = {}
    for _, enemy in ipairs(targets) do
        if validator(enemy) then
            table.insert(validTargets, enemy)
        end
    end

    return all and validTargets or validTargets[1]
end

function Utility:GetPrediction(target, inputTable)
    if inputTable.speed == 0 then return end
    return pred.getPrediction(target, inputTable)
end

function Utility:CanCastSpell(spell)
    local readyTime = myHero.asHero:getSpell(spell).readyTime
    return readyTime < game.time + self:GetLatency()
end

function Utility:IsCastingSpell()
    return myHero.activeSpell and myHero.activeSpell.castEndTime > game.time + self:GetLatency()
end

function Utility:NearestAlly(position)
    local closest, lowestDistance = nil, 10000

    for _, ally in pairs(objManager.heroes.allies.list) do
        if self:IsValidAlly(ally) then
            local distance = self:GetDistance(ally, position)
            if ally ~= myHero and distance < 150 and distance < lowestDistance then
                lowestDistance = distance
                closest = ally
            end
        end
    end

    return closest
end

local delayedActions, delayedActionsExecutor = {}, nil
function Utility:DelayAction(func, delay, args)
    if not delayedActionsExecutor then
        delayedActionsExecutor = function()
            for time, actions in pairs(delayedActions) do
                if time <= os.clock() then
                    for _, action in ipairs(actions) do
                        if action.func then
                            action.func(unpack(action.args or {}))
                        end
                    end
                    delayedActions[time] = nil
                end
            end
        end
        cb.add(cb.tick, delayedActionsExecutor)
    end

    local executionTime = os.clock() + (delay or 0)
    if not delayedActions[executionTime] then
        delayedActions[executionTime] = {}
    end
    table.insert(delayedActions[executionTime], {func = func, args = args})
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
    return ally and ally.isHero and not ally.isDead and ally.isVisible and ally.asAttackableUnit.isTargetable
end
-- Input "class" constructor
local Input = {}

function Input:CastSpell(spell, castPos)
    if not spell or Utility:IsCastingSpell() or not Utility:CanCastSpell(spell) then return end

    local pos = castPos and castPos.x and castPos or myHero.pos

    if (spell == SpellSlot.W or spell == SpellSlot.E) and castPos and castPos.pos then
        return myHero:castSpell(spell, vec3(castPos.pos.x, 0, castPos.pos.z))
    else
        return myHero:castSpell(spell, vec3(pos.x, 0, pos.z))
    end
end

function Input:SendMove(pos)
    if pos then
        return myHero:SendMove(pos)
    end
end

function Input:SendAttack(unit)
    if unit then
        return myHero:SendAttack(unit)
    end
end

-- Menu "class" constructor
local Menu = setmetatable({}, {
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)
        return result
    end
})

function Menu:init()
    menu = menu.create("csxaio", "CSXAIO")
    menu:spacer("header1", "CSX Nami")

    menu:header("combo", "Combo")
    menu.combo:spacer("headerQ", "[Q] Settings")
    menu.combo:boolean("use_q", "Use Q", true)

    menu:header("auto", "Automatic")
    menu.auto:spacer("headerQauto", "[Q] Settings")
    menu.auto:boolean("use_q_cc", "Use Q on CC", true)
    menu.auto:boolean("use_q_dash", "Use Q on Dashes/Jumps", true)
    menu.auto:boolean("use_q_spells", "Use Q on Spells", false)
    menu.auto:boolean("use_q_aa", "Use Q on AA", true)
    menu.auto:boolean("use_q_channeling", "Use Q to Interrupt", true)

    menu.auto:spacer("headerWauto", "[W] Settings")
    menu.auto:boolean("use_w", "Use W", true)
    menu.auto:slider('heal_slider', "Only W if Health <=", 5, 100, 30, 5)
    menu.auto:boolean("use_w_ks", "Use W for KillSteal", false)

    menu.auto:spacer("headerEauto", "[E] Settings")
    menu.auto:boolean("use_e_aa", "Use E on Ally AA", true)
    menu.auto:boolean("use_e_spells", "Use E on Ally Spells", true)

    menu:header("prio", "Priority")
    for _, ally in ipairs(objManager.heroes.list) do
        if ally and ally.team == myHero.team then
            local priority = priorityTable[ally.skinName] or 1
            menu.prio:slider(ally.skinName .. "_prio", ally.skinName .. " Priority", 1, 5, priority, 1)
        end
    end

    menu:header("misc", "Miscellaneous")
    menu.misc:keybind('manual_q', 'Manual Q', 0x51, false, false)
    menu.misc:keybind('manual_r', 'Manual R', 0x52, false, false)

    menu:header("drawings", "Drawings")
    menu.drawings:boolean("draw_q", "Draw Q Range", true)
    menu.drawings:boolean("draw_w", "Draw W Range", false)
    menu.drawings:boolean("draw_e", "Draw E Range", false)
    menu.drawings:boolean("draw_r", "Draw R Range", false)
end

-- Nami "class" constructor
local Nami = setmetatable({}, {
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)
        return result
    end
})
function Nami:init()
    self.selectedAlly = nil
    self.castTime = {0, 0, 0, 0}

    self.Spells = {
        Q = {
            delay = 1,
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
    cb.add(cb.tick, function() self:Combo() end)
    cb.add(cb.drawWorld, function() self:OnDraw() end)
    cb.add(cb.glow, function() self:OnGlow() end)
    cb.add(cb.basicAttack, function(...) self:OnBasicAttack(...) end)
    cb.add(cb.processSpell, function(...) self:OnProcessSpell(...) end)
    cb.add(cb.newPath, function(...) self:OnNewPath(...) end)
    cb.add(cb.buff, function(...) self:OnBuff(...) end)
    cb.add(cb.unload, function() menu.delete('csxaio') end)
end

function Nami:OnDraw()
    if menu.drawings.draw_q:get() then
        graphics.drawCircleRainbow(myHero.pos, self.Spells.Q.range, 1.5, 2)
    end
    
    if menu.drawings.draw_w:get() then
        graphics.drawCircleRainbow(myHero.pos, self.Spells.W.range, 1.5, 2)
    end

    if menu.drawings.draw_e:get() then
        graphics.drawCircleRainbow(myHero.pos, self.Spells.E.range, 1.5, 2)
    end
    
    if menu.drawings.draw_r:get() then
        graphics.drawCircleRainbow(myHero.pos, self.Spells.R.range, 1.5, 2)
    end

    if self.selectedAlly then
        graphics.drawCircleFilled(self.selectedAlly.pos, 200, graphics.argb(140, 0, 10, 120))
    end
end

function Nami:OnGlow()
    if self.selectedAlly then
        self.selectedAlly:addGlow(graphics.argb(140, 0, 255, 120), 3, 5)
    end
end

function Nami:GetQSpeed(target)
    if not Utility:Validate(target) then return end

    local predictedPos = pred.positionAfterTime(target, 1)
    local points = self:GetMECPoints()

    if points and #points >= 2 then 
        predictedPos = mec.find(points).center
    end

    if Utility:GetDistance(predictedPos, myHero) <= self.Spells.Q.range + self.Spells.Q.radius / 2 then
        Input:CastSpell(SpellSlot.Q, predictedPos)
    end
end
function Nami:getWDamage()
    local baseDamage = {70, 110, 150, 190, 230}
    local apScale = 0.5
    return baseDamage[myHero:spellSlot(SpellSlot.W).level] + apScale * myHero.asAIBase.totalAbilityPower
end

function Nami:CalculateEscapeTime(target, windup)
    if not target then return end
    local timeToCast = windup
    local moveSpeed = target.characterIntermediate.moveSpeed
    local halfRadius = 100
    local latency = Utility:GetLatency()
    local castTime = 0.25
    local inactiveTime = (halfRadius / moveSpeed) + latency + timeToCast
    return inactiveTime
end

function Nami:CalculateCastToLand()
    return 0.25 + 0.726 - Utility:GetLatency()
end

function Nami:OnBasicAttack(obj, attack)
    self:QAA(obj, attack)
    self:useE(obj, attack)
end

function Nami:OnProcessSpell(obj, spell)
    self:useQspell(obj, spell)
    self:useEspell(obj, spell)
end

function Nami:isCastingInterruptibleSpell(obj)
    self:channelingSpell(obj)
end

function Nami:OnNewPath(obj, path, isDash, speed)
    if obj.team == myHero.team or not obj.isHero or not path or not isDash or not speed or not path[2] then return end

    local endPos = vec3(path[2].x, path[2].y, path[2].z)
    local endTime = Utility:GetDistance(obj, path[2]) / speed

    if not menu.auto.use_q_dash:get() then return end

    if endTime > 0.976 then
        Utility:DelayAction(function()
            if Utility:GetDistance(myHero, path[2]) <= self.Spells.Q.range + (self.Spells.Q.radius / 2) then
                Input:CastSpell(SpellSlot.Q, endPos)
            end
        end, 0.976 - endTime)
    else
        print("Q for Dash/Jump")
        Input:CastSpell(SpellSlot.Q, endPos)
    end
end

function Nami:OnBuff(obj, buff)
    if not obj or not buff or obj.team == myHero.team or obj.type ~= myHero.type or not obj.isHero or not Utility:Validate(obj) then return end

    if Utility:GetDistance(obj, myHero) > (self.Spells.Q.range + self.Spells.Q.radius / 2) or not menu.auto.use_q_cc:get() then return end

    local ccedTime = pred.getCrowdControlledTime(obj.asAIBase)
    local ping = Utility:GetLatency()
    local castTime = self:CalculateCastToLand()
    local totalTime = ccedTime - castTime + ping + 0.4366

    if totalTime >= self:CalculateEscapeTime(obj, 0) or totalTime < 0 then return end

    print("Casting Q for CC")
    Input:CastSpell(SpellSlot.Q, obj.pos)
end

function Nami:GetPercentHealth(obj)
    obj = obj or myHero
    return (obj.health / obj.maxHealth) * 100
end

function Nami:GetPriority(unit)
    return menu.prio[unit.skinName .. "_prio"] and 6 + menu.prio[unit.skinName .. "_prio"]:get() or 3
end

function Nami:SelectAlly()
    if self.selectedAlly and Utility:GetDistance(self.selectedAlly, game.cursorPos) > 120 and keyboard.isKeyDown(0x01) then
        self.selectedAlly = nil
    end

    local ally = Utility:NearestAlly(game.cursorPos)
    if not ally or ally.team ~= myHero.team or not keyboard.isKeyDown(0x01) then return end

    if ally ~= myHero and Utility:GetDistance(ally, game.cursorPos) < 120 then
        self.selectedAlly = ally
    end
end

function Nami:GetAlly(range)
    if self.selectedAlly and Utility:IsValidAlly(self.selectedAlly) and Utility:GetDistance(myHero, self.selectedAlly) < range then
        return self.selectedAlly
    end

    local attackCount = math.huge
    local healAlly = nil 
    for _, ally in ipairs(objManager.heroes.allies.list) do
        if ally and ally.team == myHero.team and ally ~= myHero and Utility:IsValidAlly(ally) and Utility:GetDistance(myHero, ally) <= range then
            local attackNeeded = math.ceil(ally.health / myHero.asAIBase.totalAttackDamage)
            local compare = attackNeeded / self:GetPriority(ally)
            if compare < attackCount then
                attackCount = compare
                healAlly = ally
            end
        end
    end
    return healAlly
end 

function Nami:channelingSpell()
    for _, target in ipairs(ts.getTargets()) do                          
        if not target or target.isZombie or not target:isValidTarget(self.Spells.Q.range, true, myHero.pos) then goto continue end

        if Utility:GetDistance(target, myHero) > (self.Spells.Q.range + self.Spells.Q.radius / 2) or not menu.auto.use_q_channeling:get() then 
            return 
        end

        local useQ = menu.auto.use_q_channeling:get()
        local hasBuff = target.isUnstoppable or target:findBuff("MorganaE") or target:findBuff("bansheesveil") or target:findBuff("itemmagekillerveil") or target:findBuff("malzaharpassiveshield")
        local isChanneling = target.isCastingInterruptibleSpell and target.isCastingInterruptibleSpell > 0

        if hasBuff and hasBuff.valid then return end

        if useQ and isChanneling then
            myHero:castSpell(SpellSlot.Q, target)
        end

        ::continue::
    end
end

function Nami:KillSteal()
    if myHero:spellSlot(SpellSlot.W).state ~= 0 or not menu.auto.use_w_ks:get() then return end

    for _, target in ipairs(objManager.heroes.list) do
        if target.isEnemy and target.isVisible and target.isTargetable and not target.isDead and target:isValidTarget(self.Spells.W.range, true, myHero.pos) then
            if self:getWDamage() >= target.health then
                myHero:castSpell(SpellSlot.W, target)
            end
        end
    end
end

function Nami:QAA(obj, attack)
    if not menu.auto.use_q_aa:get() or obj.team == myHero.team or not obj.isHero or not attack or attack.target == myHero then return end
    if Utility:GetDistance(obj, myHero) > (self.Spells.Q.range + self.Spells.Q.radius / 2) then return end
    if self:CalculateCastToLand() - self:CalculateEscapeTime(obj, attack.castDelay) <= 0.25 then 
        self:UseQ(obj)
    end
end

function Nami:useQspell(obj, spell)
    if not menu.auto.use_q_spells:get() or obj.team == myHero.team or not obj.isHero or not spell or spell.name:find("Summoner") then return end
    if Utility:GetDistance(obj, myHero) > (self.Spells.Q.range + self.Spells.Q.radius / 2) then return end
    if self:CalculateCastToLand() - self:CalculateEscapeTime(obj, spell.castDelay) <= 0.15 then 
        self:UseQ(obj)
    end
end

function Nami:GetMECPoints()
    local points = {}
    for _, obj in ipairs(ts.getTargets()) do
        if obj and obj.team ~= myHero.team and Utility:Validate(obj) and Utility:GetDistance(obj, myHero) < self.Spells.Q.range + self.Spells.Q.radius / 2 then
            local predPos = pred.positionAfterTime(obj, 0.976)
            if predPos then
                table.insert(points, obj)
            end
        end
    end
    return points
end

function Nami:UseQ(target, prediction)
    if prediction then
        Input:CastSpell(SpellSlot.Q, prediction.castPosition)
    else
        Input:CastSpell(SpellSlot.Q, target)
    end
end

function Nami:UseW()
    local ally = self:GetAlly(self.Spells.W.range)
    if ally and ally.healthPercent < 100 and ally.healthPercent <= menu.auto.heal_slider.value then
        myHero:castSpell(SpellSlot.W, ally)
    end
end

function Nami:useE(obj, attack)
    if menu.auto.use_e_aa:get() and obj.team == myHero.team and obj.networkId ~= myHero.networkId and Utility:GetDistance(obj, myHero) < 800 and attack.hasTarget and attack.target.isHero then
        myHero:castSpell(SpellSlot.E, obj)
    end
end

function Nami:useEspell(obj, spell)
    if menu.auto.use_e_spells:get() and obj.isHero and spell and not spell.name:find("Summoner") and obj.team == myHero.team and obj.networkId ~= myHero.networkId and Utility:GetDistance(obj, myHero) < 800 and spell.hasTarget and spell.target.isHero then
        myHero:castSpell(SpellSlot.E, obj)
    end
end

function Nami:UseR(target, prediction)
    if prediction then
        Input:CastSpell(SpellSlot.R, prediction.castPosition)
    else
        Input:CastSpell(SpellSlot.R, target.pos)
    end
end

function Nami:IsSpellLocked()
    return self.spellLocked > game.time
end

function Nami:Combo()
    self:SelectAlly()
    self:channelingSpell()
    self:KillSteal()

    if menu.auto.use_w:get() then
        self:UseW()
    end

    if menu.misc.manual_r:get() then
        local target = Utility:GetTarget(function (a) return Utility:GetDistance(a, myHero) < 2650 end)
        if target then
            self:UseR(target.asAIBase)
        end
    end

    local target = Utility:GetTarget(function (a) return Utility:GetDistance(a, myHero) < self.Spells.Q.range end)
    if not target then return end

    if menu.combo.use_q:get() and orb.isComboActive or menu.misc.manual_q:get() then
        self:GetQSpeed(target.asAIBase)
    end
end

Menu = Menu()
Nami = Nami()