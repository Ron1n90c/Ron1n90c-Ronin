-- Ronin DPS - Retail (Midnight) + WoW: Forever.
-- Built from OUR tank packs, in the same style: Priority loop, small steps, every step
-- <= 250 characters once compiled, no trinkets, no big defensives.
-- Retail modifiers (same as the tank packs + Ctrl): Shift = heal, Alt = CC, Ctrl = AoE (every step has an AoE line: hold Ctrl and it casts the AoE spell of that
-- step, without Ctrl it casts the single-target spells).
-- Forever modifiers: Shift = heal, Ctrl = CC, Alt = interrupt (no AoE key).
-- A spell you did not talent is simply skipped.
local _, Ronin = ...

local function S(spell, flags) return { spell = spell, flags = flags or "" } end
local function R(line) return { raw = line, spell = "", flags = "" } end

local THANKS = ""
-- Same engine as the tank packs: Priority loop, small steps, [nochanneling] gates on
-- channelers, castsequences with reset=4, every step <= 250 characters once compiled.
local function CastLine(e, nomod, gate)
    if e.raw then return e.raw end
    if e.flags:find("s", 1, true) then
        return "/castsequence [nomod" .. (gate and ("," .. gate) or "") .. "] reset=12/target " .. e.spell .. ", Null, Null"
    end
    local conds = {}
    if gate then conds[#conds + 1] = gate end
    if e.flags:find("c", 1, true) then conds[#conds + 1] = "combat" end
    if e.flags:find("p", 1, true) then conds[#conds + 1] = "@player" end
    if #conds == 0 then return "/cast " .. e.spell end
    return "/cast [" .. table.concat(conds, ",") .. "]" .. e.spell
end
local function BuildMacro(spec, tier, list, raid)
    local lines = {}
    if tier == 1 then
        lines[#lines + 1] = raid and "/targetenemy [noexists]" or "/targetenemy [noharm][dead]"
        if not spec.preall then for _, p in ipairs(spec.pre or {}) do lines[#lines + 1] = p end end
    end
    if spec.preall then for _, p in ipairs(spec.pre or {}) do lines[#lines + 1] = p end end
    for _, u in ipairs(spec.util) do lines[#lines + 1] = u end
    for _, e in ipairs(list) do lines[#lines + 1] = CastLine(e, spec.nomod, spec.gate) end
    return table.concat(lines, "\n")
end
local function BuildActions(spec, tiers, raid)
    local loop = { Type = "Loop", StepFunction = "Priority", Repeat = "1" }
    for i, list in ipairs(tiers) do
        loop[i] = { Type = "Action", type = "macro", macro = BuildMacro(spec, i, list, raid) }
    end
    return { loop }
end
local function Copy(t) local o = {} for i, v in ipairs(t) do o[i] = v end return o end
-- Raid: the cooldown step (always the LAST one) is pressed second most.
local function RaidOrder(list)
    local o = Copy(list)
    local cd = table.remove(o)
    table.insert(o, 2, cd)
    return o
end
-- Mythic+: the cooldown step (always the LAST one) moves to step 2, so it fires right at the pull.
local function MplusOrder(list) return RaidOrder(list) end
-- Delve (solo): cooldowns at step 2 like Mythic+, plus the class defensives at step 4.
local function DelveOrder(list, def)
    local o = MplusOrder(list)
    table.insert(o, 4, def)
    return o
end
-- Beginner: the big defensives are in the macro too (step 3), press and forget.
local function BeginnerOrder(list, def)
    local o = Copy(list)
    table.insert(o, 3, def)
    return o
end
local function DPS(name, specID, spec, list, def, notes, lvl)
    return {
        MetaData = {
            Name = name, Author = "Ronin", SpecID = specID, Default = 1,
            MythicPlus = 1, Heroic = 1, Dungeon = 1, Timewalking = 1, Mythic = 1,
            PVP = 1, Raid = 2, Scenario = 3, Notes = notes, Help = notes,
        },
        Versions = {
            [1] = { Label = "Mythic+",  Actions = BuildActions(spec, MplusOrder(list)), InbuiltVariables = { Combat = true } },
            [2] = { Label = "Raid",     Actions = BuildActions(spec, RaidOrder(list), true), InbuiltVariables = { Combat = true } },
            [3] = { Label = "Delve",    Actions = BuildActions(spec, DelveOrder(list, def)), InbuiltVariables = { Combat = true } },
            [4] = { Label = "Beginner", Actions = BuildActions(spec, BeginnerOrder(list, def)), InbuiltVariables = { Combat = true } },
            [5] = { Label = "Leveling", Actions = BuildActions(spec, lvl), InbuiltVariables = { Combat = true } },
        },
    }
end

local C_DK = { stop = false, util = { "/cast [mod:shift]Death Strike;[mod:alt]Asphyxiate" } }
local D_DK = { S("Anti-Magic Shell", "c") }

local C_DH = { gate = "nochanneling:Eye Beam", stop = false, util = { "/cast [mod:shift]Disrupt;[mod:alt]Chaos Nova" } }
local D_DH = { S("Blur", "c") }

local C_DEV = { gate = "nochanneling", stop = false, util = { "/cast [mod:shift]Disrupt;[mod:alt]Chaos Nova" } }
local D_DEV = { S("Soul Immolation", "c") }

local C_SHA = { stop = false, util = { "/cast [mod:shift,@player]Healing Surge;[mod:alt]Capacitor Totem" } }
local D_SHA = { S("Astral Shift", "c") }

local C_HUNP = { stop = false, pre = { "/cast [@pet,dead]Revive Pet;[nopet]Call Pet 1", "/petattack" }, util = { "/cast [mod:shift]Exhilaration;[mod:alt]Intimidation" } }
local D_HUNP = { S("Survival of the Fittest", "c") }

local C_HUNM = { gate = "nochanneling", stop = false, util = { "/cast [mod:shift]Exhilaration;[mod:alt,@cursor]Binding Shot" } }
local D_HUNM = { S("Survival of the Fittest", "c") }

local C_PAL = { stop = false, util = { "/cast [mod:shift,@player]Word of Glory;[mod:alt]Hammer of Justice" } }
local D_PAL = { S("Shield of Vengeance", "c") }

local C_WAR = { stop = false, util = { "/cast [mod:shift]Impending Victory;[mod:alt]Shockwave" } }
local D_WAR = { S("Die by the Sword", "c") }

local C_WARF = { stop = false, util = { "/cast [mod:shift]Impending Victory;[mod:alt]Shockwave" } }
local D_WARF = { S("Enraged Regeneration", "c") }

local C_MONK = { gate = "nochanneling:Fists of Fury", stop = false, util = { "/cast [mod:shift,@player]Vivify;[mod:alt]Leg Sweep" } }
local D_MONK = { S("Touch of Karma", "c") }

local C_FERAL = { stop = false, preall = true, pre = { "/cast [noform:2]Cat Form" }, util = { "/cast [mod:shift,@player]Regrowth;[mod:alt]Mighty Bash" } }
local D_FERAL = { S("Barkskin", "c") }

local C_BAL = { stop = false, preall = true, pre = { "/cast [noform:4]Moonkin Form" }, util = { "/cast [mod:shift,@player]Regrowth;[mod:alt]Mighty Bash" } }
local D_BAL = { S("Barkskin", "c") }

local C_LOCK = { gate = "nochanneling", stop = false, util = { "/cast [mod:shift]Drain Life;[mod:alt,@cursor]Shadowfury" } }
local D_LOCK = { S("Unending Resolve", "c") }

local C_DEMO = { gate = "nochanneling", stop = false, preall = true, pre = { "/cast [nopet,nodead]Summon Felguard" }, util = { "/cast [mod:shift]Drain Life;[mod:alt,@cursor]Shadowfury" } }
local D_DEMO = { S("Unending Resolve", "c") }

local C_MAGE = { gate = "nochanneling", stop = false, util = { "/cast [mod:shift,@player]Prismatic Barrier;[mod:alt]Frost Nova" } }
local D_MAGE = { S("Mirror Image", "c") }

local Retail = {}

Retail.RoninDPS_DK_Unholy_Rider = DPS("RoninDPS_DK_Unholy_Rider", 252, C_DK, {
    { S("Putrefy"), S("Outbreak"), S("Dark Transformation", "c"), S("Death Coil") },
    { S("Festering Scythe"), S("Soul Reaper"), S("Death Coil") },
    { S("Scourge Strike"), S("Festering Strike"), S("Death Coil") },
    { R("/castsequence reset=5 Festering Strike, Scourge Strike, Scourge Strike"), S("Death Coil"), S("Festering Strike") },
    { S("Death Coil"), S("Scourge Strike"), S("Festering Strike") },
    { S("Summon Gargoyle", "c"), S("Army of the Dead", "c"), S("Scourge Strike") },
}, D_DK, "Unholy DK, Rider of the Apocalypse. Raid and Delve: Rider of the Apocalypse (Army of the Dead, Summon Gargoyle, Dark Transformation). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Outbreak"), S("Festering Strike"), S("Death Coil") },
    { S("Dark Transformation", "c"), S("Scourge Strike"), S("Death Coil") },
    { S("Death and Decay", "p"), S("Festering Strike"), S("Death Coil") },
})

Retail.RoninDPS_DK_Unh_Rider_AoE = DPS("RoninDPS_DK_Unh_Rider_AoE", 252, C_DK, {
    { S("Putrefy"), S("Outbreak"), S("Dark Transformation", "c"), S("Epidemic") },
    { S("Death and Decay", "p"), S("Festering Scythe"), S("Soul Reaper"), S("Epidemic") },
    { S("Epidemic"), S("Scourge Strike"), S("Festering Strike") },
    { R("/castsequence reset=5 Festering Strike, Scourge Strike, Scourge Strike"), S("Epidemic"), S("Festering Strike") },
    { S("Scourge Strike"), S("Festering Strike"), S("Epidemic") },
    { S("Summon Gargoyle", "c"), S("Army of the Dead", "c"), S("Epidemic") },
}, D_DK, "Unholy DK, Rider of the Apocalypse. Raid and Delve: Rider of the Apocalypse (Army of the Dead, Summon Gargoyle, Dark Transformation). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Outbreak"), S("Death and Decay", "p"), S("Epidemic") },
    { S("Dark Transformation", "c"), S("Festering Strike"), S("Epidemic") },
    { S("Scourge Strike"), S("Epidemic"), S("Death Coil") },
})

Retail.RoninDPS_DK_Unholy_Sanlayn = DPS("RoninDPS_DK_Unholy_Sanlayn", 252, C_DK, {
    { S("Putrefy"), S("Outbreak"), S("Dark Transformation", "c"), S("Death Coil") },
    { S("Festering Scythe"), S("Soul Reaper"), S("Death Coil") },
    { S("Vampiric Strike"), S("Scourge Strike"), S("Festering Strike") },
    { R("/castsequence reset=5 Festering Strike, Scourge Strike, Scourge Strike"), S("Death Coil"), S("Festering Strike") },
    { S("Vampiric Strike"), S("Death Coil"), S("Scourge Strike") },
    { S("Summon Gargoyle", "c"), S("Army of the Dead", "c"), S("Scourge Strike") },
}, D_DK, "Unholy DK, San'layn. Mythic+: San'layn (Vampiric Strike, Essence of the Blood Queen, Dark Transformation windows). No Death and Decay on single target. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Outbreak"), S("Festering Strike"), S("Death Coil") },
    { S("Dark Transformation", "c"), S("Scourge Strike"), S("Death Coil") },
    { S("Death and Decay", "p"), S("Festering Strike"), S("Death Coil") },
})

Retail.RoninDPS_DK_Unh_Sanlayn_AoE = DPS("RoninDPS_DK_Unh_Sanlayn_AoE", 252, C_DK, {
    { S("Putrefy"), S("Outbreak"), S("Dark Transformation", "c"), S("Epidemic") },
    { S("Death and Decay", "p"), S("Festering Scythe"), S("Soul Reaper"), S("Epidemic") },
    { S("Epidemic"), S("Vampiric Strike"), S("Scourge Strike") },
    { R("/castsequence reset=5 Festering Strike, Scourge Strike, Scourge Strike"), S("Epidemic"), S("Festering Strike") },
    { S("Vampiric Strike"), S("Scourge Strike"), S("Epidemic") },
    { S("Summon Gargoyle", "c"), S("Army of the Dead", "c"), S("Epidemic") },
}, D_DK, "Unholy DK, San'layn. Mythic+: San'layn (Vampiric Strike, Essence of the Blood Queen, Dark Transformation windows). No Death and Decay on single target. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Outbreak"), S("Death and Decay", "p"), S("Epidemic") },
    { S("Dark Transformation", "c"), S("Festering Strike"), S("Epidemic") },
    { S("Scourge Strike"), S("Epidemic"), S("Death Coil") },
})

Retail.RoninDPS_DK_Frost_Deathbr = DPS("RoninDPS_DK_Frost_Deathbr", 251, C_DK, {
    { S("Obliterate"), S("Frost Strike"), S("Howling Blast") },
    { S("Howling Blast"), S("Frost Strike"), S("Obliterate") },
    { S("Frost Strike"), S("Obliterate"), S("Howling Blast") },
    { R("/castsequence reset=5 Obliterate, Obliterate, Frost Strike"), S("Howling Blast"), S("Frost Strike") },
    { S("Reaper's Mark"), S("Empower Rune Weapon", "c"), S("Obliterate") },
    { S("Pillar of Frost", "c"), S("Frostwyrm's Fury", "c"), S("Remorseless Winter", "c"), S("Frost Strike") },
}, D_DK, "Frost DK, Deathbringer. Raid and Mythic+: Deathbringer (Reaper's Mark before Pillar of Frost, Frostwyrm's Fury, Breath of Sindragosa). AoE uses Frostscythe and Glacial Advance. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Obliterate"), S("Frost Strike"), S("Howling Blast") },
    { S("Howling Blast"), S("Obliterate"), S("Frost Strike") },
    { S("Pillar of Frost", "c"), S("Remorseless Winter", "c"), S("Frost Strike") },
})

Retail.RoninDPS_DK_Frost_Dbr_AoE = DPS("RoninDPS_DK_Frost_Dbr_AoE", 251, C_DK, {
    { S("Frostscythe"), S("Glacial Advance"), S("Howling Blast") },
    { S("Howling Blast"), S("Glacial Advance"), S("Frostscythe") },
    { S("Glacial Advance"), S("Frostscythe"), S("Frost Strike") },
    { S("Reaper's Mark"), S("Remorseless Winter", "c"), S("Frostscythe") },
    { S("Empower Rune Weapon", "c"), S("Frostscythe"), S("Howling Blast") },
    { S("Pillar of Frost", "c"), S("Frostwyrm's Fury", "c"), S("Breath of Sindragosa", "c"), S("Howling Blast") },
}, D_DK, "Frost DK, Deathbringer. Raid and Mythic+: Deathbringer (Reaper's Mark before Pillar of Frost, Frostwyrm's Fury, Breath of Sindragosa). AoE uses Frostscythe and Glacial Advance. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Frostscythe"), S("Howling Blast"), S("Obliterate") },
    { S("Remorseless Winter", "c"), S("Glacial Advance"), S("Frost Strike") },
    { S("Pillar of Frost", "c"), S("Obliterate"), S("Frost Strike") },
})

Retail.RoninDPS_DK_Frost_Rider = DPS("RoninDPS_DK_Frost_Rider", 251, C_DK, {
    { S("Obliterate"), S("Frost Strike"), S("Howling Blast") },
    { S("Howling Blast"), S("Frost Strike"), S("Obliterate") },
    { S("Frost Strike"), S("Obliterate"), S("Howling Blast") },
    { R("/castsequence reset=5 Obliterate, Obliterate, Frost Strike"), S("Howling Blast"), S("Frost Strike") },
    { S("Empower Rune Weapon", "c"), S("Breath of Sindragosa", "c"), S("Obliterate") },
    { S("Pillar of Frost", "c"), S("Frostwyrm's Fury", "c"), S("Remorseless Winter", "c"), S("Frost Strike") },
}, D_DK, "Frost DK, Rider of the Apocalypse. Delve: Rider of the Apocalypse (Breath of Sindragosa, Frostbane, Remorseless Winter). AoE uses Frostscythe and Glacial Advance. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Obliterate"), S("Frost Strike"), S("Howling Blast") },
    { S("Howling Blast"), S("Obliterate"), S("Frost Strike") },
    { S("Pillar of Frost", "c"), S("Remorseless Winter", "c"), S("Frost Strike") },
})

