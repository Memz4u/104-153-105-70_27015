-- "addons\\wiremod\\lua\\entities\\gmod_wire_wheel.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Wheel"
ENT.WireDebugName	= "Wheel"

if CLIENT then return end -- No more client

-- As motor constraints can't have their initial torque updated,
-- we always create it with 1000 initial torque (needs to be > friction) and then Scale it with a multiplier
local WHEEL_BASE_TORQUE = 1000

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	self.BaseTorque = 1
	self.Breaking = 0
	self.SpeedMod = 0
	self.Go = 0

	self.Inputs = Wire_CreateInputs(self, { "A: Go", "B: Break", "C: SpeedMod" })
end

function ENT:Setup(fwd, bck, stop, torque, direction, axis)
	self.fwd = fwd
	self.bck = bck
	self.stop = stop
	if torque then self:SetTorque(math.max(1, torque)) end
	if direction then self:SetDirection( direction ) end
	if axis then self.Axis = axis end

	self:UpdateOverlayText()
end

function ENT:UpdateOverlayText(speed)
	local motor = self:GetMotor()
	local friction = 0
	if IsValid(motor) then friction = motor.friction end
	self:SetOverlayText(
		"Torque: " .. math.floor( self.BaseTorque ) ..
		"\nFriction: " .. friction ..
		"\nSpeed: " .. (speed or 0) ..
		"\nBreak: " .. self.Breaking ..
		"\nSpeedMod: " .. math.floor( self.SpeedMod * 100 ) .. "%" )
end

function ENT:SetAxis( vec )
	self.Axis = self:GetPos() + vec * 512
	self.Axis = self:NearestPoint( self.Axis )
	self.Axis = self:WorldToLocal( self.Axis )
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:SetMotor( Motor )
	self.Motor = Motor
	self:UpdateOverlayText()
end

function ENT:GetMotor()
	if not self.Motor then
		self.Motor = constraint.FindConstraintEntity( self, "Motor" )
		if not IsValid(self.Motor) then
			self.Motor = nil
		end
	end
	return self.Motor
end

function ENT:SetDirection( dir )
	self:SetNWInt( 1, dir )
	self.direction = dir
end

function ENT:Forward( mul )
	if not self:IsValid() then return false end
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return false end

	mul = mul or 1
	local mdir = Motor.direction
	local Speed = mdir * mul * (self.BaseTorque / WHEEL_BASE_TORQUE) * (1 + self.SpeedMod)

	self:UpdateOverlayText(mul ~= 0 and (mdir * mul * (1 + self.SpeedMod)) or 0)

	Motor:Fire( "Scale", Speed, 0 )
	Motor:GetTable().forcescale = Speed
	Motor:Fire( "Activate", "" , 0 )

	return true
end

function ENT:TriggerInput(iname, value)
	if (iname == "A: Go") then
		if ( value == self.fwd ) then self.Go = 1
		elseif ( value == self.bck ) then self.Go = -1
		elseif ( value == self.stop ) then self.Go =0 end
	elseif (iname == "B: Break") then
		self.Breaking = value
	elseif (iname == "C: SpeedMod") then
		self.SpeedMod = (value / 100)
	end
	self:Forward( self.Go )
end


--[[---------------------------------------------------------
   Name: PhysicsUpdate
   Desc: happy fun time breaking function
---------------------------------------------------------]]
function ENT:PhysicsUpdate( physobj )
	local vel = physobj:GetVelocity()

	if (self.Breaking > 0) then -- to prevent badness
		if (self.Breaking >= 100) then --100% breaking!!!
			vel.x = 0 --full stop!
			vel.y = 0
		else
			vel.x = vel.x * ((100.0 - self.Breaking)/100.0)
			vel.y = vel.y * ((100.0 - self.Breaking)/100.0)
		end
	else
		return -- physobj:SetVelocity(physobj:GetVelocity()) will create constant acceleration
	end

	physobj:SetVelocity(vel)
end

function ENT:SetTorque( torque )
	self.BaseTorque = torque

	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end
	Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (torque / WHEEL_BASE_TORQUE), 0 )

	self:UpdateOverlayText()
