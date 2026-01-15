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