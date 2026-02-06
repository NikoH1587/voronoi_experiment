/// VOX_GRID = [[_pos0, _cells1, _seeds2, _type3, _unit4, _morale5]];

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

VOX_FNC_DRAWDIRS = {
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

			private _marker = createMarker [format ["VOX_%1", _pos1], _pos1];			
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

VOX_FNC_DRAWMARKERS = {
	{
		private _pos = _x select 0;
		private _unit = _x select 4;
		private _morale = _x select 5;
		
		private _name = format ["VOX_%1", _pos];
		deleteMarkerLocal _name;
		
		private _side = west;
		if (_unit select [0, 1] == "o") then {_side = east};		
		
		if (_unit != "hd_dot" && (side player == _side)) then {
			private _marker = createMarkerLocal [_name, _pos];
			_marker setMarkerTypeLocal _unit;
			if (_morale == 0) then {_marker setMarkerAlphaLocal 0.5};
		};
		
		if (_unit != "hd_dot" && (side player != _side)) then {
			private _marker = createMarkerLocal [_name, _pos];
			private _type = "o_unknown";
			if (_side == west) then {_type == "b_unknown"};
			_marker setMarkerTypeLocal _type;
			if (_morale == 0) then {_marker setMarkerAlphaLocal 0.5};
		};		
		
	}forEach VOX_GRID;
};

VOX_FNC_CLEARMARKERS = {
	{
		private _pos = _x select 0;
		private _cells = _x select 2;
		private _unit = _x select 4;

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

		private _newold = [_old select 0, _old select 1, _old select 2, _old select 3, "hd_dot", 0];
		private _newnew = [_new select 0, _new select 1, _new select 2, _new select 3, _old select 4, _old select 5];
		
		VOX_GRID set [_indexOld, _newold];
		VOX_GRID set [_indexNew, _newnew];	
		publicVariable "VOX_GRID";	
	
		/// re-draw markers
		remoteExec ["VOX_FNC_DRAWMARKERS", 0];
		
		/// update grid
		///_newold call VOX_FNC_UPDATEGRID;
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
		remoteExec ["VOX_FNC_CLEARMARKERS", 0];
		0 call VOX_FNC_CLEARGRID;
		0 call VOX_FNC_CLEARDIRS;
		0 call VOX_FNC_SUPPORTS;
		0 call VOX_FNC_DRAWOBJECTIVES;
		["vox_briefing.sqf"] remoteExec ["execVM"];
	};
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
		"a3\sounds_f\sfx\ui\uav\uav_07.wss",
		"a3\sounds_f\sfx\ui\uav\uav_08.wss",
		"a3\sounds_f\sfx\ui\uav\uav_09.wss"
	];
	
	private _sound = _sounds select floor random count _sounds;
	playSoundUI [_sound, 0.5, 1];
};

VOX_FNC_SUPPORTS = {
	private _atk_cells = VOX_ATTACKER select 2;
	private _atk_unit = VOX_ATTACKER select 4;
	private _atk_side = _atk_unit select [0, 1];
	private _def_cells = VOX_DEFENDER select 2;
	private _def_unit = VOX_DEFENDER select 4;
	private _def_side = _def_unit select [0, 1];

	VOX_ATTACK_SUPPORTS = [];
	VOX_DEFEND_SUPPORTS = [];
	{
		private _pos = _x select 0;
		private _unit = _x select 4;
		private _side = _unit select [0, 1];
		if (_pos in _atk_cells && _side == _atk_side) then {
			VOX_ATTACK_SUPPORTS pushback _x;
		};
		
		if (_pos in _def_cells && _side == _def_side) then {
			VOX_DEFEND_SUPPORTS pushback _x;
		};
	}forEach VOX_GRID;
	hint str VOX_ATTACK_SUPPORTS;
};

VOX_FNC_DRAWOBJECTIVES = {
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
	
	private _center = [((_atk_pos select 0) + (_def_pos select 0)) / 2, ((_atk_pos select 1) + (_def_pos select 1)) / 2];
	private _distance = _atk_pos distance _def_pos;
	private _locations = nearestLocations [_center, [], _distance];
	
	{
		private _pos = position _x;
		private _size = size _x;
		if ((_size select 1) > 50 && surfaceIsWater _pos == false) then {
			private _marker1 = createMarker [format ["REC_%1", _pos], _pos];
			_marker1 setMarkerShape "ELLIPSE";
			_marker1 setMarkerBrush "Cross";
			_marker1 setMarkerSize [(_size select 0), (_size select 0)];
			_marker1 setMarkerAlpha 0.33;
			
			private _marker2 = createMarker [format ["OBJ_%1", _pos], _pos];
			_marker2 setMarkerShape "ELLIPSE";
			_marker2 setMarkerBrush "Cross";
			_marker2 setMarkerSize [(_size select 1), (_size select 1)];
			_marker2 setMarkerAlpha 0.33;
		};
	}forEach _locations;
};

VOX_FNC_CLOSEMAP = {
	openMap false;
	(findDisplay 1400) closedisplay 1;
};