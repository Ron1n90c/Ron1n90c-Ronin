-- Ronin Retail V7.3.6 - Tank Priority Edition (tiered chains)
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
    -- flag "s": cast once per target, then two empty presses (no GCD wasted on a DoT that is up)
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

-- Mythic+: the step that holds the big cooldowns (2+ entries with the "c" flag) moves to step 2,
-- so it fires right at the pull. Specs without such a step stay as they are.
local function CdIndex(list)
    local best, bi = 1, nil
    for i, step in ipairs(list) do
        local n = 0
        for _, e in ipairs(step) do if e.flags and e.flags:find("c", 1, true) then n = n + 1 end end
        if n > best then best, bi = n, i end
    end
    return bi
end
local function MplusOrder(list)
    local o = {}
    for i, v in ipairs(list) do o[i] = v end
    local i = CdIndex(o)
    if i and i > 2 then local cd = table.remove(o, i); table.insert(o, 2, cd) end
    return o
end
-- Delve (solo): Mythic+ order plus the class defensives at step 4.
local function DelveOrder(list, def)
    local o = MplusOrder(list)
    if def then table.insert(o, 4, def) end
    return o
end

-- @@NOTES_BEGIN
local NOTES = {
    RoninPaladin_Lightsmith = "Protection Paladin, Lightsmith. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Word of Glory, Alt = Hammer of Justice; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninPaladin_Templar = "Protection Paladin, Templar. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Word of Glory, Alt = Hammer of Justice; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninBrewmaster_Harmony = "Brewmaster Monk, Master of Harmony. Purifying Brew, Celestial Brew and Black Ox Brew stay in your hands. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Vivify, Alt = Leg Sweep; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninBrewmaster_ShadoPan = "Brewmaster Monk, Shado-Pan. Purifying Brew, Celestial Brew and Black Ox Brew stay in your hands. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Vivify, Alt = Leg Sweep; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninDruid_Elune = "Guardian Druid, Elune's Chosen (Lunar Beam, Red Moon). Incarnation and Survival Instincts stay in your hands. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Frenzied Regeneration, Alt = Mighty Bash; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninDruid_Claw = "Guardian Druid, Druid of the Claw (Ravage). Incarnation and Survival Instincts stay in your hands. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Frenzied Regeneration, Alt = Mighty Bash; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninWarrior_Thane = "Protection Warrior, Mountain Thane (Thunder Blast). Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Impending Victory, Alt = Shockwave; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninWarrior_Colossus = "Protection Warrior, Colossus (Demolish). Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Impending Victory, Alt = Shockwave; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninDH_Vengeance_Aldrachi = "Vengeance Demon Hunter, Aldrachi Reaver (Reaver's Glaive). Spirit Bomb before Soul Cleave, Fracture builds. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Soul Cleave, Alt = Chaos Nova; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninDH_Vengeance_Annihil = "Vengeance Demon Hunter, Annihilator. Spirit Bomb before Soul Cleave, Fracture builds. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Soul Cleave, Alt = Chaos Nova; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninDK_Blood_Deathbringer = "Blood Death Knight, Deathbringer (Reaper's Mark). Dancing Rune Weapon and Vampiric Blood stay in your hands. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Death Strike, Alt = Asphyxiate; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
    RoninDK_Blood_Sanlayn = "Blood Death Knight, San'layn. Dancing Rune Weapon and Vampiric Blood stay in your hands. Talents: press Talents in /ronin (Mythic+, Delve, Raid, Leveling). Keys: Shift = Death Strike, Alt = Asphyxiate; put your interrupt on its own key. Versions: Mythic (cooldowns right at the pull), Raid (keeps your target), Delve (solo: one defensive at step 4), Beginner (one defensive included), Leveling (basic spells, pick it by hand while you level).",
}
-- @@NOTES_END

