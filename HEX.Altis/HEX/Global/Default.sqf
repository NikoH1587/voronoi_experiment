HEX_SIZE = 750; /// DEFAULT
HEX_PHASE = "STRATEGIC"; /// DEFAULT
HEX_SCENARIO = ["W", "E", "S", "W"] select floor random 4; // customized
HEX_TIME = ["NIGHT", "DAWN", "DAY1", "DAY2", "DAY3", "DUSK"]; /// loaded from save / customized
HEX_DAY = 0; /// default or loaded from save
HEX_TURN = [west, east] select floor random 2; /// loaded from save / customized
HEX_WEST = "BLU_F"; /// loaded from save / customized
HEX_EAST = "OPF_F"; /// loaded from save /customized

/// Default or customized
/// TODO: make randomized factions when loading defaults

/// Create random west counters
HEX_CFG_WEST = ["b_hq"];
private _westAux = ["b_art", "b_support", "b_air", "b_plane", "b_antiair"];
private _westInf = ["b_inf"];
private _westPri = ["b_recon", "b_motor_inf", "b_mech_inf", "b_armor"];

HEX_CFG_WEST pushback (_westAux select floor random count _westAux);
HEX_CFG_WEST pushback (_westAux select floor random count _westAux);
HEX_CFG_WEST pushback (_westInf select floor random count _westInf);
HEX_CFG_WEST pushback (_westInf select floor random count _westInf);
HEX_CFG_WEST pushback (_westPri select floor random count _westPri);
HEX_CFG_WEST pushback (_westPri select floor random count _westPri);

/// Create random west counters
HEX_CFG_EAST = ["o_hq"];
private _eastAux = ["o_art", "o_support", "o_air", "o_plane", "o_antiair"];
private _eastInf = ["o_inf"];
private _eastPri = ["o_recon", "o_motor_inf", "o_mech_inf", "o_armor"];

HEX_CFG_EAST pushback (_eastAux select floor random count _eastAux);
HEX_CFG_EAST pushback (_eastAux select floor random count _eastAux);
HEX_CFG_EAST pushback (_eastInf select floor random count _eastInf);
HEX_CFG_EAST pushback (_eastInf select floor random count _eastInf);
HEX_CFG_EAST pushback (_eastPri select floor random count _eastPri);
HEX_CFG_EAST pushback (_eastPri select floor random count _eastPri);

publicVariable "HEX_SIZE";
publicVariable "HEX_TIME";
publicVariable "HEX_TURN";
publicVariable "HEX_PHASE";
