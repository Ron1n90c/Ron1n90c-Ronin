-- Ronin Forever V1.7.0 - Tank macros for WoW: Forever (GSE)
--
-- Same style for all three classes (built from the Paladin "Prot_Leveling" that
-- works): SEQUENTIAL steps, plain spell NAMES (no ranks, no spell IDs), short
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
        v[i] = { Label = x[1], Actions = acts, InbuiltVariables = { Combat = true } }
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
local PAL_MOD    = "/cast [mod:shift,@player]Flash of Light;[mod:alt]Hammer of Justice;[mod:ctrl]Rebuke"
local PAL_MOD_LV = "/cast [mod:shift,@player]Holy Light"   -- no Flash of Light before 20
local PAL_SEQ    = "/castsequence reset=combat/2 Seal of Fury, Judgement, Judgement, Judgement"


local PALADIN = Flat("RoninForever_Paladin", 1486, 1, {
    { "Leveling 1-20", {
        { TGT, PAL_MOD, PAL_MOD_LV, PAL_SEQ, ATK },
        { TGT, PAL_MOD, PAL_MOD_LV, "/cast Holy Strike", ATK },
        { TGT, PAL_MOD, PAL_MOD_LV, "/cast Judgement", ATK },
    } },
    { "Leveling 20-40", {
        { TGT, PAL_MOD, PAL_SEQ, ATK },
        { TGT, PAL_MOD, "/cast Holy Strike", ATK },
        { TGT, PAL_MOD, "/cast Exorcism", ATK },
        { TGT, PAL_MOD, "/cast [nomod]Consecration", ATK },
        { TGT, PAL_MOD, "/cast [nomod]Holy Shield", ATK },
    } },
    { "60", {
        { TGT, PAL_MOD, PAL_SEQ, ATK },
        { TGT, PAL_MOD, "/cast Holy Strike", ATK },
        { TGT, PAL_MOD, "/cast [nomod]Hammer of the Righteous", ATK },
        { TGT, PAL_MOD, "/cast [nomod]Holy Shield", ATK },
        { TGT, PAL_MOD, "/cast Holy Strike", ATK },
        { TGT, PAL_MOD, "/cast [nomod]Consecration", ATK },
        { TGT, PAL_MOD, "/cast Exorcism", ATK },
    } },
})

-- ---------------------------------------------------------------------------
-- PROTECTION WARRIOR (Defensive Stance; no Devastate in Forever)
-- Defensive Stance (10), Revenge, Sunder Armor (castsequence once per target),
-- Thunder Clap (6), Shield Block, Bloodrage, Demoralizing Shout, Battle Shout,
-- Shield Slam (talent). Heroic Strike is NOT used (rage goes to threat spells).
-- ---------------------------------------------------------------------------
local WAR_MOD = "/cast [mod:shift]Victory Rush;[mod:alt]Concussion Blow;[mod:ctrl]Shield Bash"
local STANCE  = "/cast [nostance:2] Defensive Stance"
local WAR_SHOUTS = "/castsequence reset=combat Thunder Clap, Demoralizing Shout, Thunder Clap, Battle Shout, Thunder Clap, Thunder Clap, Thunder Clap"

local WARRIOR = Flat("RoninForever_Warrior", 1491, 1, {
    { "Leveling 1-20", {
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] Revenge", ATK },
        { TGT, STANCE, WAR_MOD, "/castsequence [combat,nomod] reset=target Sunder Armor, null", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] Thunder Clap", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] Shield Block", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] Bloodrage", ATK },
        { TGT, STANCE, WAR_MOD, "/castsequence [nomod] reset=combat Battle Shout, null", ATK },
    } },
    { "Leveling 20-40", {
        { TGT, STANCE, WAR_MOD, "/cast [nomod,combat] Shield Block", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] Revenge", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] Bloodrage", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] Shield Slam", ATK },
        { STANCE, WAR_MOD, WAR_SHOUTS },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] Sunder Armor", ATK },
    } },
    { "60", {
        { TGT, STANCE, WAR_MOD, "/cast [nomod] Shield Slam", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] Revenge", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] Sunder Armor", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod,combat] Shield Block", ATK },
        { STANCE, WAR_MOD, WAR_SHOUTS },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] Shield Slam", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] Revenge", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [nomod] Bloodrage", ATK },
        { TGT, STANCE, WAR_MOD, "/cast [combat,nomod] Sunder Armor", ATK },
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
local DRU_MOD  = "/cast [mod:shift]Frenzied Regeneration;[mod:alt]Bash;[mod:ctrl]Feral Charge"
local DIRE     = "/cast [noform:1] Dire Bear Form"
local BEAR     = "/cast [noform:1] Bear Form"
local ROAR     = "/castsequence [nomod] reset=target/25 Demoralizing Roar, null"
local FAERIE   = "/castsequence [nomod] reset=target/30 Faerie Fire (Feral), null"
-- Leveling versions use Bear Form (Dire Bear Form comes at 40), the 60 version uses Dire Bear Form.
local function Db(...) return { TGT, BEAR, DRU_MOD, ... } end
local function Dd(...) return { TGT, DIRE, DRU_MOD, ... } end

local DRUID = Flat("RoninForever_Druid", 103, 1, {
    { "Leveling 1-20", {
        Db("/cast [nomod] Maul", ATK),
        Db("/cast [nomod] Swipe", ATK),
        Db(ROAR, ATK),
        Db("/cast [nomod] Maul", ATK),
        Db("/cast [nomod] Swipe", ATK),
    } },
    { "Leveling 20-40", {
        Db("/cast [nomod] Primal Bite", ATK),
        Db("/cast [nomod] Lacerate", ATK),
        Db("/cast [nomod] Swipe", ATK),
        Db(FAERIE, ATK),
        Db("/cast [nomod] Maul", ATK),
        Db(ROAR, ATK),
    } },
    { "60", {
        Dd("/cast [nomod] Primal Bite", ATK),
        Dd("/cast [nomod] Lacerate", ATK),
        Dd("/cast [nomod] Swipe", ATK),
        Dd("/cast [nomod] Maul", ATK),
        Dd("/cast [nomod] Primal Bite", ATK),
        Dd(FAERIE, ATK),
        Dd("/cast [nomod] Lacerate", ATK),
        Dd(ROAR, ATK),
    } },
})

Ronin.ForeverSequences = {
    RoninForever_Paladin = PALADIN,
    RoninForever_Warrior = WARRIOR,
    RoninForever_Druid   = DRUID,
}
