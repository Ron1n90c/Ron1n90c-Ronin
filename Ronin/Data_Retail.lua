-- Ronin Retail V5.2.1 - Tank Priority Edition (tiered chains)
--
-- Each version is ONE Loop block with StepFunction = "Priority" and THREE
-- actions (tiers A, B, C). GSE clicks them A, AB, ABC (A x3, B x2, C x1 per
-- 6 key presses), so A is tried most often.
-- Inside a tier the macro lines are a priority chain: every /cast line is
-- tried in order and the first GCD spell that is ready wins.
-- EVERY tier ends with the spec FILLER, so a key press always casts something
-- as long as anything at all is castable (no dead presses).
-- Modifiers: Shift = interrupt, Alt = emergency heal. While a modifier is held
-- the rest of the macro is skipped (/stopmacro [mod]).
-- IMPORTANT: GSE limits every macro step to 255 characters AFTER compiling
-- (it inserts a space after every [conditional] and after every ';').
-- Keep every tier at 250 or less (see the length check in the build notes).
local _, Ronin = ...

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- S(spell, flags)
--   flags: "c" = only in combat, "p" = cast at @player (ground spells / self)
local function S(spell, flags)
    return { spell = spell, flags = flags or "" }
end

-- R(line): a literal macro line (used for /castsequence)
local function R(line)
    return { raw = line, spell = "", flags = "" }
end

