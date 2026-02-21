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
	private _hcm = _this select 2;
	private _marker = "inf";
	
	{
		private _entry = configFile >> "CfgVehicles" >> _x;
		
		if (isClass _entry) then {
			private _med = getNumber (_entry >> "attendant") > 0 && _forEachIndex == 0;
			private _eng = getNumber (_entry >> "engineer") > 0 && _forEachIndex == 0;
			private _amo = getNumber (_entry >> "transportAmmo") > 0;
			private _plo = getNumber (_entry >> "transportFuel") > 0;
			private _rep = getNumber (_entry >> "transportRepair") > 0;

			private _sta = getNumber (_entry >> "hasDriver") == 0;
			private _art = getNumber (_entry >> "artilleryScanner") == 1 && !_sta;
			private _mor = getNumber (_entry >> "artilleryScanner") == 1 && _sta;
			private _aaa = toLower getText (_entry >> "editorSubcategory") == "anti-air";
			private _pad = toLower getText (_entry >> "displayName") == "missile specialist (aa)";

			private _car = toLower getText (_entry >> "simulation") == "carx";
			private _apc = _car && getNumber (_entry >> "armor") > 100;
			private _arm = toLower getText (_entry >> "simulation") == "tankx" && !_sta;
			private _ifv = _arm && getNumber (_entry >> "transportSoldier") > 6;
			
			private _hel = toLower getText (_entry >> "simulation") == "helicopterrtd";
			private _pla = toLower getText (_entry >> "simulation") in ["airplanex", "airplane"];
			private _uav = toLower getText (_entry >> "vehicleClass") == "autonomous";	
			
			private _nav = toLower getText (_entry >> "simulation") in ["shipx", "submarinex"];
			
			private _icon = "inf";
			
			if (_arm) then {_icon = "armor"};			
			if (_ifv) then {_icon = "mech_inf"};
			if (_car) then {_icon = "unknown"};
			if (_apc) then {_icon = "motor_inf"};
			
			if (_sta) then {_icon = "installation"};
			if (_aaa or _pad) then {_icon = "antiair"};
			if (_art) then {_icon = "art"};
			if (_mor) then {_icon = "mortar"};

			if (_med) then {_icon = "med"};	
			if (_amo) then {_icon = "support"};
			if (_plo) then {_icon = "service"};
			if (_eng) then {_icon = "maint"};
			if (_rep) then {_icon = "maint"};
			
			if (_hel) then {_icon = "air"};
			if (_pla) then {_icon = "plane"};
			if (_uav) then {_icon = "uav"};
			if (_nav) then {_icon = "naval"};
			if (_hcm) then {_icon = "hq"};
			if (_marker == "inf") then {_marker = _icon};
		};
	}forEach _vehs;
	
	if (_side == west) then {_marker = "b_" + _marker};
	if (_side == east) then {_marker = "o_" + _marker};
	if (_side in [west, east] == false) then {_marker = "n_" + _marker};
	
	_marker
};

VOX_FNC_SYNCHRONIZE = {
	private _group = _this select 0;
	private _icon = _this select 1;
	
	private _leader = leader _group;
	private _vehicle = vehicle _leader;
	
	private _fnc_requester = {
		if (side _grp == west) then {SUP_WEST synchronizeObjectsAdd [_vehicle]};
		if (side _grp == east) then {SUP_EAST synchronizeObjectsAdd [_vehicle]};
	};
	
	private _fnc_helicopter = {
		private _seats = _vehicle emptyPositions "Cargo";
		if (side _grp == west && _seats > 1) then {TRA_WEST synchronizeObjectsAdd [_vehicle]};
		if (side _grp == east && _seats > 1) then {TRA_EAST synchronizeObjectsAdd [_vehicle]};
		if (side _grp == west) then {HEL_WEST synchronizeObjectsAdd [_vehicle]};
		if (side _grp == east) then {HEL_EAST synchronizeObjectsAdd [_vehicle]};		
	};
	
	private _fnc_support = {
		_vehicle  lockDriver true;
		private _wp = _grp addWaypoint [getPos _vehicle, 0];
		_wp setWaypointType "SUPPORT";
		private _vehType = typeOf _vehicle;
		private _cfgName = getText (configFile >> "CfgVehicles" >> _vehType >> "displayName");
		private _message = format ["%1 ready for support requests (F2 -> 5 -> 1)", _cfgName];
		_leader sideChat _message;
		
		/// fix supports dismounting
		[_leader, _vehicle] spawn {
			sleep 10;
			(_this select 1) lockDriver false;
			[(_this select 0)] allowGetIn true;
			[(_this select 0)] orderGetIn true;
		};
	};
	
	private _fnc_selectcmd = {
		private _hcside = _this;
		if (_hcside == west) then {
			CMD_WEST = _leader;
		};
		
		if (_hcside == east) then {
			CMD_EAST = _leader;		
		};
	};
	
	switch (_icon) do {
		case "b_art": {ART_WEST synchronizeObjectsAdd [_vehicle]};
		case "o_art": {ART_EAST synchronizeObjectsAdd [_vehicle]};
		case "b_mortar": {ART_WEST synchronizeObjectsAdd [_vehicle]};
		case "o_mortar": {ART_EAST synchronizeObjectsAdd [_vehicle]};
		case "b_plane": {CAS_WEST synchronizeObjectsAdd [_vehicle]};
		case "o_plane": {CAS_EAST synchronizeObjectsAdd [_vehicle]};
		case "b_air": {0 call _fnc_helicopter};
		case "o_air": {0 call _fnc_helicopter};
		
		case "b_support": {0 call _fnc_support};
		case "b_service": {0 call _fnc_support};
		case "b_maint": {0 call _fnc_support};
		case "b_med": {0 call _fnc_support};
		case "o_support": {0 call _fnc_support};
		case "o_service": {0 call _fnc_support};
		case "o_maint": {0 call _fnc_support};
		case "o_med": {0 call _fnc_support};
		
		case "b_hq": {west call _fnc_selectcmd};
		case "o_hq": {east call _fnc_selectcmd};
		default {_fnc_requester};
	};
	
	/// count if helicopter has empty cargo seats
};

