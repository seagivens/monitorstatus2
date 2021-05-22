
--[[

	Monitorstatus v2
	by Hippo, updated by Wanfohk (Twintop @ Mannoroth-US)

	Text-based party frame with target and target's target.
	Based on Ska Demon's Linoleum. Thank you for the great mod.
    2.5.0 - 2013/04/30
        Wanfohk:
            Corrected crash from group member changes in a raid.
            Changed Monk color from Jade to the lighter green that is more commonly used.
            Updated most class buffs, racial buffs, and debuff types available.

    2.4.1 - 2012/08/28
        Wanfohk:
            Minor text display bugfix
	
    2.4.0 - 2012/08/28
        Wanfohk:
            Updated for 5.0.4 / Mists of Pandaria release
	
    2.3.0 - 2011/09/06
    	Wanfohk:
    	    Added Focus option
    	    Added Focus Target option
    	    Fixed bugs with party comp changing.

    2.2.1 - 2010/12/06
        Wanfohk:
            Fixed bugs related to loading variables.
    
    2.2.0
        Updated for 4.0.3a / Cataclysm by Wanfohk
    
	2.1d
	    TOC update for 3.2
	
	2.1c
		Fixed Runic Power not displaying properly when the DK has Runic Power Mastery
	2.1b
		Removed login message
		.TOC update for 3.1
	
	2.1a
		Added login message
		
	2.1 Changes by Melatwig
	           Corrected Shaman class color
		Added missing Death Knight support 

	1.6
		Added class colors
		Added temporary weapon enchants
		Added show only my buffs / my curable debuffs

	1.5.1
		Added tooltips
		Fixed few config window bugs

	1.5
		Added config window!
		Added party pets

	1.4
		Added more variables
		Added in combat only option
		Colored all health/mana variables

	1.3
		Added text modification
		Added buff/debuff limiting

	1.2
		Added possibility to hide buff and/or debuff frames
	
	1.1
		Added a pet frame
		Fixed debuff applications
	
	1.0
		First version

--]]

-- static
ms2version = "2.5.0";
ms2updateinterval = 0.2;
ms2timesinceupdate = 0;

-- default settings
ms2vars = { };

-- class colors
ms2classcolors = {
	["WARRIOR"] = "|cffc69b6d",
	["PALADIN"] = "|cfff48cba",
	["HUNTER"] = "|cffaad372",
	["ROGUE"] = "|cfffff468",
	["PRIEST"] = "|cffffffff",
	["DEATHKNIGHT"] = "|cffcc0000",
	["SHAMAN"] = "|cff00009C",
	["MAGE"] = "|cff68ccef",
	["WARLOCK"] = "|cff9382C9",
	["MONK"] = "|cff00ff96",
	["DRUID"] = "|cffff7c0a"
};

ms2classbuffs = {
	["Warrior"] = "Commanding Shout Battle Shout",
	["Rogue"] = "Swiftblade's Cunning Smoke Bomb",
	["Mage"] = "Arcane Brilliance Dalaran Brilliance Time Warp Frost Armor Molten Armor Mage Armor Temporal Displacement",
	["Priest"] = "Power Word: Fortitude Shadowform Mind Quickening Power Word: Shield Inner Fire Inner Will Spell Warding Renew Fear Ward Fade Echo of Light Spirit Shell Divine Aegis Chakra: Sanctuary Chakra: Chastise Chakra: Serenity Holy Word: Serenity Weakened Soul",
	["Paladin"] = "Blessing of Kings Blessing of Might Illuminated Healing",
	["Druid"] = "Mark of the Wild Moonkin Aura Leader of the Pack Innervate Living Seed Nature's Grasp Prowl Stampeding Roar Lifebloom Regrowth",
	["Warlock"] = "Dark Intent Fel Armor Soulstone Unending Breath",
	["Hunter"] = "Embrace of the Shale Spider Qiraji Fortitude Trueshot Aura Still Water Cackling Howl Serpent's Swiftness Energizing Spores Bellowing Roar Furious Howl Terrifying Roar Fearless Roar Roar of Courage Spirit Beast Blessing Ancient Hysteria Aspect of the Cheetah Aspect of the Hawk Aspect of the Pack Camoflage Deterrence Feign Death Insanity",
	["Shaman"] = "Burning Wrath Unleashed Rage Elemental Oath Grace of Air Bloodlust Heroism Stormlash Totem Lightning Shield Water Shield Water Walking Earth Shield Riptide Exhaustion Sated",
	["Death Knight"] = "Horn of Winter Unholy Aura Blood Presence Frost Presence Unholy Presence Icebound Fortitude Path of Frost Pillar of Frost Unholy Frenzy Vampiric Blood",
	["Monk"] = "Legacy of the Emperor Legacy of the White Tiger Renewing Mist Soothing Mist Surging Mist"
};

