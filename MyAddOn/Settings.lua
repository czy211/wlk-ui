local defaultMiniMapTrack = {
    ["飛行管理員"] = true,
    ["專注目標"] = true,
    ["任務目標區域追蹤"] = true,
    ["追蹤挖掘場"] = true,
}
local hiddenCVars = {
    scriptErrors = 1,
    taintLog = 1,
    rawMouseEnable = 1,
    ffxDeath = 0,
    nameplateMaxDistance = 40,
    alwaysCompareItems = 1,
    cameraDistanceMaxZoomFactor = 2.6,
    floatingCombatTextFloatMode = 3,
    floatingCombatTextCombatHealing = 0,
    floatingCombatTextReactives = 0,
    floatingCombatTextCombatState = 1,
}
local voiceCVars = {
    Sound_SFXVolume = 0.7,
    Sound_MusicVolume = 0.5,
    Sound_AmbienceVolume = 1,
    Sound_DialogVolume = 1,
}
local interfaceCVars = {
    autoLootDefault = 1,
    enableFloatingCombatText = 1,
    statusTextDisplay = "BOTH",
    statusText = 1,
    showTutorials = 0,
    lockActionBars = 0,
    alwaysShowActionBars = 1,
    UnitNameFriendlySpecialNPCName = 1,
    UnitNameHostleNPC = 1,
    UnitNameInteractiveNPC = 1,
    nameplateShowSelf = 0,
    nameplateShowAll = 1,
    nameplateMotion = 1,
    cameraWaterCollision = 1,
    cameraSmoothStyle = 0,
    movieSubtitle = 1,
    useCompactPartyFrames = 1,
}

local default = CreateFrame("Button", "DefaultSettingsButton", UIParent, "UIPanelButtonTemplate")
default:SetSize(60, 22)
default:SetPoint("Right", 0, 225)
default:SetText("BLZ")
default:SetAlpha(0)

local my = CreateFrame("Button", "MySettingsButton", UIParent, "UIPanelButtonTemplate")
my:SetSize(60, 22)
my:SetPoint("Right", 0, 255)
my:SetText("MY")
my:SetAlpha(0)

StaticPopupDialogs["RELOAD_UI"] = {
    text = "重載介面以使設置生效",
    button1 = "重載介面",
    OnAccept = function()
        ReloadUI()
    end,
    OnCancel = function()
        ReloadUI()
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
}

local function OnEnter()
    default:SetAlpha(1)
    my:SetAlpha(1)
end

local function OnLeave()
    default:SetAlpha(0)
    my:SetAlpha(0)
end

default:SetScript("OnEnter", OnEnter)
default:SetScript("OnLeave", OnLeave)
my:SetScript("OnEnter", OnEnter)
my:SetScript("OnLeave", OnLeave)

local function SetCVars(cvars, toDefault)
    for cvar, value in pairs(cvars) do
        SetCVar(cvar, toDefault and GetCVarDefault(cvar) or value)
    end
end

local function ApplyDefaultSettings()
    SetCVars(hiddenCVars, true)
    SetCVars(voiceCVars, true)

    InterfaceOptionsFrame_SetAllToDefaults()

    if LoadAddOn("Blizzard_BindingUI") then
        KeyBindingFrame_ResetBindingsToDefault()
        C_VoiceChat.SetPushToTalkBinding({ "`" })
        SaveBindings(ACCOUNT_BINDINGS)
    end

    FCF_ResetChatWindows()
    if ChatConfigFrame:IsShown() then
        ChatConfig_UpdateChatSettings()
    end

    for i = 1, GetNumTrackingTypes() do
        local name = GetTrackingInfo(i)
        SetTracking(i, defaultMiniMapTrack[name])
    end
end

default:SetScript("OnClick", function()
    ApplyDefaultSettings()
    StaticPopup_Show("RELOAD_UI")
end)

local function SetMyInterfaceOptions()
    SetCVars(interfaceCVars)
    SetModifiedClick("AUTOLOOTTOGGLE", "None")
    SetModifiedClick("FOCUSCAST", "Shift")
    SetModifiedClick("SELFCAST", "None")
    SetAutoDeclineGuildInvites(true)
end

local function UnbindButton(action, buttonID)
    local key1, key2 = GetBindingKey(action, 1)
    if key1 then
        SetBinding(key1, nil, 1)
    end
    if key2 then
        SetBinding(key2, nil, 1)
    end
    if key1 and buttonID == 1 then
        KeyBindingFrame_SetBinding(key1, nil, 1, key1)
        if key2 then
            KeyBindingFrame_SetBinding(key2, action, 1, key2)
        end
    else
        if key1 then
            KeyBindingFrame_SetBinding(key1, action, 1)
        end
        if key2 then
            KeyBindingFrame_SetBinding(key2, nil, 1, key2)
        end
    end
end

local function BindButton(key, action, buttonID)
    KeyBindingFrame_AttemptKeybind(KeyBindingFrame, key, action, 1, buttonID or 1, true)
end

