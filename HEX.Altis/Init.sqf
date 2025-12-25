call compile preprocessFile "HEX\Global\Functions.sqf";

if (isServer) then {
	call compile preprocessFile "HEX\Server\Config.sqf";
	call compile preprocessFile "HEX\Server\Grid.sqf";
};

///teamSwitch;
call compile preprocessFile "HEX\Local\Strategic.sqf";
call compile preprocessFile "HEX\Local\Ambient.sqf";

///[] call BIS_fnc_jukebox; /// maybe add this at start of tactical phase?

/// ToDo:
/// Add onPLayerKilled event handler
/// Open slotting / switching menu
///
/// Fix stuff if game is loaded from save (This file mostly?)

/// Description;
///
/// HEX is a persistent mission, where real-time battles are generated from hex&counter wargame system.
/// Playable in singleplayer, COOP against HEX_AI, or hosted PVP multiplayer.
/// Customizable factions (DLC or mod) with freedom of forces scale, ratio and composition.
///
/// Players can choose the role of Commander, Leaders or Soldiers.
/// Commander dictates strategic actions on hex board, and tactics with High Command interface.
/// Leaders put Commander's orders in action, with a squad of Soldiers in real-time combat.
///
/// Campaign is split in multiple two-part phases, with progressing time and weather:
/// Strategic phase: Turn-based manouvers of counters on strategic hex-board.
/// Tactical phase: Connected counters are played out in real-time battle.
///
/// Counters are divided in two types: Primary and Auxiliary.
/// Primary (Infantry, Motorized, Mechanized, Armored, Recon) spawn tactical groups.
/// Auxiliary (Artillery, Support, Aircraft, Helicopters, Anti-Air) spawn strategic units.
///
/// Victory over enemy counters is achieved by capture of area in tactical battle.
/// Counters captured will be initially disorginized, and ultimately destroyed.
/// Campaign victory is achieved by destroying enemy Headquarters counter.
///
/// Copyright: Arma Public Licence (APL)

/// TBD: End scenario with list of casualities

/// Zero Menu:
/// Title, Author, Version
/// Cool picture
/// Description List
/// "WAITING FOR HOST" text?

/// First Menu:
/// Title, Author, Version
/// Cool picture
/// Continue Campaign / Default Campaign
/// New Campaign

/// Second Menu:
/// West / East faction
/// Current West / Selectable West
/// Current East / Selectable East
/// Scenario Direction
/// First Turn West/East
/// Experimental toggle
/// "START CAMPAIGN"

/// Third Menu:
/// Turn info
/// End Turn

/// Fourth menu:
/// Tactical Briefing
/// "To battle!" button

/// Fifth Menu:
/// Respawn / Slotting screen
/// store variable in group with spawning icon
/// On player dead switch back to ghost unit???

/// Spawn reinforcements to slot into (total 10 units) / side ????
/// if count units _side < 10 then (exc. ghosts) spawn group... ???

/// Sixth menu:
/// Tactical Debriefing
/// "Save & Continue" button
/// "Save & Exit" button

/// Sources used: 
/// https://www.youtube.com/watch?v=kDFAHoxdL4Y&list=PLrFF_4LjPgISFZ6TzRi82O153ZQp5H-TJ