--[[
ms2racebuffs = {
	["Orc"] = "Blood Fury",
	["Troll"] = "Berserking",
	["Undead"] = "Will of the Forsaken",
	["Tauren"] = "",
	["Blood Elf"] = "",
	["Goblin"] = "",
	["Human"] = "",
	["Gnome"] = "",
	["Dwarf"] = "Stoneform",
	["Night Elf"] = "Shadowmeld",
	["Draenei"] = "Gift of the Naaru",
	["Worgen"] = "",
	["Panderan"] = ""
};]]

ms2classdebuffs = {
	["Warrior"] = "",
	["Rogue"] = "",
	["Mage"] = "Curse",
	["Priest"] = "Magic Disease",
	["Paladin"] = "Magic Poison Disease",
	["Druid"] = "Magic Curse Poison",
	["Warlock"] = "",
	["Hunter"] = "",
	["Shaman"] = "Magic Poison Curse",
	["Death Knight"] = "",
	["Monk"] = "Magic Poison"
};




-- onload
function MS2_OnLoad(this)
    this:RegisterEvent("VARIABLES_LOADED");
    SLASH_MS2SLASH1 = "/ms2";
	SlashCmdList["MS2SLASH"] = MS2Slash;
end

-- Get the unit name
function MS2_GetUnitName(this)
    this.unit = strsub(this:GetName(), 4);
end

-- Start moving the frame
function MS2_StartMoving(this)
    this:StartMoving();
end

--Stop moving the frame
function MS2_StopMovingOrSizing(this)
    this:StopMovingOrSizing();
end

-- onevent
function MS2_OnEvent(unit, event, args)
    if (event == "VARIABLES_LOADED") then
        MS2_VariablesLoaded();
	end
end

