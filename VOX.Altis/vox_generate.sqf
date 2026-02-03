/// [[_pos, _cells, _type, _unit, _border, _morale]]
VOX_GRID = [];

{
	private _marker = _x;
	private _type = _x select [0, 3];
	private _pos = getMarkerPos _x;
	private _pos = [round (_pos select 0), round (_pos select 1)];
	if (_type in ["CIV", "NAV", "AIR"]) then {
		VOX_GRID pushback [_pos, [], _type, "hd_dot", [], 0];
		if !(VOX_DEBUG) then {deleteMarker _x};
	}
}forEach allMapMarkers;

_fnc_nearest = {
	private _pos = _this;
	
	private _nearest = VOX_GRID select 0;
	private _minDist = _pos distance2D (_nearest select 0);
	
	{
		private _d = _pos distance2D (_x select 0);
		if (_d < _minDist) then {
			_minDist = _d;
			_nearest = _x;
		};
	}forEach VOX_GRID;
	
	_nearest
};

/// create grid
for "_col" from 0 to round(worldSize / VOX_SIZE) do {
    for "_row" from 0 to round(worldSize / VOX_SIZE) do {
	
		private _pos = [(_col * VOX_SIZE) + VOX_SIZE / 2, (_row * VOX_SIZE) + VOX_SIZE / 2];
		if (surfaceIsWater _pos) then {continue}; /// skip water
		
		private _nearest = _pos call _fnc_nearest;

		(_nearest select 1) pushback [_row, _col];
    };
};

_fnc_edgeCells = {
	private _cells = _this;
	
	private _edges = [];
	private _dirs = [[-1, 0],[1, 0],[0, -1],[0, 1]];
	
	{
		private _cell = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _isEdge = false;
		
		{
			private _nRow = _row + (_x select 0);
			private _nCol = _col + (_x select 1);
			private _nPos = [_nCol * VOX_SIZE, _nRow * VOX_SIZE];
			
			if (_nCol < 0 or _nRow < 0 or surfaceIsWater _nPos) exitWith {
				_isEdge = true;
			};		
			
			if (_cells find [_nRow, _nCol] == -1) exitWith {
				_isEdge = true;
			};
		}forEach _dirs;
		
		if (_isEdge) then {
			_edges pushBack _cell;
		};
	}forEach _cells;
	
	_edges
};

/// create area markers
{
	private _cells = _x select 1;
	private _type = _x select 2;
	
	private _color = [0, 0, 0];
	private _edges = _cells call _fnc_edgeCells;
	switch (_type) do {
		case "NAV": {_color = [0.5, 0.5, 0.5]};
		case "AIR": {_color = [1, 1, 1]};
	};
	
	{
		if (_x in _edges) then {
			private _row = _x select 0;
			private _col = _x select 1;
			private _pos = [(_col * VOX_SIZE) + VOX_SIZE / 2, (_row * VOX_SIZE) + VOX_SIZE / 2];
			private _marker = createMarker [format ["VOX_%1_%2", _row, _col], _pos];
			_marker setMarkerShape "RECTANGLE";
			_marker setMarkerBrush "Solid";
			_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
			_marker setMarkerColor (format ["#(%1,%2,%3,1)", _color select 0, _color select 1, _color select 2]);
			_marker setMarkerAlpha 1;		
		};
	}forEach _cells;
}forEach VOX_GRID;

/// get nearby cells
/// get find cells in seeds
/// get seed

_fnc_findSeeds = {
	private _row = _x select 0;
	private _col = _x select 1;
	private _dirs = [[-1, 0],[1, 0],[0, -1],[0, 1]];
	private _seeds = [];
	{
		private _nRow = _row + (_x select 0);
		private _nCol = _col + (_x select 1);
		{
			private _seedPos = _x select 0;
			private _cells = _x select 1;
			private _find = _cells find [_nRow, _nCol];
			if (_find != -1) then {
				_seeds pushBackUnique _seedPos;
			};
		}forEach VOX_GRID;
	}forEach _dirs;
	
	_seeds
};

{	
	private _pos = _x select 0;
	private _cells = _x select 1;
	private _seeds = [];
	private _edges = (_x select 1) call _fnc_edgeCells;
	
	{
		private _cellSeeds = _x call _fnc_findSeeds;
		{
			private _seed = _x;
			if !(_seed isEqualTo _pos) then {
				_seeds pushBackUnique _seed;
			};
		}forEach _cellSeeds;
	}forEach _edges;
	
	_x set [4, _seeds];
	
	{
		private _pos2 = _x;
		if (VOX_DEBUG) then {
			private _polyline = [_pos select 0, _pos select 1, _pos2 select 0, _pos2 select 1];
			private _marker = createMarker [format ["VOX_%1_%2", _pos, _pos2], _pos2];
			_marker setMarkerPolyline _polyline;
		};
	}forEach _seeds;
	
	if (VOX_DEBUG) then {
		private _marker = createMarker [format ["VOX_%1_%2", _pos, "_2"], _pos];
		_marker setMarkerType "hd_dot";
		_marker setMarkerText str _seeds;
	};
}forEach VOX_GRID;

/// place counters
{

	private _grid = VOX_GRID;
	private _dir = 0;
	private _ord = "ASCEND";
	
	private _sorted = [_grid, [], {(_x select 0) distance (getMarkerPos "VOX_WEST")}, "ASCEND", {_x select 3 == "hd_dot"}] call BIS_fnc_sortBy;
	private _select = _sorted select 0;
	
	private _index = VOX_GRID find _select;
	private _selectGrid = VOX_GRID select _index;
	_selectGrid set [3, _x select 0];
	_selectGrid set [5, 1];
}forEach VOX_CFG_WEST;

/// place counters
{

	private _grid = VOX_GRID;
	private _dir = 0;
	private _ord = "ASCEND";
	
	private _sorted = [_grid, [], {(_x select 0) distance (getMarkerPos "VOX_EAST")}, "ASCEND", {_x select 3 == "hd_dot"}] call BIS_fnc_sortBy;
	private _select = _sorted select 0;
	
	private _index = VOX_GRID find _select;
	private _selectGrid = VOX_GRID select _index;
	_selectGrid set [3, _x select 0];
	_selectGrid set [5, 1];
}forEach VOX_CFG_EAST;

/// draw markers
0 call VOX_FNC_DRAWMARKERS;

/// make grid public;
publicVariable "VOX_GRID";