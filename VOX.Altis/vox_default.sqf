VOX_DEBUG = true;
VOX_SIZE = 500;
VOX_TURN = [west, east] select floor random 2;
VOX_PHASE = "STRATEGIC";
VOX_SCENARIO = ["WEST", "EAST", "NORTH", "SOUTH"] select floor random 4; /// "NORTH", "EAST", "SOUTH", "WEST" 

VOX_CFG_WEST = ["b_unknown", "b_recon", "b_inf", "b_motor_inf", "b_mech_inf", "b_armor", "b_air", "b_naval"];
VOX_CFG_EAST = ["o_unknown", "o_recon", "o_inf", "o_motor_inf", "o_mech_inf", "o_armor", "o_air", "o_naval"];
publicVariable "VOX_TURN";
publicVariable "VOX_PHASE";