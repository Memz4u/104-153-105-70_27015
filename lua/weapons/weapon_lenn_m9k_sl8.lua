-- "lua\\weapons\\weapon_lenn_m9k_sl8.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 5;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;

end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Your Regular Sl8";
   SWEP.Slot = 0;
   SWEP.SlotPos = 1;
   SWEP.DrawAmmo = false;
   SWEP.DrawCrosshair = false;
 
end

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;
SWEP.AdminOnly		= true
SWEP.Category = "Lenn's Weapons (ADMINS STUFF)"
SWEP.IconLetter                = "b"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= true
SWEP.ViewModel				= "models/weapons/v_hk_sl8.mdl"
SWEP.WorldModel				= "models/weapons/w_hk_sl8.mdl"
SWEP.UseHands 						= true

SWEP.HoldType                = "rpg"

SWEP.Primary.ClipSize        = 99999
SWEP.Primary.DefaultClip    = 99999
SWEP.Primary.Delay            = 0.2
SWEP.Primary.Automatic        = true
SWEP.Primary.Ammo            = "ar2"

SWEP.CSMuzzleFlashes = true


SWEP.Primary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Primary.Damage            = 60
SWEP.Primary.NumShots        = 1
SWEP.Primary.Spread = 35
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0

SWEP.Secondary.ClipSize        = 99999
SWEP.Secondary.DefaultClip    = 99999
SWEP.Secondary.Delay            = 0.05
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo            = "ar2"



SWEP.Secondary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Secondary.Damage            = 60
SWEP.Secondary.NumShots        = 5
SWEP.Secondary.Spread = 35
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Cone = 0



SWEP.IronSightsPos = Vector(5.2, 0, 1.16)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SightsPos = Vector(5.2, 0, 1.16)
SWEP.SightsAng = Vector(0, 0, 0)
SWEP.RunSightsPos = Vector (-2.3095, -3.0514, 2.3965)
SWEP.RunSightsAng = Vector (-19.8471, -33.9181, 10)

function SWEP:Initialize()

    if CLIENT then
	surface.CreateFont( "Arial",
	{
	font = "Arial",
	size = ScreenScale(10),
	weight = 400
	})   
                  killicon.Add( "weapon_lenn_m9k_sl8", "vgui/hud/m9k_sl8", Color( 255, 255, 255, 255 ) )
 	

    end
	self:SetHoldType(self.HoldType)
	
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
self.Weapon:SetNWBool("Reloading", false)
end

function SWEP:SecondaryAttack()
if self.On != true then
self.On = true
else
self.On = false
end
end
SWEP.Aimbot = {}
SWEP.Aimbot.Target = nil
SWEP.Aimbot.DeathSequences = {
    ["models/barnacle.mdl"]            = {4,15},
    ["models/antlion_guard.mdl"]    = {44},
    ["models/hunter.mdl"]            = {124,125,126,127,128},
}

function SWEP:GetHeadPos(ent)
    local model = ent:GetModel() or ""
    if model:find("crow") or model:find("seagull") or model:find("pigeon") then
        return ent:LocalToWorld(ent:OBBCenter() + Vector(0,0,-5))
    elseif ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
        return ent:GetAttachment(ent:LookupAttachment("eyes")).Pos
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

function SWEP:Visible(ent)
    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = self:GetHeadPos(ent)
    trace.filter = {self.Owner,ent}
    trace.mask = MASK_SHOT
    local tr = util.TraceLine(trace)
    return tr.Fraction >= 0.1 and true or false
end

function SWEP:CheckTarget(ent)
    if ent:IsPlayer() then
        if !ent:IsValid() then return false end
        if ent:Health() < 1 then return false end
        if ent == self.Owner then return false end    
        return true
    end
    if ent:IsNPC() then
        if ent:GetMoveType() == 0 then return false end
        if table.HasValue(self.Aimbot.DeathSequences[string.lower(ent:GetModel() or "")] or {},ent:GetSequence()) then return false end
        return true
    end
    return false
end

function SWEP:GetTargets()
    local tbl = {}
    for k,ent in pairs(ents.GetAll()) do
        if self:CheckTarget(ent) == true then
            table.insert(tbl,ent)
        end
    end
    return tbl
end

function SWEP:GetClosestTarget()
    local pos = self.Owner:GetPos()
    local ang = self.Owner:GetAimVector()
    local closest = {0,0}
    for k,ent in pairs(self:GetTargets()) do
        local diff = (ent:GetPos()-pos)
		diff:Normalize()
        diff = diff - ang
        diff = diff:Length()
        diff = math.abs(diff)
        if (diff < closest[2]) or (closest[1] == 0) then
            closest = {ent,diff}
        end
    end
    return closest[1]
