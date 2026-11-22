-- Ronin DPS (Beta) - Retail (Midnight) + WoW: Forever.
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
local function BuildMacro(spec, tier, list)
    local lines = {}
    if tier == 1 then
        lines[#lines + 1] = "/targetenemy [noharm][dead]"
        if not spec.preall then for _, p in ipairs(spec.pre or {}) do lines[#lines + 1] = p end end
    end
    if spec.preall then for _, p in ipairs(spec.pre or {}) do lines[#lines + 1] = p end end
    for _, u in ipairs(spec.util) do lines[#lines + 1] = u end
    for _, e in ipairs(list) do lines[#lines + 1] = CastLine(e, spec.nomod, spec.gate) end
    return table.concat(lines, "\n")
end
local function BuildActions(spec, tiers)
    local loop = { Type = "Loop", StepFunction = "Priority", Repeat = "1" }
    for i, list in ipairs(tiers) do
        loop[i] = { Type = "Action", type = "macro", macro = BuildMacro(spec, i, list) }
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
            [1] = { Label = "Mythic+",  Actions = BuildActions(spec, list), InbuiltVariables = { Combat = true } },
            [2] = { Label = "Raid",     Actions = BuildActions(spec, RaidOrder(list)), InbuiltVariables = { Combat = true } },
            [3] = { Label = "Delve",    Actions = BuildActions(spec, list), InbuiltVariables = { Combat = true } },
            [4] = { Label = "Beginner", Actions = BuildActions(spec, BeginnerOrder(list, def)), InbuiltVariables = { Combat = true } },
            [5] = { Label = "Leveling", Actions = BuildActions(spec, lvl), InbuiltVariables = { Combat = true } },
        },
    }
end

local C_DK = { stop = false, util = { "/cast [mod:shift]Death Strike;[mod:alt]Asphyxiate" } }
local D_DK = { S("Icebound Fortitude", "c"), S("Anti-Magic Shell", "c"), S("Vampiric Blood", "c") }

local C_DH = { gate = "nochanneling:Eye Beam", stop = false, util = { "/cast [mod:shift]Disrupt;[mod:alt]Chaos Nova" } }
local D_DH = { S("Blur", "c"), S("Darkness", "cp") }

local C_PAL = { stop = false, util = { "/cast [mod:shift,@player]Word of Glory;[mod:alt]Hammer of Justice" } }
local D_PAL = { S("Shield of Vengeance", "c"), S("Divine Protection", "c"), S("Lay on Hands", "c") }

local C_WAR = { stop = false, util = { "/cast [mod:shift]Impending Victory;[mod:alt]Shockwave" } }
local D_WAR = { S("Die by the Sword", "c"), S("Enraged Regeneration", "c"), S("Rallying Cry", "c") }

local C_MONK = { gate = "nochanneling:Fists of Fury", stop = false, util = { "/cast [mod:shift,@player]Expel Harm;[mod:alt]Leg Sweep" } }
local D_MONK = { S("Touch of Karma", "c"), S("Fortifying Brew", "c"), S("Diffuse Magic", "c") }

local C_FERAL = { stop = false, preall = true, pre = { "/cast [noform:2]Cat Form" }, util = { "/cast [mod:shift,@player]Regrowth;[mod:alt]Mighty Bash" } }
local D_FERAL = { S("Barkskin", "c"), S("Survival Instincts", "c"), S("Renewal", "c") }

local C_BAL = { stop = false, preall = true, pre = { "/cast [noform:4]Moonkin Form" }, util = { "/cast [mod:shift,@player]Regrowth;[mod:alt]Mighty Bash" } }
local D_BAL = { S("Barkskin", "c"), S("Renewal", "c") }

local Retail = {}

Retail.RoninDPS_DK_Unholy_Rider = DPS("RoninDPS_DK_Unholy_Rider", 252, C_DK, {
    { S("Putrefy"), S("Outbreak"), S("Dark Transformation", "c") },
    { S("Festering Scythe"), S("Soul Reaper"), S("Death Coil") },
    { S("Scourge Strike"), S("Festering Strike"), S("Death Coil") },
    { R("/castsequence reset=5 Festering Strike, Scourge Strike, Scourge Strike"), S("Death Coil"), S("Festering Strike") },
    { S("Death Coil"), S("Scourge Strike"), S("Festering Strike") },
    { S("Summon Gargoyle", "c"), S("Army of the Dead", "c"), S("Scourge Strike") },
}, D_DK, "Unholy DK, Rider of the Apocalypse. Raid and Delve: Rider of the Apocalypse (Army of the Dead, Summon Gargoyle, Dark Transformation). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Outbreak"), S("Festering Strike"), S("Death Coil") },
    { S("Dark Transformation", "c"), S("Scourge Strike"), S("Death Coil") },
    { S("Death and Decay", "p"), S("Festering Strike"), S("Death Coil") },
})