Retail.RoninDPS_DK_Frost_Rider_AoE = DPS("RoninDPS_DK_Frost_Rider_AoE", 251, C_DK, {
    { S("Frostscythe"), S("Glacial Advance"), S("Howling Blast") },
    { S("Howling Blast"), S("Glacial Advance"), S("Frostscythe") },
    { S("Glacial Advance"), S("Frostscythe"), S("Frost Strike") },
    { S("Remorseless Winter", "c"), S("Frostscythe"), S("Howling Blast") },
    { S("Empower Rune Weapon", "c"), S("Frostscythe"), S("Howling Blast") },
    { S("Pillar of Frost", "c"), S("Frostwyrm's Fury", "c"), S("Breath of Sindragosa", "c"), S("Howling Blast") },
}, D_DK, "Frost DK, Rider of the Apocalypse. Delve: Rider of the Apocalypse (Breath of Sindragosa, Frostbane, Remorseless Winter). AoE uses Frostscythe and Glacial Advance. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Frostscythe"), S("Howling Blast"), S("Obliterate") },
    { S("Remorseless Winter", "c"), S("Glacial Advance"), S("Frost Strike") },
    { S("Pillar of Frost", "c"), S("Obliterate"), S("Frost Strike") },
})

Retail.RoninDPS_DH_Havoc_Aldrachi = DPS("RoninDPS_DH_Havoc_Aldrachi", 577, C_DH, {
    { S("Eye Beam"), S("Essence Break"), S("Chaos Strike") },
    { S("Immolation Aura"), S("Reaver's Glaive"), S("Chaos Strike") },
    { S("The Hunt"), S("Blade Dance"), S("Chaos Strike") },
    { S("Felblade"), S("Throw Glaive"), S("Chaos Strike") },
    { R("/castsequence [nochanneling:Eye Beam] reset=4 Chaos Strike, Chaos Strike, Blade Dance"), S("Blade Dance") },
    { S("Metamorphosis", "cp"), S("Sigil of Flame", "p"), S("Chaos Strike") },
}, D_DH, "Havoc DH, Aldrachi Reaver. Raid: Aldrachi Reaver single target (Essence Break, Reaver's Glaive, Cycle of Hatred). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Demon's Bite"), S("Chaos Strike"), S("Blade Dance") },
    { S("Immolation Aura"), S("Felblade"), S("Throw Glaive") },
    { S("Eye Beam"), S("Metamorphosis", "cp"), S("Chaos Strike") },
})

Retail.RoninDPS_DH_Hav_Aldr_AoE = DPS("RoninDPS_DH_Hav_Aldr_AoE", 577, C_DH, {
    { S("Eye Beam"), S("Blade Dance"), S("Chaos Strike") },
    { S("Immolation Aura"), S("Blade Dance"), S("Chaos Strike") },
    { S("The Hunt"), S("Reaver's Glaive"), S("Chaos Strike") },
    { S("Blade Dance"), S("Felblade"), S("Chaos Strike") },
    { S("Throw Glaive"), S("Chaos Strike"), S("Demon's Bite") },
    { S("Metamorphosis", "cp"), S("Sigil of Flame", "p"), S("Blade Dance") },
}, D_DH, "Havoc DH, Aldrachi Reaver. Raid: Aldrachi Reaver single target (Essence Break, Reaver's Glaive, Cycle of Hatred). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Blade Dance"), S("Chaos Strike"), S("Demon's Bite") },
    { S("Immolation Aura"), S("Eye Beam"), S("Throw Glaive") },
    { S("Felblade"), S("Metamorphosis", "cp"), S("Chaos Strike") },
})

Retail.RoninDPS_DH_Havoc_FelScarred = DPS("RoninDPS_DH_Havoc_FelScarred", 577, C_DH, {
    { S("Immolation Aura"), S("Eye Beam"), S("Chaos Strike") },
    { S("Metamorphosis", "cp"), S("The Hunt"), S("Chaos Strike") },
    { S("Eye Beam"), S("Blade Dance"), S("Chaos Strike") },
    { S("Felblade"), S("Throw Glaive"), S("Chaos Strike") },
    { R("/castsequence [nochanneling:Eye Beam] reset=4 Chaos Strike, Chaos Strike, Blade Dance"), S("Blade Dance") },
    { S("Sigil of Flame", "p"), S("Immolation Aura"), S("Chaos Strike") },
}, D_DH, "Havoc DH, Fel-Scarred. Mythic+ and Delve: Fel-Scarred AoE (Eye Beam, Immolation Aura, Demonsurge, A Fire Inside). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Demon's Bite"), S("Chaos Strike"), S("Blade Dance") },
    { S("Immolation Aura"), S("Felblade"), S("Throw Glaive") },
    { S("Eye Beam"), S("Metamorphosis", "cp"), S("Chaos Strike") },
})

Retail.RoninDPS_DH_Hav_Fel_AoE = DPS("RoninDPS_DH_Hav_Fel_AoE", 577, C_DH, {
    { S("Eye Beam"), S("Blade Dance"), S("Immolation Aura") },
    { S("Immolation Aura"), S("Blade Dance"), S("Chaos Strike") },
    { S("Metamorphosis", "cp"), S("Eye Beam"), S("Blade Dance") },
    { S("Blade Dance"), S("The Hunt"), S("Chaos Strike") },
    { S("Throw Glaive"), S("Felblade"), S("Chaos Strike") },
    { S("Sigil of Flame", "p"), S("Immolation Aura"), S("Blade Dance") },
}, D_DH, "Havoc DH, Fel-Scarred. Mythic+ and Delve: Fel-Scarred AoE (Eye Beam, Immolation Aura, Demonsurge, A Fire Inside). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Blade Dance"), S("Chaos Strike"), S("Demon's Bite") },
    { S("Immolation Aura"), S("Eye Beam"), S("Throw Glaive") },
    { S("Felblade"), S("Metamorphosis", "cp"), S("Chaos Strike") },
})

Retail.RoninDPS_DH_Devourer_Annih = DPS("RoninDPS_DH_Devourer_Annih", 1480, C_DEV, {
    { S("Collapsing Star"), S("Void Ray"), S("Consume") },
    { S("Cull"), S("Reap"), S("Consume") },
    { S("Void Ray"), S("Collapsing Star"), S("Reap") },
    { S("Consume"), S("Reap"), S("Void Ray") },
    { S("Reap"), S("Consume") },
    { S("Void Metamorphosis", "c"), S("Void Ray"), S("Consume") },
}, D_DEV, "Devourer DH, Annihilator. Talents: Annihilator hero tree (Voidfall stacks, Void Meteors, 4-5 Collapsing Stars per Void Metamorphosis). Raid single target and Mythic+ AoE. Void Ray and Collapsing Star are long casts: stand still while they run, the macro will not interrupt them. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Consume"), S("Reap"), S("Void Ray") },
    { S("Collapsing Star"), S("Cull"), S("Consume") },
    { S("Void Metamorphosis", "c"), S("Void Ray"), S("Consume") },
})

Retail.RoninDPS_DH_Dev_Annih_AoE = DPS("RoninDPS_DH_Dev_Annih_AoE", 1480, C_DEV, {
    { S("Collapsing Star"), S("Void Ray"), S("Consume") },
    { S("Cull"), S("Reap"), S("Void Ray") },
    { S("Void Ray"), S("Cull"), S("Consume") },
    { S("Reap"), S("Collapsing Star"), S("Consume") },
    { S("Consume"), S("Reap") },
    { S("Void Metamorphosis", "c"), S("Void Ray"), S("Consume") },
}, D_DEV, "Devourer DH, Annihilator. Talents: Annihilator hero tree (Voidfall stacks, Void Meteors, 4-5 Collapsing Stars per Void Metamorphosis). Raid single target and Mythic+ AoE. Void Ray and Collapsing Star are long casts: stand still while they run, the macro will not interrupt them. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Consume"), S("Reap"), S("Void Ray") },
    { S("Collapsing Star"), S("Cull"), S("Consume") },
    { S("Void Metamorphosis", "c"), S("Void Ray"), S("Consume") },
})

Retail.RoninDPS_DH_Dev_VoidScar = DPS("RoninDPS_DH_Dev_VoidScar", 1480, C_DEV, {
    { S("Collapsing Star"), S("Void Ray"), S("Consume") },
    { S("Reaper's Toll"), S("Cull"), S("Reap") },
    { S("Hungering Slash"), S("Void Ray"), S("Consume") },
    { S("Pierce the Veil"), S("Predator's Wake"), S("Consume") },
    { S("Soul Immolation", "c"), S("Reap"), S("Consume") },
    { S("Voidblade"), S("Void Metamorphosis", "c"), S("The Hunt"), S("Consume") },
}, D_DEV, "Devourer DH, Void-Scarred. Talents: Void-Scarred hero tree (Hungering Slash, Voidstep, Burning Blades; Voidblade and The Hunt become Pierce the Veil and Predator's Wake inside Void Metamorphosis). Melee build: easier to disrupt than Annihilator, so use it when you can stay on the boss. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Consume"), S("Reap"), S("Void Ray") },
    { S("Collapsing Star"), S("Cull"), S("Consume") },
    { S("Void Metamorphosis", "c"), S("Void Ray"), S("Consume") },
})

Retail.RoninDPS_DH_Dev_VScar_AoE = DPS("RoninDPS_DH_Dev_VScar_AoE", 1480, C_DEV, {
    { S("Collapsing Star"), S("Void Ray"), S("Consume") },
    { S("Reaper's Toll"), S("Cull"), S("Reap") },
    { S("Hungering Slash"), S("Void Ray"), S("Consume") },
    { S("Pierce the Veil"), S("Predator's Wake"), S("Reap") },
    { S("Soul Immolation", "c"), S("Cull"), S("Consume") },
    { S("Voidblade"), S("Void Metamorphosis", "c"), S("The Hunt"), S("Consume") },
}, D_DEV, "Devourer DH, Void-Scarred. Talents: Void-Scarred hero tree (Hungering Slash, Voidstep, Burning Blades; Voidblade and The Hunt become Pierce the Veil and Predator's Wake inside Void Metamorphosis). Melee build: easier to disrupt than Annihilator, so use it when you can stay on the boss. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Consume"), S("Reap"), S("Void Ray") },
    { S("Collapsing Star"), S("Cull"), S("Consume") },
    { S("Void Metamorphosis", "c"), S("Void Ray"), S("Consume") },
})

Retail.RoninDPS_Ele_Farseer = DPS("RoninDPS_Ele_Farseer", 262, C_SHA, {
    { S("Lava Burst"), S("Elemental Blast"), S("Lightning Bolt") },
    { S("Ancestral Swiftness", "c"), S("Flame Shock", "s"), S("Lightning Bolt") },
    { S("Elemental Blast"), S("Earth Shock"), S("Lightning Bolt") },
    { S("Voltaic Blaze"), S("Lava Burst"), S("Lightning Bolt") },
    { S("Earth Shock"), S("Lava Burst"), S("Lightning Bolt") },
    { S("Stormkeeper", "c"), S("Ascendance", "c"), S("Fire Elemental", "c"), S("Lightning Bolt") },
}, D_SHA, "Elemental Shaman, Farseer. Talents: Farseer hero tree (Ancestral Swiftness calls your Ancestors). Raid build: Flame Shock kept up, Lava Burst and Elemental Blast before Lightning Bolt. AoE: Earthquake at your cursor and Chain Lightning. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Healing Surge, Alt = Capacitor Totem. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Flame Shock", "s"), S("Lava Burst"), S("Lightning Bolt") },
    { S("Earth Shock"), S("Lightning Bolt") },
    { S("Ascendance", "c"), S("Lava Burst"), S("Lightning Bolt") },
})

Retail.RoninDPS_Ele_Farseer_AoE = DPS("RoninDPS_Ele_Farseer_AoE", 262, C_SHA, {
    { S("Voltaic Blaze"), R("/cast [nochanneling,@cursor]Earthquake"), S("Chain Lightning") },
    { S("Ancestral Swiftness", "c"), S("Lava Burst"), S("Chain Lightning") },
    { S("Flame Shock", "s"), S("Elemental Blast"), S("Chain Lightning") },
    { R("/cast [nochanneling,@cursor]Earthquake"), S("Lava Burst"), S("Chain Lightning") },
    { S("Elemental Blast"), S("Chain Lightning") },
    { S("Stormkeeper", "c"), S("Ascendance", "c"), S("Fire Elemental", "c"), S("Chain Lightning") },
}, D_SHA, "Elemental Shaman, Farseer. Talents: Farseer hero tree (Ancestral Swiftness calls your Ancestors). Raid build: Flame Shock kept up, Lava Burst and Elemental Blast before Lightning Bolt. AoE: Earthquake at your cursor and Chain Lightning. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Healing Surge, Alt = Capacitor Totem. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Flame Shock", "s"), S("Lava Burst"), S("Chain Lightning") },
    { S("Earthquake", "p"), S("Chain Lightning") },
    { S("Ascendance", "c"), S("Lava Burst"), S("Chain Lightning") },
})

Retail.RoninDPS_Ele_Stormbringer = DPS("RoninDPS_Ele_Stormbringer", 262, C_SHA, {
    { S("Lava Burst"), S("Elemental Blast"), S("Lightning Bolt") },
    { S("Ancestral Swiftness", "c"), S("Voltaic Blaze"), S("Lightning Bolt") },
    { S("Elemental Blast"), S("Earth Shock"), S("Lightning Bolt") },
    { S("Flame Shock", "s"), S("Lava Burst"), S("Lightning Bolt") },
    { S("Earth Shock"), S("Lava Burst"), S("Lightning Bolt") },
    { S("Stormkeeper", "c"), S("Ascendance", "c"), S("Fire Elemental", "c"), S("Lightning Bolt") },
}, D_SHA, "Elemental Shaman, Stormbringer. Talents: Stormbringer hero tree (Tempest replaces Lightning Bolt when it is ready). Mythic+ build: Voltaic Blaze for Flame Shock. AoE: Earthquake at your cursor and Chain Lightning. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Healing Surge, Alt = Capacitor Totem. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Flame Shock", "s"), S("Lava Burst"), S("Lightning Bolt") },
    { S("Earth Shock"), S("Lightning Bolt") },
    { S("Ascendance", "c"), S("Lava Burst"), S("Lightning Bolt") },
})

Retail.RoninDPS_Ele_Storm_AoE = DPS("RoninDPS_Ele_Storm_AoE", 262, C_SHA, {
    { S("Voltaic Blaze"), R("/cast [nochanneling,@cursor]Earthquake"), S("Chain Lightning") },
    { S("Ancestral Swiftness", "c"), S("Lava Burst"), S("Chain Lightning") },
    { S("Flame Shock", "s"), S("Elemental Blast"), S("Chain Lightning") },
    { R("/cast [nochanneling,@cursor]Earthquake"), S("Lava Burst"), S("Chain Lightning") },
    { S("Elemental Blast"), S("Chain Lightning") },
    { S("Stormkeeper", "c"), S("Ascendance", "c"), S("Fire Elemental", "c"), S("Chain Lightning") },
}, D_SHA, "Elemental Shaman, Stormbringer. Talents: Stormbringer hero tree (Tempest replaces Lightning Bolt when it is ready). Mythic+ build: Voltaic Blaze for Flame Shock. AoE: Earthquake at your cursor and Chain Lightning. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Healing Surge, Alt = Capacitor Totem. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Flame Shock", "s"), S("Lava Burst"), S("Chain Lightning") },
    { S("Earthquake", "p"), S("Chain Lightning") },
    { S("Ascendance", "c"), S("Lava Burst"), S("Chain Lightning") },
})

Retail.RoninDPS_Enh_Stormbringer = DPS("RoninDPS_Enh_Stormbringer", 263, C_SHA, {
    { S("Voltaic Blaze"), S("Crash Lightning"), S("Stormstrike") },
    { S("Stormstrike"), S("Lava Lash"), S("Crash Lightning") },
    { S("Lightning Bolt"), S("Stormstrike") },
    { S("Lava Lash"), S("Stormstrike"), S("Voltaic Blaze") },
    { S("Stormstrike"), S("Crash Lightning"), S("Lava Lash") },
    { S("Doom Winds", "c"), S("Ascendance", "c"), S("Sundering"), S("Lava Lash") },
}, D_SHA, "Enhancement Shaman, Stormbringer. Talents: Stormbringer hero tree (Tempest). Stormstrike, Lava Lash and Crash Lightning on cooldown build Maelstrom Weapon; the spender (Lightning Bolt / Tempest, AoE: Chain Lightning) comes about every 7th press so the stacks can build up first. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Healing Surge, Alt = Capacitor Totem. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Stormstrike"), S("Lava Lash"), S("Voltaic Blaze") },
    { S("Crash Lightning"), S("Stormstrike"), S("Lava Lash") },
    { S("Lightning Bolt"), S("Stormstrike") },
})

