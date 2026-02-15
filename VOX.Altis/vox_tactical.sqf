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

VOX_FNC_CLASSIFY = {
	private _side = _this select 0;
	private _vehs = _this select 1;
	private _marker = "inf";
	
	private _inf = false;
	{if (_x isKindOf "Man") then {_inf = true}}forEach _vehs;
	
	{
		private _entry = configFile >> "CfgVehicles" >> _x;
		
		if (isClass _entry) then {
			private _amo = getNumber (_entry >> "transportAmmo") > 0;
			private _plo = getNumber (_entry >> "transportFuel") > 0;
			private _rep = getNumber (_entry >> "transportRepair") > 0;
			private _sup = _amo or _plo or _rep;

			private _sta = getNumber (_entry >> "hasDriver") == 0;
			private _art = getNumber (_entry >> "artilleryScanner") == 1 && !_sta;
			private _mor = getNumber (_entry >> "artilleryScanner") == 1 && _sta;
			private _aaa = toLower getText (_entry >> "editorSubcategory") == "anti-air";
			private _pad = toLower getText (_entry >> "displayName") == "missile specialist (aa)";

			private _car = toLower getText (_entry >> "simulation") == "carx";
			private _apc = toLower getText (_entry >> "simulation") == "carx" && _inf;
			private _ifv = toLower getText (_entry >> "simulation") == "tankx" && _inf && !_sta;
			private _arm = toLower getText (_entry >> "simulation") == "tankx" && !_sta;
			
			private _hel = toLower getText (_entry >> "simulation") == "helicopterrtd";
			private _pla = toLower getText (_entry >> "simulation") in ["airplanex", "airplane"];
			private _uav = toLower getText (_entry >> "vehicleClass") == "autonomous";	
			
			private _nav = toLower getText (_entry >> "simulation") in ["shipx", "submarinex"];
			
			private _icon = "inf";
			
			if (_arm) then {_icon = "armor"};			
			if (_ifv) then {_icon = "mech_inf"};
			if (_car) then {_icon = "unknown"};
			if (_apc) then {_icon = "motor_inf"};
			
			if (_aaa or _pad) then {_icon = "antiair"};
			if (_art) then {_icon = "art"};
			if (_mor) then {_icon = "mortar"};
			if (_sta) then {_icon = "installation"};
			
			if (_sup) then {_icon = "support"};
			
			if (_hel) then {_icon = "air"};
			if (_pla) then {_icon = "plane"};
			if (_uav) then {_icon = "uav"};
			if (_nav) then {_icon = "naval"};
			if (_marker == "inf") then {_marker = _icon};
		};
	}forEach _vehs;
	
	if (_side == west) then {_marker = "b_" + _marker};
	if (_side == east) then {_marker = "o_" + _marker};
	if (_side in [west, east] == false) then {_marker = "n_" + _marker};
	
	_marker
};

/// spawns group from vehicles list
VOX_FNC_SPAWNGROUP = {
	/// [_pos, _vehicles, _group, _morale, _supplies, _icon, _name]
	private _pos = _this select 0;
	private _vehs = _this select 1;
	private _grp = _this select 2;
	private _morale = _this select 3;
	private _dir = _this select 4;
	
	private _icon = [side _grp, _vehs] call VOX_FNC_CLASSIFY;
	
	private _pos = [_pos, 0, VOX_SIZE / 2, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
	{
		if (random 1 <= _morale) then {
			/// TODO: add check if vehicle is a boat
			private _pos2 = [_pos, 0, 50, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
			if (_icon in ["b_naval", "o_naval"]) then {_pos2 = [nil, ["ground"]] call BIS_fnc_randomPos};
			[_pos2, _dir, _x, _grp] call BIS_fnc_spawnVehicle;
		};
	}forEach _vehs;
	
	_grp setVariable ["MARTA_customIcon", [_icon]];
	
	/// set initial waypoint position
    [_grp, 0] setWPPos (getPos leader _grp);
	
	/// put dismounts in vehicle
	{
		_x moveInCargo vehicle leader _grp;
	}forEach units _grp;
	
	/// performance testing waypoint
	private _randMrk = allMapMarkers select floor random count allMapMarkers;
	private _mrkPos = getMarkerPos _randMrk;
	
	_grp addWaypoint [_mrkPos, VOX_SIZE / 2];
	
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
		private _command = true;
		
		if !(_x in [VOX_ATTACKER, VOX_DEFENDER]) then {
			_config = [_config select floor random count _config];
			_command = false;
		};
		
		private _dir = random 360;
		if (_x in [VOX_ATTACKER]) then {_dir = ((VOX_ATTACKER) select 0) getDir ((VOX_DEFENDER) select 0)};
		if (_x in [VOX_DEFENDER]) then {_dir = ((VOX_DEFENDER) select 0) getDir ((VOX_ATTACKER) select 0)};
		
		{
			private _icon = _x select 0;
			private _name = _x select 1;
			private _toSpawn = _x select 2;
			
			private _markers = allMapMarkers select {markerColor _x == _color};
			private _cell = _markers select floor random count _markers;
			private _pos = getMarkerPos _cell;
			
			if (_command == false) then {
				private _cell = _cells select floor random count _cells;
				private _row = _cell select 0;
				private _col = _cell select 1;
				_pos = [_col * VOX_SIZE, _row * VOX_SIZE];			
			};
			
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
				[_pos, _vehicles, _group, _morale, _dir] call VOX_FNC_SPAWNGROUP;
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