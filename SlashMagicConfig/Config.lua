local AddonName, AddonTable = ...
local SM = SlashMagicAddonTable

-- Bill's Utils
local ChkBox = BillsUtils.ChkBox
local CheckClick = BillsUtils.CheckClick
local SliderMW = BillsUtils.SliderMW

BillsUtils.Locals[#BillsUtils.Locals +1] = function ()
	ChkBox = BillsUtils.ChkBox
	CheckClick = BillsUtils.CheckClick
	SliderMW = BillsUtils.SliderMW
end

-- ****************************************************************************
-- * Color Changing Button Stuff                                              *
-- ****************************************************************************

local ButtonTextures = {
	RED = {
		up = "Interface\\Buttons\\UI-Panel-Button-Up",
		down = "Interface\\Buttons\\UI-Panel-Button-Down",
		highlight = "Interface\\Buttons\\UI-Panel-Button-Highlight",
	},
	GREEN = {
		up = "Interface\\AddOns\\SlashMagicConfig\\Green-Panel-Button-Up",
		down = "Interface\\AddOns\\SlashMagicConfig\\Green-Panel-Button-Down",
		highlight = "Interface\\AddOns\\SlashMagicConfig\\Green-Panel-Button-Highlight",
	},
	BLUE = {
		up = "Interface\\AddOns\\SlashMagicConfig\\Blue-Panel-Button-Up",
		down = "Interface\\AddOns\\SlashMagicConfig\\Blue-Panel-Button-Down",
		highlight = "Interface\\AddOns\\SlashMagicConfig\\Blue-Panel-Button-Highlight",
	},
	GREY = {
		up = "Interface\\AddOns\\SlashMagicConfig\\Grey-Panel-Button-Up",
		down = "Interface\\AddOns\\SlashMagicConfig\\Grey-Panel-Button-Down",
		highlight = "Interface\\AddOns\\SlashMagicConfig\\Grey-Panel-Button-Highlight",
	},
}

local function GetSkin(self)
	return self.__skin
end

local function SetSkin(self, skin)
	if self.__skin == skin then return end
	self.__skin = skin

	if self:IsMouseOver() and IsMouseButtonDown() then
		local down = ButtonTextures[skin].down
		self.Left:SetTexture(down)
		self.Right:SetTexture(down)
		self.Middle:SetTexture(down)
	else
		local up = ButtonTextures[skin].up
		self.Left:SetTexture(up)
		self.Right:SetTexture(up)
		self.Middle:SetTexture(up)
	end

	self:SetHighlightTexture(ButtonTextures[skin].highlight, "ADD")
	self:GetHighlightTexture():SetTexCoord(0, 80/128, 0, 22/32)
end

local function OnMouseDown(self, button)
	local down = ButtonTextures[self.__skin].down
	self.Left:SetTexture(down)
	self.Right:SetTexture(down)
	self.Middle:SetTexture(down)
end

local function OnMouseUp(self, button)
	local up = ButtonTextures[self.__skin].up
	self.Left:SetTexture(up)
	self.Right:SetTexture(up)
	self.Middle:SetTexture(up)
end

local function NewButton(parent, skin, name)
	local button = CreateFrame("Button", name, parent or UIParent)
	button:SetSize(40, 22)

	local left = button:CreateTexture(nil, "BACKGROUND")
	left:SetPoint("TOPLEFT")
	left:SetPoint("BOTTOMLEFT")
	left:SetWidth(12)
	left:SetTexCoord(0, 12/128, 0, 22/32)
	button.Left = left

	local right = button:CreateTexture(nil, "BACKGROUND")
	right:SetPoint("TOPRIGHT")
	right:SetPoint("BOTTOMRIGHT")
	right:SetWidth(12)
	right:SetTexCoord(68/128, 80/128, 0, 22/32)
	button.Right = right

	local middle = button:CreateTexture(nil, "BACKGROUND")
	middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
	middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
	middle:SetTexCoord(12/128, 68/128, 0, 22/32)
	button.Middle = middle

	local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetAllPoints(true)
	text:SetJustifyH("CENTER")
	text:SetJustifyV("CENTER")
	button:SetFontString(text)
	button:SetNormalFontObject("GameFontNormal")
	button:SetHighlightFontObject("GameFontHighlight")	

	button:SetScript("OnMouseDown", OnMouseDown)
	button:SetScript("OnMouseUp", OnMouseUp)
	button:SetScript("OnShow", OnMouseUp)

	button.GetSkin = GetSkin
	button.SetSkin = SetSkin

	SetSkin(button, skin or "RED")

	return button
end

-- ****************************************************************************
-- * Misc Functions and Settings                                              *
-- ****************************************************************************
local CmdListButtons = {}
local DisplayedButtons = 0
local Selected = false
local OldSelected = false
local BottomButtons = { "Active", "New", "Delete", "Default", "Restore", "Reset", "Save", "Close" }
local oldpos = -1
local oldLinePixels= -1
local pos
local me

local IndentationLib = AddonTable.IndentationLib
local ColorTable = AddonTable.defaultColorTable
-- Assign basic colors
do
	local T = IndentationLib.Tokens
	--- Assigns a color to multiple tokens at once.
	local function Color ( Code, ... )
		for Index = 1, select( "#", ... ) do
			ColorTable[ select( Index, ... ) ] = Code;
		end
	end
	Color( "|cff88bbdd", T.KEYWORD ); -- Reserved words
	Color( "|cffff6666", T.UNKNOWN );
	Color( "|cffcc7777", T.CONCAT, T.VARARG,
		T.ASSIGNMENT, T.PERIOD, T.COMMA, T.SEMICOLON, T.COLON, T.SIZE );
	Color( "|cffffaa00", T.NUMBER );
	Color( "|cff888888", T.STRING, T.STRING_LONG );
	Color( "|cff55cc55", T.COMMENT_SHORT, T.COMMENT_LONG );
	Color( "|cffccaa88", T.LEFTCURLY, T.RIGHTCURLY,
		T.LEFTBRACKET, T.RIGHTBRACKET,
		T.LEFTPAREN, T.RIGHTPAREN,
		T.ADD, T.SUBTRACT, T.MULTIPLY, T.DIVIDE, T.POWER, T.MODULUS );
	Color( "|cffccddee", T.EQUALITY, T.NOTEQUAL, T.LT, T.LTE, T.GT, T.GTE );
end

local ichars = function( value, block ) -- replace invisible chars in string
	value = value:gsub("|c%x%x%x%x%x%x%x%x", (block and "XCOLORCODE" or ""))
	value = value:gsub("|r", (block and "RR" or ""))
	return value
end

local EDGE = 48 -- lines to keep around edge of screen in editor * 12 pixel font size

local HintSet = function(self) --sets the "OnEnter" hint 
	me.HintFrameText:SetText( self.HintText )
end
local HintClear = function() --clears hint on "OnLeave"
	me.HintFrameText:SetText( " " )
end

local Backdrop={ --Main Frames
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0
	}
}
local Backdrop2={ --Sub Frames
	bgFile = "",
	edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0
	}
}
local Backdrop3 = { --Edit Boxes
	bgFile="",
	edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
	tile="true",
	tileSize= 32,
	edgeSize=10,
	insets = {
		left=5,
		right=5,
		top=5,
		bottom=5
	}
}


