function Utility:CanCastSpell(spell)
    local time = myHero.asHero:getSpell(spell).readyTime
    return time < game.time + Utility:GetLatency()
end 

function Utility:IsCastingSpell()
    return myHero.activeSpell and myHero.activeSpell.castEndTime > game.time + Utility:GetLatency()
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

local Menu = setmetatable({}, 
{
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)

        return result
    end
})

function Menu:init()
    menu = menu.create("CyberSeXAOI", "CyberSex AIO")
    menu:spacer("header1", "Sex Kindred")

    menu:header("combo", "Combo")
    menu.combo:spacer("headerQ", "[Q] Settings")
    menu.combo:boolean("use_q", "Use Q", true)
    menu.combo:spacer("headerQ", "[E] Settings")
    menu.combo:boolean("use_q", "Use E", true)
    menu.combo:spacer("headerQ", "[W] Settings")
    menu.combo:boolean("use_q", "Use W", true)

    menu:header("misc", "Misc")
    menu.misc:keybind('manual_q', 'Manual E', 0x51, false, false)

    menu:header("drawings", "Drawings")
    menu.drawings:boolean("draw_q", "Draw Q", true)
    menu.drawings:boolean("draw_w", "Draw W", false)
    menu.drawings:boolean("draw_e", "Draw E", false)
    menu.drawings:boolean("draw_r", "Draw R", false)

end

-- Kindred "class" constructor
local Kindred = setmetatable({}, 
{
    __call = function(self, ...)
        local result = setmetatable({}, {__index = self})
        result:init(...)

        return result
    end
})

function Kindred:init()

    self.selectedAlly = nil
    self.castTime = {0,0,0,0}

    self.Spells = {

        Q = {
            range = 340
        },
        
        E = {
            range = 629
        },
        R = {
            range = 535
        }
    }
    self.heroes = {}
    self.allyHeroes = {}
    self.enemyHeroes = {}
    self:LoadEvents()
end

function Kindred:LoadEvents()
    cb.add(cb.tick, function() return self:Combo() end )
    cb.add(cb.buff,function(...) self:OnBuff(...) end)
    cb.add(cb.unload, function() menu.delete('CyberSeXAOI') end)
end

function Kindred:OnDraw()
    if menu.drawings.draw_q:get() then
       -- local alpha = myHero:spellSlot(SpellSlot.Q).state == 0 and 255 or 50
        --graphics.drawCircle(myHero.pos, self.Spells.Q.range, 1, menu.drawings.color_q:get())
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
end

Menu = Menu()
Kindred = Kindred()