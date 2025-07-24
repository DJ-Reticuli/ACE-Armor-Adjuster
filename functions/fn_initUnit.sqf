// fn_initUnit.sqf
// Author: Sysroot (Improved by Gemini)
// Purpose: Custom HandleDamage event per unit using CBA sliders + vanilla caliber
//          - Corrected CBA settings retrieval to avoid "Type Object, expected String" error
//          - Enhanced debug logging and on-screen hints
//          - Refined damage calculation for clearer effect

params ["_unit"];

// Define the correct CBA settings category name.
// This MUST match the _modName used in XEH_preInit.sqf.
private _cbaSettingsCategory = "ACE Armor Adjuster";

// --- Initial Debug Flag Retrieval (for fn_initUnit scope) ---
// Retrieve the debug setting. For global settings like this, it's safer to NOT pass a unit object
// as the first parameter to CBA_settings_fnc_get, as it expects a string for the setting name.
private _debug = ["AAA_VAR_DEBUG", _cbaSettingsCategory] call CBA_settings_fnc_get;
if (isNil "_debug" || {typeName _debug != "BOOL"}) then {
    _debug = false; // Default to false if setting is not properly retrieved
    diag_log format ["AAA ERROR: AAA_VAR_DEBUG setting not found or invalid type (%1), defaulting to false.", typeName _debug];
};

if (_debug) then {
    diag_log format ["AAA DEBUG: fn_initUnit fired for unit %1 (Type: %2)", _unit, typeOf _unit];
    if (hasInterface) then {
        // Use a hint to confirm the function is called for easier in-game debugging
        hint format ["AAA DEBUG: fn_initUnit fired for %1", _unit];
    };
};

// --- Remove existing ACE_medical HandleDamage Event Handler ---
// It's crucial to remove any previously added ACE medical damage event handler
// to prevent conflicts and ensure our custom handler is the only one active.
private _oldEH = _unit getVariable ["ACE_medical_HandleDamageEHID", -1];
if (_oldEH >= 0) then {
    _unit removeEventHandler ["HandleDamage", _oldEH];
    if (_debug) then {
        diag_log format ["AAA DEBUG: Removed old ACE_medical_HandleDamageEHID (%1) from %2.", _oldEH, _unit];
    };
};