end

function SWEP:Think()
    local ent = self:GetClosestTarget()
    self.Aimbot.Target = ent ~= 0 and ent or nil
	


hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
if self.On == true then
        return true
    end
end)
end


function SWEP:OnRemove()
self.On = false
timer.Remove("aimbotspin")

end
function SWEP:Holster()
self.On = false
timer.Remove("aimbotspin")
return true
end



function SWEP:PrimaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Primary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Primary.Spread * 0.8, self.Primary.Spread * 0.8, 0.8)
    bullet.Tracer = 1
    bullet.Force = 5
    bullet.Damage = self.Primary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanPrimaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self.Weapon:EmitSound(self.Primary.Sound)

    self:TakePrimaryAmmo(1) 
end

function SWEP:SecondaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Secondary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Secondary.Spread * 0.8, self.Secondary.Spread * 0.8, 0.8)
    bullet.Tracer = 4
    bullet.Force = 5
    bullet.Damage = self.Secondary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanSecondaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    self.Weapon:EmitSound(self.Secondary.Sound)

    self:TakeSecondaryAmmo(1) 
end


function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
	
    draw.SimpleText("Fucking Whiffer Sniffer","Arial",x + wide/2,y + tall*0.35,Color(255,0,0,255),TEXT_ALIGN_CENTER)
end

function SWEP:DrawRotatingCrosshair(x,y,time,length,gap)
    surface.DrawLine(
        x + (math.sin(math.rad(time)) * length),
        y + (math.cos(math.rad(time)) * length),
        x + (math.sin(math.rad(time)) * gap),
        y + (math.cos(math.rad(time)) * gap)
    )
end

function SWEP:GetCoordiantes(ent)
    local min,max = ent:OBBMins(),ent:OBBMaxs()
    local corners = {
        Vector(min.x,min.y,min.z),
        Vector(min.x,min.y,max.z),
        Vector(min.x,max.y,min.z),
        Vector(min.x,max.y,max.z),
        Vector(max.x,min.y,min.z),
        Vector(max.x,min.y,max.z),
        Vector(max.x,max.y,min.z),
        Vector(max.x,max.y,max.z)
    }

    local minx,miny,maxx,maxy = ScrW() * 2,ScrH() * 2,0,0
    for _,corner in pairs(corners) do
        local screen = ent:LocalToWorld(corner):ToScreen()
        minx,miny = math.min(minx,screen.x),math.min(miny,screen.y)
        maxx,maxy = math.max(maxx,screen.x),math.max(maxy,screen.y)
    end
    return minx,miny,maxx,maxy
end

-- "lua\\weapons\\weapon_lenn_m9k_sl8.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 5;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;

end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Your Regular Sl8";
   SWEP.Slot = 0;
   SWEP.SlotPos = 1;
   SWEP.DrawAmmo = false;
   SWEP.DrawCrosshair = false;
 
end

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;
SWEP.AdminOnly		= true
SWEP.Category = "Lenn's Weapons (ADMINS STUFF)"
SWEP.IconLetter                = "b"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= true
SWEP.ViewModel				= "models/weapons/v_hk_sl8.mdl"
SWEP.WorldModel				= "models/weapons/w_hk_sl8.mdl"
SWEP.UseHands 						= true

SWEP.HoldType                = "rpg"

SWEP.Primary.ClipSize        = 99999
SWEP.Primary.DefaultClip    = 99999
SWEP.Primary.Delay            = 0.2
SWEP.Primary.Automatic        = true
SWEP.Primary.Ammo            = "ar2"

SWEP.CSMuzzleFlashes = true


SWEP.Primary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Primary.Damage            = 60
SWEP.Primary.NumShots        = 1
SWEP.Primary.Spread = 35
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0

SWEP.Secondary.ClipSize        = 99999
SWEP.Secondary.DefaultClip    = 99999
SWEP.Secondary.Delay            = 0.05
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo            = "ar2"



SWEP.Secondary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Secondary.Damage            = 60
SWEP.Secondary.NumShots        = 5
SWEP.Secondary.Spread = 35
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Cone = 0



SWEP.IronSightsPos = Vector(5.2, 0, 1.16)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SightsPos = Vector(5.2, 0, 1.16)
SWEP.SightsAng = Vector(0, 0, 0)
SWEP.RunSightsPos = Vector (-2.3095, -3.0514, 2.3965)
SWEP.RunSightsAng = Vector (-19.8471, -33.9181, 10)

