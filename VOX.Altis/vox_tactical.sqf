/// spawn groups (on server)
/// spawn all groups on attacker/defender
/// spawn 1x random group on all counters on map (exc. original)

/// synch aircart to aristrike support
/// sync helicopters to gunship support
/// sync helicopters with cargoseat to transport support

/// set HQ setGroupId ["Command Group"];
/// start objective loop
/// spawn jukebox

/// if SUP is not present:
/// random ammo
/// random fuel
/// random skill

/// TAC AI:
/// if arty: alarm sound after delay
/// if air: air raid siren
/// option to disable?

/// close map
/// debug group
private _group = [[15351.2,17080.1,0], west, 5] call BIS_fnc_spawnGroup;
{addSwitchableUnit _x}forEach units _group;

/// open teamswitch menu and close map&menu
remoteExec ["VOX_FNC_CLOSEMAP", 0];
remoteExec ["VOX_FNC_SLOTTING", 0];