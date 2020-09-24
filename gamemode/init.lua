include("shared.lua")

-- Mark all client side only files to be sent to client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("client/achievements/cl_ach_base.lua")
AddCSLuaFile("client/menus/cl_difficulty_vote.lua")
AddCSLuaFile("client/menus/cl_scoreboard.lua")
AddCSLuaFile("client/cl_hud.lua")
AddCSLuaFile("client/menus/cl_f4_menu.lua")
AddCSLuaFile("client/menus/cl_pets.lua")
AddCSLuaFile("client/menus/cl_new_player.lua")
AddCSLuaFile("client/menus/cl_squads.lua")
AddCSLuaFile("client/menus/cl_otf.lua")

-- Server side files only
include("server/commands/sv_commands_list.lua")
include("server/stats/sv_player_levels.lua")
include("server/saving_modules/sv_data_flatfile.lua")
include("server/sv_change_map.lua")
include("server/extend/sv_network.lua")
include("server/config/achievements/sv_ach.lua")
include("server/sv_unstuck.lua")
include("server/config/sv_difficulty.lua")
include("server/sv_spectate.lua")
include("server/stats/sv_pets_levels.lua")
include("server/config/maps/sv_loyal.lua")
include("server/sv_afkhandler.lua")
include("server/config/maps/sv_lobby_init_maps.lua")
include("server/config/maps/sv_hl2_init_maps.lua")
include("server/config/maps/sv_ep1_init_maps.lua")
include("server/config/maps/sv_coop_init_maps.lua")
include("server/config/maps/sv_vortex.lua")
include("server/config/maps/sv_lambda.lua")