end

--[[---------------------------------------------------------
   Creates the direction arrows on the wheel
---------------------------------------------------------]]
function ENT:DoDirectionEffect()
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( self.Axis )
		effectdata:SetEntity( self )
		effectdata:SetScale( Motor.direction )
	util.Effect( "wheel_indicator", effectdata, true, true )
end

--[[---------------------------------------------------------
   Reverse the wheel direction when a player uses the wheel
---------------------------------------------------------]]
function ENT:Use( activator, caller, type, value )
	local Motor = self:GetMotor()
	local Owner = self:GetPlayer()

	if (Motor and (Owner == nil or Owner == activator)) then
		if (Motor:GetTable().direction == 1) then
			Motor:GetTable().direction = -1
		else
			Motor:GetTable().direction = 1
		end

		Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (self.BaseTorque / WHEEL_BASE_TORQUE), 0 )
		self:SetDirection( Motor:GetTable().direction )

		self:DoDirectionEffect()
	end
end

duplicator.RegisterEntityClass("gmod_wire_wheel", WireLib.MakeWireEnt, "Data", "fwd", "bck", "stop", "BaseTorque", "direction", "Axis")

function ENT:SetWheelBase(Base)
	Base:DeleteOnRemove( self )
	self.Base = Base
end

function ENT:BuildDupeInfo()
	local info = BaseClass.BuildDupeInfo(self) or {}
	if IsValid(self.Base) then
		info.Base = self.Base:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID)

	local Base = GetEntByID(info.Base)
	if IsValid(Base) then
		self:SetWheelBase(Base)
	end
	self:UpdateOverlayText()
end


-- "addons\\wiremod\\lua\\entities\\gmod_wire_wheel.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Wheel"
ENT.WireDebugName	= "Wheel"

if CLIENT then return end -- No more client

-- As motor constraints can't have their initial torque updated,
-- we always create it with 1000 initial torque (needs to be > friction) and then Scale it with a multiplier
local WHEEL_BASE_TORQUE = 1000

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	self.BaseTorque = 1
	self.Breaking = 0
	self.SpeedMod = 0
	self.Go = 0

	self.Inputs = Wire_CreateInputs(self, { "A: Go", "B: Break", "C: SpeedMod" })
end

function ENT:Setup(fwd, bck, stop, torque, direction, axis)
	self.fwd = fwd
	self.bck = bck
	self.stop = stop
	if torque then self:SetTorque(math.max(1, torque)) end
	if direction then self:SetDirection( direction ) end
	if axis then self.Axis = axis end

	self:UpdateOverlayText()
end

function ENT:UpdateOverlayText(speed)
	local motor = self:GetMotor()
	local friction = 0
	if IsValid(motor) then friction = motor.friction end
	self:SetOverlayText(
		"Torque: " .. math.floor( self.BaseTorque ) ..
		"\nFriction: " .. friction ..
		"\nSpeed: " .. (speed or 0) ..
		"\nBreak: " .. self.Breaking ..
		"\nSpeedMod: " .. math.floor( self.SpeedMod * 100 ) .. "%" )
end

function ENT:SetAxis( vec )
	self.Axis = self:GetPos() + vec * 512
	self.Axis = self:NearestPoint( self.Axis )
	self.Axis = self:WorldToLocal( self.Axis )
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:SetMotor( Motor )
	self.Motor = Motor
	self:UpdateOverlayText()
end

function ENT:GetMotor()
	if not self.Motor then
		self.Motor = constraint.FindConstraintEntity( self, "Motor" )
		if not IsValid(self.Motor) then
			self.Motor = nil
		end
	end
	return self.Motor
end

function ENT:SetDirection( dir )
	self:SetNWInt( 1, dir )
	self.direction = dir
end

function ENT:Forward( mul )
	if not self:IsValid() then return false end
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return false end

	mul = mul or 1
	local mdir = Motor.direction
	local Speed = mdir * mul * (self.BaseTorque / WHEEL_BASE_TORQUE) * (1 + self.SpeedMod)

	self:UpdateOverlayText(mul ~= 0 and (mdir * mul * (1 + self.SpeedMod)) or 0)

	Motor:Fire( "Scale", Speed, 0 )
	Motor:GetTable().forcescale = Speed
	Motor:Fire( "Activate", "" , 0 )

	return true
