
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

IMAGE=${IMAGE:-ubuntu.img}
NAME=${NAME:-Ubuntu}
MEM=${MEM:-512}


# OPTS="${OPTS} --check path_in_use=off"
OPTS="${OPTS} --arch x86_64"
OPTS="${OPTS} --autostart"
OPTS="${OPTS} --print-xml"
OPTS="${OPTS} --import"

if kvm-ok; then
	echo "using KVM acceleration"
	OPTS="${OPTS} --virt-type kvm"
fi

NET_NAME=${NET_NAME:-ts_network}
MAC=${MAC:-"52:54:00:6c:3c:01"}

NETWORKING="--network network=${NET_NAME},model=virtio,mac=${MAC}"

function check_return {
	_ret=$?;
	if [[ $_ret -ne 0 ]]; then
		echo "Error during $1!"
		exit $_ret;
	fi
}

function install_vm {
	virt-install \
		--os-variant ubuntu18.04 \
		--name ${NAME} \
		--memory ${MEM} \
		--disk ${IMAGE} \
		${NETWORKING} \
		${OPTS} > .vm_definition.xml
	check_return "VM Definition";

	virsh define --file .vm_definition.xml
	check_return "VM Creation";

	run_vm
}

function run_vm {
	virsh start ${NAME};
	check_return "VM start";
}

function stop_vm {
	virsh shutdown ${NAME};
	check_return "VM stop";
}

function drop_vm {
	virsh undefine ${NAME};
	check_return "VM removal";
}

function install_net {
	virsh net-define network.xml;
	check_return "Network definition";
	virsh net-autostart ${NET_NAME};
	check_return "Network creation";

	run_net;
}

function run_net {
	virsh net-start ${NET_NAME};
	check_return "Network activation"
}

function stop_net {
	virsh net-destroy ${NET_NAME};
	check_return "Network stop"
}

function drop_net {
	virsh net-undefine ${NET_NAME};
	check_return "Network removal"
}



