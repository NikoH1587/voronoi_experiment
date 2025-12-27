/// close loading menu
HEX_PHASE = "CUSTOM";
HEX_DAY = 0;
(findDisplay 1100) closedisplay 1;

ADM_FACTIONS = []; /// List of faction names
HEX_SIZE = 750;
HEX_WEST = "BLU_F"; /// faction name for spawning
HEX_EAST = "OPF_F";

HEX_CFG_WEST = ["b_hq"];
HEX_CFG_EAST = ["o_hq"];

ADM_FNC_FACWEST = {
	/// Update list with possible options
	
};

ADM_FNC_FACEAST = {

};

ADM_FNC_ADDWEST = {
	/// if -1 ignore
	/// Add to selected
	/// update current array
	/// set cursel -1
};

ADM_FNC_DELETEWEST = {
	/// if -1 ignore
	/// Delete selected entry
	/// Exclude HQ!
	/// Update selected array
	/// set cursel -1
};

ADM_FNC_START = {
	(findDisplay 1200) closedisplay 1;
	HEX_PHASE = "STRATEGIC";
	publicVariable "HEX_WEST";
	publicVariable "HEX_EAST";
	publicVariable "HEX_CFG_WEST";
	publicVariable "HEX_CFG_EAST";
	
	publicVariable "HEX_SIZE";
	publicVariable "HEX_TIME";
	publicVariable "HEX_TURN";
	publicVariable "HEX_PHASE";
	publicVariable "HEX_DAY";
	"CUSTOM" remoteExec ["HEX_FNC_CAMPAIGN", 2, false];
};

/// updates export field every 1 sec?
AMD_FNC_EXPORT = {};

/// Open custom menu for admin
[] spawn {
	while {HEX_PHASE == "CUSTOM"} do {
		if (isNull findDisplay 1200) then {
			createDialog "HEX_CUSTOM";
			private _menu = findDisplay 1200;
			private _facWest = _menu displayCtrl 1201;
			private _facEest = _menu displayCtrl 1202;
			
			
			private _listWest = _menu displayCtrl 1203;
			private _selWest = _menu displayCtrl 1204;
			private _selEast = _menu displayCtrl 1205;
			private _listEast = _menu displayCtrl 1206;
			
			private _scenario = _menu displayCtrl 1207;
			_scenario lbAdd "WEST";
			_scenario lbAdd "NORT";
			_scenario lbAdd "EAST";
			_scenario lbAdd "SOUTH";
			_scenario lbSetCurSel 0;
			
			private _time = _menu displayCtrl 1208;
			_time lbAdd "NIGHT";
			_time lbAdd "DAWN";
			_time lbAdd "DAY";
			_time lbAdd "DAY";
			_time lbAdd "DAY";
			_time lbAdd "DUSK";
			_time lbSetCurSel 0;
			
			private _turn = _menu displayCtrl 1209;
			_turn lbAdd "BLUFOR";
			_turn lbAdd "OPFOR";
			_turn lbSetCurSel 0;
		};
		
		sleep 1;
	};
};