waitUntil {!isNil "VOX_ATTACKER"};
waitUntil {!isNil "VOX_DEFENDER"};

private _posA = VOX_ATTACKER select 0;
private _posB = VOX_DEFENDER select 0;
private _posC = [(((_posA select 0) + (_posB select 0)) / 2),(((_posA select 1) + (_posB select 1)) / 2)];
private _dist = (_posA distance _posB) / worldsize;
mapAnimAdd [1, _dist, _posC];
mapAnimCommit;

/// radio effect for briefing;
private _soundID = 0;
private _atkunit = VOX_ATTACKER select 4;
if (_atkunit in ["b_air","o_air"]) then {_soundID = 1};
if (_atkunit in ["b_art","o_art"]) then {_soundID = 2};
if (_atkunit in ["b_plane","o_plane"]) then {_soundID = 3};
0 call VOX_FNC_RADIO;
_soundID call VOX_FNC_SFX;

VOX_FNC_ENDBRIEFING = {
	if (isServer) then {
		VOX_PHASE = "TACTICAL";
		publicVariable "VOX_PHASE";
		execVM "vox_tactical.sqf";
	};
};

/// Open briefing menu
[] spawn {
	private _open = false;
	while {VOX_PHASE == "BRIEFING"} do {
		if (visibleMap && !_open) then {
			_open = true;
			(findDisplay 46) createDisplay "VOX_BRIEFING";
			private _menu = findDisplay 1400;
			private _info = _menu displayCtrl 1401;
			private _start = _menu displayCtrl 1402;
			
			/// Info text backround
			private _color = [0, 0.3, 0.6, 0.5];
			if (playerSide == east) then {
				_color = [0.5, 0, 0, 0.5];
			};

			_info ctrlSetBackgroundColor _color;

			_info lbAdd "TACTICAL BRIEFING:";
			_info lbAdd "";
			_info lbAdd "Available supports can be accessed with (F2 -> 5 -> 1)";
			_info lbAdd "'CMD' leader has High Command Module (Ctrl+Space)";
			
			/// Start button text
			if (isServer) then {
				_start ctrlSetText "COMMENCE BATTLE";
			} else {
				_start ctrlSetText "WAITING HOST...";
			};
		};
		
		/// make sure menu doesn't close if map is closed
		if (!visibleMap && _open) then {
			(findDisplay 1400) closedisplay 1;
			_open = false;
			openmap true;
		};
		
		sleep 1;
	};
};