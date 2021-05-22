--[[

	Options file

  ]]

-- on clear focus
function MS2C_ClearFocus(this)
    this:ClearFocus();
end

-- on highlight text
function MS2C_HighlightText(this)
    this:HighlightText(0, 0);
end

-- on show get value
function MS2C_Get(unit)
	local name = unit:GetName();
	local subname;
	if string.find(name,"toggle") then getglobal(name.."Text"):SetText("Enabled"); if not ms2vars.disabled then unit:SetChecked(1); end
	elseif string.find(name,"move") then getglobal(name.."Text"):SetText("Locked"); if ms2vars.locked then unit:SetChecked(1); end
	elseif string.find(name,"show") then subname = string.sub(name,9); getglobal(name.."Text"):SetText("Show "..subname); if not ms2vars.hide[subname] then unit:SetChecked(1); end
	elseif string.find(name,"enablemouse") then getglobal(name.."Text"):SetText("Put on background"); if not ms2vars.enablemouse then unit:SetChecked(1); end
	elseif string.find(name,"incombat") then getglobal(name.."Text"):SetText("Only in combat"); if ms2vars.incombat then unit:SetChecked(1); end
	elseif string.find(name,"my") then subname = string.sub(name,5); getglobal(name.."Text"):SetText("Only "..subname); if ms2vars[subname] then unit:SetChecked(1); end
	end
end

-- on show get slider
function MS2C_GetSlider(unit)
	local name = unit:GetName();
	local low = getglobal(name.."Low");
	local high = getglobal(name.."High");
	local text = getglobal(name.."Text");
	local value;
	if string.find(name,"scale") then
		value = ms2vars.scale;
		unit:SetMinMaxValues(0.5,1.5); unit:SetValueStep(0.1); unit:SetValue(value);
		low:SetText("0.5"); high:SetText("1.5"); text:SetText("Scale: "..value);
	elseif string.find(name,"debuffs") then
		value = ms2vars.maxdebuffs;
		unit:SetMinMaxValues(0,16); unit:SetValueStep(1); unit:SetValue(value);
		low:SetText("0"); high:SetText("16"); text:SetText("Debuffs: "..value);
	elseif string.find(name,"buffs") then
		value = ms2vars.maxbuffs;
		unit:SetMinMaxValues(0,16); unit:SetValueStep(1); unit:SetValue(value);
		low:SetText("0"); high:SetText("16"); text:SetText("Buffs: "..value);
	end
end

-- on show get editbox
function MS2C_GetEditbox(unit)
	local name = unit:GetName();
	local label = getglobal(name.."Label");
	local subname;
	if string.find(name,"edit") then
		subname = string.sub(name,9);
		unit:SetText(ms2vars.strings[subname]);
		unit:SetWidth(124);
		getglobal(name.."Middle"):SetWidth(124);
		
		if string.find(subname,"targettarget") then
			subname = "ttarget";
		end
		
		if string.find(subname,"focustarget") then
			subname = "ftarget";
		end
		label:SetText(subname);
	elseif string.find(name,"health") then subname = string.sub(name,11); unit:SetText(ms2vars.healths[subname]);
	elseif string.find(name,"mana") then subname = string.sub(name,9); unit:SetText(ms2vars.manas[subname]);
	elseif string.find(name,"frame") then subname = string.sub(name,10); --[[ unit:SetNumeric(1); ]] unit:SetText(ms2vars.framelen[subname]); unit:SetWidth(40); getglobal(name.."Middle"):SetWidth(40); if string.find(subname,"1") then label:SetText("Frame widths"); end
	elseif string.find(name,"strlimit") then --[[ unit:SetNumeric(1); ]] unit:SetText(ms2vars.strlimit); unit:SetWidth(40); getglobal(name.."Middle"):SetWidth(40); label:SetText("Limit unitnames");
	end
end

-- on click set value
function MS2C_Set(unit)
	local name = unit:GetName();
	if string.find(name,"toggle") then MS2Slash("toggle");
	elseif string.find(name,"move") then MS2Slash("move");
	elseif string.find(name,"show") then subname = string.sub(name,9); MS2Slash("showhide "..subname);
	elseif string.find(name,"enablemouse") then MS2Slash("enablemouse");
	elseif string.find(name,"incombat") then MS2Slash("incombat");
	elseif string.find(name,"my") then subname = string.sub(name,5); MS2Slash(subname);
	end
end

