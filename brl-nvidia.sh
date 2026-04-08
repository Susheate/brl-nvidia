#/usr/bin/bash

if [ ! -e "$HOME/brl-nvidia" ]; then
	mkdir ~/brl-nvidia
fi

if [ $1 == "install" ] || [ $1 == "update" ]; then
	driverVersion=$(nvidia-smi | grep  "Driver Version" | cut -d ' ' -f 3)
	if [ ! -e ~/brl-nvidia/nvidia-${driverVersion}.run ]; then curl https://us.download.nvidia.com/XFree86/Linux-x86_64/${driverVersion}/NVIDIA-Linux-x86_64-${driverVersion}.run -o ~/brl-nvidia/nvidia-${driverVersion}.run; fi
	if [ $2 != "all" ]; then
		sudo strat -r $2 sh ~/brl-nvidia/nvidia-${driverVersion}.run --no-kernel-modules
	else
		for stratum in $(brl list)
		do
			sudo strat -r $stratum sh ~/brl-nvidia/nvidia-${driverVersion}.run --no-kernel-modules
		done
	fi
fi