local CmdListDisplayUpdate = function()
	local list = {}
	local offset
	local size = 0
	local cmds = SlashMagic_Commands.cmds
	local code = SlashMagic_Commands.code
	local desc = SlashMagic_Commands.desc
	local dcmds = SM.Commands_Defaults
	local alias = SlashMagic_Commands.alias
	
	for index in pairs( cmds ) do
		list[#list + 1] = index
	end
	table.sort( list )
	size = #list
	if not(Selected) then
		Selected = list[1]
	end
	
	if size <= DisplayedButtons then
		me.BFslider:SetValue(0)
		me.BFslider:Disable()
	else
		me.BFslider:Enable()
		me.BFslider:SetMinMaxValues( 0, size - DisplayedButtons)
	end
	
	offset = me.BFslider:GetValue()
	
	for x = 1, DisplayedButtons do
		local which = x + offset
		local button = CmdListButtons[ x ]
		if which <= size then
			button:SetText(list[which])
			if Selected == list[which] then
				button:SetSkin("BLUE")
				if cmds[list[which]] then
					me.Active:SetText("Active")
					me.Active:SetSkin("GREEN")
				else
					me.Active:SetText("Not Active")
					me.Active:SetSkin("RED")
				end
			elseif cmds[ list[which] ] then
				button:SetSkin("GREEN")
			else
				button:SetSkin("RED")
			end
		else
			button:SetText("")
			button:SetSkin("GREY")
		end
	end
	if dcmds[Selected] then
		me.Default:SetSkin("GREEN")
	else
		me.Default:SetSkin("GREY")
	end
	
	if OldSelected ~= Selected then
		OldSelected = Selected
		me.NameFrameText:SetText( ("Name: %s"):format(Selected) )
		local whatisit = type(SlashMagic_Commands.vers[Selected])
		if whatisit == "number" then
			me.VersionText:SetText(("Version: %.2f"):format(SlashMagic_Commands.vers[Selected]))
		elseif whatisit == "string" then
			me.VersionText:SetText(("Version: %s"):format(SlashMagic_Commands.vers[Selected]))
		else
			me.VersionText:SetText(" ")
		end
		me.AliasEBox:SetText( SlashMagic_Commands.alias[Selected] and SlashMagic_Commands.alias[Selected] or "")
		me.DescFrameEBox:SetText( SlashMagic_Commands.desc[Selected] )
		local tempCode = string.join("\r",unpack(SlashMagic_Commands.code[Selected]))
		--tempCode = string.gsub( tempCode, "|", "||" )
		me.CodeFrameEBox:SetText( tempCode )
	end
end

local acceptDialogHandler = function( self, data, data2)
	if data == "DELETE" then -- Deletes Selected command
		SM.Disable(Selected)
		SlashMagic_Commands.cmds[Selected] = nil
		SlashMagic_Commands.code[Selected] = nil
		SlashMagic_Commands.desc[Selected] = nil
		SlashMagic_Commands.alias[Selected] = nil
		Selected = false
	elseif data == "RESET ADDON" then -- Resets Addon Back To "Factory"
		SM.Reset()
		Selected = false
	elseif data == "DEFAULT COMMAND" then -- Restores selected command to "factory default"
		SM.Reset1( Selected )
		OldSelected = false
	elseif data == "RESTORE" then -- Restore to state before last save
		OldSelected = false
	end
	CmdListDisplayUpdate()
end

StaticPopupDialogs["SLASHMAGIC"] = {
	text = "%s",
	button1 = "Yes",
	button2 = "No",
	OnAccept = acceptDialogHandler,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/ 
}

local BottomButtonHandler = function(self, button, down)
	if button ~= "LeftButton" or self:GetSkin() == "GREY" then
		return
	end
	PlaySound( "GAMEGENERICBUTTONPRESS" )
	local IAm = self.Name
	if IAm == "Active" then
		SlashMagic_Commands.cmds[Selected] = not( SlashMagic_Commands.cmds[Selected] )
		if SlashMagic_Commands.cmds[Selected] then
			SM.Enable( Selected )
		else
			SM.Disable( Selected )
		end
		CmdListDisplayUpdate()
	elseif IAm == "New" then
		me.NewCmdFrame:Show()
	elseif IAm == "Delete" then
		local dialog = StaticPopup_Show("SLASHMAGIC", ("Are you sure you want to delete the selected command: %s ?"):format(Selected))
		dialog.data = "DELETE"
	elseif IAm == "Default" then
		local dialog = StaticPopup_Show("SLASHMAGIC", ("Do you want to restore \"%s\" back to \"Factory\" default?"):format( Selected ))
		dialog.data = "DEFAULT COMMAND"
	elseif IAm == "Restore" then
		local dialog = StaticPopup_Show("SLASHMAGIC", ("Are you sure you want to discard all of your changes to \"%s\" since the last save?" ):format(Selected))
		dialog.data = "RESTORE"
	elseif IAm == "Reset" then
		local dialog = StaticPopup_Show("SLASHMAGIC", "Are you sure you want to reset the addon back to \"Factory\" conditions. This will remove all custom created commands and restore the original functionality to the addon." )
		dialog.data = "RESET ADDON"
	elseif IAm == "Close" then
		me:Hide()
	elseif IAm == "Save" then
		SlashMagic_Commands.desc[Selected] = me.DescFrameEBox:GetText()
		SlashMagic_Commands.vers[Selected] = "Custom"
		SlashMagic_Commands.code[Selected] = {string.split("\r", me.CodeFrameEBox:GetText()) }
		local aliases = me.AliasEBox:GetText()
		aliases = string.trim(aliases)
		aliases = string.gsub( aliases, "%s%s+", " ")
		if aliases == " " or aliases == "" then
			SlashMagic_Commands.alias[Selected] = nil
		else
			SlashMagic_Commands.alias[Selected] = aliases
		end
		SM.Disable(Selected)
		SM.Enable(Selected)
		OldSelected = false
		CmdListDisplayUpdate()
	end
end

-- ****************************************************************************
-- * Frame begins here                                                        *
-- ****************************************************************************

SM.ConfigFrame = CreateFrame("Frame" , "SMConfigFrame", UIParent )
me = SM.ConfigFrame
me:SetFrameStrata("DIALOG")
me:Hide()
me:EnableMouse(true)
me:SetPoint("CENTER", UIParent, "CENTER")
me:SetHeight( .80 * GetScreenHeight() )
me:SetWidth( .80 * GetScreenWidth() )
me:SetBackdrop( Backdrop )
me:SetBackdropColor( 128, 128,128, 1)
me:SetBackdropBorderColor( 255, 255, 255, 1)
me:SetMovable(true)
me:SetUserPlaced(false)
me:SetClampedToScreen(true)

me:SetScript("OnShow", function(self)
	if DisplayedButtons == 0 then
		me.Enable:SetChecked(SlashMagic_Settings.Enable)
		
		local MaxButtons = 0
		local BHeight = 0
		local BFHeight = me.ButtonFrame:GetHeight()
		local whatsleft
		local PrevButton
		
		repeat
			DisplayedButtons = DisplayedButtons + 1
			CmdListButtons[DisplayedButtons] = NewButton( me.ButtonFrame, "RED", "SMCmdListButton"..DisplayedButtons )
			local Button = CmdListButtons[DisplayedButtons]
			local fontString = Button:GetFontString()
			fontString:SetJustifyH("LEFT")
			fontString:ClearAllPoints()
			fontString:SetPoint("TOPRIGHT", Button, "TOPRIGHT")
			fontString:SetPoint("BOTTOMLEFT", Button, "BOTTOMLEFT", 7, 0)
			if DisplayedButtons == 1 then
				Button:SetPoint("TOPLEFT", me.ButtonFrame,  "TOPLEFT", 5, -5)
				BHeight = Button:GetHeight()
				MaxButtons = math.floor(BFHeight / BHeight)
				whatsleft = BFHeight % BHeight
			else
				Button:SetPoint("TOP", PrevButton,  "BOTTOM", 0, 1 )
			end
			Button:SetWidth( 140 )
			Button:SetScript("OnClick", function(self, button, down)
				if button ~= "LeftButton" or self:GetSkin() == "GREY" then
					return
				end
				PlaySound( "GAMEGENERICBUTTONPRESS" )
				local text = self:GetText()
				if text ~= "" and text ~= nil then
					Selected = text
					CmdListDisplayUpdate()
				end
				return
			end)
			Button.HintText = "Select the command you would like to edit, or scroll the list with your mousewheel. (Holding shift will scroll 5x faster)"
			Button:SetScript("OnEnter", HintSet )
			Button:SetScript("OnLeave", HintClear )
			PrevButton = Button
		until DisplayedButtons == MaxButtons
		me:SetHeight( me:GetHeight() - whatsleft + 7)
		CmdListDisplayUpdate()
		me.BFslider:SetValue(0)
		
		local BottomButtonWidth = me.HintFrame:GetWidth() / (#BottomButtons)
		
		for x = 1, #BottomButtons do
			me[BottomButtons[x]]:SetWidth(BottomButtonWidth)
		end
	end

	me.StrLen:SetWidth( me.EBoxOverlay:GetWidth() - 12)
	me.CodeFrameEBox:SetWidth( me.EBoxOverlay:GetWidth() - 3)
end)

me:RegisterEvent("PLAYER_REGEN_DISABLED")
me:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
		self:Hide()
	end
end)

-- Line Number measurement fontstring
me.StrLen = me:CreateFontString(nil, "BACKGROUND" )
local StrLen = me.StrLen
StrLen:SetFontObject("ChatFontNormal")
StrLen:SetPoint("TOPLEFT", me, "TOPLEFT")
StrLen:SetFont("Interface\\addons\\SlashMagicConfig\\VeraMono.ttf", 12 )
StrLen:SetJustifyH("LEFT")
StrLen:Hide()
StrLen:SetNonSpaceWrap()

-- Title region
me.TitleRegion = me:CreateTitleRegion()
me.TitleRegion:SetSize( 324, 64)
me.TitleRegion:SetPoint( "TOP", me, "TOP", 0,12)

-- Title frame header
me.TitleBkgnd=me:CreateTexture(nil , "ARTWORK")
me.TitleBkgnd:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
me.TitleBkgnd:SetSize( 324, 64)
me.TitleBkgnd:SetPoint( "TOP", me, "TOP", 0,12)

-- Title frame text
me.Title = me:CreateFontString( nil , "OVERLAY", "GameFontHighlight")
me.Title:SetText("Slash Magic")
me.Title:SetPoint( "CENTER", me.TitleBkgnd, "CENTER", 0, 12 )
me.Title:SetJustifyH( "CENTER" )
me.Title:SetJustifyV( "MIDDLE" )

-- Enable Checkbox
me.Enable = ChkBox( nil, "SMConfig", "Enable", me, CheckClick, "Enables the addon to function", nil, 15, -30 )
me.Enable.HintText = "This will enable/disable the addon. Slash commands will not work when the addon is disabled but you can edit them. This setting takes effect immediately."
me.Enable:SetScript("OnEnter", HintSet )
me.Enable:SetScript("OnLeave", HintClear )
me.Enable:SetScript("OnClick", function(self)
	SlashMagic_Settings.Enable = self:GetChecked() == 1
	if SlashMagic_Settings.Enable then
		SM.AddonEnable()
	else
		SM.AddonDisable()
	end
end)

-- Button Frame for command list buttons
me.ButtonFrame = CreateFrame("Frame" , "SMCommandButtonFrame", me )
local ButtonFrame = me.ButtonFrame
ButtonFrame:SetBackdrop( Backdrop2 )
ButtonFrame:SetBackdropColor( 128, 128,128, 1)
ButtonFrame:SetBackdropBorderColor( 255, 255, 255, 1)
ButtonFrame:SetPoint( "TOPLEFT", me, "TOPLEFT", 10, -70 )
ButtonFrame:SetPoint( "BOTTOMLEFT", me, "BOTTOMLEFT", 10, 92 )
ButtonFrame:SetWidth(150)
ButtonFrame:EnableMouseWheel(1)

ButtonFrame:SetScript("OnMouseWheel", function(self, delta)
	SliderMW(me.BFslider, -delta)
end)

ButtonFrame.HintText = "Select the command you would like to edit, or scroll the list with your mousewheel. (Holding shift will scroll 5x faster)"
ButtonFrame:SetScript("OnEnter", HintSet )
ButtonFrame:SetScript("OnLeave", HintClear )

-- Slider for button list
me.BFslider = CreateFrame( "Slider", "SMBFSlider", me, "OptionsSliderTemplate" )
local BFslider = me.BFslider
BFslider:SetMinMaxValues( 0, 1 )
BFslider:SetOrientation("VERTICAL")
BFslider:SetPoint("TOPLEFT", me.ButtonFrame ,"TOPRIGHT", -4, 0)
BFslider:SetPoint("BOTTOM", me.ButtonFrame ,"BOTTOM" )
BFslider:SetValueStep( 1 )
BFslider:SetWidth( 16 )	
BFslider:SetScript( "OnValueChanged", CmdListDisplayUpdate )
getglobal(BFslider:GetName() .. 'Low'):SetText( " " )
getglobal(BFslider:GetName() .. 'High'):SetText( " " )
BFslider:SetScript("OnMouseWheel", function(self, delta)
	SliderMW(self, -delta)
end)
BFslider.HintText = "Scroll the list with your mousewheel. (Holding shift will scroll 5x faster)"
BFslider:SetScript("OnEnter", HintSet )
BFslider:SetScript("OnLeave", HintClear )

-- BottomButtons = { "Active", "New", "Delete", "Default", "Restore", "Reset", "Save", "Close" }
local BBHelpText = {"This button enables / disables the slash command. Green is enabled, Red is disabled", -- Active
					"This button allows you to make a new slash command", -- New
					"This button deletes the selected slash command", -- Delete
					"This button will restore an edited default command, It will turn green when a default command is selected.", -- Default
					"This button will restore an edited command back to the state of its last save", -- Restore
					"This button will reset the addon back to a fresh install state", -- Reset
					"This button will save the above description/code for the selected command", -- Save
					"This button will close the config window without saving anything",
					}
for x = 1, #BottomButtons do
	me[BottomButtons[x]] = NewButton( me, "RED", "SM"..BottomButtons[x].."Button" )
	local Button = me[BottomButtons[x]]
	if x == 1 then
		Button:SetPoint("BOTTOM", me, "BOTTOM", 0, 10)
		me[BottomButtons[x]]:SetPoint("LEFT", me.ButtonFrame, "LEFT")
	else
		Button:SetPoint("LEFT", me[BottomButtons[x-1]], "RIGHT")
	end
	Button:SetSize( 150, 25)
	Button:SetText(BottomButtons[x])
	Button.Name = BottomButtons[x]
	Button.HintText = BBHelpText[x]
	Button:SetScript("OnEnter", HintSet )
	Button:SetScript("OnLeave", HintClear )
	Button:SetScript("OnClick", BottomButtonHandler )
end


me.NameFrame = CreateFrame("Frame" , "SMNameFrame", me )
local NameFrame = me.NameFrame
NameFrame:SetBackdrop( Backdrop2 )
NameFrame:SetBackdropColor( 128, 128,128, 1)
NameFrame:SetBackdropBorderColor( 255, 255, 255, 1)
NameFrame:SetPoint( "TOPLEFT", me.ButtonFrame, "TOPRIGHT", 15, 0 )
NameFrame:SetHeight( 30 )
NameFrame:SetPoint( "RIGHT", me, "RIGHT", -10, 0)

me.NameFrameText = me.NameFrame:CreateFontString( nil , "OVERLAY", "ChatFontNormal")
local NameFrameText = me.NameFrameText
NameFrameText:SetPoint( "TOPLEFT", NameFrame, "TOPLEFT", 8, -8 )
NameFrameText:SetPoint( "BOTTOM", NameFrame, "BOTTOM", 0, 0 )
NameFrameText:SetWidth( 200 )
NameFrameText:SetJustifyH( "LEFT" )
NameFrameText:SetJustifyV( "TOP" )

me.AliasText = me.NameFrame:CreateFontString( nil , "OVERLAY", "ChatFontNormal")
local AliasText = me.AliasText
AliasText:SetPoint( "TOPLEFT", NameFrameText, "TOPRIGHT", 8, 0 )
AliasText:SetPoint( "BOTTOMRIGHT", NameFrameText, "BOTTOMRIGHT", 40, 0 )
AliasText:SetJustifyH( "LEFT" )
AliasText:SetJustifyV( "TOP" )
AliasText:SetText("Alias:")

me.VersionText =  NameFrame:CreateFontString( nil , "OVERLAY", "ChatFontNormal")
local VersionText = me.VersionText
VersionText:SetPoint( "LEFT", NameFrame, "RIGHT", -120, 0)
VersionText:SetPoint( "BOTTOM", NameFrameText, "BOTTOM")
VersionText:SetPoint( "TOP", NameFrameText, "TOP")
VersionText:SetPoint( "RIGHT", NameFrame, "RIGHT", -10, 0 )
VersionText:SetJustifyH( "RIGHT" )
VersionText:SetJustifyV( "TOP" )

me.AliasEBox = CreateFrame( "EditBox", "SMAliasEditbox", me.NameFrame ) --, "InputBoxTemplate" )
local EBox = me.AliasEBox
EBox:SetFontObject("ChatFontNormal")
EBox:SetTextInsets(5, 5, 3, 3)
EBox:SetPoint("TOPLEFT", me.AliasText, "TOPRIGHT", 0, 3 )
EBox:SetPoint("BOTTOM", me.AliasText, "BOTTOM", 0, 5 )
EBox:SetPoint("RIGHT", me.VersionText, "LEFT", -10, 0)
EBox:SetMultiLine(false)
EBox:SetBackdrop( Backdrop3 )
EBox:SetAutoFocus(false)
EBox:SetMaxLetters( 128 )
EBox:SetScript("OnEnterPressed" , function(self)
	self:ClearFocus()
end)
EBox:SetScript("OnEditFocusGained", function(self)
	self:HighlightText()
end)
EBox:SetScript("OnEscapePressed", function(self)
	self:SetCursorPosition( 0 )
	self:ClearFocus()
end)

