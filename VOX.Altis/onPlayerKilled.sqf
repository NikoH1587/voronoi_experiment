params ["_oldUnit", "_killer", "_respawn", "_respawnDelay"];

/// see vox_slotting.sqf
if (VOX_SINGLEPLAYER == false) then {
	0 call VOX_FNC_SLOTTING;
};

