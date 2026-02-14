VOX_CMDBUSY = false;
VOX_FNC_STRATCMD = {
	if (VOX_CMDBUSY) exitWith {};
	VOX_CMDBUSY = true;
	sleep 1;
	private _side = _this;
	private _sid = "ColorBLUFOR";
	private _eny = "ColorOPFOR";
	if (_side == east) then {
		_sid = "ColorOPFOR";
		_eny = "ColorBLUFOR";
	};
	
	_mec = ["b_armor", "b_mech_inf", "o_armor", "o_mech_inf"];
	_inf = ["b_inf", "b_motor_inf", "o_inf", "o_motor_inf"];
	_rec = ["b_recon", "b_air", "b_naval", "o_recon", "o_air", "o_naval"];
	_hvt = ["b_support", "o_support","b_art", "o_art", "b_plane", "o_plane"];	
	_key = ["NAV", "AIR", "ALT"];
	
	_fnc_nearEny = {
		private _bluSeeds = _this select 0;
		private _defVal = _this select 1;
		private _enemyF = -100;
		{
			private _posF = _x select 0;
			private _colF = _x select 1;
			private _unitF = _x select 4;
			private _moraleF = _x select 5;
			
			private _enyValF = -100;
			if (_unitF in _hvt) then {_enyValF = 1};
			if (_unitF in _rec) then {_enyValF = 2};
			if (_unitF in _inf) then {_enyValF = 3};
			if (_unitF in _mec) then {_enyValF = 4};
			_enyValF = _enyValF * _moraleF;			
			
			if (_posF in _bluSeeds && _colF == _eny) then {_enemyF = _enemyF max _enyValF};
		}forEach VOX_GRID;
		if (_enemyF == -100) then {_enemyF = _defVal};
		_enemyF
	};
	
	/// forces ratio X factor
	private _bluX = 0;
	private _enyX = 0;
	
	/// map control Y factior
	private _bluY = 0;
	private _enyY = 0;
	private _total = 0;
	private _bluTot = 0;
	private _posBluX = 0;
	private _posBluY = 0;
	private _keys = 0;
	
	/// TODO: Z factor, AI difficulty?
	
	
	{
		private _posG = _x select 0;
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
		if (_colorX == _sid) then {
			_bluTot = _bluTot + 1; 
			_posBluX = _posBluX + (_posG select 0); 
			_posBluY = _posBluY + (_posG select 1);
		};
		_total = _total + 1;
	}forEach VOX_GRID;
	
	private _ratio = _bluX / _enyX;
	private _keyval = 1 / _keys;
	private _quota = 1 - (_bluTot / _total);
	private _bluBase = [_posBluX / _bluTot, _posBluY / _bluTot];
	
	_side call VOX_FNC_SELECTABLE;	
	/// [_weight, _selectpos, _orderpos]	
	private _weighted = [];
	
	{
		sleep 0.1;
		
		private _pos = _x select 0;
		private _seeds = _x select 2;
		private _type = _x select 3;
		private _unit = _x select 4;
		private _morale = _x select 5;
		
		private _bluVal = 0;
		if (_unit in _hvt) then {_bluVal = 1};
		if (_unit in _rec) then {_bluVal = 2};
		if (_unit in _inf) then {_bluVal = 3};
		if (_unit in _mec) then {_bluVal = 4};
		private _bluVal = (_bluVal * _morale) * _ratio;
		
		private _nearEny = [_seeds, _bluVal] call _fnc_nearEny;
		private _bluDist = (_pos distance _bluBase);
		
		private _bluLoc = 0;
		if (_type in _key) then {_bluLoc = _bluLoc + _keyVal};
		
		[_pos, _side] call VOX_FNC_SELECT;
		{
			sleep 0.1;			
			
			private _pos2 = _x select 0;
			private _color2 = _x select 1;
			private _seeds2 = _x select 2;
			private _type2 = _x select 3;
			private _unit2 = _x select 4;
			private _morale2 = _x select 5;			
			
			private _enyLoc = 0;
			if (_color2 != _sid) then {_enyLoc = _quota};
			if (_type2 in _key) then {_enyLoc = _enyLoc + _keyVal};			
			
			private _nearEny2 = [_seeds2, _bluVal] call _fnc_nearEny;
			private _enyDist = (_pos2 distance _bluBase);			
			
			private _enyVal = _bluVal;
			if (_unit2 in _hvt) then {_enyVal = 1};
			if (_unit2 in _rec) then {_enyVal = 2};
			if (_unit2 in _inf) then {_enyVal = 3};
			if (_unit2 in _mec) then {_enyVal = 4};
			_enyVal = _enyVal * _morale2;
			
			private _risk = _bluVal - _enyVal; /// 2(rec,eny)-4(mec,blu)=-2
			private _danger = _nearEny - _nearEny2; /// 0-4=-4
			private _gain = _enyLoc - _bluLoc; /// 0(civ,eny)-0.2(civ,blu)=-0.2
			private _centDist = [((_pos select 0)+(_pos2 select 0))/2, ((_pos select 1)+(_pos2 select 1))/2] distance _bluBase;
			private _front = (_bluDist - _enyDist) / _centDist;

			_risk = (round (_risk * 10)) / 10; /// round to first decimal			
			_danger = (round (_danger * 10)) / 10; /// round to first decimal			
			_gain = (round (_gain * 10)) / 10; /// round to first decimal
			_front = (round (_front * 10)) / 10; /// round to first decimal
			
			 _weight = _risk + _danger + _gain + _front;
			_weighted pushback [_weight, _pos, _pos2];			
			
			if (VOX_DEBUG) then {
				deleteMarker "ORDER";
				_marker = createMarker ["ORDER", _pos2];
				_marker setMarkerType _unit;
				_marker setMarkerText ("RSK:" + str _risk + " DNG:" + str _danger + " GIN:" + str _gain + " FRT:" + str _front);
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