end

function ENT:TriggerInput(iname, value)
	if (iname == "A: Go") then
		if ( value == self.fwd ) then self.Go = 1
		elseif ( value == self.bck ) then self.Go = -1
		elseif ( value == self.stop ) then self.Go =0 end
	elseif (iname == "B: Break") then
		self.Breaking = value
	elseif (iname == "C: SpeedMod") then
		self.SpeedMod = (value / 100)
	end
	self:Forward( self.Go )
end


--[[---------------------------------------------------------
   Name: PhysicsUpdate
   Desc: happy fun time breaking function
---------------------------------------------------------]]
function ENT:PhysicsUpdate( physobj )
	local vel = physobj:GetVelocity()

	if (self.Breaking > 0) then -- to prevent badness
		if (self.Breaking >= 100) then --100% breaking!!!
			vel.x = 0 --full stop!
			vel.y = 0
		else
			vel.x = vel.x * ((100.0 - self.Breaking)/100.0)
			vel.y = vel.y * ((100.0 - self.Breaking)/100.0)
		end
	else
		return -- physobj:SetVelocity(physobj:GetVelocity()) will create constant acceleration
	end

	physobj:SetVelocity(vel)
end

function ENT:SetTorque( torque )
	self.BaseTorque = torque

	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end
	Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (torque / WHEEL_BASE_TORQUE), 0 )

	self:UpdateOverlayText()
end

--[[---------------------------------------------------------
   Creates the direction arrows on the wheel
---------------------------------------------------------]]
function ENT:DoDirectionEffect()
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( self.Axis )
		effectdata:SetEntity( self )
		effectdata:SetScale( Motor.direction )
	util.Effect( "wheel_indicator", effectdata, true, true )
end

--[[---------------------------------------------------------
   Reverse the wheel direction when a player uses the wheel
---------------------------------------------------------]]
function ENT:Use( activator, caller, type, value )
	local Motor = self:GetMotor()
	local Owner = self:GetPlayer()

	if (Motor and (Owner == nil or Owner == activator)) then
		if (Motor:GetTable().direction == 1) then
			Motor:GetTable().direction = -1
		else
			Motor:GetTable().direction = 1
		end

		Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (self.BaseTorque / WHEEL_BASE_TORQUE), 0 )
		self:SetDirection( Motor:GetTable().direction )

		self:DoDirectionEffect()
	end
end

duplicator.RegisterEntityClass("gmod_wire_wheel", WireLib.MakeWireEnt, "Data", "fwd", "bck", "stop", "BaseTorque", "direction", "Axis")

function ENT:SetWheelBase(Base)
	Base:DeleteOnRemove( self )
	self.Base = Base
end

function ENT:BuildDupeInfo()
	local info = BaseClass.BuildDupeInfo(self) or {}
	if IsValid(self.Base) then
		info.Base = self.Base:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID)

	local Base = GetEntByID(info.Base)
	if IsValid(Base) then
		self:SetWheelBase(Base)
	end
	self:UpdateOverlayText()
end


-- "addons\\wiremod\\lua\\entities\\gmod_wire_wheel.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Wheel"
ENT.WireDebugName	= "Wheel"

if CLIENT then return end -- No more client

-- As motor constraints can't have their initial torque updated,
-- we always create it with 1000 initial torque (needs to be > friction) and then Scale it with a multiplier
local WHEEL_BASE_TORQUE = 1000

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	self.BaseTorque = 1
	self.Breaking = 0
	self.SpeedMod = 0
	self.Go = 0

	self.Inputs = Wire_CreateInputs(self, { "A: Go", "B: Break", "C: SpeedMod" })
end

function ENT:Setup(fwd, bck, stop, torque, direction, axis)
	self.fwd = fwd
	self.bck = bck
	self.stop = stop
	if torque then self:SetTorque(math.max(1, torque)) end
	if direction then self:SetDirection( direction ) end
	if axis then self.Axis = axis end

	self:UpdateOverlayText()
