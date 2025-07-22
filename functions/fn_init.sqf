// Copyright 2022 Sysroot
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0

// This is AAA_fnc_init, called by CfgFunctions with preInit = 1.
// It sets up the global HandleDamage event handler for CAManBase units.
if (isServer) then {
    ["CAManBase", "init", {
        params ["_unit"];
        if (local _unit) then {
            [_unit] call AAA_fnc_initUnit;
        } else {
            [_unit] remoteExecCall ["AAA_fnc_initUnit", _unit];
        };
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};
