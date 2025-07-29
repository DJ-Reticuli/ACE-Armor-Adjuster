////////////////////////////////////////////////////////////////////
//DeRap: config.bin
//Produced from mikero's Dos Tools Dll version 9.98
//https://mikero.bytex.digital/Downloads
//'now' is Fri Jul 25 23:34:13 2025 : 'file' last modified on Tue Sep 26 02:33:54 2023
////////////////////////////////////////////////////////////////////

#define _ARMA_

class CfgPatches
{
	class AAA
	{
		name = "$STR_AAA_Name";
		author = "Sysroot";
		requiredVersion = 1.6;
		units[] = {};
		weapons[] = {};
		requiredAddons[] = {"cba_xeh","ace_medical"};
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
				postInit = 1;
			};
			class initUnit{};
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
