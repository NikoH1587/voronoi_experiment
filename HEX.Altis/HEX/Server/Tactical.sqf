/// Spawn groups on server (variable in group)
{
	private _pos = _x select 2;
	private _posX = _pos select 0;
	private _posY = _pos select 1;
	private _posZ = _pos select 2;
	private _type = _x select 3;
	private _side = _x select 4;
	private _state = _x select 6;

	private _factions = [HEX_WEST];
	if (_side == east) then {_factions = [HEX_EAST]};
	/// spawn some infantry even for strategic counters
	private _amount = 9;
	private _armor = false;
	private _icons = ["\A3\ui_f\data\map\markers\nato\b_inf.paa", "\A3\ui_f\data\map\markers\nato\n_inf.paa", "\A3\ui_f\data\map\markers\nato\o_inf.paa"];
	if (_type in ["b_recon", "o_recon"]) then {_amount = 6; _icons = ["\A3\ui_f\data\map\markers\nato\b_recon.paa", "\A3\ui_f\data\map\markers\nato\n_recon.paa", "\A3\ui_f\data\map\markers\nato\o_recon.paa"]};	
	if (_type in ["b_motor_inf", "o_motor_inf"]) then {_amount = 6; _icons = ["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\n_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa"]};
	if (_type in ["b_mech_inf", "o_mech_inf"]) then {_amount = 3; _icons = ["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\n_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa"]};
	if (_type in ["b_armor", "o_armor"]) then {_armor = true; _amount = 3; _icons = ["\A3\ui_f\data\map\markers\nato\b_armor.paa", "\A3\ui_f\data\map\markers\nato\n_armor.paa", "\A3\ui_f\data\map\markers\nato\o_armor.paa"]};
	if (_type in ["b_hq", "o_hq", "b_support", "o_support", "b_art", "o_art", "b_antiair", "o_antiair", "b_air", "o_air", "b_plane", "o_plane"]) then {_amount = 3};
	
	private _configs = [_factions, _icons] call HEX_SRV_FNC_GROUPS;
	
	for "_i" from 1 to _amount do {
		private _select = _configs select floor random count _configs;
		private _config = "true" configClasses _select;
		if (_armor) then {_config = [_config select 0]};
	
		private _group = createGroup _side;
		_group setVariable ["HEX_ICON", _type, true];
		private _pos2 = [[[_pos, HEX_SIZE / 2]], ["water"]] call BIS_fnc_randomPos;
		private _crews = [];
		private _dismounts = false;
		{
			private _rank = getText (_x >> "rank");
			private _vehCfg = getText (_x >> "vehicle");
		
			/// check if vehicle isMan, use createUnit
			/// if vehicle is not man, use createvehicle and create
			private _cfg = (configFile >> "CfgVehicles" >> _vehCfg);
			private _isMan = getNumber (_cfg >> "isMan");
		
			if (_isMan == 1) then {
				private _unit = _vehCfg createUnit [_pos2, _group, "", 1, _rank];
				_dismounts = true;
			} else {
				private _spawned = [_pos2, 0, _vehCfg, _side] call BIS_fnc_spawnVehicle;
				private _vehicle = _spawned select 0;
				private _crew = _spawned select 1;
				private _vehGrp = _spawned select 2;
				_crews append _crew;
				(_crews select 0) setRank "CORPORAL";
				_vehGrp setVariable ["HEX_ICON", _type, true];
			};
		}forEach _config;
		
		if (count _crews > 0 && _dismounts) then {
			private _oldGrps = [];
			{
				_oldGrps pushbackUnique (group _x);
			}forEach _crews;
			_crews joinSilent _group;
			{deleteGroup _x}forEach _oldGrps;
		};
		if (_dismounts == false) then {deleteGroup _group};
		if (_side == west && HEX_SINGLEPLAYER) then {{addSwitchableUnit _x}forEach (units _group)};
		
		_group addWaypoint [_pos, HEX_SIZE];
	};
}forEach HEX_TACTICAL;

{
	private _pos = _x select 2;
	private _type = _x select 3;
	private _side = _x select 4;
	private _state = _x select 6;
	
	private _factions = [HEX_WEST];
	if (_side == east) then {_factions = [HEX_EAST]};	
	
	private _configs = [_factions, _type] call HEX_SRV_FNC_VEHICLES;
	/// if (_side == west) then {hint str _configs, copyToClipboard str _configs};
}forEach HEX_STRATEGIC;

/// Spawn Capture points on server (name after counter)
/// Start 1h counter, call debriefing after
/// if all groups killed / all points captured:
/// stop counter short of time

HEX_PHASE = "TACTICAL";
publicVariable "HEX_PHASE";

/// Close tactical briefing locally
remoteExec ["HEX_LOC_FNC_CLOSEBRIEFING", 2, false];

/// Open Slotting menu locally with JIP
remoteExec ["HEX_LOC_FNC_SLOTTING", 0, true];