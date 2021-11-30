local multiplier_damage_convar = 1
local multiplier_convar = 1
local multiplier_local = 1
local multiplier_idle = 1
local lerped_bob_the_builder = Angle(0, 0, 0)
local is_calc = false
local tool_equipped = false

local function equipped_tool(ply)
	-- returns true if a tool is equipped
	-- returns false if not and if viewbob_tools_enable is at 1
	local weapon_ent = ply:GetActiveWeapon()
	if GetConVarNumber("viewbob_tools_enable") == 0 && weapon_ent:IsValid() then
		local weapon = weapon_ent:GetClass()
		if weapon == "gmod_tool" or weapon == "weapon_physgun" or weapon == "gmod_camera" then
			return true
		else
			return false
		end
	else
		return false
	end
end

local function walk_viewbob(ply, pos, foot, sound, volume, rf)
	if GetConVarNumber("viewbob_enable") != 1 || equipped_tool(ply) then return end

	multiplier_convar = GetConVarNumber("viewbob_multiplier")

 	-- Calculate the multiplier we're going to use for walking 
	if ply:KeyDown(IN_DUCK) || ply:KeyDown(IN_WALK) then
		-- duck or walking
		multiplier_local = 0.3 * multiplier_convar
	elseif ply:KeyDown(IN_SPEED) then
		-- run
		multiplier_local = 1.2 * multiplier_convar
	else
		-- walk
		multiplier_local = 0.5 * multiplier_convar
	end

	if foot == 0 then
		-- left foot
		step = 0.5 * multiplier_local
	elseif foot == 1 then
		-- right foot
		step = -0.5 * multiplier_local
	end

	-- Jump viewbob
    if ply:KeyPressed(IN_JUMP) && GetConVarNumber("viewbob_land_jump_enable") == 1 then
        ply:ViewPunch(Angle(-4 * multiplier_local, step, step))
    end

    -- The rest of the function is related to walking, so we skip all of that if we have disabled it
	if GetConVarNumber("viewbob_walk_enable") == 0 then return end
 	
    if ply:KeyDown(IN_FORWARD) then
        ply:ViewPunch(Angle(multiplier_local, step, step))
    end
    if ply:KeyDown(IN_BACK) then
        ply:ViewPunch(Angle(-1 * multiplier_local, step, step))
    end
    if ply:KeyDown(IN_MOVELEFT) then
        ply:ViewPunch(Angle(step, step, -1 * multiplier_local))
    end
    if ply:KeyDown(IN_MOVERIGHT) then
        ply:ViewPunch(Angle(step, step, multiplier_local))
    end
end

local function land_viewbob(ply, inWater, onFloater, speed)
	if GetConVarNumber("viewbob_enable") != 1 || GetConVarNumber("viewbob_land_jump_enable") != 1 then return end
	if equipped_tool(ply) then return end
	multiplier_convar = GetConVarNumber("viewbob_multiplier")
	-- I thought that if you duck in air it'd look cooler if you bob less, so I've done that
	if ply:KeyDown(IN_DUCK) then
		ply:ViewPunch(Angle(speed / 80 * multiplier_convar, 0, 0))
	else
		ply:ViewPunch(Angle(speed / 40 * multiplier_convar, 0, 0))
	end
end

local function damage_viewbob(target, dmginfo)
	if target:IsPlayer() then
		if GetConVarNumber("viewbob_enable") != 1 || GetConVarNumber("viewbob_damage_enable") != 1 then return end
		if target:GetMoveType() == MOVETYPE_NOCLIP then return end
		if equipped_tool(target) then return end
		multiplier_damage_convar = GetConVarNumber("viewbob_damage_multiplier")
		-- OW HELL I GOT HIT >:(
		target:ViewPunch(Angle(math.random(-3,3) * multiplier_damage_convar, 
							   math.random(-3,3) * multiplier_damage_convar, 
							   math.random(-3,3) * multiplier_damage_convar))
	end
end

local function idle_viewbob(ply, origin, angles, fov, znear, zfar)
	-- pasted from tfa's cbob mod...
	-- we're doing this so that we don't completely override the other hooks into CalcView. 
	-- In modern warfare base it causes a lot of wacky stuff!
	if is_calc then return end
	is_calc = true
	local view = hook.Run("CalcView", ply, origin, angles, fov, znear, zfar) or {} 
	is_calc = false																   
	view.origin	= view.origin or pos											   
	view.angles	= view.angles or ang
	view.fov = view.fov or fov
	view.znear = view.znear or znear
	view.zfar = view.zfar or zfar

	multiplier_idle = GetConVarNumber("viewbob_idle_multiplier")

	local bob_the_builder = Angle(math.cos(CurTime() / 0.9) / 3 * multiplier_idle,
						          math.sin(CurTime() / 0.8) / 3.6 * multiplier_idle,
		                          math.cos(CurTime() / 0.5) / 3.3 * multiplier_idle)

	if ply:KeyDown(IN_ATTACK2) then
		lerped_bob_the_builder = Angle(0, 0, 0)
	else
		lerped_bob_the_builder = LerpAngle(0.1, lerped_bob_the_builder, bob_the_builder)
	end

	if GetConVarNumber("viewbob_idle_enable") == 1 && !equipped_tool(ply) && ply:GetMoveType() != MOVETYPE_NOCLIP then
		view.angles = view.angles + lerped_bob_the_builder
	else
		view.angles = view.angles
	end

	return view
end

local function crouch_uncrouch_viewbob()
	if GetConVarNumber("viewbob_crouch_enable") != 1 || GetConVarNumber("viewbob_enable") != 1 then return end
	local crouch_mult = GetConVarNumber("viewbob_crouch_multiplier")
	for i, ply in ipairs(player.GetAll()) do
		if equipped_tool(ply) then return end
		if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	    if ply:KeyPressed(IN_DUCK) then
	    	ply:ViewPunch(Angle(4 * crouch_mult, 
	    						math.random(-1, 1) * crouch_mult, 
	    						math.random(-1, 1) * crouch_mult))
	    elseif ply:KeyReleased(IN_DUCK) then
	    	ply:ViewPunch(Angle(-4 * crouch_mult, 
	    						math.random(-1, 1) * crouch_mult, 
	    						math.random(-1, 1) * crouch_mult))
	    end
	end
end

hook.Add("EntityTakeDamage", "damage_viewbob", damage_viewbob)
hook.Add("PlayerFootstep", "walk_viewbob", walk_viewbob)
hook.Remove("OnPlayerHitGround", "voskydive_falldamage_hook")
hook.Add("OnPlayerHitGround", "land_viewbob", land_viewbob)
hook.Add("CalcView", "idle_viewbob", idle_viewbob)
hook.Add("Think", "crouch_uncrouch_viewbob", crouch_uncrouch_viewbob)