function SWEP:Initialize()

    if CLIENT then
	surface.CreateFont( "Arial",
	{
	font = "Arial",
	size = ScreenScale(10),
	weight = 400
	})   
                  killicon.Add( "weapon_lenn_m9k_sl8", "vgui/hud/m9k_sl8", Color( 255, 255, 255, 255 ) )
 	

    end
	self:SetHoldType(self.HoldType)
	
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
self.Weapon:SetNWBool("Reloading", false)
end

function SWEP:SecondaryAttack()
if self.On != true then
self.On = true
else
self.On = false
end
end
SWEP.Aimbot = {}
SWEP.Aimbot.Target = nil
SWEP.Aimbot.DeathSequences = {
    ["models/barnacle.mdl"]            = {4,15},
    ["models/antlion_guard.mdl"]    = {44},
    ["models/hunter.mdl"]            = {124,125,126,127,128},
}

function SWEP:GetHeadPos(ent)
    local model = ent:GetModel() or ""
    if model:find("crow") or model:find("seagull") or model:find("pigeon") then
        return ent:LocalToWorld(ent:OBBCenter() + Vector(0,0,-5))
    elseif ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
        return ent:GetAttachment(ent:LookupAttachment("eyes")).Pos
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

function SWEP:Visible(ent)
    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = self:GetHeadPos(ent)
    trace.filter = {self.Owner,ent}
    trace.mask = MASK_SHOT
    local tr = util.TraceLine(trace)
    return tr.Fraction >= 0.1 and true or false
end

function SWEP:CheckTarget(ent)
    if ent:IsPlayer() then
        if !ent:IsValid() then return false end
        if ent:Health() < 1 then return false end
        if ent == self.Owner then return false end    
        return true
    end
    if ent:IsNPC() then
        if ent:GetMoveType() == 0 then return false end
        if table.HasValue(self.Aimbot.DeathSequences[string.lower(ent:GetModel() or "")] or {},ent:GetSequence()) then return false end
        return true
    end
    return false
end

function SWEP:GetTargets()
    local tbl = {}
    for k,ent in pairs(ents.GetAll()) do
        if self:CheckTarget(ent) == true then
            table.insert(tbl,ent)
        end
    end
    return tbl
end

function SWEP:GetClosestTarget()
    local pos = self.Owner:GetPos()
    local ang = self.Owner:GetAimVector()
    local closest = {0,0}
    for k,ent in pairs(self:GetTargets()) do
        local diff = (ent:GetPos()-pos)
		diff:Normalize()
        diff = diff - ang
        diff = diff:Length()
        diff = math.abs(diff)
        if (diff < closest[2]) or (closest[1] == 0) then
            closest = {ent,diff}
        end
    end
    return closest[1]
end

function SWEP:Think()
    local ent = self:GetClosestTarget()
    self.Aimbot.Target = ent ~= 0 and ent or nil
	


hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
if self.On == true then
        return true
    end
end)
end


function SWEP:OnRemove()
self.On = false
timer.Remove("aimbotspin")

end
function SWEP:Holster()
self.On = false
timer.Remove("aimbotspin")
return true
end



function SWEP:PrimaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Primary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Primary.Spread * 0.8, self.Primary.Spread * 0.8, 0.8)
    bullet.Tracer = 1
    bullet.Force = 5
    bullet.Damage = self.Primary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanPrimaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self.Weapon:EmitSound(self.Primary.Sound)

    self:TakePrimaryAmmo(1) 
end

function SWEP:SecondaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Secondary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Secondary.Spread * 0.8, self.Secondary.Spread * 0.8, 0.8)
    bullet.Tracer = 4
    bullet.Force = 5
    bullet.Damage = self.Secondary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanSecondaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    self.Weapon:EmitSound(self.Secondary.Sound)

    self:TakeSecondaryAmmo(1) 
end


function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
	
    draw.SimpleText("Fucking Whiffer Sniffer","Arial",x + wide/2,y + tall*0.35,Color(255,0,0,255),TEXT_ALIGN_CENTER)
end

function SWEP:DrawRotatingCrosshair(x,y,time,length,gap)
    surface.DrawLine(
        x + (math.sin(math.rad(time)) * length),
        y + (math.cos(math.rad(time)) * length),
        x + (math.sin(math.rad(time)) * gap),
        y + (math.cos(math.rad(time)) * gap)
    )
end

