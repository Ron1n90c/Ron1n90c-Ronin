-- Ronin Forever V1.9.0 - Tank macros for WoW: Forever (GSE)
--
-- Same style for all three classes: PRIORITY mode like Ronin Retail (the list order below is the
-- priority order), spell IDs (rank 1 ID; the client casts the highest rank you know). The source below uses names, the build replaces them with IDs, short
-- macros, one /castsequence for the refresh spells (seal, shouts, roars).
-- Three versions per class: "Leveling 1-20", "Leveling 20-40", "60".
-- Modifiers (every step): Shift = heal, Alt = CC (stun), Ctrl = interrupt.
-- Rules: tank only, no trinkets, no big defensives (you press those),
-- every step <= 255 characters AFTER GSE compiling (kept <= 250).
-- Forever has NO [buff]/[debuff] macro conditions, only [nostance]/[noform]/
-- [combat]/[mod]/... so refreshes are timed castsequences.
-- After a GSE update the macros must be put on the action bar again.
local _, Ronin = ...

local TGT = "/targetenemy [noexists][dead]"
local ATK = "/startattack"

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
            Name = name, Author = "Ronin Forever", SpecID = specID, Default = default,
            MythicPlus = default, Heroic = default, Dungeon = default, Timewalking = default,
            Mythic = default, PVP = default, Raid = default, Scenario = default,
        },
        Versions = v,
    }
end

-- ---------------------------------------------------------------------------
-- PROTECTION PALADIN
-- Seal of Fury (10) + Judgement x3 as one castsequence (resets after 2 s without
-- presses or when combat changes), Holy Strike (6), Consecration/Exorcism (20),
-- Holy Shield (30, talent), Hammer of the Righteous (40). You press Righteous
-- Fury yourself. Below level 10 there is no Seal of Fury: cast a seal yourself.
-- ---------------------------------------------------------------------------
local PAL_MOD    = "/cast [mod:shift,@player]19750;[mod:alt]853;[mod:ctrl]Rebuke"
local PAL_MOD_LV = "/cast [mod:shift,@player]635"   -- no 19750 before 20
local PAL_SEQ    = "/castsequence reset=combat/2 1311649, 20271, 20271, 20271"


local PALADIN = Flat("RoninForever_Paladin", 1486, 1, {
    { "Leveling 1-20", {
        { TGT, PAL_MOD, PAL_MOD_LV, PAL_SEQ, ATK },
        { TGT, PAL_MOD, PAL_MOD_LV, "/cast 679", ATK },
        { TGT, PAL_MOD, PAL_MOD_LV, "/cast 20271", ATK },
    } },
    { "Leveling 20-40", {
        { TGT, PAL_MOD, PAL_SEQ, ATK },
        { TGT, PAL_MOD, "/cast 679", ATK },
        { TGT, PAL_MOD, "/cast 879", ATK },
        { TGT, PAL_MOD, "/cast [nomod]26573", ATK },
        { TGT, PAL_MOD, "/cast [nomod]20925", ATK },
    } },
    { "60", {
        { TGT, PAL_MOD, PAL_SEQ, ATK },
        { TGT, PAL_MOD, "/cast 679", ATK },
        { TGT, PAL_MOD, "/cast [nomod]Hammer of the Righteous", ATK },
        { TGT, PAL_MOD, "/cast [nomod]20925", ATK },
        { TGT, PAL_MOD, "/cast 679", ATK },
        { TGT, PAL_MOD, "/cast [nomod]26573", ATK },
        { TGT, PAL_MOD, "/cast 879", ATK },
    } },
})

-- ---------------------------------------------------------------------------
-- PROTECTION WARRIOR (Defensive Stance; no Devastate in Forever)
-- Defensive Stance (10), Revenge, Sunder Armor (castsequence once per target),
-- Thunder Clap (6), Shield Block, Bloodrage, Demoralizing Shout, Battle Shout,
-- Shield Slam (talent). Heroic Strike is NOT used (rage goes to threat spells).
-- ---------------------------------------------------------------------------
local WAR_MOD = "/cast [mod:shift]402927;[mod:alt]12809;[mod:ctrl]72"
local STANCE  = "/cast [nostance:2] 71"
local WAR_SHOUTS = "/castsequence reset=combat 6343, 1160, 6343, 6673, 6343, 6343, 6343"