Retail.RoninDPS_DK_Unh_Rider_AoE = DPS("RoninDPS_DK_Unh_Rider_AoE", 252, C_DK, {
    { S("Putrefy"), S("Outbreak"), S("Dark Transformation", "c") },
    { S("Death and Decay", "p"), S("Festering Scythe"), S("Soul Reaper") },
    { S("Epidemic"), S("Scourge Strike"), S("Festering Strike") },
    { R("/castsequence reset=5 Festering Strike, Scourge Strike, Scourge Strike"), S("Epidemic"), S("Festering Strike") },
    { S("Scourge Strike"), S("Festering Strike"), S("Epidemic") },
    { S("Summon Gargoyle", "c"), S("Army of the Dead", "c"), S("Epidemic") },
}, D_DK, "Unholy DK, Rider of the Apocalypse. Raid and Delve: Rider of the Apocalypse (Army of the Dead, Summon Gargoyle, Dark Transformation). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Outbreak"), S("Death and Decay", "p"), S("Epidemic") },
    { S("Dark Transformation", "c"), S("Festering Strike"), S("Epidemic") },
    { S("Scourge Strike"), S("Epidemic"), S("Death Coil") },
})

Retail.RoninDPS_DK_Unholy_Sanlayn = DPS("RoninDPS_DK_Unholy_Sanlayn", 252, C_DK, {
    { S("Putrefy"), S("Outbreak"), S("Dark Transformation", "c") },
    { S("Festering Scythe"), S("Soul Reaper"), S("Death Coil") },
    { S("Vampiric Strike"), S("Scourge Strike"), S("Festering Strike") },
    { R("/castsequence reset=5 Festering Strike, Scourge Strike, Scourge Strike"), S("Death Coil"), S("Festering Strike") },
    { S("Vampiric Strike"), S("Death Coil"), S("Scourge Strike") },
    { S("Summon Gargoyle", "c"), S("Army of the Dead", "c"), S("Scourge Strike") },
}, D_DK, "Unholy DK, San'layn. Mythic+: San'layn (Vampiric Strike, Essence of the Blood Queen, Dark Transformation windows). No Death and Decay on single target. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Outbreak"), S("Festering Strike"), S("Death Coil") },
    { S("Dark Transformation", "c"), S("Scourge Strike"), S("Death Coil") },
    { S("Death and Decay", "p"), S("Festering Strike"), S("Death Coil") },
})

