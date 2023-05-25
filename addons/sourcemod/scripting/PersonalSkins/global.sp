enum struct ClientData
{
	int Skins[MAX_SAVED_SKINS];
	int Flags;
	char SteamID[40];
	ArrayList SkinList;
	void Clear()
	{
		delete this.SkinList;
		this.ClearSkins();
		this.Flags = -1;
		this.SteamID[0] = 0;
	}
	int GetSkins_Count()
	{
		int count;
		for(int i = 0; i < MAX_SAVED_SKINS; i++)
		{
			if(this.Skins[i] != -1)
				count++;
		}
		return count;
	}
	int GetSkinFree()
	{
		for(int i = 0; i < MAX_SAVED_SKINS; i++)
		{
			if(this.Skins[i] == -1)
				return i;
		}
		return -1;

	}
	int GetSkinSameCount(int skin)
	{
		if(skin == -1)
			return 0;
		
		int count;
		for(int i = 0; i < MAX_SAVED_SKINS; i++)
		{
			if(this.Skins[i] == skin)
				count++;
		}
		return count;
	}
	int GetSkinPosition(int skin)
	{
		if(skin == -1)
			return -1;

		for(int i = 0; i < MAX_SAVED_SKINS; i++)
		{
			if(this.Skins[i] == skin)
				return i;
		}
		return -1;
	}
	void ClearSkins()
	{
		for(int i = 0; i < MAX_SAVED_SKINS; i++)
		{
			this.Skins[i] = -1;
		}
	}
}

enum struct SkinData
{
	char Identifier[32];
	char Name[256];
	char Model[256];
	int Team;
	bool IsPrecached;
	bool SmartDownload;
}

bool Late;

// Куки для хранения включенных скинов игрока. Строка имеет следующий формат: "skin1;skin2;skin3;skin4"
Handle g_hCookie;

// Количества скинов в секции "Models" главного конфига
int SkinsCount;

int GroupSkins[MAX_GROUP_SKINS];

// Постоянно изменяющиеся переменные. Первая хранит индекс кеш-игрока, Вторая хранит индексы скинов по SteamID
int ClientOfCachedSkins;
int CachedClientSkins[MAX_SKINS * CLIENT_SKIN_DATA_SIZE];

// Игроки
ClientData Clients[MAXPLAYERS + 1];

// Скины
StringMap Skins;
StringMapSnapshot SkinsSnapshot;

// Скины игроков по стим айди
StringMap Players;

// Скины по флагу(ам)
ArrayList GroupList;

// Постоянно изменяющаяся глобальная переменная
SkinData Skin;

void GlobalVarsInit()
{
	Skins = new StringMap();
	Players = new StringMap();
	g_hCookie = RegClientCookie("PSkin", "", CookieAccess_Private);
}