Retail.RoninDPS_Enh_Storm_AoE = DPS("RoninDPS_Enh_Storm_AoE", 263, C_SHA, {
    { S("Crash Lightning"), S("Voltaic Blaze"), S("Stormstrike") },
    { S("Stormstrike"), S("Crash Lightning"), S("Lava Lash") },
    { S("Chain Lightning"), S("Crash Lightning") },
    { S("Voltaic Blaze"), S("Lava Lash"), S("Crash Lightning") },
    { S("Crash Lightning"), S("Stormstrike"), S("Lava Lash") },
    { S("Doom Winds", "c"), S("Ascendance", "c"), S("Sundering"), S("Crash Lightning") },
}, D_SHA, "Enhancement Shaman, Stormbringer. Talents: Stormbringer hero tree (Tempest). Stormstrike, Lava Lash and Crash Lightning on cooldown build Maelstrom Weapon; the spender (Lightning Bolt / Tempest, AoE: Chain Lightning) comes about every 7th press so the stacks can build up first. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Healing Surge, Alt = Capacitor Totem. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Crash Lightning"), S("Stormstrike"), S("Lava Lash") },
    { S("Voltaic Blaze"), S("Crash Lightning"), S("Stormstrike") },
    { S("Chain Lightning"), S("Crash Lightning") },
})

Retail.RoninDPS_Enh_Totemic = DPS("RoninDPS_Enh_Totemic", 263, C_SHA, {
    { S("Voltaic Blaze"), S("Lava Lash"), S("Crash Lightning") },
    { S("Stormstrike"), S("Lava Lash"), S("Crash Lightning") },
    { S("Primordial Storm"), S("Lightning Bolt"), S("Stormstrike") },
    { S("Lava Lash"), S("Stormstrike"), S("Voltaic Blaze") },
    { S("Sundering"), S("Stormstrike"), S("Lava Lash") },
    { S("Surging Totem", "cp"), S("Doom Winds", "c"), S("Sundering"), S("Lava Lash") },
}, D_SHA, "Enhancement Shaman, Totemic. Talents: Totemic hero tree (Surging Totem at your feet, Primordial Storm). Lava Lash, Stormstrike and Crash Lightning on cooldown build Maelstrom Weapon; Primordial Storm / Lightning Bolt (AoE: Chain Lightning) come about every 7th press so the stacks can build up first. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Healing Surge, Alt = Capacitor Totem. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Stormstrike"), S("Lava Lash"), S("Voltaic Blaze") },
    { S("Crash Lightning"), S("Stormstrike"), S("Lava Lash") },
    { S("Lightning Bolt"), S("Stormstrike") },
})

Retail.RoninDPS_Enh_Totemic_AoE = DPS("RoninDPS_Enh_Totemic_AoE", 263, C_SHA, {
    { S("Crash Lightning"), S("Voltaic Blaze"), S("Lava Lash") },
    { S("Stormstrike"), S("Crash Lightning"), S("Lava Lash") },
    { S("Primordial Storm"), S("Chain Lightning"), S("Crash Lightning") },
    { S("Voltaic Blaze"), S("Lava Lash"), S("Crash Lightning") },
    { S("Sundering"), S("Crash Lightning"), S("Stormstrike") },
    { S("Surging Totem", "cp"), S("Doom Winds", "c"), S("Sundering"), S("Crash Lightning") },
}, D_SHA, "Enhancement Shaman, Totemic. Talents: Totemic hero tree (Surging Totem at your feet, Primordial Storm). Lava Lash, Stormstrike and Crash Lightning on cooldown build Maelstrom Weapon; Primordial Storm / Lightning Bolt (AoE: Chain Lightning) come about every 7th press so the stacks can build up first. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Healing Surge, Alt = Capacitor Totem. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Crash Lightning"), S("Stormstrike"), S("Lava Lash") },
    { S("Voltaic Blaze"), S("Crash Lightning"), S("Stormstrike") },
    { S("Chain Lightning"), S("Crash Lightning") },
})

Retail.RoninDPS_BM_PackLeader = DPS("RoninDPS_BM_PackLeader", 253, C_HUNP, {
    { S("Barbed Shot"), S("Kill Command"), S("Cobra Shot") },
    { S("Kill Command"), S("Barbed Shot"), S("Cobra Shot") },
    { S("Hunter's Mark", "s"), S("Kill Command"), S("Cobra Shot") },
    { S("Barbed Shot"), S("Cobra Shot") },
    { S("Kill Command"), S("Cobra Shot") },
    { S("Bestial Wrath", "c"), S("Kill Command"), S("Barbed Shot") },
}, D_HUNP, "Beast Mastery Hunter, Pack Leader. Talents: Pack Leader hero tree (Howl of the Pack Leader beasts from Kill Command). Barbed Shot and Kill Command never sit on 2 charges, Cobra Shot fills. AoE: Wild Thrash keeps Beast Cleave up. Calls / revives your pet by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Exhilaration, Alt = Intimidation. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Barbed Shot"), S("Kill Command"), S("Cobra Shot") },
    { S("Kill Command"), S("Cobra Shot") },
    { S("Bestial Wrath", "c"), S("Barbed Shot"), S("Cobra Shot") },
})

Retail.RoninDPS_BM_PackLeader_AoE = DPS("RoninDPS_BM_PackLeader_AoE", 253, C_HUNP, {
    { S("Wild Thrash"), S("Barbed Shot"), S("Kill Command") },
    { S("Kill Command"), S("Wild Thrash"), S("Cobra Shot") },
    { S("Barbed Shot"), S("Kill Command"), S("Cobra Shot") },
    { S("Wild Thrash"), S("Cobra Shot") },
    { S("Kill Command"), S("Barbed Shot"), S("Cobra Shot") },
    { S("Bestial Wrath", "c"), S("Wild Thrash"), S("Kill Command") },
}, D_HUNP, "Beast Mastery Hunter, Pack Leader. Talents: Pack Leader hero tree (Howl of the Pack Leader beasts from Kill Command). Barbed Shot and Kill Command never sit on 2 charges, Cobra Shot fills. AoE: Wild Thrash keeps Beast Cleave up. Calls / revives your pet by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Exhilaration, Alt = Intimidation. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Wild Thrash"), S("Barbed Shot"), S("Kill Command") },
    { S("Kill Command"), S("Cobra Shot") },
    { S("Bestial Wrath", "c"), S("Wild Thrash"), S("Cobra Shot") },
})

Retail.RoninDPS_BM_DarkRanger = DPS("RoninDPS_BM_DarkRanger", 253, C_HUNP, {
    { S("Black Arrow"), S("Barbed Shot"), S("Kill Command") },
    { S("Kill Command"), S("Wailing Arrow"), S("Cobra Shot") },
    { S("Hunter's Mark", "s"), S("Black Arrow"), S("Cobra Shot") },
    { S("Barbed Shot"), S("Kill Command"), S("Cobra Shot") },
    { S("Black Arrow"), S("Cobra Shot") },
    { S("Bestial Wrath", "c"), S("Black Arrow"), S("Barbed Shot") },
}, D_HUNP, "Beast Mastery Hunter, Dark Ranger. Talents: Dark Ranger hero tree (Black Arrow, Withering Fire after Bestial Wrath, Wailing Arrow). AoE: Wild Thrash keeps Beast Cleave up. Calls / revives your pet by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Exhilaration, Alt = Intimidation. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Barbed Shot"), S("Kill Command"), S("Cobra Shot") },
    { S("Kill Command"), S("Cobra Shot") },
    { S("Bestial Wrath", "c"), S("Barbed Shot"), S("Cobra Shot") },
})

Retail.RoninDPS_BM_DarkRanger_AoE = DPS("RoninDPS_BM_DarkRanger_AoE", 253, C_HUNP, {
    { S("Black Arrow"), S("Wild Thrash"), S("Kill Command") },
    { S("Wild Thrash"), S("Barbed Shot"), S("Kill Command") },
    { S("Black Arrow"), S("Wailing Arrow"), S("Cobra Shot") },
    { S("Kill Command"), S("Barbed Shot"), S("Cobra Shot") },
    { S("Wild Thrash"), S("Black Arrow"), S("Cobra Shot") },
    { S("Bestial Wrath", "c"), S("Wild Thrash"), S("Black Arrow") },
}, D_HUNP, "Beast Mastery Hunter, Dark Ranger. Talents: Dark Ranger hero tree (Black Arrow, Withering Fire after Bestial Wrath, Wailing Arrow). AoE: Wild Thrash keeps Beast Cleave up. Calls / revives your pet by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Exhilaration, Alt = Intimidation. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Wild Thrash"), S("Barbed Shot"), S("Kill Command") },
    { S("Kill Command"), S("Cobra Shot") },
    { S("Bestial Wrath", "c"), S("Wild Thrash"), S("Cobra Shot") },
})

Retail.RoninDPS_MM_DarkRanger = DPS("RoninDPS_MM_DarkRanger", 254, C_HUNM, {
    { S("Black Arrow"), S("Explosive Shot"), S("Aimed Shot") },
    { S("Rapid Fire"), S("Aimed Shot"), S("Steady Shot") },
    { S("Hunter's Mark", "s"), S("Arcane Shot"), S("Aimed Shot") },
    { S("Wailing Arrow"), S("Black Arrow"), S("Arcane Shot") },
    { S("Aimed Shot"), S("Arcane Shot"), S("Steady Shot") },
    { S("Trueshot", "c"), R("/cast [nochanneling,@cursor]Volley"), S("Explosive Shot"), S("Steady Shot") },
}, D_HUNM, "Marksmanship Hunter, Dark Ranger. Talents: Dark Ranger hero tree (Black Arrow, Wailing Arrow during Trueshot). Aimed Shot and Rapid Fire on cooldown, Arcane Shot (AoE: Multi-Shot for Trick Shots) spends Precise Shots, Steady Shot fills. Volley at your cursor. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Exhilaration, Alt = Binding Shot. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Aimed Shot"), S("Rapid Fire"), S("Arcane Shot") },
    { S("Kill Shot"), S("Arcane Shot"), S("Steady Shot") },
    { S("Trueshot", "c"), S("Aimed Shot"), S("Steady Shot") },
})

Retail.RoninDPS_MM_DarkRanger_AoE = DPS("RoninDPS_MM_DarkRanger_AoE", 254, C_HUNM, {
    { S("Explosive Shot"), S("Black Arrow"), S("Multi-Shot") },
    { S("Aimed Shot"), S("Rapid Fire"), S("Multi-Shot") },
    { R("/cast [nochanneling,@cursor]Volley"), S("Black Arrow"), S("Multi-Shot") },
    { S("Wailing Arrow"), S("Aimed Shot"), S("Steady Shot") },
    { S("Multi-Shot"), S("Aimed Shot"), S("Steady Shot") },
    { S("Trueshot", "c"), S("Explosive Shot"), S("Rapid Fire"), S("Steady Shot") },
}, D_HUNM, "Marksmanship Hunter, Dark Ranger. Talents: Dark Ranger hero tree (Black Arrow, Wailing Arrow during Trueshot). Aimed Shot and Rapid Fire on cooldown, Arcane Shot (AoE: Multi-Shot for Trick Shots) spends Precise Shots, Steady Shot fills. Volley at your cursor. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Exhilaration, Alt = Binding Shot. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Aimed Shot"), S("Rapid Fire"), S("Multi-Shot") },
    { S("Multi-Shot"), S("Steady Shot") },
    { S("Trueshot", "c"), S("Aimed Shot"), S("Steady Shot") },
})

Retail.RoninDPS_MM_Sentinel = DPS("RoninDPS_MM_Sentinel", 254, C_HUNM, {
    { S("Explosive Shot"), S("Kill Shot"), S("Aimed Shot") },
    { S("Rapid Fire"), S("Arcane Shot"), S("Steady Shot") },
    { S("Hunter's Mark", "s"), S("Moonlight Chakram"), S("Aimed Shot") },
    { S("Kill Shot"), S("Arcane Shot"), S("Aimed Shot") },
    { S("Aimed Shot"), S("Arcane Shot"), S("Steady Shot") },
    { S("Trueshot", "c"), R("/cast [nochanneling,@cursor]Volley"), S("Explosive Shot"), S("Steady Shot") },
}, D_HUNM, "Marksmanship Hunter, Sentinel. Talents: Sentinel hero tree (Sentinel's Mark, Lunar Storm, Moonlight Chakram). Aimed Shot and Rapid Fire on cooldown, Arcane Shot (AoE: Multi-Shot for Trick Shots) spends Precise Shots, Steady Shot fills. Volley at your cursor. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Exhilaration, Alt = Binding Shot. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Aimed Shot"), S("Rapid Fire"), S("Arcane Shot") },
    { S("Kill Shot"), S("Arcane Shot"), S("Steady Shot") },
    { S("Trueshot", "c"), S("Aimed Shot"), S("Steady Shot") },
})

Retail.RoninDPS_MM_Sentinel_AoE = DPS("RoninDPS_MM_Sentinel_AoE", 254, C_HUNM, {
    { S("Explosive Shot"), S("Multi-Shot"), S("Aimed Shot") },
    { S("Rapid Fire"), S("Multi-Shot"), S("Steady Shot") },
    { R("/cast [nochanneling,@cursor]Volley"), S("Moonlight Chakram"), S("Multi-Shot") },
    { S("Aimed Shot"), S("Multi-Shot"), S("Steady Shot") },
    { S("Multi-Shot"), S("Aimed Shot"), S("Steady Shot") },
    { S("Trueshot", "c"), S("Explosive Shot"), S("Moonlight Chakram"), S("Steady Shot") },
}, D_HUNM, "Marksmanship Hunter, Sentinel. Talents: Sentinel hero tree (Sentinel's Mark, Lunar Storm, Moonlight Chakram). Aimed Shot and Rapid Fire on cooldown, Arcane Shot (AoE: Multi-Shot for Trick Shots) spends Precise Shots, Steady Shot fills. Volley at your cursor. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Exhilaration, Alt = Binding Shot. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Aimed Shot"), S("Rapid Fire"), S("Multi-Shot") },
    { S("Multi-Shot"), S("Steady Shot") },
    { S("Trueshot", "c"), S("Aimed Shot"), S("Steady Shot") },
})

Retail.RoninDPS_SV_PackLeader = DPS("RoninDPS_SV_PackLeader", 255, C_HUNP, {
    { S("Kill Command"), S("Wildfire Bomb"), S("Raptor Strike") },
    { S("Boomstick"), S("Kill Command"), S("Raptor Strike") },
    { S("Hunter's Mark", "s"), S("Kill Command"), S("Raptor Strike") },
    { S("Wildfire Bomb"), S("Raptor Strike"), S("Kill Command") },
    { S("Raptor Strike"), S("Kill Command") },
    { S("Takedown", "c"), S("Boomstick"), S("Wildfire Bomb"), S("Raptor Strike") },
}, D_HUNP, "Survival Hunter, Pack Leader. Talents: Pack Leader hero tree. Melee: Kill Command builds Tip of the Spear, Raptor Strike (AoE: Raptor Swipe) spends it, Wildfire Bomb and Boomstick on cooldown, Takedown as the burst. Calls / revives your pet by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Exhilaration, Alt = Intimidation. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Kill Command"), S("Wildfire Bomb"), S("Raptor Strike") },
    { S("Raptor Strike"), S("Kill Command") },
    { S("Takedown", "c"), S("Wildfire Bomb"), S("Raptor Strike") },
})

Retail.RoninDPS_SV_PackLeader_AoE = DPS("RoninDPS_SV_PackLeader_AoE", 255, C_HUNP, {
    { S("Kill Command"), S("Boomstick"), S("Raptor Swipe") },
    { S("Wildfire Bomb"), S("Kill Command"), S("Raptor Swipe") },
    { S("Flamefang Pitch"), S("Raptor Swipe"), S("Raptor Strike") },
    { S("Kill Command"), S("Wildfire Bomb"), S("Raptor Swipe") },
    { S("Raptor Swipe"), S("Raptor Strike"), S("Kill Command") },
    { S("Takedown", "c"), S("Boomstick"), S("Flamefang Pitch"), S("Raptor Swipe") },
}, D_HUNP, "Survival Hunter, Pack Leader. Talents: Pack Leader hero tree. Melee: Kill Command builds Tip of the Spear, Raptor Strike (AoE: Raptor Swipe) spends it, Wildfire Bomb and Boomstick on cooldown, Takedown as the burst. Calls / revives your pet by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Exhilaration, Alt = Intimidation. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Kill Command"), S("Wildfire Bomb"), S("Raptor Swipe") },
    { S("Raptor Swipe"), S("Raptor Strike"), S("Kill Command") },
    { S("Takedown", "c"), S("Wildfire Bomb"), S("Raptor Swipe") },
})

