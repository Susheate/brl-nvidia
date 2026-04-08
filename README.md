# brl-nvidia
nVidia driver manager for Bedrock Linux.

# Usage
brl-nvidia [argument] [argument]

**install** [stratum] :
Install the drivers to the given stratum.
Specifying "all" will install the drivers to all the strata.
- Also useful when updating

**remove** [stratum] :
Remove drivers on the given stratum.


The script determines the drivers version from your init stratum in order to prevent version mismatch, therefore preventing the drivers from not working.
Thus, the user needs to have drivers installed on their init stratum, preferably via package manager.
