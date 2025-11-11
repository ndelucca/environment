VM_HOSTNAME="nazareno-vm.e-ducativa.x"
DEBIAN="deb12"
MOUNTPOINT="/home/ndelucca/vmmount/educativa"

alias vm="cd ~/deploy/vm/${DEBIAN}"
alias vup=". ~/deploy/vm/${DEBIAN}/.envrc && vm && vagrant up"
alias vhalt=". ~/deploy/vm/${DEBIAN}/.envrc && vm && vagrant halt && nmcli connection down educativa"

alias vmmount="mkdir -p ${MOUNTPOINT} && sshfs educativa@${VM_HOSTNAME}: ${MOUNTPOINT}"
alias vmumount="fusermount -u /home/ndelucca/vmmount/educativa"