end

function ENT:UpdateOverlayText(speed)
	local motor = self:GetMotor()
	local friction = 0
	if IsValid(motor) then friction = motor.friction end
	self:SetOverlayText(
		"Torque: " .. math.floor( self.BaseTorque ) ..
		"\nFriction: " .. friction ..
		"\nSpeed: " .. (speed or 0) ..
		"\nBreak: " .. self.Breaking ..
		"\nSpeedMod: " .. math.floor( self.SpeedMod * 100 ) .. "%" )
end

function ENT:SetAxis( vec )
	self.Axis = self:GetPos() + vec * 512
	self.Axis = self:NearestPoint( self.Axis )
	self.Axis = self:WorldToLocal( self.Axis )
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:SetMotor( Motor )
	self.Motor = Motor
	self:UpdateOverlayText()
end

function ENT:GetMotor()
	if not self.Motor then
		self.Motor = constraint.FindConstraintEntity( self, "Motor" )
		if not IsValid(self.Motor) then
			self.Motor = nil
		end
	end
	return self.Motor
end

function ENT:SetDirection( dir )
	self:SetNWInt( 1, dir )
	self.direction = dir
end

function ENT:Forward( mul )
	if not self:IsValid() then return false end
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return false end

	mul = mul or 1
	local mdir = Motor.direction
	local Speed = mdir * mul * (self.BaseTorque / WHEEL_BASE_TORQUE) * (1 + self.SpeedMod)

	self:UpdateOverlayText(mul ~= 0 and (mdir * mul * (1 + self.SpeedMod)) or 0)

	Motor:Fire( "Scale", Speed, 0 )
	Motor:GetTable().forcescale = Speed
	Motor:Fire( "Activate", "" , 0 )

	return true
end

function ENT:TriggerInput(iname, value)
	if (iname == "A: Go") then
		if ( value == self.fwd ) then self.Go = 1
		elseif ( value == self.bck ) then self.Go = -1
		elseif ( value == self.stop ) then self.Go =0 end
	elseif (iname == "B: Break") then
		self.Breaking = value
	elseif (iname == "C: SpeedMod") then
		self.SpeedMod = (value / 100)
	end
	self:Forward( self.Go )
end


--[[---------------------------------------------------------
   Name: PhysicsUpdate
   Desc: happy fun time breaking function
---------------------------------------------------------]]
function ENT:PhysicsUpdate( physobj )
	local vel = physobj:GetVelocity()

	if (self.Breaking > 0) then -- to prevent badness
		if (self.Breaking >= 100) then --100% breaking!!!
			vel.x = 0 --full stop!
			vel.y = 0
		else
			vel.x = vel.x * ((100.0 - self.Breaking)/100.0)
			vel.y = vel.y * ((100.0 - self.Breaking)/100.0)
		end
	else
		return -- physobj:SetVelocity(physobj:GetVelocity()) will create constant acceleration
	end

	physobj:SetVelocity(vel)
end

function ENT:SetTorque( torque )
	self.BaseTorque = torque

	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end
	Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (torque / WHEEL_BASE_TORQUE), 0 )

	self:UpdateOverlayText()
end

--[[---------------------------------------------------------
   Creates the direction arrows on the wheel
---------------------------------------------------------]]
function ENT:DoDirectionEffect()
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( self.Axis )
		effectdata:SetEntity( self )
		effectdata:SetScale( Motor.direction )
	util.Effect( "wheel_indicator", effectdata, true, true )
end

--[[---------------------------------------------------------
   Reverse the wheel direction when a player uses the wheel
---------------------------------------------------------]]
function ENT:Use( activator, caller, type, value )
	local Motor = self:GetMotor()
	local Owner = self:GetPlayer()

	if (Motor and (Owner == nil or Owner == activator)) then
		if (Motor:GetTable().direction == 1) then
			Motor:GetTable().direction = -1
		else
			Motor:GetTable().direction = 1
		end

		Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (self.BaseTorque / WHEEL_BASE_TORQUE), 0 )
		self:SetDirection( Motor:GetTable().direction )

		self:DoDirectionEffect()
	end
