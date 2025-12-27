/// TBD: make a save system
ADM_SAVE = false;

/// Gee I sure do hope nobody picks "AI Commander" as their profileName! ;3
ADM_FNC_GETPLAYERS = {
	ADM_WEST_PLAYERS = ["AI Commander"];
	ADM_EAST_PLAYERS = ["AI Commander"];

	private _allPlayers = call BIS_fnc_listPlayers;
	_westPlayers = _allPlayers select {side _x == west};
	_eastPlayers = _allPlayers select {side _x == east};
	{ADM_WEST_PLAYERS pushback (name _x)}forEach _westPlayers;
	{ADM_EAST_PLAYERS pushback (name _x)}forEach _eastPlayers;
};

ADM_FNC_CONTINUE = {
	if (LOC_ADMIN) then {
		if (ADM_SAVE) then {
			/// load save from client onto server
		} else {
			/// start new default campaign on server
			"DEFAULT" remoteExec ["HEX_FNC_CAMPAIGN", 2, false];
		};
	};
};

ADM_FNC_NEWSAVE = {
	if (LOC_ADMIN) then {
		/// Set phase locally for admin
		HEX_PHASE == "CUSTOM";
		/// Open custom menu locally for admin
		call compile preprocessFile "HEX\Local\Custom.sqf"
	};
};

ADM_FNC_CMDW = {
	ADM_WEST_COMMANDER = ADM_WEST_PLAYERS select _this;
	publicVariable "ADM_WEST_COMMANDER";
};

ADM_FNC_CMDE = {
	ADM_EAST_COMMANDER = ADM_EAST_PLAYERS select _this;
	publicVariable "ADM_EAST_COMMANDER";
};

/// Open loading menu
[] spawn {
	while {HEX_PHASE == "LOADING"} do {
		
		if (isNull findDisplay 1100) then {
			createDialog "HEX_LOADING";
			private _menu = findDisplay 1100;
			private _continue = _menu displayCtrl 1101;
			private _newsave = _menu displayCtrl 1102;
			private _import = _menu displayCtrl 1103;
			private _westtext = _menu displayCtrl 1104;
			private _westCMD = _menu displayCtrl 1105;
			private _easttext = _menu displayCtrl 1106;
			private _eastCMD = _menu displayCtrl 1107;
			
			/// Show setting if player is admin
			if (LOC_ADMIN) then {
				if (ADM_SAVE) then {
					_continue ctrlSetText "CONTINUE CAMPAIGN";		
					_newsave ctrlSetText "NEW CAMPAIGN";						
				} else {
					_continue ctrlSetText "DEFAULT CAMPAIGN";		
					_newsave ctrlSetText "CUSTOM CAMPAIGN";
				};
				
				0 call ADM_FNC_GETPLAYERS;
				
				/// Selection of commanders
				{_westCMD lbAdd _x}forEach ADM_WEST_PLAYERS;
				{_eastCMD lbAdd _x}forEach ADM_EAST_PLAYERS;
				
				_westCMD lbsetCurSel 0;
				_eastCMD lbsetCurSel 0;
			} else {
			
				_continue ctrlSetText "WAIT FOR ADMIN...";
				_newsave ctrlShow false;
				_import ctrlShow false;
				_westtext ctrlShow false;
				_westCMD ctrlShow false;
				_easttext ctrlShow false;
				_eastCMD ctrlShow false;
			
			};
		};
		
		sleep 1;
	};
};