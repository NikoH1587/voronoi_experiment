/// Gee I sure do hope nobody picks "AI Commander" as their profileName! ;3
HEX_ADM_FNC_GETPLAYERS = {
	HEX_ADM_WEST_PLAYERS = ["AI Commander"];
	HEX_ADM_EAST_PLAYERS = ["AI Commander"];

	private _allPlayers = call BIS_fnc_listPlayers;
	_westPlayers = _allPlayers select {side _x == west};
	_eastPlayers = _allPlayers select {side _x == east};
	{HEX_ADM_WEST_PLAYERS pushback (name _x)}forEach _westPlayers;
	{HEX_ADM_EAST_PLAYERS pushback (name _x)}forEach _eastPlayers;
};

HEX_ADM_FNC_CONTINUE = {
	if (HEX_LOC_ADMIN) then {
		if (HEX_ADM_SAVE) then {
			/// load save from client onto server
		} else {
			/// start new default campaign on server
			"DEFAULT" remoteExec ["HEX_SRV_FNC_CAMPAIGN", 2, false];
		};
	};
};

HEX_ADM_FNC_NEWSAVE = {
	if (HEX_LOC_ADMIN) then {
		/// Set phase locally for admin
		HEX_PHASE == "CUSTOM";
		/// Open custom menu locally for admin
		call compile preprocessFile "HEX\Admin\Custom.sqf"
	};
};

HEX_ADM_FNC_CMDW = {
	HEX_ADM_WEST_COMMANDER = HEX_ADM_WEST_PLAYERS select _this;
	publicVariable "ADM_WEST_COMMANDER";
};

HEX_ADM_FNC_CMDE = {
	HEX_ADM_EAST_COMMANDER = HEX_ADM_EAST_PLAYERS select _this;
	publicVariable "ADM_EAST_COMMANDER";
};

/// Start tactical combat
HEX_ADM_FNC_TACTICAL = {
	if (HEX_LOC_ADMIN) then {
	
    [] remoteExec ["HEX_SRV_FNC_TACTICAL", 2, false]
	};
};

HEX_ADM_FNC_FACTIONS = {
	private _side = _this;
	private _factions = [];
	private _allFacs = (configFile >> "CfgFactionClasses") call BIS_fnc_getCfgSubClasses;
	{
		private _cfg = (configFile >> "CfgFactionClasses" >> _x);
		private _cfgName = _x;
		private _side2 = getNumber (_cfg >> "side");
		if (_side == _side2 or _side2 == 2) then {
			private _name = getText (_cfg >> "displayName");
			private _icon = getText (_cfg >> "icon");
			private _name = _name + " - " + _cfgName;
			
			/// get if has infantry
			private _infantry = (_cfgName call HEX_ADM_FNC_GROUPS) select 0;
			if (_infantry) then {
				_factions pushback [_cfgName, _name, _icon];
			};
		};
	}forEach _allFacs;

	_factions
};

HEX_ADM_FNC_VEHICLES = {
	private _faction = _this;

	private _support = false;
	private _arty = false;
	private _antiair = false;
	private _helo = false;
	private _plane = false;
	
	/// Scan throught cfgVehicles
	{
		private _veh = _x;
		private _fac = getText (_x >> "faction");
		private _sco = getNumber (_x >> "scope");
		private _cls = getText (_x >> "vehicleClass");
		if (_sco == 2 && _fac == _faction && _cls != "Autonomous") then {
			private _amo = getNumber (_veh >> "transportAmmo");
			private _plo = getNumber (_veh >> "transportFuel");
			private _rep = getNumber (_veh >> "transportRepair");
			private _sup = _amo + _plo + _rep;
			private _art = getNumber (_veh >> "artilleryScanner");
			private _sim = toLower getText (_veh >> "simulation");
			private _cat = getText (_veh >> "editorSubcategory");
			
			if (_sup > 0) then {_support = true};
			if (_art > 0) then {_arty = true};
			if (_cat == "EdSubcat_AAs") then {_antiair = true};
			if (_sim == "helicopterrtd" or _sim == "helicopterx") then {_helo = true};
			if (_sim == "airplanex" or _sim == "airplane") then {_plane = true};
		};
	} forEach ("true" configClasses (configFile >> "CfgVehicles"));

	/// return array
	[_support, _arty, _antiair, _helo, _plane]
};

