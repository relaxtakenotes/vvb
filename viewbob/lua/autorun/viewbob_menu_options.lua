local function settings_list(Panel)
	Panel:AddControl("Checkbox", {Label="Enable viewbob", Command="viewbob_enable"})
	Panel:AddControl("Checkbox", {Label="Viewbob with tools", Command="viewbob_tools_enable"})
	Panel:AddControl("Checkbox", {Label="Walking viewbob", Command="viewbob_walk_enable"})
	Panel:AddControl("Checkbox", {Label="Jump/Land Viewbob", Command="viewbob_land_jump_enable"})
	Panel:AddControl("Slider",{Type="float", Label = "General Multiplier", min=0, max=10, Command = "viewbob_multiplier"})

	Panel:AddControl("Checkbox", {Label="Crouch/Uncrouch Viewbob", Command="viewbob_crouch_enable"})
	Panel:AddControl("Slider",{Type="float", Label = "Crouch/Uncrouch Multiplier", min=0, max=10, Command = "viewbob_crouch_multiplier"})

	Panel:AddControl("Checkbox", {Label="Idle Viewbob", Command="viewbob_idle_enable"})
	Panel:AddControl("Slider",{Type="float", Label = "Idle Multiplier", min=0, max=10, Command = "viewbob_idle_multiplier"})
	
	Panel:AddControl("Checkbox", {Label="Enable damage viewbob", Command="viewbob_damage_enable"})
	Panel:AddControl("Slider",{Type="float", Label = "Damage viewbob multiplier", min=0, max=10, Command = "viewbob_damage_multiplier"})
end
function setup_the_settings()
	spawnmenu.AddToolMenuOption("Options", "Viewpunch viewbob", "Visual settings", "Settings", "", "", settings_list, {} )
end
hook.Add("PopulateToolMenu", "viewbob_menu_settings", setup_the_settings)