local function SetMyBindings()
    UnbindButton("MOVEFORWARD", 2)
    UnbindButton("MOVEBACKWARD", 2)
    UnbindButton("TURNLEFT", 2)
    UnbindButton("TURNRIGHT", 2)
    UnbindButton("JUMP", 2)
    UnbindButton("TOGGLEAUTORUN", 2)
    UnbindButton("PREVIOUSACTIONPAGE", 2)
    UnbindButton("NEXTACTIONPAGE", 2)
    UnbindButton("TOGGLEBACKPACK", 2)

    UnbindButton("MOVEANDSTEER", 1)
    UnbindButton("TURNRIGHT", 1)
    UnbindButton("TURNRIGHT", 1)
    BindButton("E", "MOVEFORWARD")
    BindButton("D", "MOVEBACKWARD")
    BindButton("S", "STRAFELEFT")
    BindButton("F", "STRAFERIGHT")
    BindButton(".", "SITORSTAND")
    BindButton(",", "TOGGLESHEATH")
    BindButton(";", "TOGGLEAUTORUN")
    BindButton("'", "FOLLOWTARGET")

    UnbindButton("REPLY2", 1)
    C_VoiceChat.SetPushToTalkBinding({ "BUTTON3" })

    BindButton("Q", "ACTIONBUTTON1")
    BindButton("W", "ACTIONBUTTON2")
    BindButton("R", "ACTIONBUTTON3")
    BindButton("T", "ACTIONBUTTON4")
    BindButton("A", "ACTIONBUTTON5")
    BindButton("G", "ACTIONBUTTON6")
    BindButton("4", "ACTIONBUTTON7")
    BindButton("3", "ACTIONBUTTON8")
    BindButton("2", "ACTIONBUTTON9")
    BindButton("1", "ACTIONBUTTON10")
    BindButton("Z", "ACTIONBUTTON11")
    BindButton("X", "ACTIONBUTTON12")
    BindButton("`", "EXTRAACTIONBUTTON1")
    BindButton("CTRL-8", "BONUSACTIONBUTTON1")
    BindButton("CTRL-9", "BONUSACTIONBUTTON2")
    BindButton("CTRL-0", "BONUSACTIONBUTTON3")
    BindButton("CTRL-1", "BONUSACTIONBUTTON4")
    BindButton("CTRL-2", "BONUSACTIONBUTTON5")
    BindButton("CTRL-3", "BONUSACTIONBUTTON6")
    BindButton("CTRL-4", "BONUSACTIONBUTTON7")
    BindButton("CTRL-5", "BONUSACTIONBUTTON8")
    BindButton("CTRL-6", "BONUSACTIONBUTTON9")
    BindButton("CTRL-7", "BONUSACTIONBUTTON10")
    UnbindButton("ACTIONPAGE1", 1)
    UnbindButton("ACTIONPAGE2", 1)
    UnbindButton("ACTIONPAGE3", 1)
    UnbindButton("ACTIONPAGE4", 1)
    UnbindButton("ACTIONPAGE5", 1)
    UnbindButton("ACTIONPAGE6", 1)
    UnbindButton("PREVIOUSACTIONPAGE", 1)
    UnbindButton("NEXTACTIONPAGE", 1)

    BindButton("CTRL-Q", "MULTIACTIONBAR1BUTTON1")
    BindButton("CTRL-W", "MULTIACTIONBAR1BUTTON2")
    BindButton("CTRL-R", "MULTIACTIONBAR1BUTTON3")
    BindButton("CTRL-T", "MULTIACTIONBAR1BUTTON4")
    BindButton("CTRL-A", "MULTIACTIONBAR1BUTTON5")
    BindButton("CTRL-G", "MULTIACTIONBAR1BUTTON6")
    BindButton("CTRL-E", "MULTIACTIONBAR1BUTTON7")
    BindButton("CTRL-D", "MULTIACTIONBAR1BUTTON8")
    BindButton("CTRL-S", "MULTIACTIONBAR1BUTTON9")
    BindButton("CTRL-F", "MULTIACTIONBAR1BUTTON10")
    BindButton("CTRL-Z", "MULTIACTIONBAR1BUTTON11")
    BindButton("CTRL-X", "MULTIACTIONBAR1BUTTON12")

    SaveBindings(ACCOUNT_BINDINGS)
    KeyBindingFrame.outputText:SetText("")
end

local function ApplyMySettings()
    SetCVars(hiddenCVars)
    SetCVars(voiceCVars)

    SetMyInterfaceOptions()

    if LoadAddOn("Blizzard_BindingUI") then
        SetMyBindings()
    end

    for i = 1, NUM_CHAT_WINDOWS do
        local list = _G["ChatFrame" .. i].messageTypeList
        for j = 1, #list do
            if list[j] == "CHANNEL" then
                tremove(list, j)
                ChatFrame_RemoveMessageGroup(_G["ChatFrame" .. i], "CHANNEL")
                break
            end
        end
    end

    for i = 1, GetNumTrackingTypes() do
        local name = GetTrackingInfo(i)
        if name == "旅店老闆" then
            SetTracking(i, true)
            break
        end
    end
end

my:SetScript("OnClick", function()
    ApplyDefaultSettings()
    ApplyMySettings()

    InterfaceOptionsActionBarsPanelBottomLeft.value = "1"
    InterfaceOptionsActionBarsPanelBottomRight.value = "1"
    InterfaceOptionsActionBarsPanelRight.value = "1"
    SHOW_MULTI_ACTIONBAR_1 = true
    SHOW_MULTI_ACTIONBAR_2 = true
    SHOW_MULTI_ACTIONBAR_3 = true
    InterfaceOptions_UpdateMultiActionBars()

    InterfaceOptionsNamesPanelUnitNameplatesMakeLarger.setFunc("1")

    SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "keepGroupsTogether", true)
    SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "useClassColors", true)
    SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayBorder", false)
    SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "frameHeight", 54, 54)
    SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "frameWidth", 137, 137)

    StaticPopup_Show("RELOAD_UI")
end)

hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(self)
    self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
end)