EBox.HintText = "Set aliases to the command here with a space separated list (no slashes please)"
EBox:SetScript("OnEnter", HintSet )
EBox:SetScript("OnLeave", HintClear )

me.DescFrame = CreateFrame("Frame" , "SMDescFrame", me )
me.DescFrame:SetBackdrop( Backdrop2 )
me.DescFrame:SetBackdropColor( 128, 128,128, 1)
me.DescFrame:SetBackdropBorderColor( 255, 255, 255, 1)
me.DescFrame:SetPoint( "TOPLEFT", me.NameFrame, "BOTTOMLEFT", 0, -10 )
me.DescFrame:SetHeight( 60 )
me.DescFrame:SetPoint( "RIGHT", me.NameFrame, "RIGHT" )

me.DescFrameText = me.DescFrame:CreateFontString( nil , "OVERLAY", "ChatFontNormal")
me.DescFrameText:SetPoint( "TOPLEFT", me.DescFrame, "TOPLEFT", 8, -8 )
me.DescFrameText:SetPoint( "BOTTOM", me.DescFrame, "BOTTOM" )
me.DescFrameText:SetWidth( 40 )
me.DescFrameText:SetJustifyH( "LEFT" )
me.DescFrameText:SetJustifyV( "TOP" )
me.DescFrameText:SetText("Desc:")

