/// VOX_GRID = [[_pos0, _color1, _seeds2, _type3, _unit4, _morale5, (_tempcells6)]];
VOX_GRID = [];
/// get pos and start array
{
	private _marker = _x;
	private _type = _x select [0, 3];
	private _pos = getMarkerPos _x;
	private _pos = [round (_pos select 0), round (_pos select 1)];
	if (_type in ["AIR", "AIRNAV", "MIL", "NAV", "CIV"]) then {
		VOX_GRID pushback [_pos, "colorBLACK", [], _type, "hd_dot", 0, []];
		deleteMarker _marker;
	}
}forEach allMapMarkers;

/// reduce grid to 40
VOX_CENTER = [worldSize / 2, worldSize / 2];
if (VOX_SCENARIO == "WEST") then {VOX_CENTER = [0, worldSize / 2]};
if (VOX_SCENARIO == "EAST") then {VOX_CENTER = [worldSize, worldSize / 2]};
if (VOX_SCENARIO == "NORTH") then {VOX_CENTER = [worldSize / 2, worldSize]};
if (VOX_SCENARIO == "SOUTH") then {VOX_CENTER = [worldSize / 2, 0]};
	
_tempgrid = [VOX_GRID, [], {(_x select 0) distance VOX_CENTER}, "ASCEND"] call BIS_fnc_sortBy;
VOX_GRID = _tempgrid;
VOX_GRID deleteRange [30, count VOX_GRID];


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
		private _notAO = (_pos distance VOX_CENTER > (_maxDist + VOX_SIZE));
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

/// reverse configs, so first units in list spawn further
reverse VOX_CFG_WEST;
reverse VOX_CFG_EAST;

/// place BLUFOR formations
{

	private _sorted = [VOX_GRID, [], {(_x select 0) distance VOX_CENTER}, "ASCEND", {_x select 4 == "hd_dot"}] call BIS_fnc_sortBy;
	private _select = selectRandom (_sorted select [0, 2]);
	
	private _index = VOX_GRID find _select;
	private _selectGrid = VOX_GRID select _index;
	_selectGrid set [1, "ColorBLUFOR"];
	_selectGrid set [4, _x];
	_selectGrid set [5, 1];
}forEach VOX_CFG_WEST;

/// place OPFOR formations
{

	private _sorted = [VOX_GRID, [], {(_x select 0) distance VOX_CENTER}, "DESCEND", {_x select 4 == "hd_dot"}] call BIS_fnc_sortBy;
	private _select = selectRandom (_sorted select [0, 2]);
	
	private _index = VOX_GRID find _select;
	private _selectGrid = VOX_GRID select _index;
	_selectGrid set [1, "ColorOPFOR"];
	_selectGrid set [4, _x];
	_selectGrid set [5, 1];
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

/// count markers and debug connections
if (VOX_DEBUG) then {
	private _naval = [];
	{
		private _pos = _x select 0;
		private _seeds = _x select 2;
		private _type = _x select 3;
		private _posX = _pos select 0;
		private _posY = _pos select 1;
		
		if (_type in ["NAV","NAVAIR"]) then {
			_naval pushback _pos;
		};
		
		{
			private _posX1 = _x select 0;
			private _posY1 = _x select 1;
			private _plus = _posX + _posY + _posX1 + _posY1;
			private _name = format ["VOX_%1", _plus];
			private _marker = createMarker [_name, _pos];
			private _polyline = [_posX, _posY, _posX1, _posY1];
			_marker setMarkerShape "Polyline";
			_marker setMarkerPolyline _polyline;
			_marker setMarkerAlpha 0.25;
			
			if (false) then {
				private _posC = [(_posX + _posX1)/2, (_posY + _posY1)/2];
				private _nameC = format ["VOX_%1", random 10];
				private _markerC = createMarker [_nameC, _posC];
				_markerC setMarkerType "mil_dot";
					private _distance = round (_pos distance [_posX1, _posY1]);
				_markerC setMarkerText (str _distance);
				if (_distance < 1500) then {_markerC setMarkerColor "ColorGREEN"};
				if (_distance > 3000) then {_markerC setMarkerColor "ColorRED"};
			};
		}forEach _seeds;
	}forEach VOX_GRID;
	
	/// draw naval connections
	{
		private _pos1 = _x;
		private _posX1 = _pos1 select 0;
		private _posY1 = _pos1 select 1;
		{
			private _pos2 = _x;
			private _posX2 = _pos2 select 0;
			private _posY2 = _pos2 select 1;
			if (_pos1 distance _pos2 < 5000) then {
				private _name = _posX1 + _posX2 + _posY1 + _posX2;
				private _marker = createMarker [format ["NAV_%1", _name], _pos2];
				_marker setMarkerShape "Polyline";
				_marker setMarkerPolyline [_posX1, _posY1, _posX2, _posY2];
				_marker setMarkerColor "#(0,0.75,0.75,1)";
				_marker setMarkerAlpha 0.1;
			};
		}forEach _naval;
	}forEach _naval;	
};