-- variables loaded subroutine
function MS2_VariablesLoaded(this)
	-- put default values if not found
	if (ms2vars.disabled == nil)					then ms2vars.disabled = false; end
	if (ms2vars.locked == nil)					then ms2vars.locked = false; end
	if (ms2vars.scale == nil)					then ms2vars.scale = 1; end
	if (ms2vars.strlimit == nil)					then ms2vars.strlimit = 8; end
	if (ms2vars.maxbuffs == nil)					then ms2vars.maxbuffs = 16; end
	if (ms2vars.maxdebuffs == nil)					then ms2vars.maxdebuffs = 16; end
	if (ms2vars.incombat == nil)					then ms2vars.incombat = false; end
	if (ms2vars.enablemouse == nil)					then ms2vars.enablemouse = true; end
	if (ms2vars.mybuffs == nil)					then ms2vars.mybuffs = false; end
	if (ms2vars.mydebuffs == nil)					then ms2vars.mydebuffs = false; end

	if (ms2vars.framelen == nil) 					then ms2vars.framelen = { }; end
	if (ms2vars.framelen["1"] == nil)				then ms2vars.framelen["1"] = 125; end
	if (ms2vars.framelen["2"] == nil)				then ms2vars.framelen["2"] = 40; end
	if (ms2vars.framelen["3"] == nil)				then ms2vars.framelen["3"] = 40; end

	if (ms2vars.hide == nil) 					then ms2vars.hide = { }; end
	if (ms2vars.hide.player == nil)					then ms2vars.hide.player = false; end
	if (ms2vars.hide.target == nil)					then ms2vars.hide.target = false; end
	if (ms2vars.hide.targettarget == nil)				then ms2vars.hide.targettarget = true; end
	if (ms2vars.hide.party == nil)					then ms2vars.hide.party = false; end
	if (ms2vars.hide.pet == nil)					then ms2vars.hide.pet = false; end
	if (ms2vars.hide.ppets == nil)					then ms2vars.hide.ppets = true; end
	if (ms2vars.hide.focus == nil)					then ms2vars.hide.focus = true; end
	if (ms2vars.hide.focustarget == nil)					then ms2vars.hide.focus = true; end
	if (ms2vars.hide.background == nil)				then ms2vars.hide.background = true; end
	if (ms2vars.hide.wpnbuffs == nil)				then ms2vars.hide.wpnbuffs = true; end

	if (ms2vars.strings == nil) then ms2vars.strings = { }; end
	if (ms2vars.strings.player == nil)				then ms2vars.strings.player = "$name"; end
	if (ms2vars.strings.target == nil)				then ms2vars.strings.target = "$level $name"; end
	if (ms2vars.strings.targettarget == nil)			then ms2vars.strings.targettarget = "$name"; end
	if (ms2vars.strings.party == nil)				then ms2vars.strings.party = "$bind $name"; end
	if (ms2vars.strings.pet == nil)					then ms2vars.strings.pet = "$name"; end
	if (ms2vars.strings.ppets == nil)				then ms2vars.strings.ppets = "$name"; end
	if (ms2vars.strings.focus == nil)				then ms2vars.strings.focus = "$name"; end
	if (ms2vars.strings.focustarget == nil)				then ms2vars.strings.focus = "$name"; end

	if (ms2vars.healths == nil) then ms2vars.healths = { }; end
	if (ms2vars.healths.player == nil)				then ms2vars.healths.player = "$hpp"; end
	if (ms2vars.healths.target == nil)				then ms2vars.healths.target = "$hpp"; end
	if (ms2vars.healths.targettarget == nil)			then ms2vars.healths.targettarget = "$hpp"; end
	if (ms2vars.healths.party == nil)				then ms2vars.healths.party = "$hpp"; end
	if (ms2vars.healths.pet == nil)					then ms2vars.healths.pet = "$hpp"; end
	if (ms2vars.healths.focus == nil)				then ms2vars.healths.focus = "$hpp"; end
	if (ms2vars.healths.focustarget == nil)				then ms2vars.healths.focus = "$hpp"; end

	if (ms2vars.manas == nil) then ms2vars.manas = { }; end
	if (ms2vars.manas.player == nil)				then ms2vars.manas.player = "$mpp"; end
	if (ms2vars.manas.target == nil)				then ms2vars.manas.target = "$mpp"; end
	if (ms2vars.manas.targettarget == nil)				then ms2vars.manas.targettarget = "$mpp"; end
	if (ms2vars.manas.party == nil)					then ms2vars.manas.party = "$mpp"; end
	if (ms2vars.manas.pet == nil)					then ms2vars.manas.pet = "$mpp"; end
	if (ms2vars.manas.ppets == nil)					then ms2vars.manas.ppets = "$mpp"; end
	if (ms2vars.manas.focus == nil)					then ms2vars.manas.focus = "$mpp"; end
	if (ms2vars.manas.focustarget == nil)					then ms2vars.manas.focus = "$mpp"; end
	
	-- FIX
	ms2vars.scale = tonumber(ms2vars.scale);

	if ms2vars.disabled then MonitorStatus2:Hide(); end
	if ms2vars.locked then MS2DragButton:Hide(); end
	if ms2vars.scale then MonitorStatus2:SetScale(ms2vars.scale); end
	MS2ToggleBG();
	MS2ToggleMouse();
	MS2SetFrameWidths();
	for i=1, 4 do getglobal("MS2partypet"..i):SetScale(0.8); end

	-- Buff Fix
	MS2BuffTip:SetOwner(UIParent,"ANCHOR_NONE");
end

-- onupdate
function MS2_OnUpdate(self, elapsed)
	ms2timesinceupdate = ms2timesinceupdate + elapsed;
	while (ms2timesinceupdate > ms2updateinterval) do	
		if not ms2vars.disabled then MS2Update(); end
		ms2timesinceupdate = ms2timesinceupdate - ms2updateinterval;
	end
end

-- onenter
function MS2_OnEnter(this, motion)
	if this.unit then 
		GameTooltip_SetDefaultAnchor(GameTooltip, this); 
		GameTooltip:SetUnit(this.unit);
		GameTooltip:AddLine("HP: |CFF66ff66"..MS2_GetHP(this.unit).."/"..MS2_GetMaxHP(this.unit).."|r");
		GameTooltip:AddLine("MP: |CFF99CCFF"..MS2_GetMP(this.unit).."/"..MS2_GetMaxMP(this.unit).."|r");
		GameTooltip:Show(); 
	end
end

-- onleave
function MS2_OnLeave()
	GameTooltip:Hide();
end

