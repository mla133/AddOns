local Congrats_EventFrame = CreateFrame("Frame")
Congrats_EventFrame:RegisterEvent("PLAYER_LEVEL_UP")

-- "OnEvent is passed different parameters, first 2 should always be self and event, and use ... to handle any others passed
Congrats_EventFrame:SetScript("OnEvent",
	function(self,event, ...)
		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...
		print('Congrats on reaching level ' .. arg1 .. ', ' .. UnitName("Player") .. '! You gained ' .. arg2 .. 'HP and ' .. arg3 .. ' MP!')
	end

-- arg1: new char level
-- arg2: HP gained
-- arg3: MP gained
-- arg4: talent points gained
-- arg5: STR gained
-- arg6: AGI gained
-- arg7: STA gained
-- arg8: INT gained
-- arg9: SPR gained