end

duplicator.RegisterEntityClass("gmod_wire_wheel", WireLib.MakeWireEnt, "Data", "fwd", "bck", "stop", "BaseTorque", "direction", "Axis")

function ENT:SetWheelBase(Base)
	Base:DeleteOnRemove( self )
	self.Base = Base
end

function ENT:BuildDupeInfo()
	local info = BaseClass.BuildDupeInfo(self) or {}
	if IsValid(self.Base) then
		info.Base = self.Base:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID)

	local Base = GetEntByID(info.Base)
	if IsValid(Base) then
		self:SetWheelBase(Base)
	end
	self:UpdateOverlayText()
end


-- "addons\\wiremod\\lua\\entities\\gmod_wire_wheel.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Wheel"
ENT.WireDebugName	= "Wheel"

if CLIENT then return end -- No more client

-- As motor constraints can't have their initial torque updated,
-- we always create it with 1000 initial torque (needs to be > friction) and then Scale it with a multiplier
local WHEEL_BASE_TORQUE = 1000

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	self.BaseTorque = 1
	self.Breaking = 0
	self.SpeedMod = 0
	self.Go = 0

	self.Inputs = Wire_CreateInputs(self, { "A: Go", "B: Break", "C: SpeedMod" })
end

function ENT:Setup(fwd, bck, stop, torque, direction, axis)
	self.fwd = fwd
	self.bck = bck
	self.stop = stop
	if torque then self:SetTorque(math.max(1, torque)) end
	if direction then self:SetDirection( direction ) end
	if axis then self.Axis = axis end

	self:UpdateOverlayText()
end

function ENT:UpdateOverlayText(speed)
	local motor = self:GetMotor()
	local friction = 0
	if IsValid(motor) then friction = motor.friction end
	self:SetOverlayText(
		"Torque: " .. math.floor( self.BaseTorque ) ..
		"\nFriction: " .. friction ..
		"\nSpeed: " .. (speed or 0) ..
		"\nBreak: " .. self.Breaking ..
		"\nSpeedMod: " .. math.floor( self.SpeedMod * 100 ) .. "%" )
end

function ENT:SetAxis( vec )
	self.Axis = self:GetPos() + vec * 512
	self.Axis = self:NearestPoint( self.Axis )
	self.Axis = self:WorldToLocal( self.Axis )
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:SetMotor( Motor )
	self.Motor = Motor
	self:UpdateOverlayText()
end

function ENT:GetMotor()
	if not self.Motor then
		self.Motor = constraint.FindConstraintEntity( self, "Motor" )
		if not IsValid(self.Motor) then
			self.Motor = nil
		end
	end
	return self.Motor
end

function ENT:SetDirection( dir )
	self:SetNWInt( 1, dir )
	self.direction = dir
end

function ENT:Forward( mul )
	if not self:IsValid() then return false end
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return false end

	mul = mul or 1
	local mdir = Motor.direction
	local Speed = mdir * mul * (self.BaseTorque / WHEEL_BASE_TORQUE) * (1 + self.SpeedMod)

	self:UpdateOverlayText(mul ~= 0 and (mdir * mul * (1 + self.SpeedMod)) or 0)

	Motor:Fire( "Scale", Speed, 0 )
	Motor:GetTable().forcescale = Speed
	Motor:Fire( "Activate", "" , 0 )

	return true
end

function ENT:TriggerInput(iname, value)
	if (iname == "A: Go") then
		if ( value == self.fwd ) then self.Go = 1
		elseif ( value == self.bck ) then self.Go = -1
		elseif ( value == self.stop ) then self.Go =0 end
	elseif (iname == "B: Break") then
		self.Breaking = value
	elseif (iname == "C: SpeedMod") then
		self.SpeedMod = (value / 100)
	end
	self:Forward( self.Go )
end