--[[ onclick
function MS2_OnClick(button)
	if SpellIsTargeting() then
	    if (button == "LeftButton") then
			SpellTargetUnit(this.unit);
		end
		return;
	end
	if (button == "LeftButton") then
		if CursorHasItem() then
			if (this.unit == "player") then
				AutoEquipCursorItem();
				return;
			else
				DropItemOnUnit(this.unit);
				return;
			end
		end
		TargetUnit(this.unit);
	end
end ]]--

-- update
function MS2Update(self, elapsed)
	if (not ms2vars.incombat or UnitAffectingCombat("player")) then
		if not ms2vars.hide.player 						then MS2Modify("MS2player");		else MS2player:Hide(); end
		if (UnitExists("target") and not ms2vars.hide.target)			then MS2Modify("MS2target"); 		else MS2target:Hide(); end
		if (UnitExists("targettarget") and not ms2vars.hide.targettarget) 	then MS2Modify("MS2targettarget"); 	else MS2targettarget:Hide(); end
		if (UnitExists("focus") and not ms2vars.hide.focus) 			then MS2Modify("MS2focus"); 		else MS2focus:Hide(); end
		if (UnitExists("focustarget") and not ms2vars.hide.focustarget) 	then MS2Modify("MS2focustarget"); 	else MS2focustarget:Hide(); end
		if (UnitExists("pet") and not ms2vars.hide.pet) 			then MS2Modify("MS2pet"); MS2party1:SetPoint("LEFT","MS2pet","LEFT",0,-20); else MS2pet:Hide(); MS2party1:SetPoint("LEFT","MS2player","LEFT",0,-20); end
		local i=1;
		if not ms2vars.hide.party then
			while (i <= GetNumSubgroupMembers()) do MS2Modify("MS2party"..i); i = i+1; end
		end
		while (i <= 4) do getglobal("MS2party"..i):Hide(); i = i+1; end
		i=1;
		while (i <= 4) do
			if (not ms2vars.hide.ppets and UnitExists("partypet"..i)) then MS2Modify("MS2partypet"..i); if (i < 4) then getglobal("MS2party"..i+1):SetPoint("LEFT","MS2party"..i,"LEFT",0,-36); end
			else getglobal("MS2partypet"..i):Hide(); if (i < 4) then getglobal("MS2party"..i+1):SetPoint("LEFT","MS2party"..i,"LEFT",0,-20); end end
			i = i+1;
		end
	else
		MS2player:Hide(); MS2target:Hide(); MS2targettarget:Hide(); MS2pet:Hide();
		MS2party1:Hide(); MS2party2:Hide(); MS2party3:Hide(); MS2party4:Hide();
		MS2focus:Hide(); MS2focustarget:Hide();
	end
end

-- modify single frame
function MS2Modify(name)
	local frame = getglobal(name);
	local unit = frame.unit;
	local text = name.."Text";
	local aura = name.."Aura";
	if UnitExists(unit) then
		frame:Show();
		frame:SetWidth(ms2vars.framelen["1"]+ms2vars.framelen["2"]+ms2vars.framelen["3"]+MS2Buffs(frame,aura)+10);
		MS2GetText(unit,text);
	end
end

-- get frame text
function MS2GetText(unit, text)
	local unitname;
	if strfind(unit,"party") then unitname = "party";
	else unitname = unit; end
	if ms2vars.strings[unitname] then
		local msg, hp, mp;
		msg = MS2GetValues(unit,ms2vars.strings[unitname]);
		hp = MS2GetValues(unit,ms2vars.healths[unitname]);
		mp = MS2GetValues(unit,ms2vars.manas[unitname]);
		getglobal(text.."1"):SetText(msg);
		getglobal(text.."2"):SetText(hp);
		getglobal(text.."3"):SetText(mp);
	end
end

-- get right value from text
function MS2GetValues(unit,text)
	if (UnitExists(unit) and text) then
		text = string.gsub(text,"$level",MS2_GetLvl(unit));
		text = string.gsub(text,"$bind",MS2_GetBind(unit));
		text = string.gsub(text,"$name",MS2_GetName(unit));
		text = string.gsub(text,"$hpp",MS2_GetHPP(unit));
		text = string.gsub(text,"$mpp",MS2_GetMPP(unit));
		text = string.gsub(text,"$mhp",MS2_GetMaxHP(unit,true));
		text = string.gsub(text,"$mmp",MS2_GetMaxMP(unit,true));
		text = string.gsub(text,"$hpm",MS2_GetMissingHP(unit,true));
		text = string.gsub(text,"$mpm",MS2_GetMissingMP(unit,true));
		text = string.gsub(text,"$hp",MS2_GetHP(unit,true));
		text = string.gsub(text,"$mp",MS2_GetMP(unit,true));
		return text;
	end
	return "";