--HL2CR Convars
CreateConVar("hl2cr_allowsuicide", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Disable kill command", 0, 1) 
CreateConVar("hl2cr_respawntime", 10, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE})
CreateConVar("hl2cr_difficulty", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Change Difficulty", 1, 3)
CreateConVar("hl2cr_survivalmode", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Change Difficulty", 0, 1)

--Difficulty Variant Convars
CreateConVar("hl2cr_doublehp", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Enable/Disable Double NPC HP", 0, 1)
CreateConVar("hl2cr_specials", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Enable/Disable Special NPCs", 0, 1)

--Pet Convars
CreateConVar("hl2cr_petrecovertime", 15, FCVAR_NOTIFY, "Change Pets recovering time", 1, 999)
CreateConVar("hl2cr_petrecovery", 10, FCVAR_NOTIFY, "Change Pets recover HP", 1, 999)

--Events
CreateConVar("hl2cr_halloween", 0, FCVAR_NOTIFY, "Enable/Disable Halloween Event", 0, 1)
CreateConVar("hl2cr_christmas", 0, FCVAR_NOTIFY, "Enable/Disable Christmas Event", 0, 1)

--Ammo Limits
CreateConVar("max_pistol", 				150, 	{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_357", 				12, 	{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_smg1", 				225, 	{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_smg1_grenade", 		3, 		{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_ar2", 				60, 	{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_ar2_ball", 			3, 		{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_buckshot", 			30, 	{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_crossbowbolt", 		10, 	{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_grenade", 			5, 		{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_slam", 				5, 		{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)
CreateConVar("max_rpg_round", 			3, 		{FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, true)

TEAM_ALIVE = 1
team.SetUp(TEAM_ALIVE, "Alive", Color(81, 124, 199, 255))

TEAM_COMPLETED_MAP = 2
team.SetUp(TEAM_COMPLETED_MAP, "Completed Map", Color(81, 124, 199, 255))

TEAM_DEAD = 3
team.SetUp(TEAM_DEAD, "Terminated", Color(81, 124, 199, 255))

TEAM_LOYAL = 4
team.SetUp(TEAM_LOYAL, "Loyal Combine", Color(0, 225, 255, 255))

local meta = FindMetaTable( "Entity" )
if not meta then return end

version = "0.2.3"

function meta:IsPet()
	if self:IsValid() and self:IsNPC() and self:GetNWBool("PetActive") then
		return true
	else
		return false
	end
end
local FRIENDLY_NPCS = {
	["npc_kleiner"] = true,
	["npc_monk"] = true,
	["npc_alyx"] = true,
	["npc_barney"] = true,
	["npc_citizen"] = true,
	["npc_vortigaunt"] = true,
	["npc_mossman"] = true
}

function meta:IsFriendly()
	if self:IsValid() and self:IsNPC() and FRIENDLY_NPCS[self:GetClass()] then
		return true
	else
		return false
	end
end
randomExchange = 0
function GM:Initialize()
	isAliveSurv = true
	pets = false
	airboatSpawnable = false
	airboatGunSpawnable = false
	fixAI = false
	randomExchange = math.random(100, 1000)
end

function GM:ShowHelp(ply)
	net.Start("Greetings_new_player")
		net.WriteString(version)
	net.Send(ply)
end



function GM:ShowTeam(ply)
	if ply.spawnJeep then
		ply.spawnJeep:Remove()
		ply.AllowSpawn = true
		ply.hasSeat = false
	end

	if ply.spawnAirboat then
		ply.spawnAirboat:Remove()
		ply.AllowSpawn = true
	end

	if ply.spawnAirboatGun then
		ply.spawnAirboatGun:Remove()
		ply.AllowSpawn = true
	end
end
local VEHICLES = {
	["prop_vehicle_airboat"] = true,
	["prop_vehicle_jeep"] = true
}
hook.Add( "ShouldCollide", "hl2crShouldCollide", function( ent1, ent2 )

	if ent1:IsPlayer( ) and ent2:IsPlayer( ) and ent2:Team( ) == ent1:Team( ) then return false; end
	if ent1:IsPlayer( ) and ent2:IsPlayer( ) and ent2:Team( ) ~= ent1:Team( ) then return true; end
	
	-- Set Up Pets Collision with Players
	if ent1:IsPet( ) and ent2:IsPlayer( ) then return false; end
	if ent2:IsPet( ) and ent1:IsPlayer( ) then return false; end

	if ent1:IsFriendly( ) and ent2:IsPlayer( ) then return false; end
	if ent2:IsFriendly( ) and ent1:IsPlayer( ) then return false; end

	if VEHICLES[ent1:GetClass()] and ent2:IsPlayer( ) then return false; end
	if VEHICLES[ent2:GetClass()] and ent1:IsPlayer( ) then return false; end

end )

lockedSpawn = false

function GM:ShowSpare1(ply)
	local jeep = {
		Name = "Jeep",
		Class = "prop_vehicle_jeep_old",
		Model = "models/buggy.mdl",
		KeyValues = {
			vehiclescript = "scripts/vehicles/jeep_test.txt",
			EnableGun = 1
		}
	}
	list.Set( "Vehicles", "Jeep", jeep )
	
	local airboat = {
		Name = "Airboat",
		Class = "prop_vehicle_airboat",
		Category = Category,
		Model = "models/airboat.mdl",
		KeyValues = {
			vehiclescript = "scripts/vehicles/airboat.txt",
			EnableGun = 0
		}
	}
	
	list.Set( "Vehicles", "Airboat", airboat )
	
	local airboatGun = {
		Name = "AirboatGun",
		Class = "prop_vehicle_airboat",
		Category = Category,
		Model = "models/airboat.mdl",
		KeyValues = {
			vehiclescript = "scripts/vehicles/airboat.txt",
			EnableGun = 1
		}
	}
	
	list.Set( "Vehicles", "AirboatGun", airboatGun )
	
	if ply.loyal then return end
	
	if game.GetMap() == "d2_coast_01" or game.GetMap() == "d2_coast_03" or game.GetMap() == "d2_coast_04" or game.GetMap() == "d2_coast_05" or game.GetMap() == "d2_coast_06" or game.GetMap() == "d2_coast_07" or game.GetMap() == "d2_coast_09" or (game.GetMap() == "d2_coast_10" and not lockedSpawn) then
		if ply.AllowSpawn then
			ply.spawnJeep = ents.Create(jeep.Class)
			ply.spawnJeep:SetModel(jeep.Model)
			for k, v in pairs( jeep.KeyValues ) do
				ply.spawnJeep:SetKeyValue(k, v)
			end
			ply.spawnJeep:SetPos(Vector(ply:EyePos().x, ply:EyePos().y, ply:EyePos().z - 35))
			ply.spawnJeep:Spawn()
			ply.spawnJeep:SetOwner(ply)
			ply.spawnJeep:Fire( "addoutput", "targetname jeep" )
			ply.AllowSpawn = false
		end
		
	elseif game.GetMap() == "d1_canals_06" or game.GetMap() == "d1_canals_07" or game.GetMap() == "d1_canals_08" or game.GetMap() == "d1_canals_09" or game.GetMap() == "d1_canals_10" or game.GetMap() == "d1_canals_11" and not airboatGunSpawnable or airboatSpawnable then
		if ply.AllowSpawn then
			ply.spawnAirboat = ents.Create(airboat.Class)
			ply.spawnAirboat:SetModel(airboat.Model)
			for k, v in pairs( airboat.KeyValues ) do
				ply.spawnAirboat:SetKeyValue(k, v)
			end
			ply.spawnAirboat:SetPos(Vector(ply:EyePos().x, ply:EyePos().y, ply:EyePos().z - 15))
			ply.spawnAirboat:Spawn()
			ply.spawnAirboat:SetOwner(ply)
			ply.spawnAirboat:Fire( "addoutput", "targetname airboat" )
			ply.AllowSpawn = false
		end
	elseif (game.GetMap() == "d1_canals_11" and airboatGunSpawnable) or game.GetMap() == "d1_canals_12" or game.GetMap() == "d1_canals_13" then
		if ply.AllowSpawn then
			ply.spawnAirboatGun = ents.Create(airboatGun.Class)
			ply.spawnAirboatGun:SetModel(airboatGun.Model)
			for k, v in pairs(airboatGun.KeyValues) do
				ply.spawnAirboatGun:SetKeyValue(k, v)
			end
			ply.spawnAirboatGun:SetPos(Vector(ply:EyePos().x, ply:EyePos().y, ply:EyePos().z - 15))
			ply.spawnAirboatGun:Spawn()
			ply.spawnAirboatGun:SetOwner(ply)
			ply.spawnAirboatGun:Fire( "addoutput", "targetname airboat" )
			ply.spawnAirboatGun:Activate()
			ply.AllowSpawn = false
		end
	else
		ply:ChatPrint("Vehicles are disabled on this map!")
	end
	
end

function GM:CanPlayerEnterVehicle(ply)
	if not ply.spawnJeep then
		return true
	end
	
	if ply.spawnJeep:GetOwner() == ply and ply.spawnJeep:GetOwner():IsValid() then
		return true
	end
	
	return false
end
function GM:ShowSpare2(ply)
	local red = ply.hl2cPersistent.NPCColourSettings.r
	local blue = ply.hl2cPersistent.NPCColourSettings.b
	local green = ply.hl2cPersistent.NPCColourSettings.g
	local alpha = ply.hl2cPersistent.NPCColourSettings.a
	
	local eventNumber = 0
	
	if GetConVar("hl2cr_halloween"):GetInt() == 1 then
		eventNumber = 1
	end
	
	if ply.loyal then
		ply:ChatPrint("You cannot access the F4 menu while a loyal player")
	else
		net.Start("Open_F4_Menu")
			net.WriteTable(ply.hl2cPersistent.Inventory)
			net.WriteInt(randomExchange, 32)
			if table.HasValue(ply.hl2cPersistent.Achievements, "One_True_Freeman") then
				net.WriteBool(true)
			else
				net.WriteBool(false)
			end
			net.WriteColor(Color(red, blue, green, alpha))
			net.WriteBool(ply.hl2cPersistent.NPCColourEnabled)
			net.WriteString(ply.hl2cPersistent.NPCFont)
			net.WriteInt(ply.hl2cPersistent.EventItems, 32)
			net.WriteInt(eventNumber, 8)
			net.WriteTable(ply.hl2cPersistent.HatTable)
		net.Send(ply)
	end
end

VOTE_REQUIRED = {
	["EasyVotes"] = 0,
	["MediumVotes"] = 0,
	["HardVotes"] = 0,
	["SurvVotes"] = 0,
	["neededVotes"] = 0,
	["neededVotesRestart"] = 0
}

DIFFVAR_VOTE_REQUIRED = {
	["DoubleHP"] = 0,
	["Special"] = 0
}

hook.Add("Think", "votingThink", function()
	local easyRequired = math.ceil(#player.GetAll() / 2)
	local mediumRequired = math.ceil(#player.GetAll() / 2)
	local hardRequired = math.ceil(#player.GetAll() / 2)
	
	local HPRequired = math.ceil(#player.GetAll() / 2)
	local specialRequired = math.ceil(#player.GetAll() / 2)

	local survRequired = #player.GetAll()
	local neededVotes = #player.GetAll()
	local neededVotesRestart = #player.GetAll()
	
	VOTE_REQUIRED["EasyVotes"] = easyRequired
	VOTE_REQUIRED["MediumVotes"] = mediumRequired
	VOTE_REQUIRED["HardVotes"] = hardRequired
	VOTE_REQUIRED["SurvVotes"] = survRequired
	VOTE_REQUIRED["neededVotes"] = neededVotes
	VOTE_REQUIRED["neededVotesRestart"] = neededVotesRestart
	
	DIFFVAR_VOTE_REQUIRED["DoubleHP"] = HPRequired
	DIFFVAR_VOTE_REQUIRED["Special"] = specialRequired
	
end)

gameevent.Listen("player_connect")
hook.Add("player_connect", "playerConnectSound", function(data)
	local id = data.networkid
	
	for k, v in pairs(player.GetAll()) do
		net.Start("AdminJoin")
			net.WriteString(id)
		net.Send(v)
	end
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "playerDisconnect", function(data)
	local name = data.name
	local steamid = data.networkid
	local id = data.userid
	local bot = data.bot
	local reason = data.reason
	
	PrintMessage( HUD_PRINTTALK, steamid .. ": " .. name .. " has disconnected from the server, Reason: " .. reason)
	
end)

hook.Add( "PrePACEditorOpen", "RestrictToSuperadmin", function( ply )
	if not ply:IsSuperAdmin( ) then
		return false
	end
end)

function SetUpMap()
	if game.GetMap() == "hl2cr_lobby" then
		SetupLobbyMap()
	elseif string.match(game.GetMap(), "d1_") or string.match(game.GetMap(), "d2_") 
	or string.match(game.GetMap(), "d3_") then
		SetupHL2Map()
	elseif string.match(game.GetMap(), "ep1_") then
		SetupEP1Map()
	elseif string.match(game.GetMap(), "level") then
		SetupCoopMap01()
	end
end
hook.Add("InitPostEntity", "SetupLua", SetUpMap)
hook.Add("PostCleanupMap", "SetupHL2Lua", SetUpMap)