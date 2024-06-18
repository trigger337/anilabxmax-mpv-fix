# anilabxmax-mpv-fix
A wrapper script for AniLabX MAX to fix stuff like missing chunks when playing back HLS content in MPV\
It's pretty rough and does a lot of stuff it doesn't need to do, the author assumes the user can make it work as required by said user

# How to use
Make sure you have `mitmproxy` installed, this script relies on `mitmdump`\
Put the script in the same place where the AniLab executable is located, make the script executable: `chmod +x ./mpv_wrapper.sh` and run it\
Add a custom player argument to make sure MPV connects to proxy `--http-proxy=http://localhost:8080` in player settings tab in AniLab\
![image](https://github.com/trigger337/anilabxmax-mpv-fix/assets/72268042/5f05d6cc-2155-4ce7-8004-3d917a53f3dc)

# How does this work?
The script links itself as `mpv` in the current directory, adds the directory to PATH before evetything else and runs AniLab\
Now when AniLab tries to run `mpv`, it runs the link because it's the first in PATH\
The script checks if it's run as `mpv` by a program which contains `anilab` in its name and if it is, first runs `mitmdump` and after that runs actual `/usr/bin/mpv`

# Do I need this?
No, unless MPV often skips chunks of videos when you watch HLS content (Anilibria for example)
