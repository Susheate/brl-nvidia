#!/bin/bash

initStratum=$(brl which 1)
usedDir="/bedrock/strata/${initStratum}/var/tmp" # Change later
driverVersion=$(nvidia-smi | grep  "Driver Version" | cut -d ' ' -f 3)
targetedStratum=$2

function downloadDrivers() {
	curl https://us.download.nvidia.com/XFree86/Linux-x86_64/$driverVersion/NVIDIA-Linux-x86_64-$driverVersion.run -o $usedDir/brl-nvidia/nvidia-$driverVersion.run
}

function checksumReDownloadDrivers() {
	if [[ $? == "2" ]]; then
		echo "Re-downloading the drivers..."
		downloadDrivers
		installDrivers
	fi
}

function installDrivers {
	
	if [[ ! -e "${usedDir}/brl-nvidia/nvidia-${driverVersion}.run" ]]; then downloadDrivers; fi
	if [[ $targetedStratum == "all" ]]; then
		for stratum in $(brl list)
		do
			if [[ $stratum != $initStratum ]] && [[ $stratum != "bedrock" ]]; then echo "${stratum}"; strat -r $stratum sh $usedDir/brl-nvidia/nvidia-$driverVersion.run --no-kernel-modules; fi
			checksumReDownloadDrivers
		done
	else
		strat -r $targetedStratum sh $usedDir/brl-nvidia/nvidia-$driverVersion.run --no-kernel-modules
		checksumReDownloadDrivers
	fi
}

if [[ ! -e "${usedDir}/brl-nvidia" ]]; then
	mkdir $usedDir/brl-nvidia
fi

if [ $1 == "install" ]; then
	installDrivers
elif [[ $1 == "remove" ]]; then
	strat -r $targetedStratum nvidia-uninstall
fi
