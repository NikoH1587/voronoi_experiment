VOX_FNC_DRAWMARKERS = {
	{
		private _pos = _x select 0;
		private _unit = _x select 3;
		private _morale = _x select 5;
		
		private _name = format ["VOX_%1", _pos];
		deleteMarker _name;
		
		if (_unit != "hd_dot") then {
			private _marker = createMarker [_name, _pos];
			_marker setMarkerType _unit;
			_marker setMarkerAlpha (_morale max 0.25);
		};
	}forEach VOX_GRID;
};

VOX_FNC_MOVE = {
	private _old = _this select 0;
	private _new = _this select 1;
	
	private _indexOld = VOX_GRID find _old;
	private _indexNew = VOX_GRID find _new;
	
	if (_new select 3 == "hd_dot") then {
		/// [_pos, _cells, _type, _unit, _border, _morale]
		VOX_GRID set [_indexOld, [_old select 0, _old select 1, _old select 2, "hd_dot", _old select 4, 0]];
		VOX_GRID set [_indexNew, [_new select 0, _new select 1, _new select 2, _old select 3, _new select 4, _old select 5]];	
	
		/// switch turn
		private _turn = east;
		if (VOX_TURN == east) then {_turn = west};
		VOX_TURN = _turn;
		publicVariable "VOX_TURN";	
	
		/// re-draw markers
		0 call VOX_FNC_DRAWMARKERS;
	
		/// show turn message
		((str VOX_TURN) + " TURN") remoteExec ["VOX_FNC_MESSAGE", 0];
	} else {
		VOX_PHASE = "BRIEFING";
		hint str "COMBAT!";
		private _attacker = _old;
		private _defender = _new;
		private _posA = _old select 0;
		private _posB = _new select 0;
		private _posC = [(((_posA select 0) + (_posB select 0)) / 2),(((_posA select 1) + (_posB select 1)) / 2)];
		mapAnimAdd [0, 0.1, _posC];
		mapAnimCommit;
		private _polyline = [_posA select 0, _posA select 1, _posB select 0, _posB select 1];
		private _marker = createMarker [format ["VOX_%1_%2", _posA, _posB], _posA];
		_marker setMarkerPolyline _polyline;
	};
};

VOX_FNC_MESSAGE = {
	systemChat _this;
};

VOX_FNC_SOUND = {
	private _sounds = [
		"a3\dubbing_radio_f\sfx\in2a.ogg",
		"a3\dubbing_radio_f\sfx\in2b.ogg",
		"a3\dubbing_radio_f\sfx\in2c.ogg",
		"a3\dubbing_radio_f\sfx\out2a.ogg",
		"a3\dubbing_radio_f\sfx\out2b.ogg",
		"a3\dubbing_radio_f\sfx\out2c.ogg"
	];
	
	private _sound = _sounds select floor random count _sounds;
	playSoundUI [_sound, 1, random 1];	
};