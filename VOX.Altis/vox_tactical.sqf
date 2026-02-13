/// spawn groups (on server)
/// spawn all groups on attacker/defender
/// spawn 1x random group on all counters on map (exc. original)

private _fnc_getCfg = {
	private _cfg = _this;
	private _list = [
		"b_inf", "b_motor_inf", "b_mech_inf","b_armor",
		"b_recon", "b_air", "b_naval",
		"b_support", "b_art", "b_plane",
		"o_inf", "o_motor_inf", "o_mech_inf", "o_armor",
		"o_recon", "o_air", "o_naval",
		"o_support", "o_art", "o_plane"
	];
	
	private _index = 0;
	{
		if (_cfg == _x) then {_index = _forEachIndex};
	}forEach _list;
	
	private _result = VOX_CONFIG select _index;
	_result
};

/// spawns group from vehicles list
private _fnc_spawnGroup = {
	/// [_pos, _vehicles, _group, _morale, _supplies, _icon, _name]
	private _pos = _this select 0;
	private _vehs = _this select 1;
	private _grp = _this select 2;
	private _morale = _this select 3;
	
	private _pos = [_pos, 0, VOX_SIZE / 2, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
	{
		if (random 1 <= _morale) then {
			/// TODO: add check if vehicle is a boat
			private _pos2 = [_pos, 0, 50, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
			[_pos2, random 360, _x, _grp] call BIS_fnc_spawnVehicle;
		};
	}forEach _vehs;
	
	if (_side == side player) then {
		{addSwitchableUnit _x}forEach units _grp;
	};
};


{
	if (_x select 4 != "hd_dot") then {
		
		private _color = _x select 1;
		private _unit = _x select 4;
		private _morale = _x select 5;
		private _cells = _x select 6;
		private _supplies = 1;
		
		private _side = west;
		if (_color == "ColorOPFOR") then {_side = east};		
		
		private _config = _unit call _fnc_getCfg;
		private _command = false;
		
		if !(_x in [VOX_ATTACKER, VOX_DEFENDER]) then {
			/// prevent spawning cmd group, select random to spawn 1x of
			_config = [_config select ceil random ((count _config) - 1)];
			_command = true;
		};
		 
		{
			private _icon = _x select 0;
			private _name = _x select 1;
			private _toSpawn = _x select 2;
			
			private _cell = _cells select floor random count _cells;
			private _row = _cell select 0;
			private _col = _cell select 1;
			private _pos = [_col * VOX_SIZE, _row * VOX_SIZE];	
			
			private _isVehicle = isClass (configFile >> "CfgVehicles" >> (_toSpawn select 0));
			private _isGroup = false;
			if (_isVehicle == false && count _toSpawn == 4) then {_isGroup = isClass (configFile >> "CfgGroups" >> (_toSpawn select 0) >> (_toSpawn select 1) >> (_toSpawn select 2) >> (_toSpawn select 3))};
			if (_isGroup) then {_toSpawn = configFile >> "CfgGroups" >> (_toSpawn select 0) >> (_toSpawn select 1) >> (_toSpawn select 2) >> (_toSpawn select 3)};			

			if (_isVehicle == false && _isGroup == false) then {
				diag_log format ["VOX ERROR: Invalid spawn config (Missing addon?) -> %1", _toSpawn];
			};
			
			private _vehicles = _toSpawn;
			
			if (_isGroup) then {

				_vehicles = [];
				private _grpCfg = "true" configClasses _toSpawn;
				{
					private _veh =  getText (_x >> "vehicle");
					_vehicles pushBack _veh;
				}forEach _grpCfg;
			};
			
			// [_pos2, random 360, _x, _group] call BIS_fnc_spawnVehicle;
			if (_isGroup or _isVehicle) then {
				private _group = createGroup [_side, true];
				if (_forEachIndex == 0 && _command) then {_group setGroupId ["Command Group"]};
				[_pos, _vehicles, _group, _morale, _supplies, _icon, _name] call _fnc_spawnGroup;
			}; 
		}forEach _config;
	};
}forEach VOX_GRID;
/// synch aircart to aristrike support
/// sync helicopters to gunship support
/// sync helicopters with cargoseat to transport support

/// set HQ setGroupId ["Command Group"];
/// start objective loop
/// spawn jukebox

/// if SUP is not present:
/// random ammo
/// random fuel
/// random skill

/// close map
/// debug group

private _martaGRP = createGroup sideLogic;
private _marta = "MartaManager" createUnit [
	[0, 0, 0],
	_martaGRP,
	"setGroupIconsVisible [true, false];"
];

/// open teamswitch menu and close map&menu
remoteExec ["VOX_FNC_CLOSEMAP", 0];
remoteExec ["VOX_FNC_SLOTTING", 0];