-- Ronin Heal for WoW: Forever. Written from scratch for Ronin.
-- Heal target: the friend under your mouse, otherwise YOU. Levels 1-10, 10-40, 40-60.
-- Shift = emergency heal, Ctrl = interrupt / stun, Alt = dispel or totem. No [buff] conditions in Forever.
local _, Ronin = ...

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

local FHPA = "/cast [mod:shift,@mouseover,help][mod:shift,@player]635;[mod:ctrl]853;[mod:alt,@mouseover,help][mod:alt,@player]1152"
local FHPB = "/cast [mod:shift,@mouseover,help][mod:shift,@player]635;[mod:ctrl]853;[mod:alt,@mouseover,help][mod:alt,@player]4987"
local FHPC = "/cast [mod:shift,@mouseover,help][mod:shift,@player]19750;[mod:ctrl]853;[mod:alt,@mouseover,help][mod:alt,@player]4987"
local FHDA = "/cast [mod:shift,@mouseover,help][mod:shift,@player]5185;[mod:ctrl]339;[mod:alt,@mouseover,help][mod:alt,@player]2782"
local FHDB = "/cast [mod:shift,@mouseover,help][mod:shift,@player]8936;[mod:ctrl]339;[mod:alt,@mouseover,help][mod:alt,@player]2782"
local FHSA = "/cast [mod:shift,@mouseover,help][mod:shift,@player]331;[mod:ctrl]8042;[mod:alt]5394"
local FHSB = "/cast [mod:shift,@mouseover,help][mod:shift,@player]8004;[mod:ctrl]8042;[mod:alt]5394"
local FHRA = "/cast [mod:shift,@mouseover,help][mod:shift,@player]2050;[mod:ctrl]8122;[mod:alt,@mouseover,help][mod:alt,@player]527"
local FHRB = "/cast [mod:shift,@mouseover,help][mod:shift,@player]2061;[mod:ctrl]8122;[mod:alt,@mouseover,help][mod:alt,@player]527"

local FH_PALADIN = Flat("RoninFHeal_Paladin", 1486,
    "Holy Paladin for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Holy Light (Flash of Light from 40), Ctrl = Hammer of Justice, Alt = Cleanse / Purify on the friend under the mouse. Flash of Light is the main heal (best healing per mana), Holy Light comes now and then. Holy Shock and Light's Vigil are yours to press (Light's Vigil before big damage, Holy Shock right after). For damage (solo, leveling) use RoninFDPS_Paladin_Ret from the DPS page. Hover a frame and hold the key: it heals the friend under your mouse, otherwise you. Pick your level range in GSE.",
    {
    { "Level 1-10", {
        { FHPA, "/cast [@mouseover,help][@player]635" },
    } },
    { "Level 10-40", {
        { FHPB, "/cast [@mouseover,help][@player]19750", "/cast [@mouseover,help][@player]635" },
        { FHPB, "/cast [@mouseover,help][@player]635", "/cast [@mouseover,help][@player]19750" },
    } },
    { "Level 40-60", {
        { FHPC, "/cast [@mouseover,help][@player]19750" },
        { FHPC, "/cast [@mouseover,help][@player]19750", "/cast [@mouseover,help][@player]635" },
        { FHPC, "/cast [@mouseover,help][@player]635", "/cast [@mouseover,help][@player]19750" },
    } },
})

local FH_DRUID = Flat("RoninFHeal_Druid", 103,
    "Restoration Druid for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Healing Touch (Regrowth from 10), Ctrl = Entangling Roots, Alt = Remove Curse on the friend under the mouse. Regrowth is the main heal, Rejuvenation now and then, Lifebloom and Swiftmend when you have them, Healing Touch only before you learn Regrowth. Wild Growth and Tranquility are yours to press. For damage (solo, leveling) use RoninFDPS_Druid_Cat from the DPS page. Hover a frame and hold the key: it heals the friend under your mouse, otherwise you. Pick your level range in GSE.",
    {
    { "Level 1-10", {
        { FHDA, "/cast [@mouseover,help][@player]5185" },
        { FHDA, "/cast [@mouseover,help][@player]774", "/cast [@mouseover,help][@player]5185" },
    } },
    { "Level 10-40", {
        { FHDB, "/cast [@mouseover,help][@player]8936", "/cast [@mouseover,help][@player]5185" },
        { FHDB, "/cast [@mouseover,help][@player]774", "/cast [@mouseover,help][@player]8936" },
        { FHDB, "/cast [@mouseover,help][@player]8936", "/cast [@mouseover,help][@player]774" },
    } },
    { "Level 40-60", {
        { FHDB, "/cast [@mouseover,help][@player]8936" },
        { FHDB, "/cast [@mouseover,help][@player]Lifebloom", "/cast [@mouseover,help][@player]774" },
        { FHDB, "/cast [@mouseover,help][@player]18562", "/cast [@mouseover,help][@player]8936" },
        { FHDB, "/cast [@mouseover,help][@player]8936", "/cast [@mouseover,help][@player]774" },
    } },
})