Retail.RoninDPS_SV_Sentinel = DPS("RoninDPS_SV_Sentinel", 255, C_HUNP, {
    { S("Kill Command"), S("Wildfire Bomb"), S("Raptor Strike") },
    { S("Boomstick"), S("Moonlight Chakram"), S("Raptor Strike") },
    { S("Hunter's Mark", "s"), S("Kill Command"), S("Raptor Strike") },
    { S("Wildfire Bomb"), S("Flamefang Pitch"), S("Raptor Strike") },
    { S("Raptor Strike"), S("Kill Command") },
    { S("Takedown", "c"), S("Boomstick"), S("Moonlight Chakram"), S("Raptor Strike") },
}, D_HUNP, "Survival Hunter, Sentinel. Talents: Sentinel hero tree (Sentinel's Mark, Moonlight Chakram). Melee: Kill Command builds Tip of the Spear, Raptor Strike (AoE: Raptor Swipe) spends it, Wildfire Bomb and Boomstick on cooldown, Takedown as the burst. Calls / revives your pet by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Exhilaration, Alt = Intimidation. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Kill Command"), S("Wildfire Bomb"), S("Raptor Strike") },
    { S("Raptor Strike"), S("Kill Command") },
    { S("Takedown", "c"), S("Wildfire Bomb"), S("Raptor Strike") },
})

Retail.RoninDPS_SV_Sentinel_AoE = DPS("RoninDPS_SV_Sentinel_AoE", 255, C_HUNP, {
    { S("Kill Command"), S("Boomstick"), S("Raptor Swipe") },
    { S("Wildfire Bomb"), S("Moonlight Chakram"), S("Raptor Swipe") },
    { S("Flamefang Pitch"), S("Kill Command"), S("Raptor Swipe") },
    { S("Wildfire Bomb"), S("Raptor Swipe"), S("Raptor Strike") },
    { S("Raptor Swipe"), S("Kill Command"), S("Raptor Strike") },
    { S("Takedown", "c"), S("Boomstick"), S("Flamefang Pitch"), S("Raptor Swipe") },
}, D_HUNP, "Survival Hunter, Sentinel. Talents: Sentinel hero tree (Sentinel's Mark, Moonlight Chakram). Melee: Kill Command builds Tip of the Spear, Raptor Strike (AoE: Raptor Swipe) spends it, Wildfire Bomb and Boomstick on cooldown, Takedown as the burst. Calls / revives your pet by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Exhilaration, Alt = Intimidation. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Kill Command"), S("Wildfire Bomb"), S("Raptor Swipe") },
    { S("Raptor Swipe"), S("Raptor Strike"), S("Kill Command") },
    { S("Takedown", "c"), S("Wildfire Bomb"), S("Raptor Swipe") },
})

Retail.RoninDPS_Paladin_Ret_Herald = DPS("RoninDPS_Paladin_Ret_Herald", 70, C_PAL, {
    { S("Execution Sentence"), S("Wake of Ashes"), S("Divine Toll", "c"), S("Blade of Justice") },
    { S("Hammer of Wrath"), S("Blade of Justice"), S("Final Verdict") },
    { S("Final Verdict"), S("Judgment"), S("Blade of Justice") },
    { S("Judgment"), S("Blade of Justice"), S("Final Verdict") },
    { S("Final Verdict"), S("Templar Strike"), S("Crusader Strike") },
    { S("Avenging Wrath", "c"), S("Wake of Ashes"), S("Execution Sentence"), S("Blade of Justice") },
}, D_PAL, "Retribution Paladin, Herald of the Sun. Raid and Mythic+: Herald of the Sun (Dawnlight, Execution Sentence, Divine Storm for AoE). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Word of Glory, Alt = Hammer of Justice. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Crusader Strike"), S("Judgment"), S("Hammer of Wrath") },
    { S("Blade of Justice"), S("Templar Strike"), S("Judgment") },
    { S("Final Verdict"), S("Wake of Ashes"), S("Avenging Wrath", "c") },
})

Retail.RoninDPS_Pal_Ret_Herald_AoE = DPS("RoninDPS_Pal_Ret_Herald_AoE", 70, C_PAL, {
    { S("Execution Sentence"), S("Wake of Ashes"), S("Divine Toll", "c"), S("Blade of Justice") },
    { S("Hammer of Wrath"), S("Divine Storm"), S("Blade of Justice") },
    { S("Divine Storm"), S("Judgment"), S("Blade of Justice") },
    { S("Judgment"), S("Blade of Justice"), S("Divine Storm") },
    { S("Divine Storm"), S("Templar Strike"), S("Crusader Strike") },
    { S("Avenging Wrath", "c"), S("Wake of Ashes"), S("Execution Sentence"), S("Blade of Justice") },
}, D_PAL, "Retribution Paladin, Herald of the Sun. Raid and Mythic+: Herald of the Sun (Dawnlight, Execution Sentence, Divine Storm for AoE). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Word of Glory, Alt = Hammer of Justice. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Divine Storm"), S("Judgment"), S("Hammer of Wrath") },
    { S("Blade of Justice"), S("Crusader Strike"), S("Judgment") },
    { S("Wake of Ashes"), S("Avenging Wrath", "c"), S("Divine Storm") },
})

Retail.RoninDPS_Paladin_Ret_Templar = DPS("RoninDPS_Paladin_Ret_Templar", 70, C_PAL, {
    { S("Hammer of Light"), S("Wake of Ashes"), S("Divine Toll", "c") },
    { S("Execution Sentence"), S("Hammer of Wrath"), S("Final Verdict") },
    { S("Final Verdict"), S("Judgment"), S("Blade of Justice") },
    { S("Judgment"), S("Blade of Justice"), S("Final Verdict") },
    { S("Final Verdict"), S("Templar Slash"), S("Templar Strike") },
    { S("Avenging Wrath", "c"), S("Hammer of Light"), S("Wake of Ashes") },
}, D_PAL, "Retribution Paladin, Templar. Delve: Templar (Hammer of Light, Templar Strikes, Final Verdict / Divine Storm). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Word of Glory, Alt = Hammer of Justice. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Crusader Strike"), S("Judgment"), S("Hammer of Wrath") },
    { S("Blade of Justice"), S("Templar Strike"), S("Judgment") },
    { S("Final Verdict"), S("Wake of Ashes"), S("Avenging Wrath", "c") },
})

Retail.RoninDPS_Pal_Ret_Templar_AoE = DPS("RoninDPS_Pal_Ret_Templar_AoE", 70, C_PAL, {
    { S("Hammer of Light"), S("Wake of Ashes"), S("Divine Toll", "c") },
    { S("Execution Sentence"), S("Hammer of Wrath"), S("Divine Storm") },
    { S("Divine Storm"), S("Judgment"), S("Blade of Justice") },
    { S("Judgment"), S("Blade of Justice"), S("Divine Storm") },
    { S("Divine Storm"), S("Templar Slash"), S("Templar Strike") },
    { S("Avenging Wrath", "c"), S("Hammer of Light"), S("Wake of Ashes") },
}, D_PAL, "Retribution Paladin, Templar. Delve: Templar (Hammer of Light, Templar Strikes, Final Verdict / Divine Storm). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Word of Glory, Alt = Hammer of Justice. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Divine Storm"), S("Judgment"), S("Hammer of Wrath") },
    { S("Blade of Justice"), S("Crusader Strike"), S("Judgment") },
    { S("Wake of Ashes"), S("Avenging Wrath", "c"), S("Divine Storm") },
})

Retail.RoninDPS_Fury_Slayer = DPS("RoninDPS_Fury_Slayer", 72, C_WARF, {
    { S("Rampage"), S("Execute"), S("Bloodthirst") },
    { S("Execute"), S("Rampage"), S("Raging Blow") },
    { S("Bloodthirst"), S("Raging Blow"), S("Wrecking Throw") },
    { S("Raging Blow"), S("Bloodthirst"), S("Slam") },
    { S("Bladestorm", "c"), S("Whirlwind"), S("Slam") },
    { S("Recklessness", "c"), S("Avatar", "c"), S("Odyn's Fury", "c"), S("Raging Blow") },
}, D_WARF, "Fury Warrior, Slayer. Raid: Slayer (Bladestorm, Whirlwind, Recklessness with Avatar). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Bloodthirst"), S("Raging Blow"), S("Rampage") },
    { S("Execute"), S("Whirlwind"), S("Bloodthirst") },
    { S("Recklessness", "c"), S("Heroic Strike"), S("Slam") },
})

Retail.RoninDPS_Fury_Slayer_AoE = DPS("RoninDPS_Fury_Slayer_AoE", 72, C_WARF, {
    { S("Whirlwind"), S("Rampage"), S("Bloodthirst") },
    { S("Execute"), S("Whirlwind"), S("Rampage") },
    { S("Bladestorm", "c"), S("Whirlwind"), S("Raging Blow") },
    { S("Whirlwind"), S("Bloodthirst"), S("Raging Blow") },
    { S("Whirlwind"), S("Slam") },
    { S("Recklessness", "c"), S("Avatar", "c"), S("Odyn's Fury", "c"), S("Whirlwind") },
}, D_WARF, "Fury Warrior, Slayer. Raid: Slayer (Bladestorm, Whirlwind, Recklessness with Avatar). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Whirlwind"), S("Bloodthirst"), S("Raging Blow") },
    { S("Rampage"), S("Execute"), S("Whirlwind") },
    { S("Recklessness", "c"), S("Thunder Clap"), S("Slam") },
})

Retail.RoninDPS_Fury_Thane = DPS("RoninDPS_Fury_Thane", 72, C_WARF, {
    { S("Rampage"), S("Execute"), S("Thunder Blast") },
    { S("Execute"), S("Rampage"), S("Bloodthirst") },
    { S("Thunder Blast"), S("Bloodthirst"), S("Raging Blow") },
    { S("Bloodthirst"), S("Raging Blow"), S("Thunder Clap") },
    { S("Raging Blow"), S("Thunder Clap"), S("Slam") },
    { S("Recklessness", "c"), S("Avatar", "c"), S("Odyn's Fury", "c"), S("Raging Blow") },
}, D_WARF, "Fury Warrior, Mountain Thane. Mythic+ and Delve: Mountain Thane (Thunder Blast, Thunder Clap, Recklessness with Avatar). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Bloodthirst"), S("Raging Blow"), S("Rampage") },
    { S("Execute"), S("Whirlwind"), S("Bloodthirst") },
    { S("Recklessness", "c"), S("Heroic Strike"), S("Slam") },
})

Retail.RoninDPS_Fury_Thane_AoE = DPS("RoninDPS_Fury_Thane_AoE", 72, C_WARF, {
    { S("Thunder Blast"), S("Whirlwind"), S("Rampage") },
    { S("Whirlwind"), S("Execute"), S("Bloodthirst") },
    { S("Thunder Clap"), S("Whirlwind"), S("Raging Blow") },
    { S("Whirlwind"), S("Bloodthirst"), S("Thunder Clap") },
    { S("Whirlwind"), S("Slam") },
    { S("Recklessness", "c"), S("Avatar", "c"), S("Odyn's Fury", "c"), S("Whirlwind") },
}, D_WARF, "Fury Warrior, Mountain Thane. Mythic+ and Delve: Mountain Thane (Thunder Blast, Thunder Clap, Recklessness with Avatar). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Whirlwind"), S("Bloodthirst"), S("Raging Blow") },
    { S("Rampage"), S("Execute"), S("Whirlwind") },
    { S("Recklessness", "c"), S("Thunder Clap"), S("Slam") },
})

Retail.RoninDPS_Arms_Slayer = DPS("RoninDPS_Arms_Slayer", 71, C_WAR, {
    { S("Colossus Smash"), S("Mortal Strike"), S("Overpower") },
    { S("Rend", "s"), S("Execute"), S("Mortal Strike") },
    { S("Execute"), S("Heroic Strike"), S("Overpower") },
    { S("Mortal Strike"), S("Overpower"), S("Slam") },
    { S("Overpower"), S("Slam") },
    { S("Avatar", "c"), S("Bladestorm", "c"), S("Warbreaker", "c"), S("Slam") },
}, D_WAR, "Arms Warrior, Slayer. Raid single target and Mythic+/Delve: Slayer (Overpower, Reap the Storm, Sweeping Strikes, Bladestorm). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Mortal Strike"), S("Overpower"), S("Slam") },
    { S("Execute"), S("Colossus Smash"), S("Rend") },
    { S("Bladestorm", "c"), S("Heroic Strike"), S("Slam") },
})

Retail.RoninDPS_Arms_Slayer_AoE = DPS("RoninDPS_Arms_Slayer_AoE", 71, C_WAR, {
    { S("Sweeping Strikes", "c"), S("Cleave"), S("Whirlwind") },
    { S("Colossus Smash"), S("Cleave"), S("Mortal Strike") },
    { S("Rend", "s"), S("Cleave"), S("Whirlwind") },
    { S("Execute"), S("Cleave"), S("Overpower") },
    { S("Cleave"), S("Whirlwind"), S("Mortal Strike") },
    { S("Avatar", "c"), S("Bladestorm", "c"), S("Warbreaker", "c"), S("Slam") },
}, D_WAR, "Arms Warrior, Slayer. Raid single target and Mythic+/Delve: Slayer (Overpower, Reap the Storm, Sweeping Strikes, Bladestorm). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Whirlwind"), S("Mortal Strike"), S("Overpower") },
    { S("Sweeping Strikes", "c"), S("Cleave"), S("Slam") },
    { S("Bladestorm", "c"), S("Thunder Clap"), S("Slam") },
})

Retail.RoninDPS_Arms_Colossus = DPS("RoninDPS_Arms_Colossus", 71, C_WAR, {
    { S("Colossus Smash"), S("Demolish"), S("Mortal Strike") },
    { S("Rend", "s"), S("Execute"), S("Mortal Strike") },
    { S("Execute"), S("Heroic Strike"), S("Overpower") },
    { S("Mortal Strike"), S("Overpower"), S("Slam") },
    { S("Overpower"), S("Slam") },
    { S("Avatar", "c"), S("Colossus Smash", "c"), S("Warbreaker", "c"), S("Slam") },
}, D_WAR, "Arms Warrior, Colossus. Raid multi target: Colossus (Cleave, Demolish, Colossus Smash). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Mortal Strike"), S("Overpower"), S("Slam") },
    { S("Execute"), S("Colossus Smash"), S("Rend") },
    { S("Bladestorm", "c"), S("Heroic Strike"), S("Slam") },
})

Retail.RoninDPS_Arms_Colossus_AoE = DPS("RoninDPS_Arms_Colossus_AoE", 71, C_WAR, {
    { S("Thunder Clap"), S("Cleave"), S("Whirlwind") },
    { S("Colossus Smash"), S("Demolish"), S("Cleave") },
    { S("Rend", "s"), S("Cleave"), S("Whirlwind") },
    { S("Execute"), S("Cleave"), S("Overpower") },
    { S("Cleave"), S("Whirlwind"), S("Mortal Strike") },
    { S("Avatar", "c"), S("Sweeping Strikes", "c"), S("Warbreaker", "c"), S("Slam") },
}, D_WAR, "Arms Warrior, Colossus. Raid multi target: Colossus (Cleave, Demolish, Colossus Smash). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Whirlwind"), S("Mortal Strike"), S("Overpower") },
    { S("Sweeping Strikes", "c"), S("Cleave"), S("Slam") },
    { S("Bladestorm", "c"), S("Thunder Clap"), S("Slam") },
})

Retail.RoninDPS_Monk_WW_Conduit = DPS("RoninDPS_Monk_WW_Conduit", 269, C_MONK, {
    { S("Whirling Dragon Punch"), S("Celestial Conduit", "c") },
    { S("Fists of Fury"), S("Rushing Wind Kick"), S("Strike of the Windlord") },
    { R("/castsequence [nochanneling:Fists of Fury] reset=3 Tiger Palm, Rising Sun Kick"), S("Blackout Kick"), S("Tiger Palm") },
    { R("/castsequence [nochanneling:Fists of Fury] reset=3 Tiger Palm, Blackout Kick, Spinning Crane Kick"), S("Blackout Kick") },
    { S("Touch of Death", "c"), S("Zenith Stomp"), S("Blackout Kick") },
    { S("Invoke Xuen, the White Tiger", "c"), S("Zenith", "c"), S("Tiger Palm") },
}, D_MONK, "Windwalker Monk, Conduit of the Celestials. Mythic+, Raid and Delve: Conduit of the Celestials (Celestial Conduit after Strike of the Windlord, Zenith with Invoke Xuen). One macro for single target and cleave. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Vivify, Alt = Leg Sweep. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Tiger Palm"), S("Blackout Kick"), S("Rising Sun Kick") },
    { S("Fists of Fury"), S("Rising Sun Kick"), S("Blackout Kick") },
    { S("Spinning Crane Kick"), S("Tiger Palm"), S("Blackout Kick") },
})

