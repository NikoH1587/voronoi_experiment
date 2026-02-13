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
		private _pos = _x select 0;
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


VOX_FNC_ADDWEST = {	

	private _names = [
	"Alpha","Bravo","Charlie",
	"Delta","Echo","Foxtrot",
	"Golf","Hotel","India",
	"HHC"
	];
	
	private _name = _names select count VOX_CFG_WEST;
	
	private _selected = VOX_FORMATIONS select _this;

	private _marker = _selected select 0;
	private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";

	private _menu = findDisplay 1200;
	private _blu_list =  _menu displayCtrl 1206;
	
	/// add to config
	VOX_CFG_WEST pushback _marker;
	
	/// add to ui
	private _added = _blu_list lbAdd _name;
	_blu_list lbSetPicture [_added, _icon];
	_blu_list lbSetPictureColor [_added, [0, 0.3, 0.6, 1]];
};

VOX_FNC_DELWEST = {
	if (_this == -1) exitWith {};

	private _menu = findDisplay 1200;
	private _blu_list =  _menu displayCtrl 1206;

	private _selected = VOX_CFG_WEST select _this;
	_blu_list lbDelete _this;
	
	VOX_CFG_WEST deleteAt _this;
	
	_blu_list lbSetCurSel -1;
};

VOX_FNC_ADDEAST = {	

	private _names = [
	"1st 1Bn","2nd 1Bn","3rd 1Bn",
	"1st 2Bn","2nd 2Bn","3rd 2Bn",
	"1st 3Bn","2nd 3Bn","3rd 3Bn",
	"Bde HQ"
	];

	private _name = _names select count VOX_CFG_EAST;

	private _selected = VOX_FORMATIONS select (_this + 10);

	private _marker = _selected select 0;
	private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";

	private _menu = findDisplay 1200;
	private _opf_list =  _menu displayCtrl 1208;
	
	VOX_CFG_EAST pushback _marker;
	
	private _added = _opf_list lbAdd _name;
	_opf_list lbSetPicture [_added, _icon];
	_opf_list lbSetPictureColor [_added, [0.5, 0, 0, 1]];
};

VOX_FNC_DELEAST = {
	if (_this == -1) exitWith {};

	private _menu = findDisplay 1200;
	private _opf_list =  _menu displayCtrl 1208;

	private _selected = VOX_CFG_EAST select _this;
	_opf_list lbDelete _this;
	
	VOX_CFG_EAST deleteAt _this;
	
	_opf_list lbSetCurSel -1;
};

VOX_FNC_DRAWDIRS = {
	{
		private _pos = _x select 0;
		private _posX = _pos select 0;
		private _posY = _pos select 1;

		private _seeds = _x select 2;
		private _idx = _forEachIndex;
		
		private _radius = 10000;
		
		{
			private _posXS = _x select 0;
			private _posYS = _x select 1;
			private _dir = _pos getDir _x;
			private _posS = [(_posX + _posXS) / 2, (_posY + _posYS) / 2];
			private _distance = _posS distance _pos;
			
			if (_distance < _radius) then {
				_radius = _distance;
			};

			private _marker = createMarker [format ["VOX_%1", _posS], _posS];			
			_marker setMarkerType "mil_box";
			_marker setMarkerDir _dir;
			_marker setMarkerAlpha 0.25;
			_marker setMarkerSize [0.25, 3];
		}forEach _seeds;
	}forEach VOX_GRID;
};

VOX_FNC_CLEARDIRS = {
	{
		private _pos = _x select 0;
		private _posX = _pos select 0;
		private _posY = _pos select 1;

		private _seeds = _x select 2;
		private _idx = _forEachIndex;
		{
			private _posX1 = _x select 0;
			private _posY1 = _x select 1;
			private _dir = _pos getDir _x;
			private _pos1 = [(_posX + _posX1) / 2, (_posY + _posY1) / 2];

			private _marker = format ["VOX_%1", _pos1];			
			deleteMarker _marker;
		}forEach _seeds;
	}forEach VOX_GRID;
};


/// VOX_GRID = [[_pos0, _color1, _seeds2, _type3, _unit4, _morale5, (_tempcells6)]];
VOX_GRID = [];
/// get airfields

private _airfields = [];
{
	private _marker = _x;
	private _name = _x select [0, 3];
	private _pos = getMarkerPos _x;
	if (_name == "AIR") then {
		_airfields pushback _pos;
	}
}forEach allMapMarkers;



/// locations
private _locations = nearestLocations [getPosATL player, ["NameCityCapital", "NameCity"], worldSize];
{
	private _position = position _x;
	private _posX = round (_position select 0);
	private _posY = round (_position select 1);
	private _pos = [_posX, _posY];
	/// check if there is an airfield
	/// check if is marine
	private _marine = false;
	if (type _x == "NameMarine") then {_marine = true};
	
	private _airfield = false;
	{if (_pos distance _x < VOX_SIZE) then {_airfield = true}}forEach _airfields;
	
	private _type = "CIV";
	if (_airfield) then {_type = "AIR"};
	if (_marine) then {_type = "NAV"};
	VOX_GRID pushback [_pos, "colorBLACK", [], _type, "hd_dot", 0, []];
}forEach _locations;

/// get naval locations;

{
	private _cell = _x;
	private _pos = _x select 0;
	private _type = _x select 3;
	private _naval = nearestLocation [_pos, "NameMarine", 2500];
	if (isNull _naval == false) then {
		if (_type == "CIV") then {_cell set [3, "NAV"]};
		if (_type == "AIR") then {_cell set [3, "ALT"];};
	};	
}forEach VOX_GRID;

/// get locations
private _locations = nearestLocations [getPosATL player, ["Hill","NameCityCapital", "NameCity"], (worldSize*2)];

{
	if (VOX_LOCATIONS) then {
		private _pos = position _x;
		private _pos = [round (_pos select 0), round (_pos select 1)];
		private _type = "CIV";
		VOX_GRID pushback [_pos, "colorBLACK", [], _type, "hd_dot", 0, []];
	}
}forEach _locations;

/// get naval locations;

{
	private _cell = _x;
	private _pos = _x select 0;
	private _type = _x select 3;
	private _naval = nearestLocation [_pos, "NameMarine", 2500];
	if (isNull _naval == false) then {
		if (_type == "CIV") then {_cell set [3, "NAV"]};
		if (_type == "MIL") then {_cell set [3, "NAV"]};
		if (_type == "AIR") then {_cell set [3, "ALT"];};
	};	
}forEach VOX_GRID;


VOX_LOC_AICOUNT = 0;
VOX_FNC_AICMD = {
	private _side = _this;
	_side call VOX_FNC_SELECTABLE;
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	[_select select 0, _side] call VOX_FNC_SELECT;
	
	private _sideCol = "ColorBLUFOR";
	if (_side == east) then {_sideCol == "ColorOPFOR"};
	private _attack = VOX_LOC_ORDERS select {_x select 1 != _sideCol};
	private _defend = VOX_LOC_ORDERS select {_x select 1 == _sideCol};

	private _morale = (VOX_LOC_ORDERS select 0) select 5;
	
	if ((VOX_LOC_ORDERS select 0) select 5) in ["b_support", "o_support"]) then {_morale = 0};
	
	if (_attack > 0 && _morale == 1) then {
		private _pos = _attack select floor random count _attack;
		_pos call VOX_FNC_ORDER;
	};
	
	if (_morale < 1) then {
		private _pos = _defend select floor random count _defend;
		_pos call VOX_FNC_ORDER;		
	}
};

