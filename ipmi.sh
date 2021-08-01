#!/bin/sh

set -e
#set -x

if ! [ -r /etc/oci-poc/oci-poc.conf ] ; then
        echo "Cannot read /etc/oci-poc/oci-poc.conf"
fi
. /etc/oci-poc/oci-poc.conf

# Check that we really have NUMBER_OF_GUESTS machines available
# before starting anything
check_enough_vms_available () {
        EXPECTED_NUM_OF_SLAVES=${1}

        NUM_VM=$(ocicli -csv machine-list | q -d , -H "SELECT COUNT(*) AS count FROM -")
        if [ ${NUM_VM} -lt ${EXPECTED_NUM_OF_SLAVES} ] ; then
                echo "Num of VM too low... exiting"
                exit 1
        fi
}

check_enough_vms_available $((${NUMBER_OF_GUESTS} - 1))

echo "===> Setting-up IPMI ports on VMs"
for i in $(seq 2 $((${NUMBER_OF_GUESTS} + 1))) ; do
        VM_SERIAL=$(printf "%X\n" $((0xBF + ${i})))
        VNC_PORT=$((9000 + $i))
        echo "Setting IPMI for VM with serial: $VM_SERIAL and VNC port: $VNC_PORT"
        ocicli machine-set-ipmi ${VM_SERIAL} yes 192.168.100.1 ${VNC_PORT} ipmiusr test
done
