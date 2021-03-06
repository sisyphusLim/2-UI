local _, ns = ...
local M, R, U, I = unpack(ns)
local module = M:RegisterModule("AurasTable")
local pairs, next, format, wipe = pairs, next, string.format, wipe

-- AuraWatch
local AuraWatchList = {}
local groups = {
	-- groups name = direction, interval, mode, iconsize, position, barwidth
	["ClassBar"] = {"RIGHT", 6, "ICON", 36, R.Auras.ClassBarPos},
	["Player Aura"] = {"UP", 2, "BAR2", 21, R.Auras.PlayerAuraPos, 60},
	["Target Aura"] = {"UP", 2, "BAR", 28, R.Auras.TargetAuraPos, 80},
	["Special Aura"] = {"UP", 2, "BAR2", 28, R.Auras.SpecialPos, 80},
	["Focus Aura"] = {"UP", 2, "BAR", 21, R.Auras.FocusPos, 60},
	["Spell Cooldown"] = {"LEFT", 2, "ICON", 32, R.Auras.CDPos},
	["Enchant Aura"] = {"UP", 2, "ICON", 32, R.Auras.EnchantPos},	
	["Raid Buff"] = {"UP", 2, "ICON", 36, R.Auras.RaidBuffPos},
	["Raid Debuff"] = {"UP", 2, "ICON", 36, R.Auras.RaidDebuffPos},
	["Warning"] = {"UP", 2, "ICON", 32, R.Auras.WarningPos},
	["InternalCD"] = {"DOWN", 2, "BAR2", 16, R.Auras.InternalPos, 120},
	["Absorb"] = {"DOWN", 2, "TEXT", 21, R.Auras.AbsorbPos},
	["Shield"] = {"DOWN", 2, "TEXT", 21, R.Auras.ShieldPos},
}

local function newAuraFormat(value)
	local newTable = {}
	for _, v in pairs(value) do
		local id = v.AuraID or v.SpellID or v.ItemID or v.SlotID or v.TotemID or v.IntID
		if id then
			newTable[id] = v
		end
	end
	return newTable
end

function module:AddNewAuraWatch(class, list)
	for _, k in pairs(list) do
		for _, v in pairs(k) do
			local spellID = v.AuraID or v.SpellID
			if spellID then
				local name = GetSpellInfo(spellID)
				if not name then
					wipe(v)
					if I.isDeveloper then print(format("|cffFF0000XXX:|r '%s' %s", class, spellID)) end
				end
			end
		end
	end

	if class ~= "ALL" and class ~= I.MyClass then return end
	if not AuraWatchList[class] then AuraWatchList[class] = {} end

	for name, v in pairs(list) do
		local direction, interval, mode, size, pos, width = unpack(groups[name])
		tinsert(AuraWatchList[class], {
			Name = name,
			Direction = direction,
			Interval = interval,
			Mode = mode,
			IconSize = size,
			Pos = pos,
			BarWidth = width,
			List = newAuraFormat(v)
		})
	end
end

function module:AddDeprecatedGroup()
	if not MaoRUIPerDB["AuraWatch"]["DeprecatedAuras"] then return end

	for name, value in pairs(R.DeprecatedAuras) do
		for _, list in pairs(AuraWatchList["ALL"]) do
			if list.Name == name then
				local newTable = newAuraFormat(value)
				for spellID, v in pairs(newTable) do
					list.List[spellID] = v
				end
			end
		end
	end
	wipe(R.DeprecatedAuras)
end

-- RaidFrame spells
local RaidBuffs = {}
function module:AddClassSpells(list)
	for class, value in pairs(list) do
		RaidBuffs[class] = value
	end
end

-- RaidFrame debuffs
local RaidDebuffs = {}
function module:RegisterDebuff(_, instID, _, spellID, level)
	local instName = EJ_GetInstanceInfo(instID)
	if not instName then
		if I.isDeveloper then print("Invalid instance ID: "..instID) end
		return
	end

	if not RaidDebuffs[instName] then RaidDebuffs[instName] = {} end
	if level then
		if level > 6 then level = 6 end
	else
		level = 2
	end

	RaidDebuffs[instName][spellID] = level
end

-- Party watcher spells
function module:UpdatePartyWatcherSpells()
	if not next(MaoRUIDB["PartyWatcherSpells"]) then
		for spellID, duration in pairs(R.PartysSpells) do
			local name = GetSpellInfo(spellID)
			if name then
				MaoRUIDB["PartyWatcherSpells"][spellID] = duration
			end
		end
	end
end

function module:OnLogin()
	for instName, value in pairs(RaidDebuffs) do
		for spell, priority in pairs(value) do
			if MaoRUIDB["RaidDebuffs"][instName] and MaoRUIDB["RaidDebuffs"][instName][spell] and MaoRUIDB["RaidDebuffs"][instName][spell] == priority then
				MaoRUIDB["RaidDebuffs"][instName][spell] = nil
			end
		end
	end
	for instName, value in pairs(MaoRUIDB["RaidDebuffs"]) do
		if not next(value) then
			MaoRUIDB["RaidDebuffs"][instName] = nil
		end
	end

	self:AddDeprecatedGroup()
	R.AuraWatchList = AuraWatchList
	R.RaidBuffs = RaidBuffs
	R.RaidDebuffs = RaidDebuffs

	if not MaoRUIDB["CornerBuffs"][I.MyClass] then MaoRUIDB["CornerBuffs"][I.MyClass] = {} end
	if not next(MaoRUIDB["CornerBuffs"][I.MyClass]) then
		M.CopyTable(R.CornerBuffs[I.MyClass], MaoRUIDB["CornerBuffs"][I.MyClass])
	end

	self:UpdatePartyWatcherSpells()

	-- Filter bloodlust for healers
	local bloodlustList = {57723, 57724, 80354, 264689}
	local function filterBloodlust()
		for _, spellID in pairs(bloodlustList) do
			MaoRUIDB["CornerBuffs"][I.MyClass][spellID] = I.Role ~= "Healer" and {"BOTTOMLEFT", {1, .8, 0}, true} or nil
			R.RaidBuffs["WARNING"][spellID] = (I.Role ~= "Healer")
		end
	end
	filterBloodlust()
	M:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", filterBloodlust)
end