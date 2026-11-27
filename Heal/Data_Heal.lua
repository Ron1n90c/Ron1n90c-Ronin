-- Ronin Heal - Retail (Midnight). Written from scratch in the Ronin tank style:
-- Priority loop, small steps, every step <= 250 characters once compiled.
-- Heal target: the friend under your mouse, otherwise YOU. Shift = emergency heal, Alt = CC.
-- Emergency cooldowns (Revival, Tranquility, Life Cocoon, Ironbark, Lay on Hands, Spirit Link, Healing Tide) are NOT in the loop, use them by hand.
-- A spell you did not talent is simply skipped.
local _, Ronin = ...

local function S(spell, flags) return { spell = spell, flags = flags or "" } end
local function R(line) return { raw = line, spell = "", flags = "" } end
local function CastLine(e)
    if e.raw then return e.raw end
    if e.flags:find("s", 1, true) then
        return "/castsequence [nomod] reset=12/target " .. e.spell .. ", Null, Null"
    end
    local conds = {}
    if e.flags:find("c", 1, true) then conds[#conds + 1] = "combat" end
    if e.flags:find("p", 1, true) then conds[#conds + 1] = "@player" end
    if #conds == 0 then return "/cast " .. e.spell end
    return "/cast [" .. table.concat(conds, ",") .. "]" .. e.spell
end
local function BuildMacro(spec, list, raid)
    local lines = {}
    for _, p in ipairs(spec.pre or {}) do
        if raid and p:find("^/targetenemy") then p = "/targetenemy [noexists]" end   -- Raid keeps your target
        lines[#lines + 1] = p
    end
    for _, u in ipairs(spec.util) do lines[#lines + 1] = u end
    for _, e in ipairs(list) do lines[#lines + 1] = CastLine(e) end
    return table.concat(lines, "\n")
end
local function BuildActions(spec, tiers, raid)
    local loop = { Type = "Loop", StepFunction = "Priority", Repeat = "1" }
    for i, list in ipairs(tiers) do
        loop[i] = { Type = "Action", type = "macro", macro = BuildMacro(spec, list, raid) }
    end
    return { loop }
end
local function Copy(t) local o = {} for i, v in ipairs(t) do o[i] = v end return o end
local function RaidOrder(list)
    local o = Copy(list)
    local cd = table.remove(o)
    table.insert(o, 2, cd)
    return o
end
local function MplusOrder(list) return RaidOrder(list) end
-- Raid: no big healing cooldowns in the loop, you press them for the damage moments.
local function RaidHeal(list)
    local o = Copy(list)
    table.remove(o)
    return o
end
local function DelveOrder(list, def)
    local o = MplusOrder(list)
    table.insert(o, 4, def)
    return o
end
local function BeginnerOrder(list, def)
    local o = Copy(list)
    table.insert(o, 3, def)
    return o
end
-- Damage macro of a healer: finds its own target, cooldowns early, Raid keeps your target, Delve/Beginner add ONE defensive.
local function Dmg(name, specID, spec, list, def, notes, lvl)
    return {
        MetaData = {
            Name = name, Author = "Ronin", SpecID = specID, Default = 1,
            MythicPlus = 1, Heroic = 1, Dungeon = 1, Timewalking = 1, Mythic = 1,
            PVP = 1, Raid = 2, Scenario = 3, Notes = notes, Help = notes,
        },
        Versions = {
            [1] = { Label = "Mythic+",  Actions = BuildActions(spec, MplusOrder(list)), InbuiltVariables = { Combat = true } },
            [2] = { Label = "Raid",     Actions = BuildActions(spec, MplusOrder(list), true), InbuiltVariables = { Combat = true } },
            [3] = { Label = "Delve",    Actions = BuildActions(spec, DelveOrder(list, def)), InbuiltVariables = { Combat = true } },
            [4] = { Label = "Beginner", Actions = BuildActions(spec, BeginnerOrder(list, def)), InbuiltVariables = { Combat = true } },
            [5] = { Label = "Leveling", Actions = BuildActions(spec, lvl), InbuiltVariables = { Combat = true } },
        },
    }
end
local function Heal(name, specID, spec, list, def, notes, lvl)
    return {
        MetaData = {
            Name = name, Author = "Ronin", SpecID = specID, Default = 1,
            MythicPlus = 1, Heroic = 1, Dungeon = 1, Timewalking = 1, Mythic = 1,
            PVP = 1, Raid = 2, Scenario = 3, Notes = notes, Help = notes,
        },
        Versions = {
            [1] = { Label = "Mythic+",  Actions = BuildActions(spec, MplusOrder(list)), InbuiltVariables = { Combat = true } },
            [2] = { Label = "Raid",     Actions = BuildActions(spec, RaidHeal(list)), InbuiltVariables = { Combat = true } },
            [3] = { Label = "Delve",    Actions = BuildActions(spec, DelveOrder(list, def)), InbuiltVariables = { Combat = true } },
            [4] = { Label = "Beginner", Actions = BuildActions(spec, BeginnerOrder(list, def)), InbuiltVariables = { Combat = true } },
            [5] = { Label = "Leveling", Actions = BuildActions(spec, lvl), InbuiltVariables = { Combat = true } },
        },
    }
end

local C_MW = { util = { "/cast [mod:shift,@mouseover,help][mod:shift,@player]Vivify;[mod:alt]Leg Sweep" }, pre = { "/stopmacro [channeling]" } }
local D_MW = { S("Fortifying Brew", "c") }

local C_MWC = { util = { "/cast [mod:shift,@mouseover,help][mod:shift,@player]Vivify;[mod:alt]Leg Sweep" }, pre = { "/stopmacro [channeling]" } }
local D_MWC = { S("Fortifying Brew", "c") }

local C_HP = { util = { "/cast [mod:shift,@mouseover,help][mod:shift,@player]Flash of Light;[mod:alt]Hammer of Justice" } }
local D_HP = { S("Divine Protection", "c") }

local C_RD = { util = { "/cast [mod:shift,@mouseover,help][mod:shift,@player]Regrowth;[mod:alt]Mighty Bash" } }
local D_RD = { S("Barkskin", "c") }

local C_RS = { util = { "/cast [mod:shift,@mouseover,help][mod:shift,@player]Healing Wave;[mod:alt]Capacitor Totem" } }
local D_RS = { S("Astral Shift", "c") }

local C_MWD = { util = { "/cast [mod:shift,@mouseover,help][mod:shift,@player]Vivify;[mod:alt]Leg Sweep" }, pre = { "/targetenemy [noharm][dead]" } }
local D_MWD = { S("Fortifying Brew", "c") }

local C_HPD = { util = { "/cast [mod:shift,@mouseover,help][mod:shift,@player]Flash of Light;[mod:alt]Hammer of Justice" }, pre = { "/targetenemy [noharm][dead]" } }
local D_HPD = { S("Divine Protection", "c") }

local C_RDD = { util = { "/cast [mod:shift,@mouseover,help][mod:shift,@player]Regrowth;[mod:alt]Mighty Bash" }, pre = { "/targetenemy [noharm][dead]", "/cast [noform:2]Cat Form" } }
local D_RDD = { S("Barkskin", "c") }

local C_RSD = { util = { "/cast [mod:shift,@mouseover,help][mod:shift,@player]Healing Wave;[mod:alt]Capacitor Totem" }, pre = { "/targetenemy [noharm][dead]" } }
local D_RSD = { S("Astral Shift", "c") }

local Retail = {}

Retail.RoninHeal_Mist_Conduit = Heal("RoninHeal_Mist_Conduit", 270, C_MWC, {
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), S("Thunder Focus Tea", "c"), S("Rising Sun Kick") },
    { S("Rushing Wind Kick"), R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), S("Tiger Palm") },
    { R("/cast [@mouseover,help][@player]Vivify"), R("/cast [@mouseover,help][@player]Sheilun's Gift"), S("Blackout Kick") },
    { R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), R("/cast [@mouseover,help][@player]Vivify") },
    { S("Rising Sun Kick"), S("Tiger Palm"), S("Blackout Kick") },
    { S("Celestial Conduit", "c"), S("Invoke Chi-Ji, the Red Crane", "c"), S("Mana Tea", "c"), S("Tiger Palm") },
}, { S("Fortifying Brew", "c"), S("Tiger Palm") }, "Mistweaver Monk, Conduit of the Celestials. Conduit of the Celestials hero tree (Celestial Conduit with the big cooldowns). Hover a frame and hold the key: Renewing Mist goes on friends that do not have it yet, Rising Sun Kick and Thunder Focus Tea on cooldown, Enveloping Mist and Vivify as the spot heals. Keep a hostile target for the damage spells. Single target / spot healing macro, use the AoE macro for raid damage. Talents (import in game): Mythic+ / Delve: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMWmZZYxixMzsZsssND2Mz22yMjFmRzYGwgBjZZmZmhZbYGmlZCAAAAgAsYbmlZbmBAAAGgZADwiMmBA | Raid: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAghx2MwmFzYmZbGbYmZYmlttZGLMjmxMgBDGWmZmZYWGMYxEAAAAABYxyMLz2MDAAMgBYGwYYsMZMDA | Leveling: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAghxyMLDL2MjZshtttZMDzsttMzYhhmxMgBDzgZmZGmNYYWmJAAAAAAYBWmlZGAAAAwMgBYRGzA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Vivify (friend under the mouse, otherwise you), Alt = Leg Sweep. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), S("Rising Sun Kick"), S("Tiger Palm") },
    { R("/cast [@mouseover,help][@player]Vivify"), S("Blackout Kick") },
    { R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), S("Tiger Palm") },
})

