VM_HOSTNAME="nazareno-vm.e-ducativa.x"
DEBIAN="deb12"

alias vm="cd ~/deploy/vm/${DEBIAN}"
alias vup=". ~/deploy/vm/${DEBIAN}/.envrc && vm && vagrant up"
alias vhalt=". ~/deploy/vm/${DEBIAN}/.envrc && vm && vagrant halt"

alias vmmount="sshfs educativa@${VM_HOSTNAME}: /home/ndelucca/vmmount/educativa"
alias vmumount="fusermount -u /home/ndelucca/vmmount/educativa"

