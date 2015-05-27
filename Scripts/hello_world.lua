-- Hello World Addon using Lua
local frame = CreateFrame("FRAME", "FooAddonFrame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
local function eventHandler(self, event, ...)
  print("Hello World! Hello " .. event)
end
frame:SetScript("OnEvent", eventHandler)

-- COMBAT_LOG_EVENT example
function eventHandler(self,event, ...)
  if even == "COMBAT_LOG_EVENT" then
    local timestamp, combatEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...
    -- Those arguments appear for all combat event variants.
    local eventPrefix, eventSuffix = combatEvent:match("^(.-)_?([^_]*)$")
    if eventSuffix == "DAMAGE" then
      -- Something dealt damage.  The 9 arguments in ... describe how it was dealt.
      -- To extract those, we can use the select function:
      local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(select("#", ...)-8, ...)
      -- select("#", ...) returns number of arguments in the vararg expression
      -- Do something with the damage details...
      if eventPrefix == "RANGE" or eventPrefix:match("^SPELL") then
        -- The first three arguments after destFlags in ... describe the spell or ability dealing damage
        -- Extract this data using select as well:
        local spellID, spellName, spellSchool = select(9, ...) -- Everything from 9th argument onward
	-- Do something with the spell details...
      end
    end
  end
end

