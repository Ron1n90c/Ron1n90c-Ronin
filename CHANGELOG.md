RONIN - GSE SUITE 4.3.1 - 2026-11-27   (Retail pack 7.3.1)
 * Talent strings for 4 more hero trees (checked against the current talent trees, read twice):
   - Frost DK Rider of the Apocalypse: Delve build. The macro no longer has Breath of Sindragosa (not in the Rider build).
   - Fury Warrior Mountain Thane: Mythic+ / Delve build. Bladestorm added to the cooldown step, and Rallying Cry is
     its one defensive (the Thane build has no Enraged Regeneration).
   - Guardian Druid of the Claw: Raid build. Lunar Beam and Red Moon added.
   - Elemental Stormbringer: Raid build.
 * Delve and Beginner versions (DPS and Heal): the defensive step now also has the spec filler,
   so that step is never a dead press when the defensive is on cooldown.
 * Fire Frostfire still has no string: almost nobody at the top plays it right now.

RONIN - GSE SUITE 4.3.0 - 2026-11-27   (Retail pack 7.3.0)
 * Talents first: every Retail Tank, DPS and Heal macro is now built on the talent build the top players use.
   Mythic+ and Raid builds come from the top Mythic+ players and the current Midnight 12.1.5 guides, and the
   import strings are in the GSE Notes of each macro ("Talents (import in game): Mythic+ / Delve: ... | Raid: ...").
   Import the string, pick the matching version, press. Every string was decoded and checked against the
   current talent trees before release.
 * Spells the build does not take are gone, spells it takes are in:
   - Blood DK: no Consumption (not in the top builds).
   - Vengeance DH: Soul Carver only in the Raid version (top Mythic+ players skip it).
   - Brewmaster: Exploding Keg only in the Raid version; Mythic+ keeps Niuzao at step 2.
   - Guardian Druid (Elune's Chosen): Raze out, Red Moon in.
   - Havoc DH (Fel-Scarred, both AoE macros): Essence Break added.
   - Frost DK Deathbringer: Breath of Sindragosa in the cooldown step (Raid build).
   - Fury Warrior Slayer: Odyn's Fury added, Wrecking Throw out.
   - Feral Druid: Incarnation added, Ravage out (a Druid of the Claw talent).
   - Elemental Stormbringer: Ancestral Swiftness out (a Farseer talent).
   - Enhancement Stormbringer: Sundering out. Arms Colossus AoE: Thunder Clap out.
   - Affliction Soul Harvester: Malefic Grasp out. Demonology: Summon Doomguard and Doom out.
   - Fire Sunfury: Frostfire Bolt out. Arcane AoE: Arcane Pulse out. Windwalker Shado-Pan: Invoke Xuen out.
   - Restoration Shaman Totemic: Unleash Life, Ancestral Swiftness and Downpour out; Farseer AoE: Downpour out.
 * Alt key: Arms and Fury use Storm Bolt, Affliction and Destruction use Mortal Coil (what the top builds take).
 * Hero trees without a current top build (Frost DK Rider, Elemental Stormbringer, Fire Frostfire, Fury Mountain
   Thane, Guardian Druid of the Claw) keep their macro and say so in the Notes.
 * WoW: Forever is the same as 4.2.4.

RONIN - GSE SUITE 4.2.4 - 2026-11-26   (Retail pack 7.2.1)
 * Vengeance Demon Hunter (Aldrachi Reaver + Annihilator, all versions): rebuilt on the current Midnight priority.
   Fracture came first in almost every step, so with haste it took nearly every press and Soul Cleave, Spirit Bomb,
   Fel Devastation, Soul Carver and the Sigils were rarely cast. Now the spenders come before Fracture (they only fire
   with Fury and Soul Fragments), Fel Devastation, Immolation Aura and the Sigils sit first in the busy steps and
   Fracture builds when there is nothing to spend.
 * Spirit Bomb (40 Fury + Soul Fragments) now always comes before Soul Cleave (30 Fury, eats 2 fragments).
   Before, Soul Cleave spent the Fury and the fragments first, so Spirit Bomb almost never fired.
 * Midnight: Fracture overrides Demon's Bite for Vengeance (Shear is gone). Every Vengeance step now has
   Demon's Bite right after Fracture, so the builder always fires, even when the game only knows the base spell.
   Without it there was no builder, no Fury and no Soul Cleave / Spirit Bomb.
 * Spirit Bomb now has a 25 s cooldown and Soul Cleave costs 35 Fury in Midnight: the priority follows that.
 * Vengeance Leveling: Spirit Bomb and Fel Devastation are now used.
 * Everything else is the same as 4.2.3.

RONIN - GSE SUITE 4.2.3 - 2026-11-26
 * Update button: GSE saves an import a few seconds later (out of combat). Ronin now waits for that before it
   remembers your sequence, so rows no longer show "Edited by you" by mistake and keep getting updates.
 * Your own edits are safe: when you changed a sequence in GSE and Ronin has a new version, Update leaves yours alone.
   The row says "Edited by you - new Ronin version: Overwrite ON + Import" so you can choose.
 * Rows that need an update now always say "Update available" (some said "Installed").
 * /ronin retail and /ronin forever open the role page. "Skip this screen" never opens an empty window.
 * Welcome screen: Tank, DPS + Heal.
 * Macros are the same as 4.2.2.

RONIN - GSE SUITE 4.2.2 - 2026-11-26   (WoW: Forever pack 4.1.1, checked against the Forever hotfixes up to 25 November)
 * Arms Warrior: Mortal Strike now needs its talent (Forever hotfix 23 November), so at 10-40 Heroic Strike fills
   the steps where Mortal Strike, Overpower or Execute are not ready. 40-60: Slam as backup in the opening step.
 * Fury Warrior: Heroic Strike added where Overpower / Execute (10-40) or Whirlwind / Bloodthirst (40-60) are on cooldown.
 * Warrior 1-10 (Arms and Fury): the Rend step now has Heroic Strike after it.
 * Shadow Priest 40-60: Mind Flay as filler in the Shadow Word: Pain / Mind Blast step.
 * Checked, no change needed: Summon Hawk (shares its cooldown with Arcane Shot), Balance Druid talent changes
   (Moonkin Form and Starfire stay), Enhancement Stormstrike cooldown, Affliction Wrack, Paladin Judgement / Exorcism.
 * Retail is the same as 4.2.1.

RONIN - GSE SUITE 4.2.1 - 2026-11-25
 * Fix: the Update button no longer imports the whole pack again. Ronin now remembers which sequences you imported
   after a /reload or a new login, so Update replaces only the sequences that really changed.
 * The first Update after this fix may still refresh your sequences once. After that only real changes show up.
 * Macros are the same as 4.2.0.

RONIN - GSE SUITE 4.2.0 - 2026-11-25
 * Windwalker Monk now has a separate AoE macro for both hero trees, like every other DPS spec
   (RoninDPS_Monk_WW_Cond_AoE and RoninDPS_Monk_WW_SPan_AoE), built from the Method Midnight multi-target lists:
   Fists of Fury / Whirling Dragon Punch / Strike of the Windlord first, Spinning Crane Kick as the main spender,
   Tiger Palm builds Chi for it, Rising Sun Kick / Rushing Wind Kick in between, Zenith Stomp during Zenith.
   Conduit: Celestial Conduit and Touch of Death in the pack steps. All five versions, Leveling included.
 * The single target Windwalker macros stay the same. Retail pack 7.2.0, 136 sequences.

RONIN - GSE SUITE 4.1.1 - 2026-11-25
 * The Ronin Discord server is closed: all Discord links are removed from the add-on, the website and the texts.
   Found a bug or have an idea? Leave a comment on CurseForge: https://www.curseforge.com/wow/addons/ronin
 * The Thank-you panel now links to CurseForge instead of Discord. Macros are the same as 4.1.0.

RONIN - GSE SUITE 4.1.0 - 2026-11-25   (the big one: every sequence reviewed, simulated and tested in game)
 This is the best pack I could make. Every sequence, every version, Retail and WoW: Forever, was checked against the current
 guides, simulated and tested in game. Now I will take a well deserved break and play more Azeroth myself.
 Thank you all for playing Ronin. See you in Azeroth!  - Ron1n

 * New: Update button on every installer page. Ronin compares each sequence you have in GSE with the one it ships:
   only the sequences that really changed show "Update available", and Update replaces just those (overwrite is automatic,
   your binds stay). A sequence you edited yourself in GSE shows "Edited by you" and Update leaves it alone
   (Import Selected with Overwrite ON still restores it). Select All / None is now one button.
 * New: after login Ronin tells you in chat when some of your imported sequences have an update. /ronin update updates all of them at once.
 * Vengeance: no more castsequences (they got stuck on Spirit Bomb / Fracture charges and pressed nothing).
   Plain ladders now: Fracture builds, Soul Cleave spends, Spirit Bomb in two steps, Fiery Brand + Soul Carver + Fel Devastation
   together in the cooldown step. Aldrachi: Reaver's Glaive first. Annihilator: Metamorphosis in the cooldown step.
   Fel Devastation is protected by one /stopmacro line. Leveling: Shear before you learn Fracture.
 * Protection Warrior: Thane now has Thunder Clap too (it only had Thunder Blast), Shield Block higher, Ignore Pain lower so
   Revenge and Shield Block get rage, Revenge / Shield Charge / Devastate as backups, Colossus: Revenge before Thunder Clap.
 * Brewmaster: Blackout Kick first, Chi Burst is back (still in the Midnight rotation), Niuzao + Exploding Keg together at the pull.
 * Protection Paladin: Hammer of the Righteous and Blessed Hammer in every step (whichever you talented), Hammer of Wrath higher,
   Consecration as the last filler, Divine Toll with Avenging Wrath at the pull.
 * Guardian: Elune's Chosen uses Moonfire as filler (Method), Ravage higher for Druid of the Claw, filler on every step.
 * Blood: Blood Boil as backup after the Marrowrend castsequence.
 * Delve / Beginner / Leveling: the defensive step now also has normal spells, so it never presses nothing when the defensive is on cooldown.
 * WoW: Forever Paladin (Tank + Ret): Judgement no longer uses up the seal in Forever, so the old seal castsequence recast the seal
   about every 3 seconds and emptied your mana. Now the seal is cast once (again after 28 s or in a new fight) and Judgement
   (off the global cooldown) is in every step. Tank: Holy Shield more often. Consecration stays on Alt (Tank and Ret).
 * WoW: Forever Protection Warrior: the shout castsequence waited on Thunder Clap and stopped the step. Now Thunder Clap is a
   normal spell, Demoralizing Shout once per fight (again after 28 s), Battle Shout once per fight, Shield Slam gets the rage
   first and Sunder Armor is the filler in the last steps only.
 * WoW: Forever Arms / Fury: Battle Shout once per fight.
 * WoW: Forever Cat: Shred only works from behind, so it is no longer inside the castsequence (it got stuck there in front of a mob).
   New order: Rake, Claw x3, Rip, Claw x3, Ferocious Bite.
 * WoW: Forever Frost Mage: Ice Lance out of the loop (weak unless the target is frozen; press it after Frost Nova). Ice Barrier on cooldown in combat.
 * Retail DPS (Method Midnight check):
   - Balance: Keeper of the Grove uses Solar Eclipse, Elune's Chosen uses Lunar Eclipse and Starfire as filler.
   - Arcane Sunfury: Prismatic Bolt added (both hero trees use it).
   - Devourer: Eradicate added next to Reap (talent choice).
   - Unholy: Necrotic Coil before Death Coil.
   - Fury: no Slam and no Odyn's Fury (not in the Midnight rotation); Whirlwind / Thunder Clap / Bladestorm instead.
   - Destruction Diabolist AoE: Chaos Bolt before Rain of Fire (Rain of Fire only pays off on big packs).
 * WoW: Forever DPS (Forever guide check):
   - Enhancement: no Lightning Bolt in melee from 10 (below 5 Maelstrom Weapon it resets your swing; press it at 5 stacks), Rage of the Farseer, Fire Nova.
   - Elemental: Earth Shock out of the loop (it shares the cooldown with Flame Shock; it stays on Ctrl), Lightning Mastery, Chain Lightning lower.
   - Affliction: Wrack (the Forever filler) before Shadow Bolt, the macro waits while you channel it.
   - Demonology: Searing Pain only once per target (Demonic Brand), Shadow Bolt is the filler.
   - Arcane: Fire Blast x3 then Pyroblast (Heating Up), Arcane Wrath, Arcane Power; Arcane Missiles no longer spammed.
   - Fire: Fire Blast x3 then Pyroblast, Scorch once per target (Improved Scorch), Combustion.
   - Hunter 40-60: Summon Hawk, Aimed Shot, Arcane Shot, Multi-Shot (spells that do not exist in Forever removed).
   - Priest: Devouring Plague and Vampiric Embrace added, Shadow Word: Death out of the loop (it hurts you when it does not kill).
   - Balance: always Wrath before the two Starfires (Eclipse charges).
   - Arms: Overpower before Mortal Strike, Slam after.
 * Retail Heal (Method Midnight check): Holy Paladin, Mistweaver and Resto Shaman already follow the guides.
   Resto Druid: Flourish out of the loop (it is for Tranquility, press it yourself), Nature's Swiftness goes with Regrowth.
 * Retail healer DAMAGE macros (for solo, Delves, leveling):
   - Resto Druid: Rip and Ferocious Bite only after three Shreds (they came at 1-2 combo points before), Sunfire woven in,
     Heart of the Wild with Convoke the Spirits.
   - Holy Paladin: no Light of Dawn (a heal that wasted Holy Power) and no Hammer of Wrath (Judgment turns into it during
     Avenging Wrath); Crusader Strike comes back during Avenging Wrath with Avenging Crusader.
   - Mistweaver: Thunder Focus Tea whenever it is ready. Resto Shaman: already as in the guide.
 * Retail Leveling versions (DPS and Heal) checked one by one:
   - The "no empty step" filler rule now covers the Leveling versions too.
   - Balance and Resto Druid: Moonfire / Sunfire only once per target (they were recast on every press); Balance gets the Eclipse buttons.
   - Feral: Rip and Ferocious Bite only after combo points (they came at 1 combo point); AoE: Swipe x3 then Primal Wrath.
   - Unholy: Putrefy, Festering Scythe and Soul Reaper (the Midnight core) in Leveling too.
   - Fury: no Heroic Strike. Elemental: Elemental Blast before Earth Shock. Windwalker: Strike of the Windlord, Touch of Death.
   - Affliction: Wither once per target. Destruction: Conflagrate and Soul Fire in single target. Demonology: Tyrant in its own step.
   - Holy Paladin: Eternal Flame before Word of Glory, Flash of Light / Holy Light instead of Consecration. Resto Druid: Lifebloom added.
   - Protection Paladin: Hammer of Wrath in more steps (Leveling, Delve / Beginner defensive step and the Consecration step).
 * WoW: Forever Heal (Forever guide check):
   - Paladin: Flash of Light is the main heal (best healing per mana), Holy Light now and then, Holy Shock out of the loop (poor on its own).
   - Druid: Regrowth is the main heal, Healing Touch only as a backup before Regrowth (it is weak in Forever), Rejuvenation in one step only.
   - Shaman: Riptide first when ready, Healing Wave main heal, Chain Heal for groups; Lesser Healing Wave stays on Shift.
   - Priest: Heal / Greater Heal main heals, Flash Heal only on Shift (it costs a lot of mana).
 * Retail pack 7.1.0, Forever pack 4.1.0. Same keys, same watermark.

RONIN - GSE SUITE 4.0.2 - 2026-11-25   (quality update after a full review of every sequence)
 * Destruction Warlock: fixed the step order. Mythic+ / Raid moved Incinerate up instead of the cooldowns, so Chaos Bolt
   and Conflagrate waited too often. Now Chaos Bolt comes first and Summon Infernal / Malevolence move up at the pull.
 * Windwalker and Brewmaster: Shift is now Vivify (Expel Harm was removed in Midnight). Brewmaster: Chi Burst removed too.
 * Every step that only had cooldowns now ends with the spec filler, so no press is wasted
   (Retribution, Windwalker, Unholy, Fire, Frost Mage, Demonology, Affliction, all cooldown steps, healer cooldown steps).
 * Demonology: Tyrant only in the cooldown step, Doomguard next to the Grimoires.
 * WoW: Forever: Paladin (Tank + Ret) Seal/Judgement steps get Holy Strike / Judgement as backup; Shaman Flame Shock steps get
   Lightning Bolt (put Lightning Shield on yourself before the pull); Destruction, Arcane and Hunter get a backup spell where a rune may be missing;
   Druid Heal: Swiftmend + Healing Touch (Wild Growth rune removed).
 * Retail pack 7.0.1, Forever pack 4.0.2. Same keys, same watermark.

RONIN - GSE SUITE 4.0.1 - 2026-11-24
 * FOREVER DPS: new Balance Druid (levels 1-10 / 10-40 / 40-60): Moonfire, Faerie Fire and Insect Swarm once per target,
   Wrath + 2x Starfire, Moonkin Form kept up from 40. Shift = heal on yourself, Ctrl = Entangling Roots, Alt = Faerie Fire / Hurricane at the cursor.
 * New Discord invite everywhere.

RONIN - GSE SUITE 4.0.0 - 2026-11-24   (big update: HEAL is here)
 * HEAL (new role): Retail Mistweaver, Holy Paladin, Restoration Druid, Restoration Shaman - Heal single target, Heal AoE
   and a DAMAGE macro each. WoW: Forever Paladin, Druid, Shaman, Priest. Hover a frame and hold the key: it heals the friend
   under your mouse, otherwise you. Emergency cooldowns stay in your hands.
 * RETAIL DPS: new Hunter (Beast Mastery, Marksmanship, Survival), Shaman (Elemental, Enhancement), Warlock (all specs),
   Mage (all specs) and Devourer Demon Hunter. Hunters call / revive their pet by themselves.
 * FOREVER DPS: new Hunter, Warlock, Mage and Priest (damage for leveling).
 * VERSIONS now each do their own job: Mythic+ (cooldowns at the pull), Raid (keeps your target), Delve (solo, one defensive),
   Beginner (one defensive), Leveling. Only ONE defensive in the loop, so they never all fire together.
 * INSTALLER: 2 columns + scroll, classes sorted, real versions in the titles. Retail pack 7.0.0, Forever pack 4.0.0.
 * Every rotation checked against the Midnight 12.1.5 and WoW: Forever guides. Thanks to everyone who tested!

RONIN - GSE SUITE 3.0.3 - 2026-11-23
 * Same as 3.0.2 (new welcome text); release is now started by the automatic workflow. No macro changes.

RONIN - GSE SUITE 3.0.2 - 2026-11-23
 * New welcome text in the Thank-you panel. No macro changes.

RONIN - GSE SUITE 3.0.1 - 2026-11-22
 * Authorship protection: every imported sequence carries an invisible Ronin signature. New LICENSE file.
 * No macro changes.

RONIN - GSE SUITE 3.0.0 - 2026-11-22
 * New name: Ronin - GSE SUITE. Now Tank AND DPS in one add-on.
 * RETAIL 6.0.0: 32 DPS sequences (Unholy/Frost DK, Havoc DH, Ret, Fury, Arms, WW, Feral, Balance), single target + AoE per hero tree.
 * New LEVELING version in every Retail macro (tank and DPS) for the way to level 90. Pick it by hand in GSE.
 * Midnight 12.1.5 spell check on every spec. No /startattack anywhere.
 * FOREVER 3.0.0: new level ranges 1-10 / 10-40 / 40-60. DPS added: Ret Paladin, Arms + Fury Warrior, Feral Cat, Enhancement + Elemental Shaman.
 * Forever keys: Shift = heal, Ctrl = interrupt (Paladin Hammer of Justice), Alt = class extra. Prot Paladin: Exorcism removed. Prot/Arms Warrior: Rend added.

RONIN (add-on) 2.2.0 - 2026-11-18
 * Forever now runs in Priority mode, like Retail.

RONIN FOREVER pack 1.9.0
 * Priority mode: one Priority loop per version, the most important spells come up most often. Tested on Protection Paladin and Protection Warrior.
 * Same keys (Shift = heal, Alt = CC, Ctrl = interrupt) and spell IDs as 1.8.0.
 * Import with Overwrite ON to replace the old sequences, then put the macro on the bar again.

RONIN RETAIL pack 5.2.1 - unchanged.

RONIN (add-on) 2.1.0 - 2026-11-18
 * Forever macros now use spell IDs instead of names: they work on any client language and the macros are shorter.
 * Same keys as before: Shift = heal, Alt = CC, Ctrl = interrupt.

RONIN FOREVER pack 1.8.0
 * Spell IDs (rank 1). The client casts the highest rank you know. Tested on Protection Paladin and Protection Warrior.
 * Feral Druid uses the same method; Rebuke, Hammer of the Righteous and Faerie Fire (Feral) stay by name.
 * Import with Overwrite ON to replace the old sequences.

RONIN RETAIL pack 5.2.1 - unchanged.

RONIN (add-on) 2.0.1 - 2026-11-17
 * Fixed: Vengeance Demon Hunter showed "Incomplete" (GSE cuts sequence names to 28 characters).
 * Welcome screen is cleaner: the orbiting ring and sparks around the logo are gone (soft glow stays).
 * New thank-you panel: "From one tank to another..." plus your keys for each pack.
 * Installer finds sequences even if GSE shortened their name.

RONIN RETAIL pack 5.2.1
 * Vengeance Demon Hunter / Annihilator is now named RoninDH_Vengeance_Annihil (28 character GSE limit).
   Delete the old "RoninDH_Vengeance_Annihilato" in GSE and bind the new one. Everything else unchanged.

RONIN FOREVER pack 1.7.0 - unchanged.

RONIN (add-on) 2.0.0 - 2026-11-17
 * One add-on for both worlds: Ronin replaces Ronin Retail (RoninInstaller) and Ronin Forever.
   Delete the old folders before installing.
 * Welcome screen with the Ronin logo and two buttons: Forever (glowing infinity) and Retail (violet W).
 * Resizable installer, thank-you panel (Ko-fi / Patreon / website), add-on icon.
 * Installer shows Up to date / Update available / Not installed for every class (works with the newest GSE).
 * /ronin debug prints what the add-on sees in GSE.

RONIN RETAIL pack 5.2.0
 * Same sequences as 5.1.x (now shipped inside the Ronin add-on).

RONIN FOREVER pack 1.7.0
 * Druid: Enrage removed (it lowers armor).
 * Druid: Faerie Fire and Demoralizing Roar re-apply on every new target and then every 25 / 30 s.
 * Druid: Bear Form while leveling, Dire Bear Form in the 60 version (keeps every step under 255 characters).
 * Modifiers unchanged: Shift = heal, Alt = CC, Ctrl = interrupt.
