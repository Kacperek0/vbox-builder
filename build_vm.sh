#!/bin/bash

VMNAME=$1
ISOPATH='raspbian.iso'
VMNAME_DISK="$1_DISK"
DISKSIZE=20480

# Tworzenie maszyny wirtualnej
vm_creation() {
    VBoxManage createvm --name "$VMNAME" --ostype "Linux" --register --basefolder $PWD
}

# Przypisanie RAM, vRAM i karty sieciowej
assignments() {
    VBoxManage modifyvm "$VMNAME" --ioapic on
    VBoxManage modifyvm "$VMNAME" --memory 1024 --vram 128
    VBoxManage modifyvm "$VMNAME" --nic1 nat
}

# Utworzenie dysku, napędu i zamontowanie obrazu z systemem
creation_and_mounting() {
    VBoxManage createhd --filename "$PWD/$VMNAME/$VMNAME_DISK.vdi" --size 20480 --format VDI
    VBoxManage storagectl "$VMNAME" --name "SATA Controller" --add sata --controller IntelAhci
    VBoxManage storageattach "$VMNAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $PWD/$VMNAME/$VMNAME_DISK.vdi
    VBoxManage storagectl "$VMNAME" --name "IDE Controller" --add ide --controller PIIX4
    VBoxManage storageattach "$VMNAME" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $ISOPATH
    VBoxManage modifyvm "$VMNAME" --boot1 dvd --boot2 disk --boot3 none --boot4 none
}

# Ustanowienie dostępu do maszyny
access() {
    VBoxManage modifyvm "$VMNAME" --vrde on
    VBoxManage modifyvm "$VMNAME" --vrdemulticon on --vrdeport 10001
}

vm_creation
assignments
creation_and_mounting
access
echo "$VMNAME created"
