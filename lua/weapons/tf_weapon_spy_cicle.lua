-- "lua\\weapons\\tf_weapon_spy_cicle.lua"
-- Retrieved by https://github.com/c4fe/glua-steal


-- Read all weapon_ for comments not pist_ or sec_
--Original Spy-Cicle SWEP by ErrolLiamP, and props to Buu342 for helping me out :)
	

list.Add( "OverrideMaterials", "models/player/shared/ice_player" )


 function SWEP:Precache() 
 	util.PrecacheSound("weapons/icicle_freeze_victim_01.wav") 
	util.PrecacheSound("weapons/icicle_hit_world_01.wav")
	util.PrecacheSound("TFPlayer.CritHit")
	util.PrecacheSound("Critical")
	util.PrecacheSound("Weapon_Knife.HitFlesh")
	util.PrecacheMaterial("models/shiny")
	util.PrecacheModel("models/weapons/c_models/c_spy_arms.mdl" )
	util.PrecacheModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )
 end 

function SWEP:Melee()

	self.DoMelee = nil
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	if ( trace.Hit ) then
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			if self.Weapon:GetNWBool("Critical") then
			bullet.Damage = 100000000
			bullet.Force  = 8
                                                      local hpp = self.Owner:Health();
                                                      if( hpp >= 300 ) then return; end
                                                      if( hpp <= 300 ) then hpp = hpp + 70 end

                                                      self.Owner:SetHealth( hpp );
			trace.Entity:EmitSound("TFPlayer.CritHit")
			else
			bullet.Damage = math.random(25,50)
			bullet.Force  = 2.5
			end
			if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			--self.Weapon:EmitSound("Weapon_Knife.HitFlesh")
			else
			self.Weapon:EmitSound("weapons/icicle_hit_world_01.wav")
			end
			self.Owner:FireBullets(bullet) 
	end
			self.Weapon:SetNWBool("Critical", false)
end

function SWEP:EntsInSphereBack( pos, range )
	local ents = ents.FindInSphere(pos,range)
	for k, v in pairs(ents) do
		if v != self and v != self.Owner and (v:IsNPC() or v:IsPlayer()) and IsValid(v) and self:EntityFaceBack(v) then
			return true
		end
	end
	return false
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType		= "melee"
end

if (CLIENT) then
	SWEP.Category 			= "Team Fortress 2";
	SWEP.PrintName			= "cicle for spy"	
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "S"
	SWEP.ViewModelFOV		= 50
	SWEP.DrawSecondaryAmmo = false
	SWEP.DrawAmmo		= false
	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 0, 200, 0, 255 ) )
end

SWEP.Instructions			= ""
SWEP.Author   				= "ErrolLiamP"
SWEP.Contact        		= ""

--SWEP.Base 				= "sp_tf2_base"
SWEP.ViewModelFlip		= false

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true

SWEP.ViewModel        = Model( "models/weapons/c_models/c_spy_arms.mdl" )
SWEP.WorldModel        = Model("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )

SWEP.Primary.Delay			= 0.8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"



SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip 	= 1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"




function SWEP:EjectBrass()
end

SWEP.data 				= {}
SWEP.mode 				= "auto"

SWEP.data.semi 			= {}

SWEP.data.auto 			= {}

function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
if self.Owner:GetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf hes in buildmode kill him")
self.Owner:ChatPrint("can't use this knife in buildmode")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else




	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = CurTime() + 1
	self.Weapon:SetNWBool("BackStab",false)
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos +(self.Owner:GetAimVector( ) * 72)
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata)
	if (tr.Entity and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) and self:EntityFaceBack(tr.Entity)) or self:EntsInSphereBack( tracedata.endpos,1 ) then



	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab" ) )
		self.DoMelee = CurTime() + 0.01
	--	self.Weapon:EmitSound("Weapon_Knife.MissCrit")
		self.Weapon:SetNWBool("Critical",true)
                                    self:MakeIce( tr.Entity )
                                      
			local tr, vm, muzzle, effect
    
    vm = self.Owner:GetViewModel( )
    
    tr = { }
    
    tr.start = self.Owner:GetShootPos( )
    tr.filter = self.Owner
    tr.endpos = tr.start + self.Owner:GetAimVector( ) * 72
    tr.mins = Vector( ) * -4
    tr.maxs = Vector( ) * 4
    
    tr = util.TraceHull( tr )
    
    effect = EffectData( )
        effect:SetStart( tr.StartPos )
        effect:SetOrigin( tr.HitPos )
        effect:SetEntity( self )
        effect:SetAttachment( vm:LookupAttachment( "muzzle" ) )
    util.Effect( "", effect )
	else
                  local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_stab_a" ) )
		self.DoMelee = CurTime() + 0.1
	--	self.Weapon:EmitSound("Weapon_Knife.Miss")

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

	




local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) then
local angle = self.Owner:GetAngles().y - tr.Entity:GetAngles().y
if angle < -180 then
angle = 360 + angle
end
if angle <= 90 and angle >= -90 and self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY )
self.Backstab = 1
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if !( angle <= 90 and angle >= -90 ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
end
if !( tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 2 and self.AttackTimer <= CurTime() then
self.Owner:ChatPrint("hi")


self.Attack = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 1 and self.AttackTimer <= CurTime() then
local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if SERVER and IsValid( tr.Entity ) then
local dmg = DamageInfo()
local attacker = self.Owner
if !IsValid( attacker ) then
attacker = self
end
dmg:SetAttacker( attacker )
dmg:SetInflictor( self )
dmg:SetDamage( self.Primary.Damage )
dmg:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
tr.Entity:TakeDamageInfo( dmg )
end
if tr.Hit then
if SERVER then
if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
self.Owner:EmitSound( "Weapon_Knife.HitFlesh" )
end
if !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() ) then
self.Owner:EmitSound( "Weapon_Knife.HitWorld" )
end
end
end
self.Attack = 0
end
if self.Idle == 0 and self.IdleTimer <= CurTime() then
if SERVER then
if self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
self.Owner:ChatPrint("I'm not ready to backstab")
end
if self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY_IDLE )
self.Owner:ChatPrint("I'm ready to backstab")
end
end
self.Idle = 1
end
end
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SetNWBool("Critical",false)
	self.DoMelee = nil
	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = nil
	self.Weapon:SetNWBool("BackStab",false)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Owner:GetViewModel():SetMaterial( "" )
	--self.Owner:GetViewModel():SetColor(255,255,255,255)
		if ( !SERVER ) then return end

	-- We need this because attack sequences won't work otherwise in multiplayer
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_draw" ) )
	return true
end

function SWEP:Holster()
self.Weapon:SetNWBool("Watch",false)
self.DoMelee = nil
return true
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()
if self.DoMelee and CurTime()>=self.DoMelee then
self.DoMelee = nil
self:Melee()
end
if self.Idle and CurTime()>=self.Idle then
self.Idle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_idle" ) )
end
if self.Attack and CurTime()>= self.Attack then
self.Attack = nil
end
if self.Attack then
self.BackStabIdleUp = nil
self.BackStabIdleDown = nil
self.BackStabIdle = nil
end
if self.BackStabIdleUp and CurTime()>= self.BackStabIdleUp and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleUp = nil
self.Attack = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_up" ) )
self.BackStabIdle = CurTime() + 0.1
end
if self.BackStabIdle and CurTime()>= self.BackStabIdle and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_idle" ) )
end
if self.BackStabIdleDown and CurTime()>= self.BackStabIdleDown and !self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleDown = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_down" ) )
self.Idle = CurTime() + 0.1
end

	local tra = {}
	tra.start = self.Owner:GetShootPos()
	tra.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra.filter = self.Owner
	tra.mask = MASK_SHOT
	local tracez = util.TraceLine( tra )
	local tra2 = {}
	tra2.start = self.Owner:GetShootPos()
	tra2.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra2.filter = self.Owner
	tra2.mask = MASK_SHOT
	local tracez2 = util.TraceLine( tra2 )
	
		if ( tracez2.Hit ) and ( tracez2.Entity:IsNPC() or tracez2.Entity:IsPlayer() ) and self:EntityFaceBack(tracez2.Entity) and !self.Weapon:GetNWBool("BackStab") then
		self.Weapon:SetNWBool("BackStab",true)
		if self.BackStabIdleUp and CurTime()<=self.BackStabIdleUp then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleUp = CurTime() + 0.1
		self.BackStabIdleDown = nil
		end
	end
	if ( tracez.Hit ) and self.Weapon:GetNWBool("BackStab") then
		if (tracez.Entity:IsWorld() or (tracez.Entity:IsNPC() or tracez.Entity:IsPlayer()) and !self:EntityFaceBack(tracez.Entity)) then
		self.Weapon:SetNWBool("BackStab",false)
		if self.BackStabIdleDown and CurTime()<=self.BackStabIdleDown then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleDown = CurTime() + 0.25
		self.BackStabIdleUp = nil
		end
	end
	end
end