Retail.RoninDPS_DK_Unh_Sanlayn_AoE = DPS("RoninDPS_DK_Unh_Sanlayn_AoE", 252, C_DK, {
    { S("Putrefy"), S("Outbreak"), S("Dark Transformation", "c") },
    { S("Death and Decay", "p"), S("Festering Scythe"), S("Soul Reaper") },
    { S("Epidemic"), S("Vampiric Strike"), S("Scourge Strike") },
    { R("/castsequence reset=5 Festering Strike, Scourge Strike, Scourge Strike"), S("Epidemic"), S("Festering Strike") },
    { S("Vampiric Strike"), S("Scourge Strike"), S("Epidemic") },
    { S("Summon Gargoyle", "c"), S("Army of the Dead", "c"), S("Epidemic") },
}, D_DK, "Unholy DK, San'layn. Mythic+: San'layn (Vampiric Strike, Essence of the Blood Queen, Dark Transformation windows). No Death and Decay on single target. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Pillar of Frost", "c"), S("Frostwyrm's Fury", "c"), S("Remorseless Winter", "c") },
}, D_DK, "Frost DK, Deathbringer. Raid and Mythic+: Deathbringer (Reaper's Mark before Pillar of Frost, Frostwyrm's Fury, Breath of Sindragosa). AoE uses Frostscythe and Glacial Advance. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Pillar of Frost", "c"), S("Frostwyrm's Fury", "c"), S("Breath of Sindragosa", "c") },
}, D_DK, "Frost DK, Deathbringer. Raid and Mythic+: Deathbringer (Reaper's Mark before Pillar of Frost, Frostwyrm's Fury, Breath of Sindragosa). AoE uses Frostscythe and Glacial Advance. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Pillar of Frost", "c"), S("Frostwyrm's Fury", "c"), S("Remorseless Winter", "c") },
}, D_DK, "Frost DK, Rider of the Apocalypse. Delve: Rider of the Apocalypse (Breath of Sindragosa, Frostbane, Remorseless Winter). AoE uses Frostscythe and Glacial Advance. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Pillar of Frost", "c"), S("Frostwyrm's Fury", "c"), S("Breath of Sindragosa", "c") },
}, D_DK, "Frost DK, Rider of the Apocalypse. Delve: Rider of the Apocalypse (Breath of Sindragosa, Frostbane, Remorseless Winter). AoE uses Frostscythe and Glacial Advance. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Death Strike, Alt = Asphyxiate. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_DH, "Havoc DH, Aldrachi Reaver. Raid: Aldrachi Reaver single target (Essence Break, Reaver's Glaive, Cycle of Hatred). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_DH, "Havoc DH, Aldrachi Reaver. Raid: Aldrachi Reaver single target (Essence Break, Reaver's Glaive, Cycle of Hatred). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_DH, "Havoc DH, Fel-Scarred. Mythic+ and Delve: Fel-Scarred AoE (Eye Beam, Immolation Aura, Demonsurge, A Fire Inside). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_DH, "Havoc DH, Fel-Scarred. Mythic+ and Delve: Fel-Scarred AoE (Eye Beam, Immolation Aura, Demonsurge, A Fire Inside). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Disrupt, Alt = Chaos Nova. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Blade Dance"), S("Chaos Strike"), S("Demon's Bite") },
    { S("Immolation Aura"), S("Eye Beam"), S("Throw Glaive") },
    { S("Felblade"), S("Metamorphosis", "cp"), S("Chaos Strike") },
})

Retail.RoninDPS_Paladin_Ret_Herald = DPS("RoninDPS_Paladin_Ret_Herald", 70, C_PAL, {
    { S("Execution Sentence"), S("Wake of Ashes"), S("Divine Toll", "c") },
    { S("Hammer of Wrath"), S("Blade of Justice"), S("Final Verdict") },
    { S("Final Verdict"), S("Judgment"), S("Blade of Justice") },
    { S("Judgment"), S("Blade of Justice"), S("Final Verdict") },
    { S("Final Verdict"), S("Templar Strike"), S("Crusader Strike") },
    { S("Avenging Wrath", "c"), S("Wake of Ashes"), S("Execution Sentence") },
}, D_PAL, "Retribution Paladin, Herald of the Sun. Raid and Mythic+: Herald of the Sun (Dawnlight, Execution Sentence, Divine Storm for AoE). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Word of Glory, Alt = Hammer of Justice. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Crusader Strike"), S("Judgment"), S("Hammer of Wrath") },
    { S("Blade of Justice"), S("Templar Strike"), S("Judgment") },
    { S("Final Verdict"), S("Wake of Ashes"), S("Avenging Wrath", "c") },
})

Retail.RoninDPS_Pal_Ret_Herald_AoE = DPS("RoninDPS_Pal_Ret_Herald_AoE", 70, C_PAL, {
    { S("Execution Sentence"), S("Wake of Ashes"), S("Divine Toll", "c") },
    { S("Hammer of Wrath"), S("Divine Storm"), S("Blade of Justice") },
    { S("Divine Storm"), S("Judgment"), S("Blade of Justice") },
    { S("Judgment"), S("Blade of Justice"), S("Divine Storm") },
    { S("Divine Storm"), S("Templar Strike"), S("Crusader Strike") },
    { S("Avenging Wrath", "c"), S("Wake of Ashes"), S("Execution Sentence") },
}, D_PAL, "Retribution Paladin, Herald of the Sun. Raid and Mythic+: Herald of the Sun (Dawnlight, Execution Sentence, Divine Storm for AoE). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Word of Glory, Alt = Hammer of Justice. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_PAL, "Retribution Paladin, Templar. Delve: Templar (Hammer of Light, Templar Strikes, Final Verdict / Divine Storm). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Word of Glory, Alt = Hammer of Justice. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_PAL, "Retribution Paladin, Templar. Delve: Templar (Hammer of Light, Templar Strikes, Final Verdict / Divine Storm). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Word of Glory, Alt = Hammer of Justice. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Divine Storm"), S("Judgment"), S("Hammer of Wrath") },
    { S("Blade of Justice"), S("Crusader Strike"), S("Judgment") },
    { S("Wake of Ashes"), S("Avenging Wrath", "c"), S("Divine Storm") },
})

