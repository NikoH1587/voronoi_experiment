VOX_CMDBUSY = false;
VOX_FNC_STRATCMD = {
	if (VOX_CMDBUSY) exitWith {};
	VOX_CMDBUSY = true;
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
		
		if (_colorX == _sid && _unitX != "hd_dot") then {_bluX = _bluX + _score; _bluY = _bluY + 1};
		if (_colorX == _eny && _unitX != "hd_dot") then {_enyX = _enyX + _score; _enyY = _enyY + 1};

		if (_typeY in ["AIR", "NAV", "ALT"]) then {_keys = _keys + 1};
		private _total = _total + 1;
	}forEach VOX_GRID;
	
	_ratio = _enyX / _bluX;
	_quota = _enyY / _bluY;
	_keyval = 1 / _keys;
	
	_side call VOX_FNC_SELECTABLE;	
	/// [_weight, _selectpos, _orderpos]	
	private _weighted = [];
	
	{
		sleep 0.1;
		
		private _seed = VOX_LOC_SELECTED;
		private _pos = _x select 0;
		private _type = _x select 3;
		private _unit = _x select 4;
		private _morale = _x select 5;
		private _bluVal = 0;
		if (_unit in _hvt) then {_bluVal = 1};
		if (_unit in _rec) then {_bluVal = 2};
		if (_unit in _inf) then {_bluVal = 3};
		if (_unit in _mec) then {_bluVal = 4};
		_bluVal = _bluVal * _morale;
		
		private _bluLoc = (_pos distance _base) /_distance;
		if (_type in _key) then {_bluLoc = _bluLoc + _keyVal};
		
		[_pos, _side] call VOX_FNC_SELECT;
		{
			sleep 1;			
			
			private _pos2 = _x select 0;
			private _color2 = _x select 1;
			private _type2 = _x select 3;
			private _unit2 = _x select 4;
			private _morale2 = _x select 5;
			
			private _enyLoc = (_pos2 distance _enybase) /_distance;
			if (_type2 in _key) then {_enyLoc = _enyLoc + _keyVal};			
			
			private _enyVal = _bluVal;
			if (_unit2 in _hvt) then {_enyVal = 1};
			if (_unit2 in _rec) then {_enyVal = 2};
			if (_unit2 in _inf) then {_enyVal = 3};
			if (_unit2 in _mec) then {_enyVal = 4};
			_enyVal = _enyVal * _morale2;
			
			private _risk = _bluVal - (_enyVal*_ratio); /// 4mec - 2rec = 2, 2Rec - 4mec = -2, _blu 4 - (3*1.5) = -0.5
			private _gain = _bluLoc - (_enyLoc*_quota);
			private _weight = _risk + _gain;
			
			_weighted pushback [_weight, _pos, _pos2];			
			
			if (VOX_DEBUG) then {
				deleteMarker "ORDER";
				_marker = createMarker ["ORDER", _pos2];
				_marker setMarkerType _unit;
				_marker setMarkerText ("RISK:" + str _risk + " GAIN:" + str  _gain);
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
	VOX_CMDBUSY = false;
};