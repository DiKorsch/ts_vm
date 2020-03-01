#!/usr/bin/env bash

source 00_config.sh

echo "Available Networks:"
virsh net-list --all

echo "Available VMs:"
virsh list --all


_result=$(virsh net-list --all | grep " ${NET_NAME}" | awk '{ print $2}')
if ([ "$_result" == "" ]); then
	echo "Network does not exist."
elif [[ "$_result" == "active" ]]; then
	echo "Network is active, deactivating it!"
	stop_net;
	echo "Dropping network!"
	drop_net;
else
	echo "Dropping network!"
	drop_net;
fi


_result=$(virsh list --all | grep " ${NAME}" | awk '{ print $3}')
if ([ "$_result" == "" ]); then
	echo "VM does not exist."
elif [[ "$_result" == "running" ]]; then
	echo "VM is running, stopping it!"
	stop_vm;
	echo "Dropping VM!"
	drop_vm;
else
	echo "Dropping VM!"
	drop_vm;
fi

echo ""
echo "Available Networks:"
virsh net-list --all

echo "Available VMs:"
virsh list --all