Retail.RoninHeal_Mist_Cond_AoE = Heal("RoninHeal_Mist_Cond_AoE", 270, C_MWC, {
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), S("Thunder Focus Tea", "c"), S("Rising Sun Kick") },
    { S("Rushing Wind Kick"), R("/cast [@mouseover,help][@player]Sheilun's Gift"), S("Tiger Palm") },
    { R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), S("Rising Sun Kick"), S("Blackout Kick") },
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), R("/cast [@mouseover,help][@player]Vivify") },
    { S("Tiger Palm"), S("Blackout Kick"), S("Rushing Wind Kick") },
    { S("Celestial Conduit", "c"), S("Invoke Chi-Ji, the Red Crane", "c"), S("Mana Tea", "c"), S("Tiger Palm") },
}, { S("Fortifying Brew", "c"), S("Tiger Palm") }, "Mistweaver Monk, Conduit of the Celestials. Conduit of the Celestials hero tree (Celestial Conduit with the big cooldowns). Hover a frame and hold the key: Renewing Mist goes on friends that do not have it yet, Rising Sun Kick and Thunder Focus Tea on cooldown, Enveloping Mist and Vivify as the spot heals. Keep a hostile target for the damage spells. AoE macro: use it when the whole group takes damage. Talents (import in game): Mythic+ / Delve: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMWmZZYxixMzsZsssND2Mz22yMjFmRzYGwgBjZZmZmhZbYGmlZCAAAAgAsYbmlZbmBAAAGgZADwiMmBA | Raid: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAghx2MwmFzYmZbGbYmZYmlttZGLMjmxMgBDGWmZmZYWGMYxEAAAAABYxyMLz2MDAAMgBYGwYYsMZMDA | Leveling: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAghxyMLDL2MjZshtttZMDzsttMzYhhmxMgBDzgZmZGmNYYWmJAAAAAAYBWmlZGAAAAwMgBYRGzA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Vivify (friend under the mouse, otherwise you), Alt = Leg Sweep. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), S("Rising Sun Kick"), S("Tiger Palm") },
    { R("/cast [@mouseover,help][@player]Sheilun's Gift"), R("/cast [@mouseover,help][@player]Vivify") },
    { R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), S("Blackout Kick") },
})

