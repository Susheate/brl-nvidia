#!/bin/bash

function prepareEnv() {
	if [[ ! -e /home/$(id -nu 1000)/.config/brl-nvidia/config ]] || [[ $(cat /home/$(id -nu 1000)/.config/brl-nvidia/config) == "" ]]; then
		if [[ ! -e /home/$(id -nu 1000)/.config/brl-nvidia/ ]]; then runuser -l $(id -nu 1000) -s /bin/bash -c -- 'mkdir ~/.config/brl-nvidia/'; fi
		stratList=()
		for stratum in $(brl list); do
			stratList+=("$stratum")
		done
		echo -e "Which \e[35mstratum\e[0m is providing the in-use kernel?"
		for (( i=0;i<${#stratList[@]}; i++ )); do
			echo -e "$i. \e[35m${stratList[i]}\e[0m"
		done
		usrInput=999
		while (( $usrInput<0 || $usrInput>${#stratList[@]} )); do
			read -p "Number : " usrInput
			usrInput=$(( usrInput ))
		done
		echo ${stratList[$usrInput]} >> /home/$(id -nu 1000)/.config/brl-nvidia/config
	fi
	
	export kernelStratum=$(runuser -l $(id -nu 1000) -s /bin/bash -c -- 'cat ~/.config/brl-nvidia/config')
	export usedDir="/bedrock/strata/$kernelStratum/var/tmp"
	export KMDVersion=$(modinfo -F version nvidia)
}

function checkRoot() {
	if [ $(id -u) != 0 ]; then echo "brl-nvidia requires root."; exit 1; fi
}

function downloadDrivers() {
	if [[ ! -e "$usedDir/brl-nvidia/nvidia-$KMDVersion.run" ]] || [[ $1 == "force" ]]; then
		if [[ ! -e "$usedDir/brl-nvidia" ]]; then
			mkdir $usedDir/brl-nvidia
		fi
		curl -f https://us.download.nvidia.com/XFree86/Linux-x86_64/$KMDVersion/NVIDIA-Linux-x86_64-$KMDVersion.run -o $usedDir/brl-nvidia/nvidia-$KMDVersion.run
	fi
}

function integrityCheck() {
	if [[ $? == 2 ]]; then
		echo "Re-downloading the drivers..."
		downloadDrivers force
		installDrivers $1
	fi
}

function installDrivers() {
	prepareEnv
	downloadDrivers
	if [[ $1 == "all" ]]; then
		for stratum in $(brl list); do
			if [[ $stratum != $kernelStratum ]] && [[ $stratum != "bedrock" ]] && [[ $stratum != "bpt" ]]; then
				echo -e "\e[36mProceeding with\e[36m \e[35m$stratum\e[0m"
				strat -r $stratum sh $usedDir/brl-nvidia/nvidia-$KMDVersion.run --no-kernel-modules -q --ui=none --no-x-check
			fi
			integrityCheck $2
		done
	else
		strat -r $1 sh $usedDir/brl-nvidia/nvidia-$KMDVersion.run --no-kernel-modules -q --ui=none --no-x-check
		integrityCheck $2
	fi
}

function removeDrivers() {
	prepareEnv
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
	prepareEnv
	downloadDrivers
	for stratum in $(brl list); do
		if [[ $stratum != $kernelStratum ]] && [[ $stratum != "bedrock" ]] && [[ $stratum != "bpt" ]]; then
		   strat $stratum nvidia-smi
		   if [[ $? == 18 ]]; then
			   echo -e "\e[36mProceeding with\e[36m \e[35m$stratum\e[0m"
			   strat -r $stratum sh $usedDir/brl-nvidia/nvidia-$KMDVersion.run --no-kernel-modules -q --ui=none --no-x-check
		   else
			   echo -e "\e[36mSkipping\e[36m \e[35m$stratum\e[0m"
		   fi
		else
			echo -e "\e[36mSkipping\e[36m \e[35m$stratum\e[0m"
		fi
		integrityCheck $stratum
	done
}


case $1 in
 "install")
 	checkRoot
	targetedStratum=$2
 	installDrivers $targetedStratum
 	echo -e "\e[36mDone\e[0m"
 	;;
 "remove")
 	checkRoot
	targetedStratum=$2
 	removeDrivers $targetedStratum
 	echo -e "\e[36mDone\e[0m"
 	;;
 "update")
 	checkRoot
	targetedStratum=$2
 	updateDrivers
 	echo -e "\e[36mDone\e[0m"
 	;;
 "install-script")
 	checkRoot
	prepareEnv
 	cp $0 /bedrock/strata/$kernelStratum/bin/brl-nvidia
 	chmod +x /bedrock/strata/$kernelStratum/bin/brl-nvidia
 	echo -e "\e[36mDone\e[0m"
 	;;
 "update-script")
 	checkRoot
	prepareEnv
 	curl -f https://raw.githubusercontent.com/Susheate/brl-nvidia/refs/heads/main/brl-nvidia.sh -o $usedDir/brl-nvidia/brl-nvidia.sh
 	cp $usedDir/brl-nvidia/brl-nvidia.sh /bedrock/strata/$kernelStratum/bin/brl-nvidia
 	chmod +x /bedrock/strata/$kernelStratum/bin/brl-nvidia
 	echo -e "\e[36mDone\e[0m"
 	;;
 "--help"|"")
         echo -e "install \e[35mstratum\e[0m\n     Install NVIDIA userpace drivers in the selected stratum.\n\nremove \e[35mstratum\e[0m\n     Remove NVIDIA userpace drivers from the selected stratum.\n\nupdate\n     Update NVIDIA drivers in strata providing the NVIDIA userpace drivers, syncing them to the same version as the NVIDIA kernel driver's.\n\ninstall-script\n     Copies the script into the binaries directory of the stratum providing the kernel.\n\nupdate-script\n     Updates brl-nvidia."
         ;;
esac
