// XEH_preInit.sqf
// Author: Sysroot (Modified by Gemini)
// Purpose: Defines CBA Addon Options for ACE Armor Adjuster.

diag_log "AAA DEBUG: XEH_preInit.sqf executed.";

// Define the mod's name, which serves as the category for CBA settings.
// This MUST match the category name used in fn_initUnit.sqf.
private _modName = "ACE Armor Adjuster";

// --- Core Toggles ---
// Enable/Disable the entire armor scaling system.
["AAA_VAR_MOD_ENABLED", "CHECKBOX", ["STR_AAA_MOD_ENABLED", "STR_AAA_MOD_ENABLED_Desc"], [_modName, "STR_AAA_Toggles"], true, 1, {}, false] call CBA_fnc_addSetting;

// Enable/Disable debug logging and on-screen hints.
["AAA_VAR_DEBUG", "CHECKBOX", ["STR_AAA_DEBUG", "STR_AAA_DEBUG_Desc"], [_modName, "STR_AAA_Toggles"], true, 1, {}, false] call CBA_fnc_addSetting;

// Apply scaling to player units.
["AAA_VAR_PLAYERS_ENABLED", "CHECKBOX", ["STR_AAA_PLAYERS_ENABLED", "STR_AAA_PLAYERS_ENABLED_Desc"], [_modName, "STR_AAA_Toggles"], true, 1, {}, false] call CBA_fnc_addSetting;

// Force base armor override, ignoring ACE's calculated armor for enabled hitpoints.
["AAA_VAR_FORCE_BASE_ARMOR", "CHECKBOX", ["STR_AAA_FORCE_BASE_ARMOR", "STR_AAA_FORCE_BASE_ARMOR_Desc"], [_modName, "STR_AAA_Toggles"], false, 1, {}, false] call CBA_fnc_addSetting;


// --- Core Sliders ---
// Base Armor Value: An additional armor value added to hitpoints.
// Range: 0 to 50, Default: 10, Step: 0.1
["AAA_VAR_BASE_ARMOR_VALUE", "SLIDER", ["STR_AAA_BASE_ARMOR", "STR_AAA_BASE_ARMOR_Desc"], [_modName, "STR_AAA_CoreSliders"], [0, 50, 10, 0.1, false], 1, {}, false] call CBA_fnc_addSetting;

// Minimum ACE Armor for Scaling: Below this, coefficients are not applied.
// Range: 0 to 50, Default: 2, Step: 0.1
["AAA_VAR_MIN_ARMOR_VALUE", "SLIDER", ["STR_AAA_MIN_ARMOR_VALUE", "STR_AAA_MIN_ARMOR_VALUE_Desc"], [_modName, "STR_AAA_CoreSliders"], [0, 50, 2, 0.1, false], 1, {}, false] call CBA_fnc_addSetting;