--[[---------------------------------------------------------
   Name: PhysicsUpdate
   Desc: happy fun time breaking function
---------------------------------------------------------]]
function ENT:PhysicsUpdate( physobj )
	local vel = physobj:GetVelocity()

	if (self.Breaking > 0) then -- to prevent badness
		if (self.Breaking >= 100) then --100% breaking!!!
			vel.x = 0 --full stop!
			vel.y = 0
		else
			vel.x = vel.x * ((100.0 - self.Breaking)/100.0)
			vel.y = vel.y * ((100.0 - self.Breaking)/100.0)
		end
	else
		return -- physobj:SetVelocity(physobj:GetVelocity()) will create constant acceleration
	end

	physobj:SetVelocity(vel)
end

function ENT:SetTorque( torque )
	self.BaseTorque = torque

	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end
	Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (torque / WHEEL_BASE_TORQUE), 0 )

	self:UpdateOverlayText()
end

--[[---------------------------------------------------------
   Creates the direction arrows on the wheel
---------------------------------------------------------]]
function ENT:DoDirectionEffect()
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( self.Axis )
		effectdata:SetEntity( self )
		effectdata:SetScale( Motor.direction )
	util.Effect( "wheel_indicator", effectdata, true, true )
end

--[[---------------------------------------------------------
   Reverse the wheel direction when a player uses the wheel
---------------------------------------------------------]]
function ENT:Use( activator, caller, type, value )
	local Motor = self:GetMotor()
	local Owner = self:GetPlayer()

	if (Motor and (Owner == nil or Owner == activator)) then
		if (Motor:GetTable().direction == 1) then
			Motor:GetTable().direction = -1
		else
			Motor:GetTable().direction = 1
		end

		Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (self.BaseTorque / WHEEL_BASE_TORQUE), 0 )
		self:SetDirection( Motor:GetTable().direction )

		self:DoDirectionEffect()
	end
end

duplicator.RegisterEntityClass("gmod_wire_wheel", WireLib.MakeWireEnt, "Data", "fwd", "bck", "stop", "BaseTorque", "direction", "Axis")

function ENT:SetWheelBase(Base)
	Base:DeleteOnRemove( self )
	self.Base = Base
end

function ENT:BuildDupeInfo()
	local info = BaseClass.BuildDupeInfo(self) or {}
	if IsValid(self.Base) then
		info.Base = self.Base:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID)

	local Base = GetEntByID(info.Base)
	if IsValid(Base) then
		self:SetWheelBase(Base)
	end
	self:UpdateOverlayText()
end


-- "addons\\wiremod\\lua\\entities\\gmod_wire_wheel.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Wheel"
ENT.WireDebugName	= "Wheel"

if CLIENT then return end -- No more client

-- As motor constraints can't have their initial torque updated,
-- we always create it with 1000 initial torque (needs to be > friction) and then Scale it with a multiplier
local WHEEL_BASE_TORQUE = 1000

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	self.BaseTorque = 1
	self.Breaking = 0
	self.SpeedMod = 0
	self.Go = 0

	self.Inputs = Wire_CreateInputs(self, { "A: Go", "B: Break", "C: SpeedMod" })
end

function ENT:Setup(fwd, bck, stop, torque, direction, axis)
	self.fwd = fwd
	self.bck = bck
	self.stop = stop
	if torque then self:SetTorque(math.max(1, torque)) end
	if direction then self:SetDirection( direction ) end
	if axis then self.Axis = axis end

	self:UpdateOverlayText()
end

function ENT:UpdateOverlayText(speed)
	local motor = self:GetMotor()
	local friction = 0
	if IsValid(motor) then friction = motor.friction end
	self:SetOverlayText(
		"Torque: " .. math.floor( self.BaseTorque ) ..
		"\nFriction: " .. friction ..
		"\nSpeed: " .. (speed or 0) ..
		"\nBreak: " .. self.Breaking ..
		"\nSpeedMod: " .. math.floor( self.SpeedMod * 100 ) .. "%" )
end

function ENT:SetAxis( vec )
	self.Axis = self:GetPos() + vec * 512
	self.Axis = self:NearestPoint( self.Axis )
	self.Axis = self:WorldToLocal( self.Axis )
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:SetMotor( Motor )
	self.Motor = Motor
	self:UpdateOverlayText()