me.DescFrameEBox = CreateFrame( "EditBox", "SMDescFrameEditbox", me.DescFrame )
local EBox = me.DescFrameEBox
EBox:SetFontObject("ChatFontNormal")
EBox:SetTextInsets(5, 5, 3, 3)
EBox:SetPoint("TOPLEFT", me.DescFrameText, "TOPRIGHT", 0 , 3 )
EBox:SetPoint("BOTTOMRIGHT", me.DescFrame, "BOTTOM", 5, 5 )
EBox:SetPoint("RIGHT", me.DescFrame, "RIGHT", -5, 0)
EBox:SetMultiLine(true)
EBox:SetBackdrop(Backdrop3)
EBox:SetAutoFocus(false)
EBox:SetMaxLetters( 512 )
EBox:SetScript("OnEditFocusGained", function(self)
	self:HighlightText()
end)
EBox:SetScript("OnEscapePressed", function(self)
	self:SetCursorPosition( 0 )
	self:ClearFocus()
end)

EBox.HintText = "Set the description of your command here"
EBox:SetScript("OnEnter", HintSet )
EBox:SetScript("OnLeave", HintClear )

me.CodeFrame = CreateFrame("Frame" , "SMCodeFrame", me )
me.CodeFrame:SetBackdrop( Backdrop2 )
me.CodeFrame:SetBackdropColor( 128, 128,128, 1)
me.CodeFrame:SetBackdropBorderColor( 255, 255, 255, 1)
me.CodeFrame:SetPoint( "TOPLEFT", me.DescFrame, "BOTTOMLEFT", 0, -10 )
me.CodeFrame:SetPoint( "BOTTOM", me.ButtonFrame, "BOTTOM" )
me.CodeFrame:SetPoint( "RIGHT", me.DescFrame, "RIGHT") 

