	for "_i" from 1 to _amount do {
		private _select = _groups selectRandomWeighted _weights;
		private _config = "true" configClasses _select;
		if (_armor) then {_config = [_config select 0]};
	
		private _group = createGroup _side;
		_group setVariable ["HEX_ICON", _type, true];
		private _pos2 = [_pos, 0, HEX_SIZE / 2, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
		private _crews = [];
		
		private _infantry = [];
		private _vehicles = [];
		
		{
			private _vehCfg = getText (_x >> "vehicle");
			private _rank = getText (_x >> "rank");
			private _cfg = (configFile >> "CfgVehicles" >> _vehCfg);
			private _isMan = getNumber (_cfg >> "isMan");
			
			if (_isMan == 1) then {
				_infantry pushback [_rank, _vehCfg];
			} else {
				_vehicles pushback [_rank, _vehCfg];				
			};
		}forEach _config;
		
		
		_infantry deleteRange [8, 16];
		
		{
			private _rnkI = _x select 0;
			private _vehI = _x select 1;
			private _unit = _vehI createUnit [_pos2, _group, "", 1, _rnkI];	
		}forEach _infantry;
		
		{
			private _rnkV = _x select 0;
			private _vehV = _x select 1;
			private _pos3 = [_pos2, 0, 50, 5, 0, 0, 0, [], _pos2] call BIS_fnc_findSafePos;
			private _spawned = [_pos3, 0, _vehV, _group] call BIS_fnc_spawnVehicle;
			private _crew = _spawned select 1;
			{_x setSkill 1}forEach _crew;
			(_crew select 0) setRank "PRIVATE";
			if (count _crew > 0) then {(_crew select 1) setRank "CORPORAL"};
			if (count _crew > 1) then {(_crew select 2) setRank "SERGEANT"};
		}forEach _vehicles;
		
		if (count _infantry > 0) then {
				_group selectLeader ((units _group) select 0);
			} else {
				private _count = count units _group;
				_group selectLeader ((units _group) select (_count - 1));
		};		
		
		if (_side == west && HEX_SINGLEPLAYER) then {{addSwitchableUnit _x}forEach (units _group)};
		/// TODO: PERFORMANCE TESTING
		_group addWaypoint [_pos, HEX_SIZE / 2];
	};
	
/// Create subgrid overlay on server
HEX_SRV_FNC_SUBGRID = {
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _idx = _x select 2;
		private _pos = _x select 3;
		private _name = format ["HEX_%1_%2_%3", _row, _col, _idx];
		private _marker = createMarker [_name, _pos];
		_marker setMarkerShape "HEXAGON";
		_marker setMarkerBrush "Border";
		_marker setMarkerDir 90;
		_marker setMarkerSize [HEX_SIZE / 4, HEX_SIZE / 4];
	}forEach HEX_SUBGRID;
};

/// create sub-grid
{
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _marker = format ["HEX_%1_%2", _row, _col];
	private _types = ["NameCityCapital","NameCity","NameVillage","NameLocal","Hill"];
	private _locs = nearestLocations [_pos, _types, HEX_SIZE];
	private _posLocs = [];
	
	{
		private _posLoc = position _x;
		if (_posLoc inArea _marker) then {
			_posLocs pushback [_posLoc select 0, _posLoc select 1];
		}
	}forEach _locs;
	
	{
		private _pos2 = _x;
		private _idx = _forEachIndex;
		HEX_SUBGRID pushback [_row, _col, _idx, _pos2, "hd_dot", civilian, 0, 0, "colorBLACK"];
	}forEach _posLocs;
}forEach HEX_GRID;	
	
	
/// performacne testing

private _testWest = west call HEX_LOC_FNC_GROUPS;
{
	private _obj = HEX_OBJECTIVES_NEUT select floor random count HEX_OBJECTIVES_NEUT;
	private _pos = _obj select 2;
	private _wp = _x addWaypoint [_pos, HEX_SIZE];
}forEach _testWest;

private _testEast = east call HEX_LOC_FNC_GROUPS;
{
	private _obj = HEX_OBJECTIVES_NEUT select floor random count HEX_OBJECTIVES_NEUT;
	private _pos = _obj select 2;
	private _wp = _x addWaypoint [_pos, HEX_SIZE];
}forEach _testEast;

{
	private _unit = _x;
	if (side _unit == west && HEX_SINGLEPLAYER) then {addSwitchableUnit _unit};
}forEach AllUnits;