Retail.RoninDPS_Fury_Slayer = DPS("RoninDPS_Fury_Slayer", 72, C_WAR, {
    { S("Rampage"), S("Execute"), S("Bloodthirst") },
    { S("Execute"), S("Rampage"), S("Raging Blow") },
    { S("Bloodthirst"), S("Raging Blow"), S("Wrecking Throw") },
    { S("Raging Blow"), S("Bloodthirst"), S("Slam") },
    { S("Bladestorm", "c"), S("Whirlwind"), S("Slam") },
    { S("Recklessness", "c"), S("Avatar", "c"), S("Odyn's Fury", "c") },
}, D_WAR, "Fury Warrior, Slayer. Raid: Slayer (Bladestorm, Whirlwind, Recklessness with Avatar). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Bloodthirst"), S("Raging Blow"), S("Rampage") },
    { S("Execute"), S("Whirlwind"), S("Bloodthirst") },
    { S("Recklessness", "c"), S("Heroic Strike"), S("Slam") },
})

Retail.RoninDPS_Fury_Slayer_AoE = DPS("RoninDPS_Fury_Slayer_AoE", 72, C_WAR, {
    { S("Whirlwind"), S("Rampage"), S("Bloodthirst") },
    { S("Execute"), S("Whirlwind"), S("Rampage") },
    { S("Bladestorm", "c"), S("Whirlwind"), S("Raging Blow") },
    { S("Whirlwind"), S("Bloodthirst"), S("Raging Blow") },
    { S("Whirlwind"), S("Slam") },
    { S("Recklessness", "c"), S("Avatar", "c"), S("Odyn's Fury", "c") },
}, D_WAR, "Fury Warrior, Slayer. Raid: Slayer (Bladestorm, Whirlwind, Recklessness with Avatar). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Whirlwind"), S("Bloodthirst"), S("Raging Blow") },
    { S("Rampage"), S("Execute"), S("Whirlwind") },
    { S("Recklessness", "c"), S("Thunder Clap"), S("Slam") },
})

Retail.RoninDPS_Fury_Thane = DPS("RoninDPS_Fury_Thane", 72, C_WAR, {
    { S("Rampage"), S("Execute"), S("Thunder Blast") },
    { S("Execute"), S("Rampage"), S("Bloodthirst") },
    { S("Thunder Blast"), S("Bloodthirst"), S("Raging Blow") },
    { S("Bloodthirst"), S("Raging Blow"), S("Thunder Clap") },
    { S("Raging Blow"), S("Thunder Clap"), S("Slam") },
    { S("Recklessness", "c"), S("Avatar", "c"), S("Odyn's Fury", "c") },
}, D_WAR, "Fury Warrior, Mountain Thane. Mythic+ and Delve: Mountain Thane (Thunder Blast, Thunder Clap, Recklessness with Avatar). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Bloodthirst"), S("Raging Blow"), S("Rampage") },
    { S("Execute"), S("Whirlwind"), S("Bloodthirst") },
    { S("Recklessness", "c"), S("Heroic Strike"), S("Slam") },
})