me.CodeFrame.HintText = "Edit the code for your slash command here. Your function will be called as: function(msg)     Using \"--\" anywhere on a line will cause the rest of the line to be a comment even if in quotes.\nSaved variables are accessible through 'saved.whatever' and static variables through 'static.whatever' and are per command.     You may not access any upvalues, just globals, saved, and static variables"
me.CodeFrame:SetScript("OnEnter", HintSet )
me.CodeFrame:SetScript("OnLeave", HintClear )

me.CodeFrameText = me.CodeFrame:CreateFontString( nil , "OVERLAY", "ChatFontNormal")
me.CodeFrameText:SetPoint( "TOPLEFT", me.CodeFrame, "TOPLEFT", 8, -8 )
me.CodeFrameText:SetPoint( "BOTTOM", me.CodeFrame, "BOTTOM" )
me.CodeFrameText:SetWidth( 40 )
me.CodeFrameText:SetJustifyH( "LEFT" )
me.CodeFrameText:SetJustifyV( "TOP" )
me.CodeFrameText:SetText("Code:")

me.EditCodeFrame = CreateFrame("Frame" , "SMEditCodeFrame", me )
local me2 = me.EditCodeFrame
me2:SetWidth( me.CodeFrame:GetWidth() )
me2:SetHeight( me.CodeFrame:GetHeight() )
me2.HintText = "Edit the code for your slash command here. Your function will be called as: function(msg)     Using \"--\" anywhere on a line will cause the rest of the line to be a comment even if in quotes.\nSaved variables are accessible through 'saved.whatever' and static variables through 'static.whatever' and are per command.     You may not access any upvalues, just globals, saved, and static variables"
me2:SetScript("OnEnter", HintSet )
me2:SetScript("OnLeave", HintClear )

