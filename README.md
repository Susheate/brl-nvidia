# brl-nvidia
NVIDIA driver manager for Bedrock Linux.

# Usage
brl-nvidia [argument] [argument]

**install** [stratum] :
Install the drivers to the given stratum.
Specifying "all" or not giving any argument will install the drivers to every stratum.

Usage example :

Install the driver on a cachyos stratum.
```
sudo brl-nvidia install cachyos
```
  *Note that this example and examples below assume that the script is in your $PATH (which can be done by using*`sudo bash path_to_brl-nvidia install-script`*).*

**remove** [stratum] :
Remove drivers from the given stratum.

Usage example :

Remove drivers on a cachyos stratum.
```
sudo brl-nvidia remove cachyos
```

**update**
Update NVIDIA drivers on strata providing the userspace drivers. *Note : the bedrock, init and bpt stratum aren't affected.*

Usage example :
```
sudo brl-nvidia update
```

# Installation

The script determines the kernel driver's version from your init stratum in order to prevent version mismatch between the said kernel driver and userspace drivers, therefore preventing the drivers from not working.
**Thus, the user needs to have the NVIDIA drivers installed on their init stratum, preferably via package manager.**

Two options are possible : downloading the script and using it on the go, or referencing the script in your $PATH **which allows using the script from anywhere with the `brl-nvidia` command**.
The second option can be easily achieved by using :
```
sudo bash path_to_brl-nvidia install-script
```
This will make a copy of the script into your init stratum's /usr/bin directory.
