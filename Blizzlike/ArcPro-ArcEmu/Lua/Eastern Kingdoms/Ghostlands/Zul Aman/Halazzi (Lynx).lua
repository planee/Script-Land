--[[ ArcPro Speculation License - 
This software is provided as free and open source by the
team of The ArcPro Speculation Team. This script was written and is
protected by the GPL v2. Please give credit where credit
is due, if modifying, redistributing and/or using this 
software. Thank you.
Author: ArcPro Speculation
~~End of License... Please Stand By...
-- ArcPro Speculation, January 19, 2011 - 2013. ]]

function Halazzi_OnSpawn(Unit)
	local args = getvars(Unit)
	if((args == nil) or (args.HALAZZI == nil)) then
		setvars(Unit,{HALAZZI = {
		m_phase = 0,
		merge = true,
		halazzihp = 0,
		maxhp = 0,
		lynxptr = nil,
		halazziptr = nil,
		splits = 0,
		}})
	end
end

function Halazzi_OnCombat(Unit)
	local args = getvars(Unit)
	args.HALAZZI.halazziptr = Unit
	args.HALAZZI.maxhp = Unit:GetUInt32Value(UnitField.Unit_FIELD_MAXHEALTH);
	args.HALAZZI.m_phase = 1
	Halazzi_PhaseCheck(Unit)
	Unit:SendChatMessage(ChatField.CHAT_MSG_MONSTER_YELL, LangField.LANG_UNIVERSAL, "Get on your knees and bow to da fang and claw!")
	Unit:PlaySoundToSet(12020)
end

function Halazzi_OnKillPlayer(Unit,event,mTarget)
	if(type(mTarget) == "userdata") then
		local choice = math.random(1,2)
		if(choice == 1) then
			Unit:SendChatMessage(ChatField.CHAT_MSG_MONSTER_YELL, LangField.LANG_UNIVERSAL, "You cant fight da power...")
			Unit:PlaySoundToSet(12026)
		elseif(choice == 2) then
			Unit:SendChatMessage(ChatField.CHAT_MSG_MONSTER_YELL, LangField.LANG_UNIVERSAL, "You all gonna fail...")
			Unit:PlaySoundToSet(12027)
		end
	end
end

function Halazzi_OnWipe(Unit)
	Halazzi_SetForm(Unit,"LYNX")
	Unit:RemoveEvents()
	Unit:RemoveAIUpdateEvent()
end

function Halazzi_OnDeath(Unit)
	Halazzi_SetForm(Unit,"LYNX")
	Unit:RemoveEvents()
	Unit:RemoveAIUpdateEvent()
	Unit:SendChatMessage(ChatField.CHAT_MSG_MONSTER_YELL, LangField.LANG_UNIVERSAL, "Chaga... choka'jinn.")
	Unit:PlaySoundToSet(12028)
end

function Halazzi_AIUpdate(Unit)
	local args = getvars(Unit)
	local hp = Unit:GetHealthPct()
	if((hp <= 75) and (hp > 50) and (args.HALAZZI.m_phase ~= 2) and (args.HALAZZI.splits == 0) and (args.HALAZZI.merge == true)) then
		Unit:RemoveEvents()
		args.HALAZZI.m_phase = 2
		args.HALAZZI.splits = 1
		args.HALAZZI.merge = false
		Halazzi_Split(Unit)
		Halazzi_PhaseCheck(Unit)
	elseif((hp <= 50) and (hp > 25) and (args.HALAZZI.m_phase ~= 2) and (args.HALAZZI.splits == 1) and (args.HALAZZI.merge == true)) then
		Unit:RemoveEvents()
		args.HALAZZI.m_phase = 2
		args.HALAZZI.splits = 2
		args.HALAZZI.merge = false
		Halazzi_Split(Unit)
		Halazzi_PhaseCheck(Unit)
	elseif((hp <= 25) and (hp > 20) and (args.HALAZZI.m_phase ~= 2) and (args.HALAZZI.splits == 2) and (args.HALAZZI.merge == true)) then
		Unit:RemoveEvents()
		args.HALAZZI.m_phase = 2
		args.HALAZZI.splits = 3
		args.HALAZZI.merge = false
		Halazzi_Split(Unit)
		Halazzi_PhaseCheck(Unit)
	elseif((hp <= 20) and (hp > 10) and (args.HALAZZI.m_phase ~= 3) and (args.HALAZZI.splits == 3) and (args.HALAZZI.merge == true)) then
		Unit:RemoveEvents()
		args.HALAZZI.merge = true
		args.HALAZZI.m_phase = 3
		Halazzi_PhaseCheck(Unit)
	end
	if((args.HALAZZI.m_phase == 2) and (args.HALAZZI.merge == false) and (hp <= 20)) then
		args.HALAZZI.merge = true
		args.HALAZZI.m_phase = 1
		Halazzi_Split(Unit)
		Halazzi_PhaseCheck(Unit)
	end
