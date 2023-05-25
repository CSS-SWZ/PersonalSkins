ConVar CvarSkins;
ConVar CvarSetSkinDelay;

bool SkinsEnabled;
float SetSkinDelay;

void ConVarsInit()
{
    CvarSkins = CreateConVar("sm_personal_skins", "1");
    CvarSetSkinDelay = CreateConVar("sm_personal_skins_delay", "0.75");

    SkinsEnabled = CvarSkins.BoolValue;
    SetSkinDelay = CvarSetSkinDelay.FloatValue;

    CvarSkins.AddChangeHook(OnConVarChanged);
    CvarSetSkinDelay.AddChangeHook(OnConVarChanged);
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
}