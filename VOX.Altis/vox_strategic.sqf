/// VOX_GRID = [[_pos0, _color1, _seeds2, _type3, _unit4, _morale5, _cells6]];
waitUntil {!isNil "VOX_PHASE"};

VOX_LOC_SELECTABLE = [];
VOX_LOC_MODE = "WAITING";
VOX_LOC_SELECTED = [];
VOX_LOC_ORDERS = [];

VOX_FNC_SELECTABLE = {
	private _side = _this;
	private _config = VOX_CFG_WEST;
	if (_side == east) then {_config = VOX_CFG_EAST};
	private _counters = [];
	{_counters pushback _x}forEach _config;
	
	VOX_LOC_SELECTABLE = [];
	{
		private _seed = _x;
		private _pos = _x select 0;
		if (_x select 4 in _counters) then {
			VOX_LOC_SELECTABLE pushback _seed;
			private _draw = true;
			if (side player == west && isPlayer CMD_WEST == false) then {_draw = false};
			if (side player == east && isPlayer CMD_EAST == false) then {_draw = false};
			if (_side == side player && _draw) then {
				private _marker = createMarkerLocal [format ["LOC_%1", _pos], _pos];
				_marker setMarkerTypeLocal "selector_selectable";
				_marker setMarkerSizeLocal [1.5, 1.5];
				};
		} else {
			private _marker = format ["LOC_%1", _pos];
			deletemarkerLocal _marker;
		};
	}forEach VOX_GRID;
	VOX_LOC_MODE = "SELECT";
};

VOX_FNC_SELECT = {
	private _pos = _this select 0;
	private _side = _this select 1;
	private _update = true;
	{
		private _seed = _x;
		if (_pos distance (_seed select 0) < VOX_SIZE) then {
			VOX_LOC_MODE = "ORDER";
			VOX_LOC_SELECTED = _seed;
			_side call VOX_FNC_ORDERS;
			
			private _sound = true;
			if (side player == west && isPlayer CMD_WEST == false) then {_sound = false};
			if (side player == east && isPlayer CMD_EAST == false) then {_sound = false};
			if (_sound) then {0 call VOX_FNC_SOUND};			
			
			if (_side == side player && _sound) then {0 call VOX_FNC_SOUND};
			_update = false;
		};
	}forEach VOX_LOC_SELECTABLE;
	
	if (_update) then {remoteExec ["VOX_FNC_UPDATE", 0]};
};

VOX_FNC_ORDERS = {
	private _side = _this;
	private _selected = VOX_LOC_SELECTED;
	VOX_LOC_ORDERS = [];
	private _pos1 = _selected select 0;
	private _neighbors = _selected select 2;
	
	private _config = VOX_CFG_WEST;
	if (_side == east) then {_config = VOX_CFG_EAST};
	
	private _counters = [];
	{_counters pushback _x}forEach _config;
	
	private _nav = false;
	private _air = false;
	private _plane = false;
	private _arty= false;
	
	/// teleporting rules
	if (_selected select 4 in ["b_naval", "o_naval"] && _selected select 3 in ["NAV", "ALT"]) then {_nav = true};
	if (_selected select 4 in ["b_air", "o_air"]) then {_air = true};
	if (_selected select 4 in ["b_plane", "o_plane"]) then {_plane = true};
	if (_selected select 4 in ["b_art","o_art"]) then {_arty = true};
	
	{
		private _seed = _x;
		private _pos2 = _x select 0;
		private _seeds = _x select 2;
		private _type = _x select 3;
		private _unit = _x select 4;
		
		private _isNeighbor = _pos2 in _neighbors;
		
		private _isEnemy = !(_unit in _counters);
		private _distance = _pos1 distance _pos2;
		
		/// airmobile 5km skip rule
		if (_distance < 5000 && _air) then {_isNeighbor = true};
		
		/// amphibious 5km skip rule
		if (_distance < 5000 && _nav && _type in ["NAV", "ALT"]) then {_isNeighbor = true};
		
		/// artillery 7.5km skip rule
		if (_distance < 7500 && _arty && _isEnemy && _unit != "hd_dot") then {_isNeighbor = true}; /// Artillery barrage!
		
		/// plane 10km skip rule
		private _isAir = _type in ["AIR","ALT"];
		if (_isAir && _plane && _unit == "hd_dot") then {_isNeighbor = true}; /// aircraft can teleport to any airfield
		if (_plane && _isAir == false) then {_isNeighbor = false};
		if (_distance < 10000 && _plane && _isEnemy && _unit != "hd_dot") then {_isNeighbor = true}; /// Airstrike!
		
		if (_isNeighbor && _isEnemy) then {
			VOX_LOC_ORDERS pushback _seed;
		} else {
			private _marker = format ["LOC_%1", _pos2];
			deletemarkerLocal _marker;
		};
	}forEach VOX_GRID;
	
	{
		private _pos = _x select 0;
		private _orderIndex = _forEachIndex;
		
		private _draw = true;
		if (side player == west && isPlayer CMD_WEST == false) then {_draw = false};
		if (side player == east && isPlayer CMD_EAST == false) then {_draw = false};
		if (_side == side player && _draw) then {
			private _marker = createMarkerLocal [format ["LOC_%1", _pos], _pos];
			private _markerType = "selector_selectedMission";
			_marker setMarkerTypeLocal _markerType;
			_marker setMarkerSizeLocal [1.5, 1.5];
		};
	}forEach VOX_LOC_ORDERS;
	
	private _posMarker = VOX_LOC_SELECTED select 0;
	
	VOX_LOC_MODE = "ORDER";
};

VOX_FNC_ORDER = {
	private _pos = _this;
	private _update = true;
	{
		private _seed = _x;
		private _pos2 = _seed select 0;
		if (_pos distance _pos2 < VOX_SIZE && _update == true) then {
			[VOX_LOC_SELECTED, _seed] remoteExec ["VOX_FNC_MOVE", 2];
			_update = false;
		};
		
		private _marker = format ["LOC_%1", _pos2];
		deleteMarkerLocal _marker;
		
	}forEach VOX_LOC_ORDERS;
	
	private _sound = true;
	if (side player == west && isPlayer CMD_WEST == false) then {_sound = false};
	if (side player == east && isPlayer CMD_EAST == false) then {_sound = false};
	if (_sound) then {0 call VOX_FNC_SOUND};
	
	VOX_LOC_MODE = "WAITING";
	if (_update) then {remoteExec ["VOX_FNC_UPDATE", 0]};
};

openMap true;
mapAnimAdd [0, 1, [worldSize / 2, worldSize / 2]];
mapAnimCommit;

if (VOX_LOC_COMMANDER) then {
	systemChat "Click on icon to move."
};

if (isServer) then {
	execVM "vox_stratcmd.sqf";
	VOX_MOTOSKIP = 1;
};

/// start strategic phase
if (isServer) then {
	remoteExec ["VOX_FNC_UPDATE", 0];
};