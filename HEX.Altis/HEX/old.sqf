{
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
    private _name = format ["HEX_%1_%2", _row, _col];
	private _marker = createMarker [_name, _pos];
	_marker setMarkerShape "HEXAGON";
	_marker setMarkerBrush "Border";
	_marker setMarkerAlpha 0.5;
	_marker setMarkerDir 90;
	_marker setMarkerSize [HEX_SIDE, HEX_SIDE];
}forEach HEX_GRID;

{
	private _pos = _x select 2;
	private _cfg = _x select 3;
	private _sid = _x select 4;
	
	/// create "base" locations
	private _size = HEX_SIDE/4;
	_location = createLocation [_cfg, _pos, _size, _size];
	_location setSide _sid;
	HEX_LOCS pushback _location;
	
	/// Create GRID overlay
	private _name = format ["HEX_%1", _pos];
	private _marker = createMarker [_name, _pos];
	_marker setMarkerShape "HEXAGON";
	_marker setMarkerBrush "Border";
	_marker setMarkerDir 90;
	_marker setMarkerSize [HEX_SIDE, HEX_SIDE];
	
	/// add already existing locations
	private _locs = nearestLocations [_pos, HEX_CFG_LOCS, HEX_SIDE];
	{
		private _loc = _x;
		private _pos = position _x;
		if (_pos inArea _marker) then {
			_loc setSide civilian;
			HEX_LOCS pushback _loc;
		};	
	}forEach _locs;
}forEach HEX_GRID;

{
	private _pos = position _x;
	private _side = side _x;
	private _size = (size _x) select 1;
	private _dir = direction _x;
	private _name = str _x;
	private _marker = createMarker [_name, position _x];
	private _color = "ColorUNKNOWN";
	if (side _x == west) then {_color = "colorBLUFOR"};
	if (side _x == east) then {_color = "colorOPFOR"};
	if (side _x == civilian) then {_color = "ColorCIV"};
	_marker setMarkerShape "RECTANGLE";
	_marker setMarkerBrush "Border";
	_marker setMarkerDir _dir;
	_marker setMarkerSize [_size, _size];
	_marker setMarkerColor _color;
}forEach HEX_LOCS;

	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _cfg = _x select 3;
	private _sid = _x select 4;

	_location = createLocation [_cfg, _pos, _row, _col];
	_location setSide _sid;
	HEX_LOCS pushback _location;
	
	
{
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _name = format ["HEX_%1_%2", _row, _col];
	private _marker = createMarker [_name, _pos];
	_marker setMarkerShape "HEXAGON";
	_marker setMarkerBrush "Border";
	_marker setMarkerDir 90;
	_marker setMarkerSize [HEX_SIZE, HEX_SIZE];
	
	private _loc = nearestLocation [_pos, HEX_CFG_LOCS];
	private _pos2 = position _loc;
	if (_pos2 inArea _marker) then {_pos = _pos2};
	private _name2 = format ["OBJ_%1_%2", _row, _col];
	private _marker2 = createMarker [_name2, _pos];
	_marker2 setMarkerShape "ELLIPSE";
	_marker2 setMarkerBrush "Border";
	_marker2 setMarkerSize [HEX_SIZE / 4, HEX_SIZE / 4];	
}forEach HEX_GRID;

/// Off-map reserve pool?

private _max = floor ((count HEX_GRID)/2);

/// Place counters
{
	private _counter = _x;
	if (_forEachIndex < _max) then {
		private _sorted = [
			HEX_GRID, 
			[], 
			{
				private _pos = _x select 2;
				private _posX = _pos select 0;
				private _posY = _pos select 1;
				_result = _posX - _posY;
				if (HEX_SCENARIO == "S") then {_result = _posX + _posY};
				if (HEX_SCENARIO == "R") then {_result = _posX};
				_result
			}, 
			"ASCEND", 
			{(_x select 3) == "hd_dot"}
		] call BIS_fnc_sortBy;
		private _hex = selectRandom (_sorted select [0, 3]);
		if (HEX_SCENARIO == "R") then {_hex = selectRandom (_sorted select [0, 9])};
		_hex set [3, _counter];
		_hex set [4, west];
		_hex set [5, 1];
	};
}forEach HEX_CFG_WEST;

{
	private _counter = _x;
	if (_forEachIndex < _max) then {
		private _sorted = [
			HEX_GRID, 
			[], 
			{
				private _pos = _x select 2;
				private _posX = _pos select 0;
				private _posY = _pos select 1;
				_result = _posX - _posY;
				if (HEX_SCENARIO == "S") then {_result = _posX + _posY};
				if (HEX_SCENARIO == "R") then {_result = _posX};
				_result
			}, 
			"DESCEND", 
			{(_x select 3) == "hd_dot"}
		] call BIS_fnc_sortBy;
		private _hex = selectRandom (_sorted select [0, 3]);
		if (HEX_SCENARIO == "R") then {_hex = selectRandom (_sorted select [0, 9])};
		_hex set [3, _counter];
		_hex set [4, east];
		_hex set [5, 1];
	};
}forEach HEX_CFG_EAST;

LOC_FNC_SELECT = {
	private _selectable = [];
	private _posCLICK = _this;
	/// Find counters with moves
	{
		private _hex = _x;
		private _sid = _x select 4;
			private _act = _x select 5;
		if (_sid == side player && _act > 0) then {
			_selectable pushback _hex;
		};
	}forEach HEX_GRID;

	/// Select counter
	{
		private _selected = _x;
		private _posHEX = _x select 2;
		if (_posHEX distance _posCLICK < (HEX_SIZE/2)) then {
			LOC_SELECT = _x;
			LOC_MODE = "ORDER";
			
			private _marker = createMarkerLocal ["LOC_SELECTED", _posHEX];
			_marker setMarkerTypeLocal "Select";
			/// Play sound 
			0 spawn LOC_SOUND;
			
			/// Add all possible moves
			private _near = _selected call HEX_FNC_NEAR;
			{
				private _nearHEX = _x;
				private _side = _x select 4;
				if (_side != side player) then {
					LOC_ORDERS pushback _nearHEX;
				};
			}forEach _near;
			
			private _posX = _posHEX select 0;
			private _posY = _posHEX select 1;			
			
			{
				private _pos2 = _x select 2;
				private _pos2 = [((_pos2 select 0) + _posX) / 2, ((_pos2 select 1) + _posY) / 2];
				private _name = format ["LOC_O_%1", _forEachIndex];
				private _marker2 = createMarkerLocal [_name, _pos2];
				_marker2 setMarkerTypeLocal "mil_arrow";
				_marker2 setMarkerDir (_posHEX getDir _pos2);
			}ForEach LOC_ORDERS;
		};
	}forEach _selectable;
};