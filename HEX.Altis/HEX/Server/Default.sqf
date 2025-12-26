HEX_SIZE = 750; /// DEFAULT
HEX_SCENARIO = ["W", "E", "S", "W"] select floor random count 4; // customized
HEX_TIME = ["NIGHT", "DAWN", "DAY1", "DAY2", "DAY3", "DUSK"]; /// loaded from save / customized
HEX_DAY = 0; /// default or loaded from save
HEX_TURN = [west, east] select floor random 2; /// loaded from save / customized
HEX_WEST = "BLU_F"; /// loaded from save / customized
HEX_EAST = "OPF_F"; /// loaded from save /customized

/// Default or customized
/// TODO: make randomized factions when loading defaults
HEX_CFG_WEST = ["b_hq", "b_art", "b_support", "b_air", "b_plane", "b_antiair", "b_inf", "b_recon", "b_motor_inf", "b_mech_inf", "b_armor"];
HEX_CFG_EAST = ["o_hq", "o_art", "o_support", "o_air", "o_plane", "o_antiair", "o_inf", "o_recon", "o_motor_inf", "o_mech_inf", "o_armor"];

HEX_PHASE = "STRATEGIC"; /// DEFAULT

publicVariable "HEX_SIZE";
publicVariable "HEX_TIME";
publicVariable "HEX_TURN";
publicVariable "HEX_PHASE";