// Projectile Penetration Exponent: Controls how much caliber affects armor penetration.
// Range: 0 to 0.5, Default: 0.25, Step: 0.01 (smaller steps for fine-tuning)
["AAA_VAR_PEN_EXPONENT", "SLIDER", ["STR_AAA_PEN_EXPONENT", "STR_AAA_PEN_EXPONENT_Desc"], [_modName, "STR_AAA_CoreSliders"], [0, 0.5, 0.25, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;


// --- Side-based Coefficients ---
// Armor multiplier for BLUFOR units.
// Range: 0.01 to 50, Default: 1, Step: 0.01
["AAA_VAR_BLUFOR_ARMOR_COEF", "SLIDER", ["STR_AAA_BLUFOR_ARMOR_COEF", "STR_AAA_BLUFOR_ARMOR_COEF_Desc"], [_modName, "STR_AAA_SideCoefficients"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Armor multiplier for OPFOR units.
// Range: 0.01 to 50, Default: 1, Step: 0.01
["AAA_VAR_OPFOR_ARMOR_COEF", "SLIDER", ["STR_AAA_OPFOR_ARMOR_COEF", "STR_AAA_OPFOR_ARMOR_COEF_Desc"], [_modName, "STR_AAA_SideCoefficients"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Armor multiplier for INDEP units.
// Range: 0.01 to 50, Default: 1, Step: 0.01
["AAA_VAR_INDEP_ARMOR_COEF", "SLIDER", ["STR_AAA_INDEP_ARMOR_COEF", "STR_AAA_INDEP_ARMOR_COEF_Desc"], [_modName, "STR_AAA_SideCoefficients"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Armor multiplier for CIVILIAN units.
// Range: 0.01 to 50, Default: 1, Step: 0.01
["AAA_VAR_CIVILIAN_ARMOR_COEF", "SLIDER", ["STR_AAA_CIVILIAN_ARMOR_COEF", "STR_AAA_CIVILIAN_ARMOR_COEF_Desc"], [_modName, "STR_AAA_SideCoefficients"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;


// --- Player & AI Scaling ---
// Armor multiplier for player units.
// Range: 0.01 to 50, Default: 1, Step: 0.01
["AAA_VAR_PLAYER_ARMOR_COEF", "SLIDER", ["STR_AAA_PLAYER_ARMOR_COEF", "STR_AAA_PLAYER_ARMOR_COEF_Desc"], [_modName, "STR_AAA_PlayerAIArmor"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Armor multiplier for AI units.
// Range: 0.01 to 50, Default: 1, Step: 0.01
["AAA_VAR_AI_ARMOR_COEF", "SLIDER", ["STR_AAA_AI_ARMOR_COEF", "STR_AAA_AI_ARMOR_COEF_Desc"], [_modName, "STR_AAA_PlayerAIArmor"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;


// --- Hitpoint Toggles and Coefficients ---
// For each hitpoint, there's a toggle to enable/disable scaling and a slider for its specific coefficient.
// All hitpoint coefficients will range from 0.01 to 50, Default: 1, Step: 0.01

// Face
["AAA_VAR_HITFACE_ENABLED", "CHECKBOX", ["STR_AAA_HitFace_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITFACE_COEF", "SLIDER", ["STR_AAA_FaceMult", "STR_AAA_FaceMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Head
["AAA_VAR_HITHEAD_ENABLED", "CHECKBOX", ["STR_AAA_HitHead_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITHEAD_COEF", "SLIDER", ["STR_AAA_HeadMult", "STR_AAA_HeadMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Pelvis
["AAA_VAR_HITPELVIS_ENABLED", "CHECKBOX", ["STR_AAA_HitPelvis_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITPELVIS_COEF", "SLIDER", ["STR_AAA_PelvisMult", "STR_AAA_PelvisMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Abdomen
["AAA_VAR_HITABDOMEN_ENABLED", "CHECKBOX", ["STR_AAA_HitAbdomen_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITABDOMEN_COEF", "SLIDER", ["STR_AAA_AbdomenMult", "STR_AAA_AbdomenMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Diaphragm
["AAA_VAR_HITDIAPHRAGM_ENABLED", "CHECKBOX", ["STR_AAA_HitDiaphragm_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITDIAPHRAGM_COEF", "SLIDER", ["STR_AAA_DiaphragmMult", "STR_AAA_DiaphragmMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Chest
["AAA_VAR_HITCHEST_ENABLED", "CHECKBOX", ["STR_AAA_HitChest_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITCHEST_COEF", "SLIDER", ["STR_AAA_ChestMult", "STR_AAA_ChestMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Body (General torso)
["AAA_VAR_HITBODY_ENABLED", "CHECKBOX", ["STR_AAA_HitBody_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITBODY_COEF", "SLIDER", ["STR_AAA_BodyMult", "STR_AAA_BodyMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Left Arm
["AAA_VAR_HITLEFTARM_ENABLED", "CHECKBOX", ["STR_AAA_HitLeftArm_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITLEFTARM_COEF", "SLIDER", ["STR_AAA_LeftArmMult", "STR_AAA_LeftArmMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Right Arm
["AAA_VAR_HITRIGHTARM_ENABLED", "CHECKBOX", ["STR_AAA_HitRightArm_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITRIGHTARM_COEF", "SLIDER", ["STR_AAA_RightArmMult", "STR_AAA_RightArmMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Hands (often combined with arms or separate)
["AAA_VAR_HITHANDS_ENABLED", "CHECKBOX", ["STR_AAA_HitHands_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITHANDS_COEF", "SLIDER", ["STR_AAA_HandsMult", "STR_AAA_HandsMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Legs (general)
["AAA_VAR_HITLEGS_ENABLED", "CHECKBOX", ["STR_AAA_HitLegs_ENABLED", "STR_AAA_HPEnabled_Desc"], [_modName, "STR_AAA_HitpointToggles"], true, 1, {}, false] call CBA_fnc_addSetting;
["AAA_VAR_HITLEGS_COEF", "SLIDER", ["STR_AAA_LegsMult", "STR_AAA_LegsMult_Desc"], [_modName, "STR_AAA_HitpointMults"], [0.01, 50, 1, 0.01, false], 1, {}, false] call CBA_fnc_addSetting;

// Add categories for stringtable.xml (if they don't exist)
["STR_AAA_Toggles", "Toggles"] call CBA_fnc_addCategory;
["STR_AAA_CoreSliders", "Core Sliders"] call CBA_fnc_addCategory;
["STR_AAA_SideCoefficients", "Side Coefficients"] call CBA_fnc_addCategory;
["STR_AAA_PlayerAIArmor", "Player/AI Armor"] call CBA_fnc_addCategory;
["STR_AAA_HitpointToggles", "Hitpoint Toggles"] call CBA_fnc_addCategory;
["STR_AAA_HitpointMults", "Hitpoint Multipliers"] call CBA_fnc_addCategory;