HEX_ADM_FNC_GROUPS = {
	private _faction = _this;
	private _groups = [];
	private _inf = false;
	private _rec = false;
	private _mot = false;
	private _mec = false;
	private _arm = false;

	private _infIco = ["\A3\ui_f\data\map\markers\nato\b_inf.paa", "\A3\ui_f\data\map\markers\nato\n_inf.paa", "\A3\ui_f\data\map\markers\nato\o_inf.paa"];	
	private _recIco = ["\A3\ui_f\data\map\markers\nato\b_recon.paa", "\A3\ui_f\data\map\markers\nato\n_recon.paa", "\A3\ui_f\data\map\markers\nato\o_recon.paa"];
	private _motIco = ["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\n_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa"];
	private _mecIco = ["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\n_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa"];
	private _armIco = ["\A3\ui_f\data\map\markers\nato\b_armor.paa", "\A3\ui_f\data\map\markers\nato\n_armor.paa", "\A3\ui_f\data\map\markers\nato\o_armor.paa"];
	
	/// Go throught entire cfgGroups and find groups matching icons and faction
	{
		private _facs = "true" configClasses _x;
		{
			private _cats = "true" configClasses _x;
			{
				private _grps = "true" configClasses _x;
				{
					private _fac = getText (_x >> "faction");
					private _ico = getText (_x >> "icon");
					
					if (_fac == _faction) then {
						if (_ico in _infIco) then {_inf = true};
						if (_ico in _recIco) then {_rec = true};
						if (_ico in _motIco) then {_mot = true};
						if (_ico in _mecIco) then {_mec = true};
						if (_ico in _armIco) then {_arm = true};
					};
				}forEach _grps;
			}forEach _cats;
		}forEach _facs;
	}forEach [(configFile >> "CfgGroups" >> "West"), (configFile >> "CfgGroups" >> "East"), (configFile >> "CfgGroups" >> "Indep")];
	
	/// return array
	[_inf, _rec, _mot, _mec, _arm]
};

HEX_ADM_FNC_FACWEST = {
	HEX_WEST = HEX_ADM_ALLWEST select _this;

	private _vehicles = HEX_WEST call HEX_ADM_FNC_VEHICLES;	
	private _groups = HEX_WEST call HEX_ADM_FNC_GROUPS;
	
	/// clear both lists and config
	/// add to faction list all options;
	private _menu = findDisplay 1200;
	private _listWest = _menu displayCtrl 1203;
	private _selWest = _menu displayCtrl 1204;	
	
	lbClear _listWest;
	HEX_ADM_CFG_WEST = [];
	lbClear _selWest;
	HEX_CFG_WEST = ["b_hq"];
	
	if (_vehicles select 0) then {HEX_ADM_CFG_WEST pushBack ["Support", "b_support"]};
	if (_vehicles select 1) then {HEX_ADM_CFG_WEST pushBack ["Artillery", "b_art"]};
	if (_vehicles select 2) then {HEX_ADM_CFG_WEST pushBack ["Anti-Air", "b_antiair"]};
	if (_vehicles select 3) then {HEX_ADM_CFG_WEST pushBack ["Plane", "b_plane"]};
	if (_vehicles select 4) then {HEX_ADM_CFG_WEST pushBack ["Helicopter", "b_air"]};
	
	if (_groups select 0) then {HEX_ADM_CFG_WEST pushBack ["Infantry", "b_inf"]};
	if (_groups select 1) then {HEX_ADM_CFG_WEST pushBack ["Recon", "b_recon"]};
	if (_groups select 2) then {HEX_ADM_CFG_WEST pushBack ["Motorized", "b_motor_inf"]};
	if (_groups select 3) then {HEX_ADM_CFG_WEST pushBack ["Mechanized", "b_mech_inf"]};
	if (_groups select 4) then {HEX_ADM_CFG_WEST pushBack ["Armor", "b_armor"]};
	
	{
		private _added = _listWest lbAdd (_x select 0);
		private _icon = "\A3\ui_f\data\map\markers\nato\" + (_x select 1) + ".paa";
		_listWest lbSetPicture [_added, _icon];
		_listWest lbSetPictureColor [_added, [0, 0.3, 0.6, 1]];
	}forEach HEX_ADM_CFG_WEST;
	
	/// add HQ to selected list
	private _addHQ = _selWest lbAdd "Headquarters";
	_selWest lbSetPicture [_addHQ, "\A3\ui_f\data\map\markers\nato\b_hq.paa"];
	_selWest lbSetPictureColor [_addHQ, [0, 0.3, 0.6, 1]];
};