function SWEP:GetCoordiantes(ent)
    local min,max = ent:OBBMins(),ent:OBBMaxs()
    local corners = {
        Vector(min.x,min.y,min.z),
        Vector(min.x,min.y,max.z),
        Vector(min.x,max.y,min.z),
        Vector(min.x,max.y,max.z),
        Vector(max.x,min.y,min.z),
        Vector(max.x,min.y,max.z),
        Vector(max.x,max.y,min.z),
        Vector(max.x,max.y,max.z)
    }

    local minx,miny,maxx,maxy = ScrW() * 2,ScrH() * 2,0,0
    for _,corner in pairs(corners) do
        local screen = ent:LocalToWorld(corner):ToScreen()
        minx,miny = math.min(minx,screen.x),math.min(miny,screen.y)
        maxx,maxy = math.max(maxx,screen.x),math.max(maxy,screen.y)
    end
    return minx,miny,maxx,maxy
end

-- "lua\\weapons\\weapon_lenn_m9k_sl8.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 5;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;

end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Your Regular Sl8";
   SWEP.Slot = 0;
   SWEP.SlotPos = 1;
   SWEP.DrawAmmo = false;
   SWEP.DrawCrosshair = false;
 
end

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;
SWEP.AdminOnly		= true
SWEP.Category = "Lenn's Weapons (ADMINS STUFF)"
SWEP.IconLetter                = "b"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= true
SWEP.ViewModel				= "models/weapons/v_hk_sl8.mdl"
SWEP.WorldModel				= "models/weapons/w_hk_sl8.mdl"
SWEP.UseHands 						= true

SWEP.HoldType                = "rpg"

SWEP.Primary.ClipSize        = 99999
SWEP.Primary.DefaultClip    = 99999
SWEP.Primary.Delay            = 0.2
SWEP.Primary.Automatic        = true
SWEP.Primary.Ammo            = "ar2"

SWEP.CSMuzzleFlashes = true


SWEP.Primary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Primary.Damage            = 60
SWEP.Primary.NumShots        = 1
SWEP.Primary.Spread = 35
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0

SWEP.Secondary.ClipSize        = 99999
SWEP.Secondary.DefaultClip    = 99999
SWEP.Secondary.Delay            = 0.05
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo            = "ar2"



SWEP.Secondary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Secondary.Damage            = 60
SWEP.Secondary.NumShots        = 5
SWEP.Secondary.Spread = 35
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Cone = 0



SWEP.IronSightsPos = Vector(5.2, 0, 1.16)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SightsPos = Vector(5.2, 0, 1.16)
SWEP.SightsAng = Vector(0, 0, 0)
SWEP.RunSightsPos = Vector (-2.3095, -3.0514, 2.3965)
SWEP.RunSightsAng = Vector (-19.8471, -33.9181, 10)

function SWEP:Initialize()

    if CLIENT then
	surface.CreateFont( "Arial",
	{
	font = "Arial",
	size = ScreenScale(10),
	weight = 400
	})   
                  killicon.Add( "weapon_lenn_m9k_sl8", "vgui/hud/m9k_sl8", Color( 255, 255, 255, 255 ) )
 	

    end
	self:SetHoldType(self.HoldType)
	
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
self.Weapon:SetNWBool("Reloading", false)
end

function SWEP:SecondaryAttack()
if self.On != true then
self.On = true
else
self.On = false
end
end
SWEP.Aimbot = {}
SWEP.Aimbot.Target = nil
SWEP.Aimbot.DeathSequences = {
    ["models/barnacle.mdl"]            = {4,15},
    ["models/antlion_guard.mdl"]    = {44},
    ["models/hunter.mdl"]            = {124,125,126,127,128},
}

function SWEP:GetHeadPos(ent)
    local model = ent:GetModel() or ""
    if model:find("crow") or model:find("seagull") or model:find("pigeon") then
        return ent:LocalToWorld(ent:OBBCenter() + Vector(0,0,-5))
    elseif ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
        return ent:GetAttachment(ent:LookupAttachment("eyes")).Pos
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

function SWEP:Visible(ent)
    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = self:GetHeadPos(ent)
    trace.filter = {self.Owner,ent}
    trace.mask = MASK_SHOT
    local tr = util.TraceLine(trace)
    return tr.Fraction >= 0.1 and true or false
end

function SWEP:CheckTarget(ent)
    if ent:IsPlayer() then
        if !ent:IsValid() then return false end
        if ent:Health() < 1 then return false end
        if ent == self.Owner then return false end    
        return true
    end
    if ent:IsNPC() then
        if ent:GetMoveType() == 0 then return false end
        if table.HasValue(self.Aimbot.DeathSequences[string.lower(ent:GetModel() or "")] or {},ent:GetSequence()) then return false end
        return true
    end
    return false
end