Retail.RoninDPS_Fury_Thane_AoE = DPS("RoninDPS_Fury_Thane_AoE", 72, C_WAR, {
    { S("Thunder Blast"), S("Whirlwind"), S("Rampage") },
    { S("Whirlwind"), S("Execute"), S("Bloodthirst") },
    { S("Thunder Clap"), S("Whirlwind"), S("Raging Blow") },
    { S("Whirlwind"), S("Bloodthirst"), S("Thunder Clap") },
    { S("Whirlwind"), S("Slam") },
    { S("Recklessness", "c"), S("Avatar", "c"), S("Odyn's Fury", "c") },
}, D_WAR, "Fury Warrior, Mountain Thane. Mythic+ and Delve: Mountain Thane (Thunder Blast, Thunder Clap, Recklessness with Avatar). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Avatar", "c"), S("Bladestorm", "c"), S("Warbreaker", "c") },
}, D_WAR, "Arms Warrior, Slayer. Raid single target and Mythic+/Delve: Slayer (Overpower, Reap the Storm, Sweeping Strikes, Bladestorm). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Avatar", "c"), S("Bladestorm", "c"), S("Warbreaker", "c") },
}, D_WAR, "Arms Warrior, Slayer. Raid single target and Mythic+/Delve: Slayer (Overpower, Reap the Storm, Sweeping Strikes, Bladestorm). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Avatar", "c"), S("Colossus Smash", "c"), S("Warbreaker", "c") },
}, D_WAR, "Arms Warrior, Colossus. Raid multi target: Colossus (Cleave, Demolish, Colossus Smash). Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Avatar", "c"), S("Sweeping Strikes", "c"), S("Warbreaker", "c") },
}, D_WAR, "Arms Warrior, Colossus. Raid multi target: Colossus (Cleave, Demolish, Colossus Smash). AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Impending Victory, Alt = Shockwave. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Whirlwind"), S("Mortal Strike"), S("Overpower") },
    { S("Sweeping Strikes", "c"), S("Cleave"), S("Slam") },
    { S("Bladestorm", "c"), S("Thunder Clap"), S("Slam") },
})

Retail.RoninDPS_Monk_WW_Conduit = DPS("RoninDPS_Monk_WW_Conduit", 269, C_MONK, {
    { S("Whirling Dragon Punch"), S("Celestial Conduit", "c") },
    { S("Fists of Fury"), S("Rushing Wind Kick"), S("Strike of the Windlord") },
    { R("/castsequence [nochanneling:Fists of Fury] reset=3 Tiger Palm, Rising Sun Kick"), S("Blackout Kick"), S("Tiger Palm") },
    { R("/castsequence [nochanneling:Fists of Fury] reset=3 Tiger Palm, Blackout Kick, Spinning Crane Kick"), S("Blackout Kick") },
    { S("Zenith Stomp"), S("Spinning Crane Kick"), S("Blackout Kick") },
    { S("Invoke Xuen, the White Tiger", "c"), S("Zenith", "c"), S("Touch of Death", "c") },
}, D_MONK, "Windwalker Monk, Conduit of the Celestials. Mythic+, Raid and Delve: Conduit of the Celestials (Celestial Conduit after Strike of the Windlord, Zenith with Invoke Xuen). One macro for single target and cleave. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Expel Harm, Alt = Leg Sweep. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Tiger Palm"), S("Blackout Kick"), S("Rising Sun Kick") },
    { S("Fists of Fury"), S("Rising Sun Kick"), S("Blackout Kick") },
    { S("Spinning Crane Kick"), S("Tiger Palm"), S("Blackout Kick") },
})

