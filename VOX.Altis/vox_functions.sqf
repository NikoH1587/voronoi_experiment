/// VOX_GRID = [[_pos0, _color1, _seeds2, _type3, _unit4, _morale5, _cells6]];
VOX_FNC_DRAWGRID = 	{
	private _naval = [];
	{
		private _pos = _x select 0;
		private _color = _x select 1;
		private _seeds = _x select 2;
		private _type = _x select 3;
		private _cells = _x select 6;
		private _alpha = 0.5;
		///if (_pos distance VOX_BASE_WEST < 5000) then {_alpha = 0.75};
		///if (_pos distance VOX_BASE_EAST < 5000) then {_alpha = 0.75};
		
		if (_type in ["NAV","ALT"]) then {
			_naval pushback _pos;
		};
		
		/// draw cells
		{
			private _row = _x select 0;
			private _col = _x select 1;
			_posC = [_col * VOX_SIZE, _row * VOX_SIZE];

			private _marker = createMarker [format ["VOX_%1_%2", _row, _col], _posC];
			_marker setMarkerShape "RECTANGLE";
			_marker setMarkerBrush "Solid";
			_marker setMarkerColor _color;
			_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
			_marker setMarkerAlpha _alpha;
		}forEach _cells;
		
		/// draw connection to neighboring
		if (VOX_DEBUG) then {
			{
				private _posS = _x select 0;
				private _typeS = _x select 1;
			}forEach VOX_GRID;
		
			{
				private _posS = _x;
				private _dir = _pos getDir _posS;
				private _posCent = [((_pos select 0) + (_posS select 0)) / 2, ((_pos select 1) + (_posS select 1)) / 2];
				private _markerS = createMarker [format ["VOX_%1", _posCent], _posCent];
				_markerS setMarkerType "mil_box";
				_markerS setMarkerDir _dir;
				_markerS setMarkerSize [0.25, 2];
				_markerS setMarkerAlpha _alpha;
			}forEach _seeds;
		};
	}forEach VOX_GRID;
	
	/// draw naval connections;	
	
	{
		private _posN = _x;
		
		{
			private _posN2 = _x;
			private _dirN = _posN getDir _posN2;
			if (_posN distance _posN2 < 5000) then {
				private _posCN = [((_posN select 0) + (_posN2 select 0)) / 2, ((_posN select 1) + (_posN2 select 1)) / 2];
				private _markerN = createMarker [format ["VOX_%1", _posCN], _posCN];
				_markerN setMarkerType "mil_box";
				_markerN setMarkerDir _dirN;
				_markerN setMarkerSize [0.25, 2];
				_markerN setMarkerAlpha 0.25;
				_markerN setMarkerColor "#(0,1,1,1)"
			};
		}forEach _naval;
	}forEach _naval;
	
	if (VOX_DEBUG) then {
		hint ((str (count allMapMarkers)) + " markers created for " + (str (count VOX_GRID)) + " locations");	
	};
};

VOX_FNC_CLEARGRID = {
	{
		private _color = _x select 1;
		private _cells = _x select 6;
		{
			private _row = _x select 0;
			private _col = _x select 1;
			_pos = [_col * VOX_SIZE, _row * VOX_SIZE];

			private _name = format ["VOX_%1_%2", _row, _col];
			deleteMarker _name;
		}forEach _cells;
	}forEach VOX_GRID;
};

VOX_FNC_UPDATEGRID = {
	private _color = _this select 1;
	private _unit = _this select 4;
	private _cells = _this select 6;

	{
		private _row = _x select 0;
		private _col = _x select 1;

		private _marker = format ["VOX_%1_%2", _row, _col];
		if (markerColor _marker != _color) then {
			_marker setMarkerColor _color;;		
		};
	}forEach _cells;
};