Retail.RoninDPS_Monk_WW_ShadoPan = DPS("RoninDPS_Monk_WW_ShadoPan", 269, C_MONK, {
    { S("Whirling Dragon Punch"), S("Strike of the Windlord") },
    { S("Fists of Fury"), S("Rushing Wind Kick"), S("Rising Sun Kick") },
    { R("/castsequence [nochanneling:Fists of Fury] reset=3 Tiger Palm, Rising Sun Kick"), S("Blackout Kick"), S("Tiger Palm") },
    { R("/castsequence [nochanneling:Fists of Fury] reset=3 Tiger Palm, Blackout Kick, Spinning Crane Kick"), S("Blackout Kick") },
    { S("Touch of Death", "c"), S("Zenith Stomp"), S("Blackout Kick") },
    { S("Invoke Xuen, the White Tiger", "c"), S("Zenith", "c"), S("Tiger Palm") },
}, D_MONK, "Windwalker Monk, Shado-Pan. Raid: Shado-Pan (Flurry Strikes, Zenith). One macro for single target and cleave. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Vivify, Alt = Leg Sweep. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Tiger Palm"), S("Blackout Kick"), S("Rising Sun Kick") },
    { S("Fists of Fury"), S("Rising Sun Kick"), S("Blackout Kick") },
    { S("Spinning Crane Kick"), S("Tiger Palm"), S("Blackout Kick") },
})

Retail.RoninDPS_Feral_Wildstalker = DPS("RoninDPS_Feral_Wildstalker", 103, C_FERAL, {
    { S("Tiger's Fury", "c"), S("Rake", "s"), S("Shred") },
    { S("Feral Frenzy", "c"), S("Frantic Frenzy", "c"), S("Shred") },
    { R("/castsequence reset=6 Shred, Shred, Shred, Rip"), S("Ferocious Bite"), S("Shred") },
    { S("Ravage"), S("Ferocious Bite"), S("Shred") },
    { S("Rake", "s"), S("Chomp"), S("Shred") },
    { S("Berserk", "c"), S("Convoke the Spirits", "c"), S("Tiger's Fury", "c"), S("Shred") },
}, D_FERAL, "Feral Druid, Wildstalker. Raid: Wildstalker (Unseen Predator, Patient Custodian). Mythic+: Wildstalker AoE (Rampant Ferocity, Hunger for Battle). The macro shifts into Cat Form by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Rake"), S("Rip", "c"), S("Ferocious Bite") },
    { S("Shred"), S("Swipe"), S("Ferocious Bite") },
    { S("Tiger's Fury", "c"), S("Berserk", "c"), S("Shred") },
})

Retail.RoninDPS_Feral_Wild_AoE = DPS("RoninDPS_Feral_Wild_AoE", 103, C_FERAL, {
    { S("Tiger's Fury", "c"), S("Primal Wrath"), S("Swipe") },
    { S("Rake", "s"), S("Frantic Frenzy", "c"), S("Swipe") },
    { R("/castsequence reset=6 Swipe, Swipe, Primal Wrath"), S("Ferocious Bite"), S("Swipe") },
    { S("Ravage"), S("Ferocious Bite"), S("Swipe") },
    { S("Chomp"), S("Swipe") },
    { S("Berserk", "c"), S("Convoke the Spirits", "c"), S("Tiger's Fury", "c"), S("Swipe") },
}, D_FERAL, "Feral Druid, Wildstalker. Raid: Wildstalker (Unseen Predator, Patient Custodian). Mythic+: Wildstalker AoE (Rampant Ferocity, Hunger for Battle). The macro shifts into Cat Form by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Rake"), S("Swipe"), S("Rip", "c") },
    { S("Primal Wrath"), S("Shred"), S("Ferocious Bite") },
    { S("Tiger's Fury", "c"), S("Berserk", "c"), S("Swipe") },
})

Retail.RoninDPS_Balance_Keeper = DPS("RoninDPS_Balance_Keeper", 102, C_BAL, {
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Wrath") },
    { S("Force of Nature", "c"), S("Fury of Elune", "c"), S("Starsurge") },
    { S("Starsurge"), S("Starfire"), S("Wrath") },
    { S("Starsurge"), S("Wrath") },
    { S("Starfire"), S("Wrath") },
    { S("Celestial Alignment", "c"), S("Convoke the Spirits", "c"), S("Wrath") },
}, D_BAL, "Balance Druid, Keeper of the Grove. Raid single target: Keeper of the Grove (Force of Nature, Fury of Elune, Starsurge). The macro shifts into Moonkin Form by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Moonfire"), S("Sunfire"), S("Starsurge") },
    { S("Starfire"), S("Wrath"), S("Starsurge") },
    { S("Celestial Alignment", "c"), S("Starsurge"), S("Wrath") },
})

Retail.RoninDPS_Bal_Keeper_AoE = DPS("RoninDPS_Bal_Keeper_AoE", 102, C_BAL, {
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Starfall") },
    { S("Force of Nature", "c"), S("Starfall"), S("Wrath") },
    { S("Starfall"), S("Starsurge"), S("Starfire") },
    { S("Sunfire", "s"), S("Starfall"), S("Wrath") },
    { S("Starfall"), S("Starfire"), S("Wrath") },
    { S("Celestial Alignment", "c"), S("Convoke the Spirits", "c"), S("Starfall") },
}, D_BAL, "Balance Druid, Keeper of the Grove. Raid single target: Keeper of the Grove (Force of Nature, Fury of Elune, Starsurge). The macro shifts into Moonkin Form by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Moonfire"), S("Sunfire"), S("Starfall") },
    { S("Starfire"), S("Starsurge"), S("Wrath") },
    { S("Celestial Alignment", "c"), S("Starfall"), S("Wrath") },
})

Retail.RoninDPS_Balance_Elune = DPS("RoninDPS_Balance_Elune", 102, C_BAL, {
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Wrath") },
    { S("Fury of Elune", "c"), S("Starsurge"), S("Starfire") },
    { S("Starsurge"), S("Starfire"), S("Wrath") },
    { S("Starsurge"), S("Wrath") },
    { S("Starfire"), S("Wrath") },
    { S("Incarnation: Chosen of Elune", "c"), S("Convoke the Spirits", "c"), S("Wrath") },
}, D_BAL, "Balance Druid, Elune's Chosen. Mythic+ and Delve: Elune's Chosen (Lunar Calling, Ascendant Eclipses, Fury of Elune). The macro shifts into Moonkin Form by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Moonfire"), S("Sunfire"), S("Starsurge") },
    { S("Starfire"), S("Wrath"), S("Starsurge") },
    { S("Celestial Alignment", "c"), S("Starsurge"), S("Wrath") },
})

Retail.RoninDPS_Bal_Elune_AoE = DPS("RoninDPS_Bal_Elune_AoE", 102, C_BAL, {
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Starfall") },
    { S("Fury of Elune", "c"), S("Starfall"), S("Wrath") },
    { S("Starfall"), S("Starsurge"), S("Starfire") },
    { S("Sunfire", "s"), S("Starfall"), S("Wrath") },
    { S("Starfall"), S("Starfire"), S("Wrath") },
    { S("Incarnation: Chosen of Elune", "c"), S("Convoke the Spirits", "c"), S("Starfall") },
}, D_BAL, "Balance Druid, Elune's Chosen. Mythic+ and Delve: Elune's Chosen (Lunar Calling, Ascendant Eclipses, Fury of Elune). The macro shifts into Moonkin Form by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Moonfire"), S("Sunfire"), S("Starfall") },
    { S("Starfire"), S("Starsurge"), S("Wrath") },
    { S("Celestial Alignment", "c"), S("Starfall"), S("Wrath") },
})

Retail.RoninDPS_Aff_Hellcaller = DPS("RoninDPS_Aff_Hellcaller", 265, C_LOCK, {
    { S("Haunt"), S("Summon Darkglare", "c"), S("Malevolence", "c") },
    { S("Agony", "s"), S("Wither", "s"), S("Shadow Bolt") },
    { S("Unstable Affliction"), S("Malevolence", "c"), S("Malefic Grasp") },
    { S("Unstable Affliction"), S("Drain Soul"), S("Shadow Bolt") },
    { S("Drain Soul"), S("Shadow Bolt") },
    { S("Summon Darkglare", "c"), S("Malevolence", "c"), S("Haunt") },
}, D_LOCK, "Affliction Warlock, Hellcaller. Wither replaces Corruption, Malevolence with Summon Darkglare. Talents: Hellcaller hero tree; Raid single target Haunt, Unstable Affliction, Malefic Grasp; Mythic+ Seed of Corruption. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Agony", "s"), S("Corruption", "s") },
    { S("Unstable Affliction"), S("Haunt") },
    { S("Summon Darkglare", "c"), S("Malefic Grasp") },
    { S("Drain Soul"), S("Shadow Bolt") },
})

Retail.RoninDPS_Aff_Hellcaller_AoE = DPS("RoninDPS_Aff_Hellcaller_AoE", 265, C_LOCK, {
    { S("Haunt"), S("Summon Darkglare", "c"), S("Malevolence", "c") },
    { S("Seed of Corruption"), S("Malevolence", "c"), S("Unstable Affliction") },
    { S("Agony", "s"), S("Wither", "s"), S("Shadow Bolt") },
    { S("Seed of Corruption"), S("Unstable Affliction"), S("Shadow Bolt") },
    { S("Shadow Bolt"), S("Drain Soul") },
    { S("Summon Darkglare", "c"), S("Malevolence", "c"), S("Haunt") },
}, D_LOCK, "Affliction Warlock, Hellcaller. Wither replaces Corruption, Malevolence with Summon Darkglare. Talents: Hellcaller hero tree; Raid single target Haunt, Unstable Affliction, Malefic Grasp; Mythic+ Seed of Corruption. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Agony", "s"), S("Corruption", "s") },
    { S("Haunt"), S("Summon Darkglare", "c"), S("Seed of Corruption") },
    { S("Shadow Bolt"), S("Drain Soul") },
})

Retail.RoninDPS_Aff_SoulHarvester = DPS("RoninDPS_Aff_SoulHarvester", 265, C_LOCK, {
    { S("Haunt"), S("Summon Darkglare", "c"), S("Dark Harvest", "c") },
    { S("Agony", "s"), S("Corruption", "s"), S("Shadow Bolt") },
    { S("Unstable Affliction"), S("Dark Harvest"), S("Malefic Grasp") },
    { S("Dark Harvest"), S("Unstable Affliction"), S("Drain Soul") },
    { S("Drain Soul"), S("Shadow Bolt") },
    { S("Summon Darkglare", "c"), S("Dark Harvest", "c"), S("Haunt") },
}, D_LOCK, "Affliction Warlock, Soul Harvester. Dark Harvest when you are out of shards. Talents: Soul Harvester hero tree; Raid single target Haunt, Unstable Affliction; Mythic+ Seed of Corruption. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Agony", "s"), S("Corruption", "s") },
    { S("Unstable Affliction"), S("Haunt") },
    { S("Summon Darkglare", "c"), S("Malefic Grasp") },
    { S("Drain Soul"), S("Shadow Bolt") },
})

Retail.RoninDPS_Aff_SoulHarv_AoE = DPS("RoninDPS_Aff_SoulHarv_AoE", 265, C_LOCK, {
    { S("Haunt"), S("Summon Darkglare", "c"), S("Dark Harvest", "c") },
    { S("Seed of Corruption"), S("Dark Harvest"), S("Unstable Affliction") },
    { S("Agony", "s"), S("Corruption", "s"), S("Shadow Bolt") },
    { S("Seed of Corruption"), S("Unstable Affliction"), S("Shadow Bolt") },
    { S("Shadow Bolt"), S("Drain Soul") },
    { S("Summon Darkglare", "c"), S("Dark Harvest", "c"), S("Haunt") },
}, D_LOCK, "Affliction Warlock, Soul Harvester. Dark Harvest when you are out of shards. Talents: Soul Harvester hero tree; Raid single target Haunt, Unstable Affliction; Mythic+ Seed of Corruption. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Agony", "s"), S("Corruption", "s") },
    { S("Haunt"), S("Summon Darkglare", "c"), S("Seed of Corruption") },
    { S("Shadow Bolt"), S("Drain Soul") },
})

Retail.RoninDPS_Demo_Diabolist = DPS("RoninDPS_Demo_Diabolist", 266, C_DEMO, {
    { S("Call Dreadstalkers"), S("Power Siphon"), S("Shadow Bolt") },
    { S("Hand of Gul'dan"), S("Demonbolt"), S("Shadow Bolt") },
    { S("Demonbolt"), S("Hand of Gul'dan"), S("Shadow Bolt") },
    { S("Grimoire: Fel Ravager", "c"), S("Summon Doomguard", "c"), S("Shadow Bolt") },
    { S("Grimoire: Imp Lord", "c"), S("Demonbolt"), S("Shadow Bolt") },
    { S("Summon Demonic Tyrant", "c"), S("Summon Vilefiend", "c"), S("Shadow Bolt") },
}, D_DEMO, "Demonology Warlock, Diabolist. Shadow Bolt builds shards, Hand of Gul'dan at 3+, Demonbolt on Demonic Core. Talents: Diabolist hero tree, Summon Demonic Tyrant. The macro summons your Felguard. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Call Dreadstalkers"), S("Summon Demonic Tyrant", "c"), S("Power Siphon") },
    { S("Hand of Gul'dan"), S("Demonbolt"), S("Shadow Bolt") },
    { S("Shadow Bolt") },
})

Retail.RoninDPS_Demo_Diab_AoE = DPS("RoninDPS_Demo_Diab_AoE", 266, C_DEMO, {
    { S("Call Dreadstalkers"), S("Summon Demonic Tyrant", "c"), S("Shadow Bolt") },
    { S("Implosion"), S("Hand of Gul'dan"), S("Demonbolt") },
    { S("Doom", "s"), S("Demonbolt") },
    { S("Grimoire: Fel Ravager", "c"), S("Grimoire: Imp Lord", "c"), S("Shadow Bolt") },
    { S("Shadow Bolt"), S("Demonbolt") },
    { S("Dominion of Argus", "c"), S("Summon Vilefiend", "c"), S("Implosion"), S("Shadow Bolt") },
}, D_DEMO, "Demonology Warlock, Diabolist. Shadow Bolt builds shards, Hand of Gul'dan at 3+, Demonbolt on Demonic Core. Talents: Diabolist hero tree, Summon Demonic Tyrant. The macro summons your Felguard. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Call Dreadstalkers"), S("Summon Demonic Tyrant", "c"), S("Implosion") },
    { S("Hand of Gul'dan"), S("Implosion"), S("Demonbolt") },
    { S("Shadow Bolt") },
})

Retail.RoninDPS_Demo_SoulHarvester = DPS("RoninDPS_Demo_SoulHarvester", 266, C_DEMO, {
    { S("Call Dreadstalkers"), S("Power Siphon"), S("Shadow Bolt") },
    { S("Hand of Gul'dan"), S("Demonbolt"), S("Shadow Bolt") },
    { S("Demonbolt"), S("Hand of Gul'dan"), S("Shadow Bolt") },
    { S("Grimoire: Fel Ravager", "c"), S("Summon Doomguard", "c"), S("Shadow Bolt") },
    { S("Grimoire: Imp Lord", "c"), S("Demonbolt"), S("Shadow Bolt") },
    { S("Summon Demonic Tyrant", "c"), S("Summon Vilefiend", "c"), S("Shadow Bolt") },
}, D_DEMO, "Demonology Warlock, Soul Harvester. Dreadstalkers, Hand of Gul'dan and Demonbolt, Tyrant on cooldown. Talents: Soul Harvester hero tree. The macro summons your Felguard. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Call Dreadstalkers"), S("Summon Demonic Tyrant", "c"), S("Power Siphon") },
    { S("Hand of Gul'dan"), S("Demonbolt"), S("Shadow Bolt") },
    { S("Shadow Bolt") },
})

Retail.RoninDPS_Demo_SoulH_AoE = DPS("RoninDPS_Demo_SoulH_AoE", 266, C_DEMO, {
    { S("Call Dreadstalkers"), S("Summon Demonic Tyrant", "c"), S("Shadow Bolt") },
    { S("Implosion"), S("Hand of Gul'dan"), S("Demonbolt") },
    { S("Doom", "s"), S("Demonbolt") },
    { S("Grimoire: Fel Ravager", "c"), S("Grimoire: Imp Lord", "c"), S("Shadow Bolt") },
    { S("Shadow Bolt"), S("Demonbolt") },
    { S("Dominion of Argus", "c"), S("Summon Vilefiend", "c"), S("Implosion"), S("Shadow Bolt") },
}, D_DEMO, "Demonology Warlock, Soul Harvester. Dreadstalkers, Hand of Gul'dan and Demonbolt, Tyrant on cooldown. Talents: Soul Harvester hero tree. The macro summons your Felguard. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Call Dreadstalkers"), S("Summon Demonic Tyrant", "c"), S("Implosion") },
    { S("Hand of Gul'dan"), S("Implosion"), S("Demonbolt") },
    { S("Shadow Bolt") },
})

