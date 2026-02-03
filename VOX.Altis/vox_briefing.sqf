waitUntil {!isNil "VOX_ATTACKER"};
waitUntil {!isNil "VOX_DEFENDER"};

private _posA = VOX_ATTACKER select 0;
private _posB = VOX_DEFENDER select 0;
private _posC = [(((_posA select 0) + (_posB select 0)) / 2),(((_posA select 1) + (_posB select 1)) / 2)];
mapAnimAdd [0, 0.2, _posC];
mapAnimCommit;

if (VOX_DEBUG) then {
	private _polyline = [_posA select 0, _posA select 1, _posB select 0, _posB select 1];
	private _marker = createMarker [format ["VOX_%1_%2", _posA, _posB], _posA];
	_marker setMarkerPolyline _polyline;
};

/// objective markers
if (isServer) then {
	private _posA = VOX_ATTACKER select 0;
	private _unitA = VOX_ATTACKER select 3;
	private _moraleA = VOX_ATTACKER select 5;
	private _alphaA = 1;
	if (_moraleA == 0) then {_alphaA = 0.5};
	
	private _posD = VOX_DEFENDER select 0;
	private _cellsD = VOX_DEFENDER select 1;
	private _unitD = VOX_DEFENDER select 3;
	private _moraleD = VOX_ATTACKER select 5;
	private _alphaD = 1;
	if (_moraleD == 0) then {_alphaD = 0.5};

	private _nameA = format ["ATK", _posA];
	private _markerA = createMarker [_nameA, _posA];
	_markerA setMarkerType _unitA;
	_markerA setMarkerSize [1.25, 1.25];
	_markerA setMarkerAlpha _alphaA;
		
	private _nameD = format ["DEF", _posD];
	private _markerD = createMarker [_nameD, _posD];
	_markerD setMarkerType _unitD;
	_markerD setMarkerSize [1.25, 1.25];
	_markerD setMarkerAlpha _alphaD;
		
	private _color = "ColorBLUFOR";
	if (_unitD select [0,1] == "o") then {_color = "ColorOPFOR"};
		
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos2 = [(_col * VOX_SIZE) + VOX_SIZE / 2, (_row * VOX_SIZE) + VOX_SIZE / 2];
			
		private _alpha = 0.25;
		if (isNull (nearestLocation [_pos2, "", VOX_SIZE / 2]) == false) then {_alpha = 0.5};	
			
		private _marker2 = createMarker [format ["OBJ_%1_%2", _row, _col], _pos2];
		_marker2 setMarkerShape "RECTANGLE";
		_marker2 setMarkerBrush "Solid";
		_marker2 setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
		_marker2 setMarkerColor _color;
		_marker2 setMarkerAlpha _alpha;
	}forEach _cellsD
};

/// radio effect for briefing;
0 call VOX_FNC_RADIO;

VOX_FNC_ENDBRIEFING = {
	if (isServer) then {
		VOX_PHASE = "TACTICAL";
		publicVariable "VOX_PHASE";
		execVM "vox_tactical.sqf";
	};
};

/// Open briefing menu
[] spawn {
	private _open = false;
	while {VOX_PHASE == "BRIEFING"} do {
		if (visibleMap && !_open) then {
			_open = true;
			(findDisplay 46) createDisplay "VOX_BRIEFING";
			private _menu = findDisplay 1400;
			private _info = _menu displayCtrl 1401;
			private _start = _menu displayCtrl 1402;
			
			/// Info text backround
			private _color = [0, 0.3, 0.6, 0.5];
			if (playerSide == east) then {
				_color = [0.5, 0, 0, 0.5];
			};

			_info ctrlSetBackgroundColor _color;

			_info lbAdd "TACTICAL BRIEFING:";
			_info lbAdd "Attacker victory if all sectors captured";
			_info lbAdd "Defender victory if 1h timer is reached";
			_info lbAdd "Available supports can be accessed with radio (8 -> 0)";
			_info lbAdd "'Command Group' leader has High Command Module (Ctrl+Space)";
			
			/// Start button text
			if (isServer) then {
				_start ctrlSetText "COMMENCE BATTLE";
			} else {
				_start ctrlSetText "WAITING HOST...";
			};
		};
		
		/// make sure menu doesn't close if map is closed
		if (!visibleMap && _open) then {
			(findDisplay 1400) closedisplay 1;
			_open = false;
			openmap true;
		};
		
		sleep 1;
	};
};