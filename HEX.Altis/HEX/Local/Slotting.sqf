waitUntil {!isNil "HEX_PHASE"};
LOC_SIDE = side player;
LOC_SLOTTING = true;
LOC_GROUP = group player;
LOC_UNITS = units player;
LOC_GROUPS = [];
LOC_UNIT = player;

/// Close briefing map
(findDisplay 1400) closedisplay 1;

//// Minimap? - selecting from list moves map to the units position
/// Confirm if unit can actually be selected!
/// confirm button changes color when can be switched to?

/// update units list
LOC_FNC_UNITS = {
	private _group = LOC_GROUPS select _this;
	private _menu = findDisplay 1500;
	private _unitsList = _menu displayCtrl 1503;
	
	private _color = [0, 0.3, 0.6, 0.5];
	if (LOC_SIDE == east) then {
		_color = [0.5, 0, 0, 0.5];
	};	
	
	_unitsList lbSetCurSel 0;
	lbClear _unitsList;
	
	LOC_UNITS = units _group;
	
	{
		private _unit = _x;
		private _cfg = configfile >> "CfgVehicles" >> typeOf _unit;
		private _name = getText (_cfg >> "displayName");
		private _veh = vehicle _unit;
		
		if (_unit != _veh) then {
			private _cfgVeh = configfile >> "CfgVehicles" >> typeOf _veh;
			private _nameVeh = getText (_cfgVeh >> "displayName");
			if (driver _veh == _unit) then {_name = _nameVeh + " Driver"};
			if (commander _veh == _unit) then {_name = _nameVeh + " Commander"};
			if (gunner _veh == _unit) then {_name = _nameVeh + " Gunner"};
		};
		
		if (isPlayer _x) then {_name = "(PLAYER) " + _name};
		if (leader _x == _x) then {_name = "(LEADER) " + _name};
		private _added = _unitsList lbAdd _name;		
	}forEach LOC_UNITS;
};

/// Select unit in list
LOC_FNC_UNIT = {
	LOC_UNIT = LOC_UNITS select _this;
	private _menu = findDisplay 1500;
	private _minimap = _menu displayCtrl 1505;	

	/// move map to unit's position	
	_minimap ctrlMapAnimAdd [0, 0.1, LOC_UNIT];
	ctrlMapAnimCommit _minimap;
};

/// Switch player unit
LOC_FNC_SWITCH = {
	private _newUnit = LOC_UNIT;
	private _possible = true;
	
	if (isPlayer _newUnit) then {_possible == false};
	if (alive _newUnit == false) then {_possible == false};
	
	if (_possible) then {
		selectPlayer LOC_UNIT;
		LOC_SLOTTING = false;
		(findDisplay 1500) closedisplay 1;
	};
	
	/// if check fails re-open the menu
	if (_possible == false) then {
		(findDisplay 1500) closedisplay 1;	
	};

};


/// Open slotting menu if player is ghost unit
[] spawn {
	while {HEX_PHASE == "TACTICAL"} do {
		
		if (isNull findDisplay 1500 && LOC_SLOTTING) then {
			createDialog "HEX_SLOTTING";
			private _menu = findDisplay 1500;
			private _text = _menu displayCtrl 1501;
			private _groupsList = _menu displayCtrl 1502;
			private _unitsList = _menu displayCtrl 1503;
			private _button = _menu displayCtrl 1504;
			private _minimap = _menu displayCtrl 1505;
			private _color = [0, 0.3, 0.6, 0.5];
			if (LOC_SIDE == east) then {
				_color = [0.5, 0, 0, 0.5];
			};
			
			_text ctrlSetBackgroundColor _color;
			LOC_GROUPS = LOC_SIDE call HEX_FNC_GROUPS;
			
			{
				private _type = _x getVariable "HEX_ICON";
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _type + ".paa";
				private _name = groupId _x;
				private _added = _groupsList lbAdd _name;
				_groupsList lbSetPicture [_added, _icon];
				_groupsList lbSetPictureColor [_added, _color];
			}ForEach LOC_GROUPS;
		};
		
		sleep 1;
	};
};