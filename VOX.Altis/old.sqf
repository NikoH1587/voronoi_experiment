/// create area markers
{
	private _pos = _x select 0;
	private _cells = _x select 1;
	private _type = _x select 2;
	
	private _color = [0, 0, 0];
	private _edges = _cells call _fnc_edgeCells;
	switch (_type) do {
		case "NAV": {_color = [0.5, 0.5, 0.5]};
		case "AIR": {_color = [1, 1, 1]};
	};
	
	private _cellsDXY = [];
	private _prevX = 0;
	private _prevY = 0;
	
	{
		private _row = _x select 0;
		private _col = _x select 1;
		if (_x in _edges) then {
			private _posX = _col * VOX_SIZE;
			private _posY = _row * VOX_SIZE;
			private _dir = _pos getDir [_posX, _posY];
			_cellsDXY pushback [_dir, _posX, _posY];
		};
	}forEach _cells;
	
	_cellsDXY sort true;
	private _polyline = [];
	{
		_polyline pushback (_x select 1);
		_polyline pushback (_x select 2);		
	}forEach _cellsDXY;
	
	private _marker = createMarker [format ["POL_%1", _pos], _pos];
	_marker setMarkerShape "Polyline";
	_marker setMarkerPolyline _polyline;	
	
}forEach VOX_GRID;


VOX_FNC_ADDCFG = {

	if (_this == -1) exitWith {};

	/// get selected config
	private _cfg_list_idx = _this;
	private _cfg_list_sel = VOX_FACTION select _cfg_list_idx;
	
	private _menu = findDisplay 1200;
	private _formation =  _menu displayCtrl 1201;
	private _for_list =  _menu displayCtrl 1202;
	/// private _cfg_list =  _menu displayCtrl 1204;
	
	/// get selected formation
	private _for_list_idx = lbCurSel _formation;
	private _for_list_sel = VOX_FORMATIONS select _for_list_idx;
	
	/// block adding over 20 groups
	if (count _for_list_sel) exitWith {};
	
	/// update formation list
	private _icon = _cfg_list_sel select 0;
	private _name = _cfg_list_sel select 1;
	private _cfg = _cfg_list_sel select 2;

	private _added = _for_list lbAdd "";
	_for_list lbSetPicture [_added, _icon];
	if (_added == 0) then {
		private _text = "CMD" + ". " + _name;
		_for_list lbSetText [_added, _text];
	} else {
		private _text = (str _added) + ". " +_name;
		if (_added > 19) then {
			_text = _text + " PERFORMANCE WARNING!";
		};
		_for_list lbSetText [_added, _text];	
	};
};

_names = [
	"ALPHA","BRAVO","CHARLIE",
	"DELTA","ECHO","FOXTROT",
	"GOLF","HOTEL","INDIA",
	"JULIETT","KILO","LIMA",
	"MIKE","NOVEMBER","OSCAR",
	"PAPA","QUEBEC","ROMEO",
	"SIERRA","TANGO","UNIFORM",
	"VICTOR","WHISKEY","XRAY",
	"YANKEE","ZULU","" /// easteregg
];

_names2 = [
	"ANNA","BORIS","VASILY",
	"GREGORY","DMITRI","YELENA",
	"ZHENYA","ZINAIDA","IVAN",
	"KONSTANTIN","LEONID",
	"MIKHAIL","NIKOLAI","OLGA",
	"PAVEL","ROMAN","SEMYON",
	"TATYANA","ULYANA","FYODOR",
	"KHARITON","TSAPLYA","CHELOVEK",
	"SHURA","SHCUKA","EKHO",
	"YURI","YAKOV","" /// easteregg
];

VOX_FNC_DRAWCONNECTIONS = {
	{
		private _pos = _x select 1;
		private _seeds = _x select 1;
		private _posX = _pos select 0;
		private _posY = _pos select 1;
		{
			private _posX1 = _x select 0;
			private _posY1 = _x select 1;
			private _plus = _posX + _posY + _posX1 + _posY1;
			private _name = format ["VOX_%1", _plus];
			private _marker = createMarker [_name, _pos];
			private _polyline = [_posX, _posY, _posX1, _posY1];
			_marker setMarkerShape "Polyline";
			_marker setMarkerPolyline _polyline;
		}forEach _seeds;
	}forEach VOX_GRID;
};

