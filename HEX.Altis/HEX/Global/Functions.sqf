/// start loading screen on local
HEX_FNC_LOAD = {
	call compile preprocessFile "HEX\Local\Loading.sqf";
};

/// start campaign on server
HEX_FNC_CAMPAIGN = {
	/// set new commander
	remoteExec ["HEX_FNC_COMMANDER", 0, false];
	
	/// Generate default/custom new campaign or load saved campaign
	if (_this == "DEFAULT") then {call compile preprocessFile "HEX\Server\DefaultCampaign.sqf"};
	if (_this == "CUSTOM") then {call compile preprocessFile "HEX\Server\CustomCampaign.sqf"};
	if (_this == "SAVED") then {call compile preprocessFile "HEX\Server\SavedCampaign.sqf"};
};

/// update locally if player has been chosen as commander
HEX_FNC_COMMANDER = {
	if (name player == ADM_WEST_COMMANDER) then {
		LOC_COMMANDER = true;

		systemChat "You have been chosen as BLUFOR Commander!";
		systemChat "In strategic phase: Move units on hex board by clicking them.";
		systemChat "In tactical battle: Open High Command module with ctrl+space.";
		systemChat "Good luck commander!";
	};

	if (name player == ADM_EAST_COMMANDER) then {
		LOC_COMMANDER = true;

		systemChat "You have been chosen as OPFOR Commander!";
		systemChat "In strategic phase: Move units on hex board by clicking them.";
		systemChat "In tactical battle: Open High Command module with ctrl+space.";
		systemChat "Good luck commander!";
	};
};

/// Create grid overlay on server
HEX_FNC_GRID = {
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = _x select 2;
		private _sid = _x select 4;
		private _name = format ["HEX_%1_%2", _row, _col];
		private _marker = createMarker [_name, _pos];
		_marker setMarkerShape "HEXAGON";
		_marker setMarkerBrush "Border";
		_marker setMarkerDir 90;
		_marker setMarkerSize [HEX_SIZE, HEX_SIZE];
	}forEach HEX_GRID;
};

/// start strategic on local
HEX_FNC_STRATEGIC = {
	call compile preprocessFile "HEX\Local\Strategic.sqf";
	call compile preprocessFile "HEX\Local\Ambient.sqf";
};

/// Find hexes in grid next to hex, server/local
HEX_FNC_NEAR = {
	private _hex = _this;
	private _row = _hex select 0;
	private _col = _hex select 1;
	
	private _dirs = [[0,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0]];
	if (_col mod 2 == 0) then {_dirs = [[0,-1],[1,-1],[1,0],[0,1],[-1,0],[-1,-1]]};
	private _near = [];
	
	{
		private _rowNew = _row + (_x select 1);
		private _colNew = _col + (_x select 0);
		
		private _found = HEX_GRID select {(_x select 0) == _rowNew && (_x select 1) == _colNew};
		if (count _found > 0) then {_near pushBack (_found select 0)};
	}forEach _dirs;
	
	_near
};

/// Find hexes with a fill, server/local
HEX_FNC_FILL = {
	private _hex = _this select 0;
	private _max = _this select 1;
	
	private _open = [_hex];
	private _seen = [_hex];
	
	while {count _open > 0 && count _seen < _max} do {
		private _hex2 = _open deleteAt 0;
		{
			private _hex3 = _x;
			if ((_hex3 in HEX_GRID) && !(_hex3 in _seen)) then {
				_seen pushBack _hex3;
				_open pushBack _hex3;
			};
		}forEach (_hex2 call HEX_FNC_NEAR);
	};
	
	_seen
};

/// Moves one hex into another on server
HEX_FNC_MOVE = {
	private _org = _this select 0;
	private _end = _this select 1;
	
	/// Find origin index
	private _indexORG = HEX_GRID find _org;
	/// Find destination index
	private _indexEND = HEX_GRID find _end;	
	
	/// Replace origin with "hd_dot", civilian, 0
	_newORG = [_org select 0, _org select 1, _org select 2, "hd_dot", civilian, 0, 1];
	HEX_GRID set [_indexORG, _newORG];
	
	/// Replace destination with origin
	_newEND = [_end select 0, _end select 1, _end select 2, _org select 3, _org select 4, (_org select 5) - 1, _org select 6];
	HEX_GRID set [_indexEND, _newEND];
	
	/// Update grid information globally
	publicVariable "HEX_GRID";
	
	/// Update zone of control globally
	private _zoco = 0 spawn HEX_FNC_ZOCO; 
	waitUntil {scriptDone _zoco};

	/// Update counters globally
	remoteExec ["HEX_FNC_COTE", 0, false];
};