-- Scroll Frame
me.ScrollFrame = CreateFrame("ScrollFrame", "SMScrollFrame", me, "UIPanelScrollFrameTemplate")
me.ScrollFrame:SetScrollChild(me2)
me.ScrollFrame:SetPoint("TOPLEFT", me.CodeFrameText, "TOPRIGHT", 0 , 3 )
me.ScrollFrame:SetPoint("BOTTOM", me.CodeFrame, "BOTTOM", 0, 5 )
me.ScrollFrame:SetPoint("RIGHT", me.CodeFrame, "RIGHT", -5, 0)

me.LineNumbers = me2:CreateFontString( nil, "OVERLAY")
me.LineNumbers:SetFontObject("ChatFontNormal")
me.LineNumbers:SetFont("Interface\\addons\\SlashMagicConfig\\VeraMono.ttf", 12 )
me.LineNumbers:SetPoint("TOPLEFT", me2, "TOPLEFT",0 ,0)
me.LineNumbers:SetJustifyH("RIGHT")
me.LineNumbers:SetWidth(35)
me.LineNumbers:SetText("1:\r")

me.CodeFrameEBox = CreateFrame( "EditBox", "SMCodeFrameEditbox", me2)
local EBox = me.CodeFrameEBox

EBox:SetFontObject("ChatFontNormal")
EBox:SetTextInsets(5, 5, 3, 3)
EBox:SetPoint("TOPLEFT", me.LineNumbers, "TOPRIGHT", 0 , -3 )
EBox:SetMultiLine(true)
EBox:SetFont("Interface\\addons\\SlashMagicConfig\\VeraMono.ttf", 12 )
EBox:SetAutoFocus(false)
EBox:SetMaxLetters( 8192 )
EBox:SetScript("OnEditFocusGained", function(self)
	self:HighlightText()
end)
EBox:SetScript("OnEscapePressed", function(self)
	self:SetCursorPosition( 0 )
	self:ClearFocus()
end)

