--- 获取物品等级标签
---@param button Button
local function GetLevelLabel(button)
    local levelLabel = button.levelLabel
    if levelLabel == nil then
        levelLabel = button:CreateFontString(nil, "OVERLAY", "Game12Font_o1")
        levelLabel:SetPoint("TOPLEFT", -3, 1)
        levelLabel:SetTextColor(GetTableColor(YELLOW_FONT_COLOR))
        button.levelLabel = levelLabel
    end
    return levelLabel
end

--- 获取物品是否绑定的标签
---@param button Button
local function GetBindLabel(button)
    ---@type FontString
    local bindLabel = button.bindLabel
    if bindLabel == nil then
        bindLabel = button:CreateFontString(nil, "OVERLAY", "Game12Font_o1")
        bindLabel:SetPoint("BOTTOMLEFT", -3, -1)
        bindLabel:SetTextColor(GetTableColor(RED_FONT_COLOR))
        button.bindLabel = bindLabel
    end
    return bindLabel
end

--- 获取物品右上方标签
---@param button Button
local function GetTopRightLabel(button)
    ---@type FontString
    local typeTopLabel = button.typeTopLabel
    if typeTopLabel == nil then
        typeTopLabel = button:CreateFontString(nil, "OVERLAY", "Game12Font_o1")
        typeTopLabel:SetPoint("TOPRIGHT", 3, 1)
        button.typeTopLabel = typeTopLabel
    end
    return typeTopLabel
end

--- 获取物品右下方型标签
---@param button Button
local function GetBottomRightLabel(button)
    ---@type FontString
    local typeBottomLabel = button.typeBottomLabel
    if typeBottomLabel == nil then
        typeBottomLabel = button:CreateFontString(nil, "OVERLAY", "Game12Font_o1")
        typeBottomLabel:SetPoint("BOTTOMRIGHT", 3, -1)
        button.typeBottomLabel = typeBottomLabel
    end
    return typeBottomLabel
end

local slotNames = {
    INVTYPE_HEAD = "頭",
    INVTYPE_NECK = "頸",
    INVTYPE_SHOULDER = "肩",
    INVTYPE_BODY = "衫",
    INVTYPE_CHEST = "胸",
    INVTYPE_ROBE = "胸",
    INVTYPE_WAIST = "腰",
    INVTYPE_LEGS = "腿",
    INVTYPE_FEET = "腳",
    INVTYPE_WRIST = "腕",
    INVTYPE_HAND = "手",
    INVTYPE_FINGER = "指",
    INVTYPE_TRINKET = "飾",
    INVTYPE_CLOAK = "背",
    INVTYPE_WEAPON = "單",
    INVTYPE_SHIELD = "副",
    INVTYPE_2HWEAPON = "雙",
    INVTYPE_WEAPONMAINHAND = "主",
    INVTYPE_WEAPONOFFHAND = "副",
    INVTYPE_HOLDABLE = "副",
    INVTYPE_RANGED = "遠",
    INVTYPE_RANGEDRIGHT = "遠",
    INVTYPE_TABARD = "袍",
}
local subtypes = {
    [LE_ITEM_CLASS_WEAPON] = {
        [LE_ITEM_WEAPON_AXE1H] = "斧",
        [LE_ITEM_WEAPON_AXE2H] = "斧",
        [LE_ITEM_WEAPON_BOWS] = "弓",
        [LE_ITEM_WEAPON_GUNS] = "槍",
        [LE_ITEM_WEAPON_MACE1H] = "錘",
        [LE_ITEM_WEAPON_MACE2H] = "錘",
        [LE_ITEM_WEAPON_POLEARM] = "柄",
        [LE_ITEM_WEAPON_SWORD1H] = "劍",
        [LE_ITEM_WEAPON_SWORD2H] = "劍",
        [LE_ITEM_WEAPON_WARGLAIVE] = "刃",
        [LE_ITEM_WEAPON_STAFF] = "法",
        [LE_ITEM_WEAPON_UNARMED] = "拳",
        [LE_ITEM_WEAPON_DAGGER] = "匕",
        [LE_ITEM_WEAPON_CROSSBOW] = "弩",
        [LE_ITEM_WEAPON_WAND] = "魔",
        [LE_ITEM_WEAPON_FISHINGPOLE] = "漁",
    },
    [LE_ITEM_CLASS_ARMOR] = {
        [LE_ITEM_ARMOR_CLOTH] = "布",
        [LE_ITEM_ARMOR_LEATHER] = "皮",
        [LE_ITEM_ARMOR_MAIL] = "鎖",
        [LE_ITEM_ARMOR_PLATE] = "鎧",
        [LE_ITEM_ARMOR_SHIELD] = "盾",
    },
}

