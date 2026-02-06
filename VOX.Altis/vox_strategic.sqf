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
			if (_side == side player) then {
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
		if (_pos distance (_seed select 0) < VOX_SIZE * 2) then {
			VOX_LOC_MODE = "ORDER";
			VOX_LOC_SELECTED = _seed;
			_side call VOX_FNC_ORDERS;
			if (_side == side player) then {0 call VOX_FNC_SOUND};
			_update = false;
		};
	}forEach VOX_LOC_SELECTABLE;
	
	if (_update) then {remoteExec ["VOX_FNC_UPDATE", 0]};
};

VOX_FNC_ORDERS = {
	private _side = _this;
	private _selected = VOX_LOC_SELECTED;
	VOX_LOC_ORDERS = [_selected];
	private _neighbors = _selected select 2;
	
	private _config = VOX_CFG_WEST;
	if (_side == east) then {_config = VOX_CFG_EAST};
	
	private _counters = [];
	{_counters pushback _x}forEach _config;
	
	private _nav = false;
	private _air = false;
	
	if (_selected select 4 in ["b_naval", "o_naval"] && _selected select 3 == "NAV") then {_nav = true};
	if (_selected select 4 in ["b_air", "o_air"] && _selected select 3 == "AIR") then {_air = true};
	
	{
		private _seed = _x;
		private _pos = _x select 0;
		private _type = _x select 3;
		private _unit = _x select 4;
		
		private _isNeighbor = _pos in _neighbors;
		private _isNavMove = _nav && {_type == "NAV" && _unit == "hd_dot"};
		private _isAirMove = _air && {_type == "AIR" && _unit == "hd_dot"};
		private _isNotFriend = !(_unit in _counters);
		
		if ((_isNeighbor or _isNavMove or _isAirMove) && _isNotFriend) then {
			VOX_LOC_ORDERS pushback _seed;
		} else {
			private _marker = format ["LOC_%1", _pos];
			deletemarkerLocal _marker;
		};
	}forEach VOX_GRID;
	
	{
		private _pos = _x select 0;
		private _orderIndex = _forEachIndex;
		if (_side == side player) then {
			private _marker = createMarkerLocal [format ["LOC_%1", _pos], _pos];
			private _markerType = "selector_selectedMission";
			if (_orderIndex == 0) then {_markerType = "selector_selectedEnemy"};
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
		if (_pos distance _pos2 < VOX_SIZE * 2) then {
			[VOX_LOC_SELECTED, _seed] remoteExec ["VOX_FNC_MOVE", 2];
			_update = false;
		};
		
		private _marker = format ["LOC_%1", _pos2];
		deleteMarkerLocal _marker;
		
	}forEach VOX_LOC_ORDERS;
	
	0 call VOX_FNC_SOUND;
	VOX_LOC_MODE = "WAITING";
	if (_update) then {remoteExec ["VOX_FNC_UPDATE", 0]};
};

openMap true;
mapAnimAdd [0, 1, [worldSize / 2, worldSize / 2]];
mapAnimCommit;

if (VOX_LOC_COMMANDER) then {
	systemChat "Click on icon to move."
};

/// ai testing, for now just random
VOX_LOC_AICOUNT = 0;
VOX_FNC_AICMD = {
	private _side = _this;
	
	_side call VOX_FNC_SELECTABLE;
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	private _pos = _select select 0;
	[_pos, _side] call VOX_FNC_SELECT;
	private _select2 = VOX_LOC_ORDERS select floor random count VOX_LOC_ORDERS;
	if (count VOX_LOC_ORDERS > 1 or VOX_LOC_AICOUNT > (count VOX_LOC_ORDERS)) then {
		sleep 1;
		private _pos2 = _select2 select 0;
		_pos2 call VOX_FNC_ORDER;
		VOX_LOC_AICOUNT = 0;
		systemchat ("AI MOVE: " + str _side);
	} else {
		/// if fails to move the current counter, start again
		VOX_LOC_AICOUNT = VOX_LOC_AICOUNT + 1;
		_side call VOX_FNC_AICMD;
	};
};

if (isServer) then {
	VOX_MOTOSKIP = 1;
};

/// start strategic phase
if (isServer) then {
	remoteExec ["VOX_FNC_UPDATE", 0];
};