VOX_PHASE = "CUSTOM";

/// TBD: add more types, b_recon (recon), b_unknown (militia)
/// [_marker, _name]
VOX_COMPANIES = [
["b_inf", "Infantry"],
["b_motor_inf", "Motorized"],
["b_mech_inf", "Mechanized"],
["b_air", "Airmobile"],
["b_naval", "Amphibious"],
["o_inf", "Infantry"],
["o_motor_inf", "Motorized"],
["o_mech_inf", "Mechanized"],
["o_air", "Airmobile"],
["o_naval", "Amphibious"]
];

/// contains cfgGroups and CfgVehicles entires
VOX_CFG_BINF = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
VOX_CFG_BMOT = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
VOX_CFG_BMEC = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
VOX_CFG_BAIR = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
VOX_CFG_BNAV = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
VOX_CFG_OINF = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
VOX_CFG_OMOT = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
VOX_CFG_OMEC = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
VOX_CFG_OAIR = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
VOX_CFG_ONAV = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];

VOX_CONFIG = [

];

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

/// [[_marker, _name], [_marker, _name]]
VOX_CFG_WEST = [];
VOX_CFG_EAST = [];

VOX_FNC_FACTION = {
	private _faction = (VOX_FACTIONS select _this) select 2;
	
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
						VOX_FACTION pushback [_icon, _name, _x];
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
	
	/// update faction list
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

/// Open slotting menu if player is ghost unit
[] spawn {
	while {VOX_PHASE == "CUSTOM"} do {
		if (isNull findDisplay 1200) then {
			createDialog "VOX_CUSTOM";
			private _menu = findDisplay 1200;
			private _company =  _menu displayCtrl 1201;
			private _coy_list =  _menu displayCtrl 1202;
			private _factions =  _menu displayCtrl 1203;
			private _cfg_list =  _menu displayCtrl 1204;
			private _blufor =  _menu displayCtrl 1205;
			private _blu_list =  _menu displayCtrl 1206;
			private _opfor =  _menu displayCtrl 1207;
			private _opf_list =  _menu displayCtrl 1208;
			private _minimap =  _menu displayCtrl 1209;
			private _turn =  _menu displayCtrl 1210;
			private _start =  _menu displayCtrl 1211;
			
			
			{
				private _marker = _x select 0;
				private _name = _x select 1;
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";
				
				private _added = _company lbAdd _name;
				_company lbSetPicture [_added, _icon];
				private _color = [0, 0.3, 0.6, 1];
				if (_forEachIndex > 4) then {_color = [0.5, 0, 0, 1]};
				_company lbSetPictureColor [_added, _color];
			}forEach VOX_COMPANIES;
			_company lbSetCurSel 0;
			
			{
				private _icon = _x select 0;
				private _name = _x select 1;
				private _cfg = _x select 2;
				
				private _added = _factions lbAdd (_name + " - " + (str _cfg));
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
			}forEach (VOX_COMPANIES select [0, 5]);
			_blufor lbSetCurSel 0;
			
			{
				private _marker = _x select 0;
				private _name = _x select 1;
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _marker + ".paa";
				
				private _added = _opfor lbAdd _name;
				_opfor lbSetPicture [_added, _icon];
				private _color = [0.5, 0, 0, 1];
				_opfor lbSetPictureColor [_added, _color];				
			}forEach (VOX_COMPANIES select [5, 5]);
			_opfor lbSetCurSel 0;
			
			
			/// set on map click
			/// move map to cent
			/// zoom out map to max
		};
		
		sleep 1;
	};
};