function SWEP:GetTargets()
    local tbl = {}
    for k,ent in pairs(ents.GetAll()) do
        if self:CheckTarget(ent) == true then
            table.insert(tbl,ent)
        end
    end
    return tbl
end

function SWEP:GetClosestTarget()
    local pos = self.Owner:GetPos()
    local ang = self.Owner:GetAimVector()
    local closest = {0,0}
    for k,ent in pairs(self:GetTargets()) do
        local diff = (ent:GetPos()-pos)
		diff:Normalize()
        diff = diff - ang
        diff = diff:Length()
        diff = math.abs(diff)
        if (diff < closest[2]) or (closest[1] == 0) then
            closest = {ent,diff}
        end
    end
    return closest[1]
end

function SWEP:Think()
    local ent = self:GetClosestTarget()
    self.Aimbot.Target = ent ~= 0 and ent or nil
	


hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
if self.On == true then
        return true
    end
end)
end


function SWEP:OnRemove()
self.On = false
timer.Remove("aimbotspin")

end
function SWEP:Holster()
self.On = false
timer.Remove("aimbotspin")
return true
end



function SWEP:PrimaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Primary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Primary.Spread * 0.8, self.Primary.Spread * 0.8, 0.8)
    bullet.Tracer = 1
    bullet.Force = 5
    bullet.Damage = self.Primary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanPrimaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self.Weapon:EmitSound(self.Primary.Sound)

    self:TakePrimaryAmmo(1) 
end

function SWEP:SecondaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Secondary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Secondary.Spread * 0.8, self.Secondary.Spread * 0.8, 0.8)
    bullet.Tracer = 4
    bullet.Force = 5
    bullet.Damage = self.Secondary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanSecondaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    self.Weapon:EmitSound(self.Secondary.Sound)

    self:TakeSecondaryAmmo(1) 
end


function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
	
    draw.SimpleText("Fucking Whiffer Sniffer","Arial",x + wide/2,y + tall*0.35,Color(255,0,0,255),TEXT_ALIGN_CENTER)
end

function SWEP:DrawRotatingCrosshair(x,y,time,length,gap)
    surface.DrawLine(
        x + (math.sin(math.rad(time)) * length),
        y + (math.cos(math.rad(time)) * length),
        x + (math.sin(math.rad(time)) * gap),
        y + (math.cos(math.rad(time)) * gap)
    )
end

function SWEP:GetCoordiantes(ent)
    local min,max = ent:OBBMins(),ent:OBBMaxs()
    local corners = {
        Vector(min.x,min.y,min.z),
        Vector(min.x,min.y,max.z),
        Vector(min.x,max.y,min.z),
        Vector(min.x,max.y,max.z),
        Vector(max.x,min.y,min.z),
        Vector(max.x,min.y,max.z),
        Vector(max.x,max.y,min.z),
        Vector(max.x,max.y,max.z)
    }

    local minx,miny,maxx,maxy = ScrW() * 2,ScrH() * 2,0,0
    for _,corner in pairs(corners) do
        local screen = ent:LocalToWorld(corner):ToScreen()
        minx,miny = math.min(minx,screen.x),math.min(miny,screen.y)
        maxx,maxy = math.max(maxx,screen.x),math.max(maxy,screen.y)
    end
    return minx,miny,maxx,maxy
end

-- "lua\\weapons\\weapon_lenn_m9k_sl8.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 5;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;

end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Your Regular Sl8";
   SWEP.Slot = 0;
   SWEP.SlotPos = 1;
   SWEP.DrawAmmo = false;
   SWEP.DrawCrosshair = false;
 
end

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;
SWEP.AdminOnly		= true
SWEP.Category = "Lenn's Weapons (ADMINS STUFF)"
SWEP.IconLetter                = "b"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= true
SWEP.ViewModel				= "models/weapons/v_hk_sl8.mdl"
SWEP.WorldModel				= "models/weapons/w_hk_sl8.mdl"
SWEP.UseHands 						= true

SWEP.HoldType                = "rpg"

SWEP.Primary.ClipSize        = 99999
SWEP.Primary.DefaultClip    = 99999
SWEP.Primary.Delay            = 0.2
SWEP.Primary.Automatic        = true
SWEP.Primary.Ammo            = "ar2"

SWEP.CSMuzzleFlashes = true


SWEP.Primary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Primary.Damage            = 60
SWEP.Primary.NumShots        = 1
SWEP.Primary.Spread = 35
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0

SWEP.Secondary.ClipSize        = 99999
SWEP.Secondary.DefaultClip    = 99999
SWEP.Secondary.Delay            = 0.05
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo            = "ar2"



