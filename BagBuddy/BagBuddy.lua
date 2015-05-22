function BagBuddy_OnLoad(self)
  SetPortraitToTexture(self.portrait, "Interface\\Icons\\INV_Misc_EngGizmos_30")
  -- Create the item slots
  self.items = {}
  for idx = 1, 24 do
    local item = CreateFrame(“Button“, “BagBuddy_Item“ .. idx, self, “BagBuddyItemTemplate“)
    self.items[idx] = item
    if idx == 1 then
      item:SetPoint(“TOPLEFT“, 40, -73)
    elseif idx == 7 or idx == 13 or idx == 19 then
      item:SetPoint(“TOPLEFT“, self.items[idx-6], “BOTTOMLEFT“, 0, -7)
    else
      item:SetPoint(“TOPLEFT“, self.items[idx-1], “TOPRIGHT“, 12, 0)
    end
  end

for idx, button in ipairs(self.items) do
  button:SetScript("OnEnter", BagBuddy_Button_OnEnter)
  button:SetScript("OnLeave", BagBuddy_Button_OnLeave)
end

end

local function itemNameSort(a,b)
  return a.name < b.name
end

function BagBuddy_Update()
  local items = {}
  -- Scan through the bag slots, looking for items
  for bag = 0, NUM_BAG_SLOTS do
    for slot = 0, GetContainerNumSlots(bag) do
      local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
      if texture then
        -- If found, grab the item number and store other data
        local itemNum = tonumber(link:match(“|Hitem:(%d+):“))
        if not items[itemNum] then
          items[itemNum] = {
            texture = texture,
            count = count,
            quality = quality,
            name = GetItemInfo(link),
            link = link,
           }
         else
           -- The item already exists in our table, just update the count
           items[itemNum].count = items[itemNum].count + count
         end
       end
     end
   end
  
  local sortTbl = {}
  for link, entry in pairs(items) do
    table.insert(sortTbl, entry)
  end
  table.sort(sortTbl, itemNameSort)


  -- Now update the BagBuddyFrame with the listed items (in order)
  for i = 1, 24 do
    local button = BagBuddy.items[i]
    local entry = sortTbl[i]
    
    if entry then
      -- There is an item in this slot
    
      button.link = entry.link
      button.icon:SetTexture(entry.texture)
      if entry.count > 1 then
        button.count:SetText(entry.count)
        button.count:Show()
      else
        button.count:Hide()
      end

      if entry.quality > 1 then
        button.glow:SetVertexColor(GetItemQualityColor(entry.quality))
        button.glow:Show()
      else
        button.glow:Hide()
      end

      button:Show()
    else
      button.link = nil
      button:Hide()
    end

  end

end

function BagBuddy_Button_OnEnter(self, motion)
  if self.link then
    GameToolTip:SetOwner(self, "ANCHOR_TOPRIGHT")
    GameToolTip:SetHyperlink(self.link)
    GameToolTip:Show()
  end
end

function BagBuddy_Button_OnLeave(self, motion)
  GameToolTip:Hide()
end