Retail.RoninHeal_Mist_Harmony = Heal("RoninHeal_Mist_Harmony", 270, C_MW, {
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), S("Thunder Focus Tea", "c"), S("Rising Sun Kick") },
    { S("Rushing Wind Kick"), R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), S("Tiger Palm") },
    { R("/cast [@mouseover,help][@player]Vivify"), R("/cast [@mouseover,help][@player]Sheilun's Gift"), S("Blackout Kick") },
    { R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), R("/cast [@mouseover,help][@player]Vivify") },
    { S("Rising Sun Kick"), S("Tiger Palm"), S("Blackout Kick") },
    { S("Invoke Chi-Ji, the Red Crane", "c"), S("Invoke Yu'lon, the Jade Serpent", "c"), S("Mana Tea", "c"), S("Tiger Palm") },
}, { S("Fortifying Brew", "c"), S("Tiger Palm") }, "Mistweaver Monk, Master of Harmony. Master of Harmony hero tree (Thunder Focus Tea gives Harmonic Surge charges, spent by Tiger Palm and Vivify). Hover a frame and hold the key: Renewing Mist goes on friends that do not have it yet, Rising Sun Kick and Thunder Focus Tea on cooldown, Vivify as the spot heal. Keep a hostile target for the damage spells. Single target / spot healing macro, use the AoE macro for raid damage. Talents (import in game): Mythic+ / Delve: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM2mZZYxixMzsZsssND2Mzy2yMjFmRzYGwgBjZZmZmhZbYGmlZCAAAAMbTLz2MLzGAAAAAzMDAMALyAA | Raid: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM2mB2sYGzMbzYDzMDzsstMzYhZ0MmBMYwYWmZmZY2GmhZZmAAAAAz20ysNzysBAAAAwMzAADwiMAA | Leveling: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAghxyMLDL2MjZshtttZMDzsttMzYhhmxMgBDzgZmZGmNYYWmJAAAAAAYBWmlZGAAAAwMgBYRGzA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Vivify (friend under the mouse, otherwise you), Alt = Leg Sweep. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), S("Rising Sun Kick"), S("Tiger Palm") },
    { R("/cast [@mouseover,help][@player]Vivify"), S("Blackout Kick") },
    { R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), S("Tiger Palm") },
})

Retail.RoninHeal_Mist_Harm_AoE = Heal("RoninHeal_Mist_Harm_AoE", 270, C_MW, {
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), S("Thunder Focus Tea", "c"), S("Rising Sun Kick") },
    { S("Rushing Wind Kick"), R("/cast [@mouseover,help][@player]Sheilun's Gift"), S("Tiger Palm") },
    { R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), S("Rising Sun Kick"), S("Blackout Kick") },
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), R("/cast [@mouseover,help][@player]Vivify") },
    { S("Tiger Palm"), S("Blackout Kick"), S("Rushing Wind Kick") },
    { S("Invoke Chi-Ji, the Red Crane", "c"), S("Invoke Yu'lon, the Jade Serpent", "c"), S("Mana Tea", "c"), S("Tiger Palm") },
}, { S("Fortifying Brew", "c"), S("Tiger Palm") }, "Mistweaver Monk, Master of Harmony. Master of Harmony hero tree (Thunder Focus Tea gives Harmonic Surge charges, spent by Tiger Palm and Vivify). Hover a frame and hold the key: Renewing Mist goes on friends that do not have it yet, Rising Sun Kick and Thunder Focus Tea on cooldown, Vivify as the spot heal. Keep a hostile target for the damage spells. AoE macro: use it when the whole group takes damage. Talents (import in game): Mythic+ / Delve: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM2mZZYxixMzsZsssND2Mzy2yMjFmRzYGwgBjZZmZmhZbYGmlZCAAAAMbTLz2MLzGAAAAAzMDAMALyAA | Raid: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM2mB2sYGzMbzYDzMDzsstMzYhZ0MmBMYwYWmZmZY2GmhZZmAAAAAz20ysNzysBAAAAwMzAADwiMAA | Leveling: C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAghxyMLDL2MjZshtttZMDzsttMzYhhmxMgBDzgZmZGmNYYWmJAAAAAAYBWmlZGAAAAwMgBYRGzA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Vivify (friend under the mouse, otherwise you), Alt = Leg Sweep. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), S("Rising Sun Kick"), S("Tiger Palm") },
    { R("/cast [@mouseover,help][@player]Sheilun's Gift"), R("/cast [@mouseover,help][@player]Vivify") },
    { R("/cast [@mouseover,help,nobuff:Enveloping Mist][@player,nobuff:Enveloping Mist]Enveloping Mist"), S("Blackout Kick") },
})