EBox.HintText = "Edit the code for your slash command here. Your function will be called as: function(msg)     Using \"--\" anywhere on a line will cause the rest of the line to be a comment even if in quotes.\nSaved variables are accessible through 'saved.whatever' and static variables through 'static.whatever' and are per command.     You may not access any upvalues, just globals, saved, and static variables"
EBox:SetScript("OnEnter", HintSet )
EBox:SetScript("OnLeave", HintClear )

IndentationLib.Enable(EBox, 5, ColorTable)

me.HintFrame = CreateFrame("Frame" , "SMHintFrame", me )
me.HintFrame:SetBackdrop( Backdrop2 )
me.HintFrame:SetBackdropColor( 128, 128,128, 1)
me.HintFrame:SetBackdropBorderColor( 255, 255, 255, 1)
me.HintFrame:SetPoint( "TOPLEFT", me.ButtonFrame, "BOTTOMLEFT", 0, -10 )
me.HintFrame:SetPoint( "BOTTOM", me.Close, "TOP", 0, 10 )
me.HintFrame:SetPoint( "RIGHT", me, "RIGHT", -10, 0) 

me.HintFrameText = me:CreateFontString( nil , "OVERLAY", "ChatFontNormal")
me.HintFrameText:SetAllPoints( me.HintFrame )
me.HintFrameText:SetJustifyH( "CENTER" )
me.HintFrameText:SetJustifyV( "MIDDLE" )
me.HintFrameText:SetText(" ")

me.pos = me:CreateFontString( nil , "OVERLAY", "ChatFontNormal")
me.pos:SetPoint("TOPRIGHT", me.HintFrame, "TOPRIGHT", -5, -5 )
me.pos:SetJustifyH( "RIGHT" )
me.pos:SetJustifyV( "TOP" )
me.pos:SetText(" ")

-- Code EBox Overlay
me.EBoxOverlay=CreateFrame("Frame", "SMOverlayFrame" ,me)
me.EBoxOverlay:SetBackdrop(Backdrop3)

me.EBoxOverlay.HintText = "Edit the code for your slash command here. Your function will be called as: function(msg)     Using \"--\" anywhere on a line will cause the rest of the line to be a comment even if in quotes.\nSaved variables are accessible through 'saved.whatever' and static variables through 'static.whatever' and are per command.     You may not access any upvalues, just globals, saved, and static variables"
me.EBoxOverlay:SetScript("OnEnter", HintSet )
me.EBoxOverlay:SetScript("OnLeave", HintClear )
me.EBoxOverlay:SetPoint("TOP", me.CodeFrame, "TOP", 0, -6)
me.EBoxOverlay:SetPoint("LEFT", me.LineNumbers, "RIGHT", 0, 0)
me.EBoxOverlay:SetPoint("RIGHT", me.DescFrameEBox, "RIGHT", 0, 0)
me.EBoxOverlay:SetPoint("BOTTOM", me.CodeFrame, "BOTTOM", 0, 6)

local eframe = 0
local e = 0
me2:SetScript("OnUpdate", function(self, elapsed)
	eframe = eframe + 1
	e = e + elapsed
	if eframe < 2 then return end
	eframe = 0
	
	local cursorPos = me.CodeFrameEBox:GetCursorPosition()
	if oldpos ~= cursorPos or e > .5 then
		e = 0
		pos = cursorPos
		local linewidth = me.CodeFrameEBox:GetWidth()
		local CRs
		local code = { string.split("\r\n", me.CodeFrameEBox:GetText()) }
		local ccode = { string.split("\r\n", me.CodeFrameEBox:GetText( true )) }
		local linestring = ""
		local line = false
		local currentLinePixels = 0
		
		-- Line Numbers section
		for x = 1, #code do
			code[x] = ichars( code[x], true)
			
			StrLen:SetText( code[x]:len() > 0 and code[x] or "X")
			
			CRs = math.floor(StrLen:GetStringHeight() / 12)
			linestring = linestring..x..":"..string.rep("\r", CRs)
			
			if not(line) and pos - ccode[x]:len() <= 0 then
				line = x
			elseif not( line ) then
				currentLinePixels = currentLinePixels + (CRs * 12)
				pos = -1 + pos - (ccode[x] and ccode[x]:len() or 0)
			end
		end

		linestring = linestring:gsub( ("%d:"):format(line), ("|cFF00FF00%d:|r"):format(line), 1)
		me.LineNumbers:SetText(linestring.."\n\n\nEOF\r")
		oldpos = cursorPos
		
		-- line / col section
		if pos == 0 then
			me.pos:SetText( ("line: %d  char: %d"):format(line, 0))
		else
			local tempString = ccode[line] and ccode[line]:sub(1,pos) or ""
			tempString = ichars( tempString )
			me.pos:SetText( ("line: %d  char: %d"):format(line, tempString:len()))
		end
		
		-- scroll frame adjust section
		if oldLinePixels ~= currentLinePixels and not( IsMouseButtonDown("LeftButton") ) then
			local displayPixels = me.EBoxOverlay:GetHeight() --
			local displayTop = me.ScrollFrame:GetVerticalScroll()
			local displayBottom = displayTop + displayPixels

			if currentLinePixels > displayTop + EDGE and currentLinePixels < displayBottom - EDGE then
				-- within viewing window so do nothing
			elseif currentLinePixels < displayTop + EDGE and displayTop > 1 and currentLinePixels < oldLinePixels then
				me.ScrollFrame:SetVerticalScroll( currentLinePixels - EDGE )
			elseif currentLinePixels > displayBottom - EDGE then
				me.ScrollFrame:SetVerticalScroll( currentLinePixels - displayPixels + EDGE)
			end
			oldLinePixels = currentLinePixels
		end
	end
	
end)

