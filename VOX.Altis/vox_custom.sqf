VOX_PHASE = "CUSTOM";

/// [_icon, _name, _config]
VOX_FACTIONS = [];

/// contains cfgGroups and CfgVehicles entires
VOX_CONFIG = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
/// ["b_inf","b_motor_inf"]
VOX_CFG_WEST = [];
VOX_CFG_EAST = [];

/// [_marker, _name]
VOX_FORMATIONS = [
	["b_inf", "Infantry"],
	["b_motor_inf", "Motorized"],
	["b_mech_inf", "Mechanized"],
	["b_armor", "Armor"],
	
	["b_recon", "Recon"],	
	["b_air", "Airmobile"],
	["b_naval", "Amphibious"],
	
	["b_support", "Support"],
	["b_art", "Artillery"],
	["b_plane", "Aircraft"],

	["o_inf", "Infantry"],
	["o_motor_inf", "Motorized"],
	["o_mech_inf", "Mechanized"],
	["o_armor", "Armor"],
	
	["o_recon", "Recon"],	
	["o_air", "Airmobile"],
	["o_naval", "Amphibious"],
	
	["o_support", "Support"],
	["o_art", "Artillery"],
	["o_plane", "Aircraft"]
];

/// get all factions
private _configs = (configFile >> "CfgFactionClasses") call BIS_fnc_getCfgSubClasses;

{
	private _cfg = (configFile >> "CfgFactionClasses" >> _x);
	private _name = getText (_cfg >> "displayName");
	private _icon = getText (_cfg >> "icon");
	private _side = getNumber (_cfg >> "side");
	
	private _mod = "";
	private _dlc = (configFile >> "CfgMods" >> configSourceMod _cfg);
	if (isClass _dlc) then {
		_mod = getText (_dlc >> "logo");
	};
	
	if (_side in [0, 1, 2]) then {
		VOX_FACTIONS pushBack [_icon, _name, _x, _mod];
	};
}forEach _configs;

VOX_FNC_FACTION = {
	private _faction = (VOX_FACTIONS select _this) select 2;
	private _facname = (VOX_FACTIONS select _this) select 1;
	
	/// [[_icon, _name, _cfgGroups], [_icon, _name, [_cfgVehicles]]]
	VOX_FACTION = [];
	
	/// get groups
	{
		private _facs = "true" configClasses _x;
		private _fac = configName _x;
		{
			private _cats = "true" configClasses _x;
			private _cat = configName _x;
			{
				private _grps = "true" configClasses _x;
				private _grp = configName _x;
				{
					private _unit = configName _x;
					private _fact = getText (_x >> "faction");
					private _icon = getText (_x >> "icon");
					private _name = getText (_x >> "name");
					
					private _mod = "";
					private _dlc = (configFile >> "CfgMods" >> configSourceMod _x);
					if (isClass _dlc) then {
						_mod = getText (_dlc >> "logo");
					};
					
					if (_fact == _faction) then {
						VOX_FACTION pushback [_icon, _facname + " " + _name, [_fac, _cat, _grp, _unit], _mod];
					};
				}forEach _grps;
			}forEach _cats;
		}forEach _facs;
	}forEach [(configFile >> "CfgGroups" >> "West"), (configFile >> "CfgGroups" >> "East"), (configFile >> "CfgGroups" >> "Indep")];
	
	/// get vehicles
	{
		private _scope = getNumber (_x >> "scope");
		private _side = getNumber (_x >> "side");
		if (_scope == 2 && _side in [0, 1, 2]) then {
			private _man = getNumber (_x >> "isMan");			
			private _fac = getText (_x >> "faction");
			private _pic = getText (_x >> "picture");
			private _txt = getText (_x >> "displayName");
			private _cfg = configName _x;

			private _mod = "";
			private _dlc = (configFile >> "CfgMods" >> configSourceMod _x);
			if (isClass _dlc) then {
				_mod = getText (_dlc >> "logo");
			};

			if (_man == 0 && _fac == _faction) then {
				VOX_FACTION pushback [_pic, _txt, [_cfg], _mod];
			};
		};
	} forEach ("true" configClasses (configFile >> "CfgVehicles"));	
	
	/// update config list
	private _menu = findDisplay 1200;
	private _cfg_list = _menu displayCtrl 1204;
	lbClear _cfg_list;
	
	{
		private _icon = _x select 0;
		private _name = _x select 1;
		private _cfg = _x select 2;
		private _mod = _x select 3;
				
		private _added = _cfg_list lbAdd _name;
		_cfg_list lbSetPicture [_added, _icon];
		_cfg_list lbSetPictureRight [_added, _mod];
				
	}forEach VOX_FACTION;
	_cfg_list lbSetCurSel -1;
};