-- Seq(name, specID, spec, mythic, raid [, delve])  -- each = { tierA, tierB, tierC }
local function Seq(name, specID, spec, mythic, raid, delve, allin, def)
    local seq = {
        MetaData = {
            Name = name, Author = "Ronin", SpecID = specID, Default = 1,
            MythicPlus = 1, Heroic = 1, Dungeon = 1, Timewalking = 1, Mythic = 1,
            PVP = 1, Raid = 2, Scenario = 3, Notes = NOTES[name], Help = NOTES[name],
        },
        Versions = {
            [1] = { Label = "Mythic", Actions = BuildActions("group", spec, MplusOrder(mythic)), InbuiltVariables = { Combat = true } },
            [2] = { Label = "Raid",   Actions = BuildActions("raid",  spec, MplusOrder(raid)),   InbuiltVariables = { Combat = true } },
            [3] = { Label = "Delve",  Actions = BuildActions("group", spec, DelveOrder(delve or mythic, def)), InbuiltVariables = { Combat = true } },
        },
    }
    -- Optional 4th version, not mapped to any content type in MetaData: you
    -- simply pick it by hand in GSE.
    if allin then
        seq.Versions[4] = { Label = "Beginner", Actions = BuildActions("group", spec, allin), InbuiltVariables = { Combat = true } }
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
    "/cast [mod:shift,@player]Vivify;[mod:alt]Leg Sweep" } }
local DRUID = { stop = false, pre = { "/cast [noform:1]Bear Form" }, util = {
    "/cast [mod:shift]Frenzied Regeneration;[mod:alt]Mighty Bash" } }
local WARRIOR = { stop = false, util = {
    "/cast [mod:shift]Impending Victory;[mod:alt]Shockwave" } }
