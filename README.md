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
  *Note that this example assumes that the script is in your PATH (which can be done by using* ```sudo bash path_to_brl-nvidia install-script```*).*

**remove** [stratum] :
Remove drivers on the given stratum.


The script determines the drivers version from your init stratum in order to prevent version mismatch, therefore preventing the drivers from not working.
Thus, the user needs to have drivers installed on their init stratum, preferably via package manager.