SWEP.Secondary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Secondary.Damage            = 60
SWEP.Secondary.NumShots        = 5
SWEP.Secondary.Spread = 35
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Cone = 0



SWEP.IronSightsPos = Vector(5.2, 0, 1.16)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SightsPos = Vector(5.2, 0, 1.16)
SWEP.SightsAng = Vector(0, 0, 0)
SWEP.RunSightsPos = Vector (-2.3095, -3.0514, 2.3965)
SWEP.RunSightsAng = Vector (-19.8471, -33.9181, 10)

function SWEP:Initialize()

    if CLIENT then
	surface.CreateFont( "Arial",
	{
	font = "Arial",
	size = ScreenScale(10),
	weight = 400
	})   
                  killicon.Add( "weapon_lenn_m9k_sl8", "vgui/hud/m9k_sl8", Color( 255, 255, 255, 255 ) )
 	

    end
	self:SetHoldType(self.HoldType)
	
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
self.Weapon:SetNWBool("Reloading", false)
end

function SWEP:SecondaryAttack()
if self.On != true then
self.On = true
else
self.On = false
end
end
SWEP.Aimbot = {}
SWEP.Aimbot.Target = nil
SWEP.Aimbot.DeathSequences = {
    ["models/barnacle.mdl"]            = {4,15},
    ["models/antlion_guard.mdl"]    = {44},
    ["models/hunter.mdl"]            = {124,125,126,127,128},
}

function SWEP:GetHeadPos(ent)
    local model = ent:GetModel() or ""
    if model:find("crow") or model:find("seagull") or model:find("pigeon") then
        return ent:LocalToWorld(ent:OBBCenter() + Vector(0,0,-5))
    elseif ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
        return ent:GetAttachment(ent:LookupAttachment("eyes")).Pos
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

function SWEP:Visible(ent)
    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = self:GetHeadPos(ent)
    trace.filter = {self.Owner,ent}
    trace.mask = MASK_SHOT
    local tr = util.TraceLine(trace)
    return tr.Fraction >= 0.1 and true or false
end

function SWEP:CheckTarget(ent)
    if ent:IsPlayer() then
        if !ent:IsValid() then return false end
        if ent:Health() < 1 then return false end
        if ent == self.Owner then return false end    
        return true
    end
    if ent:IsNPC() then
        if ent:GetMoveType() == 0 then return false end
        if table.HasValue(self.Aimbot.DeathSequences[string.lower(ent:GetModel() or "")] or {},ent:GetSequence()) then return false end
        return true
    end
    return false
end

function SWEP:GetTargets()
    local tbl = {}
    for k,ent in pairs(ents.GetAll()) do
        if self:CheckTarget(ent) == true then
            table.insert(tbl,ent)
        end
    end
    return tbl
end

function SWEP:GetClosestTarget()
    local pos = self.Owner:GetPos()
    local ang = self.Owner:GetAimVector()
    local closest = {0,0}
    for k,ent in pairs(self:GetTargets()) do
        local diff = (ent:GetPos()-pos)
		diff:Normalize()
        diff = diff - ang
        diff = diff:Length()
        diff = math.abs(diff)
        if (diff < closest[2]) or (closest[1] == 0) then
            closest = {ent,diff}
        end
    end
    return closest[1]
end

function SWEP:Think()
    local ent = self:GetClosestTarget()
    self.Aimbot.Target = ent ~= 0 and ent or nil
	


hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
if self.On == true then
        return true
    end
end)
end


function SWEP:OnRemove()
self.On = false
timer.Remove("aimbotspin")

end
function SWEP:Holster()
self.On = false
timer.Remove("aimbotspin")
return true
end



function SWEP:PrimaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Primary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Primary.Spread * 0.8, self.Primary.Spread * 0.8, 0.8)
    bullet.Tracer = 1
    bullet.Force = 5
    bullet.Damage = self.Primary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanPrimaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self.Weapon:EmitSound(self.Primary.Sound)

    self:TakePrimaryAmmo(1) 
end

function SWEP:SecondaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Secondary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Secondary.Spread * 0.8, self.Secondary.Spread * 0.8, 0.8)
    bullet.Tracer = 4
    bullet.Force = 5
    bullet.Damage = self.Secondary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanSecondaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    self.Weapon:EmitSound(self.Secondary.Sound)

    self:TakeSecondaryAmmo(1) 
end


function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
	
    draw.SimpleText("Fucking Whiffer Sniffer","Arial",x + wide/2,y + tall*0.35,Color(255,0,0,255),TEXT_ALIGN_CENTER)
end

