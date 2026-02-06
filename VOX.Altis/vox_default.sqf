VOX_DEBUG = true;
VOX_SIZE = 500;
VOX_TURN = [west, east] select floor random 2;
VOX_PHASE = "STRATEGIC";
VOX_SCENARIO = "WEST"; /// "NORTH", "EAST", "SOUTH", "WEST" 

VOX_CFG_WEST = ["b_recon", "b_inf", "b_mech_inf", "b_motor_inf", "b_naval", "b_air"];
VOX_CFG_EAST = ["o_recon", "o_inf", "o_mech_inf", "o_naval", "o_air"];
publicVariable "VOX_TURN";
publicVariable "VOX_PHASE";