--[[
    Ronin - one add-on for both worlds (Retail + WoW: Forever)
    Ronin - GSE SUITE: Tank, DPS and Heal macros for GSE. Type /ronin to open the installer.
    Welcome screen -> pick Retail or Forever -> installer -> thank-you panel.
    Resizable: drag the bottom-right corner.
]]

local addonName, Ronin = ...

-- WoW loads SavedVariables AFTER this file runs, so DB is bound to RoninDB on ADDON_LOADED.
local DB = {}
do
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, event, name)
        if name ~= addonName then return end
        if type(RoninDB) ~= "table" then RoninDB = {} end
        for k, v in pairs(DB) do
            if k == "imported" and type(RoninDB.imported) == "table" then
                for kk, vv in pairs(v) do RoninDB.imported[kk] = vv end
            elseif RoninDB[k] == nil then
                RoninDB[k] = v
            end
        end
        DB = RoninDB
        self:UnregisterEvent("ADDON_LOADED")
    end)
end

local ADDON_VERSION = "4.4.0-beta2"
local MEDIA = "Interface\\AddOns\\Ronin\\Media\\"
local WHITE = "Interface\\Buttons\\WHITE8x8"

local ACCENT = "|cff00e5cc"
local GOLD   = "|cffe0b84a"
local GREEN  = "|cff7cfc00"
local RED    = "|cffff5555"
local DIM    = "|cff9aa5b8"
local VIOLET = "|cffb48cff"

local C = {
    bg     = { 0.035, 0.050, 0.095, 0.985 },
    row    = { 0.050, 0.070, 0.120, 0.95 },
    gold   = { 0.82, 0.65, 0.24, 1 },
    cyanDim= { 0.00, 0.45, 0.50, 0.55 },
}

local LINKS = {
    { "CurseForge", "https://www.curseforge.com/wow/addons/ronin" },
    { "Ko-fi",   "https://ko-fi.com/ron1n90c" },
    { "Website", "https://ron1n.cc" },
    { "Patreon", "https://www.patreon.com/RON1N90C" },
}

local THANKS = "|cffffd100Hi, I'm Ron1n. I really hope U enjoy my Macros :)|r\nI hope I could help you get a little closer to enjoying Azeroth, whether you play solo, with family or push hard content. See U in Azeroth!\n\n|cffffd100Made by a tank, for every tank.|r\nNo macro plays the game for you: mechanics and positioning are still yours.\nMay your cooldowns be ready and every pull end with the whole group standing.\n\n"
    .. "These macros are free. A coffee, a follow or a share keeps the updates coming. Thank you."

local KEYS_RETAIL = "|cff00e5ccYour keys (Retail)|r\n"
    .. "|cffffd100Shift|r  heal / self-sustain\n"
    .. "|cffffd100Alt|r  crowd control (stun)\n"
    .. "Interrupt: bind it on a separate key.\n"
    .. "DPS and Heal: every spec also has a separate AoE macro.\n"
    .. "Versions: Mythic+ = cooldowns at the pull, Raid = keeps your target (Heal: big cooldowns are yours), Delve = solo + one defensive, Beginner = one defensive + calmer cooldowns, Leveling = basic spells.\n"
    .. "Heal: hover a frame and hold the key, it heals the friend under your mouse, otherwise you. Emergency cooldowns stay in your hands.\n"
    .. "Leveling: every macro has a |cffffd100Leveling|r version for the way to 90 (pick it in GSE).\n\n"
    .. "Hold the button: the Priority list picks the spell."
local KEYS_FOREVER = "|cff00e5ccYour keys (WoW: Forever)|r\n"
    .. "|cffffd100Shift|r  heal\n"
    .. "|cffffd100Ctrl|r  interrupt (Paladin: Hammer of Justice, Warrior: Shield Bash / Pummel)\n"
    .. "|cffffd100Alt|r  class extra (Consecration, totems, Concussion Blow, Bash, Rain of Fire, Frost Nova)\n"
    .. "Tank and DPS for every class, Heal for Paladin, Druid, Shaman and Priest (hover a frame and hold the key, it heals the friend under your mouse, otherwise you). "
    .. "Pick your level range in GSE: 1-10, 10-40 or 40-60."
local BLESS = "|cffffd100From one tank to another:|r\nmay Azeroth watch over you, may your cooldowns be ready\nand may every pull end with the whole group standing.\n\n"
local THANKS_BY = {
    retail  = BLESS .. KEYS_RETAIL,
    forever = BLESS .. KEYS_FOREVER,
}

local function Print(msg)
    print(ACCENT .. "[Ronin]|r " .. tostring(msg))
end

local function IsRetailClient()
    if WOW_PROJECT_ID and WOW_PROJECT_MAINLINE then
        return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
    end
    return (tonumber((select(4, GetBuildInfo()))) or 0) >= 100000
end

-- ---------------------------------------------------------------------------
-- The two packs
-- ---------------------------------------------------------------------------