--- 获取 16 进制的颜色字符串
local function GetColorStr(equipLoc, r, g, b)
    -- 双手武器显示为白色
    if equipLoc == "INVTYPE_2HWEAPON" then
        return "ffffffff"
    end
    return format("ff%.2x%.2x%.2x", r * 255, g * 255, b * 255)
end

---@type GameTooltip
local tooltip = CreateFrame("GameTooltip", "WLK_EquipmentInfoTooltip", UIParent, "GameTooltipTemplate")

--- 获取物品信息
local function GetItemInformation(link, onlyForLevel, arg, slot)
    local level, isBound, slotName, subtype
    local quality, _, _, _, _, _, equipLoc, _, _, classID, subclassID, bindType = select(3, GetItemInfo(link))
    -- 非传家宝武器和护甲直接使用 GetDetailedItemLevelInfo 方法获取物品等级
    if (classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR) and quality ~= LE_ITEM_QUALITY_HEIRLOOM then
        level = GetDetailedItemLevelInfo(link)
        if onlyForLevel then
            return level
        end
    end
    -- 其他物品等级和绑定信息通过扫描鼠标提示信息获取
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    if type(arg) == "number" and slot then
        -- 背包中的物品
        tooltip:SetBagItem(arg, slot)
    elseif type(arg) == "string" and slot then
        -- 银行中的物品
        tooltip:SetInventoryItem(arg, slot)
    elseif slot then
        -- 商人界面买回按钮上的物品
        tooltip:SetBuybackItem(slot)
    else
        -- 其他物品
        tooltip:SetHyperlink(link)
    end
    for i = 2, 7 do
        while true do
            ---@type FontString
            local textLeftLabel = _G[tooltip:GetName() .. "TextLeft" .. i]
            if textLeftLabel then
                local leftText = textLeftLabel:GetText()
                if leftText then
                    -- 获取物品等级
                    if not level then
                        level = strmatch(leftText, gsub(ITEM_LEVEL, "%%d", "(%%d+)"))
                        if level and onlyForLevel then
                            return level
                        end
                        break
                    end
                    -- 获取物品绑定信息
                    if not isBound and bindType == 2 and strfind(leftText, ITEM_SOULBOUND) then
                        -- 物品是装备后绑定，且已经绑定
                        isBound = true
                        break
                    end
                    -- 获取物品的装备槽位和类型
                    if equipLoc ~= "" then
                        if leftText == _G[equipLoc] then
                            local colorStr = GetColorStr(equipLoc, textLeftLabel:GetTextColor())
                            slotName = WrapTextInColorCode(slotNames[equipLoc], colorStr)
                            ---@type FontString
                            local textRightLabel = _G[tooltip:GetName() .. "TextRight" .. i]
                            if textRightLabel and textRightLabel:GetText() then
                                colorStr = GetColorStr(equipLoc, textRightLabel:GetTextColor())
                                subtype = WrapTextInColorCode(subtypes[classID][subclassID], colorStr)
                            end
                        end
                        break
                    end
                end
            end
            break
        end
    end
    -- 背包、银行、买回按钮未绑定的装绑物品显示 “装”
    local bind = (slot and bindType == 2 and not isBound) and "裝" or ""
    local topRightLabel, bottomRightLabel
    -- 物品类型是盾牌或武器时，右上方显示装备槽位，右下方显示物品类型
    if classID == LE_ITEM_CLASS_ARMOR and subclassID == LE_ITEM_ARMOR_SHIELD or classID == LE_ITEM_CLASS_WEAPON then
        topRightLabel = slotName
        bottomRightLabel = subtype
    else
        topRightLabel = subtype
        bottomRightLabel = slotName
    end
    return level or "", bind, topRightLabel or "", bottomRightLabel or ""
end

--- 物品按钮上显示物品信息
---@param button ItemButton
local function ShowItemInfo(button, link, arg, slot)
    local level, bind, topRight, bottomRight = "", "", "", ""
    if link then
        if button.origLink == link then
            level = button.origLevel
            bind = button.origBind
            topRight = button.origTopRight
            bottomRight = button.origBottomRight
        else
            button.origLink = link
            level, bind, topRight, bottomRight = GetItemInformation(link, false, arg, slot)
            button.origLevel = level
            button.origBind = bind
            button.origTopRight = topRight
            button.origBottomRight = bottomRight
        end
    end

    local levelLabel = GetLevelLabel(button)
    local bindLabel = GetBindLabel(button)
    local topRightLabel = GetTopRightLabel(button)
    local bottomRightLabel = GetBottomRightLabel(button)
    levelLabel:SetText(level)
    bindLabel:SetText(bind)
    topRightLabel:SetText(topRight)
    bottomRightLabel:SetText(bottomRight)