Retail.RoninDPS_Destro_Hellcaller = DPS("RoninDPS_Destro_Hellcaller", 267, C_LOCK, {
    { S("Chaos Bolt"), S("Conflagrate"), S("Incinerate") },
    { S("Wither", "s"), S("Immolate", "s"), S("Incinerate") },
    { S("Shadowburn"), S("Chaos Bolt"), S("Soul Fire") },
    { S("Conflagrate"), S("Soul Fire"), S("Incinerate") },
    { S("Chaos Bolt"), S("Incinerate") },
    { S("Summon Infernal", "c"), S("Malevolence", "c"), S("Soul Fire"), S("Incinerate") },
}, D_LOCK, "Destruction Warlock, Hellcaller. Wither, Malevolence on cooldown, Chaos Bolt and Soul Fire. Talents: Hellcaller hero tree, Summon Infernal; AoE: Rain of Fire (cast at your cursor), Cataclysm. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Immolate", "s"), S("Wither", "s") },
    { S("Chaos Bolt"), S("Soul Fire"), S("Summon Infernal", "c") },
    { S("Incinerate") },
})

Retail.RoninDPS_Destro_Hell_AoE = DPS("RoninDPS_Destro_Hell_AoE", 267, C_LOCK, {
    { R("/cast [nochanneling,@cursor]Rain of Fire"), S("Chaos Bolt"), S("Conflagrate") },
    { S("Wither", "s"), S("Immolate", "s"), S("Incinerate") },
    { S("Shadowburn"), S("Conflagrate"), S("Cataclysm") },
    { S("Chaos Bolt"), S("Incinerate") },
    { R("/cast [nochanneling,@cursor]Rain of Fire"), S("Incinerate") },
    { S("Summon Infernal", "c"), S("Malevolence", "c"), S("Soul Fire"), S("Incinerate") },
}, D_LOCK, "Destruction Warlock, Hellcaller. Wither, Malevolence on cooldown, Chaos Bolt and Soul Fire. Talents: Hellcaller hero tree, Summon Infernal; AoE: Rain of Fire (cast at your cursor), Cataclysm. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Immolate", "s"), S("Wither", "s") },
    { R("/cast [nochanneling,@cursor]Rain of Fire"), S("Chaos Bolt"), S("Conflagrate") },
    { S("Incinerate") },
})

Retail.RoninDPS_Destro_Diabolist = DPS("RoninDPS_Destro_Diabolist", 267, C_LOCK, {
    { S("Chaos Bolt"), S("Conflagrate"), S("Incinerate") },
    { S("Immolate", "s"), S("Conflagrate"), S("Incinerate") },
    { S("Shadowburn"), S("Chaos Bolt"), S("Soul Fire") },
    { S("Conflagrate"), S("Soul Fire"), S("Incinerate") },
    { S("Chaos Bolt"), S("Incinerate") },
    { S("Summon Infernal", "c"), S("Ruination"), S("Soul Fire"), S("Incinerate") },
}, D_LOCK, "Destruction Warlock, Diabolist. Immolate, Chaos Bolt for Demonic Art, Ruination with Infernal. Talents: Diabolist hero tree; AoE: Rain of Fire (cast at your cursor), Cataclysm. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Immolate", "s"), S("Wither", "s") },
    { S("Chaos Bolt"), S("Soul Fire"), S("Summon Infernal", "c") },
    { S("Incinerate") },
})

Retail.RoninDPS_Destro_Diab_AoE = DPS("RoninDPS_Destro_Diab_AoE", 267, C_LOCK, {
    { R("/cast [nochanneling,@cursor]Rain of Fire"), S("Chaos Bolt"), S("Conflagrate") },
    { S("Immolate", "s"), S("Conflagrate"), S("Cataclysm") },
    { S("Shadowburn"), S("Conflagrate"), S("Cataclysm") },
    { S("Chaos Bolt"), S("Incinerate") },
    { R("/cast [nochanneling,@cursor]Rain of Fire"), S("Incinerate") },
    { S("Summon Infernal", "c"), S("Ruination"), S("Soul Fire"), S("Incinerate") },
}, D_LOCK, "Destruction Warlock, Diabolist. Immolate, Chaos Bolt for Demonic Art, Ruination with Infernal. Talents: Diabolist hero tree; AoE: Rain of Fire (cast at your cursor), Cataclysm. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Drain Life, Alt = Shadowfury. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Immolate", "s"), S("Wither", "s") },
    { R("/cast [nochanneling,@cursor]Rain of Fire"), S("Chaos Bolt"), S("Conflagrate") },
    { S("Incinerate") },
})

Retail.RoninDPS_Frost_Spellslinger = DPS("RoninDPS_Frost_Spellslinger", 64, C_MAGE, {
    { S("Glacial Spike"), S("Frozen Orb", "c"), R("/cast [nochanneling,buff:Brain Freeze]Flurry"), S("Frostbolt") },
    { R("/cast [nochanneling,buff:Brain Freeze]Flurry"), R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Frozen Orb", "c") },
    { R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Ray of Frost"), S("Glacial Spike") },
    { S("Ray of Frost"), S("Ice Lance"), S("Frostbolt") },
    { S("Frostbolt"), S("Ice Lance") },
    { S("Icy Veins", "c"), S("Frozen Orb", "c"), S("Frostbolt") },
}, D_MAGE, "Frost Mage, Spellslinger. Flurry on Brain Freeze, Ice Lance on Fingers of Frost, Glacial Spike, Ray of Frost. Talents: Spellslinger hero tree; AoE: Blizzard (cast at your cursor). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { R("/cast [nochanneling,buff:Brain Freeze]Flurry"), S("Frozen Orb", "c"), S("Glacial Spike") },
    { R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Ray of Frost") },
    { S("Frostbolt"), S("Frostfire Bolt") },
})

Retail.RoninDPS_Frost_Spell_AoE = DPS("RoninDPS_Frost_Spell_AoE", 64, C_MAGE, {
    { S("Glacial Spike"), S("Frozen Orb", "c"), R("/cast [nochanneling,buff:Brain Freeze]Flurry"), S("Frostbolt") },
    { R("/cast [nochanneling,buff:Freezing Rain,@cursor]Blizzard"), R("/cast [nochanneling,buff:Brain Freeze]Flurry"), R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance") },
    { R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Ray of Frost"), S("Glacial Spike") },
    { S("Ray of Frost"), S("Ice Lance"), S("Frostbolt") },
    { S("Frostbolt"), S("Ice Lance") },
    { S("Icy Veins", "c"), S("Frozen Orb", "c"), S("Frostbolt") },
}, D_MAGE, "Frost Mage, Spellslinger. Flurry on Brain Freeze, Ice Lance on Fingers of Frost, Glacial Spike, Ray of Frost. Talents: Spellslinger hero tree; AoE: Blizzard (cast at your cursor). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { R("/cast [nochanneling,@cursor]Blizzard"), R("/cast [nochanneling,buff:Brain Freeze]Flurry"), S("Frozen Orb", "c") },
    { R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Glacial Spike"), S("Ray of Frost") },
    { S("Frostbolt"), S("Frostfire Bolt") },
})

Retail.RoninDPS_Frost_Frostfire = DPS("RoninDPS_Frost_Frostfire", 64, C_MAGE, {
    { S("Glacial Spike"), S("Comet Storm"), S("Frozen Orb", "c"), S("Frostbolt") },
    { R("/cast [nochanneling,buff:Brain Freeze]Flurry"), R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Frozen Orb", "c") },
    { R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Ray of Frost"), S("Glacial Spike") },
    { S("Comet Storm"), S("Ice Lance"), S("Frostfire Bolt") },
    { S("Frostfire Bolt"), S("Ice Lance") },
    { S("Icy Veins", "c"), S("Frozen Orb", "c"), S("Frostfire Bolt") },
}, D_MAGE, "Frost Mage, Frostfire. Glacial Spike then Comet Storm, Frostfire Bolt as filler. Talents: Frostfire hero tree. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { R("/cast [nochanneling,buff:Brain Freeze]Flurry"), S("Frozen Orb", "c"), S("Glacial Spike") },
    { R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Ray of Frost") },
    { S("Frostbolt"), S("Frostfire Bolt") },
})

Retail.RoninDPS_Frost_FF_AoE = DPS("RoninDPS_Frost_FF_AoE", 64, C_MAGE, {
    { S("Glacial Spike"), S("Comet Storm"), S("Frozen Orb", "c"), S("Frostbolt") },
    { R("/cast [nochanneling,buff:Brain Freeze]Flurry"), R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Frozen Orb", "c") },
    { R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Comet Storm"), S("Glacial Spike") },
    { S("Comet Storm"), S("Ice Lance"), S("Frostfire Bolt") },
    { S("Frostfire Bolt"), S("Ice Lance") },
    { S("Icy Veins", "c"), S("Frozen Orb", "c"), S("Frostfire Bolt") },
}, D_MAGE, "Frost Mage, Frostfire. Glacial Spike then Comet Storm, Frostfire Bolt as filler. Talents: Frostfire hero tree. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { R("/cast [nochanneling,@cursor]Blizzard"), R("/cast [nochanneling,buff:Brain Freeze]Flurry"), S("Frozen Orb", "c") },
    { R("/cast [nochanneling,buff:Fingers of Frost]Ice Lance"), S("Glacial Spike"), S("Ray of Frost") },
    { S("Frostbolt"), S("Frostfire Bolt") },
})

Retail.RoninDPS_Fire_Frostfire = DPS("RoninDPS_Fire_Frostfire", 63, C_MAGE, {
    { S("Combustion", "c"), R("/cast [nochanneling,@cursor]Meteor"), R("/cast [nochanneling,buff:Hot Streak!]Pyroblast"), S("Fireball") },
    { R("/cast [nochanneling,buff:Hot Streak!]Pyroblast"), R("/cast [nochanneling,buff:Heating Up]Fire Blast"), R("/cast [nochanneling,buff:Heat Shimmer]Scorch") },
    { R("/cast [nochanneling,buff:Heating Up]Fire Blast"), R("/cast [nochanneling,buff:Heat Shimmer]Scorch"), S("Frostfire Bolt") },
    { S("Frostfire Bolt"), S("Fireball"), S("Scorch") },
    { S("Scorch"), S("Fireball") },
    { S("Combustion", "c"), R("/cast [nochanneling,@cursor]Meteor"), S("Fireball") },
}, D_MAGE, "Fire Mage, Frostfire. Combustion with Meteor, Pyroblast on Hot Streak, Frostfire Bolt filler. Talents: Frostfire hero tree; AoE: Flamestrike on Hot Streak (cast at your cursor). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Combustion", "c"), R("/cast [nochanneling,buff:Hot Streak!]Pyroblast"), R("/cast [nochanneling,buff:Heating Up]Fire Blast") },
    { S("Fireball"), S("Scorch"), S("Frostfire Bolt") },
    { S("Scorch"), S("Fireball") },
})

Retail.RoninDPS_Fire_FF_AoE = DPS("RoninDPS_Fire_FF_AoE", 63, C_MAGE, {
    { S("Combustion", "c"), R("/cast [nochanneling,@cursor]Meteor"), R("/cast [nochanneling,buff:Hot Streak!,@cursor]Flamestrike") },
    { R("/cast [nochanneling,buff:Hot Streak!,@cursor]Flamestrike"), R("/cast [nochanneling,buff:Heating Up]Fire Blast"), R("/cast [nochanneling,buff:Heat Shimmer]Scorch") },
    { R("/cast [nochanneling,buff:Heating Up]Fire Blast"), R("/cast [nochanneling,buff:Heat Shimmer]Scorch"), S("Frostfire Bolt") },
    { S("Frostfire Bolt"), S("Fireball"), S("Scorch") },
    { S("Scorch"), S("Fireball") },
    { S("Combustion", "c"), R("/cast [nochanneling,@cursor]Meteor"), S("Fireball") },
}, D_MAGE, "Fire Mage, Frostfire. Combustion with Meteor, Pyroblast on Hot Streak, Frostfire Bolt filler. Talents: Frostfire hero tree; AoE: Flamestrike on Hot Streak (cast at your cursor). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Combustion", "c"), R("/cast [nochanneling,buff:Hot Streak!,@cursor]Flamestrike"), R("/cast [nochanneling,buff:Heating Up]Fire Blast") },
    { R("/cast [nochanneling,@cursor]Meteor"), S("Fireball"), S("Frostfire Bolt") },
    { S("Scorch"), S("Fireball") },
})

Retail.RoninDPS_Fire_Sunfury = DPS("RoninDPS_Fire_Sunfury", 63, C_MAGE, {
    { S("Combustion", "c"), R("/cast [nochanneling,@cursor]Meteor"), R("/cast [nochanneling,buff:Hot Streak!]Pyroblast"), S("Fireball") },
    { R("/cast [nochanneling,buff:Hot Streak!]Pyroblast"), R("/cast [nochanneling,buff:Heating Up]Fire Blast"), R("/cast [nochanneling,buff:Heat Shimmer]Scorch") },
    { R("/cast [nochanneling,buff:Heating Up]Fire Blast"), R("/cast [nochanneling,buff:Heat Shimmer]Scorch"), S("Fireball") },
    { S("Fireball"), S("Scorch"), S("Frostfire Bolt") },
    { S("Scorch"), S("Fireball") },
    { S("Combustion", "c"), R("/cast [nochanneling,@cursor]Meteor"), S("Fireball") },
}, D_MAGE, "Fire Mage, Sunfury. Combustion summons an Arcane Phoenix, Meteor, Pyroblast on Hot Streak, Scorch kept in your build. Talents: Sunfury hero tree; AoE: Flamestrike on Hot Streak (cast at your cursor). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Combustion", "c"), R("/cast [nochanneling,buff:Hot Streak!]Pyroblast"), R("/cast [nochanneling,buff:Heating Up]Fire Blast") },
    { S("Fireball"), S("Scorch"), S("Frostfire Bolt") },
    { S("Scorch"), S("Fireball") },
})

Retail.RoninDPS_Fire_Sun_AoE = DPS("RoninDPS_Fire_Sun_AoE", 63, C_MAGE, {
    { S("Combustion", "c"), R("/cast [nochanneling,@cursor]Meteor"), R("/cast [nochanneling,buff:Hot Streak!,@cursor]Flamestrike") },
    { R("/cast [nochanneling,buff:Hot Streak!,@cursor]Flamestrike"), R("/cast [nochanneling,buff:Heating Up]Fire Blast"), R("/cast [nochanneling,buff:Heat Shimmer]Scorch") },
    { R("/cast [nochanneling,buff:Heating Up]Fire Blast"), R("/cast [nochanneling,buff:Heat Shimmer]Scorch"), S("Fireball") },
    { S("Fireball"), S("Scorch"), S("Frostfire Bolt") },
    { S("Scorch"), S("Fireball") },
    { S("Combustion", "c"), R("/cast [nochanneling,@cursor]Meteor"), S("Fireball") },
}, D_MAGE, "Fire Mage, Sunfury. Combustion summons an Arcane Phoenix, Meteor, Pyroblast on Hot Streak, Scorch kept in your build. Talents: Sunfury hero tree; AoE: Flamestrike on Hot Streak (cast at your cursor). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Combustion", "c"), R("/cast [nochanneling,buff:Hot Streak!,@cursor]Flamestrike"), R("/cast [nochanneling,buff:Heating Up]Fire Blast") },
    { R("/cast [nochanneling,@cursor]Meteor"), S("Fireball"), S("Frostfire Bolt") },
    { S("Scorch"), S("Fireball") },
})

Retail.RoninDPS_Arc_Spellslinger = DPS("RoninDPS_Arc_Spellslinger", 62, C_MAGE, {
    { R("/cast [nochanneling,buff:Clearcasting]Arcane Missiles"), S("Arcane Orb"), S("Prismatic Bolt") },
    { R("/castsequence [nochanneling] reset=10 Arcane Blast, Arcane Blast, Arcane Blast, Arcane Blast, Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Orb"), S("Prismatic Bolt"), S("Arcane Blast") },
    { S("Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Blast") },
    { S("Touch of the Magi", "c"), S("Arcane Surge", "c"), S("Arcane Blast") },
}, D_MAGE, "Arcane Mage, Spellslinger. Touch of the Magi into Arcane Surge, Missiles on Clearcasting, Prismatic Bolt. Talents: Spellslinger hero tree. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { R("/cast [nochanneling,buff:Clearcasting]Arcane Missiles"), S("Arcane Orb"), S("Touch of the Magi", "c") },
    { R("/castsequence [nochanneling] reset=10 Arcane Blast, Arcane Blast, Arcane Blast, Arcane Blast, Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Blast") },
})

