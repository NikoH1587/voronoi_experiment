VOX_LOC_SELECTABLE = [];
VOX_LOC_MODE = "WAITING";
VOX_LOC_SELECTED = [];
VOX_LOC_ORDERS = [];

VOX_FNC_SELECTABLE = {
	private _side = _this;
	private _counters = VOX_CFG_WEST;
	if (_side == east) then {_counters = VOX_CFG_EAST};
	VOX_LOC_SELECTABLE = [];
	{
		private _seed = _x;
		private _pos = _x select 0;
		if (_x select 3 in _counters && _x select 5 > 0.5) then {
			VOX_LOC_SELECTABLE pushback _seed;
			private _marker = createMarkerLocal [format ["LOC_%1", _pos], _pos];
			_marker setMarkerTypeLocal "selector_selectable";
			_marker setMarkerSizeLocal [1.5, 1.5];
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
	{
		private _seed = _x;
		if (_pos distance (_seed select 0) < VOX_SIZE * 2) then {
			VOX_LOC_MODE = "ORDER";
			VOX_LOC_SELECTED = _seed;
			_side call VOX_FNC_ORDERS;
			0 call VOX_FNC_SOUND;
		};
	}forEach VOX_LOC_SELECTABLE;
};

VOX_FNC_ORDERS = {
	private _side = _this;
	private _selected = VOX_LOC_SELECTED;
	VOX_LOC_ORDERS = [];
	private _neighbors = _selected select 4;
	
	private _counters = VOX_CFG_WEST;
	if (_side == east) then {_counters = VOX_CFG_EAST};	
	
	private _nav = false;
	private _air = false;
	
	if (_selected select 3 in ["b_naval", "o_naval"] && _selected select 2 == "NAV") then {_nav = true};
	if (_selected select 3 in ["b_air", "o_air"] && _selected select 2 == "AIR") then {_air = true};
	/// [_pos, _cells, _type, _unit, _border, _morale]	
	
	{
		private _seed = _x;
		private _pos = _x select 0;
		private _type = _x select 2;
		private _unit = _x select 3;
		
		private _isNeighbor = _pos in _neighbors;
		private _isNavMove = _nav && {_type == "NAV"};
		private _isAirMove = _air && {_type == "AIR"};
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
		private _marker = createMarkerLocal [format ["LOC_%1", _pos], _pos];
		_marker setMarkerTypeLocal "selector_selectedMission";
		_marker setMarkerSizeLocal [1.5, 1.5];
	}forEach VOX_LOC_ORDERS;
	
	private _posMarker = VOX_LOC_SELECTED select 0;
	
	VOX_LOC_MODE = "ORDER";
};

VOX_FNC_ORDER = {
	private _pos = _this;
	{
		private _seed = _x;
		private _pos2 = _seed select 0;
		if (_pos distance _pos2 < VOX_SIZE * 2) then {
			[VOX_LOC_SELECTED, _seed] remoteExec ["VOX_FNC_MOVE", 2];
		};
		
		private _marker = format ["LOC_%1", _pos2];
		deleteMarkerLocal _marker;
		
	}forEach VOX_LOC_ORDERS;
	
	0 call VOX_FNC_SOUND;
	VOX_LOC_MODE = "WAITING";
};

openMap true;
mapAnimAdd [0, 1, [worldSize / 2, worldSize / 2]];
mapAnimCommit;

((str VOX_TURN) + " TURN") call VOX_FNC_MESSAGE;

if (VOX_LOC_COMMANDER) then {
	systemChat "Click on icon to move."
};

/// ai testing, for now just random
VOX_FNC_AICMD = {
	private _side = _this;
	
	_side call VOX_FNC_SELECTABLE;
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	private _pos = _select select 0;
	[_pos, _side] call VOX_FNC_SELECT;
	private _select2 = VOX_LOC_ORDERS select floor random count VOX_LOC_ORDERS;
	if (count VOX_LOC_ORDERS > 0) then {
		private _pos2 = _select2 select 0;
		_pos2 call VOX_FNC_ORDER;
	} else {
		/// if fails to move the current counter, start again
		_side call VOX_FNC_AICMD;
	};
};

while {VOX_PHASE == "STRATEGIC"} do {
	if (VOX_TURN == side player && VOX_LOC_COMMANDER) then {
		if (VOX_LOC_MODE == "WAITING") then {side player call VOX_FNC_SELECTABLE};
		onMapSingleClick {
			if (VOX_LOC_MODE == "SELECT") then {
				[_pos, side player] spawn VOX_FNC_SELECT;
			};
			if (VOX_LOC_MODE == "ORDER") then {
				_pos spawn VOX_FNC_ORDER;
			};
			true;
		};
	} else {
		onMapSingleClick {true};
	};
	
	
	
	if (isServer && isPlayer CMD_WEST == false && VOX_TURN == west) then {west call VOX_FNC_AICMD};
	if (isServer && isPlayer CMD_EAST == false && VOX_TURN == east) then {east call VOX_FNC_AICMD};
	sleep 0.1;
};

/// reset mapclick;
onMapSingleClick {true};