end

--- 背包物品按钮显示物品信息
---@param self Frame
hooksecurefunc("ContainerFrame_Update", function(self)
    local bagID = self:GetID()
    for i = 1, self.size do
        ---@type ItemButton
        local button = _G[self:GetName() .. "Item" .. i]
        local slot = button:GetID()
        local link = GetContainerItemLink(bagID, slot)
        ShowItemInfo(button, link, bagID, slot)
    end
end)

--- 银行物品按钮显示物品信息
---@param button ItemButton
hooksecurefunc("BankFrameItemButton_Update", function(button)
    if button.isBag then
        return
    end
    ---@type Frame
    local bankSlotsFrame = button:GetParent()
    local bagID = bankSlotsFrame:GetID()
    local slot = button:GetID()
    local link = GetContainerItemLink(bagID, slot)
    ShowItemInfo(button, link, "player", ButtonInventorySlot(button))
end)

--- 公会银行物品按钮显示物品信息
hooksecurefunc("GuildBankFrame_Update", function()
    if GuildBankFrame.mode == "bank" then
        local tab = GetCurrentGuildBankTab()
        for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
            local index = i % NUM_SLOTS_PER_GUILDBANK_GROUP
            if index == 0 then
                index = NUM_SLOTS_PER_GUILDBANK_GROUP
            end
            local column = ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
            local button = _G["GuildBankColumn" .. column .. "Button" .. index]
            local link = GetGuildBankItemLink(tab, i)
            ShowItemInfo(button, link)
        end
    end
end)

--- 商人界面物品按钮显示物品信息
hooksecurefunc("MerchantFrameItem_UpdateQuality", function(self, link)
    ---@type ItemButton
    local button = self.ItemButton
    local slot
    if button == MerchantBuyBackItemItemButton then
        slot = GetNumBuybackItems()
        ShowItemInfo(button, link, nil, slot)
    elseif MerchantFrame.selectedTab == 1 then
        -- 购买界面
        ShowItemInfo(button, link)
    else
        -- 买回界面
        slot = button:GetID()
        ShowItemInfo(button, link, nil, slot)
    end
end)

--- 交易界面玩家物品按钮显示物品信息
hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
    local button = _G["TradePlayerItem" .. id .. "ItemButton"]
    local link = GetTradePlayerItemLink(id)
    ShowItemInfo(button, link)
end)

--- 交易界面目标物品按钮显示物品信息
hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
    local button = _G["TradePlayerItem" .. id .. "ItemButton"]
    local link = GetTradeTargetItemLink(id)
    ShowItemInfo(button, link)
end)

--- 装备弹出按钮显示物品信息
hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
    local location = button.location
    if not location then
        return
    end
    local link, arg
    local _, _, bags, _, slot, bagID = EquipmentManager_UnpackLocation(location)
    if bags then
        link = GetContainerItemLink(bagID, slot)
        arg = bagID
    else
        link = GetInventoryItemLink("player", slot)
        arg = "player"
    end
    ShowItemInfo(button, link, arg, slot)
end)

--- 拍卖行浏览界面物品按钮显示物品信息
hooksecurefunc("AuctionFrameBrowse_Update", function()
    local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
    for i = 1, NUM_BROWSE_TO_DISPLAY do
        local button = _G["BrowseButton" .. i .. "Item"]
        local link = GetAuctionItemLink("list", offset + i)
        if button then
            ShowItemInfo(button, link)
        end
    end
end)

--- 拍卖行竞拍界面物品按钮显示物品信息
hooksecurefunc("AuctionFrameBid_Update", function()
    local offset = FauxScrollFrame_GetOffset(BidScrollFrame)
    for i = 1, NUM_BIDS_TO_DISPLAY do
        local button = _G["BidButton" .. i .. "Item"]
        local link = GetAuctionItemLink("bidder", offset + i)
        if button then
            ShowItemInfo(button, link)
        end
    end
end)

--- 拍卖行拍卖界面物品按钮显示物品信息
hooksecurefunc("AuctionFrameAuctions_Update", function()
    local offset = FauxScrollFrame_GetOffset(AuctionsScrollFrame)
    -- 获取拍卖的时光徽章的数量
    local tokenCount = C_WowTokenPublic.GetNumListedAuctionableTokens()
    for i = 1, NUM_AUCTIONS_TO_DISPLAY do
        local button = _G["AuctionsButton" .. i .. "Item"]
        local link = GetAuctionItemLink("owner", offset - tokenCount + i)
        if button then
            ShowItemInfo(button, link)
        end
    end
end)

