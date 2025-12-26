/// get all functions
call compile preprocessFile "HEX\Global\Functions.sqf";

LOC_ADMIN = false;
LOC_SINGLEPLAYER = false;
LOC_COMMANDER = false;

private _netMode = call BIS_fnc_getNetMode;
if (_netMode == "SinglePlayer") then {
	LOC_ADMIN = true;
	HEX_PHASE = "LOADING";
	publicVariable "HEX_PHASE";
	remoteExec ["HEX_FNC_LOAD", 0, true];
	{deleteVehicle _x}ForEach units HEX_ADMIN; /// delete west slotting units
	{deleteVehicle _x}ForEach units HEX_OFFICER; /// delete east slotting units
	removeSwitchableUnit HEX_ADMIN; /// remove slotting to ghost unit
};

/// start campaign on hosted
if (_netMode != "Dedicated" && _netMode != "SinglePlayer" && isServer) then {
	LOC_ADMIN = true;
	HEX_PHASE = "LOADING";
	publicVariable "HEX_PHASE";
	remoteExec ["HEX_FNC_LOAD", 0, true];
};

/// Start campaign on dedicated
if (_netMode == "Dedicated") then {
	if (player == HEX_ADMIN) then {
		LOC_ADMIN = true;
		HEX_PHASE = "LOADING";
		publicVariable "HEX_PHASE";
		remoteExec ["HEX_FNC_LOAD", 0, true];
	};
};

(group test1) setVariable ["HEX_ICON", "b_inf", true];

///[] call BIS_fnc_jukebox; /// maybe add this at start of tactical phase?

/// ToDo:
/// make changes to onPLayerKilled event handler
/// Open slotting / switching menu
///
/// Fix stuff if game is loaded from save (This file mostly?)
///
/// Add texture to menus, oversized texture of a map case, with some kind of grided paper + stains?
/// 
/// Replace Strategic layer janky map overlay with just a GUI map? but then no funni markers :<


/// Description;
///
/// HEX is a persistent mission, where real-time battles are generated from hex&counter wargame system.
/// Playable in singleplayer or multiplayer up to 20 players.
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

/// First Menu: /// "LOADING"
/// Title, Author, Version
/// Cool picture
/// Select West / East Commanders
/// Commander select 0 == AI commander
/// Continue Campaign / Default Campaign
/// New Campaign

/// Second Menu (new campaign): /// "NEWSAVE"
/// West / East faction
/// Current West / Selectable West
/// Current East / Selectable East
/// Scenario Direction
/// First Turn West/East
/// Experimental toggle
/// "START CAMPAIGN"

/// Third Menu: /// "STRATEGIC"
/// Turn info
/// End Turn

/// Fourth menu: /// "BRIEFING"
/// Tactical Briefing
/// "To battle!" button

/// Fifth Menu: /// "TACTICAL"
/// Respawn / Slotting screen

/// Spawn reinforcements to slot into (total 10 units) / side ????
/// if count units _side < 10 then (exc. ghosts) spawn group... ???

/// Sixth menu: /// "DEBRIEFING"
/// Tactical Debriefing
/// "Save & Continue" button
/// "Save & Exit" button

/// Sources used: 
/// https://www.youtube.com/watch?v=kDFAHoxdL4Y&list=PLrFF_4LjPgISFZ6TzRi82O153ZQp5H-TJ