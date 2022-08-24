-- This script is designed to show Lua beginners how to create there own scripts and using Corrupt API.
-- There will be alot of comments in this script, so please read it carefully and try to understand what each line is doing.
-- This script should define the baseline quality of a script what we expect to be released at Corrupt.
-- If you have any questions, please ask on discord or on the forum.

-- Small usefull functions which were needed to find buff names, object names, etc.
-- These functions are not needed for the script to work, but they are nice to have.

-- Gets all buff that the unit has and prints them to the console.
-- function Debug_FindBuff(unit)
--     for index, value in ipairs(unit.buffs) do
--         print(value.name .. " Counter: " .. value.counter .. " Stacks: " .. value.stacks)
--     end
-- end

-- This callback is called when the script is loaded.

cb.add(cb.load, function()

    -- Check if the current champion is Annie. If not, don't load the script
    if player.skinName ~= "Nami" then return end

    -- Create a 'class/table' where all the functions will be stored
    local Nami = {}
    local HitchanceMenu = { [0] = HitChance.Low, HitChance.Medium, HitChance.High, HitChance.VeryHigh, HitChance.DashingMidAir } -- this creates a table that starts at 0 lining up with the hitchanes in our menu, really makes it easy going from hitchance in menu to actual hitchance.

    -- Creating a debug print function, so the developer can easily check the output and if someone
    -- wants to play with the simple script can disable the debug prints in the console
    function Nami:DebugPrint(...)
        if not self.NamiMenu.debug_print:get() then return end
        print("[Corrupted-Nami] ".. ...)
    end

    -- This will be our initialization function, we call it to load the script and all its variables and functions inside
    function Nami:__init()
	
		self.castTime = {0,0,0,0}

        -- tables with spell data for prediction
		self.qData = {
            delay = 1,
            speed = math.huge,
            range = 800,
            radius= 200,
            type = spellType.circular,
            collision = {
                hero = SpellCollisionType.Hard,
                minion = SpellCollisionType.Hard,
                tower = SpellCollisionType.None,

                flags = bit.bor(CollisionFlags.Windwall, CollisionFlags.Samira, CollisionFlags.Braum)
            }
        }
        self.rData = {
            delay = 0.5,
            speed = 1300,
            range = 2500,
			radius = 300,
            width = 500,
            type = spellType.linear,
            collision = {
                hero = SpellCollisionType.Hard,
                minion = SpellCollisionType.Hard,
                tower = SpellCollisionType.None,

                flags = bit.bor(CollisionFlags.Windwall, CollisionFlags.Samira, CollisionFlags.Braum)
            }
        }

        -- self.AnnieMenu will store all the menu data which got returned from the Annie:CreateMenu function
        self.NamiMenu = self:CreateMenu()

        -- Adding all callbacks that will be used in the script, the triple dots (...) means that the function will
        -- take the return value of the function before it, so we can use it in our function
		cb.add(cb.tick,function(...) self:OnTick(...) end)
        cb.add(cb.draw,function(...) self:OnDraw(...) end)
        cb.add(cb.processSpell,function(...) self:OnCastSpell(...) end)
    end

    -- This function will create the menu and return it to the Annie:__init function and store it in self.AnnieMenu
    function Nami:CreateMenu()
        -- Create the main menu
        local mm = menu.create('csxaio', 'CSXAIO')

        mm:spacer("csxNami", "CyberSex Nami")

        mm:header('combo', 'Combo Mode')
        mm.combo:boolean('use_q', 'Use Q', true)
        mm.combo:list('q_hitchance', 'Q Hitchance', { 'Low', 'Medium', 'High', 'Very High', 'Undodgeable' }, 2) -- these fuckers start at 0 compared to lua starting at 1, be aware of that
        mm.combo:boolean('use_e', 'Use E', true)
        mm.combo:list('e_hitchance', 'E Hitchance', { 'Low', 'Medium', 'High', 'Very High', 'Undodgeable' }, 2) -- these fuckers start at 0 compared to lua starting at 1, be aware of that

        -- Return menu data
        return mm
    end
	
	
    -- Calculates the damage of a spell on a target, if spell is on cooldown it will return 0.
    -- The time variable will be a buffer for the spell cooldown. ( If time is set to 0.5 it will ignore the cooldown of the spell if the cooldown is 0.5 seconds or less )

	function Nami:GetDamageQ(target, time)
        local spell = player:spellSlot(SpellSlot.Q)
        if spell.level == 0 then return 0 end
        local time = time or 0
        if spell.state ~= 0 and spell.cooldown > time then return 0 end
        local damage = 35 + 45 * spell.level + player.totalAbilityPower
        return damageLib.physical(player, target, damage)
    end
	function Nami:GetDamageE(target, time)
        local spell = player:spellSlot(SpellSlot.Q)
        if spell.level == 0 then return 0 end
        local time = time or 0
        if spell.state ~= 0 and spell.cooldown > time then return 0 end
        local damage = 15 + 45 * spell.level + player.totalAbilityPower
        return damageLib.physical(player, target, damage)
    end
	

	function Nami:OnTick()
        if player.isDead or player.teleportType ~= TeleportType.Null then return end -- we don't want to be doing shit if we're dead or teleporting

        self:Combo()

    end
	
    -- This function will include all the logics for the combo mode
    function Nami:Combo()

        if orb.isComboActive == false then return end -- checks if we're holding down the key to combo
        local target = ts.getInRange(675)

        if target and target:isValidTarget(675, true, player.pos) then
        self:CastQ(target,"combo")
        self:CastE(target,"combo")
        end

    end

    -- This function will cast Q on the target, the mode attribute is used to check if its enabled in the menu based on mode, as we created the menu similar for combo and harass.
    function Nami:CastQ(target, mode)
        
                -- Check if use W is enabled in the menu, based on the mode, if not we will return and do nothing.
                if self.NamiMenu[mode].use_q:get() == false then return end
                -- Check if spell is ready to cast
                if player:spellSlot(SpellSlot.Q).state ~= 0 then return end
                if player.isWindingUp then return end -- checks if we're going to cancel an aa
                if player.canAttack == false then return end -- checks if we're in the middle of a spellcast

                for _, enemy in pairs(ts.getTargets()) do -- gets each target ordered by best to worst (according to the target selector)
                    if ts.selected and -- if we have a forced target (with left click)
                            enemy.handle ~= ts.selected.handle and -- and it isn't the target currently being tested
                            ts.selected.isDead == false -- and the target we've clicked on hasn't died already
                    then goto continue end -- try the next target
                    if not enemy:isValidTarget(math.huge, true, player.pos) then goto continue end -- if our target isn't valid try next target
                    if enemy:hasBuffOfType(BuffType.SpellImmunity) then goto continue end -- checks if they're immune to spells don't want to waste anything :P
                    local prediction = pred.getPrediction(enemy, self.qData) -- get our prediction with the data from q
                    if not (prediction and prediction.castPosition.isValid) then goto continue end -- if we didn't get a proper prediction go next target
                    
                   if prediction.hitChance >= HitChance.High then
                        --self:DebugPrint("Cast Q")
                        player:castSpell(SpellSlot.Q, prediction.castPosition, false, false)
                    end
                ::continue:: -- this is the "checkpoint" we goto to continue the loop
            end
    end

	
    function Nami:CastE(target, mode)
	end

    -- This function will be called every time the player draws a screen (based on FPS)
    -- This is where all drawing code will be executed
    function Nami:OnDraw()
    end

    -- This function will be called every time someone did cast a spell.
    function Nami:OnCastSpell(source, spell)
    end

    -- Call the initialization function
    Nami:__init()

end)

-- This callback is called when the script gets unloaded.
cb.add(cb.unload, function()
    -- We delete the menu for our script, with the same name as we created it.
    menu.delete('csxaio')
end)