VOX_FNC_DRAWMARKERS = {

	{
		private _pos = _x select 0;
		private _color = _x select 1;
		private _seeds = _x select 2;
		private _unit = _x select 4;
		private _morale = _x select 5;
		
		private _name = format ["VOX_%1", _pos];
		deleteMarkerLocal _name;
		
		private _side = west;
		if (_color == "ColorOPFOR") then {_side = east};	

		/// TODO:
		/// completly hide eny units that are not next to friendly units?

		/// special rule for recon unit
		/// show unit icon when next to it
		private _reconed = false;
		private _seen = false;
		/// also if unit was previously engaged
		if (_morale < 1) then {_reconed = true};
		private _recon = ["o_recon"];
		if (_side == east) then {_recon = ["b_recon"]};
		{
			private _unit2 = _x select 4;
			private _color2 = _x select 1;
			if (_x select 0 in _seeds) then {
				if (_unit2 in _recon) then {_reconed = true};
				if (_color2 == "ColorBLUFOR" && _side == east) then {_seen = true};
				if (_color2 == "ColorOPFOR" && _side == west) then {_seen = true};
			};
		}forEach VOX_GRID;
		
		if (_unit != "hd_dot" && ((side player == _side) or _reconed or VOX_DEBUG)) then {
			private _marker = createMarkerLocal [_name, _pos];
			_marker setMarkerTypeLocal _unit;
			private _text = str (_morale * 100);
			_marker setMarkerText _text + "%";
		};
		
		if (_unit != "hd_dot" && (side player != _side) && _reconed == false && _seen) then {
			private _marker = createMarkerLocal [_name, _pos];
			private _type = "o_unknown";
			if (_side == west) then {_type = "b_unknown"};
			_marker setMarkerTypeLocal _type;
			if (VOX_DEBUG) then {
				_marker setMarkerText str [_unit];
			};
		};		
		
	}forEach VOX_GRID;
};

VOX_FNC_CLEARMARKERS = {
	{
		private _pos = _x select 0;
		private _marker = format ["VOX_%1", _pos];
		deleteMarkerLocal _marker;
	}forEach VOX_GRID;
};

/// strategic update
VOX_FNC_UPDATE = {

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
		onMapSingleClick "";
	};
	
	if (isServer && isPlayer CMD_WEST == false && VOX_TURN == west) then {west spawn {call VOX_FNC_STRATCMD}};
	if (isServer && isPlayer CMD_EAST == false && VOX_TURN == east) then {east spawn {call VOX_FNC_STRATCMD}};
};

VOX_FNC_MOVE = {
	private _old = _this select 0;
	private _new = _this select 1;
	
	private _indexOld = VOX_GRID find _old;
	private _indexNew = VOX_GRID find _new;	
	
	/// switch turn
	private _turn = east;
	if (VOX_TURN == east) then {_turn = west};
	
	/// motorized special handing	
	private _motoskip = 0;
	
	if (VOX_MOTOSKIP == 0) then {
		_motoskip = 1;
	};		
			
	if (((_old select 4) in  ["b_motor_inf", "o_motor_inf"]) && VOX_MOTOSKIP == 1) then {
		private _turn2 = _turn;
			if (_turn2 == west) then {_turn = east};
			if (_turn2 == east) then {_turn = west};
		VOX_MOTOSKIP = 0;
	};
	
	if (_motoskip == 1) then {
		VOX_MOTOSKIP = 1;
	};	
	
	/// next turn
	VOX_TURN = _turn;
	publicVariable "VOX_TURN";
	
	if (_new select 4 == "hd_dot" or _old IsEqualTo _new) then {

		private _newold = [_old select 0, _old select 1, _old select 2, _old select 3, "hd_dot", 1, _old select 6];
		private _newnew = [_new select 0, _old select 1, _new select 2, _new select 3, _old select 4, _old select 5, _new select 6];
		
		VOX_GRID set [_indexOld, _newold];
		VOX_GRID set [_indexNew, _newnew];	
		publicVariable "VOX_GRID";	
	
		/// re-draw markers
		remoteExec ["VOX_FNC_DRAWMARKERS", 0];
		
		/// update grid
		_newnew call VOX_FNC_UPDATEGRID;
		
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
		/// remoteExec ["VOX_FNC_CLEARMARKERS", 0];
		0 call VOX_FNC_CLEARGRID;
		0 call VOX_FNC_DRAWOBJECTIVES;
		///0 call VOX_FNC_SUPPORTS;
		///0 call VOX_FNC_DRAWOBJECTIVES;
		["vox_briefing.sqf"] remoteExec ["execVM"];
	};
};

