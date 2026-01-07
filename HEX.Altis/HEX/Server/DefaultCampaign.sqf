/// Default variables
HEX_SIZE = 1000;
HEX_PHASE = "STRATEGIC";
HEX_SCENARIO = ["W", "E", "N", "S"] select floor random 4;
HEX_TIME = ["NIGHT", "DAWN", "DAY1", "DAY2", "DAY3", "DUSK"] select floor random 6;
HEX_DAY = 0;
HEX_TURN = [west, east] select floor random 2;
HEX_WEST = "BLU_F";
HEX_EAST = "OPF_F";
HEX_FULLMAP = false;

/// Create random west counters
private _allAux = ["b_art", "b_support", "b_air", "b_plane", "b_antiair"];
private _allPri = ["b_recon", "b_motor_inf", "b_mech_inf", "b_armor"];

private _aux1 = _allAux select floor random count _allAux;
_allAux = _allAux - [_aux1];
private _aux2 = _allAux select floor random count _allAux;

private _pri1 = _allPri select floor random count _allPri;
_allPri = _allPri - [_pri1];
private _pri2 = _allPri select floor random count _allPri;

HEX_CFG_WEST = ["b_hq", _aux1, _aux2, "b_inf", "b_inf", _pri1, _pri2];

/// Create random east counters
private _allAux = ["o_art", "o_support", "o_air", "o_plane", "o_antiair"];
private _allPri = ["o_recon", "o_motor_inf", "o_mech_inf", "o_armor"];

private _aux1 = _allAux select floor random count _allAux;
_allAux = _allAux - [_aux1];
private _aux2 = _allAux select floor random count _allAux;

private _pri1 = _allPri select floor random count _allPri;
_allPri = _allPri - [_pri1];
private _pri2 = _allPri select floor random count _allPri;

HEX_CFG_EAST = ["o_hq", _aux1, _aux2, "o_inf", "o_inf", _pri1, _pri2];

/// Globalize variables
publicVariable "HEX_SIZE";
publicVariable "HEX_TIME";
publicVariable "HEX_TURN";
publicVariable "HEX_PHASE";

/// generate grid, counters & weather
call compile preprocessFile "HEX\Server\Generation.sqf";

/// create grid overlay
0 call HEX_SRV_FNC_GRID;

/// update zone of control
0 call HEX_SRV_FNC_ZOCO;

/// update time and weather
call compile preprocessFile "HEX\Server\Time.sqf";	

/// begin strategic phase
remoteExec ["HEX_LOC_FNC_STRATEGIC", 0, false];

