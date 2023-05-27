public void OnClientConnected(int client)
{
	Clients[client].Clear();
}

public void OnClientPutInServer(int client)
{
	if(IsFakeClient(client))
		return;
		
	IntToString(GetSteamAccountID(client, true), Clients[client].SteamID, sizeof(Clients[].SteamID));

	if(!Players.GetArray(Clients[client].SteamID, CachedClientSkins, CLIENT_SKIN_DATA_SIZE))
	{
		Clients[client].SteamID[0] = 0;
	}

	ValidateClientSkins(client);
}

public void OnClientCookiesCached(int client)
{
	if(IsFakeClient(client))
		return;

	GetClientCookieSkins(client);
	ValidateClientSkins(client);
}

public void OnClientPostAdminCheck(int client)
{
	if(IsFakeClient(client))
		return;

	Clients[client].Flags = GetUserFlagBits(client);
	CheckClientGroupSkins(client);
	ValidateClientSkins(client);
}

public void OnClientDisconnect(int client)
{
	CheckCacheClientSkins(client);
}

void ValidateClientSkins(int client)
{
	if(!IsClientInGame(client) || !AreClientCookiesCached(client) || Clients[client].Flags == -1)
		return;
	
	for(int i = 0; i < MAX_SAVED_SKINS; i++)
	{
		if(!SkinGet(Clients[client].Skins[i]))
			continue;

		//DebugMessage("> ValidateClientSkins: %N (i = %i, skinid = %i, count = %i)", client, i, Clients[client].Skins[i], Clients[client].GetSkinSameCount(Clients[client].Skins[i]))
		// Нет доступа к сохраненному скину...
		if(!IsClientSkinAccess(client) || Clients[client].GetSkinSameCount(Clients[client].Skins[i]) > 1)
		{
			Clients[client].Skins[i] = -1;
		}

		if(Clients[client].Skins[i] != -1)
		{
			//DebugMessage("> ValidateClientSkins: %N (Skin #%i - %s)", client, i, Skin.Identifier)
		}
	}
}

void SaveClientSettings(int client)
{
	char buffer[256];

	FormatCookieSkins(client, buffer, sizeof(buffer));
	SetClientCookie(client, g_hCookie, buffer);
}

void FormatCookieSkins(int client, char[] buffer, int maxlength)
{
	for(int i; i < MAX_SAVED_SKINS; i++)
	{
		if(!SkinGet(Clients[client].Skins[i]))
			continue;

		StrCat(buffer, maxlength, Skin.Identifier);
		StrCat(buffer, maxlength, ";");
	}

	if(buffer[0])
		buffer[strlen(buffer) - 1] = 0;
}

stock int GetClientRandomSkin(int client)
{
	int count;
	int skins[MAX_SAVED_SKINS];
	int team = GetClientTeam(client);

	for(int i; i < MAX_SAVED_SKINS; i++)
	{
		if(!SkinGet(Clients[client].Skins[i]) || (Skin.Team != 1 && Skin.Team != team))
			continue;
			
		skins[count++] = Clients[client].Skins[i];
	}

	int skin = count ? skins[GetRandomInt(0, count - 1)]:-1;
	return skin;
}

void CheckClientGroupSkins(int client)
{
	int length = GroupList.Length;

	for(int i; i < length; i += 2)
	{
		if(IsClientHaveGroupFlags(client, i))
		{
			return;
		}
	}
	// У игрока нет ни одного флага который давал бы доступ к группе скинов. Дотвидули.
	Clients[client].Flags = 0;
}

void GetClientCookieSkins(int client)
{
	int count, skinID;
	char buffer[256]; // Строка идентификаторов скинов, разделенных символом ;
	char buffers[MAX_SAVED_SKINS][32]; // Массив с разделенными идентификаторами скинов
	GetClientCookie(client, g_hCookie, buffer, sizeof(buffer));
	if(buffer[0] && (count = ExplodeString(buffer, ";", buffers, MAX_SAVED_SKINS, 32)))
	{
		for(int i = 0; i < count; i++)
		{
			skinID = GetSkinIdByKey(buffers[i]);
			if(SkinGet(skinID))
			{
				if(skinID == -1 || Clients[client].GetSkinPosition(skinID) == -1)
				{
					Clients[client].Skins[i] = skinID;
				}
			}
		}
	}
	else
	{
		Clients[client].ClearSkins();
	}
}

// У клиента есть доступ к этому скину?
stock bool IsClientSkinAccess(int client)
{
	return IsClientSkinAccessBySteamId(client) || IsClientSkinAccessByFlag(client);
}

// У клиента есть доступ к скину, прописанному по стим айди
bool IsClientSkinAccessBySteamId(int client)
{
	if(!GetClientSkinsBySteamId(client))
		return false;

	SkinData skin;
	for(int i; i < SkinsCount * CLIENT_SKIN_DATA_SIZE; i += CLIENT_SKIN_DATA_SIZE)
	{
		if(CachedClientSkins[i] != -1 && SkinGet2(CachedClientSkins[i], skin) && strcmp(Skin.Identifier, skin.Identifier, false) == 0)
		{
			return true;
		}
	}
	return false;
}

// У клиента есть доступ к скину, прописанному по флагу
bool IsClientSkinAccessByFlag(int client)
{
	// -1 - Флаги еще не были получены в OnClientPostAdminCheck
	// 0 - У игрока нет флагов по которым мог быть доступ к скину(-ам)
	if(Clients[client].Flags <= 0)
		return false;

	SkinData skin;
	int[] skins = new int[SkinsCount];
	int length = GroupList.Length;
	for(int i; i < length; i += 2)
	{
		if(IsClientHaveGroupFlags(client, i))
		{
			GroupList.GetArray(i + 1, skins, SkinsCount);
			for(int j; j < SkinsCount; j++)
			{
				if(skins[j] != -1 && SkinGet2(skins[j], skin) && strcmp(Skin.Identifier, skin.Identifier, false) == 0)
				{
					return true;
				}
			}
		}
	}
	return false;
}

bool GetClientSkinsBySteamId(int client)
{
	if(ClientOfCachedSkins == client)
		return true;

	if (Clients[client].SteamID[0] && Players.GetArray(Clients[client].SteamID, CachedClientSkins, SkinsCount * CLIENT_SKIN_DATA_SIZE))
	{
		ClientOfCachedSkins = client;
		return true;
	}

	return false;
}

void CheckCacheClientSkins(int client)
{
	if(ClientOfCachedSkins == client)
	{
		ClientOfCachedSkins = 0;
	}
}