/*---------------------------------------------------------
CanPrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
end


function SWEP:MakeIce( what )
	if CLIENT then
		return
	end
    if not IsValid( what ) then
        return
    end

if whatGetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf no")
self.Owner:ChatPrint("you can't kill this guy because he is in buildmode, idiot")
self.Owner:ConCommand("kill")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else



    
    if what.Welds then
        --Already Ice
        return
    end
    
    if not what:GetModel( ):match( "models/.*%.mdl" ) then
        --Brush entity / point / something without a proper model
        return
    end
    
	if (SERVER) then
    if what:IsNPC( ) then
        what:SetSchedule( SCHED_WAIT_FOR_SCRIPT )
    end
	end

    local bone, bones, bone1, bone2, weld, weld2
    
    if not ( what:IsPlayer( ) or what:IsNPC( ) ) then
	--		self.Weapon:EmitSound("Weapon_Knife.MissCrit")
        --Make use of existing object
		
        bones = what:GetPhysicsObjectCount( )
        
        what.Welds = what.Welds or { }
        
        for bone = 1, bones do
            bone1 = bone - 1
            bone2 = bones - bone
            
            if not what.Welds[ bone2 ] then
                weld = constraint.Weld( what, what, bone1, bone2, 0 )
                
                if weld then
                    what.Welds[ bone1 ] = weld
                    what:DeleteOnRemove( weld )
                end
            end
            
            weld2 = constraint.Weld( what, what, bone1, 0, 0 )
            
            if weld2 then
                what.Welds[ bone1 + bones ] = weld2
                what:DeleteOnRemove( weld2 )
            end
            
            --what:GetPhysicsObjectNum( bone ):EnableMotion( true )
        end
        
        what:SetMaterial( "models/player/shared/Ice_player" )
      --  what:SetColor( color_Ice )
        what:SetPhysicsAttacker( self.Owner )
    else
        local rag, vel, solid, wep, fakewep
        
        bones = what:GetPhysicsObjectCount( )
        vel = what:GetVelocity( )
        
        solid = what:GetSolid( )
        
        what:SetSolid( SOLID_NONE )
        
		
		
		
	
        if bones > 1 or what:IsPlayer( ) or what:IsNPC( ) then
            rag = ents.Create( "prop_ragdoll" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
				rag:EmitSound( "weapons/icicle_freeze_victim_01.wav" )
				rag:EmitSound("TFPlayer.CritHit")
            rag:Spawn( )
			rag:SetCollisionGroup( COLLISION_GROUP_WEAPON ) --This makes us able to walk through the frozen ply/npc, and they won't fly around anymore!
			
            
            bones = rag:GetPhysicsObjectCount( )
            
            for solid = 1, what:GetNumBodyGroups( ) do
            	rag:SetBodygroup( solid, what:GetBodygroup( solid ) )
            end
            
            rag:SetSequence( what:GetSequence( ) )
            rag:SetCycle( what:GetCycle( ) )
            
            for bone = 1, bones do
                bone1 = rag:GetPhysicsObjectNum( bone )
                
                if IsValid( bone1 ) then
                    weld, weld2 = what:GetBonePosition( what:TranslatePhysBoneToBone( bone ) )
                    
                    bone1:SetPos( weld )
                    bone1:SetAngles( weld2 )
                    bone1:SetMaterial( "metal" )
                    
                    bone1:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS )
                    bone1:AddGameFlag( FVPHYSICS_HEAVY_OBJECT )
                    bone1:SetMass( 500 )
                    
                    bone1:Sleep( )
                                        
                    local bone2 = bone1
                end
            end

            
            constraint.Weld( rag, Entity( 0 ), 0, 0, 900 )
            
			
			
			
            if what:IsNPC( ) or what:IsPlayer( ) then
            	wep = what:GetActiveWeapon( )
            	
            	if wep:IsValid( ) then
            		fakewep = ents.Create( "base_anim" )
            			fakewep:SetModel( wep:GetModel( ) )
            			--fakewep:SetColor( color_Ice ) this makes the weapon not call the unknown value leaving the weapon, non pink
            			fakewep:SetParent( rag )
            			fakewep:AddEffects( EF_BONEMERGE )
            			fakewep:SetMaterial( "models/shiny" )
            			fakewep.Class = wep:GetClass( )
            		fakewep:Spawn( )
            		
            		function rag.PlayerUse( rag, pl )
        				pl:Give( fakewep.Class )
        				fakewep:Remove( )
        				hook.Remove( "KeyPress", rag )
        			end
        			
        			function rag.KeyPress( this, pl, key )
        				if key == IN_USE then
        					local tr = { }
        					tr.start = pl:EyePos( )
        					tr.endpos = pl:EyePos( ) + pl:GetAimVector( ) * 85
        					tr.filter = pl
        					
        					tr = util.TraceLine( tr )
        					
        					if tr.Entity == this then
        						this:PlayerUse( pl )
        					end
        				end
        			end
        			
        			hook.Add( "KeyPress", rag, rag.KeyPress )

            		rag.FakeWeapon = fakewep
            	end
            end
            
            self:MakeIce( rag )
            
            SafeRemoveEntityDelayed( rag, 90 )
        else
            rag = ents.Create( "prop_physics" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
            rag:Spawn( )
        end
        
        what:SetSolid( solid )
        
        rag:SetSequence( what:GetSequence( ) )
        rag:SetCycle( what:GetCycle( ) )

        rag:SetSkin( what:GetSkin( ) )
        if what:IsPlayer( ) then
            what:KillSilent( )
        else
            what:Remove( )
        end
        self:MakeIce( rag )
    end
end


/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choIce
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	// other initialize code goes here

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

function SWEP:makemahcmodel()
if (CLIENT) then
self.CModel = ClientsideModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl")
local vm = self.Owner:GetViewModel()
self.CModel:SetPos(vm:GetPos())
self.CModel:SetAngles(vm:GetAngles())
self.CModel:AddEffects(EF_BONEMERGE)
self.CModel:SetNoDraw(true)
self.CModel:SetParent(vm)
end
end

function SWEP:ViewModelDrawn()
if (CLIENT) then
if not self.CModel then self:makemahcmodel() end
if self.CModel then self.CModel:DrawModel() end
end
end





function SWEP:DrawWorldModel()

local hand, offset, rotate


if not IsValid(self.Owner) then
self:DrawModel()
return
end

self:SetWeaponHoldType("knife")
hand = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_rh"))

offset = hand.Ang:Right() * 0.9 + hand.Ang:Forward() * 1.8 - hand.Ang:Up() * 0.7

hand.Ang:RotateAroundAxis(hand.Ang:Right(), 17)
hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 0)
hand.Ang:RotateAroundAxis(hand.Ang:Up(), 140)

self:SetRenderOrigin(hand.Pos + offset)
self:SetRenderAngles(hand.Ang)

self:DrawModel()
if (CLIENT) then
end
end



-- "lua\\weapons\\tf_weapon_spy_cicle.lua"
-- Retrieved by https://github.com/c4fe/glua-steal


-- Read all weapon_ for comments not pist_ or sec_
--Original Spy-Cicle SWEP by ErrolLiamP, and props to Buu342 for helping me out :)
	

list.Add( "OverrideMaterials", "models/player/shared/ice_player" )


 function SWEP:Precache() 
 	util.PrecacheSound("weapons/icicle_freeze_victim_01.wav") 
	util.PrecacheSound("weapons/icicle_hit_world_01.wav")
	util.PrecacheSound("TFPlayer.CritHit")
	util.PrecacheSound("Critical")
	util.PrecacheSound("Weapon_Knife.HitFlesh")
	util.PrecacheMaterial("models/shiny")
	util.PrecacheModel("models/weapons/c_models/c_spy_arms.mdl" )
	util.PrecacheModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )
 end 

function SWEP:Melee()

	self.DoMelee = nil
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	if ( trace.Hit ) then
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			if self.Weapon:GetNWBool("Critical") then
			bullet.Damage = 100000000
			bullet.Force  = 8
                                                      local hpp = self.Owner:Health();
                                                      if( hpp >= 300 ) then return; end
                                                      if( hpp <= 300 ) then hpp = hpp + 70 end

                                                      self.Owner:SetHealth( hpp );
			trace.Entity:EmitSound("TFPlayer.CritHit")
			else
			bullet.Damage = math.random(25,50)
			bullet.Force  = 2.5
			end
			if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			--self.Weapon:EmitSound("Weapon_Knife.HitFlesh")
			else
			self.Weapon:EmitSound("weapons/icicle_hit_world_01.wav")
			end
			self.Owner:FireBullets(bullet) 
	end
			self.Weapon:SetNWBool("Critical", false)
end

function SWEP:EntsInSphereBack( pos, range )
	local ents = ents.FindInSphere(pos,range)
	for k, v in pairs(ents) do
		if v != self and v != self.Owner and (v:IsNPC() or v:IsPlayer()) and IsValid(v) and self:EntityFaceBack(v) then
			return true
		end
	end
	return false
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType		= "melee"
end

if (CLIENT) then
	SWEP.Category 			= "Team Fortress 2";
	SWEP.PrintName			= "cicle for spy"	
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "S"
	SWEP.ViewModelFOV		= 50
	SWEP.DrawSecondaryAmmo = false
	SWEP.DrawAmmo		= false
	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 0, 200, 0, 255 ) )
end

SWEP.Instructions			= ""
SWEP.Author   				= "ErrolLiamP"
SWEP.Contact        		= ""

--SWEP.Base 				= "sp_tf2_base"
SWEP.ViewModelFlip		= false

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true

SWEP.ViewModel        = Model( "models/weapons/c_models/c_spy_arms.mdl" )
SWEP.WorldModel        = Model("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )

SWEP.Primary.Delay			= 0.8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"



SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip 	= 1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"




function SWEP:EjectBrass()
end

SWEP.data 				= {}
SWEP.mode 				= "auto"

SWEP.data.semi 			= {}

SWEP.data.auto 			= {}

function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
if self.Owner:GetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf hes in buildmode kill him")
self.Owner:ChatPrint("can't use this knife in buildmode")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else




	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = CurTime() + 1
	self.Weapon:SetNWBool("BackStab",false)
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos +(self.Owner:GetAimVector( ) * 72)
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata)
	if (tr.Entity and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) and self:EntityFaceBack(tr.Entity)) or self:EntsInSphereBack( tracedata.endpos,1 ) then



	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab" ) )
		self.DoMelee = CurTime() + 0.01
	--	self.Weapon:EmitSound("Weapon_Knife.MissCrit")
		self.Weapon:SetNWBool("Critical",true)
                                    self:MakeIce( tr.Entity )
                                      
			local tr, vm, muzzle, effect
    
    vm = self.Owner:GetViewModel( )
    
    tr = { }
    
    tr.start = self.Owner:GetShootPos( )
    tr.filter = self.Owner
    tr.endpos = tr.start + self.Owner:GetAimVector( ) * 72
    tr.mins = Vector( ) * -4
    tr.maxs = Vector( ) * 4
    
    tr = util.TraceHull( tr )
    
    effect = EffectData( )
        effect:SetStart( tr.StartPos )
        effect:SetOrigin( tr.HitPos )
        effect:SetEntity( self )
        effect:SetAttachment( vm:LookupAttachment( "muzzle" ) )
    util.Effect( "", effect )
	else
                  local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_stab_a" ) )
		self.DoMelee = CurTime() + 0.1
	--	self.Weapon:EmitSound("Weapon_Knife.Miss")

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

	




local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) then
local angle = self.Owner:GetAngles().y - tr.Entity:GetAngles().y
if angle < -180 then
angle = 360 + angle
end
if angle <= 90 and angle >= -90 and self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY )
self.Backstab = 1
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if !( angle <= 90 and angle >= -90 ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
end
if !( tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 2 and self.AttackTimer <= CurTime() then
self.Owner:ChatPrint("hi")


self.Attack = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 1 and self.AttackTimer <= CurTime() then
local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if SERVER and IsValid( tr.Entity ) then
local dmg = DamageInfo()
local attacker = self.Owner
if !IsValid( attacker ) then
attacker = self
end
dmg:SetAttacker( attacker )
dmg:SetInflictor( self )
dmg:SetDamage( self.Primary.Damage )
dmg:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
tr.Entity:TakeDamageInfo( dmg )
end
if tr.Hit then
if SERVER then
if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
self.Owner:EmitSound( "Weapon_Knife.HitFlesh" )
end
if !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() ) then
self.Owner:EmitSound( "Weapon_Knife.HitWorld" )
end
end
end
self.Attack = 0
end
if self.Idle == 0 and self.IdleTimer <= CurTime() then
if SERVER then
if self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
self.Owner:ChatPrint("I'm not ready to backstab")
end
if self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY_IDLE )
self.Owner:ChatPrint("I'm ready to backstab")
end
end
self.Idle = 1
end
end
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SetNWBool("Critical",false)
	self.DoMelee = nil
	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = nil
	self.Weapon:SetNWBool("BackStab",false)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Owner:GetViewModel():SetMaterial( "" )
	--self.Owner:GetViewModel():SetColor(255,255,255,255)
		if ( !SERVER ) then return end

	-- We need this because attack sequences won't work otherwise in multiplayer
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_draw" ) )
	return true
end

function SWEP:Holster()
self.Weapon:SetNWBool("Watch",false)
self.DoMelee = nil
return true
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()
if self.DoMelee and CurTime()>=self.DoMelee then
self.DoMelee = nil
self:Melee()
end
if self.Idle and CurTime()>=self.Idle then
self.Idle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_idle" ) )
end
if self.Attack and CurTime()>= self.Attack then
self.Attack = nil
end
if self.Attack then
self.BackStabIdleUp = nil
self.BackStabIdleDown = nil
self.BackStabIdle = nil
end
if self.BackStabIdleUp and CurTime()>= self.BackStabIdleUp and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleUp = nil
self.Attack = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_up" ) )
self.BackStabIdle = CurTime() + 0.1
end
if self.BackStabIdle and CurTime()>= self.BackStabIdle and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_idle" ) )
end
if self.BackStabIdleDown and CurTime()>= self.BackStabIdleDown and !self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleDown = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_down" ) )
self.Idle = CurTime() + 0.1
end

	local tra = {}
	tra.start = self.Owner:GetShootPos()
	tra.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra.filter = self.Owner
	tra.mask = MASK_SHOT
	local tracez = util.TraceLine( tra )
	local tra2 = {}
	tra2.start = self.Owner:GetShootPos()
	tra2.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra2.filter = self.Owner
	tra2.mask = MASK_SHOT
	local tracez2 = util.TraceLine( tra2 )
	
		if ( tracez2.Hit ) and ( tracez2.Entity:IsNPC() or tracez2.Entity:IsPlayer() ) and self:EntityFaceBack(tracez2.Entity) and !self.Weapon:GetNWBool("BackStab") then
		self.Weapon:SetNWBool("BackStab",true)
		if self.BackStabIdleUp and CurTime()<=self.BackStabIdleUp then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleUp = CurTime() + 0.1
		self.BackStabIdleDown = nil
		end
	end
	if ( tracez.Hit ) and self.Weapon:GetNWBool("BackStab") then
		if (tracez.Entity:IsWorld() or (tracez.Entity:IsNPC() or tracez.Entity:IsPlayer()) and !self:EntityFaceBack(tracez.Entity)) then
		self.Weapon:SetNWBool("BackStab",false)
		if self.BackStabIdleDown and CurTime()<=self.BackStabIdleDown then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleDown = CurTime() + 0.25
		self.BackStabIdleUp = nil
		end
	end
	end
end

/*---------------------------------------------------------
CanPrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
end


function SWEP:MakeIce( what )
	if CLIENT then
		return
	end
    if not IsValid( what ) then
        return
    end

if whatGetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf no")
self.Owner:ChatPrint("you can't kill this guy because he is in buildmode, idiot")
self.Owner:ConCommand("kill")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else



    
    if what.Welds then
        --Already Ice
        return
    end
    
    if not what:GetModel( ):match( "models/.*%.mdl" ) then
        --Brush entity / point / something without a proper model
        return
    end
    
	if (SERVER) then
    if what:IsNPC( ) then
        what:SetSchedule( SCHED_WAIT_FOR_SCRIPT )
    end
	end

    local bone, bones, bone1, bone2, weld, weld2
    
    if not ( what:IsPlayer( ) or what:IsNPC( ) ) then
	--		self.Weapon:EmitSound("Weapon_Knife.MissCrit")
        --Make use of existing object
		
        bones = what:GetPhysicsObjectCount( )
        
        what.Welds = what.Welds or { }
        
        for bone = 1, bones do
            bone1 = bone - 1
            bone2 = bones - bone
            
            if not what.Welds[ bone2 ] then
                weld = constraint.Weld( what, what, bone1, bone2, 0 )
                
                if weld then
                    what.Welds[ bone1 ] = weld
                    what:DeleteOnRemove( weld )
                end
            end
            
            weld2 = constraint.Weld( what, what, bone1, 0, 0 )
            
            if weld2 then
                what.Welds[ bone1 + bones ] = weld2
                what:DeleteOnRemove( weld2 )
            end
            
            --what:GetPhysicsObjectNum( bone ):EnableMotion( true )
        end
        
        what:SetMaterial( "models/player/shared/Ice_player" )
      --  what:SetColor( color_Ice )
        what:SetPhysicsAttacker( self.Owner )
    else
        local rag, vel, solid, wep, fakewep
        
        bones = what:GetPhysicsObjectCount( )
        vel = what:GetVelocity( )
        
        solid = what:GetSolid( )
        
        what:SetSolid( SOLID_NONE )
        
		
		
		
	
        if bones > 1 or what:IsPlayer( ) or what:IsNPC( ) then
            rag = ents.Create( "prop_ragdoll" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
				rag:EmitSound( "weapons/icicle_freeze_victim_01.wav" )
				rag:EmitSound("TFPlayer.CritHit")
            rag:Spawn( )
			rag:SetCollisionGroup( COLLISION_GROUP_WEAPON ) --This makes us able to walk through the frozen ply/npc, and they won't fly around anymore!
			
            
            bones = rag:GetPhysicsObjectCount( )
            
            for solid = 1, what:GetNumBodyGroups( ) do
            	rag:SetBodygroup( solid, what:GetBodygroup( solid ) )
            end
            
            rag:SetSequence( what:GetSequence( ) )
            rag:SetCycle( what:GetCycle( ) )
            
            for bone = 1, bones do
                bone1 = rag:GetPhysicsObjectNum( bone )
                
                if IsValid( bone1 ) then
                    weld, weld2 = what:GetBonePosition( what:TranslatePhysBoneToBone( bone ) )
                    
                    bone1:SetPos( weld )
                    bone1:SetAngles( weld2 )
                    bone1:SetMaterial( "metal" )
                    
                    bone1:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS )
                    bone1:AddGameFlag( FVPHYSICS_HEAVY_OBJECT )
                    bone1:SetMass( 500 )
                    
                    bone1:Sleep( )
                                        
                    local bone2 = bone1
                end
            end

            
            constraint.Weld( rag, Entity( 0 ), 0, 0, 900 )
            
			
			
			
            if what:IsNPC( ) or what:IsPlayer( ) then
            	wep = what:GetActiveWeapon( )
            	
            	if wep:IsValid( ) then
            		fakewep = ents.Create( "base_anim" )
            			fakewep:SetModel( wep:GetModel( ) )
            			--fakewep:SetColor( color_Ice ) this makes the weapon not call the unknown value leaving the weapon, non pink
            			fakewep:SetParent( rag )
            			fakewep:AddEffects( EF_BONEMERGE )
            			fakewep:SetMaterial( "models/shiny" )
            			fakewep.Class = wep:GetClass( )
            		fakewep:Spawn( )
            		
            		function rag.PlayerUse( rag, pl )
        				pl:Give( fakewep.Class )
        				fakewep:Remove( )
        				hook.Remove( "KeyPress", rag )
        			end
        			
        			function rag.KeyPress( this, pl, key )
        				if key == IN_USE then
        					local tr = { }
        					tr.start = pl:EyePos( )
        					tr.endpos = pl:EyePos( ) + pl:GetAimVector( ) * 85
        					tr.filter = pl
        					
        					tr = util.TraceLine( tr )
        					
        					if tr.Entity == this then
        						this:PlayerUse( pl )
        					end
        				end
        			end
        			
        			hook.Add( "KeyPress", rag, rag.KeyPress )

            		rag.FakeWeapon = fakewep
            	end
            end
            
            self:MakeIce( rag )
            
            SafeRemoveEntityDelayed( rag, 90 )
        else
            rag = ents.Create( "prop_physics" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
            rag:Spawn( )
        end
        
        what:SetSolid( solid )
        
        rag:SetSequence( what:GetSequence( ) )
        rag:SetCycle( what:GetCycle( ) )

        rag:SetSkin( what:GetSkin( ) )
        if what:IsPlayer( ) then
            what:KillSilent( )
        else
            what:Remove( )
        end
        self:MakeIce( rag )
    end
end


/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choIce
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	// other initialize code goes here

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

function SWEP:makemahcmodel()
if (CLIENT) then
self.CModel = ClientsideModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl")
local vm = self.Owner:GetViewModel()
self.CModel:SetPos(vm:GetPos())
self.CModel:SetAngles(vm:GetAngles())
self.CModel:AddEffects(EF_BONEMERGE)
self.CModel:SetNoDraw(true)
self.CModel:SetParent(vm)
end
end

function SWEP:ViewModelDrawn()
if (CLIENT) then
if not self.CModel then self:makemahcmodel() end
if self.CModel then self.CModel:DrawModel() end
end
end





function SWEP:DrawWorldModel()

local hand, offset, rotate


if not IsValid(self.Owner) then
self:DrawModel()
return
end

self:SetWeaponHoldType("knife")
hand = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_rh"))

offset = hand.Ang:Right() * 0.9 + hand.Ang:Forward() * 1.8 - hand.Ang:Up() * 0.7

hand.Ang:RotateAroundAxis(hand.Ang:Right(), 17)
hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 0)
hand.Ang:RotateAroundAxis(hand.Ang:Up(), 140)

self:SetRenderOrigin(hand.Pos + offset)
self:SetRenderAngles(hand.Ang)

self:DrawModel()
if (CLIENT) then
end
end



-- "lua\\weapons\\tf_weapon_spy_cicle.lua"
-- Retrieved by https://github.com/c4fe/glua-steal


-- Read all weapon_ for comments not pist_ or sec_
--Original Spy-Cicle SWEP by ErrolLiamP, and props to Buu342 for helping me out :)
	

list.Add( "OverrideMaterials", "models/player/shared/ice_player" )


 function SWEP:Precache() 
 	util.PrecacheSound("weapons/icicle_freeze_victim_01.wav") 
	util.PrecacheSound("weapons/icicle_hit_world_01.wav")
	util.PrecacheSound("TFPlayer.CritHit")
	util.PrecacheSound("Critical")
	util.PrecacheSound("Weapon_Knife.HitFlesh")
	util.PrecacheMaterial("models/shiny")
	util.PrecacheModel("models/weapons/c_models/c_spy_arms.mdl" )
	util.PrecacheModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )
 end 

function SWEP:Melee()

	self.DoMelee = nil
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	if ( trace.Hit ) then
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			if self.Weapon:GetNWBool("Critical") then
			bullet.Damage = 100000000
			bullet.Force  = 8
                                                      local hpp = self.Owner:Health();
                                                      if( hpp >= 300 ) then return; end
                                                      if( hpp <= 300 ) then hpp = hpp + 70 end

                                                      self.Owner:SetHealth( hpp );
			trace.Entity:EmitSound("TFPlayer.CritHit")
			else
			bullet.Damage = math.random(25,50)
			bullet.Force  = 2.5
			end
			if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			--self.Weapon:EmitSound("Weapon_Knife.HitFlesh")
			else
			self.Weapon:EmitSound("weapons/icicle_hit_world_01.wav")
			end
			self.Owner:FireBullets(bullet) 
	end
			self.Weapon:SetNWBool("Critical", false)
end

function SWEP:EntsInSphereBack( pos, range )
	local ents = ents.FindInSphere(pos,range)
	for k, v in pairs(ents) do
		if v != self and v != self.Owner and (v:IsNPC() or v:IsPlayer()) and IsValid(v) and self:EntityFaceBack(v) then
			return true
		end
	end
	return false
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType		= "melee"
end

if (CLIENT) then
	SWEP.Category 			= "Team Fortress 2";
	SWEP.PrintName			= "cicle for spy"	
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "S"
	SWEP.ViewModelFOV		= 50
	SWEP.DrawSecondaryAmmo = false
	SWEP.DrawAmmo		= false
	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 0, 200, 0, 255 ) )
end

SWEP.Instructions			= ""
SWEP.Author   				= "ErrolLiamP"
SWEP.Contact        		= ""

--SWEP.Base 				= "sp_tf2_base"
SWEP.ViewModelFlip		= false

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true

SWEP.ViewModel        = Model( "models/weapons/c_models/c_spy_arms.mdl" )
SWEP.WorldModel        = Model("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )

SWEP.Primary.Delay			= 0.8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"



SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip 	= 1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"




function SWEP:EjectBrass()
end

SWEP.data 				= {}
SWEP.mode 				= "auto"

SWEP.data.semi 			= {}

SWEP.data.auto 			= {}

function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
if self.Owner:GetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf hes in buildmode kill him")
self.Owner:ChatPrint("can't use this knife in buildmode")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else




	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = CurTime() + 1
	self.Weapon:SetNWBool("BackStab",false)
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos +(self.Owner:GetAimVector( ) * 72)
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata)
	if (tr.Entity and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) and self:EntityFaceBack(tr.Entity)) or self:EntsInSphereBack( tracedata.endpos,1 ) then



	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab" ) )
		self.DoMelee = CurTime() + 0.01
	--	self.Weapon:EmitSound("Weapon_Knife.MissCrit")
		self.Weapon:SetNWBool("Critical",true)
                                    self:MakeIce( tr.Entity )
                                      
			local tr, vm, muzzle, effect
    
    vm = self.Owner:GetViewModel( )
    
    tr = { }
    
    tr.start = self.Owner:GetShootPos( )
    tr.filter = self.Owner
    tr.endpos = tr.start + self.Owner:GetAimVector( ) * 72
    tr.mins = Vector( ) * -4
    tr.maxs = Vector( ) * 4
    
    tr = util.TraceHull( tr )
    
    effect = EffectData( )
        effect:SetStart( tr.StartPos )
        effect:SetOrigin( tr.HitPos )
        effect:SetEntity( self )
        effect:SetAttachment( vm:LookupAttachment( "muzzle" ) )
    util.Effect( "", effect )
	else
                  local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_stab_a" ) )
		self.DoMelee = CurTime() + 0.1
	--	self.Weapon:EmitSound("Weapon_Knife.Miss")

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

	




local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) then
local angle = self.Owner:GetAngles().y - tr.Entity:GetAngles().y
if angle < -180 then
angle = 360 + angle
end
if angle <= 90 and angle >= -90 and self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY )
self.Backstab = 1
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if !( angle <= 90 and angle >= -90 ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
end
if !( tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 2 and self.AttackTimer <= CurTime() then
self.Owner:ChatPrint("hi")


self.Attack = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 1 and self.AttackTimer <= CurTime() then
local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if SERVER and IsValid( tr.Entity ) then
local dmg = DamageInfo()
local attacker = self.Owner
if !IsValid( attacker ) then
attacker = self
end
dmg:SetAttacker( attacker )
dmg:SetInflictor( self )
dmg:SetDamage( self.Primary.Damage )
dmg:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
tr.Entity:TakeDamageInfo( dmg )
end
if tr.Hit then
if SERVER then
if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
self.Owner:EmitSound( "Weapon_Knife.HitFlesh" )
end
if !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() ) then
self.Owner:EmitSound( "Weapon_Knife.HitWorld" )
end
end
end
self.Attack = 0
end
if self.Idle == 0 and self.IdleTimer <= CurTime() then
if SERVER then
if self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
self.Owner:ChatPrint("I'm not ready to backstab")
end
if self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY_IDLE )
self.Owner:ChatPrint("I'm ready to backstab")
end
end
self.Idle = 1
end
end
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SetNWBool("Critical",false)
	self.DoMelee = nil
	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = nil
	self.Weapon:SetNWBool("BackStab",false)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Owner:GetViewModel():SetMaterial( "" )
	--self.Owner:GetViewModel():SetColor(255,255,255,255)
		if ( !SERVER ) then return end

	-- We need this because attack sequences won't work otherwise in multiplayer
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_draw" ) )
	return true
end

function SWEP:Holster()
self.Weapon:SetNWBool("Watch",false)
self.DoMelee = nil
return true
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()
if self.DoMelee and CurTime()>=self.DoMelee then
self.DoMelee = nil
self:Melee()
end
if self.Idle and CurTime()>=self.Idle then
self.Idle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_idle" ) )
end
if self.Attack and CurTime()>= self.Attack then
self.Attack = nil
end
if self.Attack then
self.BackStabIdleUp = nil
self.BackStabIdleDown = nil
self.BackStabIdle = nil
end
if self.BackStabIdleUp and CurTime()>= self.BackStabIdleUp and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleUp = nil
self.Attack = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_up" ) )
self.BackStabIdle = CurTime() + 0.1
end
if self.BackStabIdle and CurTime()>= self.BackStabIdle and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_idle" ) )
end
if self.BackStabIdleDown and CurTime()>= self.BackStabIdleDown and !self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleDown = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_down" ) )
self.Idle = CurTime() + 0.1
end

	local tra = {}
	tra.start = self.Owner:GetShootPos()
	tra.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra.filter = self.Owner
	tra.mask = MASK_SHOT
	local tracez = util.TraceLine( tra )
	local tra2 = {}
	tra2.start = self.Owner:GetShootPos()
	tra2.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra2.filter = self.Owner
	tra2.mask = MASK_SHOT
	local tracez2 = util.TraceLine( tra2 )
	
		if ( tracez2.Hit ) and ( tracez2.Entity:IsNPC() or tracez2.Entity:IsPlayer() ) and self:EntityFaceBack(tracez2.Entity) and !self.Weapon:GetNWBool("BackStab") then
		self.Weapon:SetNWBool("BackStab",true)
		if self.BackStabIdleUp and CurTime()<=self.BackStabIdleUp then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleUp = CurTime() + 0.1
		self.BackStabIdleDown = nil
		end
	end
	if ( tracez.Hit ) and self.Weapon:GetNWBool("BackStab") then
		if (tracez.Entity:IsWorld() or (tracez.Entity:IsNPC() or tracez.Entity:IsPlayer()) and !self:EntityFaceBack(tracez.Entity)) then
		self.Weapon:SetNWBool("BackStab",false)
		if self.BackStabIdleDown and CurTime()<=self.BackStabIdleDown then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleDown = CurTime() + 0.25
		self.BackStabIdleUp = nil
		end
	end
	end
end

/*---------------------------------------------------------
CanPrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
end


function SWEP:MakeIce( what )
	if CLIENT then
		return
	end
    if not IsValid( what ) then
        return
    end

if whatGetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf no")
self.Owner:ChatPrint("you can't kill this guy because he is in buildmode, idiot")
self.Owner:ConCommand("kill")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else



    
    if what.Welds then
        --Already Ice
        return
    end
    
    if not what:GetModel( ):match( "models/.*%.mdl" ) then
        --Brush entity / point / something without a proper model
        return
    end
    
	if (SERVER) then
    if what:IsNPC( ) then
        what:SetSchedule( SCHED_WAIT_FOR_SCRIPT )
    end
	end

    local bone, bones, bone1, bone2, weld, weld2
    
    if not ( what:IsPlayer( ) or what:IsNPC( ) ) then
	--		self.Weapon:EmitSound("Weapon_Knife.MissCrit")
        --Make use of existing object
		
        bones = what:GetPhysicsObjectCount( )
        
        what.Welds = what.Welds or { }
        
        for bone = 1, bones do
            bone1 = bone - 1
            bone2 = bones - bone
            
            if not what.Welds[ bone2 ] then
                weld = constraint.Weld( what, what, bone1, bone2, 0 )
                
                if weld then
                    what.Welds[ bone1 ] = weld
                    what:DeleteOnRemove( weld )
                end
            end
            
            weld2 = constraint.Weld( what, what, bone1, 0, 0 )
            
            if weld2 then
                what.Welds[ bone1 + bones ] = weld2
                what:DeleteOnRemove( weld2 )
            end
            
            --what:GetPhysicsObjectNum( bone ):EnableMotion( true )
        end
        
        what:SetMaterial( "models/player/shared/Ice_player" )
      --  what:SetColor( color_Ice )
        what:SetPhysicsAttacker( self.Owner )
    else
        local rag, vel, solid, wep, fakewep
        
        bones = what:GetPhysicsObjectCount( )
        vel = what:GetVelocity( )
        
        solid = what:GetSolid( )
        
        what:SetSolid( SOLID_NONE )
        
		
		
		
	
        if bones > 1 or what:IsPlayer( ) or what:IsNPC( ) then
            rag = ents.Create( "prop_ragdoll" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
				rag:EmitSound( "weapons/icicle_freeze_victim_01.wav" )
				rag:EmitSound("TFPlayer.CritHit")
            rag:Spawn( )
			rag:SetCollisionGroup( COLLISION_GROUP_WEAPON ) --This makes us able to walk through the frozen ply/npc, and they won't fly around anymore!
			
            
            bones = rag:GetPhysicsObjectCount( )
            
            for solid = 1, what:GetNumBodyGroups( ) do
            	rag:SetBodygroup( solid, what:GetBodygroup( solid ) )
            end
            
            rag:SetSequence( what:GetSequence( ) )
            rag:SetCycle( what:GetCycle( ) )
            
            for bone = 1, bones do
                bone1 = rag:GetPhysicsObjectNum( bone )
                
                if IsValid( bone1 ) then
                    weld, weld2 = what:GetBonePosition( what:TranslatePhysBoneToBone( bone ) )
                    
                    bone1:SetPos( weld )
                    bone1:SetAngles( weld2 )
                    bone1:SetMaterial( "metal" )
                    
                    bone1:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS )
                    bone1:AddGameFlag( FVPHYSICS_HEAVY_OBJECT )
                    bone1:SetMass( 500 )
                    
                    bone1:Sleep( )
                                        
                    local bone2 = bone1
                end
            end

            
            constraint.Weld( rag, Entity( 0 ), 0, 0, 900 )
            
			
			
			
            if what:IsNPC( ) or what:IsPlayer( ) then
            	wep = what:GetActiveWeapon( )
            	
            	if wep:IsValid( ) then
            		fakewep = ents.Create( "base_anim" )
            			fakewep:SetModel( wep:GetModel( ) )
            			--fakewep:SetColor( color_Ice ) this makes the weapon not call the unknown value leaving the weapon, non pink
            			fakewep:SetParent( rag )
            			fakewep:AddEffects( EF_BONEMERGE )
            			fakewep:SetMaterial( "models/shiny" )
            			fakewep.Class = wep:GetClass( )
            		fakewep:Spawn( )
            		
            		function rag.PlayerUse( rag, pl )
        				pl:Give( fakewep.Class )
        				fakewep:Remove( )
        				hook.Remove( "KeyPress", rag )
        			end
        			
        			function rag.KeyPress( this, pl, key )
        				if key == IN_USE then
        					local tr = { }
        					tr.start = pl:EyePos( )
        					tr.endpos = pl:EyePos( ) + pl:GetAimVector( ) * 85
        					tr.filter = pl
        					
        					tr = util.TraceLine( tr )
        					
        					if tr.Entity == this then
        						this:PlayerUse( pl )
        					end
        				end
        			end
        			
        			hook.Add( "KeyPress", rag, rag.KeyPress )

            		rag.FakeWeapon = fakewep
            	end
            end
            
            self:MakeIce( rag )
            
            SafeRemoveEntityDelayed( rag, 90 )
        else
            rag = ents.Create( "prop_physics" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
            rag:Spawn( )
        end
        
        what:SetSolid( solid )
        
        rag:SetSequence( what:GetSequence( ) )
        rag:SetCycle( what:GetCycle( ) )

        rag:SetSkin( what:GetSkin( ) )
        if what:IsPlayer( ) then
            what:KillSilent( )
        else
            what:Remove( )
        end
        self:MakeIce( rag )
    end
end


/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choIce
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	// other initialize code goes here

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

function SWEP:makemahcmodel()
if (CLIENT) then
self.CModel = ClientsideModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl")
local vm = self.Owner:GetViewModel()
self.CModel:SetPos(vm:GetPos())
self.CModel:SetAngles(vm:GetAngles())
self.CModel:AddEffects(EF_BONEMERGE)
self.CModel:SetNoDraw(true)
self.CModel:SetParent(vm)
end
end

function SWEP:ViewModelDrawn()
if (CLIENT) then
if not self.CModel then self:makemahcmodel() end
if self.CModel then self.CModel:DrawModel() end
end
end





function SWEP:DrawWorldModel()

local hand, offset, rotate


if not IsValid(self.Owner) then
self:DrawModel()
return
end

self:SetWeaponHoldType("knife")
hand = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_rh"))

offset = hand.Ang:Right() * 0.9 + hand.Ang:Forward() * 1.8 - hand.Ang:Up() * 0.7

hand.Ang:RotateAroundAxis(hand.Ang:Right(), 17)
hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 0)
hand.Ang:RotateAroundAxis(hand.Ang:Up(), 140)

self:SetRenderOrigin(hand.Pos + offset)
self:SetRenderAngles(hand.Ang)

self:DrawModel()
if (CLIENT) then
end
end



-- "lua\\weapons\\tf_weapon_spy_cicle.lua"
-- Retrieved by https://github.com/c4fe/glua-steal


-- Read all weapon_ for comments not pist_ or sec_
--Original Spy-Cicle SWEP by ErrolLiamP, and props to Buu342 for helping me out :)
	

list.Add( "OverrideMaterials", "models/player/shared/ice_player" )


 function SWEP:Precache() 
 	util.PrecacheSound("weapons/icicle_freeze_victim_01.wav") 
	util.PrecacheSound("weapons/icicle_hit_world_01.wav")
	util.PrecacheSound("TFPlayer.CritHit")
	util.PrecacheSound("Critical")
	util.PrecacheSound("Weapon_Knife.HitFlesh")
	util.PrecacheMaterial("models/shiny")
	util.PrecacheModel("models/weapons/c_models/c_spy_arms.mdl" )
	util.PrecacheModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )
 end 

function SWEP:Melee()

	self.DoMelee = nil
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	if ( trace.Hit ) then
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			if self.Weapon:GetNWBool("Critical") then
			bullet.Damage = 100000000
			bullet.Force  = 8
                                                      local hpp = self.Owner:Health();
                                                      if( hpp >= 300 ) then return; end
                                                      if( hpp <= 300 ) then hpp = hpp + 70 end

                                                      self.Owner:SetHealth( hpp );
			trace.Entity:EmitSound("TFPlayer.CritHit")
			else
			bullet.Damage = math.random(25,50)
			bullet.Force  = 2.5
			end
			if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			--self.Weapon:EmitSound("Weapon_Knife.HitFlesh")
			else
			self.Weapon:EmitSound("weapons/icicle_hit_world_01.wav")
			end
			self.Owner:FireBullets(bullet) 
	end
			self.Weapon:SetNWBool("Critical", false)
end

function SWEP:EntsInSphereBack( pos, range )
	local ents = ents.FindInSphere(pos,range)
	for k, v in pairs(ents) do
		if v != self and v != self.Owner and (v:IsNPC() or v:IsPlayer()) and IsValid(v) and self:EntityFaceBack(v) then
			return true
		end
	end
	return false
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType		= "melee"
end

if (CLIENT) then
	SWEP.Category 			= "Team Fortress 2";
	SWEP.PrintName			= "cicle for spy"	
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "S"
	SWEP.ViewModelFOV		= 50
	SWEP.DrawSecondaryAmmo = false
	SWEP.DrawAmmo		= false
	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 0, 200, 0, 255 ) )
end

SWEP.Instructions			= ""
SWEP.Author   				= "ErrolLiamP"
SWEP.Contact        		= ""

--SWEP.Base 				= "sp_tf2_base"
SWEP.ViewModelFlip		= false

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true

SWEP.ViewModel        = Model( "models/weapons/c_models/c_spy_arms.mdl" )
SWEP.WorldModel        = Model("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )

SWEP.Primary.Delay			= 0.8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"



SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip 	= 1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"




function SWEP:EjectBrass()
end

SWEP.data 				= {}
SWEP.mode 				= "auto"

SWEP.data.semi 			= {}

SWEP.data.auto 			= {}

function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
if self.Owner:GetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf hes in buildmode kill him")
self.Owner:ChatPrint("can't use this knife in buildmode")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else




	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = CurTime() + 1
	self.Weapon:SetNWBool("BackStab",false)
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos +(self.Owner:GetAimVector( ) * 72)
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata)
	if (tr.Entity and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) and self:EntityFaceBack(tr.Entity)) or self:EntsInSphereBack( tracedata.endpos,1 ) then



	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab" ) )
		self.DoMelee = CurTime() + 0.01
	--	self.Weapon:EmitSound("Weapon_Knife.MissCrit")
		self.Weapon:SetNWBool("Critical",true)
                                    self:MakeIce( tr.Entity )
                                      
			local tr, vm, muzzle, effect
    
    vm = self.Owner:GetViewModel( )
    
    tr = { }
    
    tr.start = self.Owner:GetShootPos( )
    tr.filter = self.Owner
    tr.endpos = tr.start + self.Owner:GetAimVector( ) * 72
    tr.mins = Vector( ) * -4
    tr.maxs = Vector( ) * 4
    
    tr = util.TraceHull( tr )
    
    effect = EffectData( )
        effect:SetStart( tr.StartPos )
        effect:SetOrigin( tr.HitPos )
        effect:SetEntity( self )
        effect:SetAttachment( vm:LookupAttachment( "muzzle" ) )
    util.Effect( "", effect )
	else
                  local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_stab_a" ) )
		self.DoMelee = CurTime() + 0.1
	--	self.Weapon:EmitSound("Weapon_Knife.Miss")

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

	




local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) then
local angle = self.Owner:GetAngles().y - tr.Entity:GetAngles().y
if angle < -180 then
angle = 360 + angle
end
if angle <= 90 and angle >= -90 and self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY )
self.Backstab = 1
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if !( angle <= 90 and angle >= -90 ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
end
if !( tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 2 and self.AttackTimer <= CurTime() then
self.Owner:ChatPrint("hi")


self.Attack = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 1 and self.AttackTimer <= CurTime() then
local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if SERVER and IsValid( tr.Entity ) then
local dmg = DamageInfo()
local attacker = self.Owner
if !IsValid( attacker ) then
attacker = self
end
dmg:SetAttacker( attacker )
dmg:SetInflictor( self )
dmg:SetDamage( self.Primary.Damage )
dmg:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
tr.Entity:TakeDamageInfo( dmg )
end
if tr.Hit then
if SERVER then
if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
self.Owner:EmitSound( "Weapon_Knife.HitFlesh" )
end
if !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() ) then
self.Owner:EmitSound( "Weapon_Knife.HitWorld" )
end
end
end
self.Attack = 0
end
if self.Idle == 0 and self.IdleTimer <= CurTime() then
if SERVER then
if self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
self.Owner:ChatPrint("I'm not ready to backstab")
end
if self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY_IDLE )
self.Owner:ChatPrint("I'm ready to backstab")
end
end
self.Idle = 1
end
end
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SetNWBool("Critical",false)
	self.DoMelee = nil
	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = nil
	self.Weapon:SetNWBool("BackStab",false)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Owner:GetViewModel():SetMaterial( "" )
	--self.Owner:GetViewModel():SetColor(255,255,255,255)
		if ( !SERVER ) then return end

	-- We need this because attack sequences won't work otherwise in multiplayer
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_draw" ) )
	return true
end

function SWEP:Holster()
self.Weapon:SetNWBool("Watch",false)
self.DoMelee = nil
return true
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()
if self.DoMelee and CurTime()>=self.DoMelee then
self.DoMelee = nil
self:Melee()
end
if self.Idle and CurTime()>=self.Idle then
self.Idle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_idle" ) )
end
if self.Attack and CurTime()>= self.Attack then
self.Attack = nil
end
if self.Attack then
self.BackStabIdleUp = nil
self.BackStabIdleDown = nil
self.BackStabIdle = nil
end
if self.BackStabIdleUp and CurTime()>= self.BackStabIdleUp and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleUp = nil
self.Attack = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_up" ) )
self.BackStabIdle = CurTime() + 0.1
end
if self.BackStabIdle and CurTime()>= self.BackStabIdle and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_idle" ) )
end
if self.BackStabIdleDown and CurTime()>= self.BackStabIdleDown and !self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleDown = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_down" ) )
self.Idle = CurTime() + 0.1
end

	local tra = {}
	tra.start = self.Owner:GetShootPos()
	tra.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra.filter = self.Owner
	tra.mask = MASK_SHOT
	local tracez = util.TraceLine( tra )
	local tra2 = {}
	tra2.start = self.Owner:GetShootPos()
	tra2.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra2.filter = self.Owner
	tra2.mask = MASK_SHOT
	local tracez2 = util.TraceLine( tra2 )
	
		if ( tracez2.Hit ) and ( tracez2.Entity:IsNPC() or tracez2.Entity:IsPlayer() ) and self:EntityFaceBack(tracez2.Entity) and !self.Weapon:GetNWBool("BackStab") then
		self.Weapon:SetNWBool("BackStab",true)
		if self.BackStabIdleUp and CurTime()<=self.BackStabIdleUp then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleUp = CurTime() + 0.1
		self.BackStabIdleDown = nil
		end
	end
	if ( tracez.Hit ) and self.Weapon:GetNWBool("BackStab") then
		if (tracez.Entity:IsWorld() or (tracez.Entity:IsNPC() or tracez.Entity:IsPlayer()) and !self:EntityFaceBack(tracez.Entity)) then
		self.Weapon:SetNWBool("BackStab",false)
		if self.BackStabIdleDown and CurTime()<=self.BackStabIdleDown then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleDown = CurTime() + 0.25
		self.BackStabIdleUp = nil
		end
	end
	end
end

/*---------------------------------------------------------
CanPrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
end


function SWEP:MakeIce( what )
	if CLIENT then
		return
	end
    if not IsValid( what ) then
        return
    end

if whatGetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf no")
self.Owner:ChatPrint("you can't kill this guy because he is in buildmode, idiot")
self.Owner:ConCommand("kill")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else



    
    if what.Welds then
        --Already Ice
        return
    end
    
    if not what:GetModel( ):match( "models/.*%.mdl" ) then
        --Brush entity / point / something without a proper model
        return
    end
    
	if (SERVER) then
    if what:IsNPC( ) then
        what:SetSchedule( SCHED_WAIT_FOR_SCRIPT )
    end
	end

    local bone, bones, bone1, bone2, weld, weld2
    
    if not ( what:IsPlayer( ) or what:IsNPC( ) ) then
	--		self.Weapon:EmitSound("Weapon_Knife.MissCrit")
        --Make use of existing object
		
        bones = what:GetPhysicsObjectCount( )
        
        what.Welds = what.Welds or { }
        
        for bone = 1, bones do
            bone1 = bone - 1
            bone2 = bones - bone
            
            if not what.Welds[ bone2 ] then
                weld = constraint.Weld( what, what, bone1, bone2, 0 )
                
                if weld then
                    what.Welds[ bone1 ] = weld
                    what:DeleteOnRemove( weld )
                end
            end
            
            weld2 = constraint.Weld( what, what, bone1, 0, 0 )
            
            if weld2 then
                what.Welds[ bone1 + bones ] = weld2
                what:DeleteOnRemove( weld2 )
            end
            
            --what:GetPhysicsObjectNum( bone ):EnableMotion( true )
        end
        
        what:SetMaterial( "models/player/shared/Ice_player" )
      --  what:SetColor( color_Ice )
        what:SetPhysicsAttacker( self.Owner )
    else
        local rag, vel, solid, wep, fakewep
        
        bones = what:GetPhysicsObjectCount( )
        vel = what:GetVelocity( )
        
        solid = what:GetSolid( )
        
        what:SetSolid( SOLID_NONE )
        
		
		
		
	
        if bones > 1 or what:IsPlayer( ) or what:IsNPC( ) then
            rag = ents.Create( "prop_ragdoll" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
				rag:EmitSound( "weapons/icicle_freeze_victim_01.wav" )
				rag:EmitSound("TFPlayer.CritHit")
            rag:Spawn( )
			rag:SetCollisionGroup( COLLISION_GROUP_WEAPON ) --This makes us able to walk through the frozen ply/npc, and they won't fly around anymore!
			
            
            bones = rag:GetPhysicsObjectCount( )
            
            for solid = 1, what:GetNumBodyGroups( ) do
            	rag:SetBodygroup( solid, what:GetBodygroup( solid ) )
            end
            
            rag:SetSequence( what:GetSequence( ) )
            rag:SetCycle( what:GetCycle( ) )
            
            for bone = 1, bones do
                bone1 = rag:GetPhysicsObjectNum( bone )
                
                if IsValid( bone1 ) then
                    weld, weld2 = what:GetBonePosition( what:TranslatePhysBoneToBone( bone ) )
                    
                    bone1:SetPos( weld )
                    bone1:SetAngles( weld2 )
                    bone1:SetMaterial( "metal" )
                    
                    bone1:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS )
                    bone1:AddGameFlag( FVPHYSICS_HEAVY_OBJECT )
                    bone1:SetMass( 500 )
                    
                    bone1:Sleep( )
                                        
                    local bone2 = bone1
                end
            end

            
            constraint.Weld( rag, Entity( 0 ), 0, 0, 900 )
            
			
			
			
            if what:IsNPC( ) or what:IsPlayer( ) then
            	wep = what:GetActiveWeapon( )
            	
            	if wep:IsValid( ) then
            		fakewep = ents.Create( "base_anim" )
            			fakewep:SetModel( wep:GetModel( ) )
            			--fakewep:SetColor( color_Ice ) this makes the weapon not call the unknown value leaving the weapon, non pink
            			fakewep:SetParent( rag )
            			fakewep:AddEffects( EF_BONEMERGE )
            			fakewep:SetMaterial( "models/shiny" )
            			fakewep.Class = wep:GetClass( )
            		fakewep:Spawn( )
            		
            		function rag.PlayerUse( rag, pl )
        				pl:Give( fakewep.Class )
        				fakewep:Remove( )
        				hook.Remove( "KeyPress", rag )
        			end
        			
        			function rag.KeyPress( this, pl, key )
        				if key == IN_USE then
        					local tr = { }
        					tr.start = pl:EyePos( )
        					tr.endpos = pl:EyePos( ) + pl:GetAimVector( ) * 85
        					tr.filter = pl
        					
        					tr = util.TraceLine( tr )
        					
        					if tr.Entity == this then
        						this:PlayerUse( pl )
        					end
        				end
        			end
        			
        			hook.Add( "KeyPress", rag, rag.KeyPress )

            		rag.FakeWeapon = fakewep
            	end
            end
            
            self:MakeIce( rag )
            
            SafeRemoveEntityDelayed( rag, 90 )
        else
            rag = ents.Create( "prop_physics" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
            rag:Spawn( )
        end
        
        what:SetSolid( solid )
        
        rag:SetSequence( what:GetSequence( ) )
        rag:SetCycle( what:GetCycle( ) )

        rag:SetSkin( what:GetSkin( ) )
        if what:IsPlayer( ) then
            what:KillSilent( )
        else
            what:Remove( )
        end
        self:MakeIce( rag )
    end
end


/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choIce
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	// other initialize code goes here

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

function SWEP:makemahcmodel()
if (CLIENT) then
self.CModel = ClientsideModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl")
local vm = self.Owner:GetViewModel()
self.CModel:SetPos(vm:GetPos())
self.CModel:SetAngles(vm:GetAngles())
self.CModel:AddEffects(EF_BONEMERGE)
self.CModel:SetNoDraw(true)
self.CModel:SetParent(vm)
end
end

function SWEP:ViewModelDrawn()
if (CLIENT) then
if not self.CModel then self:makemahcmodel() end
if self.CModel then self.CModel:DrawModel() end
end
end





function SWEP:DrawWorldModel()

local hand, offset, rotate


if not IsValid(self.Owner) then
self:DrawModel()
return
end

self:SetWeaponHoldType("knife")
hand = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_rh"))

offset = hand.Ang:Right() * 0.9 + hand.Ang:Forward() * 1.8 - hand.Ang:Up() * 0.7

hand.Ang:RotateAroundAxis(hand.Ang:Right(), 17)
hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 0)
hand.Ang:RotateAroundAxis(hand.Ang:Up(), 140)

self:SetRenderOrigin(hand.Pos + offset)
self:SetRenderAngles(hand.Ang)

self:DrawModel()
if (CLIENT) then
end
end



-- "lua\\weapons\\tf_weapon_spy_cicle.lua"
-- Retrieved by https://github.com/c4fe/glua-steal


-- Read all weapon_ for comments not pist_ or sec_
--Original Spy-Cicle SWEP by ErrolLiamP, and props to Buu342 for helping me out :)
	

list.Add( "OverrideMaterials", "models/player/shared/ice_player" )


 function SWEP:Precache() 
 	util.PrecacheSound("weapons/icicle_freeze_victim_01.wav") 
	util.PrecacheSound("weapons/icicle_hit_world_01.wav")
	util.PrecacheSound("TFPlayer.CritHit")
	util.PrecacheSound("Critical")
	util.PrecacheSound("Weapon_Knife.HitFlesh")
	util.PrecacheMaterial("models/shiny")
	util.PrecacheModel("models/weapons/c_models/c_spy_arms.mdl" )
	util.PrecacheModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )
 end 

function SWEP:Melee()

	self.DoMelee = nil
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	if ( trace.Hit ) then
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			if self.Weapon:GetNWBool("Critical") then
			bullet.Damage = 100000000
			bullet.Force  = 8
                                                      local hpp = self.Owner:Health();
                                                      if( hpp >= 300 ) then return; end
                                                      if( hpp <= 300 ) then hpp = hpp + 70 end

                                                      self.Owner:SetHealth( hpp );
			trace.Entity:EmitSound("TFPlayer.CritHit")
			else
			bullet.Damage = math.random(25,50)
			bullet.Force  = 2.5
			end
			if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			--self.Weapon:EmitSound("Weapon_Knife.HitFlesh")
			else
			self.Weapon:EmitSound("weapons/icicle_hit_world_01.wav")
			end
			self.Owner:FireBullets(bullet) 
	end
			self.Weapon:SetNWBool("Critical", false)
end

function SWEP:EntsInSphereBack( pos, range )
	local ents = ents.FindInSphere(pos,range)
	for k, v in pairs(ents) do
		if v != self and v != self.Owner and (v:IsNPC() or v:IsPlayer()) and IsValid(v) and self:EntityFaceBack(v) then
			return true
		end
	end
	return false
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType		= "melee"
end

if (CLIENT) then
	SWEP.Category 			= "Team Fortress 2";
	SWEP.PrintName			= "cicle for spy"	
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "S"
	SWEP.ViewModelFOV		= 50
	SWEP.DrawSecondaryAmmo = false
	SWEP.DrawAmmo		= false
	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 0, 200, 0, 255 ) )
end

SWEP.Instructions			= ""
SWEP.Author   				= "ErrolLiamP"
SWEP.Contact        		= ""

--SWEP.Base 				= "sp_tf2_base"
SWEP.ViewModelFlip		= false

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true

SWEP.ViewModel        = Model( "models/weapons/c_models/c_spy_arms.mdl" )
SWEP.WorldModel        = Model("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl" )

SWEP.Primary.Delay			= 0.8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"



SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip 	= 1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"




function SWEP:EjectBrass()
end

SWEP.data 				= {}
SWEP.mode 				= "auto"

SWEP.data.semi 			= {}

SWEP.data.auto 			= {}

function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
if self.Owner:GetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf hes in buildmode kill him")
self.Owner:ChatPrint("can't use this knife in buildmode")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else




	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = CurTime() + 1
	self.Weapon:SetNWBool("BackStab",false)
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos +(self.Owner:GetAimVector( ) * 72)
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata)
	if (tr.Entity and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) and self:EntityFaceBack(tr.Entity)) or self:EntsInSphereBack( tracedata.endpos,1 ) then



	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab" ) )
		self.DoMelee = CurTime() + 0.01
	--	self.Weapon:EmitSound("Weapon_Knife.MissCrit")
		self.Weapon:SetNWBool("Critical",true)
                                    self:MakeIce( tr.Entity )
                                      
			local tr, vm, muzzle, effect
    
    vm = self.Owner:GetViewModel( )
    
    tr = { }
    
    tr.start = self.Owner:GetShootPos( )
    tr.filter = self.Owner
    tr.endpos = tr.start + self.Owner:GetAimVector( ) * 72
    tr.mins = Vector( ) * -4
    tr.maxs = Vector( ) * 4
    
    tr = util.TraceHull( tr )
    
    effect = EffectData( )
        effect:SetStart( tr.StartPos )
        effect:SetOrigin( tr.HitPos )
        effect:SetEntity( self )
        effect:SetAttachment( vm:LookupAttachment( "muzzle" ) )
    util.Effect( "", effect )
	else
                  local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_stab_a" ) )
		self.DoMelee = CurTime() + 0.1
	--	self.Weapon:EmitSound("Weapon_Knife.Miss")

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

	




local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) then
local angle = self.Owner:GetAngles().y - tr.Entity:GetAngles().y
if angle < -180 then
angle = 360 + angle
end
if angle <= 90 and angle >= -90 and self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY )
self.Backstab = 1
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if !( angle <= 90 and angle >= -90 ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
end
if !( tr.Hit and IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() || tr.Entity:IsNPC() ) ) and self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_UNDEPLOY )
self.Backstab = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 2 and self.AttackTimer <= CurTime() then
self.Owner:ChatPrint("hi")


self.Attack = 0
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end
if self.Attack == 1 and self.AttackTimer <= CurTime() then
local tr = util.TraceLine( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mask = MASK_SHOT_HULL,
} )
if !IsValid( tr.Entity ) then
tr = util.TraceHull( {
start = self.Owner:GetShootPos(),
endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
filter = self.Owner,
mins = Vector( -16, -16, 0 ),
maxs = Vector( 16, 16, 0 ),
mask = MASK_SHOT_HULL,
} )
end
if SERVER and IsValid( tr.Entity ) then
local dmg = DamageInfo()
local attacker = self.Owner
if !IsValid( attacker ) then
attacker = self
end
dmg:SetAttacker( attacker )
dmg:SetInflictor( self )
dmg:SetDamage( self.Primary.Damage )
dmg:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
tr.Entity:TakeDamageInfo( dmg )
end
if tr.Hit then
if SERVER then
if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
self.Owner:EmitSound( "Weapon_Knife.HitFlesh" )
end
if !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() ) then
self.Owner:EmitSound( "Weapon_Knife.HitWorld" )
end
end
end
self.Attack = 0
end
if self.Idle == 0 and self.IdleTimer <= CurTime() then
if SERVER then
if self.Backstab == 0 then
self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
self.Owner:ChatPrint("I'm not ready to backstab")
end
if self.Backstab == 1 then
self.Weapon:SendWeaponAnim( ACT_DEPLOY_IDLE )
self.Owner:ChatPrint("I'm ready to backstab")
end
end
self.Idle = 1
end
end
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SetNWBool("Critical",false)
	self.DoMelee = nil
	self.BackStabIdleUp = nil
	self.BackStabIdleDown = nil
	self.BackStabIdle = nil
	self.Attack = nil
	self.Weapon:SetNWBool("BackStab",false)
	self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.Owner:GetViewModel():SetMaterial( "" )
	--self.Owner:GetViewModel():SetColor(255,255,255,255)
		if ( !SERVER ) then return end

	-- We need this because attack sequences won't work otherwise in multiplayer
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_draw" ) )
	return true
end

function SWEP:Holster()
self.Weapon:SetNWBool("Watch",false)
self.DoMelee = nil
return true
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()
if self.DoMelee and CurTime()>=self.DoMelee then
self.DoMelee = nil
self:Melee()
end
if self.Idle and CurTime()>=self.Idle then
self.Idle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_idle" ) )
end
if self.Attack and CurTime()>= self.Attack then
self.Attack = nil
end
if self.Attack then
self.BackStabIdleUp = nil
self.BackStabIdleDown = nil
self.BackStabIdle = nil
end
if self.BackStabIdleUp and CurTime()>= self.BackStabIdleUp and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleUp = nil
self.Attack = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_up" ) )
self.BackStabIdle = CurTime() + 0.1
end
if self.BackStabIdle and CurTime()>= self.BackStabIdle and self.Weapon:GetNWBool("BackStab") then
self.BackStabIdle = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_idle" ) )
end
if self.BackStabIdleDown and CurTime()>= self.BackStabIdleDown and !self.Weapon:GetNWBool("BackStab") then
self.BackStabIdleDown = nil
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "eternal_backstab_down" ) )
self.Idle = CurTime() + 0.1
end

	local tra = {}
	tra.start = self.Owner:GetShootPos()
	tra.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra.filter = self.Owner
	tra.mask = MASK_SHOT
	local tracez = util.TraceLine( tra )
	local tra2 = {}
	tra2.start = self.Owner:GetShootPos()
	tra2.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 72 )
	tra2.filter = self.Owner
	tra2.mask = MASK_SHOT
	local tracez2 = util.TraceLine( tra2 )
	
		if ( tracez2.Hit ) and ( tracez2.Entity:IsNPC() or tracez2.Entity:IsPlayer() ) and self:EntityFaceBack(tracez2.Entity) and !self.Weapon:GetNWBool("BackStab") then
		self.Weapon:SetNWBool("BackStab",true)
		if self.BackStabIdleUp and CurTime()<=self.BackStabIdleUp then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleUp = CurTime() + 0.1
		self.BackStabIdleDown = nil
		end
	end
	if ( tracez.Hit ) and self.Weapon:GetNWBool("BackStab") then
		if (tracez.Entity:IsWorld() or (tracez.Entity:IsNPC() or tracez.Entity:IsPlayer()) and !self:EntityFaceBack(tracez.Entity)) then
		self.Weapon:SetNWBool("BackStab",false)
		if self.BackStabIdleDown and CurTime()<=self.BackStabIdleDown then
		self.BackStabIdleDown = nil
		self.BackStabIdleUp = nil
		else
		self.BackStabIdleDown = CurTime() + 0.25
		self.BackStabIdleUp = nil
		end
	end
	end
end

/*---------------------------------------------------------
CanPrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
end


function SWEP:MakeIce( what )
	if CLIENT then
		return
	end
    if not IsValid( what ) then
        return
    end

if whatGetNWString("BuildMode") then
print("[antikillinbuildmodeknifeshitaidjfidno]: wtf no")
self.Owner:ChatPrint("you can't kill this guy because he is in buildmode, idiot")
self.Owner:ConCommand("kill")
self.Owner:ConCommand("explode")
self.Owner:ConCommand("say","!pvp")
else



    
    if what.Welds then
        --Already Ice
        return
    end
    
    if not what:GetModel( ):match( "models/.*%.mdl" ) then
        --Brush entity / point / something without a proper model
        return
    end
    
	if (SERVER) then
    if what:IsNPC( ) then
        what:SetSchedule( SCHED_WAIT_FOR_SCRIPT )
    end
	end

    local bone, bones, bone1, bone2, weld, weld2
    
    if not ( what:IsPlayer( ) or what:IsNPC( ) ) then
	--		self.Weapon:EmitSound("Weapon_Knife.MissCrit")
        --Make use of existing object
		
        bones = what:GetPhysicsObjectCount( )
        
        what.Welds = what.Welds or { }
        
        for bone = 1, bones do
            bone1 = bone - 1
            bone2 = bones - bone
            
            if not what.Welds[ bone2 ] then
                weld = constraint.Weld( what, what, bone1, bone2, 0 )
                
                if weld then
                    what.Welds[ bone1 ] = weld
                    what:DeleteOnRemove( weld )
                end
            end
            
            weld2 = constraint.Weld( what, what, bone1, 0, 0 )
            
            if weld2 then
                what.Welds[ bone1 + bones ] = weld2
                what:DeleteOnRemove( weld2 )
            end
            
            --what:GetPhysicsObjectNum( bone ):EnableMotion( true )
        end
        
        what:SetMaterial( "models/player/shared/Ice_player" )
      --  what:SetColor( color_Ice )
        what:SetPhysicsAttacker( self.Owner )
    else
        local rag, vel, solid, wep, fakewep
        
        bones = what:GetPhysicsObjectCount( )
        vel = what:GetVelocity( )
        
        solid = what:GetSolid( )
        
        what:SetSolid( SOLID_NONE )
        
		
		
		
	
        if bones > 1 or what:IsPlayer( ) or what:IsNPC( ) then
            rag = ents.Create( "prop_ragdoll" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
				rag:EmitSound( "weapons/icicle_freeze_victim_01.wav" )
				rag:EmitSound("TFPlayer.CritHit")
            rag:Spawn( )
			rag:SetCollisionGroup( COLLISION_GROUP_WEAPON ) --This makes us able to walk through the frozen ply/npc, and they won't fly around anymore!
			
            
            bones = rag:GetPhysicsObjectCount( )
            
            for solid = 1, what:GetNumBodyGroups( ) do
            	rag:SetBodygroup( solid, what:GetBodygroup( solid ) )
            end
            
            rag:SetSequence( what:GetSequence( ) )
            rag:SetCycle( what:GetCycle( ) )
            
            for bone = 1, bones do
                bone1 = rag:GetPhysicsObjectNum( bone )
                
                if IsValid( bone1 ) then
                    weld, weld2 = what:GetBonePosition( what:TranslatePhysBoneToBone( bone ) )
                    
                    bone1:SetPos( weld )
                    bone1:SetAngles( weld2 )
                    bone1:SetMaterial( "metal" )
                    
                    bone1:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS )
                    bone1:AddGameFlag( FVPHYSICS_HEAVY_OBJECT )
                    bone1:SetMass( 500 )
                    
                    bone1:Sleep( )
                                        
                    local bone2 = bone1
                end
            end

            
            constraint.Weld( rag, Entity( 0 ), 0, 0, 900 )
            
			
			
			
            if what:IsNPC( ) or what:IsPlayer( ) then
            	wep = what:GetActiveWeapon( )
            	
            	if wep:IsValid( ) then
            		fakewep = ents.Create( "base_anim" )
            			fakewep:SetModel( wep:GetModel( ) )
            			--fakewep:SetColor( color_Ice ) this makes the weapon not call the unknown value leaving the weapon, non pink
            			fakewep:SetParent( rag )
            			fakewep:AddEffects( EF_BONEMERGE )
            			fakewep:SetMaterial( "models/shiny" )
            			fakewep.Class = wep:GetClass( )
            		fakewep:Spawn( )
            		
            		function rag.PlayerUse( rag, pl )
        				pl:Give( fakewep.Class )
        				fakewep:Remove( )
        				hook.Remove( "KeyPress", rag )
        			end
        			
        			function rag.KeyPress( this, pl, key )
        				if key == IN_USE then
        					local tr = { }
        					tr.start = pl:EyePos( )
        					tr.endpos = pl:EyePos( ) + pl:GetAimVector( ) * 85
        					tr.filter = pl
        					
        					tr = util.TraceLine( tr )
        					
        					if tr.Entity == this then
        						this:PlayerUse( pl )
        					end
        				end
        			end
        			
        			hook.Add( "KeyPress", rag, rag.KeyPress )

            		rag.FakeWeapon = fakewep
            	end
            end
            
            self:MakeIce( rag )
            
            SafeRemoveEntityDelayed( rag, 90 )
        else
            rag = ents.Create( "prop_physics" )
                rag:SetModel( what:GetModel( ) )
                rag:SetPos( what:GetPos( ) )
                rag:SetAngles( what:GetAngles( ) )
            rag:Spawn( )
        end
        
        what:SetSolid( solid )
        
        rag:SetSequence( what:GetSequence( ) )
        rag:SetCycle( what:GetCycle( ) )

        rag:SetSkin( what:GetSkin( ) )
        if what:IsPlayer( ) then
            what:KillSilent( )
        else
            what:Remove( )
        end
        self:MakeIce( rag )
    end
end


/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choIce
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	// other initialize code goes here

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

function SWEP:makemahcmodel()
if (CLIENT) then
self.CModel = ClientsideModel("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl")
local vm = self.Owner:GetViewModel()
self.CModel:SetPos(vm:GetPos())
self.CModel:SetAngles(vm:GetAngles())
self.CModel:AddEffects(EF_BONEMERGE)
self.CModel:SetNoDraw(true)
self.CModel:SetParent(vm)
end
end

function SWEP:ViewModelDrawn()
if (CLIENT) then
if not self.CModel then self:makemahcmodel() end
if self.CModel then self.CModel:DrawModel() end
end
end





function SWEP:DrawWorldModel()

local hand, offset, rotate


if not IsValid(self.Owner) then
self:DrawModel()
return
end

self:SetWeaponHoldType("knife")
hand = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_rh"))

offset = hand.Ang:Right() * 0.9 + hand.Ang:Forward() * 1.8 - hand.Ang:Up() * 0.7

hand.Ang:RotateAroundAxis(hand.Ang:Right(), 17)
hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 0)
hand.Ang:RotateAroundAxis(hand.Ang:Up(), 140)

self:SetRenderOrigin(hand.Pos + offset)
self:SetRenderAngles(hand.Ang)

self:DrawModel()
if (CLIENT) then
end
end



