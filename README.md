# yajdf
## yet another java duplicates finder
### Description
Every man an his dog has written a duplicates finder and many existing tools (such as fdupes) do a fantastic job of finding duplicates.
But now that I have a list of duplicates how do I easily clean them up?  Do I randomly delete one of the files?

This program attempts to create a rules parser to delete duplicate files.

### Usage
Run with a java vm.

`java -jar yajdf.jar ~/Music`

After some time a prompt appears.
The number indicates the number of duplicate groups.
Display the list of duplicates with the `print` command.

Select duplicate groups with the `group` command followed by a colon and then the matching method, this command operates like grep and allows groups which match while ignoring those which don't. The Matching method is made up of the following capitalised keywords `Any` or `All` or `One` followed by `Name` or `Parent` or `Canonical`
finally  `Contains` or `Equals` or `Matches` or `StartsWith` then another colon and the matching string.

eg `group:AnyNameContains:jpg` is a valid matching command.

`Any` means any file in the group may match
`All` means all files must match
`One` means exactly one file must match

`Name` is the filename part of the path
`Parent` is the directory name of the path
`Canonical` is the full path.

`Contains` means the matching string is part of the pathname.
`Equals` means the matching string is exactly the same as the pathname.
`StartsWith` means the matching string is found at the start of the pathname.
`Matches` is a regex match of the pathname.

Selecting single files in a group is performed with the `filter` command, then followed by the same matching command as found in the group mathcing excluding `All` Create rules that select less than the number of total files in a group.

```
java -jar yajdf.jar ~/Music
-- SCAN --
scanning... 0
scanning... 618
scanning... 490
scanning... 246
Files Remaining to Compare: 469
-- COMPARE --
comparing... 0/469 0
comparing... 300/469 81
101> group:AnyNameContains:jpg
2> print
/mnt/c/Users/mheath/Music/Compilations/One Perfect Day/AlbumArt_{B67670CF-FAA6-48FF-BFA4-CC8D6FDACAAE}_Small.jpg : /mnt/c/Users/mheath/Music/Compilations/One Perfect Day/AlbumArtSmall.jpg
/mnt/c/Users/mheath/Music/808 State (Singles)/1991 - In Yer Face (Single)/Folder.jpg : /mnt/c/Users/mheath/Music/808 State/1991 - In Yer Face (Single)/Folder.jpg
2> filter:AnyNameContains:AlbumArt_
1> print
/mnt/c/Users/mheath/Music/Compilations/One Perfect Day/AlbumArt_{B67670CF-FAA6-48FF-BFA4-CC8D6FDACAAE}_Small.jpg
1> delete
Deleting... /mnt/c/Users/mheath/Music/Compilations/One Perfect Day/AlbumArt_{B67670CF-FAA6-48FF-BFA4-CC8D6FDACAAE}_Small.jpg
```
