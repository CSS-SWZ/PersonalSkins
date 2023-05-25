void AddToDownloadFromDirectory(const char[] dir)
{
	DirectoryListing directory = OpenDirectory(dir);
	
	if(!directory)
		return;
	
	char file[256];
	char path[256]; 
	FileType fileType;
	while (directory.GetNext(file, sizeof(file), fileType))
	{
		switch(fileType)
		{
			case FileType_File:
			{
				if(IsValidFile(file))
				{
					FormatEx(path, sizeof(path), "%s/%s", dir, file);
					AddFileToDownloadsTable(path);

				}
			}
			case FileType_Directory:
			{
				if(strcmp(file, ".", true) && strcmp(file, "..", true))
				{
					FormatEx(path, sizeof(path), "%s/%s", dir, file);
					AddToDownloadFromDirectory(path);
				}
			}
		}
	}
	delete directory;
}

bool IsValidFile(const char[] s)
{
	int length = strlen(s);
	int i = length;
	while (--i > -1)
	{
		if (s[i] == '.') {
			return i > 0 && ((i+1) != length) && strcmp(s[i+1], "ztmp", false) && strcmp(s[i+1], "bz2", false);
		}
	}
	return false;
}

stock int ArrayFindValue(int[] values, int size, int value)
{
	for(int i = 0; i < size; i++)
	{
		if(values[i] == value)
			return i;
	}
	
	return -1;
}

bool IsClientHaveGroupFlags(int client, int group)
{
	int flags = GroupList.Get(group);

	if(Clients[client].Flags & flags == flags)
		return true;

	return false;
}

stock int DateToTimestamp(const char[] date) 
{
	char buffer[64];
	strcopy(buffer, sizeof(buffer), date);
		
	ReplaceString(buffer, sizeof( buffer ), "/", " " );
	ReplaceString(buffer, sizeof( buffer ), ".", " " );
		
	char time[3][6];
	ExplodeString(buffer, " ", time, sizeof(time), sizeof(time[]));
		
	int year = StringToInt(time[2]);
	int month = StringToInt(time[1]);
	int day = StringToInt(time[0]);
	int hour;
	int minute;
	int second;
		
	return TimeToUnix(year, month, day, hour, minute, second, UT_TIMEZONE_SERVER);
} 

void FormatExpiredTime(char[] buffer, int maxlength, int left)
{
	static int values[] = {1, 60, 3600, 86400};
	static char names[][] = {"secs", "mins", "hours", "days"};
	
	for(int i = sizeof(values) - 1; i >= 0; i--)
	{
		if(left > values[i])
		{
			FormatEx(buffer, maxlength, "%t: %t", "Left", names[i], left / values[i]);
			return;
		}
	}
}