end

function ENT:GetMotor()
	if not self.Motor then
		self.Motor = constraint.FindConstraintEntity( self, "Motor" )
		if not IsValid(self.Motor) then
			self.Motor = nil
		end
	end
	return self.Motor
end

function ENT:SetDirection( dir )
	self:SetNWInt( 1, dir )
	self.direction = dir
end

function ENT:Forward( mul )
	if not self:IsValid() then return false end
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return false end

	mul = mul or 1
	local mdir = Motor.direction
	local Speed = mdir * mul * (self.BaseTorque / WHEEL_BASE_TORQUE) * (1 + self.SpeedMod)

	self:UpdateOverlayText(mul ~= 0 and (mdir * mul * (1 + self.SpeedMod)) or 0)

	Motor:Fire( "Scale", Speed, 0 )
	Motor:GetTable().forcescale = Speed
	Motor:Fire( "Activate", "" , 0 )

	return true
end

function ENT:TriggerInput(iname, value)
	if (iname == "A: Go") then
		if ( value == self.fwd ) then self.Go = 1
		elseif ( value == self.bck ) then self.Go = -1
		elseif ( value == self.stop ) then self.Go =0 end
	elseif (iname == "B: Break") then
		self.Breaking = value
	elseif (iname == "C: SpeedMod") then
		self.SpeedMod = (value / 100)
	end
	self:Forward( self.Go )
end


--[[---------------------------------------------------------
   Name: PhysicsUpdate
   Desc: happy fun time breaking function
---------------------------------------------------------]]
function ENT:PhysicsUpdate( physobj )
	local vel = physobj:GetVelocity()

	if (self.Breaking > 0) then -- to prevent badness
		if (self.Breaking >= 100) then --100% breaking!!!
			vel.x = 0 --full stop!
			vel.y = 0
		else
			vel.x = vel.x * ((100.0 - self.Breaking)/100.0)
			vel.y = vel.y * ((100.0 - self.Breaking)/100.0)
		end
	else
		return -- physobj:SetVelocity(physobj:GetVelocity()) will create constant acceleration
	end

	physobj:SetVelocity(vel)
end

function ENT:SetTorque( torque )
	self.BaseTorque = torque

	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end
	Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (torque / WHEEL_BASE_TORQUE), 0 )

	self:UpdateOverlayText()
end

--[[---------------------------------------------------------
   Creates the direction arrows on the wheel
---------------------------------------------------------]]
function ENT:DoDirectionEffect()
	local Motor = self:GetMotor()
	if not IsValid(Motor) then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( self.Axis )
		effectdata:SetEntity( self )
		effectdata:SetScale( Motor.direction )
	util.Effect( "wheel_indicator", effectdata, true, true )
end

--[[---------------------------------------------------------
   Reverse the wheel direction when a player uses the wheel
---------------------------------------------------------]]
function ENT:Use( activator, caller, type, value )
	local Motor = self:GetMotor()
	local Owner = self:GetPlayer()

	if (Motor and (Owner == nil or Owner == activator)) then
		if (Motor:GetTable().direction == 1) then
			Motor:GetTable().direction = -1
		else
			Motor:GetTable().direction = 1
		end

		Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * (self.BaseTorque / WHEEL_BASE_TORQUE), 0 )
		self:SetDirection( Motor:GetTable().direction )

		self:DoDirectionEffect()
	end
end

duplicator.RegisterEntityClass("gmod_wire_wheel", WireLib.MakeWireEnt, "Data", "fwd", "bck", "stop", "BaseTorque", "direction", "Axis")

function ENT:SetWheelBase(Base)
	Base:DeleteOnRemove( self )
	self.Base = Base
end

function ENT:BuildDupeInfo()
	local info = BaseClass.BuildDupeInfo(self) or {}
	if IsValid(self.Base) then
		info.Base = self.Base:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID)

	local Base = GetEntByID(info.Base)
	if IsValid(Base) then
		self:SetWheelBase(Base)
	end
	self:UpdateOverlayText()
end