/// count markers and debug connections
if (VOX_DEBUG) then {
	private _naval = [];
	{
		private _pos = _x select 0;
		private _seeds = _x select 2;
		private _type = _x select 3;
		private _posX = _pos select 0;
		private _posY = _pos select 1;
		
		if (_type in ["NAV","ALT"]) then {
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

VOX_FNC_AICMD = {
	private _side = _this;
	
	/// ai "delay
	sleep 1;
	
	_side call VOX_FNC_SELECTABLE;
	/// [[_seed1],[_seed2]]
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	[_select select 0, _side] call VOX_FNC_SELECT;
	
	/// ai "delay"
	sleep random 1;
	
	private _sideCol = "ColorBLUFOR";
	if (_side == east) then {_sideCol = "ColorOPFOR"};
	private _attack = VOX_LOC_ORDERS select {_x select 1 != _sideCol};
	private _defend = VOX_LOC_ORDERS select {_x select 1 == _sideCol};
	private _seed = VOX_LOC_SELECTED;
	private _unit = _seed select 4;
	private _morale = _seed select 5;
	
	if (_unit in ["b_support", "o_support"]) then {_morale = 0};
	private _isSup = _unit in ["b_support", "o_support"];
	private _isArt = _unit in ["b_art", "o_art"];
	private _isAir = _unit in ["b_plane", "o_plane"];
	private _strike = if (_isArt or _isPlane && ) then {};
	
	private _done = false;
	if (count _attack > 0 && _morale == 1) then {
		private _pos = (_attack select floor random count _attack) select 0;
		_pos call VOX_FNC_ORDER;
		_done = true;
	};

	if ((_morale < 1 or count _attack == 0) && _isSup == false) then {
		_side call VOX_FNC_AICMD;
		if (VOX_DEBUG) then {systemchat ("AI NORMAL SKIP: " + str _side)};
		_done = true;
	};
	
	if (_isSup && count _defend > 0) then {
		private _pos = (_defend select floor random count _defend) select 0;
		_pos call VOX_FNC_ORDER;
		_done = true;
	};
	
	if (_isSup && count _defend == 0) then {
		_side call VOX_FNC_AICMD;
		if (VOX_DEBUG) then {systemchat ("AI SUPPORT SKIP: " + str _side)};
		_done = true;		
	};	
	
	/// switch to player turn if something strange happens
	if (_done == false) then {
		private _turn = east;
		if (VOX_TURN == east) then {_turn = west};
		
		publicVariable "VOX_TURN";
		
		/// strategic update
		remoteExec ["VOX_FNC_UPDATE", 0];
		systemchat "AI TURN SKIPPED";
	};
};

VOX_FNC_STRATCMD = {
	private _side = _this;
	
	/// ai "delay
	sleep 1;
	
	_side call VOX_FNC_SELECTABLE;
	/// [[_seed1],[_seed2]]
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	[_select select 0, _side] call VOX_FNC_SELECT;
	
	private _sidCol = "ColorBLUFOR";
	private _enyCol = "ColorOPFOR";
	if (_side == east) then {
		_sidCol = "ColorOPFOR";
		_enyCol = "ColorBLUFOR";
	};
	
	private _seed = VOX_LOC_SELECTED;
	private _unit = _seed select 4;
	private _morale = _seed select 5;
	
	private _attacks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 != "hd_dot"};
	private _recons = VOX_LOC_ORDERS select {_x select 1 == "colorBLACK"};
	private _flanks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 == "hd_dot"};
	private _retreats = VOX_LOC_ORDERS select {_x select 1 == _sidCol};
	private _HVTargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 in ["b_support","b_art","b_plane","o_support","o_art","o_plane"]};
	
	private _isArm =  _unit in ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"];
	private _isRec = _unit in ["b_recon", "o_recon"];
	
	private _isSup = _unit in ["b_support", "o_support","b_art", "o_art", "b_plane", "o_plane"];
	
	private _isInf = !(_isArm or _isRec or _isSup);
	private _skip = false;
	
	if (_isInf) then {
		private _moves = _recons;
		///if (count _moves == 0) then {_moves = _attacks};
		
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isArm) then {
		private _moves = _attacks;
		if (count _moves == 0) then {_moves = _recons};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isRec) then {
		private _moves = _HVTargets;
		if (count _moves == 0) then {_moves = _flanks};
		
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isSup) then {
		_skip = true;	
	};

	if (VOX_CMD_SKIPS > (count VOX_LOC_SELECTABLE)) then {
		if (count VOX_LOC_ORDERS > 0) then {
			_moves = _recons + _flanks + _retreats + _attacks;
		
			/// forced attack if high morale
			if (_morale > 0.5 && count _attacks > 0) then {_moves = _attacks};
			
			/// forced retreat if low morale
			if (_morale <= 0.5 && count _retreats > 0) then {_moves = _retreats};	
			
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
			_skip = false;
		} else {_skip = true};
	};
	
	/// switch side if there's no valid orders
	if (VOX_CMD_SKIPS > ((count VOX_LOC_SELECTABLE) * 2)) then {
		private _turn = east;
		if (VOX_TURN == east) then {_turn = west};
		
		VOX_MOTOSKIP = 1;
		VOX_TURN = _turn;
		publicVariable "VOX_TURN";
		
		/// strategic update
		remoteExec ["VOX_FNC_UPDATE", 0];
		_skip = false;
	};
	
	if (_skip) then {
		VOX_CMD_SKIPS = VOX_CMD_SKIPS + 1;
		_side call VOX_FNC_STRATCMD;
		if (VOX_DEBUG) then {
			hint ("CMD skip: " + str VOX_CMD_SKIPS);
		};
	};
};

VOX_FNC_STRATCMD = {
	private _side = _this;
	
	/// ai "delay
	sleep 1;
	
	_side call VOX_FNC_SELECTABLE;
	/// [[_seed1],[_seed2]]
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	[_select select 0, _side] call VOX_FNC_SELECT;
	
	private _sidCol = "ColorBLUFOR";
	private _enyCol = "ColorOPFOR";
	if (_side == east) then {
		_sidCol = "ColorOPFOR";
		_enyCol = "ColorBLUFOR";
	};
	
	private _seed = VOX_LOC_SELECTED;
	private _unit = _seed select 4;
	private _morale = _seed select 5;
	
	private _attacks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 != "hd_dot"};
	private _recons = VOX_LOC_ORDERS select {_x select 1 == "colorBLACK"};
	private _flanks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 == "hd_dot"};
	private _retreats = VOX_LOC_ORDERS select {_x select 1 == _sidCol};
	private _HVTargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 in ["b_support","b_art","b_plane","o_support","o_art","o_plane"]};
	
	/// sort based on distance to center
	private _att = [_attacks, [], {(_x select 0) distance VOX_CENTER}, "ASCEND"] call BIS_fnc_sortBy;
	private _rec = [_recons, [], {(_x select 0) distance VOX_CENTER}, "ASCEND"] call BIS_fnc_sortBy;
	private _fla = [_flanks, [], {(_x select 0) distance VOX_CENTER}, "ASCEND"] call BIS_fnc_sortBy;
	private _ret = [_retreats, [], {(_x select 0) distance VOX_CENTER}, "ASCEND"] call BIS_fnc_sortBy;
	private _hvt = [_HVTargets, [], {(_x select 0) distance VOX_CENTER}, "ASCEND"] call BIS_fnc_sortBy;
	
	private _isArm =  _unit in ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"];
	private _isRec = _unit in ["b_recon", "o_recon"];
	
	private _isSup = _unit in ["b_support", "o_support","b_art", "o_art", "b_plane", "o_plane"];
	
	private _isInf = !(_isArm or _isRec or _isSup);
	private _skip = false;
	
	if (_isInf) then {
		private _moves = _rec;
		
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = _moves select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isArm) then {
		private _moves = _att;
		if (count _moves == 0) then {_moves = _rec};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = _moves select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isRec) then {
		private _moves = _hvt;
		if (count _moves == 0) then {_moves = _fla};
		
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = _moves select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isSup) then {
		_skip = true;	
	};

	if (VOX_CMD_SKIPS > (count VOX_LOC_SELECTABLE)) then {
		if (count VOX_LOC_ORDERS > 0) then {
			_moves = _rec + _fla + _ret + _att;
		
			/// forced attack if high morale
			if (_morale > 0.5 && count _att > 0) then {_moves = _att};
			
			/// forced retreat if low morale
			if (_morale <= 0.5 && count _retreats > 0) then {_moves = _ret};	
			
			private _pos = _moves select 0;
			_pos call VOX_FNC_ORDER;
			_skip = false;
		} else {_skip = true};
	};
	
	/// switch side if there's no valid orders
	if (VOX_CMD_SKIPS > ((count VOX_LOC_SELECTABLE) * 2)) then {
		private _turn = east;
		if (VOX_TURN == east) then {_turn = west};
		
		VOX_MOTOSKIP = 1;
		VOX_TURN = _turn;
		publicVariable "VOX_TURN";
		
		/// strategic update
		remoteExec ["VOX_FNC_UPDATE", 0];
		_skip = false;
	};
	
	if (_skip) then {
		VOX_CMD_SKIPS = VOX_CMD_SKIPS + 1;
		_side call VOX_FNC_STRATCMD;
		if (VOX_DEBUG) then {
			hint ("CMD skip: " + str VOX_CMD_SKIPS);
		};
	};
};