local FH_SHAMAN = Flat("RoninFHeal_Shaman", 1489,
    "Restoration Shaman for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Healing Wave (Lesser Healing Wave from 40), Ctrl = Earth Shock, Alt = Healing Stream Totem. Riptide first when it is ready, Healing Wave is the main heal, Chain Heal for groups (from 40). Nature's Swiftness and Mana Tide Totem are yours to press. For damage (solo, leveling) use RoninFDPS_Shaman_Ele or RoninFDPS_Shaman_Enh from the DPS page. Hover a frame and hold the key: it heals the friend under your mouse, otherwise you. Pick your level range in GSE.",
    {
    { "Level 1-10", {
        { FHSA, "/cast [@mouseover,help][@player]331" },
    } },
    { "Level 10-40", {
        { FHSA, "/cast [@mouseover,help][@player]Riptide", "/cast [@mouseover,help][@player]331" },
        { FHSA, "/cast [@mouseover,help][@player]331", "/cast [@mouseover,help][@player]8004" },
        { FHSA, "/cast [@mouseover,help][@player]8004", "/cast [@mouseover,help][@player]331" },
    } },
    { "Level 40-60", {
        { FHSB, "/cast [@mouseover,help][@player]Riptide", "/cast [@mouseover,help][@player]331" },
        { FHSB, "/cast [@mouseover,help][@player]331", "/cast [@mouseover,help][@player]1064" },
        { FHSB, "/cast [@mouseover,help][@player]1064", "/cast [@mouseover,help][@player]331" },
        { FHSB, "/cast [@mouseover,help][@player]Riptide", "/cast [@mouseover,help][@player]1064" },
    } },
})

local FH_PRIEST = Flat("RoninFHeal_Priest", 1487,
    "Holy Priest for WoW: Forever. Levels 1-10, 10-40, 40-60. Keys: Shift = Lesser Heal (Flash Heal from 20), Ctrl = Psychic Scream, Alt = Dispel Magic on the friend under the mouse. Heal and Greater Heal are the main heals, Flash Heal only on Shift (it costs a lot of mana). Power Word: Shield, Renew, Prayer of Mending and Circle of Healing when you have them. Prayer of Healing is yours to press for group damage. For damage (solo, leveling) use RoninFDPS_Priest from the DPS page. Hover a frame and hold the key: it heals the friend under your mouse, otherwise you. Pick your level range in GSE.",
    {
    { "Level 1-10", {
        { FHRA, "/cast [@mouseover,help][@player]2050" },
        { FHRA, "/cast [@mouseover,help][@player]17", "/cast [@mouseover,help][@player]139" },
    } },
    { "Level 10-40", {
        { FHRB, "/cast [@mouseover,help][@player]Heal", "/cast [@mouseover,help][@player]2050" },
        { FHRB, "/cast [@mouseover,help][@player]139", "/cast [@mouseover,help][@player]Heal" },
        { FHRB, "/cast [@mouseover,help][@player]17", "/cast [@mouseover,help][@player]Heal" },
    } },
    { "Level 40-60", {
        { FHRB, "/cast [@mouseover,help][@player]2060", "/cast [@mouseover,help][@player]Heal" },
        { FHRB, "/cast [@mouseover,help][@player]139", "/cast [@mouseover,help][@player]2060" },
        { FHRB, "/cast [@mouseover,help][@player]Prayer of Mending", "/cast [@mouseover,help][@player]Heal" },
        { FHRB, "/cast [@mouseover,help][@player]17", "/cast [@mouseover,help][@player]Heal" },
        { FHRB, "/cast [@mouseover,help][@player]Circle of Healing", "/cast [@mouseover,help][@player]2060" },
    } },
})

Ronin.ForeverHealSequences = {
    ["RoninFHeal_Paladin"] = FH_PALADIN,
    ["RoninFHeal_Druid"] = FH_DRUID,
    ["RoninFHeal_Shaman"] = FH_SHAMAN,
    ["RoninFHeal_Priest"] = FH_PRIEST,
}
