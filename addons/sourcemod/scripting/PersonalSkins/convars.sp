ConVar CvarSkins;
ConVar CvarSetSkinDelay;
ConVar CvarIgnoreCustomModelscale;

bool SkinsEnabled;
float SetSkinDelay;
bool IgnoreCustomModelscale;

void ConVarsInit()
{
    CvarSkins = CreateConVar("sm_personal_skins", "1");
    CvarSetSkinDelay = CreateConVar("sm_personal_skins_delay", "0.75");
    CvarIgnoreCustomModelscale = CreateConVar("sm_personal_skins_ignore_custom_modelscale", "1");

    SkinsEnabled = CvarSkins.BoolValue;
    SetSkinDelay = CvarSetSkinDelay.FloatValue;
    IgnoreCustomModelscale = CvarIgnoreCustomModelscale.BoolValue;

    CvarSkins.AddChangeHook(OnConVarChanged);
    CvarSetSkinDelay.AddChangeHook(OnConVarChanged);
    CvarIgnoreCustomModelscale.AddChangeHook(OnConVarChanged);
}

public void OnConVarChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    if(cvar == CvarSkins)
    {
        SkinsEnabled = CvarSkins.BoolValue;
    }
    else if(cvar == CvarSetSkinDelay)
    {
        SetSkinDelay = CvarSetSkinDelay.FloatValue;
    }
    else if(cvar == CvarIgnoreCustomModelscale)
    {
        IgnoreCustomModelscale = CvarIgnoreCustomModelscale.BoolValue;
    }
}