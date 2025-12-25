waitUntil {!isNil "HEX_PHASE"};
LOC_SIDE = side player;
LOC_SLOTTING = true;

/// Close briefing map
(findDisplay 1400) closedisplay 1;

//// Minimap? - selecting from list moves map to the units position
/// Confirm if unit can actually be selected!
/// confirm button changes color when can be switched to?

LOC_FNC_SLOT = {
/// close menu
	(findDisplay 1500) closedisplay 1;
/// switch to unit

/// update slotting variable
	LOC_SLOTTING = false;
	
	/// make sure the switch actually happened, if two players slot in same unit or unit gets killed while clicking, will cause problem!

/// call update globally
};

/// Open slotting menu if player is ghost unit
[] spawn {
	while {HEX_PHASE == "TACTICAL"} do {
		
		if (isNull findDisplay 1500 && LOC_SLOTTING) then {
			createDialog "HEX_SLOTTING";
			private _menu = findDisplay 1500;
			private _text = _menu displayCtrl 1501;
			private _groups = _menu displayCtrl 1502;
			private _units = _menu displayCtrl 1503;
			private _button = _menu displayCtrl 1504;
			private _minimap = _menu displayCtrl 1505;
			private _color = [0, 0.3, 0.6, 0.5];
			if (LOC_SIDE == east) then {
				_color = [0.5, 0, 0, 0.5];
			};
			
			_text ctrlSetBackgroundColor _color;
			
		};
		
		sleep 1;
	};
};