VOX_FNC_FORMATION = {
	private _for_idx = _this;
	private _menu = findDisplay 1200;
	private _formation =  _menu displayCtrl 1201;
	private _for_list =  _menu displayCtrl 1202;	
	
	/// clear list
	lbClear _for_list;
	
	/// get formation cfg
	private _for_cfg = VOX_CONFIG select _for_idx;
	
	/// add cfg to list
	{
		private _icon = _x select 0;
		private _name = _x select 1;
		private _cfg = _x select 2;
		private _mod = _x select 3;
		
		/// add to list
		private _added = _for_list lbAdd "";
		_for_list lbSetPicture [_added, _icon];
		_for_list lbSetPictureRight [_added, _mod];
		private _text = (str (_added + 1)) + ". " +_name;
		_for_list lbSetText [_added, _text];
	}forEach _for_cfg
};

VOX_FNC_ADDCFG = {

	if (_this == -1) exitWith {};

	/// get selected config
	private _cfg_list_idx = _this;
	private _cfg_sel = VOX_FACTION select _cfg_list_idx;
	
	private _menu = findDisplay 1200;
	private _formation =  _menu displayCtrl 1201;
	private _for_list =  _menu displayCtrl 1202;
	
	/// get current formation in config
	private _for_idx = lbCurSel _formation;
	private _for_cfg = VOX_CONFIG select _for_idx;
	
	/// block adding over 10 groups/units
	if (count _for_cfg == 10) exitWith {};
	
	/// block adding over 5 log/art/air
	private _isSup = false;
	if (_for_idx in [7,8,9,17,18,19]) then {_isSup = true};
	if (_isSup && (count _for_cfg == 5)) exitWith {};
	
	/// update formation list
	private _icon = _cfg_sel select 0;
	private _name = _cfg_sel select 1;
	private _cfg = _cfg_sel select 2;
	private _mod = _cfg_sel select 3;

	/// add to list
	private _added = _for_list lbAdd "";
	_for_list lbSetPicture [_added, _icon];
	_for_list lbSetPictureRight [_added, _mod];
	_text = (str (_added + 1)) + ". " +_name;
	_for_list lbSetText [_added, _text];
	
	/// add to config
	_for_cfg pushback _cfg_sel;
};

VOX_FNC_DELCFG = {

	if (_this == -1) exitWith {};
	
	private _menu = findDisplay 1200;
	private _formation =  _menu displayCtrl 1201;
	private _for_list =  _menu displayCtrl 1202;
	
	/// get current formation in config
	private _for_idx = lbCurSel _formation;
	private _for_cfg = VOX_CONFIG select _for_idx;
	
	/// remove from config
	_for_cfg deleteAt _this;	
	
	/// clear list
	lbClear _for_list;
	
	/// reload list
	{
		private _icon = _x select 0;
		private _name = _x select 1;
		private _cfg = _x select 2;
		private _mod = _x select 3;
		
		/// add to list
		private _added = _for_list lbAdd "";
		_for_list lbSetPicture [_added, _icon];
		_for_list lbSetPictureRight [_added, _mod];
		private _text = (str (_added + 1)) + ". " +_name;
		_for_list lbSetText [_added, _text];
	}forEach _for_cfg;
	
	_for_list lbSetCurSel -1;
};

VOX_FNC_ADDWEST = {	
	private _selected = VOX_FORMATIONS select _this;

	/// prevent adding more than 10 companies (map has 33 places
	if (count VOX_CFG_WEST == 10) exitwith {};

	private _marker = _selected select 0;
	private _name = _selected select 1;
	private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";

	private _menu = findDisplay 1200;
	private _blu_list =  _menu displayCtrl 1206;
	
	/// add to config
	VOX_CFG_WEST pushback _marker;
	
	/// add to ui
	private _count = str (count VOX_CFG_WEST);
	private _added = _blu_list lbAdd (_count + ". " + _name);
	_blu_list lbSetPicture [_added, _icon];
	_blu_list lbSetPictureColor [_added, [0, 0.3, 0.6, 1]];
};