Retail.RoninDPS_Arc_Spell_AoE = DPS("RoninDPS_Arc_Spell_AoE", 62, C_MAGE, {
    { R("/cast [nochanneling,buff:Clearcasting]Arcane Missiles"), S("Arcane Orb"), S("Prismatic Bolt") },
    { R("/castsequence [nochanneling] reset=10 Arcane Blast, Arcane Blast, Arcane Blast, Arcane Blast, Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Pulse"), S("Arcane Orb"), S("Arcane Blast") },
    { S("Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Blast") },
    { S("Touch of the Magi", "c"), S("Arcane Surge", "c"), S("Arcane Blast") },
}, D_MAGE, "Arcane Mage, Spellslinger. Touch of the Magi into Arcane Surge, Missiles on Clearcasting, Prismatic Bolt. Talents: Spellslinger hero tree. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { R("/cast [nochanneling,buff:Clearcasting]Arcane Missiles"), S("Arcane Orb"), S("Touch of the Magi", "c") },
    { S("Arcane Pulse"), S("Arcane Orb"), S("Arcane Blast") },
    { S("Arcane Blast") },
})

Retail.RoninDPS_Arc_Sunfury = DPS("RoninDPS_Arc_Sunfury", 62, C_MAGE, {
    { R("/cast [nochanneling,buff:Clearcasting]Arcane Missiles"), S("Arcane Orb") },
    { R("/castsequence [nochanneling] reset=10 Arcane Blast, Arcane Blast, Arcane Blast, Arcane Blast, Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Orb"), S("Arcane Blast") },
    { S("Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Blast") },
    { S("Touch of the Magi", "c"), S("Arcane Surge", "c"), S("Arcane Blast") },
}, D_MAGE, "Arcane Mage, Sunfury. Touch of the Magi into Arcane Surge, Missiles on Clearcasting, Arcane Barrage at high Salvo. Talents: Sunfury hero tree. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { R("/cast [nochanneling,buff:Clearcasting]Arcane Missiles"), S("Arcane Orb"), S("Touch of the Magi", "c") },
    { R("/castsequence [nochanneling] reset=10 Arcane Blast, Arcane Blast, Arcane Blast, Arcane Blast, Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Blast") },
})

Retail.RoninDPS_Arc_Sun_AoE = DPS("RoninDPS_Arc_Sun_AoE", 62, C_MAGE, {
    { R("/cast [nochanneling,buff:Clearcasting]Arcane Missiles"), S("Arcane Orb") },
    { R("/castsequence [nochanneling] reset=10 Arcane Blast, Arcane Blast, Arcane Blast, Arcane Blast, Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Pulse"), S("Arcane Orb"), S("Arcane Blast") },
    { S("Arcane Barrage"), S("Arcane Blast") },
    { S("Arcane Blast") },
    { S("Touch of the Magi", "c"), S("Arcane Surge", "c"), S("Arcane Blast") },
}, D_MAGE, "Arcane Mage, Sunfury. Touch of the Magi into Arcane Surge, Missiles on Clearcasting, Arcane Barrage at high Salvo. Talents: Sunfury hero tree. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Prismatic Barrier, Alt = Frost Nova. Versions: Mythic+ (cooldowns right at the pull, auto next target), Raid (cooldowns early, keeps your target), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90).", {
    { R("/cast [nochanneling,buff:Clearcasting]Arcane Missiles"), S("Arcane Orb"), S("Touch of the Magi", "c") },
    { S("Arcane Pulse"), S("Arcane Orb"), S("Arcane Blast") },
    { S("Arcane Blast") },
})

Ronin.RetailDPSSequences = Retail

-- ---------------------------------------------------------------------------
-- WoW: FOREVER (spell IDs, rank 1, no [buff]/[debuff] conditions)
-- Level ranges: 1-10, 10-40, 40-60. Modifiers: Shift = heal, Ctrl = interrupt, Alt = class extra.
-- Steps are ladders (2-3 spells, the first one that is ready is cast), no /startattack.
-- ---------------------------------------------------------------------------
local TGT = "/targetenemy [noexists][dead]"