end

-- get unit buffs
function MS2Buffs(frame,aura)
	local i=1;
	local j=1;
	local button, app, appframe, texture, texpath, show;
	local name, rank;
	local myclass = UnitClass("player");
	while (UnitBuff(frame.unit, j) and j <= ms2vars.maxbuffs) do
		show = true;
		button = getglobal(aura..i);
		texture = getglobal(aura..i.."Overlay");
		appframe = getglobal(aura..i.."App");
		name, rank, texpath, app = UnitBuff(frame.unit, j);
		if ms2vars.mybuffs then
			show = false;
			MS2BuffTip:SetUnitBuff(frame.unit, j);
			if MS2BuffTipTextLeft1:GetText() ~= nil and strfind(ms2classbuffs[myclass],MS2BuffTipTextLeft1:GetText()) then show = true; end
		end
		if show then
			texture:SetTexture(texpath);
			button:SetBackdropColor(0,1,0);
			if (app > 1) then appframe:SetText(app); 
			else appframe:SetText(""); end
			button:Show();
			button.num = j;
			button.type = 1;
			i = i+1;
		end
		j = j+1;
	end
	j=1;
	while (UnitDebuff(frame.unit, j) and j <= ms2vars.maxdebuffs) do
		show = true;
		button = getglobal(aura..i);
		texture = getglobal(aura..i.."Overlay");
		appframe = getglobal(aura..i.."App");
		name, rank, texpath, app = UnitDebuff(frame.unit, j);
		if ms2vars.mydebuffs then
			show = false;
			MS2BuffTipTextRight1:SetText("");
			MS2BuffTip:SetUnitDebuff(frame.unit, j);
			if MS2BuffTipTextRight1:GetText() ~= nil and strfind(ms2classdebuffs[myclass],MS2BuffTipTextRight1:GetText()) then show = true; end
		end
		if show then
			texture:SetTexture(texpath);
			button:SetBackdropColor(1,0,0);
			if (app > 1) then appframe:SetText(app); 
			else appframe:SetText(""); end
			button:Show();
			button.num = j;
			button.type = 0;
			i = i+1;
		end
		j = j+1;
	end
	if strfind(frame.unit,"player") then
		local mhenchanted, mhexpire, mhcharges, ohenchanted, ohexpire, ohcharges = GetWeaponEnchantInfo();
		if (mhenchanted and not ms2vars.hide.wpnbuffs) then
			button = getglobal(aura..i);
			texture = getglobal(aura..i.."Overlay");
			appframe = getglobal(aura..i.."App");
			button:SetBackdropColor(0,0,1);
			texture:SetTexture(GetInventoryItemTexture("player",16));
			appframe:SetText("");
			button:Show();
			button.num = 16;
			button.type = 2;
			i = i+1;
		end
		if (ohenchanted and not ms2vars.hide.wpnbuffs) then
			button = getglobal(aura..i);
			texture = getglobal(aura..i.."Overlay");
			appframe = getglobal(aura..i.."App");
			button:SetBackdropColor(0,0,1);
			texture:SetTexture(GetInventoryItemTexture("player",17));
			appframe:SetText("");
			button:Show();
			button.num = 17;
			button.type = 2;
			i = i+1;
		end
	end
	local len = (i-1)*18;
	while (i <= 34) do
		getglobal(aura..i):Hide();
		i = i+1;
	end
	return len;
end

-- get bindings
function MS2_GetBind(unit)
	if strfind(unit, "player") then return "F1";
	elseif strfind(unit, "party1") then return "F2";
	elseif strfind(unit, "party2") then return "F3";
	elseif strfind(unit, "party3") then return "F4";
	elseif strfind(unit, "party4") then return "F5";
	end
	return "";
end

-- get name
function MS2_GetName(unit)
	if UnitExists(unit) then
		local uname = UnitName(unit);
		local text;
		if (strlen(uname) > ms2vars.strlimit) then text = strsub(uname,0,ms2vars.strlimit);
		else text = uname; end
		--  or UnitIsVisible(unit) ~= nil
		if (UnitInParty(unit)) then text = MS2_GetClassColor(unit)..text; end
		return text;
	end
	return "";
