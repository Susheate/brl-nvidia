#!/bin/bash

if [ $(id -u) != 0 ]; then echo "brl-nvidia requires root."; exit 1; fi

kernelStratum=$(brl which modinfo)
usedDir="/bedrock/strata/$kernelStratum/var/tmp"
KMDVersion=$(modinfo nvidia | grep ^version | awk -F ' ' '{print $2}')
targetedStratum=$2


function downloadDrivers() {
	if [[ ! -e "$usedDir/brl-nvidia/nvidia-$KMDVersion.run" ]] || [[ $1 == "force" ]]; then
		curl https://us.download.nvidia.com/XFree86/Linux-x86_64/$KMDVersion/NVIDIA-Linux-x86_64-$KMDVersion.run -o $usedDir/brl-nvidia/nvidia-$KMDVersion.run
	fi
}

function integrityCheck() {
	if [[ $? == 2 ]]; then
		echo "Re-downloading the drivers..."
		downloadDrivers force
		installDrivers
	fi
}

function installDrivers() {
	downloadDrivers
	if [[ $1 == "all" ]]; then
		for stratum in $(brl list); do
			if [[ $stratum != $kernelStratum ]] && [[ $stratum != "bedrock" ]] && [[ $stratum != "bpt" ]]; then
				echo -e "\e[36mProceeding with\e[36m \e[35m$stratum\e[0m"
				strat -r $stratum sh $usedDir/brl-nvidia/nvidia-$KMDVersion.run --no-kernel-modules -q --ui=none --no-x-check
			fi
			integrityCheck
		done
	else
		strat -r $1 sh $usedDir/brl-nvidia/nvidia-$KMDVersion.run --no-kernel-modules -q --ui=none --no-x-check
		integrityCheck
	fi
}

function removeDrivers() {
	if [[ $1 == "all" ]]; then
		for stratum in $(brl list); do
			if [[ $stratum != $kernelStratum ]] && [[ $stratum != "bedrock" ]] && [[ $stratum != "bpt" ]]; then
				echo -e "\e[36mProceeding with\e[36m \e[35m$stratum\e[0m"
				strat -r $stratum nvidia-uninstall -q --ui=none
			fi
		done
	else
		strat -r $1 nvidia-uninstall -q --ui=none
	fi
}

function updateDrivers() {
	downloadDrivers
	for stratum in $(brl list); do
		strat $stratum nvidia-smi
		if [[ $? == 0 ]] && [[ $(strat $stratum nvidia-smi | grep 'NVIDIA-SMI' | awk -F ' ' '{print $3}') != $KMDVersion ]] && [[ $stratum != $kernelStratum ]] && [[ $stratum != "bedrock" ]] && [[ $stratum != "bpt" ]]; then
			echo -e "\e[36mProceeding with\e[36m \e[35m$stratum\e[0m"
			strat -r $stratum sh $usedDir/brl-nvidia/nvidia-$KMDVersion.run --no-kernel-modules -q --ui=none --no-x-check
		else
			echo -e "\e[36mSkipping\e[36m \e[35m$stratum\e[0m"
		fi
		integrityCheck
	done
}

if [[ ! -e "$usedDir/brl-nvidia" ]]; then
	mkdir $usedDir/brl-nvidia
fi

case $1 in
	"install")
		installDrivers $targetedStratum
		echo -e "\e[36mDone\e[0m"
		;;
	"remove")
		removeDrivers $targetedStratum
		echo -e "\e[36mDone\e[0m"
		;;
	"update")
		updateDrivers
		echo -e "\e[36mDone\e[0m"
		;;
	"install-script")
		cp $0 /bedrock/strata/${kernelStratum}/bin/brl-nvidia
		chmod +x /bedrock/strata/${kernelStratum}/bin/brl-nvidia
		echo -e "\e[36mDone\e[0m"
		;;
	"update-script")
		curl https://raw.githubusercontent.com/Susheate/brl-nvidia/refs/heads/main/brl-nvidia.sh -o $usedDir/brl-nvidia/brl-nvidia.sh
		cp $usedDir/brl-nvidia/brl-nvidia.sh /bedrock/strata/$kernelStratum/bin/brl-nvidia
		chmod +x /bedrock/strata/$kernelStratum/bin/brl-nvidia
		echo -e "\e[36mDone\e[0m"
		;;
esac
