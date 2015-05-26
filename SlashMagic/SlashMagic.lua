local AddonName, SM = ...
local FriendlyAddonName = "Slash Magic"
SlashMagicAddonTable = SM

--[[ **************************************************************************
     * Add On Starts Here                                                     *
	 **************************************************************************
]]
	
-- Addon Frame
SM.Frame = CreateFrame("Frame")
SM.Frame:RegisterEvent("ADDON_LOADED")

-- Boolean Conversions
local on = true
local off = false

-- Text Colors
local yel = "|cFFFFFF00"
local wht = "|cFFFFFFFF"
local blu = "|cFF00FFFF"
local red = "|cFFFF0000"
local grn = "|cFF00FF00"
local res = "|r"

-- Bill's Utils
local addOptionMt = BillsUtils.addOptionMt
local StatColor = BillsUtils.StatColor
local SJprint = BillsUtils.SJprint
local OptSaveTF = BillsUtils.OptSaveTF

BillsUtils.Locals[#BillsUtils.Locals +1] = function ()
	addOptionMt = BillsUtils.addOptionMt
	StatColor = BillsUtils.StatColor
	SJprint = BillsUtils.SJprint
	OptSaveTF = BillsUtils.OptSaveTF
end
	
-- Addon Settings
local cmdKey = "SLASHMAGIC_%s_CMD"
local SMS
SlashMagic_Settings = {}
SlashMagicStaticValues = {}

SM.Settings_Defaults = {
	Enable = on,
	Salted = false,
	}

local CMDS, CODE, DESC, VERS, ALIAS
SlashMagic_Commands = {} 

SM.Commands_Defaults = {
		["eject"] = {
			desc = "ejects passenger from seat # or all seats",
			vers = 1.1,
			state = on,
			code = {
				"msg = math.floor( tonumber(msg) and tonumber(msg) or 0 )",
				"if msg ~= 0 then",
			    "     EjectPassengerFromSeat( msg )",
				"else",
				"     for x = 1, UnitVehicleSeatCount('player') do",
				"          EjectPassengerFromSeat(x)",
				"     end",
				"end" },	
		},
		
		["xx"] = { 
			desc = "attempts to dismount you and leave any vehicle you are in",
			vers = 1.05,
			state = on,
			code = {
				"if UnitInVehicle('player') then",
				"     VehicleExit()",
				"end",
				"if IsMounted() then",
				"     Dismount()",
				"end" },
		},
		
		["gfx"] = { 
			desc = "restart the gfx engine",
			vers = 1,
			state = on,
			code = { 	
				"RestartGx()" },
		},
		
		["fquit"] ={
			desc = "fast quit / force quit",
			vers = 1,
			state = on,
			code = {	
				"ForceQuit()" },
		},
		
		["tele"] = {
			desc = "teleport in/out of lfg dungeon",
			vers = 1,
			state = on,
			code = {	
				"LFGTeleport(IsInInstance())" },
		},
		
		["p2r"] = {
			desc = "convert your party to a raid",
			vers = 1,
			state = on,
			code = {	
				"ConvertToRaid()" },
		},
		
		["r2p"] = {
			desc = "convert your raid to a party",
			vers = 1,
			state = on,
			code = {	
				"ConvertToParty()" },
		},
			
		["clear"] = {
			desc = "clear all world markers (smoke bombs)",
			vers = 1,
			state = on,
			code =  {	
				"ClearRaidMarker()" },
		},
		
		["cloak"] = {
			desc = "toggle your cloak visibility",
			vers = 1,
			state = on,
			code = {	
				"ShowCloak( not(ShowingCloak()) )" },
		},
		
		["helm"] = {
			desc = "toggle your helm visibility",
			vers = 1,
			state = on,
			code = {	
				"ShowHelm( not(ShowingHelm()) )" },
		},
		
		["lvgrp"] = { 
			desc = "will leave your group",
			vers = 1.05,
			state = on,
			code = {	
				"LeaveParty()" },
		},
		
		["passloot"] = { 
			desc = "will toggle pass on loot",
			vers = 1.05,
			state = on,
			code = {	
				"local passing = GetOptOutOfLoot()",
				"if passing then",
				"     SetOptOutOfLoot()",
				"     print('You are no longer passing on all loot')",
				"else",
				"     SetOptOutOfLoot(1)",
				"     print('You are now passing on all loot')",
				"end" },
		},
		
		["in"] = { 
			desc = "will run a slash command in a set amount of time \"/in ## /whatever\" or \"/in #:## /whatever\" (not all slash commands can be delayed)",
			vers = 3.02,
			state = on,
			code = {	
				"local delay, what = string.split(' ', msg, 2)",
				"if string.find( delay, ':' ) then",
				"     local mins, secs = string.split(':', delay)",
				"     mins = tonumber(mins)",
				"     secs = tonumber(secs)",
				"     delay = (mins * 60) + secs",
				"else",
				"     delay = tonumber(delay)",
				"end",
				"if delay <= 0 then",
				"     print('/in delay must be greater than 0')",
				"     return",
				"end",
				"BillsUtils.Wait( delay, (MacroEditBox:GetScript('OnEvent')), MacroEditBox, 'EXECUTE_CHAT_LINE', what )" },
		},
		
		["ready"] = { 
			desc = "initiate a ready check",
			vers = 1.1,
			state = on,
			code = {	
				"DoReadyCheck()" },
		},
		
		["role"] = {
			desc = "initiates a role check",
			vers = 1.1,
			state = on,
			code = {	
				"InitiateRolePoll()" },
		},
		
		["sha"] = { 
			desc = "checks to see if you did the \"Sha of Anger\"",
			vers = 1.25,
			state = on,
			code = {	
				"if ( IsQuestFlaggedCompleted(32099) ) then",
				"     print(\"You have completed \\\"Sha of Anger\\\" this week.\")",
				"else",
				"     print(\"You haven\'t completed \\\"Sha of Anger\\\" this week.\")",
				"end" },
		},
		
		["exp"] = { 
			desc = "displays your experience and rested experience",
			vers = 1.15,
			state = on,
			code = {	
				"local unit = 'player'",
				"if(UnitLevel( unit ) < 90) then",
				"     local XP = UnitXP(unit)",
				"     local MaxXP = UnitXPMax( unit )",
				"     local XPE = GetXPExhaustion()",
				"     print( ('Exp to level: %.2d k'):format( (MaxXP - XP) / 1000))",
				"     print( ('Rested exp: %.2d k'):format( XPE / 1000) )",
				"else",
				"     print('You are at max level.')",
				"end" },
		},
		
		["toast"] = { 
			desc = "sets or clears your Battle-Net toast message",
			vers = 1,
			state = on,
			 code = {	
				"if msg ~= '' then",
				"     BNSetCustomMessage( msg )",
				"     print('Toast message set to: '..msg)",
				"else",
				"     BNSetCustomMessage( '' )",
				"     print('Toast message cleared' )",
				"end" },
		},
		
		["names"] = { 
			desc = "toggles the display of names in the 3d world",
			vers = 1.3,
			state = on,
			code = {	
				"if InCombatLockdown() then",
				"     print('You can no longer toggle names while in combat')",
				"     return",
				"end",
				"if type(saved.showing) ~= 'boolean' then",
				"     saved.showing = true",
				"end",
				"local what = { 'UnitNameEnemyGuardianName', 'UnitNameEnemyPetName', 'UnitNameEnemyPlayerName', 'UnitNameEnemyTotemName',",
				"     'UnitNameFriendlyGuardianName', 'UnitNameFriendlyPetName', 'UnitNameFriendlyPlayerName', 'UnitNameFriendlySpecialNPCName',",
				"     'UnitNameFriendlyTotemName', 'UnitNameGuildTitle', 'UnitNameHostleNPC', 'UnitNameNPC',",
				"     'UnitNameNonCombatCreatureName', 'UnitNameOwn', 'UnitNamePlayerGuild', 'UnitNamePlayerPVPTitle',",
				"     'nameplateShowEnemies', 'nameplateShowEnemyGuardians', 'nameplateShowEnemyPets', 'nameplateShowEnemyTotems',",
				"     'nameplateShowFriendlyGuardians', 'nameplateShowFriendlyPets', 'nameplateShowFriendlyTotems', 'nameplateShowFriends',",
				"     }",
				"if saved.showing then",
				"     for x = 1, #what do",
				"          saved[what[x]] = GetCVar(what[x])",
				"          SetCVar( what[x], '0')",
				"     end",
				"     saved.showing = false",
				"else",
				"     for x = 1, #what do",
				"          SetCVar( what[x], saved[what[x]])",
				"     end",
				"     saved.showing = true",
				"end" },
		},
		
		["cdown"] = { 
			desc = "counts down from passed number by optional second passed number",
			vers = 1.1,
			state = on,
			code = {	
				"local delay, by = string.split(' ', msg)",
				"delay = tonumber(delay)",
				"by = tonumber(by)",
				"if not(by) then by = 1 end",
				"if delay then",
				"	for x = delay, 0, -by do",
				"		BillsUtils.Wait( delay, SendChatMsg, tostring(x), 'SAY' )",
				"	end",
				"end" },
		},
		
		["quitaftertaxi"] = {
			desc = "quits the game once you land from a taxi flight",
			vers = 1.14,
			alias = "qat",
			state = on,
			code = {	
				"msg = string.lower(msg)",
				"if msg == 'cancel' then",
				"     print('Auto-'..(static.logout and 'Logout' or 'Exit')..' after Taxi has been cancelled')",
				"     static.cancel = true",
				"     return",
				"elseif msg == 'logout' then",
				"     static.logout = true",
				"end",
				"if static.cancel then",
				"     table.wipe(static)",
				"     return",
				"end",
				"if not(static.count) or static.count == 3 then",
				"     static.count = 0",
				"end",
				"static.count = static.count + 1",
				"if UnitOnTaxi( 'player' ) then",
				"     static.running = true",
				"     if static.count == 1 then",
				"          print('|cFFFF0000You will '..(static.logout and'Logout of' or 'Exit')..' the game once you land (to cancel type /quitaftertaxi cancel)')",
				"     end",
				"elseif not(static.running) and static.count == 1 then",
				"     print('|cFFFF0000Once you select a flight then land you will '..(static.logout and'Logout of' or 'Exit')..' the game (to cancel type /quitaftertaxi cancel)')",
				"elseif static.running and static.logout then",
				"     Logout()",
				"elseif static.running then",
				"     ForceQuit()",
				"end",
				"BillsUtils.Wait( 5, (MacroEditBox:GetScript('OnEvent')), MacroEditBox, 'EXECUTE_CHAT_LINE', '/quitaftertaxi' )" },
		},
		
		["mount"] = { 
			desc = "summons the first mount matching the passed string (attempts flying mounts first)",
			vers = 2.04,
			state = on,
			code = {	
				"msg = string.lower(msg)",
				"if InCombatLockdown() then",
				"     print('You cannot summon a mount this way while in combat')",
				"     return",
				"elseif msg == '' then",
				"     print('proper usage is /mount partialmountname')",
				"     return",
				"elseif msg == 'random' then",
				"     C_MountJournal.Summon(0)",
				"     print('Trying to summon a random favorite mount for you')",
				"     return",
				"end",
				"local flyable = IsFlyableArea()",
				"local Match, Name",
				"for x = 1, C_MountJournal.GetNumMounts() do",
				"     local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetMountInfo(x)",
				"     if not( hideOnChar ) and isUsable and isCollected then",
				"          local creatureDisplayID, descriptionText, sourceText, isSelfMount, mountType = C_MountJournal.GetMountInfoExtra(x)",
				"          if string.find( string.lower(creatureName), msg, nil, true ) then",
				"               if (flyable and (mountType == 247 or mountType == 248)) or not(flyable) then",
				"                    Match, Name = x, creatureName",
				"                    break",
				"               elseif not( Match ) then",
				"                    Match, Name = x, creatureName",
				"               end",
				"          end",
				"     end",
				"end",
				"if Match then",
				"     C_MountJournal.Summon(Match)",
				"     print('Summoning '..Name)",
				"else",
				"     print('No usable mount matching \\\"'..msg..'\\\" was found.')",
				"end" },
		},
		
		["critter"] = {
			desc = "summons the first vanity pet matching the passed string (attempts favorite pets first)",
			vers = 1.22,
			alias = "vpet",
			state = on,
			code = {	
				"msg = string.lower(msg)",
				"if InCombatLockdown() then",
				"     print('You cannot summon a pet this way while in combat')",
				"     return",
				"elseif msg == '' then",
				"     print('proper usage is /critter PartialPetName')",
				"     return",
				"end",
				"local numPets, numOwned = C_PetJournal.GetNumPets()",
				"local Match, Name",
				"for x = 1, numPets do",
				"     local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(x)",
				"     if owned and ( string.find( (string.lower(customName and customName or '')), msg, nil, true ) or string.find( (string.lower(speciesName)), msg, nil, true )  )then",
				"          if favorite then",
				"               Match, Name = petID, string.find( string.lower(customName and customName or ''), msg, nil, true) and customName or speciesName",
				"               break",
				"          elseif not( Match ) then",
				"               Match, Name = petID, string.find( string.lower(customName and customName or ''), msg, nil, true) and customName or speciesName",
				"          end",
				"     end",
				"end",
				"if Match then",
				"     C_PetJournal.SummonPetByGUID(Match)",
				"     print('Summoning '..Name)",
				"else",
				"     print('No owned vanity pet matching \\\"'..msg..'\\\" was found.')",
				"end" },
		},
		
		["wboss"] = {
			desc = "Are the weekly world bosses/quests done?",
			vers = 1.2,
			alias = "weekly",
			state = on,
			code = {	
				"local completed, uncomplete = {}, {}",
				"local wb = { 	Ordos = 33118,",
				"     ['Trove of the Thunder King'] = 32609,",
				"     Celestials = 33117,",
				"     Galleon = 32098,",
				"     Nalak = 32518,",
				"     Oondasta = 32519,",
				"     ['Sha of Anger'] = 32099,",
				"     ['Victory In Wintergrasp'] = {13181, 13183},",
				"     ['Victory In Tol Barad'] = {28882, 28884},",
				"     ['Empowering the Hourglass'] = 33338,",
				"     ['Strong Enough To Survive'] = 33334,",
				"}",
				"for k, v in pairs( wb ) do",
				"     if (type(v) == 'table' and (IsQuestFlaggedCompleted(v[1]) or IsQuestFlaggedCompleted(v[2]))) or (type(v) == 'number' and IsQuestFlaggedCompleted(v)) then",
				"          completed[#completed + 1] = k",
				"     else",
				"          uncomplete[#uncomplete + 1] = k",
				"     end",
				"end",
				"table.sort(completed)",
				"table.sort(uncomplete)",
				"print('Weekly world bosses / quest complete?')",
				"if #completed > 0 then",
				"     print('\\n|cFF66CC00Completed:')",
				"     for x = 1, #completed do",
				"          print('|cff80FF00      '..completed[x])",
				"     end",
				"end",
				"if #uncomplete > 0 then",
				"     print('\\n|cFFFF3333Uncomplete:')",
				"     for x = 1, #uncomplete do",
				"          print('|cFFFF6666      '..uncomplete[x])",
				"     end",
				"end" },
		},
		
		["dboss"] = {
			desc = "Are the daily world bosses/quests done?",
			vers = 1.15,
			alias = "daily",
			state = on,
			code = {
				"local completed, uncomplete = {}, {}",
				"local db = { 	['Path of the Mistwalker'] = 33374,",
				"     ['Timeless Trivia'] = 33211,",
				"     ['Neverending Spritewood'] = 32961,",
				"     Zarhym = 32962,",
				"     ['Archiereus of Flame'] = 333112,",
				"     ['Blingtron 4000'] = 31752,",
				"}",
				"for k, v in pairs( db ) do",
				"     if (type(v) == 'table' and (IsQuestFlaggedCompleted(v[1]) or IsQuestFlaggedCompleted(v[2]))) or (type(v) == 'number' and IsQuestFlaggedCompleted(v)) then",
				"          completed[#completed + 1] = k",
				"     else",
				"          uncomplete[#uncomplete + 1] = k",
				"     end",
				"end",
				"table.sort(completed)",
				"table.sort(uncomplete)",
				"print('Daily world bosses / quest complete?')",
				"if #completed > 0 then",
				"     print('\\n|cFF66CC00Completed:')",
				"     for x = 1, #completed do",
				"          print('|cff80FF00      '..completed[x])",
				"     end",
				"end",
				"if #uncomplete > 0 then",
				"     print('\\n|cFFFF3333Uncomplete:')",
				"     for x = 1, #uncomplete do",
				"          print('|cFFFF6666      '..uncomplete[x])",
				"     end",
				"end" },
		},
		
	}

SM.SetDefaults = function()
	table.wipe( SlashMagic_Commands )
	SlashMagic_Commands.cmds = {}
	SlashMagic_Commands.code = {}
	SlashMagic_Commands.desc = {}
	SlashMagic_Commands.vers = {}
	SlashMagic_Commands.alias = {}

	local cmds = SlashMagic_Commands.cmds
	local code = SlashMagic_Commands.code
	local desc = SlashMagic_Commands.desc
	local vers = SlashMagic_Commands.vers
	local alias = SlashMagic_Commands.alias
	local dcmds = SM.Commands_Defaults
		
	for index in pairs(dcmds) do
		cmds[index] = index
		desc[index] = dcmds[index].desc
		vers[index] = dcmds[index].vers
		code[index] = { unpack( dcmds[index].code ) }
		alias[index] = dcmds[index].alias 
	end
	
	SlashMagic_Settings.Salted = true
	return
end

SM.Enable = function( index )
	if not( SMS.Enable ) then
		return
	end
	if not(SlashMagic_CmdVars[index]) then
		SlashMagic_CmdVars[index] = {}
	end
	
	SlashMagicStaticValues[index] = {}
	
	if CMDS[index] then
		local cmdName = cmdKey:format(strupper(index))
		local CodeCleanup = {unpack(CODE[index])}
		for x = 1, #CodeCleanup do
			CodeCleanup[x] = string.trim( CodeCleanup[x]) -- removes excess spaces at start / end
			local found = string.find( CodeCleanup[x], "--", 1, true) -- removes comments
			if found then
				if found == 1 then
					CodeCleanup[x] = ""
				else
					CodeCleanup[x] = string.sub(CodeCleanup[x], 1, found - 1)
				end
			end
		end
		local code = string.join(" ", unpack(CodeCleanup) )
		code = string.format("local saved = SlashMagic_CmdVars['%s'] local static = SlashMagicStaticValues['%s'] ", index, index) .. code
		RunScript( ('SLASH_%s1 = "/%s"'):format( cmdName, strlower(index) ) )
		if ALIAS[index] then
			local aliases = { string.split(" ", ALIAS[index]) }
			for x = 1, #aliases do
				RunScript( ('SLASH_%s%d = "/%s"'):format( cmdName, x+1, strlower(aliases[x]) ) )
			end
		end
		RunScript( ('SlashCmdList["%s"] = function(msg) %s end'):format( cmdName, code) )
	end
end

SM.Disable = function( index, force )
	if type(CMDS[index]) == "boolean" or force then
		local cmdName = cmdKey:format(strupper(index))
		local i=1;
		while _G["SLASH_"..cmdName..i]~=nil do
			local slash=strupper(_G["SLASH_"..cmdName..i]);
			_G["SLASH_"..cmdName..i]=nil;--   Removes SLASH_*
			hash_SlashCmdList[slash]=nil;-- Removes from hash_SlashCmdList
			i=i+1;
		end

		SlashCmdList[cmdName]=nil;--  Removes from SlashCmdList
		getmetatable(SlashCmdList).__index[cmdName]=nil;--    Removes from metatable
	end
end
	
SM.Reset1 = function( index )
	if type( SM.Commands_Defaults[index].state ) == "boolean" then
		SM.Disable( index )		
		
		CMDS[index] = index
		DESC[index] = SM.Commands_Defaults[index].desc
		VERS[index] = SM.Commands_Defaults[index].vers
		CODE[index] = { unpack( SM.Commands_Defaults[index].code ) }
		ALIAS[index] = SM.Commands_Defaults[index].alias
		
		SM.Enable( index )
		return true
	end
	return false
end

SM.Reset = function()
	SlashMagic_Settings.Salted = false
	for index, value in pairs( CMDS ) do
		if value then
			SM.Disable( index )
		end
	end

	SM.SetDefaults()

	CMDS = SlashMagic_Commands.cmds
	CODE = SlashMagic_Commands.code
	DESC = SlashMagic_Commands.desc
	ALIAS = SlashMagic_Commands.alias
	
	for index, value in pairs( CMDS ) do
		if value then
			SM.Enable( index )
		end
	end
end

SM.Update = function()
	local dcmds = SM.Commands_Defaults
	
	local cmds = SlashMagic_Commands.cmds
	local code = SlashMagic_Commands.code
	local desc = SlashMagic_Commands.desc
	local vers = SlashMagic_Commands.vers
	local alias = SlashMagic_Commands.alias
	
	if not( SlashMagic_Commands.vers ) then
		SlashMagic_Commands.vers = {}
	end
	if not(	SlashMagic_Commands.alias ) then
		SlashMagic_Commands.alias = {}
	end
	for index, value in pairs( dcmds ) do
		local dver = dcmds[index].vers
		print( type(ver), type(vers[index]))
		if not( dver ) or ( type(vers[index]) == "number" and dver > vers[index]) then
			cmds[index] = index
			desc[index] = dcmds[index].desc
			vers[index] = dver
			code[index] = { unpack( dcmds[index].code) }
			alias[index] = dcmds[index].alias
		end
	end
end

SM.AddonEnable = function()
	for index, value in pairs(CMDS) do
		if value then
			SM.Enable( index )
		end
	end
end

SM.AddonDisable = function()
	for index, value in pairs(CMDS) do
		if value then
			SM.Disable( index, true )
		end
	end
end

SM.Frame:SetScript("OnEvent",function(self, event, ...)
	local arg = ...
	if event == "ADDON_LOADED" and arg == AddonName then
		addOptionMt( SlashMagic_Settings , SM.Settings_Defaults )
		SMS = SlashMagic_Settings
		
		if not( SMS.Salted ) then
			SM.SetDefaults()
		end
		
		if type( SlashMagic_CmdVars ) ~= "table" then
			SlashMagic_CmdVars = {}
		end
		
		SM.Update()
	
		CMDS = SlashMagic_Commands.cmds
		CODE = SlashMagic_Commands.code
		DESC = SlashMagic_Commands.desc
		VERS = SlashMagic_Commands.vers
		ALIAS = SlashMagic_Commands.alias
		
		if SMS.Enable then
			for index, value in pairs( CMDS ) do
				if value then
					SM.Enable( index )
				end
			end
		end
		SJprint(grn, FriendlyAddonName, wht, " ver:", GetAddOnMetadata( AddonName, "Version"), " loaded. type: \"/sm config\" to setup the addon", res)
	end
	return self, event, ...
end)

-- Slash Commands
SLASH_SLASHMAGIC1 = "/slashmagic"
SLASH_SLASHMAGIC2 = "/sm"

SlashCmdList["SLASHMAGIC"] = function(msg)
	msg = msg:lower()
	local cmd,arg,arg2 = string.split(" ", msg, 3)

	if cmd == "config" or cmd == "cfg" then
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo("SlashMagicConfig")
		local isLoaded = IsAddOnLoaded("SlashMagicConfig")
		if reason == "DISABLED" then
			EnableAddOn("SlashMagicConfig")
			LoadAddOn("SlashMagicConfig")
		elseif reason == "MISSING" then
			print("Slash Magic: The config gui is missing from the AddOns folder. Please reinstall SlashMagic to enable the gui.")
			return
		elseif loadable and not(isLoaded) then
			LoadAddOn("SlashMagicConfig")
		end
		
		if SM.ConfigFrame then
			SM.ConfigFrame:Show()
		else
			print("Slash Magic: There was an unknown error trying to open the config frame. Please enable the addon manually.")
		end
		return
	end
	
	if cmd == "enable" then
		OptSaveTF( SMS, "Enable", arg)
		if SMS.Enable then
			SM.AddonEnable()
		else
			SM.AddonDisable()
		end
		return
	end
	
	if cmd == "reset" then
		SM.Reset()
		return
	end
	
	if not(SMS.Enable) then
		print(" ")
		SJprint( yel, FriendlyAddonName, res)
		SJprint( yel, "  This addon is ", red, "DISABLED", res)
		SJprint( yel, "  Type: ", blu, "/sm enable on", res)
		SJprint( yel, "  to enable.", res)
		return
	end

	if type(CMDS[cmd]) ~= "boolean" then
		local temp
		for key, value in pairs(ALIAS) do
			temp = {string.split(" ", value)}
			for x = 1, #temp do
				if cmd == temp[x] then
					cmd = key
					break
				end
			end
		end
	end
	
	if type(CMDS[cmd]) == "boolean" then
		local cmdName = cmdKey:format( strupper(cmd) )
		if arg then
			local tobool = { ["on"] = 1,   ["true"] = 1,   ["1"] = 1, ["yes"] = 1,
							 ["off"] = 0, ["false"] = 0, ["0"] = 0, ["no"] = 0}
			
			if tobool[arg] then
				CMDS[cmd] = tobool[ arg ] == 1
				if CMDS[cmd] then
					SM.Enable( cmd )
				else
					SM.Disable( cmd )
				end
				
			elseif arg == "reset" then
				if SM.Reset1( cmd ) then
					SJprint( yel, "Slash Magic:", blu, cmd, yel, "has been reset to default.", res)
				else
					SJprint( yel, "Slash Magic:", blu, cmd, yel, "is not a default command so it can not be reset.", res)
					return
				end
				
			else
				SJprint(yel, "Slash Magic:", wht, "valid options for commands are [on/off/reset] not", red, arg, res)
				
			end
			
		end
		
		SJprint( yel, "Slash Magic:", blu, cmd, yel, "is set", (CMDS[cmd] and (grn.."ON") or (red.."OFF")), res)
		return
	end
	
	if cmd == "cmdlist" or cmd == "help" or cmd == "" then
		local CmdList = {}
		for index in pairs(CMDS) do
			CmdList[#CmdList +1] = index
		end
		table.sort(CmdList)
		SJprint(yel, FriendlyAddonName, res)
		SJprint(yel, "This is a list of all available commands and whether they are enabled or not", res)
		print(" ")
		for x = 1, #CmdList do
			local index = CmdList[x]
			local bool = CMDS[index]
			local desc = DESC[index]
			print( ("%s%d. %s/%s%s     %s"):format(wht, x, ( bool and grn or red ), index, res, desc ) )
			print(" ")
		end
		SJprint(yel, "Active commands are listed as", grn, "GREEN", yel, "while inactive commands are", red, "RED", res)
		SJprint(yel, "Type:", blu, "/sm COMMANDNAME on/off", yel, "to change a commands state", res)
		SJprint(yel, "Type:", blu, "/sm config", yel, "to edit commands and settings", res)
		return
	end
	
	print(" ")
	SJprint( yel, FriendlyAddonName, res)
	SJprint( yel, "  Error: ", red, cmd, yel, " is not a valid command nor command alias", res)
	SJprint( yel, "  Type: ", blu, "/sm ", yel, "for the addon status and command list", res)
	SJprint( yel, "  Type: ", blu, "/sm ", "cmdlist", yel, "for command list help", res)
	return

end

