# brl-nvidia
NVIDIA driver manager for Bedrock Linux.

# Installation

The script determines the kernel driver's version ~~from the stratum providing the kernel~~ (At least that's how it should be, currently the script uses what the user tells it to use) in order to prevent version mismatch between kernel drivers and userspace drivers, therefore preventing the drivers from not working.
**Thus, the user needs to have the NVIDIA drivers installed on their stratum providing the kernel, preferably via package manager.**

Two options are possible : downloading the script and using it on the go, or referencing the script in your $PATH **which allows using the script from anywhere with the `brl-nvidia` command**.
The latter can be easily achieved by using :
```
$ curl -f https://raw.githubusercontent.com/Susheate/brl-nvidia/refs/heads/main/brl-nvidia.sh -o brl-nvidia.sh && su -c 'bash brl-nvidia.sh install-script'
```
This will fetch the script from this repository then make a copy of the script into your kernel-providing stratum's /usr/bin directory.

## Updating
*This assumes you've installed the script through `install-script`.*

To update the script, run the following :
```
# brl-nvidia update-script
```

# Usage

## install [stratum] :
Install the drivers to the given stratum.
Specifying "all" will install the drivers to every stratum.

Usage example :

Install the driver on a arch stratum.
```
# brl-nvidia install arch
```
  *Note that this example and examples below assume that the script is in your $PATH (which can be done by using*`# bash path_to_brl-nvidia install-script`*).*

## remove [stratum] :
Remove drivers from the given stratum.

Usage example :

Remove drivers on a arch stratum.
```
# brl-nvidia remove arch
```

## update :
Update NVIDIA drivers on strata providing the userspace drivers. *Note : the bedrock, kernel providing and bpt stratum aren't affected.*

Usage example :
```
# brl-nvidia update
```
