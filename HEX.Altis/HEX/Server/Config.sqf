///HEX_GRID pushBack [[_row, _col], _name, [_x,_y], "Border", "ColorBLACK", []]
HEX_GRID = [];
HEX_SCENARIO = "W"; // N, E, S, W
HEX_PHASE = "STRATEGIC"; /// "STRATEGIC", "BRIEFING", "TACTICAL", "DEBRIEFING"
HEX_TACTICAL = []; /// Counters in combat
HEX_STRATEGIC = []; /// Counters that spawn, but not in combat
HEX_TIME = ["NIGHT", "DAWN", "DAY1", "DAY2", "DAY3", "DUSK"];
HEX_WEATHER = ["CLEAR", "CLOUDS", "STORM", "CLOUDS", "FOG", "CLEAR"];
HEX_ALLWEATHER = ["CLEAR", "CLEAR", "CLEAR", "CLEAR", "CLOUDS", "CLOUDS", "STORM", "FOG"];
HEX_DAY = 0; /// use with BIS_FNC_fixdate
HEX_SIZE = 750;
HEX_GROUPS = 6;
HEX_VEHICLES = 2;
HEX_TURN = west;
HEX_WEST = "BLU_F";
HEX_EAST = "OPF_F";
HEX_INTENSITY = 0; /// 0, 1, 2

/// MAX 15+15 counters?
HEX_CFG_WEST = ["b_hq", "b_art", "b_support", "b_air", "b_plane", "b_antiair", "b_inf", "b_recon", "b_motor_inf", "b_mech_inf", "b_armor"];
HEX_CFG_EAST = ["o_hq", "o_art", "o_support", "o_air", "o_plane", "o_antiair", "o_inf", "o_recon", "o_motor_inf", "o_mech_inf", "o_armor"];
