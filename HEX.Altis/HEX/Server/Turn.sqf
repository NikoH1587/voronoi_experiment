/// Find counter in combat
private _tactical = [];
{
	private _hex = _x;
	private _row = _x select 0;
	private _col = _x select 1;
	private _sid = _x select 4;
	
	private _near = _hex call HEX_FNC_NEAR;
	private _sides = [_sid];
		
	{
		_sides pushback (_x select 4);
	}forEach _near;
	
	if (_sid != civilian && west in _sides && east in _sides) then {
		_tactical pushback _hex;
	};
}forEach HEX_GRID;

private _strategic = [];

{
	private _hex = _x;
	private _row = _x select 0;
	private _col = _x select 1;
	private _pos = _x select 2;
	private _cfg = _x select 3;
	private _sid = _x select 4;
	private _org = _x select 5;
	
	private _isStrat = false;
	if (_cfg in ["b_art", "b_support", "b_air", "b_plane", "b_antiair"]) then {_isStrat = true};
	if (_cfg in ["o_art", "o_support", "o_air", "o_plane", "o_antiair"]) then {_isStrat = true};
	
	private _noTac = true;
	if (_hex in _tactical) then {_noTac = false};
	
	if (_org == 1 && _isStrat && _noTac) then {
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
	remoteExec ["HEX_FNC_BRIEFING", 0, false];
};

/// publicVariable "HEX_PHASE";

/// Switch turn globally
private _turn = civilian;
if (HEX_TURN == west) then {_turn = east};
if (HEX_TURN == east) then {_turn = west};
HEX_TURN = _turn;

/// Create new time array
private _time = HEX_TIME;
private _oldTime = _time select 0;
_time deleteat 0;
_time append [_oldTime];
HEX_TIME = _time;

/// Create new weather array
private _weather = HEX_WEATHER;
private _newWeather = HEX_ALLWEATHER select floor random count HEX_ALLWEATHER;
_weather deleteAt 0;
_weather append [_newWeather];
HEX_WEATHER = _weather;

/// Set new weather
private _overcast = 0;
private _fog = 0;
if (_weather select 0 == "CLOUDS") then {_overcast = 0.5};
if (_weather select 0 == "STORM") then {_overcast = 1};
if (_weather select 0 == "FOG") then {_fog = 0.33};
0 setOverCast _overcast;
0 setFog _fog;
forceWeatherChange;

/// Set date
private _now = date;
private _year = _now select 0;
private _month = _now select 1;

if (_oldTime == "DUSK") then {HEX_DAY = HEX_DAY + 1};
private _day = HEX_DAY;	

private _hour = 0;
if (HEX_TIME select 0 == "NIGHT") then {_hour = -3 + (floor (random 9))};
if (HEX_TIME select 0 == "DAWN") then {_hour = 6 + (floor (random 3))}; 
if (HEX_TIME select 0 == "DAY1") then {_hour = 9 + (floor (random 3))};
if (HEX_TIME select 0 == "DAY2") then {_hour = 12 + (floor (random 3))};
if (HEX_TIME select 0 == "DAY3") then {_hour = 15 + (floor (random 3))};
if (HEX_TIME select 0 == "DUSK") then {_hour = 18 + (floor (random 3))};

private _date = [_year, _month, _day, _hour, 0] call BIS_fnc_fixDate;
setDate _date;

/// Update grid counter moves;
{
	private _index = _forEachIndex;
	private _hex = _x;
	private _cfg = _x select 3;
	private _sid = _x select 4;
	
	private _act = 1;
	if (HEX_TURN == _sid) then {
		if (_cfg in ["b_mech_inf", "b_armor", "o_mech_inf", "o_armor", "b_antiair", "o_antiair"]) then {_act = 2};
		if (_cfg in ["b_motor_inf", "b_recon", "o_motor_inf", "o_recon", "b_support", "o_support"]) then {_act = 3};
		_hex set [5, _act];
		HEX_GRID set [_index, _hex];
	};
}forEach HEX_GRID;

publicVariable "HEX_TURN";
publicVariable "HEX_TIME";
publicVariable "HEX_WEATHER";
publicVariable "HEX_GRID";

/// Clear local orders, markers and sound
remoteExec ["HEX_FNC_CLIC", 0, false];

/// Update counters globally
remoteExec ["HEX_FNC_COTE", 0, false];