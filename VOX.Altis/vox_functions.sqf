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
			private _alpha = 1;
			if (_morale == 0) then {_alpha = 0.5};
			_marker setMarkerAlpha _alpha;
		};
		
		/// updade ZOC
	}forEach VOX_GRID;
};

VOX_FNC_CLEARMARKERS = {
	{
		private _pos = _x select 0;
		private _cells = _x select 1;
		private _unit = _x select 3;
		private _morale = _x select 5;
		
		private _marker = format ["VOX_%1", _pos];
		deleteMarker _marker;
		
		{
			private _row = _x select 0;
			private _col = _x select 1;
			private _marker2 = format ["VOX_%1_%2", _row, _col];
			deleteMarker _marker2;
		}forEach _cells;
	}forEach VOX_GRID;
};

/// strategic update
VOX_FNC_UPDATE = {

	if (VOX_DEBUG) then {((str VOX_TURN) + " TURN") call VOX_FNC_MESSAGE};

	if (VOX_TURN == side player && VOX_LOC_COMMANDER) then {
		if (VOX_LOC_MODE == "WAITING") then {side player call VOX_FNC_SELECTABLE};
		onMapSingleClick {
			if (VOX_LOC_MODE == "SELECT") then {
				[_pos, side player] spawn VOX_FNC_SELECT;
			};
			if (VOX_LOC_MODE == "ORDER") then {
				_pos spawn VOX_FNC_ORDER;
			};
			true;
		};
	} else {
		onMapSingleClick {true};
	};
	
	if (isServer && isPlayer CMD_WEST == false && VOX_TURN == west) then {west call VOX_FNC_AICMD};
	if (isServer && isPlayer CMD_EAST == false && VOX_TURN == east) then {east call VOX_FNC_AICMD};
};

VOX_FNC_MOVE = {
	private _old = _this select 0;
	private _new = _this select 1;
	
	private _indexOld = VOX_GRID find _old;
	private _indexNew = VOX_GRID find _new;
	
	/// switch turn
	private _turn = east;
	if (VOX_TURN == east) then {_turn = west};
	VOX_TURN = _turn;
	publicVariable "VOX_TURN";
	
	if (_new select 3 == "hd_dot" or _old IsEqualTo _new) then {
		/// [_pos, _cells, _type, _unit, _border, _morale]
		VOX_GRID set [_indexOld, [_old select 0, _old select 1, _old select 2, "hd_dot", _old select 4, 0]];
		VOX_GRID set [_indexNew, [_new select 0, _new select 1, _new select 2, _old select 3, _new select 4, _old select 5]];	
		publicVariable "VOX_GRID";	
	
		/// re-draw markers
		0 call VOX_FNC_DRAWMARKERS;
		
		/// strategic update
		remoteExec ["VOX_FNC_UPDATE", 0];
		
	} else {
		/// if attack, start briefing
		VOX_PHASE = "BRIEFING";
		publicVariable "VOX_PHASE";
		VOX_ATTACKER = _old;
		VOX_DEFENDER = _new;
		publicVariable "VOX_ATTACKER";
		publicVariable "VOX_DEFENDER";
		0 call VOX_FNC_CLEARMARKERS;
		["vox_briefing.sqf"] remoteExec ["execVM"]
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

VOX_FNC_RADIO = {
	private _sounds = [
		"a3\sounds_f\sfx\ui\uav\uav_01.wss",
		"a3\sounds_f\sfx\ui\uav\uav_02.wss",
		"a3\sounds_f\sfx\ui\uav\uav_03.wss",
		"a3\sounds_f\sfx\ui\uav\uav_04.wss",
		"a3\sounds_f\sfx\ui\uav\uav_05.wss",
		"a3\sounds_f\sfx\ui\uav\uav_06.wss",
		"a3\sounds_f\sfx\ui\uav\uav_07.wss",
		"a3\sounds_f\sfx\ui\uav\uav_08.wss",
		"a3\sounds_f\sfx\ui\uav\uav_09.wss"
	];
	
	private _sound = _sounds select floor random count _sounds;
	playSoundUI [_sound, 1 , 1];
};

VOX_FNC_CLOSEMAP = {
	openMap false;
	(findDisplay 1400) closedisplay 1;
};