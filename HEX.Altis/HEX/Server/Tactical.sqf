/// Spawn groups on server (variable in group)

HEX_OBJECTIVES_WEST = [];
HEX_OBJECTIVES_NEUT = [];
HEX_OBJECTIVES_EAST = [];

/// add neutral objectives

{
	private _hex = _x;
	private _sid = _x select 4;
	if (_sid == resistance) then {HEX_OBJECTIVES_NEUT pushback _hex};
}forEach HEX_GRID;

/// remove all other (grid?) markers
0 call HEX_SRV_FNC_GRIDDELETE;

/// remove all counter markers;
	remoteExec ["HEX_LOC_FNC_COTEDELETE", 0, true];

{
	private _hex = _x;
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _type = _x select 3;
	private _side = _x select 4;
	private _state = _x select 6;
	
	private _factions = [HEX_WEST];
	if (_side == east) then {_factions = [HEX_EAST]};
	
	/// add to objectives
	if (_side == west) then {HEX_OBJECTIVES_WEST pushback _hex};
	if (_side == east) then {HEX_OBJECTIVES_EAST pushback _hex};
	
	/// get platoon size
	private _size = 3;
	
	if (_type in ["b_inf", "o_inf"]) then {_size = 5};
	
	private _armor = false;
	private _icons = ["\A3\ui_f\data\map\markers\nato\b_inf.paa", "\A3\ui_f\data\map\markers\nato\n_inf.paa", "\A3\ui_f\data\map\markers\nato\o_inf.paa"];	
	if (_type in ["b_recon", "o_recon"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_recon.paa", "\A3\ui_f\data\map\markers\nato\n_recon.paa", "\A3\ui_f\data\map\markers\nato\o_recon.paa"]};	
	if (_type in ["b_motor_inf", "o_motor_inf"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\n_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa"]};
	if (_type in ["b_mech_inf", "o_mech_inf"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\n_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa"]};
	if (_type in ["b_armor", "o_armor"]) then {_armor = true; _icons = ["\A3\ui_f\data\map\markers\nato\b_armor.paa", "\A3\ui_f\data\map\markers\nato\n_armor.paa", "\A3\ui_f\data\map\markers\nato\o_armor.paa"]};
	if (_type in ["b_unknown", "o_unknown"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_inf.paa", "\A3\ui_f\data\map\markers\nato\n_inf.paa", "\A3\ui_f\data\map\markers\nato\o_inf.paa", "\A3\ui_f\data\map\markers\nato\b_recon.paa", "\A3\ui_f\data\map\markers\nato\n_recon.paa", "\A3\ui_f\data\map\markers\nato\o_recon.paa", "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\n_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\n_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa"]};		
	
	private _groupsAndWeights = [_factions, _icons] call HEX_SRV_FNC_GROUPS;
	private _weights = [];
	private _groups = [];
	
	{
		_weights pushback (_x select 0);
		_groups pushback (_x select 1);
	}ForEach _groupsAndWeights;
	
	for "_i" from 1 to _size do {
		private _select = _groups selectRandomWeighted _weights;
		private _config = "true" configClasses _select;
		if (_armor) then {_config = [_config select 0]};
	
		private _group = [_pos, _side, _config, _type] call HEX_FNC_SRV_SPAWNGROUP;
		_group setVariable ["HEX_ICON", _type, true];
		_group setVariable ["HEX_ID", [_row, _col, _i], true];
	};

	/// remove groups from pool

}forEach HEX_TACTICAL;

{
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _type = _x select 3;
	private _side = _x select 4;
	private _count = 1;
	
	private _factions = [HEX_WEST];
	if (_side == east) then {_factions = [HEX_EAST]};
	private _configs = [_factions, _type] call HEX_SRV_FNC_VEHICLES;
	
	private _select = _configs select floor random count _configs;
	private _group = [_pos, _side, _select] call HEX_FNC_SRV_SPAWNVEHICLE;
	_group setVariable ["HEX_ICON", _type, true];
	_group setVariable ["HEX_ID", [_row, _col, 1], true];
	
	if (_type == "b_hq") then {
		HEX_OFFICER_WEST = (units _group) select 0;
	};
	
	if (_type == "o_hq") then {
		HEX_OFFICER_EAST = (units _group) select 0;
	};	
	
	/// remove unit from pool
}forEach HEX_STRATEGIC;

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

/// Start 1h counter, call debriefing after
HEX_PHASE = "TACTICAL";
publicVariable "HEX_PHASE";

/// Close tactical briefing locally
remoteExec ["HEX_LOC_FNC_CLOSEBRIEFING", 2, false];

/// Open Slotting menu locally with JIP
remoteExec ["HEX_LOC_FNC_SLOTTING", 0, true];

private _martaGRP = createGroup sideLogic;
private _marta = "MartaManager" createUnit [
	[0, 0, 0],
	_martaGRP,
	"setGroupIconsVisible [true, false];"
];

HEX_REQ_WEST synchronizeObjectsAdd [HEX_OFFICER_WEST];
private _westGroups = west call HEX_LOC_FNC_GROUPS;
private _drones = false;

{
	private _group = _x;
	private _icon = _group getVariable "HEX_ICON";
	private _leader = [vehicle leader _group];
	
	switch (_icon) do {

		case "b_mortar": {HEX_ART_WEST synchronizeObjectsAdd _leader};	
		case "b_art": {HEX_ART_WEST synchronizeObjectsAdd _leader};
		case "b_antiair": {HEX_OFFICER_WEST hcSetGroup [_group]};
		case "b_air": {HEX_HAT_WEST synchronizeObjectsAdd _leader; HEX_TRA_WEST synchronizeObjectsAdd _leader; HEX_SUP_WEST synchronizeObjectsAdd _leader;};
		case "b_plane": {HEX_CAS_WEST synchronizeObjectsAdd _leader};
		case "b_uav": {_drones = true};
		case "b_support": {HEX_OFFICER_WEST hcSetGroup [_group]};
		case "b_unknown": {HEX_OFFICER_WEST hcSetGroup [_group]};
		case "b_inf": {HEX_OFFICER_WEST hcSetGroup [_group]};
		case "b_recon": {HEX_OFFICER_WEST hcSetGroup [_group]};
		case "b_motor_inf": {HEX_OFFICER_WEST hcSetGroup [_group]};
		case "b_mech_inf": {HEX_OFFICER_WEST hcSetGroup [_group]};
		case "b_armor": {HEX_OFFICER_WEST hcSetGroup [_group]};
	};
}forEach _westGroups;

if (_drones) then {
	HEX_OFFICER_WEST setUnitLoadout "B_soldier_UAV_F";
	removeBackpack HEX_OFFICER_WEST;
	};
HEX_BUNKER_WEST setpos (getPos HEX_OFFICER_WEST);

HEX_REQ_EAST synchronizeObjectsAdd [HEX_OFFICER_EAST];
private _eastGroups = east call HEX_LOC_FNC_GROUPS;
private _drones = false;

{
	private _group = _x;
	private _icon = _group getVariable "HEX_ICON";
	private _leader = [vehicle leader _group];
	
	switch (_icon) do {

		case "o_mortar": {HEX_ART_EAST synchronizeObjectsAdd _leader};	
		case "o_art": {HEX_ART_EAST synchronizeObjectsAdd _leader};
		case "o_antiair": {HEX_OFFICER_EAST hcSetGroup [_group]};
		case "o_air": {HEX_HAT_EAST synchronizeObjectsAdd _leader; HEX_TRA_EAST synchronizeObjectsAdd _leader; HEX_SUP_EAST synchronizeObjectsAdd _leader;};
		case "o_plane": {HEX_CAS_EAST synchronizeObjectsAdd _leader};
		case "o_uav": {_drones = true};
		case "o_support": {HEX_OFFICER_EAST hcSetGroup [_group]};
		case "o_unknown": {HEX_OFFICER_EAST hcSetGroup [_group]};
		case "o_inf": {HEX_OFFICER_EAST hcSetGroup [_group]};
		case "o_recon": {HEX_OFFICER_EAST hcSetGroup [_group]};
		case "o_motor_inf": {HEX_OFFICER_EAST hcSetGroup [_group]};
		case "o_mech_inf": {HEX_OFFICER_EAST hcSetGroup [_group]};
		case "o_armor": {HEX_OFFICER_EAST hcSetGroup [_group]};
	};
}forEach _eastGroups;

if (_drones) then {
	HEX_OFFICER_EAST setUnitLoadout "O_soldier_UAV_F";
	removeBackpack HEX_OFFICER_EAST;
	};
HEX_BUNKER_EAST setpos (getPos HEX_OFFICER_EAST);