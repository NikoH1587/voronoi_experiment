openmap true;
LOC_MODE = "SELECT"; /// "SELECT", "ORDER";
LOC_ORDERS = [];
LOC_SELECT = [];

LOC_FNC_SELECT = {
	private _selectable = [];
	private _posCLICK = _this;
	/// Find counters with moves
	{
		private _hex = _x;
		private _sid = _x select 4;
			private _act = _x select 5;
		if (_sid == side player && _act > 0) then {
			_selectable pushback _hex;
		};
	}forEach HEX_GRID;

	/// Select counter
	{
		private _hex = _x;
		private _pos = _x select 2;
		if (_pos distance _posCLICK < (HEX_SIZE/2)) then {
			LOC_SELECT = _x;
			LOC_MODE = "ORDER";
			
			private _marker = createMarkerLocal ["HEX_SELECT", _pos];
			_marker setMarkerTypeLocal "Select";
			_marker setMarkerSize [1.5, 1.5];
			
			/// Play sound 
			0 spawn LOC_FNC_EFFECT;
			
			/// Add all possible near moves
			private _near = _hex call HEX_FNC_NEAR;
			{
				private _nearHEX = _x;
				private _side = _x select 4;
				if (_side == civilian) then {
					LOC_ORDERS pushback _nearHEX;
				};
			}forEach _near;
			
			/// Add move markers
			{
				private _row = _x select 0;
				private _col = _x select 1;
				private _pos2 = _x select 2;
				private _name2 = format ["ACT_%1_%2", _row, _col];
				private _marker2 = createMarkerLocal [_name2, _pos2];
				_marker2 setMarkerTypeLocal "Select";
			}ForEach LOC_ORDERS;
		};
	}forEach _selectable;
};

LOC_FNC_ORDER = {
	private _posCLICK = _this;

	/// Select move
	{
		private _hex = _x;
		private _pos = _x select 2;
		
		if (_pos distance _posCLICK < (HEX_SIZE/2)) then {
		
			private _hex2 = LOC_SELECT;
			private _row2 = _hex2 select 0;
			private _col2 = _hex2 select 1;
			
			private _name2 = format ["LOC_%1_%2", _row2, _col2];
			_name2 setMarkerPosLocal _pos;
			
			/// Send move to server
			[LOC_SELECT, _hex] remoteExec ["HEX_FNC_MOVE", 2, false];
		};
	}forEach LOC_ORDERS;
	
	/// Clear local orders, markers and sound
	remoteExec ["HEX_FNC_CLIC", 0, false];
};

onMapSingleClick {
	if (LOC_MODE == "SELECT") then {
		_pos spawn LOC_FNC_SELECT;
	};
	
	if (LOC_MODE == "ORDER") then {
		_pos spawn LOC_FNC_ORDER;
	};
	true;
};

/// Sound effect
LOC_FNC_EFFECT = {
	private _sounds = [
		"a3\dubbing_radio_f\sfx\radionoise1.ogg", 
		"a3\dubbing_radio_f\sfx\radionoise2.ogg", 
		"a3\dubbing_radio_f\sfx\radionoise3.ogg"
	];
	
	private _sound = _sounds select floor random count _sounds;
	
	private _pitch = random 1;
	LOC_SOUND = playSoundUI [_sound, 2 - _pitch, _pitch];
};

/// TBD: Road +1 move skip:
/// Origin (1st hex) has to have road hex
/// Middle (2nd hex w/HEX_FNC_NEAR) is civilian & Road
/// destination (3rd) is civilian & Road

/// Could also be done like this (would use flood as origin point, with enemy ZoC + max radius limiting it):
/// road tile + logi(support) = move another unit into road hex
/// friendly helo + airport = move another unit into hex
/// ship + harbor = move another unit into shore hex
/// HQ = Teleport in reserve/imaginary units?
			
/// Aircraft carrier / etc ship = airport + harbor
/// this could make airdrops/shore landings possible