HEX_ADM_FNC_FACEAST = {
	HEX_EAST = HEX_ADM_ALLEAST select _this;

	private _vehicles = HEX_EAST call HEX_ADM_FNC_VEHICLES;	
	private _groups = HEX_EAST call HEX_ADM_FNC_GROUPS;
	
	/// clear both lists and config
	/// add to faction list all options;
	private _menu = findDisplay 1200;
	private _selEast = _menu displayCtrl 1205;
	private _listEast = _menu displayCtrl 1206;	
	
	lbClear _listEast;
	HEX_ADM_CFG_EAST = [];
	lbClear _selEast;
	HEX_CFG_EAST = ["o_hq"];
	
	if (_vehicles select 0) then {HEX_ADM_CFG_EAST pushBack ["Support", "o_support"]};
	if (_vehicles select 1) then {HEX_ADM_CFG_EAST pushBack ["Artillery", "o_art"]};
	if (_vehicles select 2) then {HEX_ADM_CFG_EAST pushBack ["Anti-Air", "o_antiair"]};
	if (_vehicles select 3) then {HEX_ADM_CFG_EAST pushBack ["Plane", "o_plane"]};
	if (_vehicles select 4) then {HEX_ADM_CFG_EAST pushBack ["Helicopter", "o_air"]};
	
	if (_groups select 0) then {HEX_ADM_CFG_EAST pushBack ["Infantry", "o_inf"]};
	if (_groups select 1) then {HEX_ADM_CFG_EAST pushBack ["Recon", "o_recon"]};
	if (_groups select 2) then {HEX_ADM_CFG_EAST pushBack ["Motorized", "o_motor_inf"]};
	if (_groups select 3) then {HEX_ADM_CFG_EAST pushBack ["Mechanized", "o_mech_inf"]};
	if (_groups select 4) then {HEX_ADM_CFG_EAST pushBack ["Armor", "o_armor"]};
	
	{
		private _added = _listEast lbAdd (_x select 0);
		private _icon = "\A3\ui_f\data\map\markers\nato\" + (_x select 1) + ".paa";
		_listEast lbSetPicture [_added, _icon];
		_listEast lbSetPictureColor [_added, [0.5, 0, 0, 1]];
	}forEach HEX_ADM_CFG_EAST;
	
	/// add HQ to selected list
	private _addHQ = _selEast lbAdd "Headquarters";
	_selEast lbSetPicture [_addHQ, "\A3\ui_f\data\map\markers\nato\o_hq.paa"];
	_selEast lbSetPictureColor [_addHQ, [0.5, 0, 0, 1]];
};

/// adds clicked counter from list to selections
HEX_ADM_FNC_ADDWEST = {
	if (_this != -1) then {
		private _selection = HEX_ADM_CFG_WEST select _this;
		private _name = _selection select 0;
		private _icon = _selection select 1;

		private _menu = findDisplay 1200;
		private _selWest = _menu displayCtrl 1204;
		private _listWest = _menu displayCtrl 1203;
	
		HEX_CFG_WEST pushback _icon;	
	
		private _added = _selWest lbAdd _name;
		private _icon = "\A3\ui_f\data\map\markers\nato\" + _icon + ".paa";
		_selWest lbSetPicture [_added, _icon];
		_selWest lbSetPictureColor [_added, [0, 0.3, 0.6, 1]];
		
		_listWest lbSetCurSel -1;
	}
};

/// Remove clicked counter
HEX_ADM_FNC_DELETEWEST = {
	
	private _selection = _this;
	/// Ignore HQ deletion and -1
	if (_selection > 0) then {
		
		private _menu = findDisplay 1200;
		private _selWest = _menu displayCtrl 1204;	
		_selWest lbDelete _selection;
		
		HEX_CFG_WEST deleteAt _selection;
		_selWest lbSetCurSel -1;
	};
};

HEX_ADM_FNC_ADDEAST = {
	if (_this != -1) then {
		private _selection = HEX_ADM_CFG_EAST select _this;
		private _name = _selection select 0;
		private _icon = _selection select 1;

		private _menu = findDisplay 1200;
		private _selEast = _menu displayCtrl 1205;
		private _listEast = _menu displayCtrl 1206;	
	
		HEX_CFG_EAST pushback _icon;	
	
		private _added = _selEast lbAdd _name;
		private _icon = "\A3\ui_f\data\map\markers\nato\" + _icon + ".paa";
		_selEast lbSetPicture [_added, _icon];
		_selEast lbSetPictureColor [_added, [0.5, 0, 0, 1]];
		
		_listEast lbSetCurSel -1;
	}
};

HEX_ADM_FNC_DELETEEAST = {
	
	private _selection = _this;
	/// Ignore HQ deletion and -1
	if (_selection > 0) then {
		
		private _menu = findDisplay 1200;
		private _selEast = _menu displayCtrl 1205;
		_selEast lbDelete _selection;
		
		HEX_CFG_EAST deleteAt _selection;
		_selEast lbSetCurSel -1;
	};
};

HEX_ADM_FNC_START = {
	(findDisplay 1200) closedisplay 1;
	HEX_PHASE = "STRATEGIC";
	publicVariable "HEX_WEST";
	publicVariable "HEX_EAST";
	publicVariable "HEX_CFG_WEST";
	publicVariable "HEX_CFG_EAST";
	
	publicVariable "HEX_FULLMAP";
	publicVariable "HEX_SIZE";
	publicVariable "HEX_TIME";
	publicVariable "HEX_TURN";
	publicVariable "HEX_PHASE";
	publicVariable "HEX_DAY";
	"CUSTOM" remoteExec ["HEX_SRV_FNC_CAMPAIGN", 2, false];
};

/// Start tactical combat
HEX_ADM_FNC_TACTICAL = {
	if (HEX_LOC_ADMIN) then {
	
    [] remoteExec ["HEX_SRV_FNC_TACTICAL", 2, false]
	};
};

/// updates export field every 1 sec? TODO
HEX_ADM_FNC_EXPORT = {};