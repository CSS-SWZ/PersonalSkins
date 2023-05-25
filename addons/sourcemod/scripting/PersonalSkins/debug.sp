#if defined DEBUG
File LogFile;

stock void _BuildLogFile()
{
	char buffer[256];
	BuildPath(Path_SM, buffer, sizeof(buffer), "logs/PersonalSkins/");

	if(!DirExists(buffer) && !CreateDirectory(buffer, 511))
		SetFailState("Cant create directory \"%s\"", buffer);

	FormatTime(buffer, 367, "logs/PersonalSkins/PersonalSkins_%Y-%m-%d.log");
	BuildPath(Path_SM, buffer, sizeof(buffer), buffer);

	if((LogFile = OpenFile(buffer, "a+")) == null)
		SetFailState("Cant create/open \"%s\"", buffer);
}

stock void _DebugMessage(const char[] format, any ...)
{
	int len = strlen(format) + 255;
	char[] buffer = new char[len];
	VFormat(buffer, len, format, 2);
	Format(buffer, len, "%f - %s", GetEngineTime(), buffer);
	LogToOpenFile(LogFile, buffer);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetUserFlagBits(i) & (ADMFLAG_RCON | ADMFLAG_ROOT))
		{
			PrintToConsole(i, buffer);
		}
	}
}

stock void _DebugClientMessage(int client, const char[] format, any ...)
{
	if(!Listen[client])
		return;

	int len = strlen(format) + 255;
	char[] buffer = new char[len];
	VFormat(buffer, len, format, 3);
	LogToOpenFile(LogFile, buffer);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetUserFlagBits(i) & (ADMFLAG_RCON | ADMFLAG_ROOT))
		{
			PrintToConsole(i, buffer);
		}
	}
}

#define DebugMessage(%0) _DebugMessage(%0)
#define DebugClientMessage(%0) _DebugClientMessage(%0)
#define BuildLogFile() _BuildLogFile()

#else
#define DebugMessage(%0)
#define DebugClientMessage(%0)
#define BuildLogFile()
#endif