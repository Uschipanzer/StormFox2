--[[-------------------------------------------------------------------------
Useful functions
---------------------------------------------------------------------------]]

StormFox2.util = {}
local cache = {}
--[[<Shared>-----------------------------------------------------------------
Returns the OBBMins and OBBMaxs of a model.
---------------------------------------------------------------------------]]
function StormFox2.util.GetModelSize(sModel)
	if cache[sModel] then return cache[sModel][1],cache[sModel][2] end
	if not file.Exists(sModel,"GAME") then
		cache[sModel] = {Vector(0,0,0),Vector(0,0,0)}
		return cache[sModel]
	end
	local f = file.Open(sModel,"r", "GAME")
	f:Seek(104)
	local hullMin = Vector( f:ReadFloat(),f:ReadFloat(),f:ReadFloat())
	local hullMax = Vector( f:ReadFloat(),f:ReadFloat(),f:ReadFloat())
	f:Close()
	cache[sModel] = {hullMin,hullMax}
	return hullMin,hullMax
end

if CLIENT then
	--[[-----------------------------------------------------------------
	Calcview results
	---------------------------------------------------------------------------]]
	local view = {}
		view.pos = Vector(0,0,0)
		view.ang = Angle(0,0,0)
		view.fov = 0
		view.drawviewer = false
	hook.Add("PreDrawTranslucentRenderables", "StormFox2.util.EyeHack", function() EyePos() end)
	hook.Add("PreRender","StormFox2.util.EyeFix",function()
		local t = hook.Run("CalcView", LocalPlayer(), EyePos(), EyeAngles(), LocalPlayer():GetFOV(),3,28377)
		if not t then 
			view.pos = EyePos()
			view.ang = EyeAngles()
			view.fov = 90
			view.drawviewer = LocalPlayer():ShouldDrawLocalPlayer()
			return
		end
		view.pos = t.origin or EyePos()
		view.ang = t.angles or EyeAngles()
		view.fov = t.fov or view.fov or 90
		view.drawviewer = t.drawviewer or LocalPlayer():ShouldDrawLocalPlayer()
	end)
	--[[<Client>-----------------------------------------------------------------
	Returns the last calcview result.
	---------------------------------------------------------------------------]]
	function StormFox2.util.GetCalcView()
		return view
	end
	--[[<Client>-----------------------------------------------------------------
	Returns the last camera position.
	---------------------------------------------------------------------------]]
	function StormFox2.util.RenderPos()
		return view.pos or EyePos()
	end
		--[[<Client>-----------------------------------------------------------------
	Returns the current viewentity
	---------------------------------------------------------------------------]]
	function StormFox2.util.ViewEntity()
		local p = LocalPlayer():GetViewEntity() or LocalPlayer()
		if p.InVehicle and p:InVehicle() and p == LocalPlayer() then
			p = p:GetVehicle() or p
		end
		return p
	end
end