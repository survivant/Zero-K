function gadget:GetInfo()
  return {
    name      = "Comander Upgrade",
    desc      = "",
    author    = "Google Frog",
    date      = "30 December 2015",
    license   = "GNU GPL, v2 or later",
    layer     = 1,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--SYNCED
if (not gadgetHandler:IsSyncedCode()) then
   return false
end

local INLOS = {inlos = true}

local moduleDefs, emptyModules, chassisDefs, upgradeUtilities = include("LuaRules/Configs/dynamic_comm_defs.lua")
include("LuaRules/Configs/customcmds.h.lua")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function SetUnitRulesModule(unitID, counts, moduleDefID)
	local slotType = moduleDefs[moduleDefID].slotType
	counts[slotType] = counts[slotType] + 1
	Spring.SetUnitRulesParam(unitID, "comm_" .. slotType .. "_" .. counts[slotType], moduleDefID, INLOS)
end

local function SetUnitRulesModuleCounts(unitID, counts)
	for name, value in pairs(counts) do
		Spring.SetUnitRulesParam(unitID, "comm_" .. name .. "_count", value, INLOS)
	end
end

local function UpdateUnitWithSharedData(unitID, data)
	if data.speedMult then
		Spring.SetUnitRulesParam(unitID, "upgradesSpeedMult", data.speedMult, INLOS)
		GG.UpdateUnitAttributes(unitID)
	end
	
	if data.metalIncome and GG.Overdrive_AddUnitResourceGeneration then
		GG.Overdrive_AddUnitResourceGeneration(unitID, data.metalIncome, data.energyIncome)
	end
	
	if data.healthBonus then
		local health, maxHealth = Spring.GetUnitHealth(unitID)
		Spring.SetUnitHealth(unitID, health + data.healthBonus)
		Spring.SetUnitMaxHealth(unitID, maxHealth + data.healthBonus)
	end

	local env = Spring.UnitScript.GetScriptEnv(unitID)
	Spring.UnitScript.CallAsUnit(unitID, env.UpdateWeapons, data.weapon1, data.weapon2, data.shield)
end

local function Upgrades_CreateUpgradedUnit(defName, x, y, z, face, unitTeam, isBeingBuilt, upgradeDef)
	local unitID = Spring.CreateUnit(defName, x, y, z, face, unitTeam, isBeingBuilt)
	
	if not unitID then
		return false
	end
	
	-- Start setting required unitRulesParams
	local totalCost = upgradeDef.totalCost
	Spring.SetUnitRulesParam(unitID, "comm_level", upgradeDef.level, INLOS)
	Spring.SetUnitRulesParam(unitID, "comm_chassis", upgradeDef.chassis, INLOS)
	Spring.SetUnitRulesParam(unitID, "comm_cost", totalCost, INLOS)
	
	Spring.SetUnitCosts(unitID, {
		buildTime = totalCost,
		metalCost = totalCost,
		energyCost = totalCost
	})
	
	local moduleList = upgradeDef.moduleList
	
	-- Set module unitRulesParams
	local counts = {module = 0, weapon = 0}
	for i = 1, #moduleList do
		local moduleDefID = moduleList[i]
		SetUnitRulesModule(unitID, counts, moduleDefID)
	end
	SetUnitRulesModuleCounts(unitID, counts)
	
	-- Set module effects
	local moduleByDefID = upgradeUtilities.ModuleListToByDefID(moduleList)
	
	local sharedData = {}
	for i = 1, #moduleList do
		local moduleDef = moduleDefs[moduleList[i]]
		if moduleDef.applicationFunction then
			moduleDef.applicationFunction(unitID, moduleByDefID, sharedData)
		end
	end
	
	UpdateUnitWithSharedData(unitID, sharedData)
	
	return unitID
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	Spring.SetUnitRulesParam(unitID, "comm_level", 0, INLOS)
	Spring.SetUnitRulesParam(unitID, "comm_chassis", 1, INLOS)
	Spring.SetUnitRulesParam(unitID, "comm_cost", 1200, INLOS)
	Spring.SetUnitRulesParam(unitID, "comm_name", "Guinea Pig", INLOS)
	Spring.SetUnitRulesParam(unitID, "comm_module_count", 0, INLOS)
	Spring.SetUnitRulesParam(unitID, "comm_weapon_count", 0, INLOS)
	Spring.SetUnitRulesParam(unitID, "upgradesSpeedMult", 1)

	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if env.UpdateWeapons then
		Spring.UnitScript.CallAsUnit(unitID, env.UpdateWeapons)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function Upgrades_GetValidAndMorphAttributes(unitID, params)
	-- Initial data and easy sanity tests
	if #params <= 4 then
		return false
	end
	
	local pLevel = params[1]
	local pChassis = params[2]
	local pAlreadyCount = params[3]
	local pNewCount = params[4]
	
	if #params ~= 4 + pAlreadyCount + pNewCount then
		return false
	end
	
	-- Make sure level and chassis match.
	local level = Spring.GetUnitRulesParam(unitID, "comm_level")
	local chassis = Spring.GetUnitRulesParam(unitID, "comm_chassis")
	if level ~= pLevel or chassis ~= pChassis then
		return false
	end
	
	-- Determine what the command thinks the unit already owns
	local index = 5
	local pAlreadyOwned = {}
	for i = 1, pAlreadyCount do
		pAlreadyOwned[i] = params[index] 
		index = index + 1
	end
	
	-- Find the modules which are already owned
	local alreadyOwned = {}
	local fullModuleList = {}
	local weaponCount = Spring.GetUnitRulesParam(unitID, "comm_weapon_count")
	for i = 1, weaponCount do
		local weapon = Spring.GetUnitRulesParam(unitID, "comm_weapon_" .. i)
		alreadyOwned[#alreadyOwned + 1] = weapon
		fullModuleList[#fullModuleList + 1] = weapon
	end
	
	local moduleCount = Spring.GetUnitRulesParam(unitID, "comm_module_count")
	for i = 1, moduleCount do
		local module = Spring.GetUnitRulesParam(unitID, "comm_module_" .. i)
		alreadyOwned[#alreadyOwned + 1] = module
		fullModuleList[#fullModuleList + 1] = module
	end
	
	-- Strictly speaking sort is not required. It is for leniency
	table.sort(alreadyOwned)
	table.sort(pAlreadyOwned)
	
	if not upgradeUtilities.ModuleSetsAreIdentical(alreadyOwned, pAlreadyOwned) then
		return false
	end
	
	-- Check the validity of the new module set
	local pNewModules = {}
	for i = 1, pNewCount do
		pNewModules[#pNewModules + 1] = params[index] 
		index = index + 1
	end
	
	-- Finish the full modules list
	-- Empty module slots do not make it into this list
	for i = 1, #pNewModules  do
		if not emptyModules[pNewModules[i]] then
			fullModuleList[#fullModuleList + 1] = pNewModules[i] 
		end
	end
	
	local modulesByDefID = upgradeUtilities.ModuleListToByDefID(fullModuleList)
	
	-- Determine Cost and check that the new modules are valid.
	local levelDefs = chassisDefs[chassis].levelDefs[level+1]
	local slotDefs = levelDefs.upgradeSlots
	local cost = 0
	
	for i = 1, #pNewModules do
		local moduleDefID = pNewModules[i]
		if upgradeUtilities.ModuleIsValid(level, chassis, slotDefs[i].slotType, moduleDefID, modulesByDefID) then
			cost = cost + moduleDefs[moduleDefID].cost
		else
			return false
		end
	end
	
	-- The command is now known to be valid. Construct the morphDef.
	local cost = cost + levelDefs.morphBaseCost
	local targetUnitDefID = levelDefs.morphUnitDefFunction(modulesByDefID)
	
	local morphTime = cost/levelDefs.morphBuildPower
	local increment = (1 / (30 * morphTime))
	
	local morphDef = {
		upgradeDef = {
			name = Spring.GetUnitRulesParam(unitID, "comm_name"),
			totalCost = cost + Spring.Utilities.GetUnitCost(unitID),
			level = level + 1,
			chassis = chassis,
			moduleList = fullModuleList
		},
		combatMorph = true,
		metal = cost,
		time = morphTime,
		into = targetUnitDefID,
		increment = increment,
		stopCmd = CMD_UPGRADE_STOP,
		resTable = {
			m = (increment * cost),
			e = (increment * cost)
		},
		cmd = nil, -- for completeness
		facing = nil,
	}
	
	return true, targetUnitDefID, morphDef
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:Initialize()
	GG.Upgrades_CreateUpgradedUnit         = Upgrades_CreateUpgradedUnit
	GG.Upgrades_GetValidAndMorphAttributes = Upgrades_GetValidAndMorphAttributes
	
	-- load active units
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = Spring.GetUnitDefID(unitID)
		local teamID = Spring.GetUnitTeam(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	
end