function SWEP:DrawRotatingCrosshair(x,y,time,length,gap)
    surface.DrawLine(
        x + (math.sin(math.rad(time)) * length),
        y + (math.cos(math.rad(time)) * length),
        x + (math.sin(math.rad(time)) * gap),
        y + (math.cos(math.rad(time)) * gap)
    )
end

function SWEP:GetCoordiantes(ent)
    local min,max = ent:OBBMins(),ent:OBBMaxs()
    local corners = {
        Vector(min.x,min.y,min.z),
        Vector(min.x,min.y,max.z),
        Vector(min.x,max.y,min.z),
        Vector(min.x,max.y,max.z),
        Vector(max.x,min.y,min.z),
        Vector(max.x,min.y,max.z),
        Vector(max.x,max.y,min.z),
        Vector(max.x,max.y,max.z)
    }

    local minx,miny,maxx,maxy = ScrW() * 2,ScrH() * 2,0,0
    for _,corner in pairs(corners) do
        local screen = ent:LocalToWorld(corner):ToScreen()
        minx,miny = math.min(minx,screen.x),math.min(miny,screen.y)
        maxx,maxy = math.max(maxx,screen.x),math.max(maxy,screen.y)
    end
    return minx,miny,maxx,maxy
end

-- "lua\\weapons\\weapon_lenn_m9k_sl8.lua"
-- Retrieved by https://github.com/c4fe/glua-steal
if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 5;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;

end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Your Regular Sl8";
   SWEP.Slot = 0;
   SWEP.SlotPos = 1;
   SWEP.DrawAmmo = false;
   SWEP.DrawCrosshair = false;
 
end

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;
SWEP.AdminOnly		= true
SWEP.Category = "Lenn's Weapons (ADMINS STUFF)"
SWEP.IconLetter                = "b"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= true
SWEP.ViewModel				= "models/weapons/v_hk_sl8.mdl"
SWEP.WorldModel				= "models/weapons/w_hk_sl8.mdl"
SWEP.UseHands 						= true

SWEP.HoldType                = "rpg"

SWEP.Primary.ClipSize        = 99999
SWEP.Primary.DefaultClip    = 99999
SWEP.Primary.Delay            = 0.2
SWEP.Primary.Automatic        = true
SWEP.Primary.Ammo            = "ar2"

SWEP.CSMuzzleFlashes = true


SWEP.Primary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Primary.Damage            = 60
SWEP.Primary.NumShots        = 1
SWEP.Primary.Spread = 35
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0

SWEP.Secondary.ClipSize        = 99999
SWEP.Secondary.DefaultClip    = 99999
SWEP.Secondary.Delay            = 0.05
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo            = "ar2"



SWEP.Secondary.Sound = Sound ("Weapon_hksl8.Single")
SWEP.Secondary.Damage            = 60
SWEP.Secondary.NumShots        = 5
SWEP.Secondary.Spread = 35
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Cone = 0



SWEP.IronSightsPos = Vector(5.2, 0, 1.16)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SightsPos = Vector(5.2, 0, 1.16)
SWEP.SightsAng = Vector(0, 0, 0)
SWEP.RunSightsPos = Vector (-2.3095, -3.0514, 2.3965)
SWEP.RunSightsAng = Vector (-19.8471, -33.9181, 10)

function SWEP:Initialize()

    if CLIENT then
	surface.CreateFont( "Arial",
	{
	font = "Arial",
	size = ScreenScale(10),
	weight = 400
	})   
                  killicon.Add( "weapon_lenn_m9k_sl8", "vgui/hud/m9k_sl8", Color( 255, 255, 255, 255 ) )
 	

    end
	self:SetHoldType(self.HoldType)
	
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
self.Weapon:SetNWBool("Reloading", false)
end

function SWEP:SecondaryAttack()
if self.On != true then
self.On = true
else
self.On = false
end
end
SWEP.Aimbot = {}
SWEP.Aimbot.Target = nil
SWEP.Aimbot.DeathSequences = {
    ["models/barnacle.mdl"]            = {4,15},
    ["models/antlion_guard.mdl"]    = {44},
    ["models/hunter.mdl"]            = {124,125,126,127,128},
}

function SWEP:GetHeadPos(ent)
    local model = ent:GetModel() or ""
    if model:find("crow") or model:find("seagull") or model:find("pigeon") then
        return ent:LocalToWorld(ent:OBBCenter() + Vector(0,0,-5))
    elseif ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
        return ent:GetAttachment(ent:LookupAttachment("eyes")).Pos
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

function SWEP:Visible(ent)
    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = self:GetHeadPos(ent)
    trace.filter = {self.Owner,ent}
    trace.mask = MASK_SHOT
    local tr = util.TraceLine(trace)
    return tr.Fraction >= 0.1 and true or false