local PACKS = {
    retail = {
        key = "retail", world = "retail", name = "Retail", version = "7.3.4",
        sub = "Midnight 12.0",
        seqs = Ronin.RetailSequences or {},
        regkey = "RoninRetail",
        art = "W",
        groups = {
            { name = "Protection Warrior", color = "|cffc69b6d", sub = "Mountain Thane  |  Colossus", seqs = { "RoninWarrior_Thane", "RoninWarrior_Colossus" }, specID = 73 },
            { name = "Protection Paladin", color = "|cfff48cba", sub = "Lightsmith  |  Templar", seqs = { "RoninPaladin_Lightsmith", "RoninPaladin_Templar" }, specID = 66 },
            { name = "Guardian Druid", color = "|cffff7c0a", sub = "Elune's Chosen  |  Druid of the Claw", seqs = { "RoninDruid_Elune", "RoninDruid_Claw" }, specID = 104 },
            { name = "Brewmaster Monk", color = "|cff00ff98", sub = "Master of Harmony  |  Shado-Pan", seqs = { "RoninBrewmaster_Harmony", "RoninBrewmaster_ShadoPan" }, specID = 268 },
            { name = "Vengeance Demon Hunter", color = "|cffa330c9", sub = "Aldrachi Reaver  |  Annihilator", seqs = { "RoninDH_Vengeance_Aldrachi", "RoninDH_Vengeance_Annihil" }, specID = 581 },
            { name = "Blood Death Knight", color = "|cffc41e3a", sub = "Deathbringer  |  San'layn", seqs = { "RoninDK_Blood_Deathbringer", "RoninDK_Blood_Sanlayn" }, specID = 250 },
        },
    },
    forever = {
        key = "forever", world = "forever", name = "Forever", version = "4.1.2",
        sub = "WoW: Forever",
        seqs = Ronin.ForeverSequences or {},
        regkey = "RoninForever",
        art = "infinity",
        groups = {
            { name = "Protection Warrior", color = "|cffc69b6d", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninForever_Warrior" }, icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance" },
            { name = "Protection Paladin", color = "|cfff48cba", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninForever_Paladin" }, icon = "Interface\\Icons\\Spell_Holy_DevotionAura" },
            { name = "Feral Druid (Bear)", color = "|cffff7c0a", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninForever_Druid" }, icon = "Interface\\Icons\\Ability_Racial_BearForm" },
        },
    },
}

local SUBPACKS = {}
local function SubPack(base, role, label, seqs, groups)
    local sp = {
        key = base.key .. "_" .. role, world = base.key,
        name = base.name .. " " .. label, sub = label .. " macros",
        version = base.version, seqs = seqs or {}, regkey = base.regkey .. "_" .. role,
        art = base.art, groups = groups,
    }
    SUBPACKS[sp.key] = sp
    PACKS[sp.key] = sp
end
SubPack(PACKS.retail, "dps", "DPS", Ronin.RetailDPSSequences, {
            { name = "Unholy Death Knight", color = "|cffc41e3a", sub = "Rider  |  San'layn  (+ AoE)", seqs = { "RoninDPS_DK_Unholy_Rider", "RoninDPS_DK_Unh_Rider_AoE", "RoninDPS_DK_Unholy_Sanlayn", "RoninDPS_DK_Unh_Sanlayn_AoE" }, specID = 252 },
            { name = "Frost Death Knight", color = "|cffc41e3a", sub = "Deathbringer  |  Rider  (+ AoE)", seqs = { "RoninDPS_DK_Frost_Deathbr", "RoninDPS_DK_Frost_Dbr_AoE", "RoninDPS_DK_Frost_Rider", "RoninDPS_DK_Frost_Rider_AoE" }, specID = 251 },
            { name = "Havoc Demon Hunter", color = "|cffa330c9", sub = "Aldrachi Reaver  |  Fel-Scarred  (+ AoE)", seqs = { "RoninDPS_DH_Havoc_Aldrachi", "RoninDPS_DH_Hav_Aldr_AoE", "RoninDPS_DH_Havoc_FelScarred", "RoninDPS_DH_Hav_Fel_AoE" }, specID = 577 },
            { name = "Devourer Demon Hunter", color = "|cffa330c9", sub = "Annihilator  |  Void-Scarred  (+ AoE)", seqs = { "RoninDPS_DH_Devourer_Annih", "RoninDPS_DH_Dev_Annih_AoE", "RoninDPS_DH_Dev_VoidScar", "RoninDPS_DH_Dev_VScar_AoE" }, specID = 1480 },
            { name = "Feral Druid", color = "|cffff7c0a", sub = "Wildstalker  (+ AoE)", seqs = { "RoninDPS_Feral_Wildstalker", "RoninDPS_Feral_Wild_AoE" }, specID = 103 },
            { name = "Balance Druid", color = "|cffff7c0a", sub = "Keeper of the Grove  |  Elune's Chosen  (+ AoE)", seqs = { "RoninDPS_Balance_Keeper", "RoninDPS_Bal_Keeper_AoE", "RoninDPS_Balance_Elune", "RoninDPS_Bal_Elune_AoE" }, specID = 102 },
            { name = "Beast Mastery Hunter", color = "|cffaad372", sub = "Pack Leader  |  Dark Ranger  (+ AoE)", seqs = { "RoninDPS_BM_PackLeader", "RoninDPS_BM_PackLeader_AoE", "RoninDPS_BM_DarkRanger", "RoninDPS_BM_DarkRanger_AoE" }, specID = 253 },
            { name = "Marksmanship Hunter", color = "|cffaad372", sub = "Dark Ranger  |  Sentinel  (+ AoE)", seqs = { "RoninDPS_MM_DarkRanger", "RoninDPS_MM_DarkRanger_AoE", "RoninDPS_MM_Sentinel", "RoninDPS_MM_Sentinel_AoE" }, specID = 254 },
            { name = "Survival Hunter", color = "|cffaad372", sub = "Pack Leader  |  Sentinel  (+ AoE)", seqs = { "RoninDPS_SV_PackLeader", "RoninDPS_SV_PackLeader_AoE", "RoninDPS_SV_Sentinel", "RoninDPS_SV_Sentinel_AoE" }, specID = 255 },
            { name = "Arcane Mage", color = "|cff3fc7eb", sub = "Spellslinger  |  Sunfury  (+ AoE)", seqs = { "RoninDPS_Arc_Spellslinger", "RoninDPS_Arc_Spell_AoE", "RoninDPS_Arc_Sunfury", "RoninDPS_Arc_Sun_AoE" }, specID = 62 },
            { name = "Fire Mage", color = "|cff3fc7eb", sub = "Frostfire  |  Sunfury  (+ AoE)", seqs = { "RoninDPS_Fire_Frostfire", "RoninDPS_Fire_FF_AoE", "RoninDPS_Fire_Sunfury", "RoninDPS_Fire_Sun_AoE" }, specID = 63 },
            { name = "Frost Mage", color = "|cff3fc7eb", sub = "Spellslinger  |  Frostfire  (+ AoE)", seqs = { "RoninDPS_Frost_Spellslinger", "RoninDPS_Frost_Spell_AoE", "RoninDPS_Frost_Frostfire", "RoninDPS_Frost_FF_AoE" }, specID = 64 },
            { name = "Windwalker Monk", color = "|cff00ff98", sub = "Shado-Pan  |  Conduit  (+ AoE)", seqs = { "RoninDPS_Monk_WW_ShadoPan", "RoninDPS_Monk_WW_SPan_AoE", "RoninDPS_Monk_WW_Conduit", "RoninDPS_Monk_WW_Cond_AoE" }, specID = 269 },
            { name = "Retribution Paladin", color = "|cfff48cba", sub = "Herald of the Sun  |  Templar  (+ AoE)", seqs = { "RoninDPS_Paladin_Ret_Herald", "RoninDPS_Pal_Ret_Herald_AoE", "RoninDPS_Paladin_Ret_Templar", "RoninDPS_Pal_Ret_Templar_AoE" }, specID = 70 },
            { name = "Elemental Shaman", color = "|cff0070dd", sub = "Farseer  |  Stormbringer  (+ AoE)", seqs = { "RoninDPS_Ele_Farseer", "RoninDPS_Ele_Farseer_AoE", "RoninDPS_Ele_Stormbringer", "RoninDPS_Ele_Storm_AoE" }, specID = 262 },
            { name = "Enhancement Shaman", color = "|cff0070dd", sub = "Stormbringer  |  Totemic  (+ AoE)", seqs = { "RoninDPS_Enh_Stormbringer", "RoninDPS_Enh_Storm_AoE", "RoninDPS_Enh_Totemic", "RoninDPS_Enh_Totemic_AoE" }, specID = 263 },
            { name = "Affliction Warlock", color = "|cff8788ee", sub = "Hellcaller  |  Soul Harvester  (+ AoE)", seqs = { "RoninDPS_Aff_Hellcaller", "RoninDPS_Aff_Hellcaller_AoE", "RoninDPS_Aff_SoulHarvester", "RoninDPS_Aff_SoulHarv_AoE" }, specID = 265 },
            { name = "Demonology Warlock", color = "|cff8788ee", sub = "Diabolist  |  Soul Harvester  (+ AoE)", seqs = { "RoninDPS_Demo_Diabolist", "RoninDPS_Demo_Diab_AoE", "RoninDPS_Demo_SoulHarvester", "RoninDPS_Demo_SoulH_AoE" }, specID = 266 },
            { name = "Destruction Warlock", color = "|cff8788ee", sub = "Hellcaller  |  Diabolist  (+ AoE)", seqs = { "RoninDPS_Destro_Hellcaller", "RoninDPS_Destro_Hell_AoE", "RoninDPS_Destro_Diabolist", "RoninDPS_Destro_Diab_AoE" }, specID = 267 },
            { name = "Fury Warrior", color = "|cffc69b6d", sub = "Slayer  |  Mountain Thane  (+ AoE)", seqs = { "RoninDPS_Fury_Slayer", "RoninDPS_Fury_Slayer_AoE", "RoninDPS_Fury_Thane", "RoninDPS_Fury_Thane_AoE" }, specID = 72 },
            { name = "Arms Warrior", color = "|cffc69b6d", sub = "Slayer  |  Colossus  (+ AoE)", seqs = { "RoninDPS_Arms_Slayer", "RoninDPS_Arms_Slayer_AoE", "RoninDPS_Arms_Colossus", "RoninDPS_Arms_Colossus_AoE" }, specID = 71 },
})
SubPack(PACKS.retail, "heal", "Heal", Ronin.RetailHealSequences, {
            { name = "Restoration Druid", color = "|cffff7c0a", sub = "Keeper of the Grove  |  Wildstalker  (+ AoE, + Damage)", seqs = { "RoninHeal_Resto_Keeper", "RoninHeal_Resto_Keeper_AoE", "RoninHeal_Resto_Wildstalk", "RoninHeal_Resto_Wild_AoE", "RoninHeal_Resto_Damage" }, specID = 105 },
            { name = "Mistweaver Monk", color = "|cff00ff98", sub = "Conduit  |  Harmony  (+ AoE, + Damage)", seqs = { "RoninHeal_Mist_Conduit", "RoninHeal_Mist_Cond_AoE", "RoninHeal_Mist_Harmony", "RoninHeal_Mist_Harm_AoE", "RoninHeal_Mist_Damage" }, specID = 270 },
            { name = "Holy Paladin", color = "|cfff48cba", sub = "Herald of the Sun  |  Lightsmith  (+ AoE, + Damage)", seqs = { "RoninHeal_Holy_Herald", "RoninHeal_Holy_Herald_AoE", "RoninHeal_Holy_Lightsmith", "RoninHeal_Holy_Light_AoE", "RoninHeal_Holy_Damage" }, specID = 65 },
            { name = "Restoration Shaman", color = "|cff0070dd", sub = "Farseer  |  Totemic  (+ AoE, + Damage)", seqs = { "RoninHeal_RShaman_Farseer", "RoninHeal_RSham_Far_AoE", "RoninHeal_RShaman_Totemic", "RoninHeal_RSham_Tot_AoE", "RoninHeal_RShaman_Damage" }, specID = 264 },
})
SubPack(PACKS.forever, "dps", "DPS", Ronin.ForeverDPSSequences, {
            { name = "Feral Druid (Cat)", color = "|cffff7c0a", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Druid_Cat" }, icon = "Interface\\Icons\\Ability_Druid_CatForm" },
            { name = "Balance Druid", color = "|cffff7c0a", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Druid_Balance" }, icon = "Interface\\Icons\\Spell_Nature_StarFall" },
            { name = "Hunter", color = "|cffaad372", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Hunter" }, icon = "Interface\\Icons\\INV_Weapon_Bow_07" },
            { name = "Arcane Mage", color = "|cff3fc7eb", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Mage_Arcane" }, icon = "Interface\\Icons\\Spell_Holy_MagicalSentry" },
            { name = "Fire Mage", color = "|cff3fc7eb", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Mage_Fire" }, icon = "Interface\\Icons\\Spell_Fire_FlameBolt" },
            { name = "Frost Mage", color = "|cff3fc7eb", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Mage_Frost" }, icon = "Interface\\Icons\\Spell_Frost_FrostBolt02" },
            { name = "Retribution Paladin", color = "|cfff48cba", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Paladin_Ret" }, icon = "Interface\\Icons\\Spell_Holy_AuraOfLight" },
            { name = "Priest (Damage)", color = "|cffffffff", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Priest" }, icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain" },
            { name = "Enhancement Shaman", color = "|cff0070dd", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Shaman_Enh" }, icon = "Interface\\Icons\\Spell_Nature_LightningShield" },
            { name = "Elemental Shaman", color = "|cff0070dd", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Shaman_Ele" }, icon = "Interface\\Icons\\Spell_Nature_Lightning" },
            { name = "Affliction Warlock", color = "|cff8788ee", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Warlock_Aff" }, icon = "Interface\\Icons\\Spell_Shadow_DeathCoil" },
            { name = "Demonology Warlock", color = "|cff8788ee", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Warlock_Demo" }, icon = "Interface\\Icons\\Spell_Shadow_Metamorphosis" },
            { name = "Destruction Warlock", color = "|cff8788ee", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Warlock_Destro" }, icon = "Interface\\Icons\\Spell_Shadow_RainOfFire" },
            { name = "Arms Warrior", color = "|cffc69b6d", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Warrior" }, icon = "Interface\\Icons\\Ability_Warrior_OffensiveStance" },
            { name = "Fury Warrior", color = "|cffc69b6d", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFDPS_Warrior_Fury" }, icon = "Interface\\Icons\\Ability_Warrior_InnerRage" },
})
SubPack(PACKS.forever, "heal", "Heal", Ronin.ForeverHealSequences, {
            { name = "Restoration Druid", color = "|cffff7c0a", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFHeal_Druid" }, icon = "Interface\\Icons\\Spell_Nature_HealingTouch" },
            { name = "Holy Paladin", color = "|cfff48cba", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFHeal_Paladin" }, icon = "Interface\\Icons\\Spell_Holy_HolyBolt" },
            { name = "Holy Priest", color = "|cffffffff", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFHeal_Priest" }, icon = "Interface\\Icons\\Spell_Holy_FlashHeal" },
            { name = "Restoration Shaman", color = "|cff0070dd", sub = "Level 1-10  |  10-40  |  40-60", seqs = { "RoninFHeal_Shaman" }, icon = "Interface\\Icons\\Spell_Nature_HealingWaveGreater" },
})

Ronin.Sequences = {}
local PACK_OF = {}
for pk, pack in pairs(PACKS) do
    for name, seq in pairs(pack.seqs) do
        Ronin.Sequences[name] = seq
        PACK_OF[name] = pack
    end
end

-- ---------------------------------------------------------------------------
-- Finding what GSE already has (GSE changed how it stores sequences, so every
-- way we know is tried; a probe that is missing is never a "not installed")
-- ---------------------------------------------------------------------------

local function EnsureGSE()
    return type(GSE) == "table"
        and (type(GSE.ImportSerialisedSequence) == "function" or type(GSE.RegisterAddon) == "function")
end

-- returns found (true / false / nil = no way to look), sequence table (or nil)
local function Lookup(name)
    if type(GSE) ~= "table" then return nil end
    local probed = false

    if type(GSE.FindSequenceId) == "function" then
        probed = true
        -- GSE cuts names to 28 characters, so a long name is also tried cut
        local ok, id, cid = pcall(GSE.FindSequenceId, name, nil, true)
        if ok and id == nil and #name > 28 then
            ok, id, cid = pcall(GSE.FindSequenceId, name:sub(1, 28), nil, true)
        end
        if ok and id ~= nil then
            local seq
            if type(GSE.GetSequence) == "function" then
                local ok2, s = pcall(GSE.GetSequence, id, cid)
                if ok2 and type(s) == "table" then seq = s end
            end
            if not seq and cid ~= nil and type(GSE.Library) == "table" and type(GSE.Library[cid]) == "table" then
                seq = GSE.Library[cid][id]
            end
            return true, seq
        end
    end

    if type(GSE.Library) == "table" then
        probed = true
        for _, t in pairs(GSE.Library) do
            if type(t) == "table" and type(t[name]) == "table" then return true, t[name] end
        end
    end

    if type(GSEStore) == "table" and type(GSEStore.sequence) == "table" then
        probed = true
        for _, envs in pairs(GSEStore.sequence) do
            if type(envs) == "table" then
                for _, env in pairs(envs) do
                    if type(env) == "table" and env.Name == name then return true, nil end
                end
            end
        end
    end

    if type(GSESequences) == "table" then
        probed = true
        for _, t in pairs(GSESequences) do
            if type(t) == "table" and t[name] ~= nil then
                local v = t[name]
                return true, type(v) == "table" and v or nil
            end
        end
    end

    if probed then return false end
    return nil
end

-- Fingerprint of a sequence = hash of all macro texts in order
local function Collect(node, out, depth)
    if type(node) ~= "table" or depth > 14 then return end
    if type(node.macro) == "string" then out[#out + 1] = node.macro end
    local keys = {}
    for k in pairs(node) do
        if type(k) == "number" then keys[#keys + 1] = k end
    end
    table.sort(keys)
    for _, k in ipairs(keys) do Collect(node[k], out, depth + 1) end
end

local function Fingerprint(seq)
    if type(seq) ~= "table" or type(seq.Versions) ~= "table" then return nil end
    local vk, out = {}, {}
    for k in pairs(seq.Versions) do
        if type(k) == "number" then vk[#vk + 1] = k end
    end
    table.sort(vk)
    for _, k in ipairs(vk) do
        out[#out + 1] = "V" .. k
        local v = seq.Versions[k]
        if type(v) == "table" then Collect(v.Actions, out, 0) end
    end
    if #out == 0 then return nil end
    local str = table.concat(out, "\n")
    local h = 5381
    for i = 1, #str do h = (h * 33 + str:byte(i)) % 4294967296 end
    return string.format("%08x", h) .. ":" .. #str
end

-- GSE stores an import later, from its out-of-combat queue (about 7 s, longer in combat).
-- So an import is first "pending": we keep what GSE had before, and the first time GSE shows
-- something different we take that as the stored Ronin version (rec.lib). Records from before
-- this (no rec.s) never mark a sequence as "edited", because their rec.lib may be too early.
local REC_SCHEMA = 2
local PENDING_MAX = 1800   -- seconds; after that a pending import is taken as stored

local function Settle(rec, cur)
    if not rec.pending then return end
    local now = type(time) == "function" and time() or 0
    if cur and cur ~= rec.old then
        rec.lib, rec.pending, rec.old = cur, nil, nil
    elseif cur and now - (rec.t or now) > PENDING_MAX then
        rec.lib, rec.pending, rec.old = cur, nil, nil
    end
end

-- "none" | "current" | "present" | "old" | "modified" | "mineold" | "other"
local function StatusOf(key)
    local found, lib = Lookup(key)
    if found == false then return "none" end
    local pkg = Fingerprint(Ronin.Sequences[key])
    local rec = DB.imported and DB.imported[key]
    local cur = Fingerprint(lib)
    if rec then Settle(rec, cur) end
    local trusted = rec and rec.s == REC_SCHEMA and not rec.pending and rec.lib ~= nil
    local edited = trusted and cur ~= nil and cur ~= rec.lib
    if cur and pkg and cur == pkg then return "current" end
    if rec and pkg and rec.fp == pkg then
        if edited then return "modified" end
        return "current"
    end
    if found == nil and not rec then return "none" end
    if rec then
        if edited then return "mineold", rec.v end   -- you changed it and Ronin has a new version: yours stays
        return "old", rec.v
    end
    if cur then return "other" end
    return "present"
end
Ronin.StatusOf = StatusOf

-- what GSE has right now (taken BEFORE an import)
local function Snapshot(keys)
    local before = {}
    for _, key in ipairs(keys) do
        local _, lib = Lookup(key)
        before[key] = Fingerprint(lib) or "none"
    end
    return before
end

local function RecordImport(keys, before)
    DB.imported = DB.imported or {}
    local now = type(time) == "function" and time() or 0
    for _, key in ipairs(keys) do
        local rec = {
            v = PACK_OF[key] and PACK_OF[key].version or ADDON_VERSION,
            fp = Fingerprint(Ronin.Sequences[key]),
            old = before and before[key] or "none",
            pending = true, t = now, s = REC_SCHEMA,
        }
        local _, lib = Lookup(key)
        Settle(rec, Fingerprint(lib))   -- GSE may already have stored it
        DB.imported[key] = rec
    end
end

-- ---------------------------------------------------------------------------
-- Import logic
-- ---------------------------------------------------------------------------

local function DeepCopy(t)
    if type(t) ~= "table" then return t end
    local c = {}
    for k, v in pairs(t) do c[k] = DeepCopy(v) end
    return c
end

function Ronin.Sign(name)
    local h1, h2 = 5381, 52711
    local str = "Ron1n90c|RONIN-GSE-SUITE|" .. tostring(name)
    for i = 1, #str do
        local c = string.byte(str, i)
        h1 = (h1 * 33 + c) % 4294967296
        h2 = (h2 * 31 + c * i) % 4294967296
    end
    return string.format("R1N-%08X%08X", h1, h2)
end

function Ronin.InstallBatch(keys, overwrite, regkey)
    local gseVersion = tonumber(GSE.VersionNumber) or 3400
    local toc = tonumber((select(4, GetBuildInfo())))
    local members, names = {}, {}
    for _, key in ipairs(keys) do
        local src = Ronin.Sequences[key]
        if src then
            local seq = DeepCopy(src)
            seq.MetaData.GSEVersion = gseVersion
            seq.MetaData.TOC = toc
            -- authorship mark (invisible in game, does not change the macro)
            local sig = Ronin.Sign(key)
            seq.MetaData.RoninSig = sig
            if type(seq.Versions) == "table" then
                for _, ver in pairs(seq.Versions) do
                    if type(ver) == "table" then ver.RoninSig = sig end
                end
            end
            members[key] = seq
            names[#names + 1] = key
        end
    end
    if #names == 0 then
        return false, "no matching sequences"
    end

    local collection = { type = "COLLECTION", payload = { Sequences = members } }

    if type(GSE.ImportSerialisedSequence) == "function" then
        local ok, err = pcall(GSE.ImportSerialisedSequence, collection, overwrite and true or false)
        if not ok then return false, err end
        return true
    end

    local ok, res = pcall(GSE.RegisterAddon, regkey, ADDON_VERSION .. "-" .. tostring(time()), names, { collection })
    if not ok then return false, res end
    return true
end

-- ---------------------------------------------------------------------------
-- UI helpers (every call that might not exist on one client is wrapped)
-- ---------------------------------------------------------------------------

local function clamp(v, lo, hi)
    if v < lo then return lo elseif v > hi then return hi end
    return v
end

local function NewGroup(region, looping)
    local ok, ag = pcall(region.CreateAnimationGroup, region)
    if not ok or not ag then return nil end
    if looping then pcall(ag.SetLooping, ag, looping) end
    return ag
end

local function AddAnim(ag, kind, order, duration, setup)
    if not ag then return nil end
    local ok, a = pcall(ag.CreateAnimation, ag, kind)
    if not ok or not a then return nil end
    pcall(a.SetOrder, a, order)
    pcall(a.SetDuration, a, duration)
    if setup then pcall(setup, a) end
    return a
end

local function PlayGroup(ag) if ag then pcall(ag.Play, ag) end end

local function Pulse(region, from, to, dur)
    local ag = NewGroup(region, "BOUNCE")
    AddAnim(ag, "Alpha", 1, dur, function(a)
        a:SetFromAlpha(from); a:SetToAlpha(to); a:SetSmoothing("IN_OUT")
    end)
    PlayGroup(ag)
    return ag
end

local function Float(region, dy, dur)
    local ag = NewGroup(region, "BOUNCE")
    AddAnim(ag, "Translation", 1, dur, function(a)
        a:SetOffset(0, dy); a:SetSmoothing("IN_OUT")
    end)
    PlayGroup(ag)
    return ag
end

local function Spin(region, seconds)
    local ag = NewGroup(region, "REPEAT")
    AddAnim(ag, "Rotation", 1, seconds, function(a)
        a:SetDegrees(-360); a:SetOrigin("CENTER", 0, 0)
    end)
    PlayGroup(ag)
    return ag
end

local function FadeIn(frame)
    local ag = NewGroup(frame)
    AddAnim(ag, "Alpha", 1, 0.30, function(a)
        a:SetFromAlpha(0); a:SetToAlpha(1); a:SetSmoothing("OUT")
    end)
    return ag
end

local function MakeButton(parent, text, w, h, primary)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(w, h)
    b:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    local base  = primary and { 0.46, 0.34, 0.08, 1 } or { 0.07, 0.11, 0.19, 1 }
    local hover = primary and { 0.62, 0.47, 0.12, 1 } or { 0.10, 0.17, 0.28, 1 }
    local edge  = primary and C.gold or C.cyanDim
    b:SetBackdropColor(unpack(base))
    b:SetBackdropBorderColor(unpack(edge))
    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("CENTER", 0, 0)
    fs:SetText(text)
    fs:SetTextColor(primary and 1 or 0.78, primary and 0.92 or 0.95, primary and 0.70 or 1)
    b.label = fs
    b:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(hover))
        self:SetBackdropBorderColor(0.0, 0.9, 0.85, 1)
    end)
    b:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(base))
        self:SetBackdropBorderColor(unpack(edge))
    end)
    b:SetScript("OnMouseDown", function(self) self.label:SetPoint("CENTER", 0, -1) end)
    b:SetScript("OnMouseUp", function(self) self.label:SetPoint("CENTER", 0, 0) end)
    return b
end

local function GroupIcon(g)
    if g.specID and type(GetSpecializationInfoByID) == "function" then
        local ok, _, _, _, icon = pcall(GetSpecializationInfoByID, g.specID)
        if ok and icon then return icon end
    end
    return g.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- the art of a world: Retail = violet W, Forever = glowing infinity (additive, black = transparent)
local function MakeArt(parent, pack, layer)
    local t = parent:CreateTexture(nil, layer or "ARTWORK")
    t:SetBlendMode("ADD")
    if pack.art == "W" then
        t:SetTexture(MEDIA .. "W.tga")
        t.ratio = 1
    else
        t:SetTexture(MEDIA .. "Infinity.tga")
        t.ratio = 2
    end
    return t
end

local function MakeHalo(parent, pack)
    local h = parent:CreateTexture(nil, "BACKGROUND")
    h:SetTexture(MEDIA .. "Spark.tga")
    h:SetBlendMode("ADD")
    if pack.art == "W" then h:SetVertexColor(0.55, 0.30, 1.0, 0.55) else h:SetVertexColor(0.20, 0.60, 1.0, 0.50) end
    return h
end

-- ---------------------------------------------------------------------------
-- UI
-- ---------------------------------------------------------------------------

local frame, UI = nil, { pages = {} }
local overwrite = true
local owButtons = {}

local function SetMsg(page, text)
    if page and page.msg then page.msg:SetText(text or "") end
end

-- A sequence "needs an update" when what Ronin ships is different from what you have in GSE.
-- A sequence you changed yourself in GSE (and Ronin did not change) is "Edited by you": Update leaves it alone.
local function UpdatableKeys(keys)
    local out = {}
    for _, key in ipairs(keys) do
        local st = StatusOf(key)
        if st == "old" or st == "other" or st == "present" then out[#out + 1] = key end
    end
    return out
end
Ronin.UpdatableKeys = UpdatableKeys

local function RefreshStatus(page)
    local pack = page.pack
    local needs = 0
    page.updKeys = {}
    for _, r in ipairs(page.rows) do
        local n = #r.group.seqs
        local cur, present, upd, none, old, mine, mineold = 0, 0, 0, 0, nil, 0, 0
        for _, key in ipairs(r.group.seqs) do
            local st, v = StatusOf(key)
            if st == "current" then cur = cur + 1
            elseif st == "present" then present = present + 1; upd = upd + 1; page.updKeys[#page.updKeys + 1] = key
            elseif st == "none" then none = none + 1
            elseif st == "modified" then mine = mine + 1
            elseif st == "mineold" then mineold = mineold + 1
            else upd = upd + 1; old = old or v; page.updKeys[#page.updKeys + 1] = key end
        end
        if cur == n then
            r.status:SetText(GREEN .. "Up to date|r  |TInterface\\Buttons\\UI-CheckBox-Check:16:16|t")
        elseif upd == 0 and none == 0 and mineold > 0 then
            r.status:SetText(ACCENT .. "Edited by you|r" .. DIM .. "\nnew Ronin version: Overwrite ON + Import|r")
        elseif upd == 0 and none == 0 and mine > 0 then
            r.status:SetText(ACCENT .. "Edited by you|r" .. DIM .. "\nUpdate keeps your changes|r")
        elseif upd > 0 then
            needs = needs + 1
            r.status:SetText(GOLD .. "Update available|r" .. (old and (DIM .. "\nyou have V" .. tostring(old) .. "|r") or (DIM .. "\ndifferent version|r")))
        elseif none == n then
            needs = needs + 1
            r.status:SetText(DIM .. "Not installed|r")
        elseif none > 0 then
            needs = needs + 1
            r.status:SetText(GOLD .. "Incomplete|r" .. DIM .. "\nimport to finish|r")
        else
            r.status:SetText(GREEN .. "Installed|r  |TInterface\\Buttons\\UI-CheckBox-Check:16:16|t" .. DIM .. "\nimport to refresh|r")
        end
    end
    if page.updBtn then
        local u = #page.updKeys
        page.updBtn.label:SetText(u > 0 and (GOLD .. "Update (" .. u .. ")|r") or (DIM .. "Up to date|r"))
        page.updBtn:SetAlpha(u > 0 and 1 or 0.55)
    end
    return needs
end

local MarkForYouRef
local function ShowPage(name)
    for _, p in pairs(UI.pages) do p:Hide() end
    local p = UI.pages[name]
    if not p then return end
    p:Show()
    PlayGroup(p.fade)
    if p.pack then
        if p.SetScroll then p.scrollPos = 0; p.SetScroll(0) end
        DB.last = p.pack.key
        local needs = RefreshStatus(p)
        local mineRow = MarkForYouRef and MarkForYouRef(p)
        if mineRow and p.rows[mineRow] and p.rows[mineRow].y and p.SetScroll then p.SetScroll(p.rows[mineRow].y) end
        local wrongWorld = ((p.pack.world or p.pack.key) == "retail") ~= IsRetailClient()
        if not EnsureGSE() then
            SetMsg(p, RED .. "GSE is not loaded or too old. Install/enable GSE first.|r")
        elseif wrongWorld then
            SetMsg(p, GOLD .. "Note: this pack is for " .. p.pack.name .. " but you are not playing it.|r")
        elseif #(p.updKeys or {}) > 0 then
            SetMsg(p, GOLD .. #p.updKeys .. " sequence(s) have an update.|r " .. DIM .. "Press Update: it replaces only those, nothing else.|r")
        elseif needs > 0 then
            SetMsg(p, GOLD .. needs .. " row(s) can be installed.|r " .. DIM .. "Tick them and press Import Selected.|r")
        else
            SetMsg(p, GREEN .. "Everything here is up to date.|r")
        end
    end
end

local SPARKS = {
    { -0.30, -0.28, 0.0 }, { 0.32, -0.18, 0.6 }, { -0.42, 0.10, 1.3 }, { 0.40, 0.22, 1.9 },
    { -0.10, 0.40, 2.5 }, { 0.12, -0.42, 3.1 }, { -0.36, -0.40, 3.8 }, { 0.46, -0.02, 4.4 },
}

local function BuildLogo(parent)
    local box = CreateFrame("Frame", nil, parent)
    box:SetSize(200, 200)

    local halo = box:CreateTexture(nil, "BACKGROUND", nil, 0)
    halo:SetTexture(MEDIA .. "Spark.tga")
    halo:SetBlendMode("ADD")
    halo:SetVertexColor(0.25, 0.55, 1.0, 0.55)
    halo:SetPoint("CENTER")
    box.halo = halo
    Pulse(halo, 0.35, 0.9, 2.4)

    local logo = box:CreateTexture(nil, "ARTWORK")
    logo:SetTexture(MEDIA .. "Logo.tga")
    logo:SetAllPoints(box)

    local glow = box:CreateTexture(nil, "OVERLAY")
    glow:SetTexture(MEDIA .. "Logo.tga")
    glow:SetBlendMode("ADD")
    glow:SetAllPoints(box)
    Pulse(glow, 0.0, 0.38, 1.9)

    box.sparks = {}
    Float(box, 7, 2.6)
    return box
end

local function LayoutBox(box, size)
    box:SetSize(size, size)
    box.halo:SetSize(size * 1.9, size * 1.9)
    for _, s in ipairs(box.sparks) do
        s.tex:ClearAllPoints()
        s.tex:SetPoint("CENTER", box, "CENTER", s.fx * size, s.fy * size)
    end
end

-- a clickable card on the welcome screen: art + name + version
local function MakeWorldCard(parent, pack)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(230, 104)
    b:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    b:SetBackdropColor(unpack(C.row))
    b:SetBackdropBorderColor(0.10, 0.25, 0.35, 1)

    local halo = MakeHalo(b, pack)
    halo:SetSize(130, 130)
    halo:SetPoint("CENTER", b, "LEFT", 54, 0)
    Pulse(halo, 0.4, 1.0, 2.2)

    local art = MakeArt(b, pack, "ARTWORK")
    if pack.art == "W" then
        art:SetSize(62, 62)
        art:SetPoint("CENTER", b, "LEFT", 54, 0)
    else
        art:SetSize(92, 46)
        art:SetPoint("CENTER", b, "LEFT", 54, 0)
    end
    Pulse(art, 0.65, 1.0, 1.8)

    local name = b:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("LEFT", b, "LEFT", 112, 10)
    name:SetText((pack.art == "W" and VIOLET or ACCENT) .. pack.name .. "|r")
    local sub = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sub:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
    sub:SetText(DIM .. pack.sub .. "|r")
    local ver = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ver:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -2)
    ver:SetText(DIM .. "V" .. pack.version .. "|r")

    b:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.0, 0.9, 0.85, 1)
        self:SetBackdropColor(0.07, 0.11, 0.20, 1)
    end)
    b:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.10, 0.25, 0.35, 1)
        self:SetBackdropColor(unpack(C.row))
    end)
    b:SetScript("OnClick", function() ShowPage("roles_" .. pack.key) end)
    return b
end


-- ---------------------------------------------------------------------------
-- Role page: Tank / DPS / Heal (shown after you choose a world)
-- ---------------------------------------------------------------------------

local ROLES = {
    { key = "tank", name = "Tank", role = "TANK",    color = { 0.25, 0.60, 1.00 }, hex = "|cff4da6ff",
      icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance", coords = { 0.0, 0.296875, 0.296875, 0.59375 } },
    { key = "dps",  name = "DPS",  role = "DAMAGER", color = { 1.00, 0.35, 0.30 }, hex = "|cffff5a4d",
      icon = "Interface\\Icons\\Ability_DualWield", coords = { 0.296875, 0.59375, 0.296875, 0.59375 } },
    { key = "heal", name = "Heal", role = "HEALER",  color = { 0.30, 1.00, 0.55 }, hex = "|cff4dff8c",
      icon = "Interface\\Icons\\Spell_Holy_FlashHeal", coords = { 0.296875, 0.59375, 0.0, 0.296875 } },
}

local function RoleReady(pack, role)
    if role.key == "tank" then return true end
    local sp = SUBPACKS[pack.key .. "_" .. role.key]
    return sp ~= nil and next(sp.seqs) ~= nil
end

local function SetRoleIcon(tex, role)
    local ok = false
    if type(GetTexCoordsForRole) == "function" then
        local good, l, r, tp, b = pcall(GetTexCoordsForRole, role.role)
        if good and l then
            tex:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-ROLES")
            tex:SetTexCoord(l, r, tp, b)
            ok = true
        end
    end
    if not ok then
        tex:SetTexture(role.icon)
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
end

local function MakeRoleCard(parent, pack, role, page)
    local ready = RoleReady(pack, role)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(200, 236)
    b:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    b:SetBackdropColor(unpack(C.row))
    local r, g, bl = unpack(role.color)
    b.baseBorder = { r * 0.35, g * 0.35, bl * 0.35, 1 }
    b:SetBackdropBorderColor(unpack(b.baseBorder))

    local halo = b:CreateTexture(nil, "BACKGROUND")
    halo:SetTexture(MEDIA .. "Spark.tga")
    halo:SetBlendMode("ADD")
    halo:SetVertexColor(r, g, bl, ready and 0.60 or 0.22)
    halo:SetSize(190, 190)
    halo:SetPoint("CENTER", b, "TOP", 0, -86)
    if ready then Pulse(halo, 0.45, 1.0, 2.2) end

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetSize(92, 92)
    icon:SetPoint("CENTER", b, "TOP", 0, -86)
    SetRoleIcon(icon, role)
    if not ready then
        pcall(icon.SetDesaturated, icon, true)
        icon:SetAlpha(0.55)
    else
        Pulse(icon, 0.80, 1.0, 2.0)
    end

    local name = b:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("TOP", b, "TOP", 0, -150)
    name:SetText((ready and role.hex or DIM) .. role.name .. "|r")
    local sub = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sub:SetPoint("TOP", name, "BOTTOM", 0, -6)
    if ready then
        sub:SetText(DIM .. (role.key == "tank" and "Ready  -  Priority macros" or "Ready") .. "|r")
    else
        sub:SetText(GOLD .. "More to come|r")
    end

    b:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(r, g, bl, ready and 1 or 0.5)
        if ready then self:SetBackdropColor(0.07, 0.11, 0.20, 1) end
    end)
    b:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(self.baseBorder))
        self:SetBackdropColor(unpack(C.row))
    end)
    b:SetScript("OnClick", function()
        if ready then
            local target = (role.key == "tank") and pack.key or (pack.key .. "_" .. role.key)
            if UI.pages[target] then ShowPage(target); return end
        end
        page.msg:SetText(GOLD .. role.name .. " macros for " .. pack.name .. " are in the works.|r " .. DIM .. "More to come!|r")
    end)
    return b
end

local function BuildRolePage(inner, pack)
    local page = CreateFrame("Frame", nil, inner)
    page:SetAllPoints(inner)
    page.fade = FadeIn(page)
    page.roleOf = pack

    local halo = MakeHalo(page, pack)
    halo:SetSize(260, 150)
    halo:SetPoint("TOP", page, "TOP", 0, -8)
    Pulse(halo, 0.35, 0.8, 2.6)
    page.halo = halo

    local art = MakeArt(page, pack, "ARTWORK")
    if pack.art == "W" then art:SetSize(56, 56) else art:SetSize(96, 48) end
    art:SetPoint("TOP", page, "TOP", 0, -26)
    Pulse(art, 0.70, 1.0, 2.0)

    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", art, "BOTTOM", 0, -16)
    title:SetText(GOLD .. "Choose your role|r")
    local sub = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sub:SetPoint("TOP", title, "BOTTOM", 0, -4)
    sub:SetText(DIM .. "Ronin " .. pack.name .. "  -  " .. pack.sub .. "|r")

    local back = CreateFrame("Button", nil, page)
    back:SetSize(36, 36)
    back:SetPoint("TOPLEFT", 10, -8)
    back:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    back:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    back:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    back:SetScript("OnClick", function() ShowPage("welcome") end)

    page.msg = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    page.msg:SetPoint("BOTTOM", page, "BOTTOM", 0, 62)
    page.msg:SetText("")

    page.cards = {}
    for _, role in ipairs(ROLES) do
        page.cards[#page.cards + 1] = MakeRoleCard(page, pack, role, page)
    end

    local more = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    more:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -34, 26)
    more:SetText(DIM .. "More to come...|r")
    Pulse(more, 0.45, 1.0, 2.4)
    return page
end

local function LayoutRoles(page, w, h)
    local cw = clamp((w - 140) / 3 - 18, 170, 260)
    local ch = clamp(cw * 1.18, 200, 300)
    local gap = 22
    local total = 3 * cw + 2 * gap
    for i, c in ipairs(page.cards) do
        c:SetSize(cw, ch)
        c:ClearAllPoints()
        c:SetPoint("CENTER", page, "CENTER", -total / 2 + cw / 2 + (i - 1) * (cw + gap), -h * 0.04)
    end
end

local function BuildThanks()
    local t = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    t:SetPoint("TOPLEFT", 14, -14)
    t:SetPoint("BOTTOMRIGHT", -14, 14)
    t:SetFrameLevel(frame:GetFrameLevel() + 30)
    t:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    t:SetBackdropColor(0.03, 0.045, 0.09, 0.985)
    t:SetBackdropBorderColor(unpack(C.gold))
    t:EnableMouse(true)
    t:Hide()
    t.fade = FadeIn(t)

    local mini = t:CreateTexture(nil, "ARTWORK")
    mini:SetTexture(MEDIA .. "Logo.tga")
    mini:SetSize(64, 64)
    mini:SetPoint("TOP", 0, -18)

    local title = t:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", mini, "BOTTOM", 0, -8)
    title:SetText(GOLD .. "Ronin - GSE SUITE|r")

    local body = t:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOP", title, "BOTTOM", 0, -12)
    body:SetPoint("LEFT", 36, 0); body:SetPoint("RIGHT", -36, 0)
    body:SetJustifyH("CENTER")
    body:SetText(THANKS)
    body:SetSpacing(2)
    t.body = body

    local hint = t:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetTextColor(0.6, 0.67, 0.78)
    hint:SetText("Click a box, press Ctrl+C, then paste it in your browser.")

    local prev
    for _, l in ipairs(LINKS) do
        local lab = t:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lab:SetText(ACCENT .. l[1] .. "|r")
        lab:SetWidth(64); lab:SetJustifyH("LEFT")

        local eb = CreateFrame("EditBox", nil, t, "BackdropTemplate")
        eb:SetAutoFocus(false)
        eb:SetFontObject("GameFontHighlightSmall")
        eb:SetHeight(26)
        eb:SetTextInsets(8, 8, 0, 0)
        eb:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
        eb:SetBackdropColor(0.02, 0.03, 0.06, 1)
        eb:SetBackdropBorderColor(unpack(C.cyanDim))
        eb:SetText(l[2]); eb:SetCursorPosition(0)
        eb:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
        eb:SetScript("OnEditFocusLost", function(self) self:HighlightText(0, 0) end)
        eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        eb:SetScript("OnTextChanged", function(self)
            if self:GetText() ~= l[2] then self:SetText(l[2]); self:HighlightText() end
        end)
        if prev then
            lab:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
        else
            lab:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 40, -22)
        end
        eb:SetPoint("LEFT", lab, "RIGHT", 10, 0)
        eb:SetPoint("RIGHT", t, "RIGHT", -60, 0)
        prev = lab
    end
    hint:SetPoint("TOP", prev, "BOTTOM", 0, -22)
    hint:SetPoint("LEFT", 36, 0); hint:SetPoint("RIGHT", -36, 0)

    local back = MakeButton(t, "Back", 120, 30, true)
    back:SetPoint("BOTTOM", 0, 22)
    back:SetScript("OnClick", function() t:Hide() end)
    return t
end

local function OpenThanks(key)
    if UI.thanks.body then UI.thanks.body:SetText(THANKS_BY[key] or THANKS) end
    UI.thanks:Show(); PlayGroup(UI.thanks.fade)
end

-- one installer page per world
local function BuildInstallPage(inner, pack)
    local page = CreateFrame("Frame", nil, inner)
    page:SetAllPoints(inner)
    page.fade = FadeIn(page)
    page.pack = pack
    page.rows = {}

    local header = CreateFrame("Frame", nil, page)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:SetHeight(130)
    pcall(header.SetClipsChildren, header, true)
    page.header = header

    page.halo = MakeHalo(header, pack)
    page.art = MakeArt(header, pack, "ARTWORK")
    Pulse(page.halo, 0.45, 1.0, 2.4)
    Pulse(page.art, 0.70, 1.0, 2.0)
    Float(page.art, 5, 2.8)

    local ver = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ver:SetPoint("BOTTOMLEFT", 16, 8)
    ver:SetText(DIM .. "Ronin " .. pack.name .. "  V" .. pack.version .. "|r")

    local back = CreateFrame("Button", nil, page)
    back:SetSize(36, 36)
    back:SetPoint("TOPLEFT", 10, -8)
    back:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    back:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    back:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    back:SetScript("OnClick", function() ShowPage("roles_" .. (pack.world or pack.key)) end)

    local sep = page:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(0.82, 0.65, 0.24, 0.35)
    sep:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 22, 0)
    sep:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -22, 0)
    sep:SetHeight(1)

    -- the class rows live in a scroll area (mouse wheel), laid out in 2 columns when there are many
    local scroll = CreateFrame("ScrollFrame", nil, page)
    pcall(scroll.SetClipsChildren, scroll, true)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(10, 10)
    scroll:SetScrollChild(content)
    scroll:EnableMouseWheel(true)
    page.scroll, page.content, page.maxScroll = scroll, content, 0
    local track = page:CreateTexture(nil, "ARTWORK")
    track:SetColorTexture(0.10, 0.20, 0.30, 0.6)
    local thumb = page:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(0.0, 0.8, 0.78, 0.85)
    page.track, page.thumb = track, thumb
    local function SetScroll(v)
        v = math.max(0, math.min(page.maxScroll or 0, v or 0))
        scroll:SetVerticalScroll(v)
        page.scrollPos = v
        if (page.maxScroll or 0) > 0 and page.trackH then
            local th = math.max(24, page.trackH * page.viewH / (page.viewH + page.maxScroll))
            thumb:SetHeight(th)
            thumb:ClearAllPoints()
            thumb:SetPoint("TOPRIGHT", track, "TOPRIGHT", 0, -((page.trackH - th) * v / page.maxScroll))
        end
    end
    page.SetScroll = SetScroll
    scroll:SetScript("OnMouseWheel", function(_, delta) SetScroll((page.scrollPos or 0) - delta * 60) end)

    for _, g in ipairs(pack.groups) do
        local row = CreateFrame("Button", nil, content, "BackdropTemplate")
        row:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
        row:SetBackdropColor(unpack(C.row))
        row:SetBackdropBorderColor(0.10, 0.20, 0.30, 1)
        row.group = g

        local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        cb:SetSize(26, 26)
        cb:SetPoint("LEFT", 8, 0)
        cb:SetChecked(true)
        cb:EnableMouse(false)
        row.cb = cb

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("LEFT", cb, "RIGHT", 8, 0)
        icon:SetTexture(GroupIcon(g))
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        row.icon = icon

        local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        name:SetPoint("LEFT", icon, "RIGHT", 12, 5)
        name:SetJustifyH("LEFT")
        pcall(name.SetWordWrap, name, false)
        name:SetText(g.color .. g.name .. "|r")
        row.name = name
        local sub = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        sub:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
        sub:SetJustifyH("LEFT")
        pcall(sub.SetWordWrap, sub, false)
        sub:SetText(DIM .. (g.sub or "") .. "|r")
        row.sub = sub

        local status = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        status:SetPoint("RIGHT", -14, 0)
        status:SetJustifyH("RIGHT")
        row.status = status

        local hasTal = false
        for _, key in ipairs(g.seqs) do if Ronin.Meta and Ronin.Meta[key] and Ronin.Meta[key].tal and not Ronin.Meta[key].same then hasTal = true end end
        if hasTal then
            local tb = MakeButton(row, "Talents", 64, 22, false)
            tb:SetPoint("RIGHT", status, "LEFT", -10, 0)
            tb:SetScript("OnClick", function() if Ronin.ShowTalents then Ronin.ShowTalents(g.seqs, g.name .. " talents") end end)
            row.talBtn = tb
        end
        row:SetScript("OnClick", function() cb:SetChecked(not cb:GetChecked()) end)
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function(_, delta) page.SetScroll((page.scrollPos or 0) - delta * 60) end)
        row:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(0.0, 0.8, 0.78, 0.9) end)
        row:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(0.10, 0.20, 0.30, 1) end)
        page.rows[#page.rows + 1] = row
    end

    -- bottom bar
    local bar = CreateFrame("Frame", nil, page)
    bar:SetPoint("BOTTOMLEFT", 0, 0)
    bar:SetPoint("BOTTOMRIGHT", 0, 0)
    bar:SetHeight(92)

    page.msg = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    page.msg:SetPoint("BOTTOM", bar, "TOP", 0, 2)

    local importBtn = MakeButton(bar, "Import Selected", 170, 38, true)
    importBtn:SetPoint("BOTTOMRIGHT", -24, 22)
    local updBtn = MakeButton(bar, "Update", 150, 38, false)
    updBtn:SetPoint("RIGHT", importBtn, "LEFT", -18, 0)
    page.updBtn = updBtn
    local allBtn = MakeButton(bar, "Select None", 116, 38, false)
    allBtn:SetPoint("RIGHT", updBtn, "LEFT", -18, 0)
    local thanksBtn = MakeButton(bar, "Thank you", 100, 38, false)
    thanksBtn:SetPoint("BOTTOMLEFT", 24, 22)
    thanksBtn:SetScript("OnClick", function() OpenThanks(pack.world or pack.key) end)

    local owBtn = MakeButton(bar, "", 130, 38, false)
    owBtn:SetPoint("LEFT", thanksBtn, "RIGHT", 18, 0)
    owBtn:SetScript("OnClick", function()
        overwrite = not overwrite
        for _, b in ipairs(owButtons) do
            b.label:SetText("Overwrite: " .. (overwrite and (GREEN .. "ON|r") or (RED .. "OFF|r")))
        end
    end)
    owBtn.label:SetText("Overwrite: " .. (overwrite and (GREEN .. "ON|r") or (RED .. "OFF|r")))
    owButtons[#owButtons + 1] = owBtn

    allBtn:SetScript("OnClick", function()
        local any = false
        for _, r in ipairs(page.rows) do if r.cb:GetChecked() then any = true end end
        for _, r in ipairs(page.rows) do r.cb:SetChecked(not any) end
        allBtn.label:SetText(any and "Select All" or "Select None")
    end)

    -- Update: replaces ONLY the sequences whose Ronin version changed (always with overwrite).
    -- Sequences you edited yourself in GSE and new rows you never imported are left alone.
    updBtn:SetScript("OnClick", function()
        if not EnsureGSE() then
            SetMsg(page, RED .. "GSE is not loaded or too old.|r"); return
        end
        if InCombatLockdown() then
            SetMsg(page, RED .. "Leave combat first.|r"); return
        end
        RefreshStatus(page)
        local keys = page.updKeys or {}
        if #keys == 0 then
            SetMsg(page, GREEN .. "Everything here is up to date.|r"); return
        end
        local before = Snapshot(keys)
        local ok, err = Ronin.InstallBatch(keys, true, pack.regkey)
        if ok then
            RecordImport(keys, before)
            SetMsg(page, GREEN .. "Updated " .. #keys .. " sequence(s).|r " .. DIM .. "GSE saves them in a few seconds. Your binds stay the same.|r")
            Print(GREEN .. "Updated " .. #keys .. " sequence(s).|r")
            RefreshStatus(page)
            if type(C_Timer) == "table" and C_Timer.After then
                C_Timer.After(9, function() RefreshStatus(page) end)
                C_Timer.After(20, function() RefreshStatus(page) end)
            end
        else
            SetMsg(page, RED .. "Update failed: " .. tostring(err) .. "|r")
            Print(RED .. "Update failed: " .. tostring(err))
        end
    end)

    importBtn:SetScript("OnClick", function()
        if not EnsureGSE() then
            SetMsg(page, RED .. "GSE is not loaded or too old.|r"); return
        end
        if InCombatLockdown() then
            SetMsg(page, RED .. "Leave combat first.|r"); return
        end
        local selected = {}
        for _, r in ipairs(page.rows) do
            if r.cb:GetChecked() then
                for _, key in ipairs(r.group.seqs) do
                    if overwrite or StatusOf(key) == "none" then selected[#selected + 1] = key end
                end
            end
        end
        if #selected == 0 then
            SetMsg(page, DIM .. "Nothing to import (tick a row, or turn Overwrite ON to replace).|r"); return
        end
        local before = Snapshot(selected)
        local ok, err = Ronin.InstallBatch(selected, overwrite, pack.regkey)
        if ok then
            SetMsg(page, GREEN .. "Imported " .. #selected .. " sequence(s).|r " .. DIM .. "Bind them in GSE and place the macro on your bar.|r")
            Print(GREEN .. "Imported " .. #selected .. " sequence(s).|r Bind them in GSE.")
            RecordImport(selected, before)
            RefreshStatus(page)
            if type(C_Timer) == "table" and C_Timer.After then
                C_Timer.After(9, function() RefreshStatus(page) end)
                C_Timer.After(20, function() RefreshStatus(page) end)
            end
        else
            SetMsg(page, RED .. "Import failed: " .. tostring(err) .. "|r")
            Print(RED .. "Import failed: " .. tostring(err))
        end
    end)

    return page
end

local function LayoutInstall(page, w, h)
    local headerH = (#page.rows > 8) and clamp(h * 0.17, 96, 150) or clamp(h * 0.27, 112, 210)   -- long lists: smaller header
    page.header:SetHeight(headerH)
    local hs = headerH - 20
    page.art:ClearAllPoints(); page.halo:ClearAllPoints()
    page.art:SetPoint("CENTER", page.header, "CENTER", 0, 2)
    page.halo:SetPoint("CENTER", page.header, "CENTER", 0, 2)
    if page.art.ratio == 2 then
        page.art:SetSize(hs * 3.0, hs * 1.5)
        page.halo:SetSize(hs * 3.4, hs * 2.0)
    else
        page.art:SetSize(hs * 0.95, hs * 0.95)
        page.halo:SetSize(hs * 2.0, hs * 2.0)
    end

    local rows = page.rows
    local n = #rows
    local top = headerH + 10
    local bottom = 112                       -- buttons + the message line stay free
    local viewH = math.max(80, h - top - bottom)
    local cols = (n > 4 and w >= 640) and 2 or 1
    local gap, colGap = 6, 10
    local perCol = math.ceil(n / cols)
    local rh = clamp(viewH / perCol - gap, 44, 56)
    local contentH = perCol * (rh + gap) - gap
    local viewW = w - 44 - 14                -- 22 px margins, 14 px for the scroll bar
    local colW = (viewW - (cols - 1) * colGap) / cols

    page.scroll:ClearAllPoints()
    local offY = (contentH < viewH) and (viewH - contentH) / 2 or 0
    page.scroll:SetPoint("TOPLEFT", page, "TOPLEFT", 22, -(top + offY))
    page.scroll:SetSize(viewW, math.min(viewH, contentH))
    page.content:SetSize(viewW, contentH)
    page.viewH = math.min(viewH, contentH)
    page.maxScroll = math.max(0, contentH - viewH)

    page.track:ClearAllPoints()
    page.track:SetPoint("TOPRIGHT", page, "TOPRIGHT", -22, -top)
    page.track:SetSize(4, viewH)
    page.trackH = viewH
    page.thumb:SetWidth(4)
    if page.maxScroll > 0 then page.track:Show(); page.thumb:Show() else page.track:Hide(); page.thumb:Hide() end

    local nameFont = (cols == 2) and "GameFontNormal" or "GameFontNormalLarge"
    for i, r in ipairs(rows) do
        local c = (i - 1) % cols                       -- row by row: left, right, then the next line (reads well with the scroll)
        local k = math.floor((i - 1) / cols)
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", page.content, "TOPLEFT", c * (colW + colGap), -(k * (rh + gap)))
        r.y = k * (rh + gap)
        r:SetSize(colW, rh)
        r.icon:SetSize(rh - 12, rh - 12)
        r.name:SetFontObject(nameFont)
        local textW = colW - (8 + 26 + 8 + (rh - 12) + 12) - 118 - (r.talBtn and 74 or 0)   -- room left of the status text (and the Talents button)
        r.name:SetWidth(textW)
        r.sub:SetWidth(textW)
    end
    page.SetScroll(page.scrollPos or 0)
end

local function Layout()
    if not frame then return end
    local w, h = frame:GetWidth(), frame:GetHeight()

    -- welcome: logo on the left of centre, two world cards on the right
    local ls = clamp(math.min((w - 300) * 0.80, h * 0.56), 150, 440)
    LayoutBox(UI.wlogo, ls)
    UI.wlogo:ClearAllPoints()
    UI.wlogo:SetPoint("CENTER", UI.welcome, "CENTER", -125, h * 0.05)

    for _, p in pairs(UI.pages) do
        if p.pack then LayoutInstall(p, w, h) end
        if p.roleOf then LayoutRoles(p, w, h) end
    end
end

local function CreateFrameUI()
    if frame then return frame end

    frame = CreateFrame("Frame", "RoninFrame", UIParent, "BackdropTemplate")
    frame:SetSize(840, 620)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 2 })
    frame:SetBackdropColor(unpack(C.bg))
    frame:SetBackdropBorderColor(unpack(C.gold))
    tinsert(UISpecialFrames, "RoninFrame") -- Esc closes it

    if frame.SetResizeBounds then
        frame:SetResizeBounds(780, 540, 1200, 900)
    else
        if frame.SetMinResize then frame:SetMinResize(780, 540) end
        if frame.SetMaxResize then frame:SetMaxResize(1200, 900) end
    end

    local inner = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    inner:SetPoint("TOPLEFT", 6, -6)
    inner:SetPoint("BOTTOMRIGHT", -6, 6)
    inner:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    inner:SetBackdropColor(0.02, 0.03, 0.07, 0.55)
    inner:SetBackdropBorderColor(0.0, 0.55, 0.60, 0.40)

    local close = MakeButton(frame, "X", 24, 24, false)
    close:SetPoint("TOPRIGHT", -12, -12)
    close:SetFrameLevel(frame:GetFrameLevel() + 20)
    close:SetScript("OnClick", function() frame:Hide() end)

    ---------------------------------------------------------------- WELCOME
    local welcome = CreateFrame("Frame", nil, inner)
    welcome:SetAllPoints(inner)
    welcome.fade = FadeIn(welcome)
    UI.welcome = welcome
    UI.pages.welcome = welcome

    UI.wlogo = BuildLogo(welcome)

    local wtitle = welcome:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    wtitle:SetPoint("BOTTOM", welcome, "BOTTOM", -125, 78)
    wtitle:SetText(ACCENT .. "Welcome|r")
    local wsub = welcome:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    wsub:SetPoint("TOP", wtitle, "BOTTOM", 0, -6)
    wsub:SetText(DIM .. "GSE SUITE  -  Tank, DPS + Heal, both worlds  -  V" .. ADDON_VERSION .. "|r")

    local cardForever = MakeWorldCard(welcome, PACKS.forever)
    local cardRetail  = MakeWorldCard(welcome, PACKS.retail)
    cardRetail:SetPoint("RIGHT", welcome, "RIGHT", -30, -62)
    cardForever:SetPoint("RIGHT", welcome, "RIGHT", -30, 62)

    local pick = welcome:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pick:SetPoint("BOTTOM", cardForever, "TOP", 0, 10)
    pick:SetText(GOLD .. "Choose your world|r")

    local skip = CreateFrame("CheckButton", nil, welcome, "UICheckButtonTemplate")
    skip:SetSize(24, 24)
    skip:SetPoint("BOTTOMLEFT", 20, 18)
    skip:SetChecked(DB.skipWelcome and true or false)
    skip:SetScript("OnClick", function(self) DB.skipWelcome = self:GetChecked() and true or false end)
    local skipTxt = welcome:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    skipTxt:SetPoint("LEFT", skip, "RIGHT", 4, 1)
    skipTxt:SetTextColor(0.6, 0.67, 0.78)
    skipTxt:SetText("Skip this screen next time")

    local wthanks = MakeButton(welcome, "Thank you", 120, 34, false)
    wthanks:SetPoint("BOTTOMRIGHT", -30, 18)
    wthanks:SetScript("OnClick", function() OpenThanks(nil) end)

    ---------------------------------------------------------------- INSTALLER PAGES
    UI.pages.roles_retail  = BuildRolePage(inner, PACKS.retail)
    UI.pages.roles_forever = BuildRolePage(inner, PACKS.forever)
    UI.pages.retail  = BuildInstallPage(inner, PACKS.retail)
    UI.pages.forever = BuildInstallPage(inner, PACKS.forever)
    for sk, sp in pairs(SUBPACKS) do
        if next(sp.seqs) ~= nil then UI.pages[sk] = BuildInstallPage(inner, sp) end
    end

    UI.thanks = BuildThanks()

    ---------------------------------------------------------------- RESIZE GRIP
    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(20, 20)
    grip:SetPoint("BOTTOMRIGHT", -3, 3)
    grip:SetFrameLevel(frame:GetFrameLevel() + 40)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
    grip:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() Layout() end)

    frame:SetScript("OnSizeChanged", Layout)
    frame:SetScript("OnShow", function()
        Layout()
        if UI.wanted then
            ShowPage(UI.wanted); UI.wanted = nil
        elseif DB.skipWelcome then
            local last = DB.last
            if not (last and UI.pages[last]) then last = IsRetailClient() and "roles_retail" or "roles_forever" end
            ShowPage(last)
        else
            ShowPage("welcome")
        end
    end)
    Layout()
    frame:Hide()
    return frame
end

local function Toggle(which)
    local f = CreateFrameUI()
    if which then
        UI.wanted = which
        if f:IsShown() then ShowPage(which) else f:Show() end
        return
    end
    if f:IsShown() then f:Hide() else f:Show() end
end

local function Debug()
    Print("GSE: " .. tostring(type(GSE) == "table" and (GSE.VersionString or GSE.VersionNumber) or "not loaded"))
    Print("FindSequenceId=" .. tostring(type(GSE) == "table" and type(GSE.FindSequenceId)) ..
        "  GetSequence=" .. tostring(type(GSE) == "table" and type(GSE.GetSequence)) ..
        "  Library=" .. tostring(type(GSE) == "table" and type(GSE.Library)) ..
        "  GSEStore=" .. tostring(type(GSEStore)) .. "  GSESequences=" .. tostring(type(GSESequences)))
    local n = 0
    for key in pairs(Ronin.Sequences) do
        if n >= 3 then break end
        local found, lib = Lookup(key)
        Print(key .. ": found=" .. tostring(found) .. " decoded=" .. tostring(lib ~= nil) ..
            " status=" .. tostring((StatusOf(key))) .. " fp=" .. tostring(Fingerprint(lib)) ..
            " pkg=" .. tostring(Fingerprint(Ronin.Sequences[key])))
        n = n + 1
    end
end

-- ---------------------------------------------------------------------------
-- Ronin tools (4.4): /ronin check, Copy talents, "for you" rows, /ronin report
-- Ronin.Meta (Data_Meta.lua): per Retail sequence the hero tree, the talent import strings and the
-- spells the build needs. Forever: the spells of the version for your level are read from the macro.
-- ---------------------------------------------------------------------------

local META = Ronin.Meta or {}

local function PlayerSpec()
    if type(GetSpecialization) ~= "function" then return nil end
    local ok, idx = pcall(GetSpecialization)
    if not ok or not idx then return nil end
    local ok2, id, name = pcall(GetSpecializationInfo, idx)
    if ok2 then return id, name end
end

local function PlayerHero()
    if type(C_ClassTalents) ~= "table" or type(C_ClassTalents.GetActiveHeroTalentSpec) ~= "function" then return nil end
    local ok, sub = pcall(C_ClassTalents.GetActiveHeroTalentSpec)
    if not ok or not sub then return nil end
    if type(C_Traits) == "table" and type(C_Traits.GetSubTreeInfo) == "function" and type(C_ClassTalents.GetActiveConfigID) == "function" then
        local okc, cfg = pcall(C_ClassTalents.GetActiveConfigID)
        if okc and cfg then
            local oki, info = pcall(C_Traits.GetSubTreeInfo, cfg, sub)
            if oki and type(info) == "table" and info.name then return info.name end
        end
    end
end

local function LoadoutString()
    if type(C_ClassTalents) ~= "table" or type(C_Traits) ~= "table" then return nil end
    if type(C_ClassTalents.GetActiveConfigID) ~= "function" or type(C_Traits.GenerateImportString) ~= "function" then return nil end
    local ok, cfg = pcall(C_ClassTalents.GetActiveConfigID)
    if not ok or not cfg then return nil end
    local ok2, s = pcall(C_Traits.GenerateImportString, cfg)
    if ok2 then return s end
end

-- is this spell (name or spell ID) known by your character right now?
local function Known(spell)
    local id = tonumber(spell)
    if not id then
        if type(C_Spell) == "table" and type(C_Spell.GetSpellInfo) == "function" then
            local ok, info = pcall(C_Spell.GetSpellInfo, spell)
            if not ok or type(info) ~= "table" then return false end
            id = info.spellID
        elseif type(GetSpellInfo) == "function" then
            local r = { pcall(GetSpellInfo, spell) }
            if not r[1] or not r[2] then return false end
            id = r[8]
            if not id then return true end
        else
            return nil
        end
    end
    if not id then return false end
    if type(IsPlayerSpell) == "function" then
        local ok, v = pcall(IsPlayerSpell, id); if ok and v then return true end
    end
    if type(IsSpellKnownOrOverridesKnown) == "function" then
        local ok, v = pcall(IsSpellKnownOrOverridesKnown, id); if ok and v then return true end
    end
    if type(IsSpellKnown) == "function" then
        local ok, v = pcall(IsSpellKnown, id); if ok and v then return true end
    end
    if type(C_SpellBook) == "table" and type(C_SpellBook.IsSpellKnown) == "function" then
        local ok, v = pcall(C_SpellBook.IsSpellKnown, id); if ok and v then return true end
    end
    return false
end
Ronin.Known = Known

-- spells used by one macro text (names or IDs), conditions and resets removed
local function MacroSpells(text, out, seen)
    for line in tostring(text):gmatch("[^\n]+") do
        local cmd, body = line:match("^%s*/(%a+)%s+(.*)$")
        if cmd == "cast" or cmd == "castsequence" or cmd == "use" then
            for rawClause in (body .. ";"):gmatch("([^;]*);") do
                local clause = rawClause:gsub("%b[]", ""):gsub("^%s*reset=%S+%s*", "")
                local parts = {}
                if cmd == "castsequence" then
                    for p in clause:gmatch("[^,]+") do parts[#parts + 1] = p end
                else
                    parts[1] = clause
                end
                for _, raw in ipairs(parts) do
                    local p = raw:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^!", ""):gsub("%s%s+", " ")
                    if p ~= "" and p:lower() ~= "null" and not seen[p] and not (cmd == "use" and tonumber(p) and tonumber(p) < 20) then
                        seen[p] = true; out[#out + 1] = p
                    end
                end
            end
        end
    end
end
local function VersionSpells(seq, label)
    local out, seen = {}, {}
    local function walk(t)
        if type(t) ~= "table" then return end
        if type(t.macro) == "string" then MacroSpells(t.macro, out, seen) end
        for k, v in pairs(t) do if type(v) == "table" then walk(v) end end
    end
    for _, v in pairs(seq.Versions or {}) do
        if v.Label == label then walk(v) end
    end
    return out
end
Ronin.MacroSpells = MacroSpells

local FOREVER_CLASS = { WARRIOR = "Warrior", PALADIN = "Paladin", DRUID = "Druid", SHAMAN = "Shaman", WARLOCK = "Warlock",
    MAGE = "Mage", HUNTER = "Hunter", PRIEST = "Priest" }

-- which Ronin sequences are for your character (Retail: your spec, Forever: your class)
local function MySequences()
    local list = {}
    local retail = IsRetailClient()
    local spec = PlayerSpec()
    local classTag
    if type(UnitClass) == "function" then classTag = select(2, UnitClass("player")) end
    for name, seq in pairs(Ronin.Sequences) do
        local pack = PACK_OF[name]
        local isRetail = pack and (pack.world or pack.key) == "retail"
        if retail and isRetail then
            if spec and seq.MetaData and tonumber(seq.MetaData.SpecID) == spec then list[#list + 1] = name end
        elseif not retail and not isRetail then
            local cls = FOREVER_CLASS[classTag or ""]
            if cls and name:find(cls, 1, true) then list[#list + 1] = name end
        end
    end
    table.sort(list)
    return list
end

local function ForeverLabel()
    local lvl = (UnitLevel and UnitLevel("player")) or 60
    if lvl < 10 then return "Level 1-10" elseif lvl < 40 then return "Level 10-40" end
    return "Level 40-60"
end

-- returns { {name=, hero=, missing={...}, checked=n}, ... }, header text
function Ronin.Check()
    local res = {}
    local retail = IsRetailClient()
    local hero = PlayerHero()
    for _, name in ipairs(MySequences()) do
        local m = META[name]
        local need
        if retail then
            need = m and m.need or {}
        else
            need = VersionSpells(Ronin.Sequences[name], ForeverLabel())
        end
        local miss = {}
        for _, e in ipairs(need) do
            local sp, eng = e, nil
            if type(e) == "table" then sp, eng = e[1], e[2] end      -- Retail: { spellID, English name }
            if Known(sp) == false then
                local shown
                if tonumber(sp) then
                    if type(C_Spell) == "table" and type(C_Spell.GetSpellName) == "function" then
                        local ok, n = pcall(C_Spell.GetSpellName, tonumber(sp)); if ok and n then shown = n end
                    end
                    if not shown and type(GetSpellInfo) == "function" then
                        local ok, n = pcall(GetSpellInfo, tonumber(sp)); if ok and n then shown = n end
                    end
                end
                miss[#miss + 1] = shown or eng or tostring(sp)
            end
        end
        res[#res + 1] = { name = name, hero = m and m.hero, missing = miss, checked = #need,
            yours = (hero and m and m.hero == hero) or false }
    end
    -- you play one hero tree: the macros of the other one are not checked (their hero spells are not yours)
    local any = false
    for _, r in ipairs(res) do if r.yours then any = true end end
    if any then
        local keep = {}
        for _, r in ipairs(res) do if r.yours or not r.hero then keep[#keep + 1] = r end end
        res = keep
    end
    return res, hero
end

local function CheckText()
    local res, hero = Ronin.Check()
    local retail = IsRetailClient()
    local _, specName = PlayerSpec()
    local lines = {}
    if #res == 0 then
        lines[1] = retail and "No Ronin sequence for your spec." or "No Ronin sequence for your class."
        return table.concat(lines, "\n"), res
    end
    lines[#lines + 1] = "Ronin check for " .. tostring(specName or (UnitClass and UnitClass("player")) or "you")
        .. (hero and (" (" .. hero .. ")") or "") .. (retail and "" or (" - " .. ForeverLabel()))
    for _, r in ipairs(res) do
        local mark = r.yours and "  <- your hero tree" or ""
        if #r.missing == 0 then
            lines[#lines + 1] = r.name .. ": all " .. r.checked .. " spells known" .. mark
        else
            lines[#lines + 1] = r.name .. ": missing " .. table.concat(r.missing, ", ") .. mark
        end
    end
    if retail then
        lines[#lines + 1] = "Missing spells: import the talents of that macro (Talents button in /ronin or its GSE Notes)."
        lines[#lines + 1] = "\"You can't do that yet\" below max level is normal: the spell comes with a later level."
    else
        lines[#lines + 1] = "Missing spells in WoW: Forever: not learned yet (trainer, level, talent or rune). The macro skips them."
    end
    return table.concat(lines, "\n"), res
end
Ronin.CheckText = CheckText

-- one copy box for talents, check and report
local copyBox
local function CopyBox()
    if copyBox then return copyBox end
    local f = CreateFrame("Frame", "RoninCopyBox", UIParent, "BackdropTemplate")
    f:SetSize(620, 360)
    f:SetPoint("CENTER", 0, 40)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving); f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 2 })
    f:SetBackdropColor(unpack(C.bg)); f:SetBackdropBorderColor(unpack(C.gold))
    tinsert(UISpecialFrames, "RoninCopyBox")
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOPLEFT", 16, -14)
    f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.hint:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -4)
    f.hint:SetJustifyH("LEFT")
    local close = MakeButton(f, "X", 24, 24, false)
    close:SetPoint("TOPRIGHT", -10, -10)
    close:SetScript("OnClick", function() f:Hide() end)
    f.tabs = {}
    local sf = CreateFrame("ScrollFrame", "RoninCopyScroll", f, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 16, -96)
    sf:SetPoint("BOTTOMRIGHT", -34, 16)
    local eb = CreateFrame("EditBox", nil, sf)
    eb:SetMultiLine(true); eb:SetAutoFocus(false); eb:SetFontObject("ChatFontNormal")
    eb:SetWidth(560)
    eb:SetScript("OnEscapePressed", function() f:Hide() end)
    eb:SetScript("OnTextChanged", function(self, user) if user and f.text then self:SetText(f.text); self:HighlightText() end end)
    sf:SetScrollChild(eb)
    f.eb = eb
    f:Hide()
    copyBox = f
    return f
end
local function ShowCopy(title, hint, text, choices)
    local f = CopyBox()
    f.title:SetText(GOLD .. title .. "|r")
    f.hint:SetText(DIM .. hint .. "|r")
    for _, b in ipairs(f.tabs) do b:Hide() end
    local function put(t)
        f.text = t
        f.eb:SetText(t); f.eb:SetFocus(); f.eb:HighlightText()
    end
    if choices and #choices > 0 then
        local x = 16
        for i, c in ipairs(choices) do
            local b = f.tabs[i]
            if not b then b = MakeButton(f, "", 140, 26, false); f.tabs[i] = b end
            b:ClearAllPoints(); b:SetPoint("TOPLEFT", x, -62)
            local w = math.min(190, 24 + #c.label * 7); b:SetWidth(w); x = x + w + 8
            b.label:SetText(c.label)
            b:SetScript("OnClick", function() put(c.text) end)
            b:Show()
        end
        put(choices[1].text)
    else
        put(text or "")
    end
    f:Show()
    return f
end
Ronin.ShowCopy = ShowCopy

-- the talent strings of a row (both hero trees), your hero tree first
local function TalentChoices(keys)
    local hero = PlayerHero()
    local list = {}
    for _, key in ipairs(keys) do
        local m = META[key]
        if m and m.tal and not m.same then
            for _, t in ipairs(m.tal) do
                list[#list + 1] = { label = (m.hero or key) .. ": " .. t[1], text = t[2], mine = (hero and m.hero == hero) }
            end
        end
    end
    table.sort(list, function(a, b) if a.mine ~= b.mine then return a.mine end return false end)
    return list
end
Ronin.TalentChoices = TalentChoices

function Ronin.ShowTalents(keys, title)
    local ch = TalentChoices(keys)
    if #ch == 0 then
        Print(DIM .. "No talent string for this one: pick the hero tree in your talent window.|r"); return
    end
    ShowCopy(title or "Talents", "Ctrl+C, then in the talent window: Import (the button at the bottom), Ctrl+V. Pick the macro version that matches (Mythic+ / Delve or Raid).", nil, ch)
end

function Ronin.ShowCheck()
    local text, res = CheckText()
    local missing = 0
    for _, r in ipairs(res) do if #r.missing > 0 then missing = missing + 1 end end
    if #res > 0 then
        Print((missing == 0 and GREEN .. "Check: every spell of your Ronin macros is known.|r") or
            (GOLD .. "Check: " .. missing .. " macro(s) use spells you do not have.|r Details in the window."))
    end
    ShowCopy("Ronin check", "Which spells of your Ronin macros your character knows right now.", text)
end

function Ronin.ReportText()
    local lines = {}
    local _, specName = PlayerSpec()
    local spec = PlayerSpec()
    local gse = type(GSE) == "table" and (GSE.VersionString or GSE.VersionNumber) or "not loaded"
    local _, _, _, toc = GetBuildInfo()
    lines[#lines + 1] = "Ronin " .. ADDON_VERSION .. " (Retail " .. PACKS.retail.version .. ", Forever " .. PACKS.forever.version .. ") | GSE " .. tostring(gse) .. " | client " .. tostring(toc)
    lines[#lines + 1] = "Character: " .. tostring(UnitClass and UnitClass("player") or "?") .. " " .. tostring(specName or "") ..
        (spec and (" (" .. spec .. ")") or "") .. " | hero tree: " .. tostring(PlayerHero() or "-") .. " | level " .. tostring(UnitLevel and UnitLevel("player") or "?")
    lines[#lines + 1] = "Talents: " .. tostring(LoadoutString() or "-")
    local mine = MySequences()
    local st = {}
    for _, n in ipairs(mine) do st[#st + 1] = n .. "=" .. tostring((StatusOf(n))) end
    lines[#lines + 1] = "Ronin sequences: " .. (#st > 0 and table.concat(st, ", ") or "-")
    local text = CheckText()
    lines[#lines + 1] = "Check: " .. text:gsub("\n", " | ")
    lines[#lines + 1] = "Which version (Mythic+ / Raid / Delve / Beginner / Leveling): "
    lines[#lines + 1] = "What happens: "
    return table.concat(lines, "\n")
end
function Ronin.ShowReport()
    ShowCopy("Ronin report", "Ctrl+C and paste it in a comment on the Ronin CurseForge page. Add the version and what happens at the end.", Ronin.ReportText())
end

-- rows for your spec: gold border + "for you" (and your hero tree when it is known)
local function MarkForYou(page)
    if not page or not page.rows then return nil end
    local spec = PlayerSpec()
    local hero = PlayerHero()
    local first
    for i, r in ipairs(page.rows) do
        local g = r.group
        local mine = spec and g.specID and g.specID == spec
        if mine then
            local h
            for _, key in ipairs(g.seqs) do local m = META[key]; if hero and m and m.hero == hero and not h then h = m.hero end end
            r.sub:SetText(DIM .. (g.sub or "") .. "|r  " .. GOLD .. "For you" .. (h and (": " .. h) or "") .. "|r")
            r:SetBackdropBorderColor(unpack(C.gold))
            r.forYou = true
            first = first or i
        elseif r.forYou then
            r.sub:SetText(DIM .. (g.sub or "") .. "|r"); r.forYou = nil
            r:SetBackdropBorderColor(0.10, 0.20, 0.30, 1)
        end
    end
    return first
end
Ronin.MarkForYou = MarkForYou
MarkForYouRef = MarkForYou

SLASH_RONIN1 = "/ronin"
SLASH_RONIN2 = "/roninforever"
SLASH_RONIN3 = "/roninretail"
SlashCmdList["RONIN"] = function(msg, editbox)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "debug" then Debug(); return end
    if msg == "update" then Ronin.UpdateAll(); return end
    if msg == "retail" or msg == "forever" then Toggle("roles_" .. msg); return end
    if msg == "check" then Ronin.ShowCheck(); return end
    if msg == "report" then Ronin.ShowReport(); return end
    if msg == "talents" then
        local keys = MySequences()
        if #keys == 0 then Print(DIM .. "No Ronin sequence for your spec.|r") else Ronin.ShowTalents(keys, "Talents for your spec") end
        return
    end
    if msg == "help" then
        Print("/ronin  open the installer  |  /ronin update  |  /ronin check  spells you miss  |  /ronin talents  copy the talent string  |  /ronin report  text for a bug report  |  /ronin retail  |  /ronin forever")
        return
    end
    Toggle(nil)
end

-- Update everything you imported before that has a newer Ronin version (all packs).
local function AllUpdatable()
    local keys = {}
    for key in pairs(Ronin.Sequences) do keys[#keys + 1] = key end
    table.sort(keys)
    return UpdatableKeys(keys)
end
function Ronin.UpdateAll()
    if not EnsureGSE() then Print(RED .. "GSE is not loaded or too old.|r"); return end
    if InCombatLockdown() then Print(RED .. "Leave combat first.|r"); return end
    local keys = AllUpdatable()
    if #keys == 0 then Print(GREEN .. "Everything you imported is up to date.|r"); return end
    local byReg = {}
    for _, key in ipairs(keys) do
        local reg = PACK_OF[key] and PACK_OF[key].regkey or "Ronin"
        byReg[reg] = byReg[reg] or {}
        table.insert(byReg[reg], key)
    end
    local done = 0
    for reg, list in pairs(byReg) do
        local before = Snapshot(list)
        local ok, err = Ronin.InstallBatch(list, true, reg)
        if ok then RecordImport(list, before); done = done + #list else Print(RED .. "Update failed: " .. tostring(err)) end
    end
    if done > 0 then
        Print(GREEN .. "Updated " .. done .. " sequence(s).|r Your binds stay the same.")
    end
end

local loginCheck = CreateFrame("Frame")
loginCheck:RegisterEvent("PLAYER_LOGIN")
loginCheck:SetScript("OnEvent", function()
    if type(C_Timer) ~= "table" or not C_Timer.After then return end
    C_Timer.After(6, function()
        if not EnsureGSE() then return end
        local ok, keys = pcall(AllUpdatable)
        if ok and #keys > 0 then
            Print(GOLD .. #keys .. " of your Ronin sequence(s) have an update.|r Type |cffffffff/ronin update|r or open |cffffffff/ronin|r and press Update.")
        end
        if DB.toolsHint ~= ADDON_VERSION then
            DB.toolsHint = ADDON_VERSION
            Print("New: |cffffffff/ronin check|r (spells you miss), |cffffffff/ronin talents|r (copy the build), |cffffffff/ronin report|r (bug report text).")
        end
    end)
end)

local seqCount = 0
for _ in pairs(Ronin.Sequences) do seqCount = seqCount + 1 end
Print(ACCENT .. "Ronin V" .. ADDON_VERSION .. "|r loaded (" .. seqCount .. " sequences: Retail V" .. PACKS.retail.version ..
    ", Forever V" .. PACKS.forever.version .. "). Type |cffffffff/ronin|r")