VOX_FNC_STRATCMD = {
	private _side = _this;
	
	sleep 0.1;
	
	_side call VOX_FNC_SELECTABLE;
	/// [[_seed1],[_seed2]]
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	[_select select 0, _side] call VOX_FNC_SELECT;
	
	private _sidCol = "ColorBLUFOR";
	private _enyCol = "ColorOPFOR";
	if (_side == east) then {
		_sidCol = "ColorOPFOR";
		_enyCol = "ColorBLUFOR";
	};
	
	private _seed = VOX_LOC_SELECTED;
	private _unit = _seed select 4;
	private _morale = _seed select 5;
	
	private _attacks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 != "hd_dot"};
	private _recons = VOX_LOC_ORDERS select {_x select 1 == "colorBLACK"};
	private _flanks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 == "hd_dot"};
	private _retreats = VOX_LOC_ORDERS select {_x select 1 == _sidCol};
	private _HVTargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 in ["b_support","b_art","b_plane","o_support","o_art","o_plane"]};
	
	private _isArm =  _unit in ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"];
	private _isRec = _unit in ["b_recon", "b_motor_inf", "b_air", "o_recon", "o_motor_inf", "o_air"];
	private _isSup = _unit in ["b_support", "o_support","b_art", "o_art", "b_plane", "o_plane"];
	
	private _isInf = !(_isArm or _isRec or _isSup);
	private _skip = false;
	
	if (_isInf) then {
		private _moves = _recons + _flanks;
		
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isArm) then {
		private _moves = _attacks;
		if (count _moves == 0) then {_moves = _recons + _flanks};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isRec) then {
		private _moves = _HVTargets;
		if (count _moves == 0) then {_moves = _recons + _flanks};
		
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isSup) then {
		_skip = true;	
	};

	if (VOX_CMD_SKIPS > (count VOX_LOC_SELECTABLE)) then {
		if (count VOX_LOC_ORDERS > 0) then {
			_moves = _recons + _flanks + _retreats + _attacks;
		
			/// forced attack if high morale
			if (_morale > 0.5 && count _attacks > 0) then {_moves = _attacks};
			
			/// forced retreat if low morale
			if (_morale <= 0.5 && count _retreats > 0) then {_moves = _retreats};	
			
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
			_skip = false;
		} else {_skip = true};
	};
	
	/// switch side if there's no valid orders
	if (VOX_CMD_SKIPS > ((count VOX_LOC_SELECTABLE) * 2)) then {
		private _turn = east;
		if (VOX_TURN == east) then {_turn = west};
		
		VOX_MOTOSKIP = 1;
		VOX_TURN = _turn;
		publicVariable "VOX_TURN";
		
		/// strategic update
		remoteExec ["VOX_FNC_UPDATE", 0];
		_skip = false;
	};
	
	if (_skip) then {
		VOX_CMD_SKIPS = VOX_CMD_SKIPS + 1;
		_side call VOX_FNC_STRATCMD;
		if (VOX_DEBUG) then {
			hint ("CMD skip: " + str VOX_CMD_SKIPS);
		};
	};
}

VOX_FNC_CMDTYPE = {
	private _unit = _this;
	
	private _type = "INF";
	if (_unit in ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"]) then {_type = "MEC"};
	if (_unit in ["b_recon" "b_air", "o_recon", "o_air"]) then {_type = "REC"};
	if (_unit in ["b_art", "o_art", "b_plane", "o_plane"]) then {_type = "SUP"};
	if (_unit in ["b_support", "o_support"]) then {_type = "LOG"};
	
	_type
};

VOX_FNC_CMDWEIGHTS = {};

VOX_FNC_STRATCMD = {
	private _side = _this;
	private _bestMove = {};
	
	private _conquest = 0; /// conquest need for side
	private _destruction = 0; /// destruction need for side
	
	private _sidCol = "ColorBLUFOR";
	private _enyCol = "ColorOPFOR";
	
	if (_side == east) then {
		private _sidCol = "ColorBLUFOR";
		private _enyCol = "ColorOPFOR";	
	};
	
	_side call VOX_FNC_SELECTABLE;
	
	{
		private _pos = _x select 0;
		private _unit = _x select 4;
		private _morale = _x select 5;
		
		VOX_LOC_SELECTED = _x;
		_side call VOX_FNC_ORDERS;
		
		private _destruction = VOX_LOC_ORDERS select {_x select 4 != "hd_dot"};
		private _conquest = VOX_LOC_ORDERS select {_x select 4 == "hd_dot"};
		_unit call VOX_FNC_CMDTYPE;
		
		/// order value:
		/// 
		
		///_destruction: enemy occupied cells
		/// +1 if NAV
		/// +1 if AIR
		/// +2 if ALT
		
		/// +1 if "MEC"
		/// +1 if mor > 0.5
		/// +1 if HVT
		
		/// -1 if "REC"
		/// -2 if "ART"
		/// -4 if "SUP"
		/// points * cellval = weight
		
		///_conquest: unoccupied cells
		/// +1 if NAV
		/// +1 if AIR
		/// +2 if ALT
		/// +1 if colorBLACK
		
		/// +2 if rec
		/// +1 if INF
		
		/// -2 if "ART"
		/// -3 if "SUP"
		/// points * cellval = weight
	}forEach VOX_SELECTABLE;
};

VOX_FNC_STRATCMD = {
	private _side = _this;
	
	sleep 0.5;
	
	_side call VOX_FNC_SELECTABLE;
	/// [[_seed1],[_seed2]]
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	[_select select 0, _side] call VOX_FNC_SELECT;
	
	private _sidCol = "ColorBLUFOR";
	private _enyCol = "ColorOPFOR";
	if (_side == east) then {
		_sidCol = "ColorOPFOR";
		_enyCol = "ColorBLUFOR";
	};
	
	private _seed = VOX_LOC_SELECTED;
	private _unit = _seed select 4;
	private _morale = _seed select 5;
	
	private _recons = VOX_LOC_ORDERS select {_x select 1 == "colorBLACK"};
	private _keyrecons = VOX_LOC_ORDERS select {_x select 1 == "colorBLACK" && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _flanks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 == "hd_dot"};
	private _keyflanks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _keyroutes = VOX_LOC_ORDERS select {_x select 1 == _sidCol && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _retreats = VOX_LOC_ORDERS select {_x select 1 == _sidCol};
	
	private _attacks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 != "hd_dot"};	
	private _hvtargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 in ["b_support","b_art","b_plane","o_support","o_art","o_plane"]};
	private _keytargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _weaktargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 5 < 0.5};
	
	private _isArm =  _unit in ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"];
	private _isRec = _unit in ["b_recon", "b_motor_inf", "b_air", "o_recon", "o_motor_inf", "o_air"];
	private _isSup = _unit in ["b_support", "o_support","b_art", "o_art", "b_plane", "o_plane"];
	
	private _isInf = !(_isArm or _isRec or _isSup);
	private _skip = false;
	
	if (_isArm) then {
		private _moves = _attacks;
		if (count _moves == 0) then {_moves = _keyrecons};
		if (count _moves == 0) then {_moves = _recons};
		if (count _moves == 0) then {_moves = _keyflanks};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isInf) then {
		private _moves = _keyrecons;
		if (count _moves == 0) then {_moves = _keyflanks};
		if (count _moves == 0) then {_moves = _keytargets};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};	
	
	if (_isRec) then {
		private _moves = _hvtargets;
		if (count _moves == 0) then {_moves = _weaktargets};	
		if (count _moves == 0) then {_moves = _recons + _flanks};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isSup) then {
		_skip = true;	
	};

	if (VOX_CMD_SKIPS > (count VOX_LOC_SELECTABLE)) then {
		if (count VOX_LOC_ORDERS > 0) then {
			private _pos = (VOX_LOC_ORDERS select floor random count VOX_LOC_ORDERS) select 0;
			_pos call VOX_FNC_ORDER;
			_skip = false;
		} else {_skip = true};
	};
	
	/// switch side if there's no valid orders
	if (VOX_CMD_SKIPS > ((count VOX_LOC_SELECTABLE) * 2)) then {
		private _turn = east;
		if (VOX_TURN == east) then {_turn = west};
		
		VOX_MOTOSKIP = 1;
		VOX_TURN = _turn;
		publicVariable "VOX_TURN";
		
		/// strategic update
		remoteExec ["VOX_FNC_UPDATE", 0];
		_skip = false;
	};
	
	if (_skip) then {
		VOX_CMD_SKIPS = VOX_CMD_SKIPS + 1;
		_side call VOX_FNC_STRATCMD;
		if (VOX_DEBUG) then {
			hint ("CMD skip: " + str VOX_CMD_SKIPS);
		};
	};
}