end

-- get class color
function MS2_GetClassColor(unit)
	if UnitExists(unit) then
		classDisplayName, class, classID = UnitClass(unit);
		if not (classID == nil) then
			if (classID > 0 and classID < 12) then
				return ms2classcolors[class];
			end
		end
	end
	return "";
end

-- get level
function MS2_GetLvl(unit)
	if UnitExists(unit) then
		local text;
		if (UnitLevel(unit) == -1) then text = "X";
		else lbl = UnitLevel(unit); end
		return MS2_GetLvlColor(unit)..lbl.."|r";
	end
	return "";
end

function MS2_GetLvlColor(unit)
	local color = "";
	local diff = UnitLevel(unit) - UnitLevel("player");
	if diff >= 5 then color = "|CFFFF0000";
	elseif diff >= 3 then color = "|CFFFF8800";
	elseif diff >= -2 then color = "|CFFFFCC00";
	elseif -diff <= GetQuestGreenRange() then color = "|CFF00FF00";
	else color = "|CFF888888"; end
	return color;
end

-- get hp
function MS2_GetHP(unit,color)
  if UnitExists(unit) then
		if color then return MS2_HealthColor(unit)..UnitHealth(unit); end
		return UnitHealth(unit);
	end
	return "";
end

-- get max hp
function MS2_GetMaxHP(unit,color)
  if UnitExists(unit) then
		if color then return "|CFFFFFFFF"..UnitHealthMax(unit); end
		return UnitHealthMax(unit);
	end
	return "";
end

-- get hp missing
function MS2_GetMissingHP(unit)
	if UnitExists(unit) then
		local hp = UnitHealthMax(unit) - UnitHealth(unit);
		return MS2_HealthColor(unit)..hp;
	end
	return "";
end

-- get percent hp
function MS2_GetHPP(unit)
  if UnitExists(unit) then
		local hp = (UnitHealth(unit) * 100.0) / UnitHealthMax(unit);
		return MS2_HealthColor(unit)..string.format("%d", hp);
	end
	return "";
end

-- get health color
function MS2_HealthColor(unit)
		local hp = (UnitHealth(unit) * 100.0) / UnitHealthMax(unit);
		if (hp >= 100) then return "|CFFFFFFFF";
		elseif (hp > 80) then return "|CFF00FF00";
		elseif (hp > 60) then return "|CFF00CC00";
		elseif (hp > 40) then return "|CFFFFFF00";
		elseif (hp > 20) then return "|CFFFF8800";
		elseif (hp > 0) then return "|CFFFF0101";
		else return "|CFF888888";
		end
end

-- get mp
function MS2_GetMP(unit,color)
  if UnitExists(unit) then
		if color then return MS2_ManaColor(unit)..UnitPower(unit); end
		return UnitPower(unit);
	end
	return "";
end

-- get max mp
function MS2_GetMaxMP(unit,color)
  if UnitExists(unit) then
		if color then return "|CFFFFFFFF"..UnitPowerMax(unit); end
		return UnitPowerMax(unit);
	end
	return "";
end


-- get mp missing
function MS2_GetMissingMP(unit)
	if UnitExists(unit) then
		local mp = UnitPowerMax(unit) - UnitPower(unit);
		return MS2_ManaColor(unit)..mp;
	end
	return "";
end

-- get percent mp
function MS2_GetMPP(unit)
  if UnitExists(unit) then
		if (UnitPowerMax(unit) == 0) then return ""; end
		local mp = (UnitPower(unit) * 100.0) / UnitPowerMax(unit);
		return MS2_ManaColor(unit)..string.format("%d", mp);
	end
	return "";
end