VOX_FNC_DRAWPOLYGONS = {
	{
		private _pos = _x select 0;
		private _edges = _x select 1;
		
		private _posDXY = [];
		{
			private _row = _x select 0;
			private _col = _x select 1;
			
			private _posX = _col * VOX_SIZE;
			private _posY = _row * VOX_SIZE;
			
			private _dir = _pos getDir [_posX, _posY];
			
			_posDXY pushback [_dir, _posX, _posY];
		}forEach _edges;
		
		_posDXY sort true;
		
		_posDXY pushback (_posDXY select 0);
		private _polyline = [];
		
		{
			_polyline pushback (_x select 1);
			_polyline pushback (_x select 2);
		}forEach _posDXY;
		
		private _name = format ["POL_%1", _pos];
		private _marker = createMarker [_name, _pos];
		_marker setMarkerShape "Polyline";
		_marker setMarkerPolyline _polyline;
		
	}forEach VOX_GRID;
};

VOX_FNC_DRAWGRID = {
	private _count = 0;
	{
		private _pos = _x select 0;
		private _edges = _x select 1;
		_count = _count + (count _edges);
		private _posDXY = [];
		{
			private _row = _x select 0;
			private _col = _x select 1;
			_posE = [_col * VOX_SIZE, _row * VOX_SIZE];
			/// private _dir = round ((_pos getDir _posE) / 45) * 45;
			private _dir = _pos getDir _posE;

			private _marker = createMarker [format ["VOX_%1_%2", _row, _col], _posE];
			_marker setMarkerType "mil_triangle";
			_marker setMarkerAlpha 0.5;
			_marker setMarkerDir _dir;
			_posDXY pushback [_dir, _posE select 0, _posE select 1];
		}forEach _edges;
		
		_posDXY sort true;
		private _polyline = [];
		
		{
			_polyline pushback (_x select 1);
			_polyline pushback (_x select 2);
		}forEach _posDXY;
		
		_polyline pushback (_polyline select 0);
		_polyline pushback (_polyline select 1);
		
		private _name = format ["POL_%1", _pos];
		private _marker = createMarker [_name, _pos];
		_marker setMarkerShape "Polyline";
		_marker setMarkerPolyline _polyline;
	}forEach VOX_GRID;
	
	if (VOX_DEBUG) then {
		hint ((str _count) + " markers created");
	};
};

VOX_FNC_DRAWGRID = {
	private _count = 0;
	{
		private _pos = _x select 0;
		private _edges = _x select 1;
		private _cells = _x select 2;
		
		_count = _count + (count _edges);
		{
			private _row = _x select 0;
			private _col = _x select 1;
			_posE = [_col * VOX_SIZE, _row * VOX_SIZE];

			private _marker = createMarker [format ["VOX_%1_%2", _row, _col], _posE];
			_marker setMarkerType "mil_dot";
			_marker setMarkerAlpha 0.5;
			
			private _nearest = _pos;
			private _distance = 100000;
			
			{
				private _d = _posE distance2D _x;
				if (_d < _distance) then {
					_distance = _d;
					_nearest = _x;
				};
			}forEach _cells;
			
			private _dir = _pos getDir _nearest;			
			_marker setMarkerDir _dir;
			
			/// point markers towards nearest seed
			/// dir of this is _pos getdir _nearest;
			
		}forEach _edges;
	}forEach VOX_GRID;
	
	if (VOX_DEBUG) then {
		hint ((str _count) + " markers created");
	};
};

