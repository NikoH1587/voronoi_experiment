/// VOX_GRID = [[_pos0, _cell1, _seeds2, _type3, _unit4, _morale5, (_tempcells6)]];
VOX_GRID = [];
/// get pos and start array
{
	private _marker = _x;
	private _type = _x select [0, 3];
	private _pos = getMarkerPos _x;
	private _pos = [round (_pos select 0), round (_pos select 1)];
	private _legend = _marker in ["CIV_0","MIL_0","AIR_0","NAV_0"];
	if (_type in ["CIV", "MIL", "NAV", "AIR"] && !_legend) then {
		VOX_GRID pushback [_pos, [_marker, "ColorWHITE"], [], _type, "hd_dot", 0, []];
		/// deleteMarker _marker;
	}
}forEach allMapMarkers;

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
		private _pos = [_col * VOX_SIZE, _row * VOX_SIZE];
		///private _isWater = (surfaceIsWater _pos);
		private _isWoods = ((_pos nearRoads (VOX_SIZE * 0.7)) isEqualTo []);
		if (_isWoods) then {continue}; /// skip water and wasteland
		private _nearest = _pos call _fnc_nearest;
		
		(_nearest select 6) pushback [_row, _col];
    };
};

/// debug temporary cells
if (VOX_DEBUG) then {
	{
		private _cells = _x select 6;
		{
			private _row = _x select 0;
			private _col = _x select 1;
			_pos = [_col * VOX_SIZE, _row * VOX_SIZE];

			private _marker = createMarker [format ["VOX_%1_%2", _row, _col], _pos];
			_marker setMarkerShape "RECTANGLE";
			_marker setMarkerBrush "Solid";
			_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
			_marker setMarkerAlpha 0.5;
		}forEach _cells;
	}forEach VOX_GRID;	
};

/// TODO:
/// make the actual tarrain cells into temp array here
/// index == VOX_GRID index
/// just store the cells to draw markers on load
/// can be upsampled to be larger?

/// just store so polyline can be drawn?
/// store just single pos (from center) + radius to nearest obj? ( from center)
/// store size A (nearest) sizeB, dir and pos?

/// MOTORIZED
/// Can move twice?
/// ignore turn swich?
/// keep internal counter????

/// Add 3rd standard movement formation
/// Militia / Reservist
/// extra flavor
/// "b_recon" marker

/// Logistics constraint -> Militia
/// Vehicle constraint -> Infantry
/// Opposition roughness constraint -> Mechanized
/// Distance constraint -> Motorized
/// Water constraint -> Amphibious
/// Complex terrain constraint -> Airmobile

/// Move counter to center!
/// so that spawn area calculation is easier
/// and also can have the air/naval markers!

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

/// set pos to middle of temporary cells
{
	
}forEach VOX_GRID;

/// remove temporary cells array
{
	_x deleteAt 6;
}forEach VOX_GRID;

/// place BLUFOR formations
{

	private _grid = VOX_GRID;
	private _ord = "ASCEND";
	
	private _sorted = [_grid, [], {(_x select 0) distance (getMarkerPos "VOX_WEST")}, "ASCEND", {_x select 4 == "hd_dot"}] call BIS_fnc_sortBy;
	private _select = _sorted select 0;
	
	private _index = VOX_GRID find _select;
	private _selectGrid = VOX_GRID select _index;
	private _marker = (_selectGrid select 1) select 0;
	_selectGrid set [1, [_marker, "ColorBLUFOR"]];
	_selectGrid set [4, _x];
	_selectGrid set [5, 1];
}forEach VOX_CFG_WEST;

/// place OPFOR formations
{

	private _grid = VOX_GRID;
	private _ord = "ASCEND";
	
	private _sorted = [_grid, [], {(_x select 0) distance (getMarkerPos "VOX_EAST")}, "ASCEND", {_x select 4 == "hd_dot"}] call BIS_fnc_sortBy;
	private _select = _sorted select 0;
	
	private _index = VOX_GRID find _select;
	private _selectGrid = VOX_GRID select _index;
	private _marker = (_selectGrid select 1) select 0;
	_selectGrid set [1, [_marker, "ColorOPFOR"]];
	_selectGrid set [4, _x];
	_selectGrid set [5, 1];
}forEach VOX_CFG_EAST;

hint str VOX_GRID;

/// draw connections
0 call VOX_FNC_DRAWDIRS;

/// make grid public;
publicVariable "VOX_GRID";

/// update zone of control
{
	_x call VOX_FNC_UPDATEGRID;
}forEach VOX_GRID;

/// draw counters
remoteExec ["VOX_FNC_DRAWMARKERS", 0];

/// count markers

if (VOX_DEBUG) then {
	hint ((str (count allMapMarkers)) + " markers created");
};