VOX_FNC_STRATCMD = {
	private _side = _this;
	
	_side call VOX_FNC_SELECTABLE;
	/// [[_seed1],[_seed2]]
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	[_select select 0, _side] call VOX_FNC_SELECT;
	
	private _sidCol = "ColorBLUFOR";
	private _enyCol = "ColorOPFOR";
	if (_side == east) then {
		_sidCol = "ColorOPFOR";
		_enyCol = "ColorBLUFOR";
	};
	
	private _seed = VOX_LOC_SELECTED;
	private _unit = _seed select 4;
	private _morale = _seed select 5;
	
	private _recons = VOX_LOC_ORDERS select {_x select 1 == "colorBLACK"};
	private _keyrecons = VOX_LOC_ORDERS select {_x select 1 == "colorBLACK" && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _flanks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 == "hd_dot"};
	private _keyflanks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _keyroutes = VOX_LOC_ORDERS select {_x select 1 == _sidCol && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _retreats = VOX_LOC_ORDERS select {_x select 1 == _sidCol};
	
	private _attacks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 != "hd_dot"};	
	private _hvtargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 in ["b_support","b_art","b_plane","o_support","o_art","o_plane"]};
	private _keytargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _weaktargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 5 < 0.5};
	
	private _isArm =  _unit in ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"];
	private _isRec = _unit in ["b_recon", "b_motor_inf", "b_air", "o_recon", "o_motor_inf", "o_air"];
	private _isSup = _unit in ["b_support", "o_support","b_art", "o_art", "b_plane", "o_plane"];
	
	private _isInf = !(_isArm or _isRec or _isSup);
	private _skip = false;
	
	if (_isArm) then {
		private _moves = _attacks;
		if (count _moves == 0) then {_moves = _keyrecons};
		if (count _moves == 0) then {_moves = _recons};
		if (count _moves == 0) then {_moves = _keyflanks};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isInf) then {
		private _moves = _keyrecons;
		if (count _moves == 0) then {_moves = _recons};
		if (count _moves == 0) then {_moves = _keyflanks};
		if (count _moves == 0) then {_moves = _keytargets};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};	
	
	if (_isRec) then {
		private _moves = _hvtargets;
		if (count _moves == 0) then {_moves = _weaktargets};	
		if (count _moves == 0) then {_moves = _recons + _flanks};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isSup) then {
		_skip = true;	
	};

	if (VOX_CMD_SKIPS > (count VOX_LOC_SELECTABLE)) then {
		if (count VOX_LOC_ORDERS > 0) then {
			private _pos = (VOX_LOC_ORDERS select floor random count VOX_LOC_ORDERS) select 0;
			_pos call VOX_FNC_ORDER;
			_skip = false;
		} else {_skip = true};
	};
	
	/// switch side if there's no valid orders
	if (VOX_CMD_SKIPS > ((count VOX_LOC_SELECTABLE) * 2)) then {
		private _turn = east;
		if (VOX_TURN == east) then {_turn = west};
		
		VOX_MOTOSKIP = 1;
		VOX_TURN = _turn;
		publicVariable "VOX_TURN";
		
		/// strategic update
		remoteExec ["VOX_FNC_UPDATE", 0];
		_skip = false;
	};
	
	if (_skip) then {
		VOX_CMD_SKIPS = VOX_CMD_SKIPS + 1;
		_side call VOX_FNC_STRATCMD;
		if (VOX_DEBUG) then {
			hint ("CMD skip: " + str VOX_CMD_SKIPS);
		};
	};
};

VOX_FNC_STRATCMD = {
	private _side = _this;
	sleep 1;
	
	_side call VOX_FNC_SELECTABLE;
	/// [[_seed1],[_seed2]]
	private _select = VOX_LOC_SELECTABLE select floor random count VOX_LOC_SELECTABLE;
	[_select select 0, _side] call VOX_FNC_SELECT;
	
	private _sidCol = "ColorBLUFOR";
	private _enyCol = "ColorOPFOR";
	if (_side == east) then {
		_sidCol = "ColorOPFOR";
		_enyCol = "ColorBLUFOR";
	};
	
	private _seed = VOX_LOC_SELECTED;
	private _unit = _seed select 4;
	private _morale = _seed select 5;
	
	/// weighted system
	/// _ordWeight = (_enyVAL - _bluVAL) + _objVAL

	/// _enyVAL: isHVT = +2, _isREC = +1, _mor < 50 = +1, isMEC = -1
	/// _bluVAL: isHVT = +2, _isREC = +1, _mor < 50 = +1, isMEC = -1
	/// _objVal: _isKEY = +1, _isCIV = +1, isBluLog (blulog < 5000) + 1, isEnyLog +1, isEny = -1

	/// moto example: 	_enyVal = 0 (nobody)	
	/// 				_bluVAl = 1
	/// 				_objVal = 2 (CIV,KEY)
	///					_ordWgt = (0 - 1) + 2 = 1 -> proceed
	
	/// moto example2: 	_enyVal = 2 (isHVT)	
	/// 				_bluVAl = 1
	/// 				_objVal = 0 (normal cell)
	///					_ordWgt = (2 - 1) + 0 = 1 -> proceed
	
	/// mech example:
	///		_enyVal = -1 (mech)
	///		_bluVal = -1 
	///		_objVal = 1 (isKey +1, isEny -1, isEnyLog +1);
	/// 	_total: (0) + 1 = 1 -> proceed
	
	private _recons = VOX_LOC_ORDERS select {_x select 1 == "colorBLACK"};
	private _keyrecons = VOX_LOC_ORDERS select {_x select 1 == "colorBLACK" && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _flanks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 == "hd_dot"};
	private _keyflanks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _keyroutes = VOX_LOC_ORDERS select {_x select 1 == _sidCol && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _retreats = VOX_LOC_ORDERS select {_x select 1 == _sidCol};
	
	private _attacks = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 != "hd_dot"};	
	private _hvtargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 in ["b_support","b_art","b_plane","o_support","o_art","o_plane"]};
	private _keytargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 3 in ["NAV", "AIR", "ALT"]};
	private _weaktargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 5 < 0.5};
	private _rectargets = VOX_LOC_ORDERS select {_x select 1 == _enyCol && _x select 4 in ["b_recon", "b_motor_inf", "b_air", "o_recon", "o_motor_inf", "o_air"]};
	
	private _isArm =  _unit in ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"];
	private _isRec = _unit in ["b_recon", "b_motor_inf", "b_air", "o_recon", "o_motor_inf", "o_air"];
	private _isSup = _unit in ["b_support", "o_support","b_art", "o_art", "b_plane", "o_plane"];
	
	private _isInf = !(_isArm or _isRec or _isSup);
	private _skip = false;
	
	if (_isArm) then {
		private _moves = _attacks;
		if (count _moves == 0) then {_moves = _keyrecons};
		if (count _moves == 0) then {_moves = _recons};
		if (count _moves == 0) then {_moves = _keyflanks};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isInf) then {
		private _moves = _keyrecons;
		if (count _moves == 0) then {_moves = _weaktargets};
		if (count _moves == 0) then {_moves = _rectargets};
		if (count _moves == 0) then {_moves = _recons};
		if (count _moves == 0) then {_moves = _keyflanks};
		if (count _moves == 0) then {_moves = _keytargets};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};	
	
	if (_isRec) then {
		private _moves = _hvtargets;
		if (count _moves == 0) then {_moves = _weaktargets};
		if (count _moves == 0) then {_moves = _recons + _flanks};
		if (count _moves != 0 && _morale > 0.5) then {
			private _pos = (_moves select floor random count _moves) select 0;
			_pos call VOX_FNC_ORDER;
		} else {_skip = true};
	};
	
	if (_isSup) then {
		_skip = true;	
	};

	if (VOX_CMD_SKIPS > (count VOX_LOC_SELECTABLE)) then {
		if (count VOX_LOC_ORDERS > 0) then {
			private _pos = (VOX_LOC_ORDERS select floor random count VOX_LOC_ORDERS) select 0;
			_pos call VOX_FNC_ORDER;
			_skip = false;
		} else {_skip = true};
	};
	
/// 	switch side if there's no valid orders
///	if (VOX_CMD_SKIPS > ((count VOX_LOC_SELECTABLE) * 2)) then {
///		private _turn = east;
///		if (VOX_TURN == east) then {_turn = west};
		