--- 人物界面显示装备等级
local function ShowPaperDollItemLevel(button, unit)
    local slot = button:GetID()
    local link = GetInventoryItemLink(unit, slot)
    local levelLabel = GetLevelLabel(button)
    levelLabel:SetText(link and GetItemInformation(link, true, unit, slot) or "")
end

hooksecurefunc("PaperDollItemSlotButton_OnShow", function(self)
    ShowPaperDollItemLevel(self, "player")
end)

---@param self ItemButton
hooksecurefunc("PaperDollItemSlotButton_OnEvent", function(self, event, ...)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        local equipmentSlot = ...
        if self:GetID() == equipmentSlot then
            ShowPaperDollItemLevel(self, "player")
        end
    end
end)

---@type Frame
local eventListener = CreateFrame("Frame")

eventListener:RegisterEvent("INSPECT_READY")

eventListener:SetScript("OnEvent", function(...)
    -- 观察人物界面显示装备等级
    local _, _, guid = ...
    if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
        ShowPaperDollItemLevel(InspectHeadSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectNeckSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectShoulderSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectBackSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectChestSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectShirtSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectTabardSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectWristSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectHandsSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectWaistSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectLegsSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectFeetSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectFinger0Slot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectFinger1Slot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectTrinket0Slot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectTrinket1Slot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectMainHandSlot, InspectFrame.unit)
        ShowPaperDollItemLevel(InspectSecondaryHandSlot, InspectFrame.unit)
    end
end)

local GuildNewsItemLevels = {}

--- 公会新闻的物品添加等级信息
hooksecurefunc("GuildNewsButton_SetText", function(button, _, text, text1, text2, ...)
    if type(text2) == "string" then
        local link = strmatch(text2, "|H(item:%d+:.-)h|.-|h")
        if link then
            local level = GuildNewsItemLevels[link] or GetDetailedItemLevelInfo(link)
            if level then
                GuildNewsItemLevels[link] = level
                text2 = gsub(text2, "(%|Hitem:%d+:.-%|h%[)(.-)(%]%|h)", "%1" .. level .. ":%2%3")
                ---@type FontString
                local buttonText = button.text
                buttonText:SetFormattedText(text, text1, text2, ...)
            end
        end
    end
end)

--- 通过纹理的 fileID 获得纹理文件路径
local function GetTextureFilePathByID(fileID)
    ---@type Frame
    local frame = CreateFrame("Frame")
    ---@type Texture
    local texture = frame:CreateTexture()
    texture:SetTexture(fileID)
    return texture:GetTexture()
end

--- 获取宝石图标
local function GetGemIcons(link)
    local gems = ""
    -- 获取宝石插槽数量
    local stats = GetItemStats(link)
    local count = 0
    for key, value in pairs(stats) do
        if strfind(key, "EMPTY_SOCKET_") then
            count = value
            break
        end
    end

    for i = 1, count do
        local _, gemLink = GetItemGem(link, i)
        if gemLink then
            gems = gems .. "|T" .. GetTextureFilePathByID(select(10, GetItemInfo(gemLink))) .. ":0|t"
        else
            -- 未插入宝石时使用棱彩插槽图标
            gems = gems .. "|TInterface/ItemSocketingFrame/UI-EmptySocket-Prismatic:0|t"
        end
    end
    if count > 0 then
        gems = gems .. " "
    end
    return gems
end

local chatFrameItems = {}

--- 将物品等级、装备槽位和宝石图标添加到物品链接
local function AddInfoToLink(link)
    if chatFrameItems[link] then
        return chatFrameItems[link]
    end

    local level = GetItemInformation(link, true)
    if level ~= "" then
        local name, _, _, _, _, _, _, _, equipLoc = GetItemInfo(link)
        local equipSlotName = equipLoc == "" and "" or ("(" .. _G[equipLoc] .. ")")
        local gems = GetGemIcons(link)
        link = gsub(link, "|h%[(.-)%]|h", "|h[" .. level .. equipSlotName .. ":" .. name .. "]|h" .. gems)
        chatFrameItems[link] = link
    end
    return link
end

--- 聊天信息事件过滤器
local function MessageEventFilter(_, _, text, ...)
    -- 把链接换成添加了物品信息的链接
    text = gsub(text, "(|Hitem:%d+:.-|h.-|h)", AddInfoToLink)
    return false, text, ...
end

local chatInfoEvents = {
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_BATTLEGROUND",
    "CHAT_MSG_LOOT",
}

for i = 1, #chatInfoEvents do
    ChatFrame_AddMessageEventFilter(chatInfoEvents[i], MessageEventFilter)
end