/// Clears markers and orders locally
HEX_FNC_CLIC = {
	/// Remove order markers
	{
		private _hex = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = _x select 2;
		private _name = format ["ACT_%1_%2", _row, _col];		
		deleteMarkerLocal _name;
	}forEach LOC_ORDERS;
	
	deleteMarkerLocal "HEX_SELECT";
	
	/// Reset local variables
	if (isNil "LOC_ORDERS" == false) then {
		LOC_ORDERS = [];
	};
	
	if (isNil "LOC_SELECT" == false) then {
		LOC_SELECT = [];
	};
	
	if (isNil "LOC_MODE" == false) then {
		LOC_MODE = "SELECT";
	};	
	
	/// Stop radio noise;
	if (isNil "LOC_SOUND" == false) then {
		stopSound LOC_SOUND;
	};
};

/// Updates counter markers on client
HEX_FNC_COTE = {
	{
		private _hex = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = _x select 2;
		private _cfg = _x select 3;
		private _sid = _x select 4;
		private _act = _x select 5;
		private _org = _x select 6;

		private _name = format ["LOC_%1_%2", _row, _col];
		deleteMarkerLocal _name;

		private _draw = false;
		if (_sid == side player) then {_draw = true};
	
		private _near = _hex call HEX_FNC_NEAR;
		{
			private _sid2 = _x select 4;
			if (_sid2 == side player) then {
				_draw = true;
			};
		}forEach _near;
	
		if (_draw == true && _cfg != "hd_dot") then {
			private _marker = createMarkerLocal [_name, _pos];
			_marker setMarkerTypeLocal _cfg;
			if (_org == 2) then {_marker setMarkerAlphaLocal 0.5};
			if (_sid == side player && _act > 0) then {
				if (_act == 1) then {_marker setMarkerTextLocal ("I")};
				if (_act == 2) then {_marker setMarkerTextLocal ("II")};
				if (_act == 3) then {_marker setMarkerTextLocal ("III")};
			};
		};
	}forEach HEX_GRID;
};

/// Updates grid zone of control of counters on server and intensity globally
HEX_FNC_ZOCO = {
	private _intensity = 0;
	
	{
		private _hex = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _sid = _x select 4;
	
		private _near = _hex call HEX_FNC_NEAR;
		private _sides = [_sid];
		{
			_sides pushback (_x select 4);
		}forEach _near;
	
		private _color = "colorBLACK";
		if (west in _sides) then {_color = "colorBLUFOR"};
		if (east in _sides) then {_color = "colorOPFOR"};
		if (west in _sides && east in _sides) then {_color = "ColorCIV"; _Intensity = _Intensity + 1};
	
		private _marker = format ["HEX_%1_%2", _row, _col];
		_marker setMarkerColor _color;
		if (_color != "ColorBLACK") then {
			_marker setMarkerAlpha 0.5;
			_marker setMarkerBrush "SolidBorder";
		} else {
			_marker setMarkerBrush "Border";
			_marker setMarkerAlpha 1;
		};
	}forEach HEX_GRID;
	
	private _ambience = 0;
	if (_intensity > 3) then {_ambience = 1};
	if (_intensity > 6) then {_ambience = 2};
	HEX_INTENSITY = _ambience;
	publicVariable "HEX_INTENSITY";
};

/// Start tactical on server
HEX_FNC_TACTICAL = {
	call compile preprocessFile "HEX\Server\Tactical.sqf"
};

/// End turn on server
HEX_FNC_TURN = {
	call compile preprocessFile "HEX\Server\Turn.sqf";
};

/// Open briefing menu
HEX_FNC_BRIEFING = {
	call compile preprocessFile "HEX\Local\Briefing.sqf";
};

/// Close tactical briefing for clients
HEX_FNC_CLOSEBRIEFING = {
	(findDisplay 1400) closedisplay 1;
};

/// Open slotting menu
HEX_FNC_SLOTTING = {
	call compile preprocessFile "HEX\Local\Slotting.sqf";
};

/// gets all HEX groups of specific side
HEX_FNC_GROUPS = {
	private _side = _this;
	private _groups = allGroups select {
		side _x == _side && _x isNil "HEX_ICON" == false;
	};
	_groups
};