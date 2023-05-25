void HookEvents()
{
	HookEvent("player_team", OnPlayerTeam);
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_disconnect", OnPlayerDisconnect);
}

public void OnPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(Clients[client].Flags > 0 || Clients[client].SteamID[0])
		RequestFrame(SetClientSkinNextTick, client);
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(Clients[client].Flags > 0 || Clients[client].SteamID[0])
		RequestFrame(SetClientSkinNextTick, client);
}

public void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	Clients[client].Clear();
}