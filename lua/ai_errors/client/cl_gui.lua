local function CreateTextEntry(parent, labelText, defaultText, censor, readonly)
	local label = vgui.Create("DLabel", parent)
	label:SetText(labelText)
	label:SetFont("DermaDefaultBold")
	label:Dock(TOP)
	label:DockMargin(0, 0, 0, 5)
	local entry = vgui.Create("DTextEntry", parent)
	entry:Dock(TOP)
	entry:DockMargin(0, 0, 0, 15)
	local realValue = defaultText or ""
	if censor then
		entry:SetText(("*"):rep(#realValue))
		entry.OnGetFocus = function(s)
			s:SetText(realValue)
			s:SetCaretPos(#realValue)
		end

		entry.OnLoseFocus = function(s)
			if s:GetText() ~= "" then
				realValue = s:GetText()
				s.changed = true
				s.newValue = realValue
			end

			s:SetText(("*"):rep(#realValue))
		end
	else
		entry:SetText(defaultText or "")
	end

	if readonly then entry:SetEditable(false) end
	return entry
end

local function CreateCheckBoxEntry(parent, labelText, isChecked)
	local panel = vgui.Create("DPanel", parent)
	panel:SetTall(30)
	panel:Dock(TOP)
	panel:DockMargin(0, 0, 0, 15)
	panel.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(70, 70, 70, 255)) end
	local label = vgui.Create("DLabel", panel)
	label:SetText(labelText)
	label:Dock(LEFT)
	label:DockMargin(0, 5, 10, 0)
	local checkBox = vgui.Create("DCheckBox", panel)
	checkBox:SetChecked(isChecked or false)
	checkBox:Dock(RIGHT)
	checkBox:DockMargin(0, 0, 10, 0)
	checkBox:SetWide(20)
	return checkBox
end

local PANEL = {}
function PANEL:Init()
	self:SetSize(ScrW() * 0.3, ScrH() * 0.5)
	self:Center()
	self:MakePopup()
	self:SetTitle("")
	self:ShowCloseButton(true)
	self:SetDraggable(true)
	self:DockPadding(20, 30, 20, 20)
	self.Paint = function(s, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 255))
		draw.SimpleText("AI Errors Configuration", "DermaDefaultBold", w / 2, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	end

	local scrollPanel = vgui.Create("DScrollPanel", self)
	scrollPanel:Dock(FILL)
	scrollPanel:DockMargin(0, 0, 0, 50)
	self:CreateUI(scrollPanel)
	local saveButton = vgui.Create("DButton", self)
	saveButton:SetText("")
	saveButton:Dock(BOTTOM)
	saveButton:DockMargin(0, 10, 0, 0)
	saveButton:SetTall(40)
	saveButton.Paint = function(s, w, h)
		local buttonColor = s:IsHovered() and Color(100, 100, 255, 255) or Color(70, 70, 70, 255)
		draw.RoundedBox(6, 0, 0, w, h, buttonColor)
		draw.SimpleText("Save", "DermaDefaultBold", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	saveButton.DoClick = function()
		local newAPIKey = self.apiKeyEntry.changed and self.apiKeyEntry.newValue or ai_errors.apiKey
		local newWebhook = self.webhookEntry.changed and self.webhookEntry.newValue or ai_errors.webhook
		ai_errors.apiKey = newAPIKey
		ai_errors.webhook = newWebhook
		self.webhookEntry.changed = false
		self.apiKeyEntry.changed = false
		ai_errors.model = self.modelEntry:GetText() or ai_errors.model
		ai_errors.clientsideErrors = self.clientsideErrorsEntry:GetChecked() or ai_errors.clientsideErrors
		ai_errors.useAnthropic = self.useAnthropicEntry:GetChecked() or ai_errors.useAnthropic
		ai_errors.webhookName = self.webhookNameEntry:GetText() or ai_errors.webhookName
		ai_errors.webhookAvatar = self.webhookAvatarEntry:GetText() or ai_errors.webhookAvatar
		ai_errors.embedTitle = self.embedTitleEntry:GetText() or ai_errors.embedTitle
		ai_errors.embedColor = tonumber(self.embedColorEntry:GetText():gsub("#", ""), 16) or ai_errors.embedColor
		ai_errors.embedFooterText = self.embedFooterTextEntry:GetText() or ai_errors.embedFooterText
		ai_errors.embedFooterAvatar = self.embedFooterAvatarEntry:GetText() or ai_errors.embedFooterAvatar
		net.Start("ai_errors")
		net.WriteString("config")
		net.WriteString(ai_errors.apiKey)
		net.WriteString(ai_errors.model)
		net.WriteBool(ai_errors.clientsideErrors)
		net.WriteBool(ai_errors.useAnthropic)
		net.WriteString(ai_errors.webhook)
		net.WriteString(ai_errors.webhookName)
		net.WriteString(ai_errors.webhookAvatar)
		net.WriteString(ai_errors.embedTitle)
		net.WriteUInt(ai_errors.embedColor, 32)
		net.WriteString(ai_errors.embedFooterText)
		net.WriteString(ai_errors.embedFooterAvatar)
		net.SendToServer()
		self:Close()
	end
end

function PANEL:CreateUI(parent)
	-- OpenAI API Key Section
	self.apiKeyEntry = CreateTextEntry(parent, "OpenAI API Key:", ai_errors.apiKey, true)
	-- Model Section
	self.modelEntry = CreateTextEntry(parent, "Model:", ai_errors.model, false, true)
	-- Client-side Errors Checkbox
	self.clientsideErrorsEntry = CreateCheckBoxEntry(parent, "CL Errors", ai_errors.clientsideErrors)
	-- Warning Label
	local warningLabel = vgui.Create("DLabel", parent)
	warningLabel:SetText("Warning: Enabling CL Errors can lead to spam and increased costs!")
	warningLabel:SetFont("DermaDefault")
	warningLabel:SetTextColor(Color(255, 0, 0))
	warningLabel:Dock(TOP)
	warningLabel:DockMargin(0, 0, 0, 5)
	warningLabel:SetWrap(true)
	-- Anthropic Checkbox
	self.useAnthropicEntry = CreateCheckBoxEntry(parent, "Use Claude", ai_errors.useAnthropic, false, true)
	-- Webhook URL Section
	self.webhookEntry = CreateTextEntry(parent, "Webhook URL:", ai_errors.webhook, true)
	-- Webhook Name Section
	self.webhookNameEntry = CreateTextEntry(parent, "Webhook Name:", ai_errors.webhookName)
	-- Webhook Avatar Section
	self.webhookAvatarEntry = CreateTextEntry(parent, "Webhook Avatar URL:", ai_errors.webhookAvatar)
	-- Embed Title Section
	self.embedTitleEntry = CreateTextEntry(parent, "Embed Title:", ai_errors.embedTitle)
	-- Embed Color Section
	self.embedColorEntry = CreateTextEntry(parent, "Embed Color (Hex):", string.format("#%06x", ai_errors.embedColor or 15158332))
	-- Embed Footer Text Section
	self.embedFooterTextEntry = CreateTextEntry(parent, "Embed Footer Text:", ai_errors.embedFooterText)
	-- Embed Footer Avatar Section
	self.embedFooterAvatarEntry = CreateTextEntry(parent, "Embed Footer Avatar URL:", ai_errors.embedFooterAvatar)
end

vgui.Register("AIErrorsConfig", PANEL, "DFrame")