-- DH: one /stopmacro line keeps Fel Devastation (a channel) from being interrupted (after the Shift / Alt line).
local DEMONHUNTER = { stop = "/stopmacro [channeling:Fel Devastation]", util = {
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
    { S("Avenger's Shield"), S("Hammer of Wrath"), S("Judgment"), S("Hammer of the Righteous"), S("Blessed Hammer"), S("Consecration", "c") },
    { S("Shield of the Righteous"), S("Hammer of Wrath"), S("Judgment"), S("Hammer of the Righteous"), S("Blessed Hammer"), S("Consecration", "c") },
    { S("Consecration", "c"), S("Hammer of Wrath"), S("Judgment"), S("Hammer of the Righteous"), S("Blessed Hammer") },
    { S("Sacred Weapon", "p"), S("Avenger's Shield"), S("Hammer of the Righteous"), S("Blessed Hammer"), S("Consecration", "c") },
    { S("Holy Bulwark", "p"), S("Shield of the Righteous"), S("Hammer of the Righteous"), S("Blessed Hammer"), S("Consecration", "c") },
    { S("Avenging Wrath", "c"), S("Divine Toll", "c"), S("Hammer of the Righteous"), S("Blessed Hammer"), S("Consecration", "c") },
}
local PAL_TEMPLAR = {
    { S("Hammer of Light"), S("Hammer of Wrath"), S("Judgment"), S("Blessed Hammer"), S("Hammer of the Righteous"), S("Consecration", "c") },
    { S("Shield of the Righteous"), S("Avenger's Shield"), S("Judgment"), S("Blessed Hammer"), S("Hammer of the Righteous"), S("Consecration", "c") },
    { S("Hammer of Light"), S("Hammer of Wrath"), S("Blessed Hammer"), S("Hammer of the Righteous"), S("Consecration", "c") },
    { S("Consecration", "c"), S("Avenger's Shield"), S("Blessed Hammer"), S("Hammer of the Righteous") },
    { S("Shield of the Righteous"), S("Judgment"), S("Blessed Hammer"), S("Hammer of the Righteous"), S("Consecration", "c") },
    { S("Avenging Wrath", "c"), S("Divine Toll", "c"), S("Blessed Hammer"), S("Hammer of the Righteous"), S("Consecration", "c") },
}

-- BREWMASTER (6 steps, Method Midnight): Blackout Kick first, Chi Burst, Keg Smash, Breath of Fire,
-- Niuzao + Exploding Keg in the cooldown step, Tiger Palm as the filler everywhere.
-- Mythic / Raid: NO Purifying Brew / Celestial Brew (you press them).
local BREW_HARMONY = {
    { S("Blackout Kick"), S("Keg Smash"), S("Tiger Palm") },
    { S("Keg Smash"), S("Breath of Fire"), S("Tiger Palm") },
    { S("Chi Burst"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Breath of Fire"), S("Keg Smash"), S("Tiger Palm") },
    { S("Celestial Infusion", "c"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Invoke Niuzao, the Black Ox", "c"), S("Exploding Keg", "cp"), S("Tiger Palm") },
}
local BREW_SHADOPAN = {
    { S("Blackout Kick"), S("Keg Smash"), S("Tiger Palm") },
    { S("Breath of Fire"), S("Keg Smash"), S("Tiger Palm") },
    { S("Chi Burst"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Keg Smash"), S("Breath of Fire"), S("Tiger Palm") },
    { S("Blackout Kick"), S("Breath of Fire"), S("Tiger Palm") },
    { S("Invoke Niuzao, the Black Ox", "c"), S("Exploding Keg", "cp"), S("Tiger Palm") },
}
-- 4.3.0 talents-first: the Mythic+ builds have no Exploding Keg (Raid builds do), so the Mythic+ / Delve /
-- Beginner lists drop it (Blackout Kick + Breath of Fire take its place, so that step never goes dead).
-- Niuzao then is the only cooldown, so CdFirst() puts that step at 2 by hand.
local function NoKeg(list)
    local o = {}
    for i, st in ipairs(list) do
        local n = {}
        local had = false
        for _, e in ipairs(st) do
            if e.spell == "Exploding Keg" then had = true
            else
                if had and e.spell == "Tiger Palm" then n[#n + 1] = S("Blackout Kick"); n[#n + 1] = S("Breath of Fire") end
                n[#n + 1] = e
            end
        end
        o[i] = n
    end
    return o
end
local function CdFirst(list)
    local o = {}
    for i, v in ipairs(list) do o[i] = v end
    local cd = table.remove(o)
    table.insert(o, 2, cd)
    return o
end
local BREW_HARMONY_M = NoKeg(BREW_HARMONY)
local BREW_SHADOPAN_M = NoKeg(BREW_SHADOPAN)

-- GUARDIAN DRUID (6 steps): Mangle / Thrash / Ironfur, Raze + Maul as the
-- rage spenders, Swipe as the filler.
-- 7 steps. Moonfire is the once-per-target castsequence (flag "s") and sits FIRST in
-- steps 1, 2 and 7: after it has been cast on a target it is stuck on "Null",
-- so it costs no GCD, and it can no longer be starved by Mangle / Thrash.
-- reset=12/target recasts it about every 12 s and on every new target.
local DRU_ELUNE = {
    { S("Moonfire", "s"), S("Mangle"), S("Thrash"), S("Moonfire") },
    { S("Moonfire", "s"), S("Thrash"), S("Mangle"), S("Moonfire") },
    { S("Ironfur"), S("Mangle"), S("Thrash"), S("Moonfire") },
    { S("Thrash"), S("Mangle"), S("Moonfire") },
    { S("Maul"), S("Mangle"), S("Moonfire") },
    { S("Lunar Beam", "c"), S("Red Moon", "c"), S("Moonfire") },   -- 4.4: Fury of Elune is a Balance talent, not in the Guardian tree
    { S("Moonfire", "s"), S("Thrash"), S("Moonfire") },
}
local DRU_CLAW = {
    { S("Moonfire", "s"), S("Mangle"), S("Thrash"), S("Swipe") },
    { S("Moonfire", "s"), S("Thrash"), S("Mangle"), S("Swipe") },
    { S("Ironfur"), S("Mangle"), S("Thrash"), S("Swipe") },
    { S("Ravage"), S("Thrash"), S("Swipe") },
    { S("Maul"), S("Mangle"), S("Swipe") },
    { S("Lunar Beam", "c"), S("Ravage"), S("Raze"), S("Red Moon"), S("Swipe") },
    { S("Moonfire", "s"), S("Swipe") },
}

-- PROTECTION WARRIOR (6 steps): Shield Slam / Revenge core, Shield Block and
-- Ignore Pain as the rage sinks, cooldowns last, Revenge is the filler.
-- Thunder Blast / Thunder Clap is in steps 1-4 so it never sits ready.
local WAR_COLOSSUS = {
    { S("Shield Slam"), S("Revenge"), S("Thunder Clap"), S("Devastate"), S("Shield Charge") },
    { S("Shield Block"), S("Shield Slam"), S("Thunder Clap"), S("Revenge"), S("Shield Charge") },
    { S("Demolish"), S("Shield Slam"), S("Revenge"), S("Thunder Clap"), S("Shield Charge") },
    { S("Shield Charge"), S("Execute"), S("Revenge"), S("Thunder Clap") },
    { S("Ignore Pain"), S("Shield Slam"), S("Thunder Clap"), S("Devastate"), S("Revenge"), S("Shield Charge") },
    { S("Avatar", "c"), S("Demoralizing Shout", "c"), S("Ravager", "cp"), S("Thunder Clap"), S("Revenge") },
}
local WAR_THANE = {
    { S("Shield Slam"), S("Thunder Blast"), S("Thunder Clap"), S("Revenge"), S("Shield Charge") },
    { S("Shield Block"), S("Thunder Blast"), S("Shield Slam"), S("Thunder Clap"), S("Revenge"), S("Shield Charge") },
    { S("Thunder Blast"), S("Shield Slam"), S("Revenge"), S("Thunder Clap"), S("Shield Charge") },
    { S("Shield Charge"), S("Execute"), S("Thunder Clap"), S("Revenge") },
    { S("Ignore Pain"), S("Shield Slam"), S("Thunder Clap"), S("Devastate"), S("Revenge"), S("Shield Charge") },
    { S("Avatar", "c"), S("Demoralizing Shout", "c"), S("Ravager", "cp"), S("Thunder Clap"), S("Revenge") },
}

-- SAN'LAYN (RoninDK_Blood_Sanlayn): Marrowrend -> Heart Strike x2 as a castsequence (Bone Shield
-- refresh, then spend the runes) and Blood Boil -> Death Strike, plus Raise Dead on its own.
-- Dancing Rune Weapon and Vampiric Blood stay in your hands (big cooldowns).
-- 4.3.0 talents-first: Consumption is not in the top Mythic+ / Raid builds, so it is gone.
-- "Heart  Strike" has two spaces on purpose (so GSE cannot rewrite it as
-- Vampiric Strike). All castsequences reset after 4 s so they can never get stuck.
local DK_SANLAYN_AIO = {
    { S("Death Strike"), R("/castsequence reset=4 Marrowrend, Heart  Strike, Heart  Strike"), S("Blood Boil") },
    { R("/castsequence reset=4 Blood Boil, Death Strike"), S("Heart Strike") },
    { S("Death and Decay", "p"), S("Heart Strike"), S("Blood Boil") },
    { S("Raise Dead"), S("Heart Strike"), S("Blood Boil") },
    { R("/castsequence reset=4 Heart  Strike, Heart  Strike, Blood Boil"), S("Death Strike") },
    { S("Marrowrend"), S("Heart Strike"), S("Blood Boil") },
}

-- DEATHBRINGER in the same castsequence style (Reaper's Mark instead of Raise
-- Dead's slot priority; plain "Heart Strike" because Deathbringer has no
-- Vampiric Strike override).
local DK_DEATHBRINGER_CS = {
    { S("Death Strike"), R("/castsequence reset=4 Marrowrend, Heart Strike, Heart Strike"), S("Blood Boil") },
    { R("/castsequence reset=4 Blood Boil, Death Strike"), S("Heart Strike") },
    { S("Death and Decay", "p"), S("Heart Strike"), S("Blood Boil") },
    { S("Reaper's Mark"), S("Heart Strike"), S("Blood Boil") },
    { R("/castsequence reset=4 Heart Strike, Heart Strike, Blood Boil"), S("Death Strike") },
    { S("Raise Dead"), S("Marrowrend"), S("Heart Strike") },
}

-- VENGEANCE (Method Midnight priority as plain ladders, no castsequences: they stalled on
-- Spirit Bomb / Fracture charges). Spenders BEFORE Fracture (they only fire with Fury / souls),
-- cooldowns first in their step, Fracture as the builder (4.2.4: Fracture first starved them).
-- Spirit Bomb (40 Fury + Soul Fragments) ALWAYS before Soul Cleave (30 Fury, eats 2 fragments), or it never fires.
-- Midnight: Fracture overrides Demon's Bite for Vengeance (Shear is gone). /cast Demon's Bite after Fracture casts
-- Fracture through the override when /cast Fracture does not resolve. Spirit Bomb has a 25 s cooldown, Soul Cleave 35 Fury.
-- Fiery Brand + Fel Devastation + Soul Carver together in the cooldown step (Brand first).
-- Fel Devastation is protected by the /stopmacro [channeling:Fel Devastation] line.
local DH_CS_ALDRACHI = {
    { S("Fel Devastation"), S("Reaver's Glaive"), S("Spirit Bomb"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite") },
    { S("Sigil of Spite", "p"), S("Soul Carver"), S("Spirit Bomb"), S("Fracture"), S("Demon's Bite"), S("Throw Glaive") },
    { S("Immolation Aura"), S("Sigil of Flame", "p"), S("Spirit Bomb"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite") },
    { S("Immolation Aura"), S("Felblade"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite"), S("Throw Glaive") },
    { S("Demon Spikes", "c"), S("Spirit Bomb"), S("Fracture"), S("Demon's Bite"), S("Felblade"), S("Throw Glaive") },
    { S("Fiery Brand", "c"), S("Fel Devastation", "c"), S("Soul Carver", "c"), S("Felblade"), S("Throw Glaive") },
}
local DH_CS_ANNIHILATOR = {
    { S("Fel Devastation"), S("Immolation Aura"), S("Spirit Bomb"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite") },
    { S("Soul Carver"), S("Sigil of Spite", "p"), S("Spirit Bomb"), S("Fracture"), S("Demon's Bite"), S("Throw Glaive") },
    { S("Sigil of Flame", "p"), S("Spirit Bomb"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite"), S("Throw Glaive") },
    { S("Felblade"), S("Spirit Bomb"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite"), S("Throw Glaive") },
    { S("Demon Spikes", "c"), S("Spirit Bomb"), S("Fracture"), S("Demon's Bite"), S("Throw Glaive") },
    { S("Metamorphosis", "c"), S("Fiery Brand", "c"), S("Fel Devastation", "c"), S("Felblade"), S("Throw Glaive") },
}
-- 4.3.0 talents-first: Soul Carver is in the Raid builds only (top Mythic+ players skip it).
local function Without(list, spell)
    local o = {}
    for i, st in ipairs(list) do
        local n = {}
        for _, e in ipairs(st) do if e.spell ~= spell then n[#n + 1] = e end end
        o[i] = n
    end
    return o
end
local DH_CS_ALDRACHI_M = Without(DH_CS_ALDRACHI, "Soul Carver")
local DH_CS_ANNIHILATOR_M = Without(DH_CS_ANNIHILATOR, "Soul Carver")

-- "Beginner" version (4th, pick it by hand) for every class: the same steps plus ONE
-- extra step (3rd) with ONE defensive (off-GCD defensives would all fire together), so a new player can just press and go.
local function Beginner(list, def)
    local o = {}
    for i, v in ipairs(list) do o[i] = v end
    table.insert(o, 3, def)
    return o
end
local DEF_PAL  = { S("Ardent Defender", "c"), S("Hammer of Wrath"), S("Judgment"), S("Hammer of the Righteous"), S("Blessed Hammer") }
local DEF_DRU  = { S("Barkskin", "c"), S("Mangle"), S("Thrash"), S("Swipe") }
local DEF_WAR  = { S("Shield Wall", "c"), S("Shield Slam"), S("Thunder Clap"), S("Revenge") }
local DEF_DH   = { S("Fiery Brand", "c"), S("Fracture"), S("Demon's Bite"), S("Throw Glaive") }      -- Leveling only
local DEF_DH_ALD = { S("Metamorphosis", "c"), S("Spirit Bomb"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite") }
local DEF_DH_ANN = { S("Demon Spikes", "c"), S("Spirit Bomb"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite") }
local DEF_BREW = { S("Celestial Brew", "c"), S("Celestial Infusion", "c"), S("Blackout Kick"), S("Breath of Fire"), S("Tiger Palm") }
local DEF_DK   = { S("Vampiric Blood", "c"), S("Heart Strike"), S("Blood Boil") }

Ronin.RetailSequences = {
    RoninPaladin_Lightsmith     = Seq("RoninPaladin_Lightsmith",     66,  PALADIN,     PAL_LIGHTSMITH,  PAL_LIGHTSMITH,  nil, Beginner(PAL_LIGHTSMITH, DEF_PAL), DEF_PAL),
    RoninPaladin_Templar        = Seq("RoninPaladin_Templar",        66,  PALADIN,     PAL_TEMPLAR,     PAL_TEMPLAR,     nil, Beginner(PAL_TEMPLAR, DEF_PAL), DEF_PAL),
    RoninBrewmaster_Harmony     = Seq("RoninBrewmaster_Harmony",     268, BREWMASTER,  CdFirst(BREW_HARMONY_M),  BREW_HARMONY,  CdFirst(BREW_HARMONY_M),  Beginner(BREW_HARMONY_M, DEF_BREW), DEF_BREW),
    RoninBrewmaster_ShadoPan    = Seq("RoninBrewmaster_ShadoPan",    268, BREWMASTER,  CdFirst(BREW_SHADOPAN_M), BREW_SHADOPAN, CdFirst(BREW_SHADOPAN_M), Beginner(BREW_SHADOPAN_M, DEF_BREW), DEF_BREW),
    RoninDruid_Elune            = Seq("RoninDruid_Elune",            104, DRUID,       DRU_ELUNE,       DRU_ELUNE,       nil, Beginner(DRU_ELUNE, DEF_DRU), DEF_DRU),
    RoninDruid_Claw             = Seq("RoninDruid_Claw",             104, DRUID,       DRU_CLAW,        DRU_CLAW,        nil, Beginner(DRU_CLAW, DEF_DRU), DEF_DRU),
    RoninWarrior_Thane          = Seq("RoninWarrior_Thane",          73,  WARRIOR,     WAR_THANE,       WAR_THANE,       nil, Beginner(WAR_THANE, DEF_WAR), DEF_WAR),
    RoninWarrior_Colossus       = Seq("RoninWarrior_Colossus",       73,  WARRIOR,     WAR_COLOSSUS,    WAR_COLOSSUS,    nil, Beginner(WAR_COLOSSUS, DEF_WAR), DEF_WAR),
    RoninDH_Vengeance_Aldrachi    = Seq("RoninDH_Vengeance_Aldrachi",    581, DEMONHUNTER, DH_CS_ALDRACHI_M,    DH_CS_ALDRACHI,    nil, Beginner(DH_CS_ALDRACHI_M, DEF_DH_ALD), DEF_DH_ALD),
    RoninDH_Vengeance_Annihil     = Seq("RoninDH_Vengeance_Annihil", 581, DEMONHUNTER, DH_CS_ANNIHILATOR_M, DH_CS_ANNIHILATOR, nil, Beginner(DH_CS_ANNIHILATOR_M, DEF_DH_ANN), DEF_DH_ANN),
    RoninDK_Blood_Deathbringer = Seq("RoninDK_Blood_Deathbringer", 250, DEATHKNIGHT, DK_DEATHBRINGER_CS, DK_DEATHBRINGER_CS, nil, Beginner(DK_DEATHBRINGER_CS, DEF_DK), DEF_DK),
    RoninDK_Blood_Sanlayn      = Seq("RoninDK_Blood_Sanlayn",       250, DEATHKNIGHT, DK_SANLAYN_AIO,  DK_SANLAYN_AIO,  nil, Beginner(DK_SANLAYN_AIO, DEF_DK), DEF_DK),
}

-- ---------------------------------------------------------------------------
-- "Leveling" version (5th, pick it by hand in GSE): only the basic spells every
-- spec learns on the way to the level cap, no hero talents needed. The big
-- defensives are in step 3 like the Beginner version, so a new tank can level
-- and quest with one button. Spells you have not learned yet are skipped.
-- ---------------------------------------------------------------------------
local LV_PAL = {
    { S("Avenger's Shield"), S("Judgment"), S("Shield of the Righteous"), S("Hammer of the Righteous"), S("Blessed Hammer"), S("Consecration", "c") },
    { S("Hammer of Wrath"), S("Judgment"), S("Hammer of the Righteous"), S("Blessed Hammer"), S("Crusader Strike"), S("Consecration", "c") },
    { S("Consecration", "c"), S("Hammer of Wrath"), S("Judgment"), S("Hammer of the Righteous"), S("Blessed Hammer") },
}
local LV_DRU = {
    { S("Mangle"), S("Thrash"), S("Moonfire") },
    { S("Ironfur"), S("Mangle"), S("Swipe") },
    { S("Maul"), S("Thrash"), S("Swipe") },
}
local LV_WAR = {
    { S("Shield Slam"), S("Thunder Clap"), S("Revenge"), S("Devastate"), S("Shield Charge") },
    { S("Shield Block"), S("Thunder Clap"), S("Revenge"), S("Devastate"), S("Shield Charge") },
    { S("Execute"), S("Shield Charge"), S("Thunder Clap"), S("Devastate"), S("Revenge") },
}
local LV_BREW = {
    { S("Keg Smash"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Breath of Fire"), S("Blackout Kick"), S("Tiger Palm") },
    { S("Chi Burst"), S("Spinning Crane Kick"), S("Tiger Palm") },
}
local LV_DH = {
    { S("Spirit Bomb"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite"), S("Throw Glaive") },
    { S("Immolation Aura"), S("Sigil of Flame", "p"), S("Fracture"), S("Demon's Bite") },
    { S("Fel Devastation"), S("Spirit Bomb"), S("Soul Cleave"), S("Fracture"), S("Demon's Bite") },
    { S("Fel Devastation", "c"), S("Felblade"), S("Fracture"), S("Demon's Bite") },
}
local LV_DK = {
    { S("Marrowrend"), S("Heart Strike"), S("Blood Boil") },
    { S("Death Strike"), S("Heart Strike"), S("Blood Boil") },
    { S("Death and Decay", "p"), S("Blood Boil"), S("Heart Strike") },
}
local LEVELING = {
    RoninPaladin_Lightsmith = { PALADIN, LV_PAL, DEF_PAL },  RoninPaladin_Templar = { PALADIN, LV_PAL, DEF_PAL },
    RoninBrewmaster_Harmony = { BREWMASTER, LV_BREW, nil },  RoninBrewmaster_ShadoPan = { BREWMASTER, LV_BREW, nil },
    RoninDruid_Elune = { DRUID, LV_DRU, DEF_DRU },           RoninDruid_Claw = { DRUID, LV_DRU, DEF_DRU },
    RoninWarrior_Thane = { WARRIOR, LV_WAR, DEF_WAR },       RoninWarrior_Colossus = { WARRIOR, LV_WAR, DEF_WAR },
    RoninDH_Vengeance_Aldrachi = { DEMONHUNTER, LV_DH, DEF_DH }, RoninDH_Vengeance_Annihil = { DEMONHUNTER, LV_DH, DEF_DH },
    RoninDK_Blood_Deathbringer = { DEATHKNIGHT, LV_DK, DEF_DK }, RoninDK_Blood_Sanlayn = { DEATHKNIGHT, LV_DK, DEF_DK },
}
local BREW_DEF = DEF_BREW
for name, x in pairs(LEVELING) do
    local list = x[3] and Beginner(x[2], x[3]) or Beginner(x[2], BREW_DEF)
    Ronin.RetailSequences[name].Versions[5] = { Label = "Leveling", Actions = BuildActions("group", x[1], list), InbuiltVariables = { Combat = true } }
end
