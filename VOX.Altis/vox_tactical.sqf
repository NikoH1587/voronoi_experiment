/// spawn groups (on server)
/// set HQ setGroupId ["Command Group"];
/// start objective loop
/// spawn jukebox

/// close map
/// debug group
private _group = [[15351.2,17080.1,0], west, 5] call BIS_fnc_spawnGroup;
{addSwitchableUnit _x}forEach units _group;

/// open teamswitch menu and close map&menu
remoteExec ["VOX_FNC_CLOSEMAP", 0];
remoteExec ["VOX_FNC_SLOTTING", 0];