end

function Halazzi_SaberSlash(Unit)
	local tank = Unit:GetMainTank()
	if(type(tank) == "userdata") then
		local choice = math.random(1,2)
		if(choice == 1) then
			Unit:SendChatMessage(ChatField.CHAT_MSG_MONSTER_YELL, LangField.LANG_UNIVERSAL, "Me gonna carve ya now!")
			Unit:PlaySoundToSet(12023)
		elseif(choice == 2) then
			Unit:SendChatMessage(ChatField.CHAT_MSG_MONSTER_YELL, LangField.LANG_UNIVERSAL, "You gonna leave in pieces!")
			Unit:PlaySoundToSet(12024)
		end
		Unit:FullCastSpellOnTarget(43267, tank)
		Unit:RegisterEvent("Halazzi_SaberSlash", math.random(20000,30000), 1)
	end
end

function Halazzi_ShockSpells(Unit)
	local args = getvars(Unit)
	if(args.HALAZZI.merge ~= true) then
		return
	end
	local rand = math.random(1,2)
	local plr = Unit:GetRandomPlayer(0)
	if(type(plr) == "userdata") then
		if(rand == 1) then
			Unit:FullCastSpellOnTarget(43303, plr)
		elseif(rand == 2) then
			Unit:FullCastSpellOnTarget(43305, plr)
		end
		Unit:RegisterEvent("Halazzi_ShockSpells", math.random(10000,20000), 1)
	end
end

function Halazzi_CorruptedTotem(Unit)
	local totem = Unit:SpawnCreature(24224, Unit:GetX()+math.cos(40,60)*3, Unit:GetY()+math.sin(40,60)*3, Unit:GetZ(), Unit:GetO(), 14, 20000)
	totem:AttackReaction(Unit:GetNextTarget(), 1, 0)
	Unit:RegisterEvent("Halazzi_CorruptedTotem", math.random(15000,20000), 1)
end

function Halazzi_PeriodicEnrage(Unit)
	local args = getvars(Unit)
	Unit:FullCastSpell(43139)
	Unit:RegisterEvent("Halazzi_PeriodicEnrage", math.random(10000,15000), 1)
end

function Halazzi_Split(Unit)
	local args = getvars(Unit)
	if(args.HALAZZI.merge == false) then
		Halazzi_SetForm(Unit, "TROLL")
		Unit:SendChatMessage(ChatField.CHAT_MSG_MONSTER_YELL, LangField.LANG_UNIVERSAL, "I fight wit' untamed spirit...")
		Unit:PlaySoundToSet(12021)
		args.HALAZZI.halazzihp = Unit:GetHealth()
		Unit:SetUInt32Value(UnitField.Unit_FIELD_MAXHEALTH, 400000)
		args.HALAZZI.lynxptr = Unit:SpawnCreature(24143, Unit:GetX()+math.cos(20,30)*3, Unit:GetY()+math.sin(20,40)*3, Unit:GetZ(), Unit:GetO(), Unit:GetUInt32Value(UnitField.Unit_FIELD_FACTIONTEMPLATE), 0)
		args.HALAZZI.lynxptr:SetUInt32Value(UnitField.Unit_FIELD_MAXHEALTH, 200000)
		args.HALAZZI.lynxptr:AttackReaction(Unit:GetNextTarget(), 1, 0)
		Unit:FullCastSpell(44054)
	elseif(args.HALAZZI.merge == true) then
		Halazzi_SetForm(Unit, "LYNX")
		Unit:SendChatMessage(ChatField.CHAT_MSG_MONSTER_YELL, LangField.LANG_UNIVERSAL, "Spirit, come back to me!")
		Unit:PlaySoundToSet(12022)
		args.HALAZZI.lynxptr:RemoveFromWorld()
		Unit:SetUInt32Value(UnitField.Unit_FIELD_MAXHEALTH, args.HALAZZI.maxhp)
		Unit:SetUInt32Value(UnitField.Unit_FIELD_HEALTH, args.HALAZZI.halazzihp)
	end
end

