VOX_PHASE = "CUSTOM";

/// TBD: add more types, b_recon (recon), b_unknown (militia)

/// [_icon, _name, _config]
VOX_FACTIONS = [];

/// get all factions
private _configs = (configFile >> "CfgFactionClasses") call BIS_fnc_getCfgSubClasses;

{
	private _cfg = (configFile >> "CfgFactionClasses" >> _x);
	private _name = getText (_cfg >> "displayName");
	private _icon = getText (_cfg >> "icon");
	private _side = getNumber (_cfg >> "side");
	if (_side in [0, 1, 2]) then {
		VOX_FACTIONS pushBack [_icon, _name, _x];
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
		{
			private _cats = "true" configClasses _x;
			{
				private _grps = "true" configClasses _x;
				{
					private _fact = getText (_x >> "faction");
					private _icon = getText (_x >> "icon");
					private _name = getText (_x >> "name");
					
					if (_fact == _faction) then {
						VOX_FACTION pushback [_icon, _facname + " " + _name, _x];
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

			if (_man == 0 && _fac == _faction) then {
				VOX_FACTION pushback [_pic, _txt, [_cfg]];
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
				
		private _added = _cfg_list lbAdd _name;
		_cfg_list lbSetPicture [_added, _icon];
				
	}forEach VOX_FACTION;
	_cfg_list lbSetCurSel -1;
};

/// contains cfgGroups and CfgVehicles entires
VOX_CONFIG = [[],[],[],[],[],[],[],[],[],[]];

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
		
		/// add to list
		private _added = _for_list lbAdd "";
		_for_list lbSetPicture [_added, _icon];
		if (_added == 0) then {
			private _text = "CMD" + ". " + _name;
			_for_list lbSetText [_added, _text];
		} else {
			private _text = (str _added) + ". " +_name;
			_for_list lbSetText [_added, _text];
		};
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
	/// private _cfg_list =  _menu displayCtrl 1204;
	
	/// get current formation in config
	private _for_idx = lbCurSel _formation;
	private _for_cfg = VOX_CONFIG select _for_idx;
	
	/// block adding over 20 groups
	if (count _for_cfg == 18) exitWith {};
	
	/// update formation list
	private _icon = _cfg_sel select 0;
	private _name = _cfg_sel select 1;
	private _cfg = _cfg_sel select 2;

	/// add to list
	private _added = _for_list lbAdd "";
	_for_list lbSetPicture [_added, _icon];
	if (_added == 0) then {
		private _text = "CMD" + ". " + _name;
		_for_list lbSetText [_added, _text];
	} else {
		private _text = (str _added) + ". " +_name;
		_for_list lbSetText [_added, _text];	
	};
	
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
		
		/// add to list
		private _added = _for_list lbAdd "";
		_for_list lbSetPicture [_added, _icon];
		if (_added == 0) then {
			private _text = "CMD" + ". " + _name;
			_for_list lbSetText [_added, _text];
		} else {
			private _text = (str _added) + ". " +_name;
			_for_list lbSetText [_added, _text];
		};
	}forEach _for_cfg;
	
	_for_list lbSetCurSel -1;
};	

/// ["b_inf","b_motor_inf"]
VOX_CFG_WEST = [];
VOX_CFG_EAST = [];

VOX_FNC_ADDWEST = {	
	private _selected = VOX_FORMATIONS select _this;

	private _marker = _selected select 0;
	private _name = _selected select 1;
	private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";

	private _menu = findDisplay 1200;
	private _blu_list =  _menu displayCtrl 1206;
	
	/// add to config
	VOX_CFG_WEST pushback _marker;
	
	/// add to ui
	private _added = _blu_list lbAdd (_name + " Formation");
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
	private _selected = VOX_FORMATIONS select (_this + 6);

	private _marker = _selected select 0;
	private _name = _selected select 1;
	private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";

	private _menu = findDisplay 1200;
	private _opf_list =  _menu displayCtrl 1208;
	
	VOX_CFG_EAST pushback _marker;
	
	private _added = _opf_list lbAdd (_name + " Formation");
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

VOX_FNC_MAP = {
	private _pos = _this;
	private _nearest = "VOX_NEUT";
	
	{
		private _pos2 = getMarkerPos _x;
		private _marker = _x;
		if ((getMarkerPos _nearest) distance _pos > _pos2 distance _pos) then {
			_nearest = _marker;
		};
	}ForEach ["VOX_WEST", "VOX_NEUT", "VOX_EAST"];
	
	_nearest setMarkerPos _pos;
};

/// [_marker, _name]
VOX_FORMATIONS = [
	["b_recon", "Militia"],
	["b_inf", "Infantry"],
	["b_mech_inf", "Mechanized"],
	["b_motor_inf", "Motorized"],
	["b_air", "Airmobile"],
	["b_naval", "Amphibious"],
	["o_recon", "Militia"],
	["o_inf", "Infantry"],
	["o_mech_inf", "Mechanized"],
	["o_motor_inf", "Motorized"],
	["o_air", "Airmobile"],
	["o_naval", "Amphibious"]
];

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
			private _minimap =  _menu displayCtrl 1209;
			private _side = _menu displayCtrl 1210;
			private _start =  _menu displayCtrl 1211;
			
			{
				private _marker = _x select 0;
				private _name = _x select 1;
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";
				
				private _added = _formation lbAdd _name;
				_formation lbSetPicture [_added, _icon];
				private _color = [0, 0.3, 0.6, 1];
				if (_forEachIndex > 4) then {_color = [0.5, 0, 0, 1]};
				_formation lbSetPictureColor [_added, _color];
			}forEach VOX_FORMATIONS;
			_formation lbSetCurSel 0;
			
			{
				private _icon = _x select 0;
				private _name = _x select 1;
				private _cfg = _x select 2;
				
				private _added = _factions lbAdd _name;
				_factions lbSetPicture [_added, _icon];
				
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
			}forEach (VOX_FORMATIONS select [0, 6]);
			
			{
				private _marker = _x select 0;
				private _name = _x select 1;
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";
				
				private _added = _opfor lbAdd _name;
				_opfor lbSetPicture [_added, _icon];
				private _color = [0.5, 0, 0, 1];
				_opfor lbSetPictureColor [_added, _color];				
			}forEach (VOX_FORMATIONS select [6, 6]);
			
			_minimap ctrlMapAnimAdd [1, 1, [worldSize / 2, worldSize / 2]];
			ctrlMapAnimCommit _minimap;
			
			/// Info text backround
			private _color = [0, 0.3, 0.6, 0.5];
			private _text = "PLAYING BLUFOR:";
			if (playerSide == east) then {
				_text = "PLAYING OPFOR:";
				_color = [0.5, 0, 0, 0.5];
			};

			onMapSingleClick {
				_pos spawn VOX_FNC_MAP;
			};

			_side ctrlSetText _text;
			_side ctrlSetBackgroundColor _color;			
		};
		
		sleep 1;
	};
};