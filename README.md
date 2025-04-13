# 🔥 COAL 🔥  
**Coordinate-based Orchestration and Automation for Linux**  

*"When you need to burn it down and win by default, throw some COAL on the fire!"*  
```bash
# To Build Coordinate
# MUST BE RAN FROM coordinate-root directory!!!!!
./build_coordinate.sh
```

```bash
# this part will handle everything in initial and put the firewall on all hosts
# Also creates the config
./coal -t <ips> -p <pass>
```

```bash
# -U uses the config.json file
# second part runs scripts on all hosts from local machine
./coordinate -U /path/to/scripts
```