function Halazzi_PhaseCheck(Unit)
	local args = getvars(Unit)
	if((args.HALAZZI.merge == false) and (args.HALAZZI.m_phase == 2)) then
		Unit:RegisterEvent("Halazzi_ShockSpells", math.random(10000,20000), 1)
		Unit:RegisterEvent("Halazzi_CorruptedTotem", math.random(10000,20000), 1)
		Unit:RegisterAIUpdateEvent(1000)
	elseif((args.HALAZZI.merge == true) and (args.HALAZZI.m_phase == 1)) then
		Unit:RegisterEvent("Halazzi_SaberSlash", math.random(20000,30000), 1)
		Unit:RegisterEvent("Halazzi_ShockSpells", math.random(10000,20000), 1)
		Unit:RegisterEvent("Halazzi_PeriodicEnrage", math.random(10000,15000), 1)
		Unit:RegisterAIUpdateEvent(1000)
	elseif((args.HALAZZI.merge == true) and (args.HALAZZI.m_phase == 3)) then
		Unit:RegisterEvent("Halazzi_SaberSlash", math.random(20000,30000), 1)
		Unit:RegisterEvent("Halazzi_ShockSpells", math.random(10000,20000), 1)
		Unit:RegisterEvent("Halazzi_PeriodicEnrage", math.random(10000,15000), 1)
		Unit:RegisterEvent("Halazzi_CorruptedTotem", math.random(10000,20000), 1)
		Unit:RegisterAIUpdateEvent(1000)
	end
end

function Halazzi_SetForm(Unit,val)
	if(val == "TROLL") then
		Unit:SetUInt32Value(UnitField.Unit_FIELD_DISPLAYID, 22348)
	elseif(val == "LYNX") then
		Unit:SetUInt32Value(UnitField.Unit_FIELD_DISPLAYID, 21632)
	end
end

function SpiritofLynx_OnCombat(Unit)
	Unit:RegisterEvent("SpiritofLynx_Abilities", 3000, 1)
	Unit:RegisterAIUpdateEvent(1000)
end

function SpiritofLynx_AIUpdate(Unit)
	local args = getvars(Unit)
	local hp = Unit:GetHealthPct()
	if((args.HALAZZI.m_phase == 2) and (hp <= 20) and (args.HALAZZI.merge == false)) then
		args.HALAZZI.merge = true
		args.HALAZZI.m_phase = 1
		Halazzi_Split(args.HALAZZI.halazziptr)
		Unit:RemoveAIUpdateEvent()
	end
end

function SpiritofLynx_Abilities(Unit)
	local tank = Unit:GetMainTank()
	local choice = math.random(1,2)
	if(type(tank) == "userdata") then
		if(choice == 1) then
			Unit:FullCastSpellOnTarget(43243, tank)
		elseif(choice == 2) then
			Unit:FullCastSpell(43290)
		end
		Unit:RegisterEvent("SpiritofLynx_Abilities", math.random(5000,10000), 1)
	end
end

function Halazzi_CorruptedTotemOnSpawn(Unit)
	Unit:SetCombatMeleeCapable(1)
	Unit:Root()
	Unit:RegisterEvent("Halazzi_CorruptedTotemLightning", 1000, 1)
end

function Halazzi_CorruptedTotemOnWipe(Unit)
	Unit:RemoveEvents()
	Unit:RemoveFromWorld()
end

function Halazzi_CorruptedTotemLightning(Unit)
	local plr = Unit:GetRandomPlayer(0)
	if(type(plr) == "userdata") then
		Unit:FullCastSpellOnTarget(43301, plr)
		Unit:RegisterEvent("Halazzi_CorruptedTotemLightning", 1000, 1)
	end
end

RegisterUnitEvent(23577, 1, "Halazzi_OnCombat")
RegisterUnitEvent(23577, 18, "Halazzi_OnSpawn")
RegisterUnitEvent(23577, 3, "Halazzi_OnKillPlayer")
RegisterUnitEvent(23577, 2, "Halazzi_OnWipe")
RegisterUnitEvent(23577, 4, "Halazzi_OnDeath")
RegisterUnitEvent(23577, 21, "Halazzi_AIUpdate")
RegisterUnitEvent(24143, 21, "SpiritofLynx_AIUpdate")
RegisterUnitEvent(24143, 1, "SpiritofLynx_OnCombat")
RegisterUnitEvent(24224, 18, "Halazzi_CorruptedTotemOnSpawn")
RegisterUnitEvent(24224, 4, "Halazzi_CorruptedTotemOnWipe")
RegisterUnitEvent(24224, 2, "Halazzi_CorruptedTotemOnWipe")