local function CastLine(e, nomod, gate)
    if e.raw then return e.raw end
    -- flag "s": cast once per target, then two empty presses (your MOONSPAM macro)
    if e.flags:find("s", 1, true) then
        return "/castsequence [nomod,nochanneling] reset=12/target " .. e.spell .. ", Null, Null"
    end
    local conds = {}
    if gate then conds[#conds + 1] = gate end
    if e.flags:find("c", 1, true) then conds[#conds + 1] = "combat" end
    if e.flags:find("p", 1, true) then conds[#conds + 1] = "@player" end
    if e.flags:find("t", 1, true) then conds[#conds + 1] = "@target" end
    if nomod then conds[#conds + 1] = "nomod" end
    if #conds == 0 then return "/cast " .. e.spell end
    return "/cast [" .. table.concat(conds, ",") .. "]" .. e.spell
end

local function BuildMacro(ctx, spec, tier, list)
    local lines = {}
    if tier == 1 then
        lines[#lines + 1] = ctx == "raid" and "/targetenemy [noexists]" or "/targetenemy [noharm][dead]"
        lines[#lines + 1] = "/startattack"
        for _, p in ipairs(spec.pre or {}) do lines[#lines + 1] = p end
    end
    for _, u in ipairs(spec.util) do lines[#lines + 1] = u end
    if spec.stop ~= false then lines[#lines + 1] = spec.stop or "/stopmacro [mod]" end

    local hasFiller = false
    for _, e in ipairs(list) do
        lines[#lines + 1] = CastLine(e, spec.nomod, spec.gate)
        if e.spell == spec.filler then hasFiller = true end
    end
    -- the filler is always the last line of every tier
    if spec.filler and not hasFiller then
        lines[#lines + 1] = CastLine(S(spec.filler), spec.nomod, spec.gate)
    end
    return table.concat(lines, "\n")
end

local function BuildActions(ctx, spec, tiers)
    local loop = { Type = "Loop", StepFunction = "Priority", Repeat = "1" }
    for i, list in ipairs(tiers) do
        loop[i] = { Type = "Action", type = "macro", macro = BuildMacro(ctx, spec, i, list) }
    end
    return { loop }
end

-- Seq(name, specID, spec, mythic, raid [, delve])  -- each = { tierA, tierB, tierC }
local function Seq(name, specID, spec, mythic, raid, delve, allin)
    local seq = {
        MetaData = {
            Name = name, Author = "Ronin V5.0", SpecID = specID, Default = 1,
            MythicPlus = 1, Heroic = 1, Dungeon = 1, Timewalking = 1, Mythic = 1,
            PVP = 1, Raid = 2, Scenario = 3,
        },
        Versions = {
            [1] = { Label = "Mythic", Actions = BuildActions("group", spec, mythic), InbuiltVariables = { Combat = true } },
            [2] = { Label = "Raid",   Actions = BuildActions("raid",  spec, raid),   InbuiltVariables = { Combat = true } },
            [3] = { Label = "Delve",  Actions = BuildActions("group", spec, delve or mythic), InbuiltVariables = { Combat = true } },
        },
    }
    -- Optional 4th version, not mapped to any content type in MetaData: you
    -- simply pick it by hand in GSE.
    if allin then
        seq.Versions[4] = { Label = "All In", Actions = BuildActions("group", spec, allin), InbuiltVariables = { Combat = true } }
    end
    return seq
end

-- ---------------------------------------------------------------------------
-- Per-class setup. Shift = heal, Alt = CC (stun). Interrupts: put them on
-- their own key. Big defensives are NOT in the macros (they are yours).
-- ---------------------------------------------------------------------------

local PALADIN = { stop = false, util = {
    "/cast [mod:shift,@player]Word of Glory;[mod:alt]Hammer of Justice" } }
local BREWMASTER = { stop = false, util = {
    "/cast [mod:shift,@player]Expel Harm;[mod:alt]Leg Sweep" } }
local DRUID = { stop = false, pre = { "/cast [noform:1]Bear Form" }, util = {
    "/cast [mod:shift]Frenzied Regeneration;[mod:alt]Mighty Bash" } }
local WARRIOR = { stop = false, util = {
    "/cast [mod:shift]Impending Victory;[mod:alt]Shockwave" } }
-- DH: every cast is gated so Fel Devastation (a channel) is never interrupted.
local DEMONHUNTER = { gate = "nochanneling:Fel Devastation", stop = false, util = {
    "/cast [mod:shift]Soul Cleave;[mod:alt]Chaos Nova" } }
local DEATHKNIGHT = { stop = false, util = {
    "/cast [mod:shift]Death Strike;[mod:alt]Asphyxiate" } }

-- ---------------------------------------------------------------------------
-- Steps. Each class = a list of small steps (1-3 spells). Priority presses
-- step 1 most often and the LAST step least often. A spell you did not talent
-- is simply skipped. Every step must stay <= 250 characters once compiled.
-- ---------------------------------------------------------------------------

-- PALADIN (6 steps): Divine Toll / Avenger's Shield / Shield of the Righteous
-- first, Judgment + Hammer of Wrath for Holy Power, cooldowns last.
local PAL_LIGHTSMITH = {
    { S("Divine Toll"), S("Avenger's Shield"), S("Shield of the Righteous") },
    { S("Judgment"), S("Shield of the Righteous"), S("Blessed Hammer") },
    { S("Avenger's Shield"), S("Hammer of Wrath"), S("Blessed Hammer") },
    { S("Consecration", "c"), S("Holy Bulwark", "p"), S("Shield of the Righteous") },
    { S("Sacred Weapon", "p"), S("Judgment"), S("Blessed Hammer") },
    { S("Avenging Wrath", "c"), S("Sentinel", "c"), S("Hammer of the Righteous") },
}
local PAL_TEMPLAR = {
    { S("Divine Toll"), S("Hammer of Light"), S("Avenger's Shield") },
    { S("Judgment"), S("Shield of the Righteous"), S("Blessed Hammer") },
    { S("Avenger's Shield"), S("Hammer of Wrath"), S("Blessed Hammer") },
    { S("Consecration", "c"), S("Shield of the Righteous"), S("Blessed Hammer") },
    { S("Hammer of Light"), S("Judgment"), S("Blessed Hammer") },
    { S("Avenging Wrath", "c"), S("Sentinel", "c"), S("Hammer of the Righteous") },
}

-- BREWMASTER (7 steps): Keg Smash / Blackout Kick / Breath of Fire core,
-- Tiger Palm as the filler everywhere, brews in the middle.
-- Mythic / Raid / Delve: NO Purifying Brew / Celestial Brew (you press them).
-- "All In" version (4th, pick it by hand): same plus both brews in step 4.
local BREW_HARMONY = {
    { S("Keg Smash"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Breath of Fire"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Chi Burst"), S("Rushing Jade Wind"), S("Tiger Palm") },
    { S("Keg Smash"), S("Breath of Fire"), S("Tiger Palm") },
    { S("Blackout Kick"), S("Tiger Palm") },
    { S("Celestial Infusion", "c"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Exploding Keg", "cp"), S("Keg Smash"), S("Tiger Palm") },
}
local BREW_HARMONY_ALLIN = {
    { S("Keg Smash"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Breath of Fire"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Chi Burst"), S("Rushing Jade Wind"), S("Tiger Palm") },
    { S("Purifying Brew", "c"), S("Celestial Brew", "c"), S("Tiger Palm") },
    { S("Keg Smash"), S("Tiger Palm") },
    { S("Celestial Infusion", "c"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Exploding Keg", "cp"), S("Keg Smash"), S("Tiger Palm") },
}
local BREW_SHADOPAN = {
    { S("Keg Smash"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Breath of Fire"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Rushing Jade Wind"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Keg Smash"), S("Breath of Fire"), S("Tiger Palm") },
    { S("Blackout Kick"), S("Tiger Palm") },
    { S("Celestial Infusion", "c"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Exploding Keg", "cp"), S("Chi Burst"), S("Tiger Palm") },
}
local BREW_SHADOPAN_ALLIN = {
    { S("Keg Smash"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Breath of Fire"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Rushing Jade Wind"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Purifying Brew", "c"), S("Celestial Brew", "c"), S("Tiger Palm") },
    { S("Keg Smash"), S("Tiger Palm") },
    { S("Celestial Infusion", "c"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Exploding Keg", "cp"), S("Chi Burst"), S("Tiger Palm") },
}

-- GUARDIAN DRUID (6 steps): Mangle / Thrash / Ironfur, Raze + Maul as the
-- rage spenders, Swipe as the filler.
-- 7 steps. Moonfire is your MOONSPAM castsequence (flag "s") and sits FIRST in
-- steps 1, 2 and 7: after it has been cast on a target it is stuck on "Null",
-- so it costs no GCD, and it can no longer be starved by Mangle / Thrash.
-- reset=12/target recasts it about every 12 s and on every new target.
local DRU_ELUNE = {
    { S("Moonfire", "s"), S("Mangle"), S("Thrash") },
    { S("Moonfire", "s"), S("Thrash"), S("Mangle") },
    { S("Ironfur"), S("Mangle"), S("Thrash") },
    { S("Raze"), S("Thrash"), S("Swipe") },
    { S("Maul"), S("Mangle"), S("Swipe") },
    { S("Fury of Elune", "c"), S("Lunar Beam", "c"), S("Swipe") },
    { S("Moonfire", "s"), S("Swipe") },
}
local DRU_CLAW = {
    { S("Moonfire", "s"), S("Mangle"), S("Thrash") },
    { S("Moonfire", "s"), S("Thrash"), S("Mangle") },
    { S("Ironfur"), S("Mangle"), S("Thrash") },
    { S("Raze"), S("Thrash"), S("Swipe") },
    { S("Maul"), S("Mangle"), S("Swipe") },
    { S("Raze"), S("Maul"), S("Swipe") },
    { S("Moonfire", "s"), S("Swipe") },
}

-- PROTECTION WARRIOR (6 steps): Shield Slam / Revenge core, Shield Block and
-- Ignore Pain as the rage sinks, cooldowns last, Revenge is the filler.
-- Thunder Blast / Thunder Clap is in steps 1-4 so it never sits ready.
local WAR_COLOSSUS = {
    { S("Shield Slam"), S("Thunder Clap"), S("Revenge") },
    { S("Thunder Clap"), S("Shield Slam"), S("Revenge") },
    { S("Ignore Pain"), S("Thunder Clap"), S("Revenge") },
    { S("Demolish", "c"), S("Shield Block"), S("Revenge") },
    { S("Execute"), S("Shield Charge", "c"), S("Revenge") },
    { S("Avatar", "c"), S("Demoralizing Shout", "c"), S("Ravager", "cp") },
}
local WAR_THANE = {
    { S("Thunder Blast"), S("Shield Slam"), S("Revenge") },
    { S("Shield Slam"), S("Thunder Blast"), S("Revenge") },
    { S("Ignore Pain"), S("Thunder Blast"), S("Revenge") },
    { S("Shield Block"), S("Thunder Blast"), S("Revenge") },
    { S("Execute"), S("Shield Charge", "c"), S("Revenge") },
    { S("Avatar", "c"), S("Demoralizing Shout", "c"), S("Ravager", "cp") },
}

-- SAN'LAYN (RoninDK_Blood_Sanlayn) (adapted from the imported BDK_SL_AIO sequence): its two
-- ideas are kept - Marrowrend -> Heart Strike x2 as a castsequence (Bone Shield
-- refresh, then spend the runes) and Blood Boil -> Death Strike - plus Raise Dead
-- on its own. Dancing Rune Weapon and trinket 13 of the original are NOT used.
-- "Heart  Strike" has two spaces on purpose (so GSE cannot rewrite it as
-- Vampiric Strike). All castsequences reset after 4 s so they can never get stuck.
local DK_SANLAYN_AIO = {
    { S("Death Strike"), R("/castsequence reset=4 Marrowrend, Heart  Strike, Heart  Strike") },
    { R("/castsequence reset=4 Blood Boil, Death Strike"), S("Heart Strike") },
    { S("Death and Decay", "p"), S("Heart Strike"), S("Blood Boil") },
    { S("Raise Dead"), S("Consumption"), S("Heart Strike") },
    { R("/castsequence reset=4 Heart  Strike, Heart  Strike, Blood Boil"), S("Death Strike") },
    { S("Consumption"), S("Marrowrend"), S("Heart Strike") },
}

-- DEATHBRINGER in the same castsequence style (Reaper's Mark instead of Raise
-- Dead's slot priority; plain "Heart Strike" because Deathbringer has no
-- Vampiric Strike override).
local DK_DEATHBRINGER_CS = {
    { S("Death Strike"), R("/castsequence reset=4 Marrowrend, Heart Strike, Heart Strike") },
    { R("/castsequence reset=4 Blood Boil, Death Strike"), S("Heart Strike") },
    { S("Death and Decay", "p"), S("Heart Strike"), S("Blood Boil") },
    { S("Reaper's Mark"), S("Consumption"), S("Heart Strike") },
    { R("/castsequence reset=4 Heart Strike, Heart Strike, Blood Boil"), S("Death Strike") },
    { S("Raise Dead"), S("Consumption"), S("Marrowrend") },
}

-- VENGEANCE in the castsequence style (like RoninDK_Blood_*): fury is built and
-- spent in a fixed order - Fracture, Fracture, Spirit Bomb / Fracture, Soul
-- Cleave - so Fel Devastation, Spirit Bomb and Soul Cleave all get fury.
-- Every line keeps the [nochanneling:Fel Devastation] guard. castsequences
-- reset after 4 s so they can never get stuck.
local DH_CS_ALDRACHI = {
    { S("Fel Devastation", "c"), R("/castsequence [nochanneling:Fel Devastation] reset=4 Fracture, Fracture, Spirit Bomb") },
    { S("Immolation Aura"), R("/castsequence [nochanneling:Fel Devastation] reset=4 Fracture, Soul Cleave") },
    { S("Sigil of Spite", "p"), S("Spirit Bomb"), S("Soul Carver") },
    { S("Sigil of Flame", "p"), S("Immolation Aura"), S("Felblade") },
    { R("/castsequence [nochanneling:Fel Devastation] reset=4 Fracture, Fracture, Soul Cleave"), S("Demon Spikes", "c") },
    { S("Immolation Aura"), S("Reaver's Glaive"), S("Fracture") },
    { S("Sigil of Spite", "p"), S("Felblade"), S("Throw Glaive") },
}
local DH_CS_ANNIHILATOR = {
    { S("Fel Devastation", "c"), R("/castsequence [nochanneling:Fel Devastation] reset=4 Fracture, Fracture, Spirit Bomb") },
    { S("Immolation Aura"), R("/castsequence [nochanneling:Fel Devastation] reset=4 Fracture, Soul Cleave") },
    { S("Sigil of Spite", "p"), S("Spirit Bomb"), S("Soul Carver") },
    { S("Sigil of Flame", "p"), S("Immolation Aura"), S("Felblade") },
    { R("/castsequence [nochanneling:Fel Devastation] reset=4 Fracture, Fracture, Soul Cleave"), S("Demon Spikes", "c") },
    { S("Immolation Aura"), S("Throw Glaive"), S("Fracture") },
    { S("Sigil of Spite", "p"), S("Felblade"), S("Throw Glaive") },
}

Ronin.RetailSequences = {
    RoninPaladin_Lightsmith     = Seq("RoninPaladin_Lightsmith",     66,  PALADIN,     PAL_LIGHTSMITH,  PAL_LIGHTSMITH),
    RoninPaladin_Templar        = Seq("RoninPaladin_Templar",        66,  PALADIN,     PAL_TEMPLAR,     PAL_TEMPLAR),
    RoninBrewmaster_Harmony     = Seq("RoninBrewmaster_Harmony",     268, BREWMASTER,  BREW_HARMONY,    BREW_HARMONY,    BREW_HARMONY,    BREW_HARMONY_ALLIN),
    RoninBrewmaster_ShadoPan    = Seq("RoninBrewmaster_ShadoPan",    268, BREWMASTER,  BREW_SHADOPAN,   BREW_SHADOPAN,   BREW_SHADOPAN,   BREW_SHADOPAN_ALLIN),
    RoninDruid_Elune            = Seq("RoninDruid_Elune",            104, DRUID,       DRU_ELUNE,       DRU_ELUNE),
    RoninDruid_Claw             = Seq("RoninDruid_Claw",             104, DRUID,       DRU_CLAW,        DRU_CLAW),
    RoninWarrior_Thane          = Seq("RoninWarrior_Thane",          73,  WARRIOR,     WAR_THANE,       WAR_THANE),
    RoninWarrior_Colossus       = Seq("RoninWarrior_Colossus",       73,  WARRIOR,     WAR_COLOSSUS,    WAR_COLOSSUS),
    RoninDH_Vengeance_Aldrachi    = Seq("RoninDH_Vengeance_Aldrachi",    581, DEMONHUNTER, DH_CS_ALDRACHI,    DH_CS_ALDRACHI),
    RoninDH_Vengeance_Annihil     = Seq("RoninDH_Vengeance_Annihil", 581, DEMONHUNTER, DH_CS_ANNIHILATOR, DH_CS_ANNIHILATOR),
    RoninDK_Blood_Deathbringer = Seq("RoninDK_Blood_Deathbringer", 250, DEATHKNIGHT, DK_DEATHBRINGER_CS, DK_DEATHBRINGER_CS),
    RoninDK_Blood_Sanlayn      = Seq("RoninDK_Blood_Sanlayn",       250, DEATHKNIGHT, DK_SANLAYN_AIO,  DK_SANLAYN_AIO),
}
