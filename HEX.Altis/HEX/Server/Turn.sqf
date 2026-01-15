/// Find counter in combat
/// counters tounching are in tactical array
private _tactical = [];
{
	private _hex = _x;
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _cfg = _x select 3;
	private _sid = _x select 4;
	private _act = _x select 5;
	private _org = _x select 6;
	
	private _near = _hex call HEX_GLO_FNC_NEAR;
	private _sides = [_sid];
		
	{
		_sides pushback (_x select 4);
	}forEach _near;

	private _isTac = true;
	if (_cfg in ["b_art", "b_support", "b_air", "b_plane", "b_antiair"]) then {_isTac = false};
	if (_cfg in ["o_art", "o_support", "o_air", "o_plane", "o_antiair"]) then {_isTac = false};

	if (_sid != civilian && west in _sides && east in _sides && _isTac) then {
		_tactical pushback _hex;
	};
}forEach HEX_GRID;

/// counters that are of strategic type, not in tactical already go in strategic array
private _strategic = [];

{
	private _hex = _x;
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _cfg = _x select 3;
	private _sid = _x select 4;
	private _act = _x select 5;
	private _org = _x select 6;
	
	private _isStrat = false;
	if (_cfg in ["b_art", "b_support", "b_air", "b_plane", "b_antiair"]) then {_isStrat = true};
	if (_cfg in ["o_art", "o_support", "o_air", "o_plane", "o_antiair"]) then {_isStrat = true};
	
	if (_isStrat) then {
		_strategic pushback _hex;
	};
}forEach HEX_GRID;

/// Start tactical phase
if (count _tactical > 0) then {
	HEX_TACTICAL = _tactical;
	HEX_STRATEGIC = _strategic;
	HEX_PHASE = "BRIEFING";
	publicVariable "HEX_PHASE";
	publicVariable "HEX_TACTICAL";
	publicVariable "HEX_STRATEGIC";
	
	/// Open briefing locally for all
	remoteExec ["HEX_LOC_FNC_BRIEFING", 0, false];
	
/// Changes current state only if still in strategic phase
} else {

	/// Switch turn globally
	private _turn = civilian;
	if (HEX_TURN == west) then {_turn = east};
	if (HEX_TURN == east) then {_turn = west};
	HEX_TURN = _turn;

	/// Create new weather
	HEX_WEATHER = ["CLEAR", "CLEAR", "CLEAR", "CLEAR", "CLOUDS", "CLOUDS", "STORM", "FOG"] select floor random 8;

	/// Create new time
	private _time = "NONE";
	if (HEX_TIME == "NIGHT") then {_time = "DAWN"};
	if (HEX_TIME == "DAWN") then {_time = "DAY1"};
	if (HEX_TIME == "DAY1") then {_time = "DAY2"};
	if (HEX_TIME == "DAY2") then {_time = "DAY3"};
	if (HEX_TIME == "DAY3") then {_time = "DUSK"};
	if (HEX_TIME == "DUSK") then {_time = "NIGHT"};

	HEX_TIME = _time;

	/// Set new day
	if (_time == "NIGHT") then {HEX_DAY = HEX_DAY + 1};

	/// Update grid counter moves;
	{
		private _index = _forEachIndex;
		private _hex = _x;
		private _cfg = _x select 3;
		private _sid = _x select 4;
	
		private _act = 0;
		if (HEX_TURN == _sid) then {
			if (_cfg in ["b_inf", "b_hq", "b_art", "o_inf", "o_hq", "o_art"]) then {_act = 1};
			if (_cfg in ["b_mech_inf", "b_armor", "o_mech_inf", "o_armor", "b_antiair", "o_antiair"]) then {_act = 2};
			if (_cfg in ["b_motor_inf", "b_recon", "o_motor_inf", "o_recon", "b_support", "o_support"]) then {_act = 3};
			_hex set [5, _act];
			HEX_GRID set [_index, _hex];
		};
	}forEach HEX_GRID;

	/// update variables globally
	publicVariable "HEX_DAY";
	publicVariable "HEX_TURN";
	publicVariable "HEX_TIME";
	publicVariable "HEX_WEATHER";
	publicVariable "HEX_GRID";

	/// update time and weather 
	call compile preprocessFile "HEX\Server\Time.sqf";

	/// Clear local orders, markers and sound
	remoteExec ["HEX_LOC_FNC_CLIC", 0, false];

	/// Update counters globally
	remoteExec ["HEX_LOC_FNC_COTE", 0, false];
}