-- on click set slider value
function MS2C_SetSlider(unit)
	local name = unit:GetName();
	local text = getglobal(name.."Text");
	local value;
	if string.find(name,"scale") then
		value = tonumber(string.format("%1.1f", unit:GetValue()));
		text:SetText("Scale: "..value);
		MS2Slash("scale "..value);
	elseif string.find(name,"debuffs") then
		value = tonumber(string.format("%d", unit:GetValue()));
		text:SetText("Debuffs: "..value);
		MS2Slash("maxdebuffs "..value);
	elseif string.find(name,"buffs") then
		value = tonumber(string.format("%d", unit:GetValue()));
		text:SetText("Buffs: "..value);
		MS2Slash("maxbuffs "..value);
	end
end

-- on edit set string value
function MS2C_SetString(unit)
	local name = unit:GetName();
	local value = unit:GetText();
	if string.find(name,"edit") then subname = string.sub(name,9); MS2Slash("string "..subname.." "..value);
	elseif string.find(name,"health") then subname = string.sub(name,11); MS2Slash("health "..subname.." "..value);
	elseif string.find(name,"mana") then subname = string.sub(name,9); MS2Slash("mana "..subname.." "..value);
	elseif string.find(name,"frame") then subname = string.sub(name,10); MS2Slash("framelen "..subname.." "..value);
	elseif string.find(name,"strlimit") then MS2Slash("strlimit "..value);
	end
end

-- on hover show tooltip
function MS2C_TT(unit)
	local name = unit:GetName();
	local text = "";
	local subname;
	if string.find(name,"toggle") then text = "Check this to\nenable monitorstatus";
	elseif string.find(name,"wpnbuffs") then text = "Check this to\nshow your weaponbuffs";
	elseif string.find(name,"move") then text = "Check this to\nlock monitorstatus";
	elseif string.find(name,"show") then subname = string.sub(name,9); if string.find(subname,"targettarget") then subname = "target's target"; elseif string.find(subname,"ppets") then subname = "party pets"; end text = "Check this to\nshow "..subname;
	elseif string.find(name,"enablemouse") then text = "Check this to\ndisable mouse clicks";
	elseif string.find(name,"incombat") then text = "Check this to show monitorstatus\nonly when you're engaged in combat";
	elseif string.find(name,"mybuffs") then text = "Check this to show\nonly your castable buffs";
	elseif string.find(name,"mydebuffs") then text = "Check this to show\nonly debuffs you can cure";
	end
	if text then
		GameTooltip_SetDefaultAnchor(GameTooltip, unit);
		GameTooltip:AddLine(text);
		GameTooltip:Show();
	end
end

-- on hover show slider tooltip
function MS2C_STT(unit)
	local name = unit:GetName();
	local text = "";
	if string.find(name,"scale") then text = "Set the scale of\nthe main window";
	elseif string.find(name,"debuffs") then text = "Set the amount of debuffs to show.\n0 disables the showing utterly";
	elseif string.find(name,"buffs") then text = "Set the amount of buffs to show.\n0 disables the showing utterly";
	end
	if text then
		GameTooltip_SetDefaultAnchor(GameTooltip, unit); 
		GameTooltip:AddLine(text);
		GameTooltip:Show();
	end
end

-- on hover show editbox tooltip
function MS2C_ETT(unit)
	local name = unit:GetName();
	local text = "";
	local subname;
	if string.find(name,"edit") then subname = string.sub(name,9); if string.find(subname,"targettarget") then subname = "target's target"; elseif string.find(subname,"ppets") then subname = "party pets"; end text = "Set the format of 1st frame of "..subname.." using\nvariables shown below and any characters";
	elseif string.find(name,"health") then subname = string.sub(name,11); if string.find(subname,"targettarget") then subname = "target's target"; elseif string.find(subname,"ppets") then subname = "party pets"; end text = "Set the format of 2nd frame of "..subname.." using\nvariables shown below and any characters";
	elseif string.find(name,"mana") then subname = string.sub(name,9); if string.find(subname,"targettarget") then subname = "target's target"; elseif string.find(subname,"ppets") then subname = "party pets"; end text = "Set the format of 3rd frame of "..subname.." using\nvariables shown below and any characters";
	elseif string.find(name,"frame") then subname = string.sub(name,10); if string.find(subname,"targettarget") then subname = "target's target"; elseif string.find(subname,"ppets") then subname = "party pets"; end text = "Set the length of\nframe "..subname.." in pixels";
	elseif string.find(name,"strlimit") then text = "Set the amount of characters\nunit names will be limited";
	end
	if text then
		GameTooltip_SetDefaultAnchor(GameTooltip, unit); 
		GameTooltip:AddLine(text);
		GameTooltip:Show();
	end
end