# Ananicy-cpp-rules for CachyOS
This is a ananicy-cpp-rules collection for ananicy-cpp maintained by the CachyOS team.

## Ananicy-cpp & ananicy-cpp-rules
- **[ananicy-cpp](https://gitlab.com/ananicy-cpp/ananicy-cpp)** - daemon that automatically adjusts the nice levels of processes.
- **ananicy-cpp-rules** - list of rules used to assign specific nice values to specific processes.
> The nice value determines the priority of a process, with higher values indicating lower priority and making the process "nicer" to other processes. By default, on Linux workstations, the nice value is set to 0.

## How to contribute
You can add your favorite games, apps, and more. Any help would be greatly appreciated!  
**For example, let's say you want to add a game.**
1. Go to [00-default](https://github.com/CachyOS/ananicy-rules/tree/master/00-default)
2. Go to [games](https://github.com/CachyOS/ananicy-rules/tree/master/00-default/games)
3. Create a new file with the same name as your game, for example, `gamename.rules`

### Examples of rules
The **first example** is simple. In the **second example**, it is different because some games generate multiple processes. In such cases, you need to add all the processes related to the game.

#### 1. [Example rule for Just Cause 2](https://github.com/CachyOS/ananicy-rules/blob/68a0f5f2d83fefb657ac0db8e0c8848609b319e4/00-default/games/wine_proton.rules#L617)
```
# https://store.steampowered.com/app/8190/Just_Cause_2/
{ "name": "JustCause2.exe", "type": "Game" }
```
#### 2. [Example rules for The Outer Worlds](https://github.com/CachyOS/ananicy-rules/blob/68a0f5f2d83fefb657ac0db8e0c8848609b319e4/00-default/games/wine_proton.rules#L1144)
```
# The Outer Worlds https://store.steampowered.com/app/578650
{ "name": "Indiana-Win64-Shipping.exe", "type": "Game"}
{ "name": "TheOuterWorlds.exe", "type": "Game"}
```

#### 3. [Example rules for Portal 2 which is Linux native game](https://github.com/CachyOS/ananicy-rules/blob/68a0f5f2d83fefb657ac0db8e0c8848609b319e4/00-default/games/steam-native.rules#L256)
```
# https://store.steampowered.com/app/620/Portal_2/
{ "name": "portal2_linux", "type": "Game" }
```

## How to find out proper process name?
Here is a list of tools
### CLI
- [htop](https://htop.dev/)
- [btop](https://github.com/aristocratos/btop)
### GUI
- System Monitor [KDE Plasma](https://apps.kde.org/plasma-systemmonitor/) or [GNOME](https://help.gnome.org/users/gnome-system-monitor/)

## [GameMode](https://github.com/FeralInteractive/gamemode) + [ananicy-cpp](https://gitlab.com/ananicy-cpp/ananicy-cpp) = bad idea
GameMode and ananicy-cpp both adjust the nice levels of processes. However, combining both tools is not recommended, and we strongly advise against doing so.
