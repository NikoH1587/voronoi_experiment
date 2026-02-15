/// VOX: Campaign Generator

/// TODO: make savegame compatible

/// check if player commander
VOX_LOC_COMMANDER = true;
if (player == CMD_WEST) then {VOX_LOC_COMMANDER = true};
if (player == CMD_EAST) then {VOX_LOC_COMMANDER = true};

VOX_SINGLEPLAYER = false;
if ((call BIS_fnc_getNetMode) == "SinglePlayer") then {
	VOX_SINGLEPLAYER = true;
	addMissionEventHandler ["teamswitch",{(_this select 0) enableAI "teamswitch"}];
};

/// global functions
private _functions = execVM "vox_functions.sqf";
waitUntil {scriptDone _functions};

if (isServer) then {
	[] spawn {
		///private _custom=  execVM "vox_custom.sqf";
		///waitUntil {scriptDone _custom};
		private _default = execVM "vox_default.sqf";
		waitUntil {scriptDone _default};
		private _generate = execVM "vox_generate.sqf";
		waitUntil {scriptDone _generate};
		["vox_strategic.sqf"] remoteExec ["execVM"];
		{removeSwitchableUnit _x}forEach allUnits;
	};
};

addMissionEventHandler ["TeamSwitch", {
	params ["_previousUnit", "_newUnit"];
	if (VOX_SINGLEPLAYER) then {
		_previousUnit enableAI "TEAMSWITCH";/// set ai to teamswitch
		if (leader _newUnit == _newUnit) then {
			if (side _newUnit == west) then {SUP_WEST synchronizeObjectsAdd [_newUnit]};
			if (side _newUnit == east) then {SUP_EAST synchronizeObjectsAdd [_newUnit]};
		};
	
		/// re-create marta, breaks on teamswitch
		private _martaGRP = createGroup sideLogic; 
		private _marta = "MartaManager" createUnit [ 
			[0, 0, 0], 
			_martaGRP, 
			"setGroupIconsVisible [true, false];" 
		];
		
		/// re-sync HCM, breaks on teamswitch
		private _martaicon = (group _newUnit) getVariable "MARTA_customIcon";
		private _martaicon = _martaicon select 0;
		private _isLeader = leader _newUnit == _newUnit;
		if (_isLeader && _martaicon == "b_hq") then {
			systemChat "Access High-Command module with ctrl+space";
		};
		if (_isLeader && _martaicon == "o_hq") then {
			systemChat "Access High-Command module with ctrl+space";
		};
	};
}];