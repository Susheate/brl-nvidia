#!/bin/bash

initStratum=$(brl which 1)
usedDir="/bedrock/strata/${initStratum}/var/tmp" # Change later
driverVersion=$(nvidia-smi | grep  "Driver Version" | cut -d ' ' -f 3)
targetedStratum=$2

if [ $(id -u) != 0 ]; then echo "You must run brl-nvidia as root."; exit 2; fi

function downloadDrivers() {
	if [[ ! -e "${usedDir}/brl-nvidia/nvidia-${driverVersion}.run" ]] || [[ $1 == "force" ]]; then
		curl https://us.download.nvidia.com/XFree86/Linux-x86_64/$driverVersion/NVIDIA-Linux-x86_64-$driverVersion.run -o $usedDir/brl-nvidia/nvidia-$driverVersion.run
	fi
}

function checksumReDownloadDrivers() {
	if [[ $? == "2" ]]; then
		echo "Re-downloading the drivers..."
		downloadDrivers
		installDrivers
	fi
}

function installDrivers {
	downloadDrivers
	if [[ $targetedStratum == "all" ]] || [[ $targetedStratum == "" ]]; then
		for stratum in $(brl list)
		do
			if [[ $stratum != $initStratum ]] && [[ $stratum != "bedrock" ]] && [[ $stratum != "bpt" ]]; then echo "${stratum}"; strat -r $stratum sh $usedDir/brl-nvidia/nvidia-$driverVersion.run --no-kernel-modules; fi
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

if [[ $1 == "install" ]]; then
	installDrivers
elif [[ $1 == "remove" ]]; then
	strat -r $targetedStratum nvidia-uninstall
elif [[ $1 == "install-script" ]]; then
	cp $0 /bedrock/strata/${initStratum}/bin/brl-nvidia
	chmod +x /bedrock/strata/${initStratum}/bin/brl-nvidia
elif [[ $1 == "update-script" ]]; then
	curl https://raw.githubusercontent.com/Susheate/brl-nvidia/refs/heads/main/brl-nvidia.sh -o $usedDir/brl-nvidia/brl-nvidia.sh
	cp $usedDir/brl-nvidia/brl-nvidia.sh /bedrock/strata/${initStratum}/bin/brl-nvidia
	chmod +x /bedrock/strata/${initStratum}/bin/brl-nvidia
	echo "Done"
fi