local function Flat(name, specID, notes, versions)
    local v = {}
    for i, x in ipairs(versions) do
        local loop = { Type = "Loop", StepFunction = "Priority", Repeat = "1" }
        local seen = {}
        for _, m in ipairs(x[2]) do
            local text = table.concat(m, "\n")
            if not seen[text] then seen[text] = true; loop[#loop + 1] = { Type = "Action", type = "macro", macro = text } end
        end
        v[i] = { Label = x[1], Actions = { loop }, InbuiltVariables = { Combat = true } }
    end
    return {
        MetaData = { Name = name, Author = "Ronin", SpecID = specID, Default = 1,
            MythicPlus = 1, Heroic = 1, Dungeon = 1, Timewalking = 1, Mythic = 1, PVP = 1, Raid = 1, Scenario = 1,
            Notes = notes, Help = notes },
        Versions = v,
    }
end

-- PALADIN RETRIBUTION (made from RoninForever_Paladin)
local PMA  = "/cast [mod:shift,@player]635;[mod:ctrl]853;[mod:alt]26573"
local PM   = "/cast [mod:shift,@player]19750;[mod:ctrl]853;[mod:alt]26573"
local PSQA = "/castsequence reset=combat/2 20154, 20271, 20271, 20271"
local PSQ  = "/castsequence reset=combat/2 20375, 20271, 20271, 20271"
local FPAL = Flat("RoninFDPS_Paladin_Ret", 1486,
    "Retribution Paladin for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Holy Light / Flash of Light, Ctrl = Hammer of Justice, Alt = Consecration. Seal of Command comes at 20: before that change the seal in the first line to Seal of Righteousness.",
    {
    { "Level 1-10", {
        { TGT, PMA, PSQA, "/cast 679" },
        { TGT, PMA, "/cast 679", "/cast 20271" },
    } },
    { "Level 10-40", {
        { TGT, PMA, PSQ, "/cast 679" },
        { TGT, PMA, "/cast 679", "/cast 20271" },
        { TGT, PMA, "/cast [nomod]24275", "/cast [nomod]879", "/cast [nomod]20473" },
        { TGT, PMA, "/cast 20271", "/cast 679" },
    } },
    { "Level 40-60", {
        { TGT, PM, PSQ, "/cast 679" },
        { TGT, PM, "/cast 679", "/cast 20271" },
        { TGT, PM, "/cast [nomod]24275", "/cast [nomod]879", "/cast [nomod]20473" },
        { TGT, PM, "/cast 20271", "/cast 679" },
    } },
})

-- WARRIOR (Battle Stance DPS): Rend per target, Mortal Strike, Overpower, Execute, Heroic Strike.
local WM  = "/cast [mod:shift]402927;[mod:ctrl]6552;[mod:alt]5246"
local BATTLE = "/cast [nostance:1] 2457"
local FWAR = Flat("RoninFDPS_Warrior", 1491,
    "Arms Warrior DPS for WoW: Forever, Battle Stance. Levels 1-10, 10-40, 40-60. Keys: Shift = Victory Rush, Ctrl = Pummel (needs Berserker Stance, change the stance yourself), Alt = Intimidating Shout.",
    {
    { "Level 1-10", {
        { TGT, WM, "/castsequence [nomod] reset=target 772, null" },
        { TGT, WM, "/cast [nomod] 78" },
    } },
    { "Level 10-40", {
        { TGT, BATTLE, WM, "/cast [nomod] 12294", "/cast [nomod] 7384" },
        { TGT, BATTLE, WM, "/castsequence [nomod] reset=target 772, null", "/cast [nomod] 78" },
        { TGT, BATTLE, WM, "/cast [nomod] 5308", "/cast [nomod] 7384" },
        { TGT, BATTLE, WM, "/cast [nomod] 78" },
    } },
    { "Level 40-60", {
        { TGT, BATTLE, WM, "/cast [nomod] 12294", "/cast [nomod] 5308" },
        { TGT, BATTLE, WM, "/castsequence [nomod] reset=target 772, null", "/cast [nomod] 7384" },
        { TGT, BATTLE, WM, "/cast [nomod] 5308", "/cast [nomod] 1464" },
        { TGT, BATTLE, WM, "/cast [nomod] 7384", "/cast [nomod] 78" },
    } },
})


-- WARRIOR FURY (Berserker Stance from level 30 up; below that it fights like the Arms macro).
local BERS = "/cast [nostance:3] 2458"
local FFUR = Flat("RoninFDPS_Warrior_Fury", 1491,
    "Fury Warrior DPS for WoW: Forever. Levels 1-10, 10-40 (Battle Stance until you learn Berserker Stance), 40-60 (Berserker Stance: Whirlwind, Bloodthirst, Execute). Keys: Shift = Victory Rush, Ctrl = Pummel, Alt = Intimidating Shout.",
    {
    { "Level 1-10", {
        { TGT, WM, "/castsequence [nomod] reset=target 772, null" },
        { TGT, WM, "/cast [nomod] 78" },
    } },
    { "Level 10-40", {
        { TGT, BATTLE, WM, "/cast [nomod] 7384", "/cast [nomod] 5308" },
        { TGT, BATTLE, WM, "/castsequence [nomod] reset=target 772, null", "/cast [nomod] 78" },
        { TGT, BATTLE, WM, "/cast [nomod] 5308", "/cast [nomod] 78" },
    } },
    { "Level 40-60", {
        { TGT, BERS, WM, "/cast [nomod] 1680", "/cast [nomod] 23881" },
        { TGT, BERS, WM, "/cast [nomod] 23881", "/cast [nomod] 5308" },
        { TGT, BERS, WM, "/cast [nomod] 5308", "/cast [nomod] 78" },
        { TGT, BERS, WM, "/cast [nomod] 78" },
    } },
})

-- DRUID CAT (made from RoninForever_Druid): caster below the Cat Form, then Claw/Shred, Rake, Rip, Ferocious Bite.
local CM  = "/cast [mod:shift,@player]5185;[mod:ctrl]1238122"
local CAT = "/cast [noform:3] 768"
local CMA = "/cast [mod:shift,@player]5185;[mod:alt]339"
local FDRU = Flat("RoninFDPS_Druid_Cat", 103,
    "Feral Cat for WoW: Forever. Levels 1-10 (caster: Moonfire, Wrath), 10-40, 40-60. Cat Form comes at 20: until then the macro keeps casting Moonfire and Wrath. Keys: Shift = Healing Touch, Ctrl = Feral Charge (Alt = Entangling Roots as a caster).",
    {
    { "Level 1-10", {
        { TGT, CMA, "/castsequence [nomod] reset=target 8921, 5176, 5176, 5176" },
        { TGT, CMA, "/cast [nomod] 5176" },
    } },
    { "Level 10-40", {
        { TGT, CAT, CM, "/cast [form,nomod] 1082", "/castsequence [noform,nomod] reset=target 8921, 5176, 5176, 5176" },
        { TGT, CAT, CM, "/castsequence [form,nomod] reset=target 1822, 1082, 1082, 1079", "/cast [noform,nomod] 5176" },
        { TGT, CAT, CM, "/cast [form,nomod] 22568", "/cast [form,nomod] Shifting Power", "/cast [noform,nomod] 5176" },
        { TGT, CAT, CM, "/castsequence [form,nomod] reset=target/30 770, null", "/cast [noform,nomod] 5176" },
    } },
    { "Level 40-60", {
        { TGT, CAT, CM, "/cast [nomod] 5221", "/cast [nomod] 1082" },
        { TGT, CAT, CM, "/castsequence [nomod] reset=target 1822, 5221, 5221, 1079", "/cast [nomod] 1082" },
        { TGT, CAT, CM, "/cast [nomod] 22568", "/cast [nomod] Shifting Power", "/cast [nomod] 1082" },
        { TGT, CAT, CM, "/castsequence [nomod] reset=target/30 770, null", "/cast [nomod] 1082" },
    } },
})

-- SHAMAN (DPS only, no tank): Enhancement and Elemental.
-- Shift = Healing Wave, Ctrl = Earth Shock (interrupt), Alt = totems (castsequence, press Alt again for the next totem).
local SMA  = "/cast [mod:shift,@player]331;[mod:ctrl]8042;[mod:alt]8071"
local SM   = "/cast [mod:shift,@player]331;[mod:ctrl]8042"
local TOTA = "/castsequence [mod:alt] reset=5 8075, 3599, null"
local TOTB = "/castsequence [mod:alt] reset=5 8075, 8512, 8190, null"
local FENH = Flat("RoninFDPS_Shaman_Enh", 1489,
    "Enhancement Shaman for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Healing Wave, Ctrl = Earth Shock, Alt = totems (press again for the next totem). Put the weapon imbue and Lightning Shield on by hand.",
    {
    { "Level 1-10", {
        { TGT, SMA, "/cast [nomod] 403" },
        { TGT, SMA, "/cast [nomod] 8042", "/cast [nomod] 403" },
    } },
    { "Level 10-40", {
        { TGT, SM, TOTA, "/cast [nomod] 17364", "/cast [nomod] 8042" },
        { SM, TOTA, "/castsequence [nomod] reset=target/12 8050, null", "/cast [nomod] 403" },
        { TGT, SM, TOTA, "/cast [nomod] 17364", "/cast [nomod] 403" },
    } },
    { "Level 40-60", {
        { TGT, SM, TOTB, "/cast [nomod] 17364", "/cast [nomod] 8042" },
        { SM, TOTB, "/castsequence [nomod] reset=target/12 8050, null", "/cast [nomod] 403" },
        { TGT, SM, TOTB, "/cast [nomod] Fire Nova", "/cast [nomod] 403" },
        { TGT, SM, TOTB, "/cast [nomod] 403" },
    } },
})
local FELE = Flat("RoninFDPS_Shaman_Ele", 1489,
    "Elemental Shaman for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Healing Wave, Ctrl = Earth Shock, Alt = totems (press again for the next totem). Put Lightning Shield on yourself before the pull (it lasts 10 minutes).",
    {
    { "Level 1-10", {
        { TGT, SMA, "/cast [nomod] 403" },
        { TGT, SMA, "/castsequence [nomod] reset=target 8050, 403, 403" },
    } },
    { "Level 10-40", {
        { TGT, SM, TOTA, "/cast [nomod] 421", "/cast [nomod] 403" },
        { SM, TOTA, "/castsequence [nomod] reset=target/12 8050, null", "/cast [nomod] 403" },
        { TGT, SM, TOTA, "/cast [nomod] 403" },
    } },
    { "Level 40-60", {
        { TGT, SM, TOTB, "/cast [nomod] 421", "/cast [nomod] 403" },
        { SM, TOTB, "/castsequence [nomod] reset=target/12 8050, null", "/cast [nomod] 403" },
        { TGT, SM, TOTB, "/cast [nomod] 8042", "/cast [nomod] 403" },
        { TGT, SM, TOTB, "/cast [nomod] 403" },
    } },
})

-- WARLOCK (Affliction, Demonology, Destruction) and MAGE (Arcane, Fire, Frost). Written from scratch for Ronin.
-- Warlock keys: Shift = Drain Life, Ctrl = Death Coil (level 42), Alt = Rain of Fire at your cursor.
-- Mage keys: Shift = Evocation, Ctrl = Counterspell, Alt = Frost Nova. No wand lines (Shoot is a toggle): use your wand by hand.
-- DoTs are single-spell castsequences with a fallback cast, so they never stall on a spell you have not learned yet.
local WLM  = "/cast [mod:shift]689;[mod:ctrl]6789;[mod:alt,@cursor]5740"
local PETA = "/cast [nopet,nodead]688"
local PETB = "/cast [nopet,nodead]697"
local PATK = "/petattack"
local MGM  = "/cast [mod:shift]12051;[mod:ctrl]2139;[mod:alt]122"
local FAFF = Flat("RoninFDPS_Warlock_Aff", 1490,
    "Affliction Warlock for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Drain Life, Ctrl = Death Coil, Alt = Rain of Fire (at your cursor). The macro summons your Imp (1-10) or Voidwalker and sends it in. Use your wand and Life Tap by hand.",
    {
    { "Level 1-10", {
        { TGT, WLM, PETA, PATK, "/castsequence [nomod] reset=target/15 348, null", "/cast [nomod] 686" },
        { TGT, WLM, PETA, PATK, "/castsequence [nomod] reset=target/18 172, null", "/cast [nomod] 686" },
        { TGT, WLM, PETA, PATK, "/castsequence [nomod] reset=target/24 Bane of Agony, null", "/cast [nomod] 686" },
        { TGT, WLM, PETA, PATK, "/cast [nomod] 686" },
    } },
    { "Level 10-40", {
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/18 172, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/24 Bane of Agony, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/30 18265, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/15 348, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/cast [nomod] 686" },
    } },
    { "Level 40-60", {
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/18 172, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/24 Bane of Agony, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/30 18265, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/15 348, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, "/castsequence [nomod] reset=target/60 1490, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/cast [nomod] 686" },
    } },
})
local FDEM = Flat("RoninFDPS_Warlock_Demo", 1490,
    "Demonology Warlock for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Drain Life, Ctrl = Death Coil, Alt = Rain of Fire (at your cursor). The macro summons your Imp (1-10) or Voidwalker and sends it in; swap the summon line for your Succubus after 20 if you prefer. Soul Link is refreshed out of combat.",
    {
    { "Level 1-10", {
        { TGT, WLM, PETA, PATK, "/castsequence [nomod] reset=target/15 348, null", "/cast [nomod] 686" },
        { TGT, WLM, PETA, PATK, "/castsequence [nomod] reset=target/18 172, null", "/cast [nomod] 686" },
        { TGT, WLM, PETA, PATK, "/castsequence [nomod] reset=target/24 Bane of Agony, null", "/cast [nomod] 686" },
        { TGT, WLM, PETA, PATK, "/cast [nomod] 686" },
    } },
    { "Level 10-40", {
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/18 172, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/15 348, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/24 Bane of Agony, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/cast [nomod] 5676", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=combat 19028, null", "/cast [nomod] 686" },
    } },
    { "Level 40-60", {
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/18 172, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/15 348, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=target/24 Bane of Agony, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/cast [nomod] 5676", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/castsequence [nomod] reset=combat 19028, null", "/cast [nomod] 686" },
    } },
})
local FDES = Flat("RoninFDPS_Warlock_Destro", 1490,
    "Destruction Warlock for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Drain Life, Ctrl = Death Coil, Alt = Rain of Fire (at your cursor). Shadowburn from 20, Conflagrate from 25, Incinerate from 40. The macro summons your Imp (1-10) or Voidwalker and sends it in.",
    {
    { "Level 1-10", {
        { TGT, WLM, PETA, PATK, "/castsequence [nomod] reset=target/15 348, null", "/cast [nomod] 686" },
        { TGT, WLM, PETA, PATK, "/castsequence [nomod] reset=target/18 172, null", "/cast [nomod] 686" },
        { TGT, WLM, PETA, PATK, "/cast [nomod] 686" },
    } },
    { "Level 10-40", {
        { WLM, PETB, PATK, "/castsequence [nomod] reset=target/15 348, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/cast [nomod] 17962", "/cast [nomod] 17877", "/cast [nomod] 686" },
        { WLM, PETB, PATK, "/castsequence [nomod] reset=target/18 172, null", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/cast [nomod] 5676", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/cast [nomod] 686" },
    } },
    { "Level 40-60", {
        { WLM, PETB, PATK, "/castsequence [nomod] reset=target/15 348, null", "/cast [nomod] Incinerate", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/cast [nomod] 17962", "/cast [nomod] 17877", "/cast [nomod] Incinerate" },
        { WLM, PETB, PATK, "/castsequence [nomod] reset=target/18 172, null", "/cast [nomod] Incinerate", "/cast [nomod] 686" },
        { WLM, PETB, PATK, "/castsequence [nomod] reset=target/24 Bane of Agony, null", "/cast [nomod] Incinerate", "/cast [nomod] 686" },
        { TGT, WLM, PETB, PATK, "/cast [nomod] Incinerate", "/cast [nomod] 686" },
    } },
})
local FARC = Flat("RoninFDPS_Mage_Arcane", 1485,
    "Arcane Mage for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Evocation, Ctrl = Counterspell, Alt = Frost Nova. Arcane Missiles from 8, Arcane Blast from 20. Use your wand and Arcane Intellect by hand.",
    {
    { "Level 1-10", {
        { TGT, MGM, "/cast [nomod] 5143", "/cast [nomod] 116" },
        { TGT, MGM, "/cast [nomod] 2136", "/cast [nomod] 116" },
        { TGT, MGM, "/cast [nomod] 116" },
    } },
    { "Level 10-40", {
        { TGT, MGM, "/cast [nomod] Arcane Blast", "/cast [nomod] 5143", "/cast [nomod] 116" },
        { TGT, MGM, "/cast [nomod] 5143", "/cast [nomod] Arcane Blast", "/cast [nomod] 116" },
        { TGT, MGM, "/cast [nomod] 2136", "/cast [nomod] Arcane Blast", "/cast [nomod] 116" },
    } },
    { "Level 40-60", {
        { TGT, MGM, "/cast [nomod] Arcane Blast", "/cast [nomod] 5143", "/cast [nomod] Frostfire Bolt" },
        { TGT, MGM, "/cast [nomod] 5143", "/cast [nomod] Arcane Blast", "/cast [nomod] Frostfire Bolt" },
        { TGT, MGM, "/cast [nomod] 12042", "/cast [nomod] 2136", "/cast [nomod] Arcane Blast", "/cast [nomod] 5143" },
    } },
})
local FFIR = Flat("RoninFDPS_Mage_Fire", 1485,
    "Fire Mage for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Evocation, Ctrl = Counterspell, Alt = Frost Nova. Frostfire Bolt replaces Fireball at 40 (the macro uses both, the first one you know). Use your wand by hand.",
    {
    { "Level 1-10", {
        { TGT, MGM, "/cast [nomod] 133" },
        { TGT, MGM, "/cast [nomod] 2136", "/cast [nomod] 133" },
    } },
    { "Level 10-40", {
        { TGT, MGM, "/cast [nomod] 133" },
        { TGT, MGM, "/cast [nomod] 2136", "/cast [nomod] 133" },
        { TGT, MGM, "/cast [nomod] 11129", "/cast [nomod] 2948", "/cast [nomod] 133" },
    } },
    { "Level 40-60", {
        { TGT, MGM, "/cast [nomod] Frostfire Bolt", "/cast [nomod] 133" },
        { TGT, MGM, "/cast [nomod] 2136", "/cast [nomod] Frostfire Bolt", "/cast [nomod] 133" },
        { TGT, MGM, "/cast [nomod] 11129", "/cast [nomod] 2948", "/cast [nomod] Frostfire Bolt" },
    } },
})
local FFRO = Flat("RoninFDPS_Mage_Frost", 1485,
    "Frost Mage for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Evocation, Ctrl = Counterspell, Alt = Frost Nova. Frostbolt, Ice Lance from your talents, Ice Barrier from 40. Use your wand, Frost Armor and Arcane Intellect by hand.",
    {
    { "Level 1-10", {
        { TGT, MGM, "/cast [nomod] 116" },
        { TGT, MGM, "/cast [nomod] 2136", "/cast [nomod] 116" },
    } },
    { "Level 10-40", {
        { TGT, MGM, "/cast [nomod] 116" },
        { TGT, MGM, "/cast [nomod] Ice Lance", "/cast [nomod] 116" },
        { TGT, MGM, "/cast [nomod] 2136", "/cast [nomod] 116" },
    } },
    { "Level 40-60", {
        { TGT, MGM, "/cast [nomod] 116" },
        { TGT, MGM, "/cast [nomod] Ice Lance", "/cast [nomod] 116" },
        { TGT, MGM, "/cast [nomod] 2136", "/cast [nomod] 116" },
        { TGT, MGM, "/castsequence [nomod] reset=combat 11426, null", "/cast [nomod] 116" },
    } },
})

-- ===== Hunter (WoW: Forever). One sequence for every Hunter: talents and runes you do not have are simply skipped.
-- Shift = Mend Pet, Ctrl = Concussive Shot, Alt = Freezing Trap. The macro calls / revives your pet (from level 10),
-- keeps Auto Shot running (the "!" never turns it off), Serpent Sting and Hunter's Mark once per target.
local HUM = "/cast [mod:shift]136;[mod:ctrl]5116;[mod:alt]1499"
local PETH = "/cast [@pet,dead]Revive Pet;[nopet]Call Pet"
local HAUTO = "/cast [nomod]!Auto Shot"
local ASP = "/cast [nomod]!Aspect of the Hawk"
local FHUN = Flat("RoninFDPS_Hunter", 1484,
    "Hunter for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Mend Pet, Ctrl = Concussive Shot, Alt = Freezing Trap. The macro calls or revives your pet (from level 10) and sends it in, keeps Auto Shot running and Aspect of the Hawk up, Serpent Sting and Hunter's Mark go once on each target. Raptor Strike and Mongoose Bite when the mob reaches you. Aimed Shot, Bestial Wrath and the runes (Chimera Shot, Explosive Shot, Kill Command, Steady Shot) are used when you have them.",
    {
    { "Level 1-10", {
        { TGT, HUM, HAUTO, "/castsequence [nomod] reset=target/15 1978, null", "/cast [nomod] 3044" },
        { TGT, HUM, HAUTO, "/cast [nomod] 2973", "/cast [nomod] 3044" },
        { TGT, HUM, "/castsequence [nomod] reset=target/120 1130, null", "/cast [nomod] 2973" },
    } },
    { "Level 10-40", {
        { TGT, HUM, PETH, PATK, HAUTO, "/cast [nomod] 3044" },
        { TGT, HUM, HAUTO, "/castsequence [nomod] reset=target/15 1978, null", "/cast [nomod] 3044" },
        { TGT, HUM, ASP, "/castsequence [nomod] reset=target/120 1130, null", "/cast [nomod] 2973" },
        { TGT, HUM, PATK, "/cast [nomod] 19434", "/cast [nomod] 2643", "/cast [nomod] 3044" },
        { TGT, HUM, "/cast [nomod] 1495", "/cast [nomod] 2973", "/cast [nomod] 3044" },
    } },
    { "Level 40-60", {
        { TGT, HUM, PETH, PATK, HAUTO, "/cast [nomod] Chimera Shot", "/cast [nomod] 3044" },
        { TGT, HUM, HAUTO, "/castsequence [nomod] reset=target/15 1978, null", "/cast [nomod] Explosive Shot", "/cast [nomod] 19434" },
        { HUM, ASP, "/castsequence [nomod] reset=target/120 1130, null", "/cast [nomod] Kill Command", "/cast [nomod] 3044" },
        { TGT, HUM, PATK, "/cast [nomod,combat] 3045", "/cast [nomod,combat] 19574", "/cast [nomod] Steady Shot" },
        { TGT, HUM, "/cast [nomod] 1495", "/cast [nomod] 2973", "/cast [nomod] 2643" },
    } },
})

-- ===== Priest DAMAGE (WoW: Forever), for leveling and solo. Method Forever leveling guide: Smite and Shadow Word: Pain early,
-- Mind Blast + Shadow Word: Pain + wand from 10, Holy Fire / Penance, Mind Flay and Shadow Word: Death from 40.
-- Shift = heal on yourself, Ctrl = Psychic Scream, Alt = Power Word: Shield on yourself. The wand is used only if you have one.
local PRA = "/cast [mod:shift,@player]2050;[mod:ctrl]8122;[mod:alt,@player]17"
local PRB = "/cast [mod:shift,@player]2061;[mod:ctrl]8122;[mod:alt,@player]17"
local WAND = "/cast [nomod,equipped:Wands]!Shoot;[nomod]585"
local CHAN = "/stopmacro [channeling]"
local FPRI = Flat("RoninFDPS_Priest", 1487,
    "Priest DAMAGE for WoW: Forever (leveling, solo). Levels 1-10, 10-40, 40-60. Keys: Shift = heal on yourself (Lesser Heal, Flash Heal from 40), Ctrl = Psychic Scream, Alt = Power Word: Shield on yourself. Shadow Word: Pain once per target, Mind Blast on cooldown, wand to fill (Smite if you have no wand), Holy Fire and Penance when you have them, Mind Flay and Shadow Word: Death from 40. The macro waits while Mind Flay channels.",
    {
    { "Level 1-10", {
        { TGT, PRA, "/castsequence [nomod] reset=target/18 589, null", "/cast [nomod] 585" },
        { TGT, PRA, "/cast [nomod] 585" },
    } },
    { "Level 10-40", {
        { TGT, PRA, "/castsequence [nomod] reset=target/18 589, null", WAND },
        { TGT, PRA, "/cast [nomod] 8092", "/cast [nomod] 14914", WAND },
        { TGT, PRA, "/cast [nomod] Penance", WAND },
        { TGT, PRA, WAND },
    } },
    { "Level 40-60", {
        { CHAN, TGT, PRB, "/castsequence [nomod] reset=target/18 589, null", "/cast [nomod] 8092" },
        { CHAN, TGT, PRB, "/cast [nomod] 8092", "/cast [nomod] 15407" },
        { CHAN, TGT, PRB, "/cast [nomod] Shadow Word: Death", "/cast [nomod] 15407" },
        { CHAN, TGT, PRB, "/cast [nomod] 15407", WAND },
    } },
})

-- ===== Balance Druid (WoW: Forever). Icy Veins Forever guide: keep Moonfire and Insect Swarm up, then Wrath + 2x Starfire (Eclipse),
-- Hurricane for big packs. Moonkin Form from 40 (talent), the macro keeps it up and never toggles it off.
-- Shift = heal on yourself (leaves Moonkin Form, the next press goes back in), Ctrl = Entangling Roots, Alt = Faerie Fire / Hurricane at the cursor.
local BMA = "/cast [mod:shift,@player]5185;[mod:ctrl]339;[mod:alt]Faerie Fire"
local BMB = "/cast [mod:shift,@player]8936;[mod:ctrl]339;[mod:alt]Faerie Fire"
local BMC = "/cast [mod:shift,@player]8936;[mod:ctrl]339;[mod:alt,@cursor]16914"
local UNMK = "/cancelform [mod:shift]"
local MKF = "/cast [noform:5,nomod]24858"
local FBAL = Flat("RoninFDPS_Druid_Balance", 103,
    "Balance Druid for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Healing Touch (Regrowth from 10) on yourself, Ctrl = Entangling Roots, Alt = Faerie Fire (from 40: Hurricane at your cursor). Moonfire, Faerie Fire and Insect Swarm go once on each target, then Wrath and two Starfire. From 40 the macro keeps Moonkin Form up (if you have the talent).",
    {
    { "Level 1-10", {
        { TGT, BMA, "/castsequence [nomod] reset=target/12 8921, null", "/cast [nomod] 5176" },
        { TGT, BMA, "/cast [nomod] 5176" },
    } },
    { "Level 10-40", {
        { TGT, BMB, "/castsequence [nomod] reset=target/12 8921, null", "/castsequence [nomod] reset=8 5176, 2912, 2912" },
        { TGT, BMB, "/castsequence [nomod] reset=target/40 Faerie Fire, null", "/castsequence [nomod] reset=8 5176, 2912, 2912" },
        { TGT, BMB, "/castsequence [nomod] reset=target/12 5570, null", "/cast [nomod] 5176" },
        { TGT, BMB, "/castsequence [nomod] reset=8 5176, 2912, 2912", "/cast [nomod] 5176" },
    } },
    { "Level 40-60", {
        { TGT, UNMK, BMC, "/castsequence [nomod] reset=target/12 8921, null", "/cast [nomod] 5176" },
        { TGT, UNMK, BMC, "/castsequence [nomod] reset=target/12 5570, null", "/cast [nomod] 2912" },
        { TGT, UNMK, MKF, BMC, "/castsequence [nomod] reset=8 5176, 2912, 2912" },
        { TGT, UNMK, BMC, "/castsequence [nomod] reset=target/40 Faerie Fire, null", "/cast [nomod] 2912" },
    } },
})

Ronin.ForeverDPSSequences = {
    RoninFDPS_Paladin_Ret = FPAL,
    RoninFDPS_Warrior     = FWAR,
    RoninFDPS_Warrior_Fury = FFUR,
    RoninFDPS_Druid_Cat   = FDRU,
    RoninFDPS_Shaman_Enh  = FENH,
    RoninFDPS_Shaman_Ele  = FELE,
    RoninFDPS_Hunter = FHUN,
    RoninFDPS_Druid_Balance = FBAL,
    RoninFDPS_Priest = FPRI,
    RoninFDPS_Warlock_Aff = FAFF,
    RoninFDPS_Warlock_Demo = FDEM,
    RoninFDPS_Warlock_Destro = FDES,
    RoninFDPS_Mage_Arcane = FARC,
    RoninFDPS_Mage_Fire   = FFIR,
    RoninFDPS_Mage_Frost  = FFRO,
}