Retail.RoninHeal_Holy_Herald = Heal("RoninHeal_Holy_Herald", 65, C_HP, {
    { R("/cast [@mouseover,help][@player]Holy Shock"), R("/cast [@mouseover,help][@player]Eternal Flame") },
    { S("Divine Toll", "c"), S("Judgment"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { R("/cast [@mouseover,help][@player]Holy Shock"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { R("/cast [@mouseover,help][@player]Eternal Flame"), R("/cast [@mouseover,help][@player]Word of Glory") },
    { R("/cast [@mouseover,help][@player]Flash of Light"), R("/cast [@mouseover,help][@player]Holy Light") },
    { S("Avenging Wrath", "c"), S("Judgment") },
}, { S("Divine Protection", "c"), R("/cast [@mouseover,help][@player]Flash of Light") }, "Holy Paladin, Herald of the Sun. Herald of the Sun hero tree (Dawnlight, Eternal Flame, Sun's Avatar with Avenging Wrath). Hover a frame and hold the key: Holy Shock on cooldown, Holy Shock and Judgment build Holy Power, Eternal Flame is the main spender (AoE macro: Light of Dawn), Divine Toll high up, Flash of Light spends Infusion of Light. Single target / spot healing macro, use the AoE macro for raid damage. Talents (import in game): Mythic+ / Delve: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAADWGzMzMjZmZBGDLjNzsY0EDjZmhxslBgBgNwGLzMzsMbzMzWDAAAwCLMzwmHAmxgZAAMzwMGjGA | Raid: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAAw2MzMjZMzYxYmZYZwMLmpJGGzMDjZLDADAbgNWmxMLz2Mzs1AAAAsAGYzwYGDmBAwMDzYMaA | Leveling: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAAwyYmZmZMzMLwYYZsZmFzkYWmxMzwY2yAwAwGYzsMzMzysNzMbNAAAALsBYDGjlZGDAAzMMjxwA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Flash of Light (friend under the mouse, otherwise you), Alt = Hammer of Justice. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help][@player]Holy Shock"), S("Judgment"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { R("/cast [@mouseover,help][@player]Eternal Flame"), R("/cast [@mouseover,help][@player]Word of Glory"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { S("Judgment"), R("/cast [@mouseover,help][@player]Flash of Light"), R("/cast [@mouseover,help][@player]Holy Light") },
})

Retail.RoninHeal_Holy_Herald_AoE = Heal("RoninHeal_Holy_Herald_AoE", 65, C_HP, {
    { R("/cast [@mouseover,help][@player]Holy Shock"), S("Light of Dawn") },
    { S("Divine Toll", "c"), S("Judgment"), S("Light of Dawn") },
    { R("/cast [@mouseover,help][@player]Holy Shock"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { S("Light of Dawn"), R("/cast [@mouseover,help][@player]Eternal Flame") },
    { R("/cast [@mouseover,help][@player]Flash of Light"), R("/cast [@mouseover,help][@player]Holy Light") },
    { S("Avenging Wrath", "c"), S("Judgment") },
}, { S("Divine Protection", "c"), R("/cast [@mouseover,help][@player]Flash of Light") }, "Holy Paladin, Herald of the Sun. Herald of the Sun hero tree (Dawnlight, Eternal Flame, Sun's Avatar with Avenging Wrath). Hover a frame and hold the key: Holy Shock on cooldown, Holy Shock and Judgment build Holy Power, Eternal Flame is the main spender (AoE macro: Light of Dawn), Divine Toll high up, Flash of Light spends Infusion of Light. AoE macro: use it when the whole group takes damage. Talents (import in game): Mythic+ / Delve: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAADWGzMzMjZmZBGDLjNzsY0EDjZmhxslBgBgNwGLzMzsMbzMzWDAAAwCLMzwmHAmxgZAAMzwMGjGA | Raid: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAAw2MzMjZMzYxYmZYZwMLmpJGGzMDjZLDADAbgNWmxMLz2Mzs1AAAAsAGYzwYGDmBAwMDzYMaA | Leveling: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAAwyYmZmZMzMLwYYZsZmFzkYWmxMzwY2yAwAwGYzsMzMzysNzMbNAAAALsBYDGjlZGDAAzMMjxwA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Flash of Light (friend under the mouse, otherwise you), Alt = Hammer of Justice. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help][@player]Holy Shock"), S("Judgment"), S("Light of Dawn") },
    { S("Light of Dawn"), R("/cast [@mouseover,help][@player]Eternal Flame"), R("/cast [@mouseover,help][@player]Word of Glory") },
    { S("Judgment"), R("/cast [@mouseover,help][@player]Flash of Light"), R("/cast [@mouseover,help][@player]Holy Light") },
})

Retail.RoninHeal_Holy_Lightsmith = Heal("RoninHeal_Holy_Lightsmith", 65, C_HP, {
    { R("/cast [@mouseover,help][@player]Holy Shock"), R("/cast [@mouseover,help][@player]Eternal Flame") },
    { S("Divine Toll", "c"), S("Judgment"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { R("/cast [@mouseover,help][@player]Holy Shock"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { R("/cast [@mouseover,help][@player]Eternal Flame"), R("/cast [@mouseover,help][@player]Word of Glory") },
    { R("/cast [@mouseover,help][@player]Flash of Light"), R("/cast [@mouseover,help][@player]Holy Light") },
    { S("Avenging Wrath", "c"), S("Holy Armaments"), S("Judgment") },
}, { S("Divine Protection", "c"), R("/cast [@mouseover,help][@player]Flash of Light") }, "Holy Paladin, Lightsmith. Lightsmith hero tree (Holy Armaments, Hammer and Anvil from Judgment, Blessing of the Forge). Hover a frame and hold the key: Holy Shock and Judgment build Holy Power, Eternal Flame is the main spender (AoE macro: Light of Dawn), Divine Toll high up, Holy Armaments with Avenging Wrath. Single target / spot healing macro, use the AoE macro for raid damage. Talents (import in game): Mythic+ / Delve: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAADWGzMzMjZmZBGDLjNzsY0EDjZmhxslBgBgNwGLzMzsMbzMzWDAAAwCLMzwmHAmxgZAAMzwMGjGA (then switch the hero tree to Lightsmith) | Leveling: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAAwyYmZmZMzMLwYYZsZmFzkYWmxMzwY2yAwAwGYzsMzMzysNzMbNAAAALsBYDGjlZGDAAzMMjxwA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Flash of Light (friend under the mouse, otherwise you), Alt = Hammer of Justice. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help][@player]Holy Shock"), S("Judgment"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { R("/cast [@mouseover,help][@player]Eternal Flame"), R("/cast [@mouseover,help][@player]Word of Glory"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { S("Judgment"), R("/cast [@mouseover,help][@player]Flash of Light"), R("/cast [@mouseover,help][@player]Holy Light") },
})

Retail.RoninHeal_Holy_Light_AoE = Heal("RoninHeal_Holy_Light_AoE", 65, C_HP, {
    { R("/cast [@mouseover,help][@player]Holy Shock"), S("Light of Dawn") },
    { S("Divine Toll", "c"), S("Judgment"), S("Light of Dawn") },
    { R("/cast [@mouseover,help][@player]Holy Shock"), R("/cast [@mouseover,help][@player]Flash of Light") },
    { S("Light of Dawn"), R("/cast [@mouseover,help][@player]Eternal Flame") },
    { R("/cast [@mouseover,help][@player]Flash of Light"), R("/cast [@mouseover,help][@player]Holy Light") },
    { S("Avenging Wrath", "c"), S("Holy Armaments"), S("Judgment") },
}, { S("Divine Protection", "c"), R("/cast [@mouseover,help][@player]Flash of Light") }, "Holy Paladin, Lightsmith. Lightsmith hero tree (Holy Armaments, Hammer and Anvil from Judgment, Blessing of the Forge). Hover a frame and hold the key: Holy Shock and Judgment build Holy Power, Eternal Flame is the main spender (AoE macro: Light of Dawn), Divine Toll high up, Holy Armaments with Avenging Wrath. AoE macro: use it when the whole group takes damage. Talents (import in game): Mythic+ / Delve: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAADWGzMzMjZmZBGDLjNzsY0EDjZmhxslBgBgNwGLzMzsMbzMzWDAAAwCLMzwmHAmxgZAAMzwMGjGA (then switch the hero tree to Lightsmith) | Leveling: CEEAAAAAAAAAAAAAAAAAAAAAAAAAALAwMAAwyYmZmZMzMLwYYZsZmFzkYWmxMzwY2yAwAwGYzsMzMzysNzMbNAAAALsBYDGjlZGDAAzMMjxwA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Flash of Light (friend under the mouse, otherwise you), Alt = Hammer of Justice. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help][@player]Holy Shock"), S("Judgment"), S("Light of Dawn") },
    { S("Light of Dawn"), R("/cast [@mouseover,help][@player]Eternal Flame"), R("/cast [@mouseover,help][@player]Word of Glory") },
    { S("Judgment"), R("/cast [@mouseover,help][@player]Flash of Light"), R("/cast [@mouseover,help][@player]Holy Light") },
})

Retail.RoninHeal_Resto_Keeper = Heal("RoninHeal_Resto_Keeper", 105, C_RD, {
    { R("/cast [@mouseover,help][@player]Swiftmend"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Lifebloom][@player,nobuff:Lifebloom]Lifebloom"), R("/cast [@mouseover,help][@player]Swiftmend") },
    { R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help][@player]Wild Growth"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help][@player]Regrowth"), R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation") },
    { S("Nature's Swiftness", "c"), S("Convoke the Spirits", "c"), R("/cast [@mouseover,help][@player]Regrowth") },
}, { S("Barkskin", "c"), R("/cast [@mouseover,help][@player]Regrowth") }, "Restoration Druid, Keeper of the Grove. Keeper of the Grove hero tree (Sylvan Beckoning empowers your next Swiftmend, strong healing with little cat-weaving). Hover a frame and hold the key: Lifebloom and Rejuvenation only on friends that do not have them, Swiftmend and Wild Growth on cooldown, Regrowth as the spot heal. Single target / spot healing macro, use the AoE macro for raid damage. Talents (import in game): Mythic+ / Delve / Leveling: CkGAAAAAAAAAAAAAAAAAAAAAAMMmZZMjZmxsN8AMzsYsYbGAAAAAAAAAAsYoZbGmmBwsYmZmZxwDMAAAAAMAAzA22GLYamZZAAACYhZmZGmZ2ANDAmZAADA | Raid: CkGAAAAAAAAAAAAAAAAAAAAAAMjxMbzMjZmxsN8AzYGGbMDAAAAAAAAAAWG0sZGTzMGGzyMzMzwwMAAAAAAAAw2yYDTzMLDAAQALMmZwMDQzAgZGAwA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Regrowth (friend under the mouse, otherwise you), Alt = Mighty Bash. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Lifebloom][@player,nobuff:Lifebloom]Lifebloom"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help][@player]Wild Growth"), R("/cast [@mouseover,help][@player]Swiftmend"), R("/cast [@mouseover,help][@player]Regrowth") },
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Wrath") },
})

Retail.RoninHeal_Resto_Keeper_AoE = Heal("RoninHeal_Resto_Keeper_AoE", 105, C_RD, {
    { R("/cast [@mouseover,help][@player]Wild Growth"), R("/cast [@mouseover,help][@player]Swiftmend") },
    { R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Lifebloom][@player,nobuff:Lifebloom]Lifebloom"), R("/cast [@mouseover,help][@player]Swiftmend") },
    { R("/cast [@player]Efflorescence"), R("/cast [@mouseover,help][@player]Wild Growth") },
    { R("/cast [@mouseover,help][@player]Regrowth"), R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation") },
    { S("Convoke the Spirits", "c"), S("Nature's Swiftness", "c"), R("/cast [@mouseover,help][@player]Regrowth") },
}, { S("Barkskin", "c"), R("/cast [@mouseover,help][@player]Regrowth") }, "Restoration Druid, Keeper of the Grove. Keeper of the Grove hero tree (Sylvan Beckoning empowers your next Swiftmend, strong healing with little cat-weaving). Hover a frame and hold the key: Lifebloom and Rejuvenation only on friends that do not have them, Swiftmend and Wild Growth on cooldown, Regrowth as the spot heal. AoE macro: use it when the whole group takes damage. Talents (import in game): Mythic+ / Delve / Leveling: CkGAAAAAAAAAAAAAAAAAAAAAAMMmZZMjZmxsN8AMzsYsYbGAAAAAAAAAAsYoZbGmmBwsYmZmZxwDMAAAAAMAAzA22GLYamZZAAACYhZmZGmZ2ANDAmZAADA | Raid: CkGAAAAAAAAAAAAAAAAAAAAAAMjxMbzMjZmxsN8AzYGGbMDAAAAAAAAAAWG0sZGTzMGGzyMzMzwwMAAAAAAAAw2yYDTzMLDAAQALMmZwMDQzAgZGAwA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Regrowth (friend under the mouse, otherwise you), Alt = Mighty Bash. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help][@player]Wild Growth"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Lifebloom][@player,nobuff:Lifebloom]Lifebloom"), R("/cast [@mouseover,help][@player]Swiftmend"), R("/cast [@mouseover,help][@player]Regrowth") },
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Starfire") },
})

Retail.RoninHeal_Resto_Wildstalk = Heal("RoninHeal_Resto_Wildstalk", 105, C_RD, {
    { R("/cast [@mouseover,help][@player]Swiftmend"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Lifebloom][@player,nobuff:Lifebloom]Lifebloom"), R("/cast [@mouseover,help][@player]Swiftmend") },
    { R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help][@player]Wild Growth"), R("/cast [@mouseover,help][@player]Regrowth") },
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Wrath") },
    { S("Nature's Swiftness", "c"), S("Convoke the Spirits", "c"), R("/cast [@mouseover,help][@player]Regrowth") },
}, { S("Barkskin", "c"), R("/cast [@mouseover,help][@player]Regrowth") }, "Restoration Druid, Wildstalker. Wildstalker hero tree (Symbiotic Bloom, Vigorous Creepers, Bursting Growth from Rejuvenation). Hover a frame and hold the key: Lifebloom and Rejuvenation only on friends that do not have them, Swiftmend and Wild Growth on cooldown, Moonfire and Sunfire kept up on your hostile target. Single target / spot healing macro, use the AoE macro for raid damage. Talents (import in game): Mythic+ / Delve / Leveling: CkGAAAAAAAAAAAAAAAAAAAAAAMMmZZMjZmxsN8ADzsYsZbGAAAAAAAAAAsMoZbGmmZMwsYmZmZZGegBAAAAgBAYGAACAAY2mZrZbmFbMzMwMzCoZAAmZAYA | Raid: CkGAAAAAAAAAAAAAAAAAAAAAAYMmZZmZMzMmthHYYmNjtxMAAAAAAAAAAYZQzmZMNzYYMLzMzMDDzAAAAAAAAAAIAAgZbmlmtZ2sxYmBmBoZAAmZAYA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Regrowth (friend under the mouse, otherwise you), Alt = Mighty Bash. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Lifebloom][@player,nobuff:Lifebloom]Lifebloom"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help][@player]Wild Growth"), R("/cast [@mouseover,help][@player]Swiftmend"), R("/cast [@mouseover,help][@player]Regrowth") },
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Wrath") },
})

Retail.RoninHeal_Resto_Wild_AoE = Heal("RoninHeal_Resto_Wild_AoE", 105, C_RD, {
    { R("/cast [@mouseover,help][@player]Wild Growth"), R("/cast [@mouseover,help][@player]Swiftmend") },
    { R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Lifebloom][@player,nobuff:Lifebloom]Lifebloom"), R("/cast [@mouseover,help][@player]Swiftmend") },
    { R("/cast [@player]Efflorescence"), R("/cast [@mouseover,help][@player]Wild Growth") },
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Wrath") },
    { S("Convoke the Spirits", "c"), S("Nature's Swiftness", "c"), R("/cast [@mouseover,help][@player]Regrowth") },
}, { S("Barkskin", "c"), R("/cast [@mouseover,help][@player]Regrowth") }, "Restoration Druid, Wildstalker. Wildstalker hero tree (Symbiotic Bloom, Vigorous Creepers, Bursting Growth from Rejuvenation). Hover a frame and hold the key: Lifebloom and Rejuvenation only on friends that do not have them, Swiftmend and Wild Growth on cooldown, Moonfire and Sunfire kept up on your hostile target. AoE macro: use it when the whole group takes damage. Talents (import in game): Mythic+ / Delve / Leveling: CkGAAAAAAAAAAAAAAAAAAAAAAMMmZZMjZmxsN8ADzsYsZbGAAAAAAAAAAsMoZbGmmZMwsYmZmZZGegBAAAAgBAYGAACAAY2mZrZbmFbMzMwMzCoZAAmZAYA | Raid: CkGAAAAAAAAAAAAAAAAAAAAAAYMmZZmZMzMmthHYYmNjtxMAAAAAAAAAAYZQzmZMNzYYMLzMzMDDzAAAAAAAAAAIAAgZbmlmtZ2sxYmBmBoZAAmZAYA. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Regrowth (friend under the mouse, otherwise you), Alt = Mighty Bash. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help][@player]Wild Growth"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Rejuvenation][@player,nobuff:Rejuvenation]Rejuvenation"), R("/cast [@mouseover,help][@player]Regrowth") },
    { R("/cast [@mouseover,help,nobuff:Lifebloom][@player,nobuff:Lifebloom]Lifebloom"), R("/cast [@mouseover,help][@player]Swiftmend"), R("/cast [@mouseover,help][@player]Regrowth") },
    { S("Moonfire", "s"), S("Sunfire", "s"), S("Starfire") },
})

