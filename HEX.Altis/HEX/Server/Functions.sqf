/// start campaign on server
HEX_SRV_FNC_CAMPAIGN = {
	/// set new commander
	remoteExec ["HEX_LOC_FNC_COMMANDER", 0, false];
	
	/// Generate default/custom new campaign or load saved campaign
	if (_this == "DEFAULT") then {call compile preprocessFile "HEX\Server\DefaultCampaign.sqf"};
	if (_this == "CUSTOM") then {call compile preprocessFile "HEX\Server\CustomCampaign.sqf"};
	if (_this == "SAVED") then {call compile preprocessFile "HEX\Server\SavedCampaign.sqf"};
};

/// Create grid overlay on server
HEX_SRV_FNC_GRID = {
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

/// Moves one hex into another on server
HEX_SRV_FNC_MOVE = {
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
	private _zoco = 0 spawn HEX_SRV_FNC_ZOCO; 
	waitUntil {scriptDone _zoco};

	/// Update counters globally
	remoteExec ["HEX_LOC_FNC_COTE", 0, false];
};

/// Updates grid zone of control of counters on server and intensity globally
HEX_SRV_FNC_ZOCO = {
	private _intensity = 0;
	
	{
		private _hex = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _sid = _x select 4;
	
		private _near = _hex call HEX_GLO_FNC_NEAR;
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

/// End turn on server
HEX_SRV_FNC_TURN = {
	call compile preprocessFile "HEX\Server\Turn.sqf";
};

/// Start tactical on server
HEX_SRV_FNC_TACTICAL = {
	call compile preprocessFile "HEX\Server\Tactical.sqf"
};

/// Get cfgGroups configs of groups
HEX_SRV_FNC_GROUPS = {
	private _factions = _this select 0;
	private _icons = _this select 1;
	
	/// blacklist diver squads
	private _blacklist = ["Diver Team", "Diver Team (Boat)", "Diver Team (SDV)", "Mechanized Air-defense Squad", "Mechanized Support Squad", "Motorized Air-defense Team", "Motorized GMG Team", "Motorized HMG Team", "Motorized Mortar Team", "AWC Air-Defense Platoon", "AWC Platoon (Combined)", "AWC Air-Defense Section", "AWC Recon Section"];
	
	/// Go throught entire cfgGroups and find groups matching icons and faction
	private _groups = [];
	{
		private _facs = "true" configClasses _x;
		{
			private _cats = "true" configClasses _x;
			{
				private _grps = "true" configClasses _x;
				
				/// move "Special Forces" to recon
				private _CATname = getText (_x >> "name");
				private _INFnoskip = true;
				private _RECnoskip = false;
				private _SUPnoskip = true;
				if (_CATname == "Special Forces" && (_icons select 0 == "\A3\ui_f\data\map\markers\nato\b_inf.paa")) then {_INFnoskip = false};	
				if (_CATname == "Special Forces" && (_icons select 0 == "\A3\ui_f\data\map\markers\nato\b_recon.paa")) then {_RECnoskip = true};
				if (_CATname == "Support Infantry") then {_SUPnoskip = false};
				if (_CATname == "Guard Infantry") then {_SUPnoskip = false};					
				{
					private _fac = getText (_x >> "faction");
					private _ico = getText (_x >> "icon");
					private _GRPname = getText (_x >> "name");
					
					private _ARMnoskip = false;
					if (_GRPname == "Tank Destroyer Section" && _icons select 0 == "\A3\ui_f\data\map\markers\nato\b_armor.paa") then {_ARMnoskip = true};
					if (_GRPname == "Tank Destroyer Section (UP)" && _icons select 0 == "\A3\ui_f\data\map\markers\nato\b_armor.paa") then {_ARMnoskip = true};
					
					if (_fac in _factions && (_ico in _icons or _RECnoskip or _ARMnoskip) && _INFnoskip && _SUPnoskip && (_GRPname in _blacklist == false)) then {
						_groups append [_x];
					};
				}forEach _grps;
			}forEach _cats;
		}forEach _facs;
	}forEach [(configFile >> "CfgGroups" >> "West"), (configFile >> "CfgGroups" >> "East"), (configFile >> "CfgGroups" >> "Indep")];
	
	_groups
};

/// get cfgVehicles
HEX_SRV_FNC_VEHICLES = {
	private _factions = _this select 0;
	private _type = _this select 1;
	private _men = [];
	private _configs = [];
	
	private _typ = 0;
	if (_type in ["b_art", "o_art"]) then {_typ = 1};
	if (_type in ["b_support", "o_support"]) then {_typ = 2};
	if (_type in ["b_antiair", "o_antiair"]) then {_typ = 3};
	if (_type in ["b_air", "o_air"]) then {_typ = 4};
	if (_type in ["b_plane", "o_plane"]) then {_typ = 5};
	
	/// Scan throught cfgVehicles
	{
		private _veh = _x;
		private _fac = getText (_x >> "faction");
		private _sco = getNumber (_x >> "scope");
		private _cls = getText (_x >> "vehicleClass");
		private _drv = getNumber (_x >> "hasDriver");
		private _cfg = configName _x;

		if (_sco == 2 && _fac in _factions && _cls != "Autonomous" && _drv == 1) then {
			private _amo = getNumber (_veh >> "transportAmmo");
			private _plo = getNumber (_veh >> "transportFuel");
			private _rep = getNumber (_veh >> "transportRepair");
			private _sup = _amo + _plo + _rep;
			private _art = getNumber (_veh >> "artilleryScanner");
			private _sim = toLower getText (_veh >> "simulation");
			private _cat = getText (_veh >> "editorSubcategory");
			private _dsp = getText (_veh >> "displayName");

			if (_sim == "soldier") then {_men pushback _cfg};
			if (_typ == 0 && _dsp == "Officer") then {_configs pushback _cfg};	
			if (_typ == 1 && _art > 0) then {_configs pushback _cfg};			
			if (_typ == 2 && _sup > 0) then {_configs pushback _cfg};
			if (_typ == 3 && _cat == "EdSubcat_AAs") then {_configs pushback _cfg};
			if (_typ == 4 && _sim == "helicopterrtd" or _sim == "helicopterx") then {_configs pushback _cfg};
			if (_typ == 5 && _sim == "airplanex" or _sim == "airplane") then {_configs pushback _cfg};
		};
	} forEach ("true" configClasses (configFile >> "CfgVehicles"));

	/// not configs, pick random man
	if (count _configs == 0) then {_configs = [_men select floor random count _men]};

	/// return array
	_configs
};