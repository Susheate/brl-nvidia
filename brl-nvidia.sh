#!/bin/bash

if [ $(id -u) != 0 ]; then echo "brl-nvidia requires root."; exit 1; fi

initStratum=$(brl which 1)
usedDir="/bedrock/strata/${initStratum}/var/tmp"
driverVersion=$(nvidia-smi | grep "KMD Version" | cut -d " " -f 3)
targetedStratum=$2


function downloadDrivers() {
	if [[ ! -e "${usedDir}/brl-nvidia/nvidia-${driverVersion}.run" ]] || [[ $1 == "force" ]]; then
		curl https://us.download.nvidia.com/XFree86/Linux-x86_64/$driverVersion/NVIDIA-Linux-x86_64-$driverVersion.run -o $usedDir/brl-nvidia/nvidia-$driverVersion.run
	fi
}

function integrityCheck() {
	if [[ $? == "2" ]]; then
		echo "Re-downloading the drivers..."
		downloadDrivers force
		installDrivers
	fi
}

function installDrivers() {
	downloadDrivers
	if [[ $1 == "all" ]] || [[ $1 == "" ]]; then
		for stratum in $(brl list); do
			if [[ $stratum != $initStratum ]] && [[ $stratum != "bedrock" ]] && [[ $stratum != "bpt" ]]; then
				echo "${stratum}"
				strat -r $stratum sh $usedDir/brl-nvidia/nvidia-$driverVersion.run --no-kernel-modules
			fi
			integrityCheck
		done
	else
		strat -r $1 sh $usedDir/brl-nvidia/nvidia-$driverVersion.run --no-kernel-modules
		integrityCheck
	fi
}

function removeDrivers() {
	if [[ $1 == "all" ]] || [[ $1 == "" ]]; then
		for stratum in $(brl list); do
			if [[ $stratum != $initStratum ]] && [[ $stratum != "bedrock" ]] && [[ $stratum != "bpt" ]]; then
				echo -e "\e[36m${stratum}\e[0m"
				strat -r $stratum nvidia-uninstall
			fi
		done
	else
		strat -r $1 nvidia-uninstall
	fi
}

function updateDrivers() {
	downloadDrivers
	for stratum in $(brl list); do
		if [[ $stratum != $initStratum ]] && [[ $stratum != "bedrock" ]] && [[ $stratum != "bpt" ]] && [[ $(strat $stratum nvidia-smi | grep "KMD Version" | cut -d " " -f 3) == $driverVersion ]]; then
			echo "${stratum}"
			strat -r $stratum sh $usedDir/brl-nvidia/nvidia-$driverVersion.run --no-kernel-modules --ui=none --no-questions --no-x-check
		fi
		integrityCheck
	done
}

if [[ ! -e "${usedDir}/brl-nvidia" ]]; then
	mkdir $usedDir/brl-nvidia
fi

case $1 in
	"install")
		installDrivers $targetedStratum
		;;
	"remove")
		removeDrivers $targetedStratum
		;;
	"update")
		updateDrivers
		;;
	"install-script")
		cp $0 /bedrock/strata/${initStratum}/bin/brl-nvidia
		chmod +x /bedrock/strata/${initStratum}/bin/brl-nvidia
		;;
	"update-script")
		curl https://raw.githubusercontent.com/Susheate/brl-nvidia/refs/heads/main/brl-nvidia.sh -o $usedDir/brl-nvidia/brl-nvidia.sh
		cp $usedDir/brl-nvidia/brl-nvidia.sh /bedrock/strata/${initStratum}/bin/brl-nvidia
		chmod +x /bedrock/strata/${initStratum}/bin/brl-nvidia
		echo -e "\n\e[36mDone\e[0m"
		;;
esac
