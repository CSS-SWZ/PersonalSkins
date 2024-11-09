void SetClientSkin(int client, int skin = -1, bool bTimer = true)
{
	if(!SkinsEnabled)
		return;

	if(!IgnoreCustomModelscale)
	{
		float modelscale = GetEntPropFloat(client, Prop_Send, "m_flModelScale");

		if(modelscale != 1.0)
			return;
	}

	int team = GetClientTeam(client);
	if(team < 2 || !IsPlayerAlive(client))
		return;

	if(skin == -1)
	{
		if((skin = GetClientRandomSkin(client)) == -1)
		{
			return;
		}
	}

	if(SkinGet(skin) && (Skin.Team == 1 || team == Skin.Team) && Skin.IsPrecached)
	{
		if(bTimer)
		{
			CreateTimer(SetSkinDelay, Timer_SetClientSkin, GetClientUserId(client));
			
		}
		else if(IsModelPrecached(Skin.Model))
		{
			SetEntityModel(client, Skin.Model);
		}
	}
}

void SkinsOnMapStart()
{
	if(!SkinsEnabled)
		return;

	SkinsCacheSettings();
	SkinsCacheClients();
	SkinsDownload();
	SkinsPrecache();
}

void SkinsOnMapEnd()
{
	for(int i = 0; i < SkinsCount; i++)
	{
		if(!SkinGet(i))
			continue;

		Skin.IsPrecached = false;
		Skins.SetArray(Skin.Identifier, Skin, sizeof(Skin), true);
	}
}

void SkinsCacheSettings()
{
	bool cached;
	for(int i; i < SkinsCount; i++)
	{
		if(!SkinGet(i))
			continue;

		cached = IsModelPrecached(Skin.Model);
		Skin.IsPrecached = ((Late && cached) || !Skin.SmartDownload);
		Skins.SetArray(Skin.Identifier, Skin, sizeof(Skin), true);
	}
}

void SkinsCacheClients()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		SkinsCacheClientBySteamID(i);
		SkinsCacheClientByFlags(i);
	}
}

void SkinsCacheClientBySteamID(int client)
{
	if(!Clients[client].SteamID[0])
		return;

	if(!Players.GetArray(Clients[client].SteamID, CachedClientSkins, SkinsCount * CLIENT_SKIN_DATA_SIZE))
		return;

	int skin;

	for(int i = 0; i < SkinsCount * CLIENT_SKIN_DATA_SIZE; i += CLIENT_SKIN_DATA_SIZE)
	{
		skin = CachedClientSkins[i];

		if(skin == -1)
			break;
			
		if(!SkinGet(skin))
			continue;

		Skin.IsPrecached = true;
		Skins.SetArray(Skin.Identifier, Skin, sizeof(Skin), true);
	}
}

void SkinsCacheClientByFlags(int client)
{
	if(Clients[client].Flags <= 0)
		return;

	int skin;
	int length = GroupList.Length;

	for(int i = 0; i < length; i += 2)
	{
		if(!IsClientHaveGroupFlags(client, i))
			continue;

		GroupList.GetArray(i + 1, GroupSkins, MAX_GROUP_SKINS);

		for(int j; j < SkinsCount; j++)
		{
			skin = GroupSkins[j];
			if(skin == -1)
				break;

			if(!SkinGet(skin) || Skin.IsPrecached)
				continue;

			Skin.IsPrecached = true;
			Skins.SetArray(Skin.Identifier, Skin, sizeof(Skin), true);
		}
	}
}

void SkinsDownload()
{
	char path[PLATFORM_MAX_PATH];
	char buffer[PLATFORM_MAX_PATH];
	File f;
	for(int i; i < SkinsCount; i++)
	{
		if(!SkinGet(i) || !Skin.IsPrecached)
			continue;

		if(!BuildPath(Path_SM, path, sizeof(path), "data/personal_skins/%s.txt", Skin.Identifier))
			continue;

		if((f = OpenFile(path, "r")) == null)
			continue;
	    
		while(!f.EndOfFile())
		{
		    if(!f.ReadLine(buffer, sizeof(buffer)) || TrimString(buffer) <= 0 || buffer[0] == '#' || buffer[0] == '/')
		        continue;
		
		    if (DirExists(buffer))
			{
				AddToDownloadFromDirectory(buffer);
			}
			else if (IsValidFile(buffer)) 
			{
				AddFileToDownloadsTable(buffer);
			}
		}
		delete f;
	}
}

void SkinsPrecache()
{
	for(int i; i < SkinsCount; i++)
	{
		if(!SkinGet(i))
		{
			continue;
		}
		if(Skin.IsPrecached)
		{
			PrecacheModel(Skin.Model, true);
		}
		Skins.SetArray(Skin.Identifier, Skin, sizeof(Skin), true)
	}
}

int ToggleClientSavedSkin(int client, int skinId)
{
	if(!SkinGet(skinId))
		return -1;
	
	// Получить текущий индекс в массиве сохраненных скинов игрока
	int skinPos = Clients[client].GetSkinPosition(skinId);

	// Получить свободный индекс
	int freePos = Clients[client].GetSkinFree();
	
	// Скин не включен
	if(skinPos == -1)
	{
		if(Clients[client].GetSkins_Count() == MAX_SAVED_SKINS)
		{
			PrintToChat(client, "%t", "Save skins limit");
			return 2;
		}
		else
		{
			Clients[client].Skins[freePos] = skinId;
		}
		return 1;
	}
	else
	{
		Clients[client].Skins[skinPos] = -1;
		return 0;
	}
}

public Action Timer_SetClientSkin(Handle hTimer, int client)
{
	if((client = GetClientOfUserId(client)) && IsClientInGame(client))
	{
		SetClientSkin(client, _, false);
	}

	return Plugin_Continue;
}

void SetClientSkinNextTick(int client)
{
	if(IsClientInGame(client))
	{
		SetClientSkin(client, _, true);
	}
}

stock bool SkinGet(int skinID)
{
	static char buffer[32];
	return (skinID != -1 && SkinsSnapshot.GetKey(skinID, buffer, sizeof(buffer)) && Skins.GetArray(buffer, Skin, sizeof(Skin)));
}

stock bool SkinGet2(int skinID, SkinData skin)
{
	static char buffer[32];
	return (skinID != -1 && SkinsSnapshot.GetKey(skinID, buffer, sizeof(buffer)) && Skins.GetArray(buffer, skin, sizeof(skin)));
}

int GetSkinIdByKey(const char[] key)
{
	char buffer[256];
	for(int i; i < SkinsCount; i++)
	{
		if(SkinsSnapshot.GetKey(i, buffer, sizeof(buffer)) && !strcmp(key, buffer, false))
			return i;
	}
	return -1;
}