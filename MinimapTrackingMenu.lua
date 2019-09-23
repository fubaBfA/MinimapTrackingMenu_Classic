local AddOn = select(2, ...)

-- This AddOn is inspired by "TrackingEye" and "Tukui Tracking Menu"

local TrackingSpells = {
	1494,	-- Track Beasts (Hunter)
	2383,	-- Find Herbs (Herbalism)
	2481,	-- Find Treasure (Dwarf racial)
	2580,	-- Find Minerals (Mining)
	5225,	-- Track Humanoids (Druid)
	5500,	-- Sense Demons (Warlock)
	5502,	-- Sense Undead (Paladin)
	19878,	-- Track Demons (Hunter)
	19879,	-- Track Dragonkin (Hunter)
	19880,	-- Track Elementals (Hunter)
	19882,	-- Track Giants (Hunter)
	19883,	-- Track Humanoids (Hunter)
	19884,	-- Track Undead (Hunter)
	19885	-- Track Hidden (Hunter)
}

local menuList = {
	{text = _G.CHARACTER_BUTTON,
	func = function() ToggleCharacter("PaperDollFrame") end},
	{text = _G.SPELLBOOK_ABILITIES_BUTTON,
	func = function()
		if not _G.SpellBookFrame:IsShown() then
			ShowUIPanel(_G.SpellBookFrame)
		else
			HideUIPanel(_G.SpellBookFrame)
		end
	end},
	{text = _G.TALENTS_BUTTON,
	func = function()
		if not _G.TalentFrame then
			_G.TalentFrame_LoadUI()
		end

		if not TalentFrame:IsShown() then
			ShowUIPanel(TalentFrame)
		else
			HideUIPanel(TalentFrame)
		end
	end},
	{text = _G.CHAT_CHANNELS,
	func = _G.ToggleChannelFrame},
	{text = _G.TIMEMANAGER_TITLE,
	func = function() ToggleFrame(_G.TimeManagerFrame) end},
	{text = _G.SOCIAL_LABEL,
	func = ToggleFriendsFrame},
	{text = _G.GUILD,
	func = function()
		if IsInGuild() then
			ToggleFriendsFrame(3)
		else
			ToggleGuildFrame()
		end
	end},
	{text = _G.MAINMENU_BUTTON,
	func = function()
		if not _G.GameMenuFrame:IsShown() then
			if _G.VideoOptionsFrame:IsShown() then
				_G.VideoOptionsFrameCancel:Click();
			elseif _G.AudioOptionsFrame:IsShown() then
				_G.AudioOptionsFrameCancel:Click();
			elseif _G.InterfaceOptionsFrame:IsShown() then
				_G.InterfaceOptionsFrameCancel:Click();
			end

			CloseMenus();
			CloseAllWindows()
			PlaySound(850) --IG_MAINMENU_OPEN
			ShowUIPanel(_G.GameMenuFrame);
		else
			PlaySound(854) --IG_MAINMENU_QUIT
			HideUIPanel(_G.GameMenuFrame);
			MainMenuMicroButton_SetNormal();
		end
	end},
	{text = _G.HELP_BUTTON, func = ToggleHelpFrame}
}

function AddOn:OnInitialize()
	if MiniMapTrackingFrame == nil then
		return
	end
	MiniMapTrackingFrame:SetFrameStrata(Minimap:GetFrameStrata())
	MiniMapTrackingFrame:SetFrameLevel(Minimap:GetFrameLevel() + 5)

	AddOn.Menu = CreateFrame("Frame", "fuba_TrackingMenu_DropDown", UIParent, "UIDropDownMenuTemplate")
	AddOn.Menu:Hide()

	AddOn.MenuButtons = {}
	for i = 1, #TrackingSpells do
		local SpellID = TrackingSpells[i]
		table.insert(AddOn.MenuButtons, {
			_spellID = SpellID,
			text = GetSpellInfo(SpellID),
			icon = GetSpellTexture(SpellID),
			func = function()
				CastSpellByID(SpellID)
			end
		})
	end
	table.sort(AddOn.MenuButtons, function(lh, rh)
		return strcmputf8i(lh.text, rh.text) < 0
	end)
end

function AddOn:OpenMenu(frame, left)
	local anchor
	local CurrentTexture = GetTrackingTexture()
	local VisibleButtons = {}
	for i = 1, #AddOn.MenuButtons do
		local MenuButton = AddOn.MenuButtons[i]
		if IsPlayerSpell(MenuButton._spellID) then
			MenuButton.checked = MenuButton.icon == CurrentTexture
			table.insert(VisibleButtons, MenuButton)
		end
	end

	if frame then anchor=frame else anchor="MiniMapTrackingFrame" end
	if left then
		EasyMenu(VisibleButtons, AddOn.Menu, anchor, 0 , 0, "MENU", 2);
	else
		EasyMenu(VisibleButtons, AddOn.Menu, anchor, -160 , 0, "MENU", 2);
	end	
end

if ElvUI then
	_G.Minimap:SetScript("OnMouseDown", function(self, btn)
		local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
		local M = E:GetModule('Minimap')
		local menuFrame = _G["MinimapRightClickMenu"]
		if menuFrame then menuFrame:Hide() else return end
		local position = self:GetPoint()
		if btn == "MiddleButton" then
			if position:match("LEFT") then
				E:DropDown(menuList, menuFrame)
			else
				E:DropDown(menuList, menuFrame, -160, 0)
			end
		elseif btn == "RightButton" then
				AddOn:OpenMenu("cursor")
		else
			_G.Minimap_OnClick(self)
		end
	end)
else
	_G.Minimap:SetScript("OnMouseUp", function() end)
	_G.Minimap:SetScript("OnMouseDown", function(self, btn)
		if btn == "RightButton" then
			AddOn:OpenMenu("cursor")
		else
			_G.Minimap_OnClick(self)
		end
	end)
end

AddOn:OnInitialize()