///		VOX_MOTOSKIP = 1;
///		VOX_TURN = _turn;
///		publicVariable "VOX_TURN";
		
		/// strategic update
///		remoteExec ["VOX_FNC_UPDATE", 0];
///		_skip = false;
///	};
	
	if (_skip) then {
		VOX_CMD_SKIPS = VOX_CMD_SKIPS + 1;
		if (VOX_DEBUG) then {
			systemChat ("CMD skip: " + str VOX_CMD_SKIPS);
		};
		_side call VOX_FNC_STRATCMD;
	};
};


/// attack value = _enyVal (_hvt + _mor) + _objVal (_key + _pos) + _forVal (_hvt + _mor)
/// recon value = _col + _pos + _rec
/// defend value = _hvt + _pos + _key

VOX_FNC_STRATCMD = {
	sleep 1;
	private _side = _this;
	private _sid = "ColorBLUFOR";
	private _eny = "ColorOPFOR";
	private _base = VOX_BASE_WEST;
	private _enybase = VOX_BASE_EAST;
	if (_side == east) then {
		_sid = "ColorOPFOR";
		_eny = "ColorBLUFOR";
		_base = VOX_BASE_EAST;
		_enybase = VOX_BASE_WEST;
	};
	
	_mec = ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"];
	_inf = ["b_inf", "b_motor_inf", "b_naval", "o_inf", "o_motor_inf", "o_naval"];
	_rec = ["b_recon", "b_air", "o_recon", "o_air"];
	_hvt = ["b_support", "o_support","b_art", "o_art", "b_plane", "o_plane"];	
	_key = ["NAV", "AIR", "ALT"];
	
	/// forces ratio X factor
	private _bluX = 0;
	private _enyX = 0;
	
	/// map control X factior
	private _bluY = 0;
	private _total = 0;
	_keys = 0;
	
	/// total map distance
	private _distance = VOX_BASE_WEST distance VOX_BASE_EAST;
	
	{
		private _colorX = _x select 1;
		private _typeY = _x select 3;
		private _unitX = _x select 4;
		private _moraleX = _x select 5;
		private _score = 3;
		if (_unitX in _mec) then {_score = 4};
		if (_unitX in _rec) then {_score = 2};
		if (_unitX in _hvt) then {_score = 1};
		_score = _score * _moraleX;
		
		if (_colorX == _sid && _unitX != "hd_dot") then {_bluX = _bluX + _score};
		if (_colorX == _eny && _unitX != "hd_dot") then {_enyX = _enyX + _score};
		if (_colorX == _sid) then {_bluY = _bluY + 1};
		if (_typeY in ["AIR", "NAV", "ALT"]) then {_keys = _keys + 1};
		_total = _total + 1;
	}forEach VOX_GRID;
	
	_ratio = _bluX / _enyX;
	_quota = 1 - (_bluY / _total);
	_keyval = 1 / _keys;
	
	_side call VOX_FNC_SELECTABLE;	
	/// [_weight, _selectpos, _orderpos]	
	private _weighted = [];
	
	{
		sleep 0.1;
		private _selPos = _x select 0;
		[_selPos, _side] call VOX_FNC_SELECT;
		
		private _seed = VOX_LOC_SELECTED;
		private _type = _x select 3;
		private _unit = _seed select 4;
		private _morale = _seed select 5;
		private _isHVT = _unit in _hvt;
		private _isREC = _unit in _rec;
		private _isINF = _unit in _inf;
		private _isMEC = _unit in _mec;
		
		private _wBLU = 0;
		if (_isHVT) then {_wBLU = 1};
		if (_isREC) then {_wBLU = 2};
		if (_isINF) then {_wBLU = 3};
		if (_isMEC) then {_wBLU = 4};
		_wBLU = _wBLU * _morale;
		
		{
			sleep 2;
			
			private _unit2 = _x select 4;
			private _morale2 = _x select 5;
			private _isHVT2 = _unit2 in _hvt;
			private _isREC2 = _unit2 in _rec;
			private _isINF2 = _unit2 in _inf;
			private _isMEC2 = _unit2 in _mec;
		
			private _wENY = 0;
			if (_isHVT2) then {_wENY = 1};
			if (_isREC2) then {_wENY = 2};
			if (_isINF2) then {_wENY = 3};
			if (_isMEC2) then {_wENY = 4};
			_wENY = _wENY * _morale2;
			
			private _ordPos = _x select 0;
			private _ordDis = ((_ordPos distance _base) + 1) /_distance;
			private _isKEY = (_x select 3) in _key;
			private _isCIV = (_x select 1) == "ColorBLACK";
			private _isENY = (_x select 1) == _eny && _unit2 == "hd_dot";
			private _inKEY = _type in _key;
			
			/// _ordDis = 0-1 from enybase
			/// _quota = 0.1-1 not held areas
			
			/// TODO: fix this shit
			
			private _wCONQ = _ordDis - _quota;
			if (_isKEY) then {_wCONQ = _wCONQ + _keyVal};
			if (_isCIV) then {_wCONQ = _wCONQ + 0.2};
			if (_isENY) then {_wCONQ = _wCONQ + 0.1};
			if (_inKEY) then {_wCONQ = _wCONQ - _keyVal};
			
			/// RSK-RWD	...		...		...		...		...		...		...		...
			/// 3 (rec)	2 (inf)	4 (hvt)	1 (mec)	2(inf)	1(mec)	2(inf)	4(hvt)	1(mec)
			/// 2 (inf)	3 (rec)	1 (mec)	4 (hvt)	4(sup)	5(civ)	5(civ)	5(civ)	3(rec)
			/// 2-3 =-1	3-2 =1	1-4=-3	4-1=3	4-2=2	5-1=0.5	5-2=0.3 1=0.1	3-1=2
			private _risk = 5 - _wBLU; /// MEC -> 1, REC -> 3
			private _reward = (5 - _wENY) * _ratio;
			private _wDEST = _reward - _risk;
			if (_unit2 == "hd_dot") then {_wDEST = _wDEST/10};

			private _weight = _wDEST + (_wCONQ / 10);
			
			_weighted pushback [_weight, _selPos, _ordPos];			
			
			if (VOX_DEBUG) then {
				deleteMarker "ORDER";
				_marker = createMarker ["ORDER", _ordPOS];
				_marker setMarkerType _unit;
				_marker setMarkerText ("DEST:" + str  _wDEST + " CONQ:" + str  _wCONQ);
				_marker setMarkerColor "ColorWHITE";
			};
		}forEach VOX_LOC_ORDERS;
	}forEach VOX_LOC_SELECTABLE;
	
	_weighted sort false;
	private _highest = (_weighted select 0) select 0;
	private _allbest = _weighted select {_x select 0 == _highest};
	private _select = _allbest select floor random count _allbest;
	
	_side call VOX_FNC_SELECTABLE;
	[_select select 1, _side] call VOX_FNC_SELECT;
	(_select select 2) call VOX_FNC_ORDER;
	
	if (VOX_DEBUG) then {
		systemChat ("AI ORD: " + str _side + " RATIO: " + str _ratio + " QUOTA: " + str _quota + " WEIGHT: " + str _highest);
	};
};

