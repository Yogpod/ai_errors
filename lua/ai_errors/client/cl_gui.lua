local PANEL = {}
function PANEL:Init()
	self:SetSize(ScrW() * 0.3, ScrH() * 0.3)
	self:Center()
	self:MakePopup()
	self:SetTitle("AI Errors Configuration")
	self:ShowCloseButton(true)
	self:SetDraggable(true)
	self:DockPadding(20, 30, 20, 20)
	self.Paint = function(s, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 255))
		draw.SimpleText(self:GetTitle(), "DermaDefaultBold", w / 2, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	end

	self:CreateUI()
end

function PANEL:CreateUI()
	local apiKeyLabel = vgui.Create("DLabel", self)
	apiKeyLabel:SetText("OpenAI API Key:")
	apiKeyLabel:SetFont("DermaDefaultBold")
	apiKeyLabel:Dock(TOP)
	apiKeyLabel:DockMargin(0, 0, 0, 5)
	local apiKeyEntry = vgui.Create("DTextEntry", self)
	apiKeyEntry:SetText(ai_errors.apiKey)
	apiKeyEntry:Dock(TOP)
	apiKeyEntry:DockMargin(0, 0, 0, 15)
	local clientsidePanel = vgui.Create("DPanel", self)
	clientsidePanel:SetTall(30)
	clientsidePanel:Dock(TOP)
	clientsidePanel:DockMargin(0, 0, 0, 15)
	clientsidePanel.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(70, 70, 70, 255)) end
	local clientsideErrorsLabel = vgui.Create("DLabel", clientsidePanel)
	clientsideErrorsLabel:SetText("CL Errors")
	clientsideErrorsLabel:Dock(LEFT)
	clientsideErrorsLabel:DockMargin(0, 5, 10, 0)
	local clientsideErrorsEntry = vgui.Create("DCheckBox", clientsidePanel)
	clientsideErrorsEntry:SetChecked(ai_errors.clientsideErrors)
	clientsideErrorsEntry:Dock(RIGHT)
	clientsideErrorsEntry:DockMargin(0, 0, 10, 0)
	clientsideErrorsEntry:SetWide(20)

	-- Add the warning label
	local warningLabel = vgui.Create("DLabel", self)
	warningLabel:SetText("Warning: Enabling CL Errors can lead to spam and increased costs!")
	warningLabel:SetFont("DermaDefault")
	warningLabel:SetTextColor(Color(255, 0, 0)) -- red text for emphasis
	warningLabel:Dock(TOP)
	warningLabel:DockMargin(0, 0, 0, 5)
	warningLabel:SetWrap(true) -- Wrap text if it's too long

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
		net.Start("ai_errors")
		net.WriteString(apiKeyEntry:GetText())
		net.WriteBool(clientsideErrorsEntry:GetChecked())
		net.SendToServer()
		self:Close()
	end
end

vgui.Register("AIErrorsConfig", PANEL, "DFrame")