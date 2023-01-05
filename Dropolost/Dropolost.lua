--font used for error and system messages (the ones in the upper center of the screen, e.g. "Not enough mana")
dropohobo_errorfont_native = ""
--font's height. 1 is a placeholder, the actual value is gotten upon loading the addon
dropohobo_errorfont_height = 1
--blank font. All symbols in this font are blank. Used in hiding the exploration system messages.
dropohobo_errorfont_blank = "Interface\\AddOns\\Dropohobo\\BLANK.ttf"

function Dropolost_OnLoad()
	--get the default font for system messages
	local kids = {UIErrorsFrame:GetRegions()}
	dropohobo_errorfont_native,dropohobo_errorfont_height = kids[1]:GetFont()
	
	--subscribe to the world map event so we can deny opening the map
	this:RegisterEvent("WORLD_MAP_UPDATE")

	--disable minimap satellite texture
	Minimap:SetMaskTexture("Interface\\AddOns\\Dropohobo\\mask");
	
	--make the minimap border semi-transparent
	--MinimapBackdrop:SetAlpha(0.5);
	
	--change the minimap frame to Terra Incognita
	local kids = {MinimapBackdrop:GetRegions()}
	kids[1]:SetTexture("Interface\\AddOns\\Dropohobo\\minimapframe")
	
	--hide all unnecessary buttons around the minimap
	GameTimeFrame:Hide();
	MinimapBorderTop:Hide();
	MinimapToggleButton:Hide();
	MinimapZoneTextButton:Hide();
	MinimapZoomIn:Hide();
	MinimapZoomOut:Hide();

	--[[the following code is necessary to disable tracking dots (e.g. quest givers, gathering nodes) on the minimap]]
	--re-attach all children of the minimap to the parent of the minimap
	local kids = {Minimap:GetChildren()}
	for _,child in kids do
		child:SetParent("MinimapCluster")
	end
	--hide the minimap
	Minimap:Hide()
end

function Dropolost_OnEvent(event)
	if (event=="WORLD_MAP_UPDATE") then
		if WorldMapFrame:IsVisible() then
			ToggleWorldMap();
			DEFAULT_CHAT_FRAME:AddMessage("|cFFAAAAFF"..UnitName("player").." does not have a map!|r");
		end
	end
end

function Dropolost_Update()
	--hide floating zone text (i.e. when you enter a zone or a subzone)
	ZoneTextFrame:SetAlpha(0)
	SubZoneTextFrame:SetAlpha(0)

	--hide minimap arrows (pointing to nearby points of interest) and the player arrow
	local kids = {MinimapCluster:GetChildren()}
	for _,child in kids do
		if child:GetObjectType()=="Model" then
			child:SetAlpha(0)
			child:Hide()
		end
	end

	--replace Discovery chat message with a generic one
	local kids = {ChatFrame1:GetRegions()}
	for _,child in kids do
		if child:GetObjectType()=="FontString" then
			if child:GetText() then 
				if strsub(child:GetText(),1,11)=="Discovered " and child:GetText()~="Discovered a new location." then
					child:SetText("|cFFFFFF00Discovered a new location.|r")
				end
			end
		end
	end

	--replace Discovery system message with a generic one
	--also update fonts, this is needed because otherwise the Discovery message will be visible for a single frame
	local kids = {UIErrorsFrame:GetRegions()}
	for _,child in kids do
		child:SetFont(dropohobo_errorfont_blank,dropohobo_errorfont_height)
		if child:GetText() then
			if strsub(child:GetText(),1,12)=="Discovered: " then
				child:SetText("Discovered a new location.")
			elseif child:GetAlpha()==0 then
				child:SetFont(dropohobo_errorfont_blank,dropohobo_errorfont_height)
			else
				child:SetFont(dropohobo_errorfont_native,dropohobo_errorfont_height)
			end
		end
	end
end