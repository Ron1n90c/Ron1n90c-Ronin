-- Ronin Forever V4.1.0 - Tank macros for WoW: Forever (GSE)
--
-- Same style for all three classes: PRIORITY mode like Ronin Retail (the list order below is the
-- priority order), spell IDs (rank 1 ID; the client casts the highest rank you know). The source below uses names, the build replaces them with IDs, short
-- macros, one /castsequence for the refresh spells (seal, shouts, roars).
-- Versions: Leveling 1-10, 10-40, 40-60 (all classes).
-- Modifiers (every step): Shift = heal, Ctrl = interrupt, Alt = class extra (Paladin Consecration, Warrior Concussion Blow, Druid Bash).
-- Rules: tank only, no trinkets, no big defensives (you press those),
-- every step <= 255 characters AFTER GSE compiling (kept <= 250).
-- Forever has NO [buff]/[debuff] macro conditions, only [nostance]/[noform]/
-- [combat]/[mod]/... so refreshes are timed castsequences.
-- After a GSE update the macros must be put on the action bar again.
local _, Ronin = ...

local TGT = "/targetenemy [noexists][dead]"

-- steps: list of macros (list of lines). Sequential, like the originals.
local function Flat(name, specID, default, versions)
    local v = {}
    for i, x in ipairs(versions) do
        local acts = {}
        for j, m in ipairs(x[2]) do
            acts[j] = { Type = "Action", type = "macro", macro = table.concat(m, "\n"), Interval = "3" }
        end
        -- ONE Loop with StepFunction "Priority" (like Retail): the first steps come up
        -- most often. A step that appears twice in the list is kept only once.
        local seen, loop = {}, { Type = "Loop", StepFunction = "Priority", Repeat = "1" }
        for _, a in ipairs(acts) do
            if not seen[a.macro] then seen[a.macro] = true; loop[#loop + 1] = a end
        end
        v[i] = { Label = x[1], Actions = { loop }, InbuiltVariables = { Combat = true } }
    end
    return {
        MetaData = {
            Name = name, Author = "Ronin", SpecID = specID, Default = default,
            MythicPlus = default, Heroic = default, Dungeon = default, Timewalking = default,
            Mythic = default, PVP = default, Raid = default, Scenario = default,
        },
        Versions = v,
    }
end

-- ---------------------------------------------------------------------------
-- PROTECTION PALADIN
-- Short macros, few blocks: a step can hold 2-3 spells in a row, the first one that is
-- ready is cast (Holy Shield, Exorcism, Holy Shock ... as you learn them).
-- Shift = Holy Light / Flash of Light, Ctrl = Hammer of Justice, Alt = Consecration.
-- Righteous Fury: you press it yourself.
-- ---------------------------------------------------------------------------
local PM1 = "/cast [mod:shift,@player]635;[mod:ctrl]853;[mod:alt]26573"
local PM  = "/cast [mod:shift,@player]19750;[mod:ctrl]853;[mod:alt]26573"
-- In Forever Judgement no longer uses up the seal: the seal is cast once (again after 28 s or a new fight)
-- and Judgement (off the global cooldown) sits in every step.
local PSEQ1 = "/castsequence [nomod] reset=combat/28 20154, null"
local PSEQ  = "/castsequence [nomod] reset=combat/28 1311649, null"
local function P(m, ...) return { TGT, m, ... } end

local PALADIN = Flat("RoninForever_Paladin", 1486, 1, {
    { "Level 1-10", {
        P(PM1, PSEQ1, "/cast 20271", "/cast 679"),
        P(PM1, "/cast 20271", "/cast 679"),
    } },
    { "Level 10-40", {
        P(PM1, PSEQ, "/cast 20271", "/cast 679", "/cast [nomod]20925"),
        P(PM1, "/cast 20271", "/cast [nomod]20925", "/cast 679"),
        P(PM1, "/cast 20271", "/cast 679", "/cast [nomod]20473"),
        P(PM1, PSEQ, "/cast 20271", "/cast 679"),
    } },
    { "Level 40-60", {
        P(PM, PSEQ, "/cast 20271", "/cast 679", "/cast [nomod]20925"),
        P(PM, "/cast 20271", "/cast [nomod]20925", "/cast 679"),
        P(PM, "/cast 20271", "/cast [nomod]Hammer of the Righteous", "/cast [nomod]20473", "/cast 679"),
        P(PM, "/cast 20271", "/cast 679", "/cast [nomod]20925"),
        P(PM, PSEQ, "/cast 20271", "/cast 679"),
    } },
})

-- ---------------------------------------------------------------------------
-- PROTECTION WARRIOR (Defensive Stance from level 10; no Devastate in Forever)
-- Shift = Victory Rush, Ctrl = Shield Bash, Alt = Concussion Blow.
-- Shield Slam first, Revenge as the fallback in the same step (whichever is ready).
-- Heroic Strike is NOT used from 10 on (rage goes to threat spells).
-- ---------------------------------------------------------------------------
local WM  = "/cast [mod:shift]402927;[mod:ctrl]72;[mod:alt]12809"
local STANCE  = "/cast [nostance:2] 71"
local DEMO = "/castsequence [nomod] reset=combat/28 1160, null"
local BSH  = "/castsequence [nomod] reset=combat/110 6673, null"
local function W(...) return { TGT, STANCE, WM, ... } end

local WARRIOR = Flat("RoninForever_Warrior", 1491, 1, {
    -- below 10 there is no Defensive Stance: Battle Stance fighting
    { "Level 1-10", {
        { TGT, WM, "/cast [nomod] 78" },
        { TGT, WM, "/cast [nomod] 6343", "/cast [nomod] 78" },
        { TGT, WM, "/castsequence [nomod] reset=combat 6673, null" },
        { TGT, WM, "/castsequence [nomod] reset=target 772, null" },
    } },
    { "Level 10-40", {
        W("/cast [nomod] 23922", "/cast [combat,nomod] 6572"),
        W("/cast [combat,nomod] 2565", "/cast [nomod] 23922", "/cast [combat,nomod] 6572"),
        W("/cast [combat,nomod] 6572", "/cast [nomod] 23922", "/cast [nomod] 6343"),
        W(DEMO, "/cast [combat,nomod] 7386"),
        W("/castsequence [nomod] reset=target 772, null", "/cast [combat,nomod] 7386"),
        { STANCE, WM, "/cast [nomod] 2687", BSH, "/cast [combat,nomod] 7386" },
    } },
    { "Level 40-60", {
        W("/cast [nomod] 23922", "/cast [combat,nomod] 6572"),
        W("/cast [combat,nomod] 2565", "/cast [nomod] 23922", "/cast [combat,nomod] 6572"),
        W("/cast [combat,nomod] 6572", "/cast [nomod] 23922", "/cast [nomod] 6343"),
        W(DEMO, "/cast [combat,nomod] 7386"),
        W("/castsequence [nomod] reset=target 772, null", "/cast [combat,nomod] 7386"),
        { STANCE, WM, "/cast [nomod] 2687", BSH, "/cast [combat,nomod] 7386" },
    } },
})

-- ---------------------------------------------------------------------------
-- FERAL DRUID TANK (no AoE, no Swipe)
--   1-10   caster (Bear Form is a level 10 quest): Moonfire once per target, then Wrath.
--   10-40  Bear Form; ONE step holds Primal Bite, Lacerate, Maul - the first ready one is cast.
--   40-60  Dire Bear Form + Frenzied Regeneration (Shift).
-- Roar / Faerie Fire re-apply on a new target and every 25/30 s (no [debuff] in Forever).
-- Shift = heal, Ctrl = Feral Charge (interrupt), Alt = Bash (CC) - Entangling Roots as a caster.
-- Travel form: put it on a separate key (casting your own form again takes it OFF).
-- ---------------------------------------------------------------------------
local DM1  = "/cast [mod:shift,@player]5185;[mod:alt]339"
local DM   = "/cast [mod:shift,@player]5185;[mod:ctrl]1238122;[mod:alt]5211"
local DM4  = "/cast [mod:shift]22842;[mod:ctrl]1238122;[mod:alt]5211"
local BEAR = "/cast [noform:1] 5487"
local DIRE = "/cast [noform:1] 9634"
local ROAR   = "/castsequence [nomod] reset=target/25 99, null"
local FAERIE = "/castsequence [nomod] reset=target/30 770, null"
local function B(...) return { TGT, BEAR, DM, ... } end
local function D(...) return { TGT, DIRE, DM4, ... } end

local DRUID = Flat("RoninForever_Druid", 103, 1, {
    { "Level 1-10", {
        { TGT, DM1, "/castsequence [nomod] reset=target 8921, 5176, 5176, 5176" },
        { TGT, DM1, "/cast [nomod] 5176" },
    } },
    { "Level 10-40", {
        B("/cast [nomod] 407995", "/cast [nomod] 1328617", "/cast [nomod] 6807"),
        B("/cast [nomod] 1328617", "/cast [nomod] 6807"),
        B(FAERIE),
        B("/cast [nomod] 6807"),
        B(ROAR),
    } },
    { "Level 40-60", {
        D("/cast [nomod] 407995", "/cast [nomod] 1328617", "/cast [nomod] 6807"),
        D("/cast [nomod] 1328617", "/cast [nomod] 6807"),
        D(FAERIE),
        D("/cast [nomod] 6807"),
        D(ROAR),
    } },
})

Ronin.ForeverSequences = {
    RoninForever_Paladin = PALADIN,
    RoninForever_Warrior = WARRIOR,
    RoninForever_Druid   = DRUID,
}
