/*
	4.1	-	Fix players authorization
	4.2	-	Fix group error
	4.3 -	Fix root flags mistake
	4.4 -	Fix Group-Arraylist memory
	4.5 -	Added a new parameter "Expiration date"
	4.6 -	Fix cookies group skins
	4.7 - 	Showing the expiration date
			Multilanguage
	4.8 -	Skin can be used for any team ("team" = 1)
			Client can have more "enabled" skins (default = 4, can change in .sp)
	5.0 -	Big update
			Restruct files
			Separate downloadlist file
	5.1 -	Code improve...
			Bug fix: Client have skin with no access
			Bug fix: Skin dont auto set to client (rare bug)
	5.2 -	Code improme
*/

#include <sourcemod>
#include <clientprefs>
#include <sdktools_functions>
#include <sdktools_stringtables>
#include <unixtime_sourcemod>

//#define DEBUG
#define MAX_SKINS 250
#define MAX_GROUP_SKINS 25
#define MAX_SAVED_SKINS 4
#define CLIENT_SKIN_DATA_SIZE 2

#pragma newdecls required

#include "PersonalSkins/debug.sp"
#include "PersonalSkins/convars.sp"
#include "PersonalSkins/global.sp"
#include "PersonalSkins/client.sp"
#include "PersonalSkins/data.sp"
#include "PersonalSkins/events.sp"
#include "PersonalSkins/helpers.sp"
#include "PersonalSkins/menu.sp"
#include "PersonalSkins/skins.sp"

public Plugin myinfo =
{
	name = "PersonalSkins",
	author = "hEl",
	description = "Provides the ability to have personal skins for players and skins by flags",
	version = "5.2",
	url = "https://github.com/CSS-SWZ/PersonalSkins"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	Late = late;

	return APLRes_Success;
}

public void OnPluginStart()
{
	ConVarsInit();
	GlobalVarsInit();
	LoadData();
	MenuInit();
	HookEvents();

	LoadTranslations("personal_skins.phrases");
	
	CreateTimer(0.1, Timer_OnPluginStart);
}

public void OnPluginEnd()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientDisconnect(i);
		}
	}
}

public void OnMapStart()
{
	BuildLogFile()

	SkinsOnMapStart();
	Late = false;
}

public void OnMapEnd()
{
	SkinsOnMapEnd();
}

public Action Timer_OnPluginStart(Handle timer)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		Clients[i].Clear();
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
			
			if(AreClientCookiesCached(i))
			{
				OnClientCookiesCached(i);
			}
			OnClientPostAdminCheck(i);
		}
	}
	
	return Plugin_Continue;
}
