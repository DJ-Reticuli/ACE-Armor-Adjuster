#define _ARMA_

class CfgPatches
{
    class AAA
    {
        name = "ACE Armor Adjuster";
        author = "Sysroot";
        requiredVersion = 1.6;
        units[] = {};
        weapons[] = {};
        requiredAddons[] = {"cba_xeh", "ace_medical"};
        magazines[] = {};
    };
};

class CfgFunctions
{
    class AAA
    {
        class functions
        {
            tag = "AAA";
            file = "AAA\functions";
            class init
            {
                preInit = 1;
            };
            class initUnit {};
        };
    };
};

class Extended_PreInit_EventHandlers
{
    class AAA_Init_Addon_Options
    {
        init = "call compile preprocessFileLineNumbers 'AAA\XEH_preInit.sqf'";
    };
};
