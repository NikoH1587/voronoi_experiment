/// HEX_ variables from admin

/// generate grid, counters & weather
call compile preprocessFile "HEX\Server\Generation.sqf";

/// create grid overlay
0 call HEX_FNC_GRID;

/// update zone of control
0 call HEX_FNC_ZOCO;

/// update time and weather
call compile preprocessFile "HEX\Server\Time.sqf";

/// begin strategic phase
remoteExec ["HEX_FNC_STRATEGIC", 0, false];	