Retail.RoninDPS_Monk_WW_ShadoPan = DPS("RoninDPS_Monk_WW_ShadoPan", 269, C_MONK, {
    { S("Whirling Dragon Punch"), S("Strike of the Windlord") },
    { S("Fists of Fury"), S("Rushing Wind Kick"), S("Rising Sun Kick") },
    { R("/castsequence [nochanneling:Fists of Fury] reset=3 Tiger Palm, Rising Sun Kick"), S("Blackout Kick"), S("Tiger Palm") },
    { R("/castsequence [nochanneling:Fists of Fury] reset=3 Tiger Palm, Blackout Kick, Spinning Crane Kick"), S("Blackout Kick") },
    { S("Zenith Stomp"), S("Spinning Crane Kick"), S("Blackout Kick") },
    { S("Invoke Xuen, the White Tiger", "c"), S("Zenith", "c"), S("Touch of Death", "c") },
}, D_MONK, "Windwalker Monk, Shado-Pan. Raid: Shado-Pan (Flurry Strikes, Zenith). One macro for single target and cleave. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Expel Harm, Alt = Leg Sweep. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Berserk", "c"), S("Convoke the Spirits", "c"), S("Tiger's Fury", "c") },
}, D_FERAL, "Feral Druid, Wildstalker. Raid: Wildstalker (Unseen Predator, Patient Custodian). Mythic+: Wildstalker AoE (Rampant Ferocity, Hunger for Battle). The macro shifts into Cat Form by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
    { S("Berserk", "c"), S("Convoke the Spirits", "c"), S("Tiger's Fury", "c") },
}, D_FERAL, "Feral Druid, Wildstalker. Raid: Wildstalker (Unseen Predator, Patient Custodian). Mythic+: Wildstalker AoE (Rampant Ferocity, Hunger for Battle). The macro shifts into Cat Form by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_BAL, "Balance Druid, Keeper of the Grove. Raid single target: Keeper of the Grove (Force of Nature, Fury of Elune, Starsurge). The macro shifts into Moonkin Form by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_BAL, "Balance Druid, Keeper of the Grove. Raid single target: Keeper of the Grove (Force of Nature, Fury of Elune, Starsurge). The macro shifts into Moonkin Form by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_BAL, "Balance Druid, Elune's Chosen. Mythic+ and Delve: Elune's Chosen (Lunar Calling, Ascendant Eclipses, Fury of Elune). The macro shifts into Moonkin Form by itself. Single target macro, use the AoE macro for packs (3+ targets). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
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
}, D_BAL, "Balance Druid, Elune's Chosen. Mythic+ and Delve: Elune's Chosen (Lunar Calling, Ascendant Eclipses, Fury of Elune). The macro shifts into Moonkin Form by itself. AoE macro: use it on packs of 3+ targets (Mythic+ trash, Delve packs). Keys: Shift = Regrowth, Alt = Mighty Bash. Versions: Mythic+, Raid, Delve, Beginner (big defensives included), Leveling (basic spells, pick it by hand while you level to 90).", {
    { S("Moonfire"), S("Sunfire"), S("Starfall") },
    { S("Starfire"), S("Starsurge"), S("Wrath") },
    { S("Celestial Alignment", "c"), S("Starfall"), S("Wrath") },
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
        { TGT, PMA, PSQA },
        { TGT, PMA, "/cast 679", "/cast 20271" },
    } },
    { "Level 10-40", {
        { TGT, PMA, PSQ },
        { TGT, PMA, "/cast 679" },
        { TGT, PMA, "/cast [nomod]24275", "/cast [nomod]879", "/cast [nomod]20473" },
        { TGT, PMA, "/cast 20271" },
    } },
    { "Level 40-60", {
        { TGT, PM, PSQ },
        { TGT, PM, "/cast 679" },
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
        { TGT, SM, TOTA, "/castsequence [nomod] reset=target/12 8050, null" },
        { TGT, SM, TOTA, "/cast [nomod] 17364", "/cast [nomod] 403" },
    } },
    { "Level 40-60", {
        { TGT, SM, TOTB, "/cast [nomod] 17364", "/cast [nomod] 8042" },
        { TGT, SM, TOTB, "/castsequence [nomod] reset=target/12 8050, null" },
        { TGT, SM, TOTB, "/cast [nomod] Fire Nova", "/cast [nomod] 403" },
        { TGT, SM, TOTB, "/castsequence [nomod] reset=combat 324, null" },
    } },
})
local FELE = Flat("RoninFDPS_Shaman_Ele", 1489,
    "Elemental Shaman for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Healing Wave, Ctrl = Earth Shock, Alt = totems (press again for the next totem).",
    {
    { "Level 1-10", {
        { TGT, SMA, "/cast [nomod] 403" },
        { TGT, SMA, "/castsequence [nomod] reset=target 8050, 403, 403" },
    } },
    { "Level 10-40", {
        { TGT, SM, TOTA, "/cast [nomod] 421", "/cast [nomod] 403" },
        { TGT, SM, TOTA, "/castsequence [nomod] reset=target/12 8050, null" },
        { TGT, SM, TOTA, "/castsequence [nomod] reset=combat 324, null" },
    } },
    { "Level 40-60", {
        { TGT, SM, TOTB, "/cast [nomod] 421", "/cast [nomod] 403" },
        { TGT, SM, TOTB, "/castsequence [nomod] reset=target/12 8050, null" },
        { TGT, SM, TOTB, "/cast [nomod] 8042", "/cast [nomod] 403" },
        { TGT, SM, TOTB, "/castsequence [nomod] reset=combat 324, null" },
    } },
})

Ronin.ForeverDPSSequences = {
    RoninFDPS_Paladin_Ret = FPAL,
    RoninFDPS_Warrior     = FWAR,
    RoninFDPS_Warrior_Fury = FFUR,
    RoninFDPS_Druid_Cat   = FDRU,
    RoninFDPS_Shaman_Enh  = FENH,
    RoninFDPS_Shaman_Ele  = FELE,
}