VOX_FNC_DRAWOBJECTIVES = {
	/// losing CMD group causes formation to become disorganized
	/// losing all objectives also causes formation to become surrounded
	/// surrounded / disorganized = cannot move (blocked / stuck)
	/// groups remaining % = spawn groups randomization (doesn't affect CMD spawning)
	/// losing all groups will destroy unit?
	
	/// bordering formations:
	/// friendly = automatically captured/held
	/// enemy = automatically lost
	
	/// bordering cells are supporting formations
	/// bordering cells respawn units
	private _atk_pos = VOX_ATTACKER select 0;
	private _atk_edges = VOX_ATTACKER select 1;
	private _atk_unit = VOX_ATTACKER select 4;
	private _atk_morale = VOX_ATTACKER select 5;
	private _def_pos = VOX_DEFENDER select 0;
	private _def_edges = VOX_DEFENDER select 1;
	private _def_unit = VOX_DEFENDER select 4;
	private _def_morale = VOX_DEFENDER select 5;

	private _atk_mrk = createMarker ["VOX_ATK", _atk_pos];
	_atk_mrk setMarkerType _atk_unit;
	if (_atk_morale == 0) then {_atk_mrk setMarkerAlphaLocal 0.5};
	_atk_mrk setMarkerSize [1.25, 1.25];
	
	private _def_mrk = createMarker ["VOX_DEF", _def_pos];
	_def_mrk setMarkerType _def_unit;
	if (_def_morale == 0) then {_def_mrk setMarkerAlphaLocal 0.5};
	_def_mrk setMarkerSize [1.25, 1.25];
	
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = [_col * VOX_SIZE, _row * VOX_SIZE];
			
		private _nearest = _atk_pos;
		private _distance = 100000;
			
		{
			if ((_x select 0) isEqualTo _atk_pos) exitWith {};
			private _d = _pos distance2D (_x select 0);
			if (_d < _distance) then {
				_distance = _d;
				_nearest = (_x select 0);
			};
		}forEach VOX_GRID;
		
		if (_nearest isEqualTo _def_pos) then {
			private _marker = createMarker [format ["ATK_%1_%2", _row, _col], _pos];
			_marker setMarkerType "mil_triangle";
			_color = "ColorBLUFOR";
			if (_atk_unit select [0, 1] == "o") then {_color = "ColorOPFOR"};
			_marker setMarkerColor _color;		
		};

	}forEach _atk_edges;
	
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = [_col * VOX_SIZE, _row * VOX_SIZE];
		
		private _nearest = _def_pos;
		private _distance = 100000;
			
		{
			if ((_x select 0) isEqualTo _def_pos) exitWith {};
			private _d = _pos distance2D (_x select 0);
			if (_d < _distance) then {
				_distance = _d;
				_nearest = (_x select 0);
			};
		}forEach VOX_GRID;
		
		if (_nearest isEqualTo _atk_pos) then {
			private _marker = createMarker [format ["DEF_%1_%2", _row, _col], _pos];
			_marker setMarkerType "mil_triangle";
			_color = "ColorBLUFOR";
			if (_def_unit select [0, 1] == "o") then {_color = "ColorOPFOR"};
			_marker setMarkerColor _color;		
		};

	}forEach _def_edges;
	
};


/// set found edges to 1
{
	private _seed = _x select 0;
	private _cells = _x select 1;
	private _type = _x select 3;
	private _edges = [];
	private _dirs = [[-1, 0],[1, 0],[0, -1],[0, 1]];
	
	{
		private _cell = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _edge = false;
		
		{
			private _nRow = _row + (_x select 0);
			private _nCol = _col + (_x select 1);
			private _nPos = [_nCol * VOX_SIZE, _nRow * VOX_SIZE];
			
			private _isStrat = false;
			if (_type in ["CIV", "NAV", "AIR"] && _seed distance _nPos < (VOX_SIZE / 2)) then {_isStrat = true};
			if (_isStrat) exitWith {_edge = true};
			
			private _isEdge = _cells find [_nRow, _nCol] == -1;
			private _isFlat = !((_nPos isFlatEmpty [-1, -1, 0.1]) isEqualTo []);
			private _isLand = !(surfaceIsWater _nPos);
			private _isRoad = !((_nPos nearRoads (VOX_SIZE / 2)) isEqualTo []);
			
			if (_isEdge && _isRoad && _isLand) exitWith {
				_edge = true;
			};		
		}forEach _dirs;
		
		if (_edge) then {
			_edges pushBack _cell;
		};
	}forEach _cells;

	_x set [1, _edges];
}forEach VOX_GRID;


VOX_FNC_DRAWOBJECTIVES = {
	private _atk_pos = VOX_ATTACKER select 0;
	private _atk_edges = VOX_ATTACKER select 1;
	private _atk_unit = VOX_ATTACKER select 4;
	private _atk_morale = VOX_ATTACKER select 5;
	private _def_pos = VOX_DEFENDER select 0;
	private _def_edges = VOX_DEFENDER select 1;
	private _def_unit = VOX_DEFENDER select 4;
	private _def_morale = VOX_DEFENDER select 5;
	
	private _distance = (_atk_pos distance _def_pos) / 2;
	private _cnt_pos = [((_atk_pos select 0)+(_def_pos select 0)) / 2, ((_atk_pos select 1)+(_def_pos select 1)) / 2];
	
	private _atk_mrk = createMarker ["VOX_ATK", _atk_pos];
	_atk_mrk setMarkerType _atk_unit;
	if (_atk_morale == 0) then {_atk_mrk setMarkerAlphaLocal 0.5};
	_atk_mrk setMarkerSize [1.25, 1.25];
	
	private _def_mrk = createMarker ["VOX_DEF", _def_pos];
	_def_mrk setMarkerType _def_unit;
	if (_def_morale == 0) then {_def_mrk setMarkerAlphaLocal 0.5};
	_def_mrk setMarkerSize [1.25, 1.25];
	
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = [_col * VOX_SIZE, _row * VOX_SIZE];
		if (_pos distance _cnt_pos < _distance) then {
			private _marker = createMarker [format ["VOX_%1_%2", _row, _col], _pos];
			_marker setMarkerType "mil_triangle";
		}
	}forEach (_atk_edges + _def_edges);
	
};