VOX_SPAWNEDAUX = [];

/// spawns group from vehicles list
VOX_FNC_SPAWNGROUP = {
	/// [_pos, _vehicles, _group, _morale, _supplies, _icon, _name]
	private _pos = _this select 0;
	private _vehs = _this select 1;
	private _grp = _this select 2;
	private _morale = _this select 3;
	private _dir = _this select 4;
	private _isHCM = _this select 5;
	private _isAUX = _this select 6;
	
	private _icon = [side _grp, _vehs, _isHCM] call VOX_FNC_CLASSIFY;
	
	private _pos = [_pos, 0, VOX_SIZE / 2, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
	
	
	private _isSpawned = false;
	if (_isAUX && _icon in VOX_SPAWNEDAUX) then {continue}; // only spawn 1x of each support unit
	if (_isAUX) then {VOX_SPAWNEDAUX pushback _icon};
	private _auxList = ["art","mortar","plane","air","uav","support","service","maint","med","antiair"];
	if (_isAUX && (_icon select [2]) in _auxList == false) then {continue};
	
	{
		if (random 1 <= _morale or _isHCM) then {
			private _pos2 = [_pos, 0, 50, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
			/// todo: try to spawn naval units close first
			/// if fails: spawn randomly somewhere
			if (_icon in ["b_naval", "o_naval"]) then {_pos2 = [nil, ["ground"]] call BIS_fnc_randomPos};
			[[_pos2 select 0, _pos2 select 1], _dir, _x, _grp] call BIS_fnc_spawnVehicle;
		};
	}forEach _vehs;
	
	_grp setVariable ["MARTA_customIcon", [_icon]];
	
	/// set initial waypoint position
    [_grp, 0] setWPPos (getPos leader _grp);
	
	/// put dismounts in vehicle
	{
		_x moveInCargo vehicle leader _grp;
		_x setSkill _morale;
	}forEach units _grp;
	
	[_grp, _icon] call VOX_FNC_SYNCHRONIZE;
	
	if (_side == side player) then {
		{addSwitchableUnit _x}forEach units _grp;
	};
	
};


/// TODO: re-do this whole thing
/// creates empty groups and is confusing!
/// pass down side and create group AFTER calling for spawning!

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
		private _isPRI = true;
		private _isAUX = false;
		
		if !(_x in [VOX_ATTACKER, VOX_DEFENDER]) then {
			_isPRI = false;
			if (_unit in ["b_art", "o_art","b_support","o_support", "b_plane", "o_plane"]) then {
				_isAUX = true;
			};
		};
		
		private _dir = random 360;
		if (_x in [VOX_ATTACKER]) then {_dir = ((VOX_ATTACKER) select 0) getDir ((VOX_DEFENDER) select 0)};
		if (_x in [VOX_DEFENDER]) then {_dir = ((VOX_DEFENDER) select 0) getDir ((VOX_ATTACKER) select 0)};
		
		{
			if (_isPRI == false && _isAUX == false) then {continue}; /// don't spawn except for primary / aux
		
			private _icon = _x select 0;
			private _name = _x select 1;
			private _toSpawn = _x select 2;
			
			/// fix this? might be explodiet by placing player markers!
			private _markers = allMapMarkers select {markerColor _x == _color && _x select [0,3] == "OBJ"};
			private _cell = _markers select floor random count _markers;
			private _pos = getMarkerPos _cell;
			
			if (_isAUX) then {
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
			
			private _isHCM = false;
			if (_isPRI && _forEachIndex == 0) then {_isHCM = true};
			
			// [_pos2, random 360, _x, _group] call BIS_fnc_spawnVehicle;
			if (_isGroup or _isVehicle) then {
				private _group = createGroup [_side, true];
				[_pos, _vehicles, _group, _morale, _dir, _isHCM, _isAUX] call VOX_FNC_SPAWNGROUP;
			}; 
		}forEach _config;
	};
}forEach VOX_GRID;

private _martaGRP = createGroup sideLogic; 
private _marta = "MartaManager" createUnit [ 
	[0, 0, 0], 
	_martaGRP, 
	"setGroupIconsVisible [true, false];" 
];

/// set HC module commanders:
{
	CMD_WEST hcSetGroup [_x];
}forEach (allGroups select {side _x == west && simulationEnabled (leader _x)});


{
	CMD_EAST hcSetGroup [_x];
}forEach (allGroups select {side _x == east && simulationEnabled (leader _x)});


private _randounit = allUnits select floor random count allUnits;
///selectPlayer _randounit;

/// open teamswitch menu and close map&menu
remoteExec ["VOX_FNC_CLEARMARKERS", 0];
remoteExec ["VOX_FNC_CLOSEMAP", 0];
remoteExec ["VOX_FNC_SLOTTING", 0];