// --- Add new Custom HandleDamage Event Handler ---
// This is the core of the mod, where damage is intercepted and modified.
private _ehID = _unit addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
    // Re-fetch debug setting within the event handler scope to ensure it's current.
    // Still using the global retrieval method without a unit object for this global setting.
    private _debugEH = ["AAA_VAR_DEBUG", _cbaSettingsCategory] call CBA_settings_fnc_get;
    if (isNil "_debugEH" || {typeName _debugEH != "BOOL"}) then {
        _debugEH = false; // Default to false if setting is not properly retrieved
    };
    if (_debugEH) then {
        diag_log format ["AAA DEBUG: HandleDamage called for %1. Initial params: %2", _unit, _this];
    };

    // --- Fetch Core Toggles ---
    // Retrieve mod enablement settings from CBA.
    // These are global settings, so retrieve without a unit object.
    private _modEnabled     = ["AAA_VAR_MOD_ENABLED",     _cbaSettingsCategory] call CBA_settings_fnc_get;
    private _playersEnabled = ["AAA_VAR_PLAYERS_ENABLED", _cbaSettingsCategory] call CBA_settings_fnc_get;
    private _forceBase      = ["AAA_VAR_FORCE_BASE_ARMOR", _cbaSettingsCategory] call CBA_settings_fnc_get;
    // Robustly default settings if not found or invalid type.
    if (isNil "_modEnabled"     || {typeName _modEnabled     != "BOOL"}) then { _modEnabled     = true; };
    if (isNil "_playersEnabled" || {typeName _playersEnabled != "BOOL"}) then { _playersEnabled = true; };
    if (isNil "_forceBase"      || {typeName _forceBase      != "BOOL"}) then { _forceBase = false; };


    // --- Early Exit Conditions ---
    // If the mod is disabled, or if players are disabled and this is a player unit,
    // exit early and return the original damage, letting ACE handle it normally.
    if (!_modEnabled || (! _playersEnabled && isPlayer _unit)) exitWith {
        if (_debugEH) then { diag_log "AAA DEBUG: Mod disabled or players not enabled for this unit. Exiting."; };
        _damage
    };

    // Normalize hitpoint name to lowercase for consistent lookup.
    private _hp = toLower _hitPoint;
    // Define a list of valid hitpoints that the mod should process.
    private _validHPs = ["hitface","hithead","hitpelvis","hitabdomen","hitdiaphragm","hitchest","hitbody","hitleftarm","hitrightarm","hithands","hitlegs"];
    // If the hitpoint is not one we're configured to handle, exit.
    if !(_hp in _validHPs) exitWith {
        if (_debugEH) then { diag_log format ["AAA DEBUG: Hitpoint '%1' not in valid list. Exiting.", _hp]; };
        _damage
    };

    // Check if scaling is enabled for this specific hitpoint.
    // **Corrected:** These are global settings, so do NOT pass the unit object.
    private _hpEnabled = ["AAA_VAR_" + (toUpper _hp) + "_ENABLED", _cbaSettingsCategory] call CBA_settings_fnc_get;
    if (isNil "_hpEnabled" || {typeName _hpEnabled != "BOOL"}) then { _hpEnabled = true; }; // Default to true if not found/invalid
    if (!_hpEnabled) exitWith {
        if (_debugEH) then { diag_log format ["AAA DEBUG: Scaling disabled for hitpoint '%1'. Exiting.", _hp]; };
        _damage
    };

    // Calculate the actual damage added in this hit.
    // _prevDamage is the current damage level of the hitpoint.
    // _addedDamage is the new damage being applied in this hit.
    private _prevDamage  = _unit getHit _hp;
    private _addedDamage = _damage - _prevDamage;
    // If no new damage is being added (e.g., already dead, or a very small hit), exit.
    if (_addedDamage <= 0) exitWith {
        if (_debugEH) then { diag_log "AAA DEBUG: No new damage added or damage <= 0. Exiting."; };
        _damage
    };

    // --- Fetch Global Settings (Sliders) ---
    // Retrieve various numerical settings from CBA.
    // These are global settings, so retrieve without a unit object.
    private _baseArmor  = ["AAA_VAR_BASE_ARMOR_VALUE", _cbaSettingsCategory] call CBA_settings_fnc_get;
    private _minArmor   = ["AAA_VAR_MIN_ARMOR_VALUE",  _cbaSettingsCategory] call CBA_settings_fnc_get;
    private _exponent   = ["AAA_VAR_PEN_EXPONENT",     _cbaSettingsCategory] call CBA_settings_fnc_get;
    // Robustly default settings if not found or invalid type.
    if (isNil "_baseArmor" || {typeName _baseArmor != "SCALAR"}) then { _baseArmor = 10; }; // Default base armor
    if (isNil "_minArmor"  || {typeName _minArmor  != "SCALAR"}) then { _minArmor  = 2; }; // Default min ACE armor for scaling
    if (isNil "_exponent"  || {typeName _exponent  != "SCALAR"}) then { _exponent  = 0.25; }; // Default caliber exponent

    // --- Retrieve Raw ACE Armor Value ---
    // Get the base armor value for the hitpoint from ACE.
    private _aceRawArmor = [_unit, _hp] call ace_medical_engine_fnc_getHitpointArmor;
    // If ACE returns an array (e.g., [value, max_value]), take the first element.
    if (typeName _aceRawArmor == "ARRAY") then { _aceRawArmor = _aceRawArmor param [0, 0]; };
    // Ensure raw armor is not negative.
    _aceRawArmor = _aceRawArmor max 0;
    // --- Compute Effective Armor (ACE + Base) ---
    // This is the total armor value used in the damage calculation.
    // If 'Force Base Armor Override' is enabled, only _baseArmor is used.
    // Otherwise, it's a sum of ACE's raw armor and the custom base armor.
    // Ensure it's never zero or negative to prevent division errors.
    private _effectiveArmor = (if (_forceBase) then {
        (_baseArmor) max 0.001
    } else {
        (_aceRawArmor + _baseArmor) max 0.001
    });
    // --- Determine Combined Armor Coefficient ---
    // This coefficient combines side, player/AI, and hitpoint specific multipliers.
    private _isPlayer = isPlayer _unit;
    private _side     = if (_isPlayer) then { playerSide } else { side _unit };
    // These are global settings, so retrieve without a unit object.
    private _sideCoef = ["AAA_VAR_" + (toUpper str _side) + "_ARMOR_COEF", _cbaSettingsCategory] call CBA_settings_fnc_get;
    private _playerCoef = ["AAA_VAR_" + (if (_isPlayer) then {"PLAYER"} else {"AI"}) + "_ARMOR_COEF", _cbaSettingsCategory] call CBA_settings_fnc_get;
    // **Corrected:** This is a global setting, so do NOT pass the unit object.
    private _hitpointCoef = ["AAA_VAR_" + (toUpper _hp) + "_COEF", _cbaSettingsCategory] call CBA_settings_fnc_get;
    // Default coefficients if not found or invalid type.
    if (isNil "_sideCoef"   || {typeName _sideCoef   != "SCALAR"}) then { _sideCoef   = 1; };
    if (isNil "_playerCoef" || {typeName _playerCoef != "SCALAR"}) then { _playerCoef = 1; };
    if (isNil "_hitpointCoef" || {typeName _hitpointCoef != "SCALAR"}) then { _hitpointCoef = 1; };

    // Initialize the combined coefficient.
    private _combinedCoef = 1;

    // Apply coefficients only if ACE raw armor meets the minimum threshold.
    // This allows for 'weak spots' or areas where ACE armor is too low to be scaled.
    if (_aceRawArmor >= _minArmor) then {
        _combinedCoef = (_sideCoef max 0.001) * (_playerCoef max 0.001) * (_hitpointCoef max 0.001);
    };

    // --- Caliber Attenuation ---
    // Adjust the combined coefficient based on the projectile's caliber and the exponent.
    // Larger caliber (and higher exponent) means more penetration, thus reducing the effective armor.
    private _caliber = getNumber (configFile >> "CfgAmmo" >> _projectile >> "caliber");
    if (_caliber <= 0) then { _caliber = 1; }; // Prevent division by zero if caliber is not defined
    private _attMod = _caliber ^ _exponent;
    _combinedCoef = _combinedCoef / (_attMod max 0.001); // Ensure _attMod is not zero to prevent division by zero

    // --- Final Damage Multiplier Calculation ---
    // This is the core formula for reducing incoming damage.
    // The '+ 1' in the denominator ensures that damage is always attenuated (never amplified)
    // and provides a smoother scaling curve, preventing extreme damage reduction at low armor values.
    private _damageMultiplier = 1 / ((_combinedCoef * _effectiveArmor) + 1);
    // --- Compute New Damage ---
    // Apply the calculated damage multiplier to the added damage.
    // The total damage to the hitpoint is the previous damage plus the attenuated new damage.
    private _newDamage = _prevDamage + (_addedDamage * _damageMultiplier);

    // --- Debug Output for Each Hit ---
    if (_debugEH) then {
        private _initSpeed = getNumber (configFile >> "CfgAmmo" >> _projectile >> "initSpeed");
        if (_initSpeed <= 0) then { _initSpeed = "N/A"; };

        // Calculate the percentage change for debug clarity.
        private _changeText = if (_addedDamage > 0) then {
            format ["DAMAGE REDUCTION: %1%%", (100 - (_damageMultiplier * 100)) toFixed 2]
        } else {
            "CHANGE: N/A"
        };
        private _msg = format [
            "AAA DEBUG: NEW HIT!\n" +
            "UNIT: %1\nHITPOINT: %2\nPROJECTILE: %3\n" +
            "CALIBER: %4 | INIT SPD: %5 | EXP: %6\n" +
            "RAW ACE ARMOR: %7 | BASE ARMOR: %8 | EFFECTIVE ARMOR: %9\n" +
            "SIDE COEF: %10 | PLAYER/AI COEF: %11 | HITPOINT COEF: %12\n" +
            "COMBINED COEF (Pre-Caliber): %13 | CALIBER ATTENUATION: %14\n" +
            "FINAL COEF: %15\n" +
            "DAMAGE MULTIPLIER: %16 | %17\n" +
            "ORIGINAL ADDED DAMAGE: %18 | MODIFIED ADDED DAMAGE: %19\n" +
            "TOTAL HITPOINT DAMAGE: %20",
            _unit, _hp, _projectile,
            _caliber, _initSpeed, _exponent,
            _aceRawArmor, _baseArmor, _effectiveArmor,
            _sideCoef, _playerCoef, _hitpointCoef,
            (_sideCoef max 0.001) * (_playerCoef max 0.001) * (_hitpointCoef max 0.001), _attMod,
            _combinedCoef,
            _damageMultiplier, _changeText,
            _addedDamage, (_addedDamage * _damageMultiplier),
            _newDamage
        ];
        diag_log _msg; // Log detailed info to RPT file
        if (hasInterface && (_isPlayer || {local _unit})) then {
            // Show hint only for player or locally controlled units with interface
            hint _msg;
        };
    };

    // Return the adjusted damage value.
    _newDamage
}];

// Store the event handler ID on the unit for future removal/cleanup.
_unit setVariable ["ACE_medical_HandleDamageEHID", _ehID, true];