VOX_FNC_DELWEST = {
	if (_this == -1) exitWith {};

	private _menu = findDisplay 1200;
	private _blu_list =  _menu displayCtrl 1206;

	private _selected = VOX_CFG_WEST select _this;
	_blu_list lbDelete _this;
	
	VOX_CFG_WEST deleteAt _this;
	
	_blu_list lbSetCurSel -1;
};

VOX_FNC_ADDEAST = {	
	private _selected = VOX_FORMATIONS select (_this + 10);

	/// prevent adding more than 10 companies (map has ~30 objectives)
	if (count VOX_CFG_EAST == 10) exitwith {};

	private _marker = _selected select 0;
	private _name = _selected select 1;
	private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";

	private _menu = findDisplay 1200;
	private _opf_list =  _menu displayCtrl 1208;
	
	VOX_CFG_EAST pushback _marker;
	
	private _count = str (count VOX_CFG_EAST);
	private _added = _opf_list lbAdd (_count + ". " + _name);
	_opf_list lbSetPicture [_added, _icon];
	_opf_list lbSetPictureColor [_added, [0.5, 0, 0, 1]];
};

VOX_FNC_DELEAST = {
	if (_this == -1) exitWith {};

	private _menu = findDisplay 1200;
	private _opf_list =  _menu displayCtrl 1208;

	private _selected = VOX_CFG_EAST select _this;
	_opf_list lbDelete _this;
	
	VOX_CFG_EAST deleteAt _this;
	
	_opf_list lbSetCurSel -1;
};

VOX_FNC_IMPORT = {
	private _menu = findDisplay 1200;
	private _importfield = _menu displayCtrl 1209;
	private _text = ctrlText _importfield;
	private _array = call compile _text;
	if (count _array == 20) then {
		hint "Config imported.";
		VOX_CONFIG = _array;
	} else {
		hint "Config error!";
	};
};

VOX_FNC_EXPORT = {
	copyToClipBoard str VOX_CONFIG;
	hint "Config copied to clipboard";
};

VOX_FNC_START = {

};

[] spawn {
	while {VOX_PHASE == "CUSTOM"} do {
		if (isNull findDisplay 1200) then {
			createDialog "VOX_CUSTOM";
			private _menu = findDisplay 1200;
			private _formation =  _menu displayCtrl 1201;
			private _factions =  _menu displayCtrl 1203;
			private _blufor =  _menu displayCtrl 1205;
			private _opfor =  _menu displayCtrl 1207;
			private _scenario = _menu displayCtrl 1212;
			private _start =  _menu displayCtrl 1213;
			
			{
				private _marker = _x select 0;
				private _name = _x select 1;
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";
				
				private _added = _formation lbAdd _name;
				_formation lbSetPicture [_added, _icon];
				private _color = [0, 0.3, 0.6, 1];
				if (_forEachIndex > 9) then {_color = [0.5, 0, 0, 1]};
				_formation lbSetPictureColor [_added, _color];
			}forEach VOX_FORMATIONS;
			_formation lbSetCurSel 0;
			
			{
				private _icon = _x select 0;
				private _name = _x select 1;
				private _cfg = _x select 2;
				private _mod = _x select 3;
				
				private _added = _factions lbAdd _name;
				_factions lbSetPicture [_added, _icon];
				_factions lbSetPictureRight [_added, _mod];
				
			}forEach VOX_FACTIONS;
			_factions lbSetCurSel 0;
			
			{
				private _marker = _x select 0;
				private _name = _x select 1;
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";
				
				private _added = _blufor lbAdd _name;
				_blufor lbSetPicture [_added, _icon];
				private _color = [0, 0.3, 0.6, 1];
				_blufor lbSetPictureColor [_added, _color];				
			}forEach (VOX_FORMATIONS select [0, 10]);
			
			{
				private _marker = _x select 0;
				private _name = _x select 1;
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";
				
				private _added = _opfor lbAdd _name;
				_opfor lbSetPicture [_added, _icon];
				private _color = [0.5, 0, 0, 1];
				_opfor lbSetPictureColor [_added, _color];				
			}forEach (VOX_FORMATIONS select [10, 10]);
			
			_scenario lbAdd "WEST";
			_scenario lbAdd "EAST";
			_scenario lbAdd "NORTH";
			_scenario lbAdd "SOUTH";
			_scenario lbSetCurSel 0;
		};
		
		sleep 1;
	};
};