-- ****************************************************************************
-- * New Command Entry Frame                                                  *
-- ****************************************************************************
me.NewCmdFrame = CreateFrame("Frame", "SMNewCmdFrame", me )
local NewCmdFrame = me.NewCmdFrame
NewCmdFrame:SetFrameStrata("TOOLTIP")
NewCmdFrame:SetBackdrop( Backdrop )
NewCmdFrame:SetBackdropColor( 128, 128,128, 1)
NewCmdFrame:SetBackdropBorderColor( 255, 255, 255, 1)
NewCmdFrame:SetHeight( 240 )
NewCmdFrame:SetWidth( 480 )
NewCmdFrame:SetPoint( "CENTER", UIParent, "CENTER" )
NewCmdFrame:SetMovable(true)
NewCmdFrame:SetClampedToScreen(true)
NewCmdFrame:EnableMouse(true)
NewCmdFrame:Hide()

NewCmdFrame:SetScript("OnShow", function(self)
	me.FrameText:SetText("Enter the name of your new command.")
end)

-- Title region
local TitleRegion = NewCmdFrame:CreateTitleRegion()
TitleRegion:SetSize( 324, 64)
TitleRegion:SetPoint( "TOP", NewCmdFrame, "TOP", 0,12)

-- Title frame header
local TitleBkgnd= NewCmdFrame:CreateTexture(nil , "ARTWORK")
TitleBkgnd:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
TitleBkgnd:SetSize( 324, 64)
TitleBkgnd:SetPoint( "TOP", NewCmdFrame, "TOP", 0,12)

-- Title frame text
local Title = NewCmdFrame:CreateFontString( nil , "OVERLAY", "GameFontHighlight")
Title:SetText("Slash Magic")
Title:SetPoint( "CENTER", TitleBkgnd, "CENTER", 0, 12 )
Title:SetJustifyH( "CENTER" )
Title:SetJustifyV( "MIDDLE" )

-- Message Box text
me.FrameText= NewCmdFrame:CreateFontString( nil , "OVERLAY", "ChatFontNormal")
local FrameText = me.FrameText
FrameText:SetPoint( "TOPLEFT", NewCmdFrame, "TopLeft", 20, -20 )
FrameText:SetPoint( "BOTTOMRIGHT", NewCmdFrame, "BOTTOMRIGHT", -20, 100 )

me.EBox = CreateFrame( "EditBox", "SMNewCmdEditbox", NewCmdFrame, "InputBoxTemplate" )
local EBox = me.EBox
EBox:SetFontObject("ChatFontNormal")
EBox:SetTextInsets(0, 0, 3, 3)
EBox:SetPoint("TOPLEFT", FrameText , "BOTTOMLEFT", 0 ,-15 )
EBox:SetPoint("RIGHT", FrameText, "RIGHT" )
EBox:SetHeight(19)
EBox:SetAutoFocus(true)
EBox:SetMaxLetters( 254 )
EBox:SetScript("OnEnterPressed" , function(self)
	self:ClearFocus()
	me.CreateButton:Click("LeftButton")
end)
EBox:SetScript("OnEditFocusGained", function(self)
	self:HighlightText()
end)
EBox:SetScript("OnEscapePressed", function(self)
	self:SetCursorPosition( 0 )
	self:ClearFocus()
end)

-- Create Button
me.CreateButton = CreateFrame( "Button", "SMNewCmdFrameCreateButton", NewCmdFrame, "UIPanelButtonTemplate" )
local CreateButton = me.CreateButton
CreateButton:SetPoint("CENTER", NewCmdFrame, "BOTTOM", -85, 25)
CreateButton:SetSize( 150, 25)
CreateButton:SetText("CREATE")
CreateButton:SetScript("OnClick", function(self, button, down)
	if button ~= "LeftButton" then
		return
	end
	PlaySound( "GAMEGENERICBUTTONPRESS" )
	local NewCmd = string.lower(EBox:GetText())
	if type(SlashMagic_Commands.cmds[NewCmd]) == "boolean" then
		FrameText:SetText( ("The command |cFFFF0000[ %s ]|r already exists as part of this addon. Please edit that command or choose a different name."):format(NewCmd) )
		me.EBox:SetFocus()
		return
	elseif SlashCmdList[ string.upper(NewCmd)] ~= nil then
		FrameText:SetText( ("The command |cFFFF0000[ %s ]|r already exists as part of some other addon. Please choose a different name."):format(NewCmd) )
		me.EBox:SetFocus()
		return
	end
	SlashMagic_Commands.cmds[NewCmd] = false
	SlashMagic_Commands.code[NewCmd] = { "-- Put some code here and make your own command","return" ,}
	SlashMagic_Commands.desc[NewCmd] = "Enter a description here"
	Selected = NewCmd
	CmdListDisplayUpdate()
	EBox:SetText("")
	NewCmdFrame:Hide()
end)

local CancelButton = CreateFrame( "Button", "SMNewCmdFrameCancelButton", NewCmdFrame, "UIPanelButtonTemplate" )
CancelButton:SetPoint("CENTER", NewCmdFrame, "BOTTOM", 85, 25)
CancelButton:SetSize( 150, 25)
CancelButton:SetText("CANCEL")
CancelButton:SetScript("OnClick", function(self, button, down)
	if button ~= "LeftButton" then
		return
	end
	PlaySound( "GAMEGENERICBUTTONPRESS" )
	NewCmdFrame:Hide()
end)