end

function SWEP:CheckTarget(ent)
    if ent:IsPlayer() then
        if !ent:IsValid() then return false end
        if ent:Health() < 1 then return false end
        if ent == self.Owner then return false end    
        return true
    end
    if ent:IsNPC() then
        if ent:GetMoveType() == 0 then return false end
        if table.HasValue(self.Aimbot.DeathSequences[string.lower(ent:GetModel() or "")] or {},ent:GetSequence()) then return false end
        return true
    end
    return false
end

function SWEP:GetTargets()
    local tbl = {}
    for k,ent in pairs(ents.GetAll()) do
        if self:CheckTarget(ent) == true then
            table.insert(tbl,ent)
        end
    end
    return tbl
end

function SWEP:GetClosestTarget()
    local pos = self.Owner:GetPos()
    local ang = self.Owner:GetAimVector()
    local closest = {0,0}
    for k,ent in pairs(self:GetTargets()) do
        local diff = (ent:GetPos()-pos)
		diff:Normalize()
        diff = diff - ang
        diff = diff:Length()
        diff = math.abs(diff)
        if (diff < closest[2]) or (closest[1] == 0) then
            closest = {ent,diff}
        end
    end
    return closest[1]
end

function SWEP:Think()
    local ent = self:GetClosestTarget()
    self.Aimbot.Target = ent ~= 0 and ent or nil
	


hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
if self.On == true then
        return true
    end
end)
end


function SWEP:OnRemove()
self.On = false
timer.Remove("aimbotspin")

end
function SWEP:Holster()
self.On = false
timer.Remove("aimbotspin")
return true
end



function SWEP:PrimaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Primary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Primary.Spread * 0.8, self.Primary.Spread * 0.8, 0.8)
    bullet.Tracer = 1
    bullet.Force = 5
    bullet.Damage = self.Primary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanPrimaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self.Weapon:EmitSound(self.Primary.Sound)

    self:TakePrimaryAmmo(1) 
end

function SWEP:SecondaryAttack()
 
    if self.Aimbot.Target ~= nil then
   -- self.Owner:SetEyeAngles((self:GetHeadPos(self.Aimbot.Target) - self.Owner:GetShootPos()):Angle())
    
    local bullet = {}
    bullet.Num = self.Secondary.NumShots
    bullet.Src = self.Owner:GetPos()
    bullet.Dir = ( self.Aimbot.Target:LocalToWorld( self.Aimbot.Target:OBBCenter() ) - self.Owner:GetPos()  )
    bullet.Spread = Vector( self.Secondary.Spread * 0.8, self.Secondary.Spread * 0.8, 0.8)
    bullet.Tracer = 4
    bullet.Force = 5
    bullet.Damage = self.Secondary.Damage

    self.Owner:FireBullets(bullet)
    end
    
   if (!self:CanSecondaryAttack()) then return end

    self.Owner:MuzzleFlash()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
	
    self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    self.Weapon:EmitSound(self.Secondary.Sound)

    self:TakeSecondaryAmmo(1) 
end


function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
	
    draw.SimpleText("Fucking Whiffer Sniffer","Arial",x + wide/2,y + tall*0.35,Color(255,0,0,255),TEXT_ALIGN_CENTER)
end

function SWEP:DrawRotatingCrosshair(x,y,time,length,gap)
    surface.DrawLine(
        x + (math.sin(math.rad(time)) * length),
        y + (math.cos(math.rad(time)) * length),
        x + (math.sin(math.rad(time)) * gap),
        y + (math.cos(math.rad(time)) * gap)
    )
end

function SWEP:GetCoordiantes(ent)
    local min,max = ent:OBBMins(),ent:OBBMaxs()
    local corners = {
        Vector(min.x,min.y,min.z),
        Vector(min.x,min.y,max.z),
        Vector(min.x,max.y,min.z),
        Vector(min.x,max.y,max.z),
        Vector(max.x,min.y,min.z),
        Vector(max.x,min.y,max.z),
        Vector(max.x,max.y,min.z),
        Vector(max.x,max.y,max.z)
    }

    local minx,miny,maxx,maxy = ScrW() * 2,ScrH() * 2,0,0
    for _,corner in pairs(corners) do
        local screen = ent:LocalToWorld(corner):ToScreen()
        minx,miny = math.min(minx,screen.x),math.min(miny,screen.y)
        maxx,maxy = math.max(maxx,screen.x),math.max(maxy,screen.y)
    end
    return minx,miny,maxx,maxy
end

