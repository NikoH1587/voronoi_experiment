/// VOX_GRID = [[_pos0, _color1, _seeds2, _type3, _unit4, _morale5, (_tempcells6)]];
VOX_GRID = [];
/// get pos and start array
{
	private _marker = _x;
	private _type = _x select [0, 3];
	private _pos = getMarkerPos _x;
	private _pos = [round (_pos select 0), round (_pos select 1)];
	if (_type in ["AIR", "ALT", "MIL", "NAV", "CIV"]) then {
		VOX_GRID pushback [_pos, "colorBLACK", [], _type, "hd_dot", 1, []];
		deleteMarker _marker;
	}
}forEach allMapMarkers;

/// TODO: Change generation

/// reduce grid to 40
VOX_CENTER = [] call BIS_fnc_randomPos;;
if (VOX_SCENARIO == "WEST") then {VOX_WEST = [0, worldSize / 2]; VOX_EAST = [worldSize, worldSize / 2]};
if (VOX_SCENARIO == "EAST") then {VOX_EAST = [0, worldSize / 2]; VOX_WEST = [worldSize, worldSize / 2]};
if (VOX_SCENARIO == "NORTH") then {VOX_WEST = [worldSize / 2, 0]; VOX_EAST = [worldSize / 2, worldsize]};
if (VOX_SCENARIO == "SOUTH") then {VOX_EAST = [worldSize / 2, 0]; VOX_WEST = [worldSize / 2, worldsize]};
	
_tempgrid = [VOX_GRID, [], {(_x select 0) distance VOX_CENTER}, "ASCEND"] call BIS_fnc_sortBy;
VOX_GRID = _tempgrid;
private _counters = (count (VOX_CFG_WEST + VOX_CFG_EAST))*2;
VOX_GRID deleteRange [_counters, count VOX_GRID];

/// create AO marker;
private _furthest = (VOX_GRID select ((count VOX_GRID) - 1)) select 0;
private _maxDist = _furthest distance VOX_CENTER;

/// generate grid on valid positions
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

for "_col" from 0 to round(worldSize / VOX_SIZE) do {
    for "_row" from 0 to round(worldSize / VOX_SIZE) do {
		_pos = [_col * VOX_SIZE, _row * VOX_SIZE];
		private _isWater = (surfaceIsWater _pos);
		private _isWoods = ((_pos nearRoads (VOX_SIZE * 0.7)) isEqualTo []);
		private _notAO = (_pos distance VOX_CENTER > (_maxDist + (VOX_SIZE*2)));
		if (_isWoods or _notAO) then {continue}; /// skip water and wasteland
		private _nearest = _pos call _fnc_nearest;
		
		(_nearest select 6) pushback [_row, _col];
    };
};

/// get neighboring seeds
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
			private _cells = _x select 6;
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
	private _cells = _x select 6;
	private _seeds = [];
	
	{
		private _cellSeeds = _x call _fnc_findSeeds;
		{
			private _seed = _x;
			if !(_seed isEqualTo _pos) then {
				_seeds pushBackUnique _seed;
			};
		}forEach _cellSeeds;
	}forEach _cells;
	
	_x set [2, _seeds];
}forEach VOX_GRID;

/// reverse configs, so first units in list spawns further
reverse VOX_CFG_WEST;
reverse VOX_CFG_EAST;

/// TODO: change generation shape

/// place attacker formation
{
	private _sorted = [VOX_GRID, [], {(_x select 0) distance VOX_WEST}, "ASCEND", {_x select 4 == "hd_dot"}] call BIS_fnc_sortBy;
	private _select = selectRandom (_sorted select [0, 2]);
	
	private _hasair = false;
	{
		if (_x select 3 in ["AIR", "ALT"] && (_x select 4) == "hd_dot") then {_hasair = true};
	}forEach _sorted;
	
	if (_hasair && _x in ["b_plane", "o_plane"]) then {
		_sorted2 = [VOX_GRID, [], {(_x select 0) distance VOX_WEST}, "ASCEND", {_x select 3 in ["AIR", "ALT"] && _x select 4 == "hd_dot"}] call BIS_fnc_sortBy;
		_select = _sorted2 select 0;
	};
	
	private _index = VOX_GRID find _select;
	private _selectGrid = VOX_GRID select _index;
	_selectGrid set [1, "ColorBLUFOR"];
	_selectGrid set [4, _x];
	_selectGrid set [5, 1];
	
	private _pos = (_sorted select 0) select 0;
	if (_forEachIndex == 0) then {
		VOX_BASE_WEST = _pos;
	};
}forEach VOX_CFG_WEST;

/// place defender formation
{
	private _sorted = [VOX_GRID, [], {(_x select 0) distance VOX_EAST}, "ASCEND", {_x select 4 == "hd_dot"}] call BIS_fnc_sortBy;
	private _select = selectRandom (_sorted select [0, 2]);
	
	private _hasair = false;
	{
		if (_x select 3 in ["AIR", "ALT"] && (_x select 4) == "hd_dot") then {_hasair = true};
	}forEach _sorted;
	
	if (_hasair && _x in ["b_plane", "o_plane"]) then {
		_sorted2 = [VOX_GRID, [], {(_x select 0) distance VOX_EAST}, "ASCEND", {_x select 3 in ["AIR", "ALT"] && _x select 4 == "hd_dot"}] call BIS_fnc_sortBy;
		_select = _sorted2 select 0;
	};
	
	private _index = VOX_GRID find _select;
	private _selectGrid = VOX_GRID select _index;
	_selectGrid set [1, "ColorOPFOR"];
	_selectGrid set [4, _x];
	_selectGrid set [5, 1];
	
	private _pos = (_sorted select 0) select 0;
	if (_forEachIndex == 0) then {
		VOX_BASE_EAST = _pos;
	};	

}forEach VOX_CFG_EAST;

/// draw grid;
0 call VOX_FNC_DRAWGRID;

/// make grid public;
publicVariable "VOX_GRID";

/// update zone of control
{
	_x call VOX_FNC_UPDATEGRID;
}forEach VOX_GRID;

/// draw counters
remoteExec ["VOX_FNC_DRAWMARKERS", 0];