local WARRIOR = Flat("RoninForever_Warrior", 1491, 1, {
    { "Leveling 1-20", {
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] 6572", ATK },
        { TGT, STANCE, WAR_MOD, "/castsequence [combat,nomod] reset=target 7386, null", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] 6343", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] 2565", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] 2687", ATK },
        { TGT, STANCE, WAR_MOD, "/castsequence [nomod] reset=combat 6673, null", ATK },
    } },
    { "Leveling 20-40", {
        { TGT, STANCE, WAR_MOD, "/cast [nomod,combat] 2565", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] 6572", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] 2687", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] 23922", ATK },
        { STANCE, WAR_MOD, WAR_SHOUTS },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] 7386", ATK },
    } },
    { "60", {
        { TGT, STANCE, WAR_MOD, "/cast [nomod] 23922", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] 6572", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] 7386", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod,combat] 2565", ATK },
        { STANCE, WAR_MOD, WAR_SHOUTS },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] 23922", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] 6572", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] 2687", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] 7386", ATK },
    } },
})

-- ---------------------------------------------------------------------------
-- FERAL DRUID TANK
-- EVERY step first makes sure you are in Bear Form (Bear Form is learned at 10 by
-- quest; Dire Bear Form at 40: the 60 version uses it). Mangle is PRIMAL BITE here (talent),
-- Lacerate and Faerie Fire (Feral) are talents (Faerie Fire only from 20-40 on).
-- Roar / Faerie Fire re-apply on a new target and every 25/30 s (reset=target/N);
-- there are no [debuff] conditions in Forever. Enrage is left out (it lowers armor).
-- ---------------------------------------------------------------------------
local DRU_MOD  = "/cast [mod:shift]22842;[mod:alt]5211;[mod:ctrl]1238122"
local DIRE     = "/cast [noform:1] 9634"
local BEAR     = "/cast [noform:1] 5487"
local ROAR     = "/castsequence [nomod] reset=target/25 99, null"
local FAERIE   = "/castsequence [nomod] reset=target/30 Faerie Fire (Feral), null"
-- Leveling versions use Bear Form (Dire Bear Form comes at 40), the 60 version uses Dire Bear Form.
local function Db(...) return { TGT, BEAR, DRU_MOD, ... } end
local function Dd(...) return { TGT, DIRE, DRU_MOD, ... } end

local DRUID = Flat("RoninForever_Druid", 103, 1, {
    { "Leveling 1-20", {
        Db("/cast [nomod] 6807", ATK),
        Db("/cast [nomod] 779", ATK),
        Db(ROAR, ATK),
        Db("/cast [nomod] 6807", ATK),
        Db("/cast [nomod] 779", ATK),
    } },
    { "Leveling 20-40", {
        Db("/cast [nomod] 407995", ATK),
        Db("/cast [nomod] 1328617", ATK),
        Db("/cast [nomod] 779", ATK),
        Db(FAERIE, ATK),
        Db("/cast [nomod] 6807", ATK),
        Db(ROAR, ATK),
    } },
    { "60", {
        Dd("/cast [nomod] 407995", ATK),
        Dd("/cast [nomod] 1328617", ATK),
        Dd("/cast [nomod] 779", ATK),
        Dd("/cast [nomod] 6807", ATK),
        Dd("/cast [nomod] 407995", ATK),
        Dd(FAERIE, ATK),
        Dd("/cast [nomod] 1328617", ATK),
        Dd(ROAR, ATK),
    } },
})

Ronin.ForeverSequences = {
    RoninForever_Paladin = PALADIN,
    RoninForever_Warrior = WARRIOR,
    RoninForever_Druid   = DRUID,
}