-- get mana color
function MS2_ManaColor(unit)
	if (UnitPowerMax(unit) == 0) then
		return "|CFFFFFFFF";
		end
	local mp = (UnitPower(unit) * 100.0) / UnitPowerMax(unit);
	local ptype = UnitPowerType(unit);
	if (ptype == 0) then
		if (mp >= 100) then return "|CFFFFFFFF";
		elseif (mp > 80) then return "|CFF8888FF";
		elseif (mp > 60) then return "|CFF8888CC";
		elseif (mp > 40) then return "|CFF00FFFF";
		elseif (mp > 20) then return "|CFF00FF80";
		elseif (mp > 0) then return "|CFF00FF00";
		else return "|CFFFFFFFF";
		end
	elseif (ptype == 3) then
		if (mp >= 100) then return "|CFFFFFF00";
		elseif (mp > 80) then return "|CFFFFFF33";
		elseif (mp > 60) then return "|CFFFFFF66";
		elseif (mp > 40) then return "|CFFFFFF99";
		elseif (mp > 20) then return "|CFFFFFFBB";
		else return "|CFFFFFFFF";
		end
	else
		if (mp >= 100) then return "|CFFFF0000";
		elseif (mp > 80) then return "|CFFFF8800";
		elseif (mp > 60) then return "|CFFFFFF00";
		elseif (mp > 40) then return "|CFFFF8888";
		elseif (mp > 20) then return "|CFFFFCCCC";
		elseif (mp > 0) then return "|CFFFFFFFF";
		else return "|CFFFFFFFF";
		end
	end
end

-- get buffinfo
function MS2_GetBuffInfo(this)
	local unit = this:GetParent().unit;
	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	
	if (this.type == 0) then
		GameTooltip:SetUnitDebuff(unit, this.num);
	elseif (this.type == 1) then
		GameTooltip:SetUnitBuff(unit, this.num);
	elseif (this.type == 2) then
		GameTooltip:SetInventoryItem("player", this.num);
	end
	GameTooltip:Show();
end

-- parse strings
function MS2ParseString(msg)
	if msg then
		while (strfind(msg,"  ") ~= nil) do
			msg = string.gsub(msg,"  "," ");
		end
		local a,b,c=strfind(msg,"(%S+)");
		if a then
			return c,strsub(msg,b+2);
		else	
			return "";
		end
	end
end

-- slash command
function MS2Slash(msg)
	local cmd, subcmd = MS2ParseString(msg);
	local subcmd1, subcmd2;
	if (cmd == "move") then
		if ms2vars.locked then ms2vars.locked = false; MS2DragButton:Show();
		else ms2vars.locked = true; MS2DragButton:Hide(); end
	elseif (cmd == "toggle") then 
		if ms2vars.disabled then ms2vars.disabled = false; MonitorStatus2:Show();
		else ms2vars.disabled = true; MonitorStatus2:Hide(); end
	elseif (cmd == "hide") then
		ms2vars.hide[subcmd] = true;
		if (subcmd == "background") then MS2ToggleBG(); end
	elseif (cmd == "show") then
		ms2vars.hide[subcmd] = false;
		if (subcmd == "background") then MS2ToggleBG(); end
	elseif (cmd == "showhide") then
		if ms2vars.hide[subcmd] then MS2Slash("show "..subcmd);
		else MS2Slash("hide "..subcmd); end
	elseif (cmd == "scale") then
	  if (subcmd ~= "" and tonumber(subcmd) <= 1.5 and tonumber(subcmd) >= 0.5) then ms2vars.scale = tonumber(subcmd); MonitorStatus2:SetScale(tonumber(subcmd)); end
	elseif (cmd == "strlimit") then
		if (subcmd ~= "" and tonumber(subcmd) >= 0) then ms2vars.strlimit = tonumber(subcmd); end
	elseif (cmd == "framelen") then
		if (subcmd ~= "") then
			subcmd1, subcmd2 = MS2ParseString(subcmd);
			if (subcmd2 ~= nil and subcmd2 ~= "" and tonumber(subcmd1) > 0 and tonumber(subcmd2) >= 0) then ms2vars.framelen[subcmd1] = tonumber(subcmd2); MS2SetFrameWidths(); end
		end
	elseif (cmd == "maxbuffs") then
		if (subcmd ~= "" and tonumber(subcmd) >= 0) then ms2vars.maxbuffs = tonumber(subcmd); end
	elseif (cmd == "maxdebuffs") then
		if (subcmd ~= "" and tonumber(subcmd) >= 0) then ms2vars.maxdebuffs = tonumber(subcmd); end
	elseif (cmd == "string") then
		if (subcmd ~= "") then
			subcmd1, subcmd2 = MS2ParseString(subcmd);
			ms2vars.strings[subcmd1] = subcmd2;
		end
	elseif (cmd == "health") then
		if (subcmd ~= "") then
			subcmd1, subcmd2 = MS2ParseString(subcmd);
			ms2vars.healths[subcmd1] = subcmd2;
		end
	elseif (cmd == "mana") then
		if (subcmd ~= "") then
			subcmd1, subcmd2 = MS2ParseString(subcmd);
			ms2vars.manas[subcmd1] = subcmd2;
		end
	elseif (cmd == "incombat") then
		if ms2vars.incombat then ms2vars.incombat = false;
		else ms2vars.incombat = true; end
	elseif (cmd == "enablemouse") then
		if ms2vars.enablemouse then ms2vars.enablemouse = false;
		else ms2vars.enablemouse = true; end
		MS2ToggleMouse();
	elseif (cmd == "mybuffs") then
		if ms2vars.mybuffs then ms2vars.mybuffs = false;
		else ms2vars.mybuffs = true; end
	elseif (cmd == "mydebuffs") then
		if ms2vars.mydebuffs then ms2vars.mydebuffs = false;
		else ms2vars.mydebuffs = true; end
	elseif (cmd == "wpnbuffs") then
		if ms2vars.hide.wpnbuffs then ms2vars.hide.wpnbuffs = false;
		else ms2vars.hide.wpnbuffs = true; end
	else
		MS2Options:Show();
	end
