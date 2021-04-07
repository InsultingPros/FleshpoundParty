# FP Party Changelog

## [Version 2.18] - 21.03.2019

- New trader boost function, custom pawn removed!
- Updated helper class, messaging functions.
- Moved colors, trader boost value to config file.
- Added map dependant spawnrate/maxzeds in config.
- Must kill last 10 zeds much faster (i hope).
- Traders open on 1st wave.

## [Version 2.17] - 21.03.2019

### Added

- System for automatically incrementing the NextSpawnTime between 1 and 6 players. 
    You just have to input the BaseSpawnTime (6 players) and PeakSpawnTime (1 player) in the config.
    and it will automatically increment between player amounts for easy balancing and tweaking.
    However, it get twice as faster for 4+ players than for 1-3P.
- Config var for SinMod multiplier.
- ZedTime activation when a player dies. Bool in config.
- Trader speed boost, requested by Kaio and easily found working code in ScrN sources. 
    Just needed to make a custom player controller. Nikc's favorite feature m8 :yoba:
- Specific maps to only be affected by MDTP because some maps break with a global MDTP (transit, fuck you). This is a shitty, temporary solution.
- Made a function for automatically adjusting MaxZeds depending on the amount of alive players 'AdjustMaxZeds()'. Works but not in real time unfortunately. FIX THIS!! 
    Commented out MaxZed config stuff as a result of this because this function is on a timer and will override it anyway.
- Custom "last player alive" message when everyone dies. Also plays a sound but only one player can hear it for some reason. Will fix later.

### Changed

- Kill stuck zeds function to only work on waves 2 - 10. Changed NumMonsters from 5 to 8 because we use Admin kill anyway
    Big zeds will also die now if there are 4 or less and haven't been seen for a long time.
- If bForceSpawnrate = false then the map's original spawnrate will be used EXCEPT if it's 0.5 and below or 3 and above
    so maps don't become too OP or too fucking slow. The spawnrate will be set to 1.5 to maps in this range.
    OP maps = HE maps and doom2. Slow maps = Bedlam, fucking 4 sr.

## [Version 2.16] - 7.02.2019

### Changed

-Heavily tweaked 2.15 settings
### Removed

-Server info line
-Scrakes from pat wave

## [Version 2.15] - 12.01.2019

### Fixed

- Message for pat wave now works correctly.
- 60 second trader time on FP wave and above now works correctly.

### Changed.

- Lowered NextSpawnTime for SineMod from 2.0 to 0.5 for a faster and more consistent ass raping. Line 678.
- Spawn rate and MaxZeds is now dynamic instead of being a fixed global value for all maps, and will higher or lower depending on the map's spawn rate.

### Added

- Message for big zed wave (wave 11)

## [Version 2.14] - 12.04.2018

### Fixed

- Some fuckup in KillZeds cmd.

### Changed

- Game hints made more awesome.
- Game made faster for lower amounts of player.
- Made a separate config for game.

### Removed

- Short game (4 waves).
- Trader messages when you are close to wave clearing. Because i simply hate her ^_^


## [Version 2.13] - 13.01.2017

### Added

- Custom monster collection and fixed incorrect squad spawns in FP waves.

### Changed

- All color tags are removed for WebAdmin in BroadcastText(). No more unreadable garbage in the console.

### Fixed

- Fixed zeds amount for Medium / Short gamelenghts.


## [Version 2.12] - 02.01.2017

### Added

- Trader, FP, Pat wave messages / RGB colors are now editable in config. You can use %b, %w, %y, %r, %g, %p color tags with them.
- Dropped Dosh doesnt disappear when waves switch.

### Changed

- Good old 10 seconds initial time is back.
- Broadcast color. Similar to a+.
- FP and Pat waves have 60 seconds trader time no matter what you set for others.

### Fixed

- Buggy 'AntiBlocker'.
- Respawned players have proper collision, depending on 'AntiBlocker' or config.
- Log spam from BuzzSaw removing function.

### Removed

- Objective mode checks in InitGame(). Now KFO maps must be 100% playable.
- 'KeepWeapons' and appropriate function - OP and unnecessary for this mod.
- AllowBecomeActivePlayer() fix. Kinda no needed and no one noticed what it does.

## [Version 2.11] - 17.12.2016

### Added

- Config bool 'bForceMDTP'. If you dont want to override default numbers set this to false.
- Debug cmd - 'AntiBlocker (OFF)'.
- Debug cmd - 'MZ'. Changes MaxZeds.

### Changed

- DramaticEvent() optimisation.
- SetupPickups()- limited weapon spawns.

### Fixed

- Some of the loading hints.
- Stuck zed killing function.

### Removed

- Timer(). Trader messages moved to OpenShops() / CloseShops().
- 'bUseDefaultZVWaveDisabling'. We dont use custom maps :v

## [Version 2.10] - 06.11.2016

### Added

- Config bool 'bDisableAntiblocker'. If true players wont go through each other during trader.
- Config bool 'bForceSpawnrate'. If true, game uses our config spawnrate.

### Changed

