/// VOX: Campaign Generator

/// TODO: make savegame compatible

/// check if player commander
VOX_LOC_COMMANDER = false;
if (player == CMD_WEST) then {VOX_LOC_COMMANDER = true};
if (player == CMD_EAST) then {VOX_LOC_COMMANDER = true};

if ((call BIS_fnc_getNetMode) == "SinglePlayer") then {
	VOX_SINGLEPLAYER = true;
	addMissionEventHandler ["teamswitch",{(_this select 0) enableAI "teamswitch"}];
};

/// global functions
private _functions = execVM "vox_functions.sqf";
waitUntil {scriptDone _functions};

if (isServer) then {
	private _default = execVM "vox_custom.sqf";
	///private _default = execVM "vox_default.sqf";
	///waitUntil {scriptDone _default};
	///private _generate = execVM "vox_generate.sqf";
	///waitUntil {scriptDone _generate};
	///["vox_strategic.sqf"] remoteExec ["execVM"];
	///{removeSwitchableUnit _x}forEach allUnits;
};