end

-- messaging
function MS2MSG(msg)
	if msg then
		DEFAULT_CHAT_FRAME:AddMessage("MS2 - "..msg);
	end
end

-- toggle enablemouse
function MS2ToggleMouse()
	local toggle;
	if ms2vars.enablemouse then toggle = 1;
	else toggle = 0; end
	MS2player:EnableMouse(toggle);
	MS2target:EnableMouse(toggle);
	MS2targettarget:EnableMouse(toggle);
	MS2focus:EnableMouse(toggle);
	MS2focustarget:EnableMouse(toggle);
	MS2pet:EnableMouse(toggle);
	for i=1, 4 do
		MS2player:EnableMouse(toggle);
		getglobal("MS2party"..i):EnableMouse(toggle);
	end
	for i=1, 4 do
		getglobal("MS2partypet"..i):EnableMouse(toggle);
	end
end

-- toggle background
function MS2ToggleBG()
	local toggle;
	if ms2vars.hide.background then toggle = 0;
	else toggle = 1; end
	MS2player:SetBackdropColor(toggle,toggle,toggle,toggle);
	MS2player:SetBackdropBorderColor(toggle,toggle,toggle,toggle);
	MS2target:SetBackdropColor(toggle,toggle,toggle,toggle);
	MS2target:SetBackdropBorderColor(toggle,toggle,toggle,toggle);
	MS2targettarget:SetBackdropColor(toggle,toggle,toggle,toggle);
	MS2targettarget:SetBackdropBorderColor(toggle,toggle,toggle,toggle);
	MS2focus:SetBackdropColor(toggle,toggle,toggle,toggle);
	MS2focus:SetBackdropBorderColor(toggle,toggle,toggle,toggle);
	MS2focustarget:SetBackdropColor(toggle,toggle,toggle,toggle);
	MS2focustarget:SetBackdropBorderColor(toggle,toggle,toggle,toggle);
	MS2pet:SetBackdropColor(toggle,toggle,toggle,toggle);
	MS2pet:SetBackdropBorderColor(toggle,toggle,toggle,toggle);
	for i=1, 4 do
		getglobal("MS2party"..i):SetBackdropColor(toggle,toggle,toggle,toggle);
		getglobal("MS2party"..i):SetBackdropBorderColor(toggle,toggle,toggle,toggle);
	end
	for i=1, 4 do
		getglobal("MS2partypet"..i):SetBackdropColor(toggle,toggle,toggle,toggle);
		getglobal("MS2partypet"..i):SetBackdropBorderColor(toggle,toggle,toggle,toggle);
	end
end

-- set frame widths
function MS2SetFrameWidths()
  for i=1, 3 do
		getglobal("MS2playerText"..i):SetWidth(ms2vars.framelen[""..i]);
		getglobal("MS2targetText"..i):SetWidth(ms2vars.framelen[""..i]);
		getglobal("MS2targettargetText"..i):SetWidth(ms2vars.framelen[""..i]);
		getglobal("MS2focusText"..i):SetWidth(ms2vars.framelen[""..i]);
		getglobal("MS2focustargetText"..i):SetWidth(ms2vars.framelen[""..i]);
		getglobal("MS2petText"..i):SetWidth(ms2vars.framelen[""..i])
		for j=1, 4 do
			getglobal("MS2party"..j.."Text"..i):SetWidth(ms2vars.framelen[""..i]);
		end
	end
end