VOX_FNC_STRATCMD = {
	sleep 1;
	private _side = _this;
	private _sid = "ColorBLUFOR";
	private _eny = "ColorOPFOR";
	private _base = VOX_BASE_WEST;
	private _enybase = VOX_BASE_EAST;
	if (_side == east) then {
		_sid = "ColorOPFOR";
		_eny = "ColorBLUFOR";
		_base = VOX_BASE_EAST;
		_enybase = VOX_BASE_WEST;
	};
	
	_mec = ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"];
	_inf = ["b_inf", "b_motor_inf", "b_naval", "o_inf", "o_motor_inf", "o_naval"];
	_rec = ["b_recon", "b_air", "o_recon", "o_air"];
	_hvt = ["b_support", "o_support","b_art", "o_art", "b_plane", "o_plane"];	
	_key = ["NAV", "AIR", "ALT"];
	
	/// forces ratio X factor
	private _bluX = 0;
	private _enyX = 0;
	
	/// map control X factior
	private _bluY = 0;
	private _enyY = 0;
	_keys = 0;
	
	/// total map distance
	private _distance = VOX_BASE_WEST distance VOX_BASE_EAST;
	
	{
		private _selPos = _x select 0;
		[_selPos, _side] call VOX_FNC_SELECT;
		private _seed = VOX_LOC_SELECTED;	
	
		private _colorX = _x select 1;
		private _typeY = _x select 3;
		private _unitX = _x select 4;
		private _moraleX = _x select 5;
		private _score = 3;
		if (_unitX in _mec) then {_score = 4};
		if (_unitX in _rec) then {_score = 2};
		if (_unitX in _hvt) then {_score = 1};
		_score = _score * _moraleX;
		
		if (_colorX == _sid && _unitX != "hd_dot") then {_bluX = _bluX + _score; _bluY = _bluY + 1};
		if (_colorX == _eny && _unitX != "hd_dot") then {_enyX = _enyX + _score; _enyY = _enyY + 1};

		if (_typeY in ["AIR", "NAV", "ALT"]) then {_keys = _keys + 1};
		_total = _total + 1;
	}forEach VOX_GRID;
	
	_ratio = _enyX / _bluX;
	_quota = _enyY / _bluY;
	_keyval = 1 / _keys;
	
	_side call VOX_FNC_SELECTABLE;	
	/// [_weight, _selectpos, _orderpos]	
	private _weighted = [];
	
	{
		sleep 0.1;
		[_pos, _side] call VOX_FNC_SELECT;
		
		private _seed = VOX_LOC_SELECTED;
		private _pos = _seed select 0;
		private _type = _seed select 3;
		private _unit = _seed select 4;
		private _morale = _seed select 5;
		private _bluVal = 0;
		if (_unit in _hvt) then {_bluVal = 1};
		if (_unit in _rec) then {_bluVal = 2};
		if (_unit in _inf) then {_bluVal = 3};
		if (_unit in _mec) then {_bluVal = 4};
		_bluVal = _bluVal * _morale;
		
		private _bluLoc = (_pos distance _base) /_distance;
		if (_type in _key) then {_bluLoc = _bluLoc + _keyVal};
		
		{
			sleep 2;
			
			private _seed = VOX_LOC_SELECTED;
			private _pos2 = _seed select 0;
			private _type2 = _seed select 3;
			private _unit2 = _seed select 4;
			private _morale2 = _seed select 5;
			private _enyVal = 0;
			if (_unit in _hvt) then {_enyVal = 1};
			if (_unit in _rec) then {_enyVal = 2};
			if (_unit in _inf) then {_enyVal = 3};
			if (_unit in _mec) then {_enyVal = 4};
			_enyVal = _enyVal * _morale;
		
			private _enyLoc = (_pos2 distance _enybase) /_distance;
			if (_type2 in _key) then {_enyLoc = _enyLoc + _keyVal};
			
			private _risk = _bluVal - (_enyVal*_ratio); /// 4mec - 2rec = 2, 2Rec - 4mec = -2, _blu 4 - (3*1.5) = -0.5
			private _gain = _bluLoc - (_enyLoc*_quota);
			private _weight = _risk + _gain;
			
			_weighted pushback [_weight, _selPos, _ordPos];			
			
			if (VOX_DEBUG) then {
				deleteMarker "ORDER";
				_marker = createMarker ["ORDER", _ordPOS];
				_marker setMarkerType _unit;
				_marker setMarkerText ("RSK:" + str _risk + " GIN:" + str  _gain);
				_marker setMarkerColor "ColorWHITE";
			};
		}forEach VOX_LOC_ORDERS;
	}forEach VOX_LOC_SELECTABLE;
	
	_weighted sort false;
	private _highest = (_weighted select 0) select 0;
	private _allbest = _weighted select {_x select 0 == _highest};
	private _select = _allbest select floor random count _allbest;
	
	_side call VOX_FNC_SELECTABLE;
	[_select select 1, _side] call VOX_FNC_SELECT;
	(_select select 2) call VOX_FNC_ORDER;
	
	if (VOX_DEBUG) then {
		systemChat ("AI ORD: " + str _side + " RATIO: " + str _ratio + " QUOTA: " + str _quota + " WEIGHT: " + str _highest);
	};
};

/// spawn groups (on server)
/// spawn all groups on attacker/defender
/// spawn 1x random group on all counters on map (exc. original)

private _fnc_findCfg = {};

private _fnc_spawnGroup = {
	/// [_pos, _vehicles, _group, _morale, _supplies, _icon, _name]
	private _pos = _this select 0;
	private _vehs = _this select 1;
	private _grp = _this select 2;
	private _morale = _this select 3;
	
	{
		if (random 1 <= _morale) then {
			/// TODO: add check if vehicle is a boat
			private _pos2 = [_pos, 0, 50, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
			[_pos2, random 360, _x, _grp] call BIS_fnc_spawnVehicle;
		};
	}forEach _vehs;
	
	if (_side == side player) then {
		{addSwitchableUnit _x}forEach units _grp;
	};
};


{
	if (_x in [VOX_ATTACKER, VOX_DEFENDER] == false && _x select 4 != "hd_dot") then {
		
		private _color = _x select 1;
		private _unit = _x select 4;
		private _morale = _x select 5;
		private _cells = _x select 6;
		private _supplies = 1; /// TODO: change to depend if side has LOG unit
		
		private _side = west;
		if (_color == "ColorOPFOR") then {_side = east};
		
		private _cell = _cells select floor random count _cells;
		private _row = _cell select 0;
		private _col = _cell select 1;
		private _pos = [_col * VOX_SIZE, _row * VOX_SIZE];		
		
		/// might be broken?
		private _configs = 	["b_inf","b_mech_inf","b_armor","b_recon","b_air","b_naval","b_support","b_art","b_plane","o_inf","o_motor_inf","o_mech_inf","o_armor","o_recon","o_air","o_naval","o_support","o_art","o_plane"];
		private _index = 0;
		
		{
			if (_unit == _x) then {_index = _forEachIndex}
		}forEach _configs;
		
		private _config = VOX_CONFIG select _index;
		private _config = _config select floor random count _config;
		
		private _icon = _config select 0;
		private _name = _config select 1;
		private _toSpawn = _config select 2;
		
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
			private _configs = "true" configClasses _toSpawn;
			{
				private _veh =  getText (_x >> "vehicle");
				_vehicles pushBack _veh;
			}forEach _configs;
		};
		
		/// [_pos2, random 360, _x, _group] call BIS_fnc_spawnVehicle;
		if (_isGroup or _isVehicle) then {
			private _group = createGroup [_side, true];			
			[_pos, _vehicles, _group, _morale, _supplies, _icon, _name] call _fnc_spawnGroup;
		}; 
	};
}forEach VOX_GRID;
/// synch aircart to aristrike support
/// sync helicopters to gunship support
/// sync helicopters with cargoseat to transport support

/// set HQ setGroupId ["Command Group"];
/// start objective loop
/// spawn jukebox

/// if SUP is not present:
/// random ammo
/// random fuel
/// random skill

/// close map
/// debug group

private _martaGRP = createGroup sideLogic;
private _marta = "MartaManager" createUnit [
	[0, 0, 0],
	_martaGRP,
	"setGroupIconsVisible [true, false];"
];

/// open teamswitch menu and close map&menu
remoteExec ["VOX_FNC_CLOSEMAP", 0];
remoteExec ["VOX_FNC_SLOTTING", 0];