Retail.RoninHeal_RShaman_Farseer = Heal("RoninHeal_RShaman_Farseer", 264, C_RS, {
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), S("Healing Stream Totem") },
    { R("/cast [@mouseover,help][@player]Unleash Life"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { R("/cast [@mouseover,help][@player]Healing Wave"), S("Lava Burst") },
    { S("Flame Shock", "s"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { S("Ancestral Swiftness", "c"), R("/cast [@mouseover,help][@player]Healing Wave") },
}, { S("Astral Shift", "c"), R("/cast [@mouseover,help][@player]Healing Wave") }, "Restoration Shaman, Farseer. Farseer hero tree (Ancestral Swiftness calls your Ancestors). Hover a frame and hold the key: Riptide only on friends that do not have it, Healing Stream Totem and Unleash Life on cooldown, Healing Wave as the single target heal (AoE macro: Chain Heal, Healing Rain at your feet). Single target / spot healing macro, use the AoE macro for raid damage. Talents (import in game): Raid: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsssNjZGjxYmhZWMzGMgBMbMBGLmhZYWGzMTz2yMziZMbsMjZGDmlBAAAmZGAMzADmB | Leveling: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsssNzMzMzMzYmhBjFYAAzCTgxCDwsNzY0stMzwMzgFzMzYglBAAAYGAMzgZgB. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Healing Wave (friend under the mouse, otherwise you), Alt = Capacitor Totem. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { S("Healing Stream Totem"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { S("Lava Burst"), S("Flame Shock", "s") },
})

Retail.RoninHeal_RSham_Far_AoE = Heal("RoninHeal_RSham_Far_AoE", 264, C_RS, {
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), S("Healing Stream Totem") },
    { R("/cast [@player]Healing Rain"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { R("/cast [@mouseover,help][@player]Unleash Life"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { R("/cast [@player]Healing Rain"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { S("Ancestral Swiftness", "c"), R("/cast [@mouseover,help][@player]Chain Heal") },
}, { S("Astral Shift", "c"), R("/cast [@mouseover,help][@player]Chain Heal") }, "Restoration Shaman, Farseer. Farseer hero tree (Ancestral Swiftness calls your Ancestors). Hover a frame and hold the key: Riptide only on friends that do not have it, Healing Stream Totem and Unleash Life on cooldown, Healing Wave as the single target heal (AoE macro: Chain Heal, Healing Rain at your feet). AoE macro: use it when the whole group takes damage. Talents (import in game): Raid: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsssNjZGjxYmhZWMzGMgBMbMBGLmhZYWGzMTz2yMziZMbsMjZGDmlBAAAmZGAMzADmB | Leveling: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsssNzMzMzMzYmhBjFYAAzCTgxCDwsNzY0stMzwMzgFzMzYglBAAAYGAMzgZgB. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Healing Wave (friend under the mouse, otherwise you), Alt = Capacitor Totem. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { R("/cast [@player]Healing Rain"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { S("Healing Stream Totem"), R("/cast [@mouseover,help][@player]Chain Heal") },
})

Retail.RoninHeal_RShaman_Totemic = Heal("RoninHeal_RShaman_Totemic", 264, C_RS, {
    { R("/cast [@player]Surging Totem"), R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide") },
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { S("Healing Stream Totem"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { S("Lava Burst"), S("Flame Shock", "s") },
    { S("Healing Stream Totem"), R("/cast [@mouseover,help][@player]Healing Wave") },
}, { S("Astral Shift", "c"), R("/cast [@mouseover,help][@player]Healing Wave") }, "Restoration Shaman, Totemic. Totemic hero tree (Surging Totem at your feet). Hover a frame and hold the key: Surging Totem and Riptide on cooldown, Healing Stream Totem, Healing Wave as the single target heal (AoE macro: Chain Heal, Healing Rain at your feet). Earth Shield on the tank stays yours. Single target / spot healing macro, use the AoE macro for raid damage. Talents (import in game): Mythic+ / Delve: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsstMzMzMjZGjZgFYDmxiGbDIzAbMzMY2mZMa2WmZ2MjZhFjZGDLzyAAAAzMDmZAgBzA | Raid: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsssNzMzYMzYmBjFYDmxmGbDgZgNzgBLjZmpZbZmZxMmF2m5BmZMYWGAAAYmZwMDAMYG | Leveling: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsssNzMzMzMzYmhBjFYAAzCTgxCDwsNzY0stMzwMzgFzMzYglBAAAYGAMzgZgB. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Healing Wave (friend under the mouse, otherwise you), Alt = Capacitor Totem. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { S("Healing Stream Totem"), R("/cast [@mouseover,help][@player]Healing Wave") },
    { S("Lava Burst"), S("Flame Shock", "s") },
})

Retail.RoninHeal_RSham_Tot_AoE = Heal("RoninHeal_RSham_Tot_AoE", 264, C_RS, {
    { R("/cast [@player]Surging Totem"), R("/cast [@player]Healing Rain"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), S("Healing Stream Totem") },
    { R("/cast [@player]Healing Rain"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { S("Healing Stream Totem"), R("/cast [@mouseover,help][@player]Chain Heal") },
}, { S("Astral Shift", "c"), R("/cast [@mouseover,help][@player]Chain Heal") }, "Restoration Shaman, Totemic. Totemic hero tree (Surging Totem at your feet). Hover a frame and hold the key: Surging Totem and Riptide on cooldown, Healing Stream Totem, Healing Wave as the single target heal (AoE macro: Chain Heal, Healing Rain at your feet). Earth Shield on the tank stays yours. AoE macro: use it when the whole group takes damage. Talents (import in game): Mythic+ / Delve: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsstMzMzMjZGjZgFYDmxiGbDIzAbMzMY2mZMa2WmZ2MjZhFjZGDLzyAAAAzMDmZAgBzA | Raid: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsssNzMzYMzYmBjFYDmxmGbDgZgNzgBLjZmpZbZmZxMmF2m5BmZMYWGAAAYmZwMDAMYG | Leveling: CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzsssNzMzMzMzYmhBjFYAAzCTgxCDwsNzY0stMzwMzgFzMzYglBAAAYGAMzgZgB. Tip: a talent loadout helper shows each talent of a string as you level. Keys: Shift = Healing Wave (friend under the mouse, otherwise you), Alt = Capacitor Totem. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns right at the pull), Raid (big healing cooldowns left to you, for the damage moments), Delve (solo: cooldowns early + one defensive), Beginner (one defensive included, cooldowns later), Leveling (basic spells, pick it by hand while you level to 90). Emergency cooldowns are never in the macro: use them by hand.", {
    { R("/cast [@mouseover,help,nobuff:Riptide][@player,nobuff:Riptide]Riptide"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { R("/cast [@player]Healing Rain"), R("/cast [@mouseover,help][@player]Chain Heal") },
    { S("Healing Stream Totem"), R("/cast [@mouseover,help][@player]Chain Heal") },
})

Retail.RoninHeal_Mist_Damage = Dmg("RoninHeal_Mist_Damage", 270, C_MWD, {
    { S("Rising Sun Kick"), S("Rushing Wind Kick"), R("/castsequence reset=8 Tiger Palm, Tiger Palm, Tiger Palm, Blackout Kick") },
    { S("Touch of Death"), R("/castsequence reset=8 Tiger Palm, Tiger Palm, Tiger Palm, Blackout Kick") },
    { S("Rising Sun Kick"), R("/castsequence reset=8 Tiger Palm, Tiger Palm, Tiger Palm, Blackout Kick") },
    { S("Spinning Crane Kick"), R("/castsequence reset=8 Tiger Palm, Tiger Palm, Tiger Palm, Blackout Kick") },
    { R("/cast [@mouseover,help,nobuff:Renewing Mist][@player,nobuff:Renewing Mist]Renewing Mist"), S("Blackout Kick") },
    { S("Thunder Focus Tea", "c"), S("Rising Sun Kick"), R("/castsequence reset=8 Tiger Palm, Tiger Palm, Tiger Palm, Blackout Kick") },
}, { S("Fortifying Brew", "c"), S("Tiger Palm") }, "Mistweaver Monk, DAMAGE macro (Delves, solo, leveling, or when nobody needs healing). Rising Sun Kick / Rushing Wind Kick on cooldown, Tiger Palm three times then Blackout Kick (Teachings of the Monastery), Touch of Death when it lights up, Thunder Focus Tea whenever it is ready, Spinning Crane Kick now and then for packs, Renewing Mist kept rolling. Talents: your healing build (import strings in the Notes of the heal macros). Keys: Shift = Vivify (friend under the mouse, otherwise you), Alt = Leg Sweep. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns at the pull), Raid (keeps your target), Delve (cooldowns early + one defensive), Beginner (one defensive, cooldowns later), Leveling (basic spells).", {
    { S("Rising Sun Kick"), R("/castsequence reset=8 Tiger Palm, Tiger Palm, Tiger Palm, Blackout Kick") },
    { S("Touch of Death"), R("/castsequence reset=8 Tiger Palm, Tiger Palm, Tiger Palm, Blackout Kick") },
    { S("Spinning Crane Kick"), R("/castsequence reset=8 Tiger Palm, Tiger Palm, Tiger Palm, Blackout Kick") },
})

Retail.RoninHeal_Holy_Damage = Dmg("RoninHeal_Holy_Damage", 65, C_HPD, {
    { S("Shield of the Righteous"), S("Holy Shock"), S("Judgment") },
    { S("Judgment"), S("Holy Shock"), S("Crusader Strike"), S("Consecration") },
    { S("Holy Shock"), S("Judgment"), S("Consecration") },
    { S("Shield of the Righteous"), S("Judgment"), S("Holy Shock") },
    { S("Holy Shock"), S("Judgment"), S("Crusader Strike") },
    { S("Avenging Wrath", "c"), S("Divine Toll", "c"), S("Holy Shock") },
}, { S("Divine Protection", "c"), S("Crusader Strike") }, "Holy Paladin, DAMAGE macro (Delves, solo, leveling, or when nobody needs healing). Holy Shock and Judgment on the enemy build Holy Power, Shield of the Righteous spends it, Consecration at your feet, Avenging Wrath with Divine Toll (Judgment turns into Hammer of Wrath, Crusader Strike comes back with Avenging Crusader). Talents: your healing build (import strings in the Notes of the heal macros). Keys: Shift = Flash of Light (friend under the mouse, otherwise you), Alt = Hammer of Justice. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns at the pull), Raid (keeps your target), Delve (cooldowns early + one defensive), Beginner (one defensive, cooldowns later), Leveling (basic spells).", {
    { S("Holy Shock"), S("Judgment"), S("Consecration") },
    { S("Shield of the Righteous"), S("Judgment"), S("Holy Shock") },
    { S("Holy Shock"), S("Judgment") },
})

Retail.RoninHeal_Resto_Damage = Dmg("RoninHeal_Resto_Damage", 105, C_RDD, {
    { S("Rake", "s"), S("Shred") },
    { R("/castsequence reset=8 Shred, Shred, Shred, Rip, Shred, Shred, Shred, Ferocious Bite"), S("Shred") },
    { S("Sunfire", "s"), S("Shred") },
    { R("/castsequence reset=8 Shred, Shred, Shred, Rip, Shred, Shred, Shred, Ferocious Bite"), S("Thrash") },
    { S("Thrash"), S("Swipe"), S("Shred") },
    { S("Heart of the Wild", "c"), S("Convoke the Spirits", "c"), S("Shred") },
}, { S("Barkskin", "c"), S("Shred") }, "Restoration Druid, DAMAGE macro (Delves, solo, leveling, or when nobody needs healing). Shifts into Cat Form by itself: Rake once per target, Shred builds combo points, Rip then Ferocious Bite only after three Shreds, Sunfire woven in once per target (the next press goes back to Cat Form), Thrash and Swipe for packs, Heart of the Wild with Convoke the Spirits. Shift = Regrowth leaves Cat Form, the next press goes back in. Talents: your healing build (import strings in the Notes of the heal macros). Keys: Shift = Regrowth (friend under the mouse, otherwise you), Alt = Mighty Bash. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns at the pull), Raid (keeps your target), Delve (cooldowns early + one defensive), Beginner (one defensive, cooldowns later), Leveling (basic spells).", {
    { S("Rake", "s"), S("Shred") },
    { R("/castsequence reset=8 Shred, Shred, Shred, Rip, Shred, Shred, Shred, Ferocious Bite"), S("Shred") },
    { S("Thrash"), S("Swipe"), S("Shred") },
})

Retail.RoninHeal_RShaman_Damage = Dmg("RoninHeal_RShaman_Damage", 264, C_RSD, {
    { S("Flame Shock", "s"), S("Lava Burst"), S("Lightning Bolt") },
    { R("/cast [@cursor]Healing Rain"), S("Lava Burst"), S("Chain Lightning") },
    { S("Lava Burst"), S("Lightning Bolt") },
    { S("Flame Shock", "s"), S("Chain Lightning") },
    { S("Lava Burst"), S("Lightning Bolt") },
    { S("Ancestral Swiftness", "c"), S("Lava Burst"), S("Lightning Bolt") },
}, { S("Astral Shift", "c"), S("Lightning Bolt") }, "Restoration Shaman, DAMAGE macro (Delves, solo, leveling, or when nobody needs healing). Flame Shock once per target, Lava Burst on cooldown, Lightning Bolt to fill, Healing Rain at your cursor (with Acid Rain it hits the enemies) and Chain Lightning for packs. Talents: your healing build (import strings in the Notes of the heal macros). Keys: Shift = Healing Wave (friend under the mouse, otherwise you), Alt = Capacitor Totem. Interrupt: bind it on a separate key. Versions: Mythic+ (cooldowns at the pull), Raid (keeps your target), Delve (cooldowns early + one defensive), Beginner (one defensive, cooldowns later), Leveling (basic spells).", {
    { S("Flame Shock", "s"), S("Lava Burst"), S("Lightning Bolt") },
    { R("/cast [@cursor]Healing Rain"), S("Chain Lightning") },
    { S("Lava Burst"), S("Lightning Bolt") },
})

Ronin.RetailHealSequences = Retail