VOX_FNC_DRAWOBJECTIVES = {
	private _centerA = VOX_ATTACKER select 0;
	private _cellsA = VOX_ATTACKER select 6;
	private _colorA = VOX_ATTACKER select 1;
	
	private _centerD = VOX_DEFENDER select 0;
	private _cellsD = VOX_DEFENDER select 6;
	private _colorD = VOX_DEFENDER select 1;
	
	private _dirAD = _centerD vectorDiff _centerA;
	private _dirDA = _centerA vectorDiff _centerD;
	
	private _fnc_isFront = {
		private _cellPos = _this select 0;
		private _center = _this select 1;
		private _vector = _this select 2;
		
		private _cellVec = _cellPos vectorDiff _center;
		(_cellVec vectorDotProduct _vector) > 0
	};
	
	{
		private _row = _x select 0;
		private _col = _X select 1;
		_pos = [_col * VOX_SIZE, _row * VOX_SIZE];
		
		if ([_pos, _centerA, _dirAD] call _fnc_isFront) then {
			private _name = "OBJA_" + (str _forEachIndex);
			private _marker = createMarker [_name, _pos];
			_marker setMarkerShape "RECTANGLE";
			_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
			_marker setMarkerAlpha 0.5;
			_marker setMarkerColor _colorA;
			
			{
				private _row2 = _x select 0;
				private _col2 = _X select 1;
				_pos2 = [_col2 * VOX_SIZE, _row2 * VOX_SIZE];
				if (_pos2 distance _pos < VOX_SIZE*1.4) then {
					_marker setMarkerColor "ColorBLACK";
				};
			}forEach _cellsD;
		};
	}forEach _cellsA;
	
	{
		private _row = _x select 0;
		private _col = _X select 1;
		_pos = [_col * VOX_SIZE, _row * VOX_SIZE];
		
		if ([_pos, _centerD, _dirDA] call _fnc_isFront) then {		
			private _name = "OBJD_" + (str _forEachIndex);
			private _marker = createMarker [_name, _pos];
			_marker setMarkerShape "RECTANGLE";
			_marker setMarkerSize [VOX_SIZE / 2, VOX_SIZE / 2];
			_marker setMarkerAlpha 0.5;
			_marker setMarkerColor _colorD;
			
			{
				private _row2 = _x select 0;
				private _col2 = _X select 1;
				_pos2 = [_col2 * VOX_SIZE, _row2 * VOX_SIZE];
				if (_pos2 distance _pos < VOX_SIZE*1.4) then {
					_marker setMarkerColor "ColorBLACK";
				};
			}forEach _cellsA;
		};
	}forEach _cellsD;
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
		"a3\sounds_f\sfx\ui\uav\uav_07.wss"
	];
	
	private _sound = _sounds select floor random count _sounds;
	playSoundUI [_sound, 1, 1];
};

VOX_FNC_SFX = {
	private _soundinf = [
		"a3\sounds_f\ambient\battlefield\battlefield_firefight1.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_firefight2.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_firefight3.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_firefight4.wss"	
	];

	private _soundhel = [
		"a3\sounds_f\ambient\battlefield\battlefield_heli1.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_heli2.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_heli3.wss"	
	];

	private _soundart = [
		"a3\sounds_f\ambient\battlefield\battlefield_explosions1.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_explosions2.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_explosions3.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_explosions4.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_explosions5.wss"
	];
	
	private _soundair = [
		"a3\sounds_f\ambient\battlefield\battlefield_jet1.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_jet2.wss",
		"a3\sounds_f\ambient\battlefield\battlefield_jet3.wss"	
	];
	
	private _sounds = [_soundinf, _soundhel, _soundart, _soundair] select _this;
	private _sound = _sounds select floor random count _sounds;
	sleep 3;
	playSoundUI [_sound, 1, 1];
};

VOX_FNC_CLOSEMAP = {
	openMap false;
	(findDisplay 1400) closedisplay 1;
};

