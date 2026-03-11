# Ananicy-cpp-rules for CachyOS
This is a ananicy-cpp-rules collection for ananicy-cpp maintained by the CachyOS team and the community.

## Ananicy-cpp & ananicy-cpp-rules
- **[ananicy-cpp](https://gitlab.com/ananicy-cpp/ananicy-cpp)** - daemon that automatically adjusts the nice levels of processes.
- **ananicy-cpp-rules** - list of rules used to assign specific nice values to specific processes.
> The nice value determines the priority of a process, with higher values indicating lower priority and making the process "nicer" to other processes. By default, on Linux workstations, the nice value is set to 0.

## How to contribute

You can add your favorite games, apps, and more. Any help would be greatly appreciated!  
**For example, let's say you want to add a game:**
1. Go to [00-default](https://github.com/CachyOS/ananicy-rules/tree/master/00-default)
2. Go to [Games](https://github.com/CachyOS/ananicy-rules/tree/master/00-default/Games)
3. Navigate to the desired folder depending on:
	- Game is meant to be ran under with Proton: `ẁine_proton` - *Open the corresponding file depending on the letter.*
	- Provides a native version for Linux: `linux-native` - *Open the corresponding file depending on the letter.*
4. Open the corresponding file depending on the letter.
5. Follow the examples from below.

### Examples of rules
The **first example** is simple. In the **second example**, it is different because some games generate multiple processes. In such cases, you need to add all the processes related to the game.

#### 1. Example rule for Just Cause 2

```
# https://store.steampowered.com/app/8190/Just_Cause_2/
{ "name": "JustCause2.exe", "type": "Game" }
```

#### 2. Example rules for The Outer Worlds

```
# https://store.steampowered.com/app/578650/The_Outer_Worlds/
{ "name": "Indiana-Win64-Shipping.exe", "type": "Game" }
{ "name": "TheOuterWorlds.exe", "type": "Game" }
```

#### 3. Example rules for Portal 2 which is Linux native game

```
# https://store.steampowered.com/app/620/Portal_2/
{ "name": "portal2_linux", "type": "Game" }
```

### <u>You can also contribute by opening an [issue](https://github.com/CachyOS/ananicy-rules/issues) and providing information about the application </u>
**Make sure the app is not already in the repository before opening an issue.**
## How to find out proper process name?
Here is a list of tools
### CLI
- [htop](https://htop.dev/)
- [btop](https://github.com/aristocratos/btop)
### GUI
- System Monitor [KDE Plasma](https://apps.kde.org/plasma-systemmonitor/) or [GNOME](https://help.gnome.org/users/gnome-system-monitor/)

**Don't use absolute paths for the executables. Process name alone is enough.**

## [GameMode](https://github.com/FeralInteractive/gamemode) + [ananicy-cpp](https://gitlab.com/ananicy-cpp/ananicy-cpp) = bad idea
GameMode and ananicy-cpp both adjust the nice levels of processes. However, combining both tools is not recommended, and we strongly advise against doing so.
