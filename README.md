# Ananicy-cpp-rules for CachyOS
This is a ananicy-cpp-rules collection for ananicy-cpp maintained by the CachyOS team.

## Ananicy-cpp & ananicy-cpp-rules
- **[ananicy-cpp](https://gitlab.com/ananicy-cpp/ananicy-cpp)** - daemon that automatically adjusts the nice levels of processes.
- **ananicy-cpp-rules** - list of rules used to assign specific nice values to specific processes.
> The nice value determines the priority of a process. The higher the value, the lower the priority, making the process 'nicer' to other processes. On Linux workstations, the default nice value is 0.

## [GameMode](https://github.com/FeralInteractive/gamemode) + [ananicy-cpp](https://gitlab.com/ananicy-cpp/ananicy-cpp) = bad idea
GameMode and ananicy-cpp both adjust the nice levels of processes. However, combining both tools is not recommended, and we strongly advise against doing so.