for "_col" from 0 to round(worldSize / VOX_SIZE) do {
    for "_row" from 0 to round(worldSize / VOX_SIZE) do {
		private _pos = [_col * VOX_SIZE, _row * VOX_SIZE];
		if (surfaceIsWater _pos) then {continue}; /// skip water
		private _nearest = _pos call _fnc_nearest;
		
		(_nearest select 1) pushback [_row, _col];
    };
};

/// set found edges to 1
{
	private _seed = _x select 0;
	private _cells = _x select 1;
	private _type = _x select 3;
	private _edges = [];
	private _dirs = [[-1, 0],[1, 0],[0, -1],[0, 1]];
	
	{
		private _cell = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _edge = false;
		
		{
			private _nRow = _row + (_x select 0);
			private _nCol = _col + (_x select 1);
			private _nPos = [_nCol * VOX_SIZE, _nRow * VOX_SIZE];
			
			private _isEdge = _cells find [_nRow, _nCol] == -1;
			private _isFlat = !((_nPos isFlatEmpty [-1, -1, 0.1]) isEqualTo []);
			private _isLand = !(surfaceIsWater _nPos);
			private _isRoad = !((_nPos nearRoads (VOX_SIZE / 2)) isEqualTo []);
			
			if (_isEdge && _isLand) exitWith {
				_edge = true;
			};		
		}forEach _dirs;
		
		if (_edge) then {
			_edges pushBack _cell;
		};
	}forEach _cells;

	_x set [1, _edges];
}forEach VOX_GRID;


VOX_FNC_DRAWGRID = {
	private _count = 0;
	{
		private _edges = _x select 1;
		_count = _count + (count _edges);
		{
			private _row = _x select 0;
			private _col = _x select 1;
			_pos = [_col * VOX_SIZE, _row * VOX_SIZE];

			private _marker = createMarker [format ["VOX_%1_%2", _row, _col], _pos];
			_marker setMarkerShape "RECTANGLE";
			_marker setMarkerBrush "DiagGrid";
			_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
		}forEach _edges;
	}forEach VOX_GRID;
	
	if (VOX_DEBUG) then {
		hint ((str _count) + " markers created");
	};
};


VOX_FNC_DRAWGRID = {
	{
		private _edges = _x select 1;
		{
			private _row = _x select 0;
			private _col = _x select 1;
			_pos = [_col * VOX_SIZE, _row * VOX_SIZE];

			private _marker = createMarker [format ["VOX_%1_%2", _row, _col], _pos];
			_marker setMarkerShape "RECTANGLE";
			_marker setMarkerBrush "Solid";
			_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
			_marker setMarkerAlpha 0.5;
		}forEach _edges;
	}forEach VOX_GRID;
};

VOX_FNC_CLEARGRID = {
	{
		private _edges = _x select 1;
		{
			private _row = _x select 0;
			private _col = _x select 1;

			private _name = format ["VOX_%1_%2", _row, _col];
			deleteMarker _name;
		}forEach _edges;
	}forEach VOX_GRID;
};

VOX_FNC_UPDATEGRID = {
	private _edges = _this select 1;
	private _unit = _this select 4;

	_count = count _edges;
	{
		private _row = _x select 0;
		private _col = _x select 1;
		_pos = [_col * VOX_SIZE, _row * VOX_SIZE];

		private _color = "ColorBLACK";
		if (_unit select [0, 1] == "b") then {_color = "ColorBLUFOR"};
		if (_unit select [0, 1] == "o") then {_color = "ColorOPFOR"};
		private _marker = format ["VOX_%1_%2", _row, _col];
		if (markerColor _marker != _color) then {
			_marker setMarkerColor _color;;		
		};
	}forEach _edges;
};