/// contains cfgGroups and CfgVehicles entires
VOX_CONFIG = [
	[
		["\A3\ui_f\data\map\markers\nato\b_mortar.paa","NATO Mortar Team",["West","BLU_F","Support","BUS_Support_Mort"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Weapons Squad",["West","BLU_F","Infantry","BUS_InfSquad_Weapons"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Weapons Squad",["West","BLU_F","Infantry","BUS_InfSquad_Weapons"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Anti-armor Team",["West","BLU_F","Infantry","BUS_InfTeam_AT"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Air-defense Team",["West","BLU_F","Infantry","BUS_InfTeam_AA"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Mortar Team",["West","BLU_F","Motorized","BUS_MotInf_MortTeam"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Team",["West","BLU_F","Motorized","BUS_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Team",["West","BLU_F","Motorized","BUS_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Team",["West","BLU_F","Motorized","BUS_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Team",["West","BLU_F","Motorized","BUS_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Team",["West","BLU_F","Motorized","BUS_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Reinforcements",["West","BLU_F","Motorized","BUS_MotInf_Reinforce"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Reinforcements",["West","BLU_F","Motorized","BUS_MotInf_Reinforce"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Anti-armor Team",["West","BLU_F","Motorized","BUS_MotInf_AT"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Air-defense Team",["West","BLU_F","Motorized","BUS_MotInf_AA"]]
	],
	
	[	
		["\A3\armor_f_gamma\MBT_01\Data\UI\Slammer_M2A1_Base_ca.paa","M2A4 Slammer UP",["B_MBT_01_TUSK_F"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Anti-armor Squad",["West","BLU_F","Mechanized","BUS_MechInf_AT"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Anti-armor Squad",["West","BLU_F","Mechanized","BUS_MechInf_AT"]],
		["\A3\armor_f_gamma\MBT_01\Data\UI\Slammer_M2A1_Base_ca.paa","M2A4 Slammer UP",["B_MBT_01_TUSK_F"]],
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Air-defense Team",["West","BLU_F","Motorized","BUS_MotInf_AA"]]
	],
	
	[
		["\A3\armor_f_beta\APC_Tracked_01\Data\UI\APC_Tracked_01_CRV_ca.paa","CRV-6e Bobcat",["B_APC_Tracked_01_CRV_F"]],
		["\A3\armor_f_gamma\MBT_01\Data\UI\Slammer_M2A1_Base_ca.paa","M2A1 Slammer",["B_MBT_01_cannon_F"]],
		["\A3\armor_f_gamma\MBT_01\Data\UI\Slammer_M2A1_Base_ca.paa","M2A1 Slammer",["B_MBT_01_cannon_F"]],
		["\A3\armor_f_gamma\MBT_01\Data\UI\Slammer_M2A1_Base_ca.paa","M2A1 Slammer",["B_MBT_01_cannon_F"]],
		["\A3\armor_f_gamma\MBT_01\Data\UI\Slammer_M2A1_Base_ca.paa","M2A1 Slammer",["B_MBT_01_cannon_F"]],
		["\A3\armor_f_gamma\MBT_01\Data\UI\Slammer_M2A1_Base_ca.paa","M2A1 Slammer",["B_MBT_01_cannon_F"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Anti-armor Squad",["West","BLU_F","Mechanized","BUS_MechInf_AT"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Anti-armor Squad",["West","BLU_F","Mechanized","BUS_MechInf_AT"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Anti-armor Squad",["West","BLU_F","Mechanized","BUS_MechInf_AT"]],
		["\A3\armor_f_beta\APC_Tracked_01\Data\UI\APC_Tracked_01_AA_ca.paa","IFV-6a Cheetah",["B_APC_Tracked_01_AA_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\b_recon.paa","NATO Recon UAV Team",["West","BLU_F","SpecOps","BUS_ReconTeam_UAV"]],
		["\A3\ui_f\data\map\markers\nato\b_recon.paa","NATO Recon Team",["West","BLU_F","Infantry","BUS_ReconTeam"]],
		["\A3\ui_f\data\map\markers\nato\b_recon.paa","NATO Recon Team",["West","BLU_F","Infantry","BUS_ReconTeam"]],
		["\A3\ui_f\data\map\markers\nato\b_recon.paa","NATO Recon Team",["West","BLU_F","Infantry","BUS_ReconTeam"]],
		["\A3\ui_f\data\map\markers\nato\b_recon.paa","NATO Recon Team",["West","BLU_F","Infantry","BUS_ReconTeam"]],
		["\A3\ui_f\data\map\markers\nato\b_recon.paa","NATO Recon Team",["West","BLU_F","Infantry","BUS_ReconTeam"]],
		["\A3\ui_f\data\map\markers\nato\b_recon.paa","NATO Sniper Team",["West","BLU_F","Infantry","BUS_SniperTeam"]],
		["\A3\Soft_F_Exp\LSV_01\Data\UI\LSV_01_base_CA.paa","Prowler (HMG)",["B_LSV_01_armed_F"]],
		["\A3\Soft_F_Exp\LSV_01\Data\UI\LSV_01_base_CA.paa","Prowler (AT)",["B_LSV_01_AT_F"]],
		["\A3\Air_F\Heli_Light_01\Data\UI\Heli_Light_01_CA.paa","MH-9 Hummingbird",["B_Heli_Light_01_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Weapons Squad",["West","BLU_F","Infantry","BUS_InfSquad_Weapons"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Rifle Squad",["West","BLU_F","Infantry","BUS_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Weapons Squad",["West","BLU_F","Infantry","BUS_InfSquad_Weapons"]],
		["\A3\Air_F_Beta\Heli_Transport_01\Data\UI\Heli_Transport_01_base_CA.paa","UH-80 Ghost Hawk",["B_Heli_Transport_01_F"]],
		["\A3\Air_F_Heli\Heli_Transport_03\Data\UI\Heli_Transport_03_base_CA.paa","CH-67 Huron",["B_Heli_Transport_03_F"]],
		["A3\Air_F\Heli_Light_01\Data\UI\Heli_Light_01_armed_CA.paa","AH-9 Pawnee",["B_Heli_Light_01_dynamicLoadout_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\b_mortar.paa","NATO Mortar Team",["West","BLU_F","Support","BUS_Support_Mort"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa","NATO Mechanized Rifle Squad",["West","BLU_F","Mechanized","BUS_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Anti-armor Team",["West","BLU_F","Infantry","BUS_InfTeam_AT"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Air-defense Team",["West","BLU_F","Infantry","BUS_InfTeam_AA"]],
		["\A3\ui_f\data\map\markers\nato\b_inf.paa","NATO Diver Team (Boat)",["West","BLU_F","SpecOps","BUS_DiverTeam_Boat"]],
		["\A3\boat_f\Boat_Armed_01\data\ui\Boat_Armed_01_minigun.paa","Speedboat Minigun",["B_Boat_Armed_01_minigun_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Reinforcements",["West","BLU_F","Motorized","BUS_MotInf_Reinforce"]],
		["\a3\soft_f_gamma\Truck_01\Data\UI\Truck_01_box_F_CA.paa","HEMTT Repair",["B_Truck_01_Repair_F"]],
		["\a3\soft_f_gamma\Truck_01\Data\UI\Truck_01_Ammo_CA.paa","HEMTT Ammo",["B_Truck_01_ammo_F"]],
		["\a3\soft_f_gamma\Truck_01\Data\UI\Truck_01_Fuel_CA.paa","HEMTT Fuel",["B_Truck_01_fuel_F"]]
	],
		
	[
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Reinforcements",["West","BLU_F","Motorized","BUS_MotInf_Reinforce"]],
		["\A3\Armor_F_Gamma\MBT_01\Data\UI\Slammer_Scorcher_M4_Base_ca.paa","M4 Scorcher",["B_MBT_01_arty_F"]],
		["\A3\Armor_F_Gamma\MBT_01\Data\UI\Slammer_Scorcher_M4_Base_ca.paa","M4 Scorcher",["B_MBT_01_arty_F"]],
		["\A3\Armor_F_Gamma\MBT_01\Data\UI\Slammer_MLRS_Base_ca.paa","M5 Sandstorm MLRS",["B_MBT_01_mlrs_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa","NATO Motorized Reinforcements",["West","BLU_F","Motorized","BUS_MotInf_Reinforce"]],
		["\A3\Air_F_Beta\Heli_Attack_01\Data\UI\Heli_Attack_01_CA.paa","AH-99 Blackfoot",["B_Heli_Attack_01_dynamicLoadout_F"]],
		["\A3\Air_F_EPC\Plane_CAS_01\Data\UI\Plane_CAS_01_CA.paa","A-164 Wipeout (CAS)",["B_Plane_CAS_01_dynamicLoadout_F"]],
		["\A3\Air_F_Jets\Plane_Fighter_01\Data\UI\Fighter01_picture_ca.paa","F/A-181 Black Wasp II",["B_Plane_Fighter_01_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\o_mortar.paa","CSAT Mortar Team",["East","OPF_F","Support","OI_support_Mort"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Rifle Squad",["East","OPF_F","Infantry","OIA_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Rifle Squad",["East","OPF_F","Infantry","OIA_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Rifle Squad",["East","OPF_F","Infantry","OIA_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Rifle Squad",["East","OPF_F","Infantry","OIA_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Rifle Squad",["East","OPF_F","Infantry","OIA_InfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Weapons Squad",["East","OPF_F","Infantry","OIA_InfSquad_Weapons"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Weapons Squad",["East","OPF_F","Infantry","OIA_InfSquad_Weapons"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Anti-armor Team",["East","OPF_F","Infantry","OIA_InfTeam_AT"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Air-defense Team",["East","OPF_F","Infantry","OIA_InfTeam_AA"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Mortar Team",["East","OPF_F","Motorized_MTP","OIA_MotInf_MortTeam"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Team",["East","OPF_F","Motorized_MTP","OIA_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Team",["East","OPF_F","Motorized_MTP","OIA_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Team",["East","OPF_F","Motorized_MTP","OIA_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Team",["East","OPF_F","Motorized_MTP","OIA_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Team",["East","OPF_F","Motorized_MTP","OIA_MotInf_Team"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Reinforcements",["East","OPF_F","Motorized_MTP","OIA_MotInf_Reinforce"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Reinforcements",["East","OPF_F","Motorized_MTP","OIA_MotInf_Reinforce"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Anti-armor Team",["East","OPF_F","Motorized_MTP","OIA_MotInf_AT"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Air-defense Team",["East","OPF_F","Motorized_MTP","OIA_MotInf_AA"]]
	],
	
	[
		["\A3\armor_f_gamma\MBT_02\Data\UI\MBT_02_Base_ca.paa","T-100 Varsuk",["O_MBT_02_cannon_F"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],
		["\A3\armor_f_gamma\MBT_02\Data\UI\MBT_02_Base_ca.paa","T-100 Varsuk",["O_MBT_02_cannon_F"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Anti-armor Squad",["East","OPF_F","Mechanized","OIA_MechInf_AT"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Anti-armor Squad",["East","OPF_F","Mechanized","OIA_MechInf_AT"]],
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Air-defense Team",["East","OPF_F","Motorized_MTP","OIA_MotInf_AA"]]
	],
	
	[
		["\a3\Armor_F_Decade\MBT_02\Data\UI\MBT_02_RailGun_ca.paa","T-100X Futura",["O_MBT_02_railgun_F"]],
		["\A3\armor_f_gamma\MBT_02\Data\UI\MBT_02_Base_ca.paa","T-100 Varsuk",["O_MBT_02_cannon_F"]],
		["\A3\armor_f_gamma\MBT_02\Data\UI\MBT_02_Base_ca.paa","T-100 Varsuk",["O_MBT_02_cannon_F"]],
		["\A3\armor_f_gamma\MBT_02\Data\UI\MBT_02_Base_ca.paa","T-100 Varsuk",["O_MBT_02_cannon_F"]],
		["\A3\armor_f_gamma\MBT_02\Data\UI\MBT_02_Base_ca.paa","T-100 Varsuk",["O_MBT_02_cannon_F"]],
		["\A3\armor_f_gamma\MBT_02\Data\UI\MBT_02_Base_ca.paa","T-100 Varsuk",["O_MBT_02_cannon_F"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Anti-armor Squad",["East","OPF_F","Mechanized","OIA_MechInf_AT"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Anti-armor Squad",["East","OPF_F","Mechanized","OIA_MechInf_AT"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Anti-armor Squad",["East","OPF_F","Mechanized","OIA_MechInf_AT"]],
		["\A3\armor_f_beta\APC_Tracked_02\Data\UI\APC_Tracked_02_aa_ca.paa","ZSU-39 Tigris",["O_APC_Tracked_02_AA_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Recon UAV Team",["East","OPF_F","SpecOps","OI_ReconTeam_UAV"]],
		["\A3\ui_f\data\map\markers\nato\o_recon.paa","CSAT Recon Team",["East","OPF_F","Infantry","OI_reconTeam"]],
		["\A3\ui_f\data\map\markers\nato\o_recon.paa","CSAT Recon Team",["East","OPF_F","Infantry","OI_reconTeam"]],
		["\A3\ui_f\data\map\markers\nato\o_recon.paa","CSAT Recon Team",["East","OPF_F","Infantry","OI_reconTeam"]],
		["\A3\ui_f\data\map\markers\nato\o_recon.paa","CSAT Recon Team",["East","OPF_F","Infantry","OI_reconTeam"]],
		["\A3\ui_f\data\map\markers\nato\o_recon.paa","CSAT Recon Team",["East","OPF_F","Infantry","OI_reconTeam"]],
		["\A3\ui_f\data\map\markers\nato\o_recon.paa","CSAT Sniper Team",["East","OPF_F","Infantry","OI_SniperTeam"]],
		["\A3\Soft_F_Exp\LSV_02\Data\UI\LSV_02_base_CA.paa","Qilin (Minigun)",["O_LSV_02_armed_F"]],
		["\A3\Soft_F_Exp\LSV_02\Data\UI\LSV_02_base_CA.paa","Qilin (AT)",["O_LSV_02_AT_F"]],
		["\A3\Air_F\Heli_Light_02\Data\UI\Heli_Light_02_CA.paa","PO-30 Orca (Unarmed)",["O_Heli_Light_02_unarmed_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Weapons Squad",["East","OPF_F","Infantry","OIA_InfSquad_Weapons"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Guard Squad",["East","OPF_F","UInfantry","OIA_GuardSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Guard Squad",["East","OPF_F","UInfantry","OIA_GuardSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Guard Squad",["East","OPF_F","UInfantry","OIA_GuardSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Guard Squad",["East","OPF_F","UInfantry","OIA_GuardSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Guard Squad",["East","OPF_F","UInfantry","OIA_GuardSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Weapons Squad",["East","OPF_F","Infantry","OIA_InfSquad_Weapons"]],
		["\A3\Air_F\Heli_Light_02\Data\UI\Heli_Light_02_rockets_CA.paa","PO-30 Orca",["O_Heli_Light_02_dynamicLoadout_F"]],
		["\A3\Air_F\Heli_Light_02\Data\UI\Heli_Light_02_rockets_CA.paa","PO-30 Orca",["O_Heli_Light_02_dynamicLoadout_F"]],
		["\A3\Air_F\Heli_Light_02\Data\UI\Heli_Light_02_rockets_CA.paa","PO-30 Orca",["O_Heli_Light_02_dynamicLoadout_F"]]
	],
		
	[
		["\A3\ui_f\data\map\markers\nato\o_mortar.paa","CSAT Mortar Team",["East","OPF_F","Support","OI_support_Mort"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],[
		"\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_mech_inf.paa","CSAT Mechanized Rifle Squad",["East","OPF_F","Mechanized","OIA_MechInfSquad"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Anti-armor Team",["East","OPF_F","Infantry","OIA_InfTeam_AT"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Air-defense Team",["East","OPF_F","Infantry","OIA_InfTeam_AA"]],
		["\A3\ui_f\data\map\markers\nato\o_inf.paa","CSAT Diver Team (Boat)",["East","OPF_F","SpecOps","OI_diverTeam_Boat"]],
		["\A3\boat_f\Boat_Armed_01\data\ui\Boat_Armed_01_base.paa","Speedboat HMG",["O_Boat_Armed_01_hmg_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Reinforcements",["East","OPF_F","Motorized_MTP","OIA_MotInf_Reinforce"]],
		["\A3\Soft_F_EPC\Truck_03\Data\UI\truck_03_ammo_CA.paa","Tempest Repair",["O_Truck_03_repair_F"]],
		["\A3\Soft_F_EPC\Truck_03\Data\UI\truck_03_box_CA.paa","Tempest Ammo",["O_Truck_03_ammo_F"]],
		["\A3\Soft_F_EPC\Truck_03\Data\UI\truck_03_fuel_CA.paa","Tempest Fuel",["O_Truck_03_fuel_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Reinforcements",["East","OPF_F","Motorized_MTP","OIA_MotInf_Reinforce"]],
		["\A3\armor_f_gamma\MBT_02\Data\ui\MBT_02_Arty_ca.paa","2S9 Sochor",["O_MBT_02_arty_F"]],
		["\A3\armor_f_gamma\MBT_02\Data\ui\MBT_02_Arty_ca.paa","2S9 Sochor",["O_MBT_02_arty_F"]],
		["\A3\armor_f_gamma\MBT_02\Data\ui\MBT_02_Arty_ca.paa","2S9 Sochor",["O_MBT_02_arty_F"]]
	],
	
	[
		["\A3\ui_f\data\map\markers\nato\o_motor_inf.paa","CSAT Motorized Reinforcements",["East","OPF_F","Motorized_MTP","OIA_MotInf_Reinforce"]],
		["\A3\Air_F_Beta\Heli_Attack_02\Data\UI\Heli_Attack_02_CA.paa","Mi-48 Kajman",["O_Heli_Attack_02_dynamicLoadout_F"]],
		["\A3\Air_F_EPC\Plane_CAS_02\Data\UI\Plane_cas_02_F.paa","To-199 Neophron (CAS)",["O_Plane_CAS_02_dynamicLoadout_F"]],
		["A3\Air_F_Jets\Plane_Fighter_02\Data\UI\Fighter02_picture_ca.paa","To-201 Shikra",["O_Plane_Fighter_02_F"]]
	]
];