- 'settrader' affects ongoing trader countdown.
- Optimised spawnrate related code.
- Respawn dosh increased from 4k to 8k by default.

### Fixed

- A little fuckup with broadcasting.

### Removed

- Built in mutloader. You never used it, right Joabyy? D:

## [Version 2.9] - 27.10.2016

### Added

- BroadcastToALL now can log messages. All debug cmds have it by default.

### Fixed

- NoDrama / KeepWeapons won't exec if you already have desired option enabled.
- Yet another try to remove annoying late joiner messages.
- Removed SteamData from Killed().
- Duplicated code in InitGame().

## [Version 2.8] - 26.09.2016

### Fixed

- [probably] The issue when infinite amount of players could join when team the team was full.
- Some fixes to RestartPlayer and AllowBecomeActivePlayer functions.

### Changed

- 'Pubs' cmd will set fakes amount both for bUseOriginalFakes=False / True.

## [Version 2.7] - 24.09.2016

### Added

- Config int - 'TraderTime'.
- Debug cmd - 'SetTrader (value)'. If you dont type the value it will use 'TraderTime'.
- Trader warning for FP only waves.

### Fixed

- Function that is responsible for killing last 5 zeds of the wave, now doesnt touch FPs and SCs. And fixed accessed none 'C' log spam.
- Fixed issue when banned and kicked players were able to join again :D
- Fixed some TWI nonsense in boss spawning code + now zed's AI will disable in final wave. No more need to find and kill all zeds.

### Changed

- Decreased MaxPlayers 12->6. We barely collect 6 players..

## [Version 2.6] - 21.09.2016

### Added

- Buzzsaws destroy on wave switch.
- Config bool - 'bDisableSlomo'.
- Debug cmd - 'NoDrama (OFF)'.
- Config bool - 'bKeepDroppedWeapons'. True = only knife / welder / syringe will be removed on wave switch, everything else will stay on the ground. False = works like vanilla.
- Debug cmd - 'KeepWeapons (OFF)'.
- Debug cmd - 'SR (value)'. Allows to change spawnrate.
- Debug cmd - 'GetVersion'. Broadcasts FPP version.

### Fixed

- 'KillZeds' cmd. No more log spam and disabling steamstats.
- Fixed broadcasting "traders open" while map is switched and there are no players.

### Changed

- Ammo and weapon pickups have Hard dfficulty percentage for spawning.
- Disabled garbage collection for clients on wave switch. Trader -> wave switches become lag free.
- Removed all multipliers depending from difficulty. Final resulting values match the vanilla HOE.

## [Version 2.5] - 10.09.2016

### Added

- Debug cmd - 'Pubs (value)'. Sets alternative fakes if you have bUseOriginalFakes=False.

### Changed

- Updated wavemasks.
- Removed custom monster collection for now. Coz reasons.
- Removed trader path (whisp) for not to confuse players. If they still confuse - advice them to read the chat from times to times :v
- Players have collision during trader time.

## [Version 2.4] - 6.08.2016

### Added

- Added custom FPMonsterCollection. If you are not lazy you can edit special sqauds there. In theory now its much safer to dick around and not worry that other votings will get bugged after FPP game.
- Config bool - 'bRespawnOnPat'. False = you wont respawn after Pat death [DEPRECATED].
- Config int - 'SimulatedFakes'. If its higher than real players game will use it to calculate zed amount. Doesnt use player slots, so everyone can join.

### Changed

- Cleaned server info from unnecessary stuff (blame my OCD), added wave info and FPP version.
- Fixed / added game hints.

## [Version 2.3] - 1.08.2016

### Added

- Config bool - 'bUseDefaultZVWaveDisabling'. True = uses default zombie volume settings. This is used only in a few maps (from thousands out there), but still can be usefull to have all ZVs enabled.

### Changes

- Changed game hits. Do you like them, fgt?!
- Dead or not spawned teammates doesnt add zeds to the wave.
- Made game faster for >4 players. If you think its too fast raise the "spawnRate" in the config.
- Optimised shit tons of code for "MatchInProgress" state. So bugs can happen :v
- Possible fix for bad squad spawning. + it should work a bit quicker.
- Added another check for zombie volumes, so they wont try to spawn zeds they cant.

## [Version 2.2] - 28.07.2016

### Changed

- Trader broadcasting now uses teamsay instead of level.game.broadcast. Means more clear text that can see everyone.

## [Version 2.1] - 20.07.2016

### Added

- Mutator config file. MDTP (minmal spawn distance), dosh, maxZeds, spawn rate and squads can be configured from there.
- You can vote for a different GameLength. GameLenght= 0-short / 1-medium / 2-long.
- Built in MutLoader. Add your mutators after 'AutoLoadMutators=' lines in the config.

### Changed

- Renamed package to 'FleshpoundParty'.
- Decreased MDTP from 12m to 9m by default.
- Spawn rate forced to 1.5.
- 1-st wave is more intense.

## [Version 2.0 'Initial release'] - 29.05.2016

### Added

- All traders open during trader time.
- Added trader broadcast to inform players about ^.
- MDTP - minimal distance to players. Prevents zed spawning in this radius.