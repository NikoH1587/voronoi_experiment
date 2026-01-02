/// Spawn groups on server (variable in group)
{
	private _pos = _x select 2;
	private _type = _x select 3;
	private _side = _x select 4;
	private _state = _x select 6;

	private _factions = [HEX_WEST];
	if (_side == east) then {_factions = [HEX_EAST]};
	/// spawn some infantry even for strategic counters
	private _icons = ["\A3\ui_f\data\map\markers\nato\b_inf.paa", "\A3\ui_f\data\map\markers\nato\n_inf.paa", "\A3\ui_f\data\map\markers\nato\o_inf.paa"];
	if (_type in ["b_recon", "o_recon"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_recon.paa", "\A3\ui_f\data\map\markers\nato\n_recon.paa", "\A3\ui_f\data\map\markers\nato\o_recon.paa"]};	
	if (_type in ["b_motor_inf", "o_motor_inf"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\n_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa"]};
	if (_type in ["b_mech_inf", "o_mech_inf"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\n_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa"]};
	if (_type in ["b_armor", "o_armor"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_armor.paa", "\A3\ui_f\data\map\markers\nato\n_armor.paa", "\A3\ui_f\data\map\markers\nato\o_armor.paa"]};

	private _configs = [_factions, _icons] call HEX_SRV_FNC_GROUPS;
}forEach HEX_TACTICAL;

{
	private _pos = _x select 2;
	private _type = _x select 3;
	private _side = _x select 4;
	private _state = _x select 6;
	
	private _factions = [HEX_WEST];
	if (_side == east) then {_factions = [HEX_EAST]};	
	
	private _configs = [_factions, _type] call HEX_SRV_FNC_VEHICLES;
	if (_side == west) then {hint str _configs, copyToClipboard str _configs};
}forEach HEX_STRATEGIC;

/// Spawn Capture points on server (name after counter)
/// Start 1h counter, call debriefing after
/// if all groups killed / all points captured:
/// stop counter short of time

HEX_PHASE = "TACTICAL";
publicVariable "HEX_PHASE";

/// Close tactical briefing locally
remoteExec ["HEX_FNC_CLOSEBRIEFING", 2, false];

/// Open Slotting menu locally with JIP
remoteExec ["HEX_FNC_SLOTTING", 0, true];