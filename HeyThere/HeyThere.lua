SLASH_HEYTHERE1 = "/hey"
SLASH_HEYTHERE2 = "/heythere"
SlashCmdLst["HEYTHERE"] = function(self, txt)
	if UnitExists("target") then
		SendChatMessage("Hello " .. UnitName("target"), "SAY")
	else
		SendChatMessage("Hey there everybody!")
	end
end
