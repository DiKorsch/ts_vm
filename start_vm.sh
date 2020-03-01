#!/usr/bin/env bash

source 00_config.sh

echo "Available Networks:"
virsh net-list --all

echo "Available VMs:"
virsh list --all

_result=$(virsh net-list --all | grep " ${NET_NAME}" | awk '{ print $2}')
if ([ "$_result" == "" ]); then
	echo "Network does not exist, installing ..."
	install_net;
elif [[ "$_result" == "active" ]]; then
	echo "Network is already active!"
else
	echo "Network already exist, starting it!"
	run_net;
fi


_result=$(virsh list --all | grep " ${NAME}" | awk '{ print $3}')
if ([ "$_result" == "" ]); then
	echo "VM does not exist, installing ..."
	install;
elif [[ "$_result" == "running" ]]; then
	echo "VM is already running!"
else
	echo "VM already exist, starting it!"
	run_vm;
fi

echo ""
virsh list --all
echo "VM's IP adress:"
sudo virsh domifaddr ${NAME}
