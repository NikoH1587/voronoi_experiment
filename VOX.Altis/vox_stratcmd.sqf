VOX_FNC_STRATCMD = {
	sleep 1;
	private _side = _this;
	private _sid = "ColorBLUFOR";
	private _eny = "ColorOPFOR";
	private _base = VOX_BASE_EAST;
	if (_side == east) then {
		_sid = "ColorOPFOR";
		_eny = "ColorBLUFOR";
		_base = VOX_BASE_WEST;
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
	
	/// total map distance
	private _distance = VOX_BASE_WEST distance VOX_BASE_EAST;
	
	{
		private _colorX = _x select 1;
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
		_total = _total + 1;
	}forEach VOX_GRID;
	
	_ratio = _bluX / _enyX;
	_quota = _bluY / _total;
	
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
			sleep 1;
			
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
			private _ordDis = _distance / ((_ordPos distance _base) + 1);
			private _isKEY = (_x select 3) in _key;
			private _isCIV = (_x select 1) == "ColorBLACK";
			private _isENY = (_x select 1) == _eny && _unit2 == "hd_dot";
			private _inKEY = _type in _key;
			
			private _wCONQ = _ordDis - _quota;
			if (_isKEY) then {_wCONQ = _wCONQ + 1};
			if (_isCIV) then {_wCONQ = _wCONQ + 1};
			if (_isENY) then {_wCONQ = _wCONQ + 0.5};
			if (_inKEY) then {_wCONQ = _wCONQ - 1};
			
			/// RSK-RWD			...			...			...				...			 ...
			/// 0 (mec)			2 (rec)		1 (inf)		3 (sup)			1 (inf)		 3 (sup)
			/// 4 * 0.75 (mec)	3 * 1 (inf)	3 * 1 (inf)	3 * 1.5 (inf)	4 *  (civ)	 4 - 3 = 1
			/// 3 - 0 = 3		3 - 2 = 1	3 - 1 = 2	4.5 - 3 = 1.5	4 - 1 = 3?	 0 - 3 = -3?
			
			private _risk = 4 - _wBLU; /// MEC -> 0, REC -> 2
			private _reward = _wENY * _ratio; /// 4 * 0.75(losing) = 3 ... 4 * 1.25 (winning) = 5
			private _wDEST = _reward - _risk;
			private _weight = _wDEST + _wCONQ;
			
			if (VOX_DEBUG) then {
				deleteMarker "ORDER";
				_marker = createMarker ["ORDER", _ordPOS];
				_marker setMarkerType _unit;
				_marker setMarkerText ("DEST:" + str _wDEST + " CONQ:" + str _wCONQ + " RWD-RSK: " + str _reward + " - " + str _risk);
				_marker setMarkerColor "ColorWHITE";
				_weighted pushback [_weight, _selPos, _ordPos];
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