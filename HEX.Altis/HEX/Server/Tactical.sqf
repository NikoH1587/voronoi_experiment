HEX_OBJECTIVES_WEST = [];
HEX_OBJECTIVES_NEUT = [];
HEX_OBJECTIVES_EAST = [];

/// add objectives
{
	private _hex = _x;
	private _sid = _x select 4;
	if (_sid == west && _hex in HEX_TACTICAL) then {HEX_OBJECTIVES_WEST pushback _hex};
	if (_sid == east && _hex in HEX_TACTICAL) then {HEX_OBJECTIVES_EAST pushback _hex};
	if (_sid == resistance) then {HEX_OBJECTIVES_NEUT pushback _hex};
}forEach HEX_GRID;

/// spawn strategic units
{
	private _hex = _x;
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _type = _x select 3;
	private _side = _x select 4;
	private _count = _x select 6; /// how many groups are stored
	private _map = _x select 7;
	
	private _factions = [HEX_WEST];
	if (_side == east) then {_factions = [HEX_EAST]};
	private _configs = [_factions, _type] call HEX_SRV_FNC_VEHICLES;
	
	private _select = _configs select floor random count _configs;
	private _group = [_pos, _side, _select] call HEX_FNC_SRV_SPAWNVEHICLE;
	_group setVariable ["HEX_ICON", _type, true];
	_group setVariable ["HEX_ID", [_row, _col], true];
	_group setVariable ["MARTA_customIcon", [_type], true];
	_group deleteGroupWhenEmpty true;
	
	if (_type == "b_hq") then {
		HEX_OFFICER_WEST = (units _group) select 0;
	};
	
	if (_type == "o_hq") then {
		HEX_OFFICER_EAST = (units _group) select 0;
	};
}forEach HEX_STRATEGIC;

/// Start 1h counter, call debriefing after
HEX_PHASE = "TACTICAL";
publicVariable "HEX_PHASE";

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
	};
}forEach _westGroups;

if (_drones) then {
	HEX_OFFICER_WEST linkItem "B_UavTerminal"; 
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
	};
}forEach _eastGroups;

if (_drones) then {
	HEX_OFFICER_EAST linkItem "O_UavTerminal"; 
};

/// remove all other (grid?) markers
0 call HEX_SRV_FNC_GRIDDELETE;

/// Close tactical briefing locally
remoteExec ["HEX_LOC_FNC_CLOSEBRIEFING", 0, false];

/// start game functions loop and spawn tactical groups
call compile preprocessFile "HEX\Server\Game.sqf";

sleep 5;

/// remove all counter markers;
remoteExec ["HEX_LOC_FNC_COTEDELETE", 0, true];

/// Open Slotting menu locally with JIP
remoteExec ["HEX_LOC_FNC_SLOTTING", 0, true];