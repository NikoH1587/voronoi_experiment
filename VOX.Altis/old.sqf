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