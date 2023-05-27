void LoadData()
{
	KeyValues kv = GetDataFile();

	if(!kv)
		return;

	ParseSkins(kv);
	ParseClients(kv);
	ParseGroups(kv);

	delete kv;
}

KeyValues GetDataFile()
{
	char buffer[PLATFORM_MAX_PATH];
	KeyValues kv = new KeyValues("Skins");
	BuildPath(Path_SM, buffer, sizeof(buffer), "data/personal_skins.cfg");

	if(!kv.ImportFromFile(buffer))
	{
		SetFailState("[Personal Skins] Config file \"%s\" doesnt exists...", buffer);
		return null;
	}

	return kv;
}

void ParseSkins(KeyValues kv)
{
	if(!kv.JumpToKey("Skins") || !kv.GotoFirstSubKey())
		SetFailState("Cant read \"Skins\" section");

	do
	{
		kv.GetSectionName(Skin.Identifier, sizeof(Skin.Identifier));
		kv.GetString("name", Skin.Name, sizeof(Skin.Name));
		kv.GetString("model", Skin.Model, sizeof(Skin.Model));
		Skin.Team = kv.GetNum("team", 1);
		Skin.SmartDownload = !!(kv.GetNum("smart_download", 1));
		Skins.SetArray(Skin.Identifier, Skin, sizeof(Skin), true);
	}
	while(kv.GotoNextKey());

	kv.Rewind();

	SkinsSnapshot = Skins.Snapshot();
	SkinsCount = SkinsSnapshot.Length;
}

void ParseClients(KeyValues kv)
{
	if(!kv.JumpToKey("Clients") || !kv.GotoFirstSubKey())
		SetFailState("Cant read \"Clients\" section");

	char buffer[256];
	char buffer2[256];
	int count;
	int expired;
	int time = GetTime();
	GroupList = new ArrayList(ByteCountToCells(SkinsCount * 4));
	do
	{
		if(!kv.GotoFirstSubKey(false))
			continue;
		
		do
		{
			kv.GetSectionName(buffer2, sizeof(buffer2));
			kv.GetString(NULL_STRING, buffer, sizeof(buffer));
			if(strcmp(buffer2, "0", false) && strcmp(buffer2, "model", false))
			{
				expired = DateToTimestamp(buffer2);
				if(expired > time)
				{
					CachedClientSkins[count++] = GetSkinIdByKey(buffer);
					CachedClientSkins[count++] = expired;
				}
			}
			else
			{
				CachedClientSkins[count++] = GetSkinIdByKey(buffer);
				CachedClientSkins[count++] = 0;
			}


		}
		while(kv.GotoNextKey(false));

		kv.GoBack();
		kv.GetSectionName(buffer, sizeof(buffer));
		
		if(count)
		{
			for(int i = count; i < SkinsCount * CLIENT_SKIN_DATA_SIZE; i += CLIENT_SKIN_DATA_SIZE)
				CachedClientSkins[i] = -1;

			count = 0;
			Players.SetArray(buffer, CachedClientSkins, SkinsCount * CLIENT_SKIN_DATA_SIZE, true);
		}
	}
	while(kv.GotoNextKey());

	kv.Rewind();
}

void ParseGroups(KeyValues kv)
{
	if(!kv.JumpToKey("Groups") || !kv.GotoFirstSubKey())
		SetFailState("Cant read \"Groups\" section");

	char buffer[256];
	int flags;
	int[] skins = new int[SkinsCount];
	int count;
	do
	{
		if(!kv.GotoFirstSubKey(false))
			continue;
	
		do
		{
			kv.GetSectionName(buffer, sizeof(buffer));
			if(strcmp(buffer, "flags", false))
			{
				kv.GetString(NULL_STRING, buffer, sizeof(buffer));
				skins[count++] = GetSkinIdByKey(buffer);
			}

		}
		while(kv.GotoNextKey(false));

		kv.GoBack();
		kv.GetString("flags", buffer, sizeof(buffer));

		flags = ReadFlagString(buffer);
			
		if(flags)
		{
			for(int i = count; i < SkinsCount; i++)
				skins[i] = -1;

			GroupList.Push(flags);
			GroupList.PushArray(skins, SkinsCount);
		}

		count = 0;
	}
	while(kv.GotoNextKey());
	
	kv.Rewind();
}