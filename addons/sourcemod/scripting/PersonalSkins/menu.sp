void MenuInit()
{
	RegConsoleCmd("sm_skins", Skins_Menu);
}

public Action Skins_Menu(int client, int args)
{
	SkinsMenu(client);
	return Plugin_Handled;
}

void SkinsMenu(int client, int startItem = 0)
{
	if(!SkinsEnabled)
	{
		PrintToChat(client, "%t", "Skins are disabled");
		return;
	}
	
	SetGlobalTransTarget(client);

	Menu menu = new Menu(SkinsMenuHandler);
	menu.SetTitle("%t", "Title");

	int count, count2;
	int[] skins = new int[SkinsCount];
	int[] skinsMenu = new int[SkinsCount];
	char buffer[256];
	char buffer2[256];

	if(GetClientSkinsBySteamId(client))
	{
		for(int i; i < SkinsCount * CLIENT_SKIN_DATA_SIZE; i += CLIENT_SKIN_DATA_SIZE)
		{

			if(CachedClientSkins[i] == -1)
				break;

			if(!SkinGet(CachedClientSkins[i]))
				continue;

			FormatEx(buffer, sizeof(buffer), "%s (%s)", Skin.Name, Skin.Team == 1 ? "T & CT":Skin.Team == 2 ? "T":"CT");

			if(!Skin.IsPrecached)
				Format(buffer, sizeof(buffer), "%s (%t)", buffer, "Next map");
			
			if(!CachedClientSkins[i + 1])
			{
				Format(buffer, sizeof(buffer), "%s (%t)", buffer, "Permanently");
			}
			else
			{
				int left = CachedClientSkins[i + 1] - GetTime();
				if(left > 0)
				{
					FormatExpiredTime(buffer2, sizeof(buffer2), left);
					Format(buffer, sizeof(buffer), "%s (%s)", buffer, buffer2);
				}
				
			}

			if(Clients[client].GetSkinPosition(CachedClientSkins[i]) != -1)
				Format(buffer, sizeof(buffer), "%s [✔]", buffer);

			IntToString(CachedClientSkins[i], buffer2, sizeof(buffer2));
			menu.AddItem(buffer2, buffer);
			skinsMenu[count++] = CachedClientSkins[i];
		}
	}
	if(Clients[client].Flags > 0)
	{
		int length = GroupList.Length;
		for(int i; i < length; i += 2)
		{
			if(IsClientHaveGroupFlags(client, i))
			{
				GroupList.GetArray(i + 1, skins, SkinsCount);
				for(int j; j < SkinsCount; j++)
				{
					if(skins[j] == -1)
						break;

					if(ArrayFindValue(skinsMenu, count, skins[j]) != -1)
						continue;
						
					if(!SkinGet(skins[j]))
						continue;

					IntToString(skins[j], buffer2, 32);
					FormatEx(buffer, sizeof(buffer), "%s (%s)", Skin.Name, Skin.Team == 1 ? "T & CT":Skin.Team == 2 ? "T":"CT");

					if(!Skin.IsPrecached)
						Format(buffer, sizeof(buffer), "%s (%t)", buffer, "Next map");
						
					if(Clients[client].GetSkinPosition(skins[j]) != -1)
						Format(buffer, sizeof(buffer), "%s [✔]", buffer);

					menu.AddItem(buffer2, buffer);
					count2++;
				}
			}
		}
	}
	if(!count && !count2)
	{
		FormatEx(buffer, sizeof(buffer), "%t", "No skins");
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);
	}
	menu.DisplayAt(client, startItem, 0);
}

public int SkinsMenuHandler(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char buffer[256];
			menu.GetItem(item, buffer, sizeof(buffer));
			int skinID = StringToInt(buffer);
			switch(ToggleClientSavedSkin(client, skinID))
			{
				case -1:
				{
					LogError("ToggleClientSavedSkin");
				}
				case 0:
				{
					if(SkinGet(skinID))
					{
						GetEntPropString(client, Prop_Data, "m_ModelName", buffer, sizeof(buffer));
						if(!strcmp(Skin.Model, buffer, false))
						{
							SetClientSkin(client, _, false);
						}
					}
				}
				case 1:
				{
					SetClientSkin(client, skinID, false);
				}

			}
			SkinsMenu(client, menu.Selection);
			SaveClientSettings(client);
		}
	}

	return 0;
}