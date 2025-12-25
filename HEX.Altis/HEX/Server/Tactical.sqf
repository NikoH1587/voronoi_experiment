/// Spawn Units on server
/// Spawn Capture points on server

/// set phase globally
HEX_PHASE = "TACTICAL";
publicVariable "HEX_PHASE";

/// Close tactical briefing locally
remoteExec ["HEX_FNC_CLOSEBRIEFING", 2, false];

/// Open Slotting menu locally
remoteExec ["HEX_FNC_SLOTTING", 0, false];