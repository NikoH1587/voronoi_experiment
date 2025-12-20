call compile preprocessFile "HEX\Global\Functions.sqf";

if (isServer) then {
	call compile preprocessFile "HEX\Server\Config.sqf";
	call compile preprocessFile "HEX\Server\Grid.sqf";
};

sleep 1;
removeSwitchableUnit OFFICER_EAST;
removeSwitchableUnit LEADER_EAST;
removeSwitchableUnit SOLDIER_EAST;
teamSwitch;
call compile preprocessFile "HEX\Local\Strategic.sqf";

///[] call BIS_fnc_jukebox; maybe add this at start of tactical phase?



/// First Menu:
/// Title, Author, Version
/// Cool picture?
/// Continue Operation 
/// Start Operation 
/// Import operation
/// {Import field}
/// For clients says Waiting for host to begin

/// Second Menu:
/// West / East faction
/// Current West / Selectable West
/// Current East / Selectable East
/// Scenario Direction
/// First Turn West/East
/// Experimental toggle
/// Export field
/// Start Operation

/// Third Menu:
/// Commander Voting
/// Time
/// Weather forecast

/// Sources used: 
/// https://www.youtube.com/watch?v=kDFAHoxdL4Y&list=PLrFF_4LjPgISFZ6TzRi82O153ZQp5H-TJ