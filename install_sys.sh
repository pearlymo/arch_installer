#!/bin/bash

# Important: read about `pacman -Sy` before running it 
pacman -Sy dialog --noconfirm

timedatectl set-ntp true

# Yesno message types - see `man dialog`
dialog --defaultno --title "Are you sure?" --yesno "Personal
arch linux install. \n\n\
Installation will wipe chosen hard disk. \n\n\
Abort if uncertain \n\n\
Confirm YES to proceed with installation" 15 60 || exit

dialog --no-cancel --inputbox "Enter a name for your machine." \
10 60 2> comp

comp=$(cat comp) && rm comp

# Verify boot (UEFI or BIOS)
uefi=0
ls /sys/firmware/efi/efivars 2> /dev/null && uefi=1

# Choosing hard disk
devices_list=($(lsblk -d | awk '{print "/dev/" $1 " " $4 " on"}' \
    | grep -E 'sd|hd|vd|nvme|mmcblk'))

dialog --title "Choose hard disk" --no-cancel --radiolist \
"Where do you want to install the operating system?\n\n\
Select with SPACE, validate with ENTER.\n\n\
Important: chosen hard disk will be wiped before installation." \
15 60 4 "${devices_list[@]}" 2> hd

hd=$(cat hd) && rm hd

# Ask for swap partition size
default_size="8"
dialog --no-cancel --inputbox \
"Three partitions: Boot, Root and Swap \n\
The boot partition will be 512M \n\
The root partition will be the remaining of the hard disk \n\n\
Enter the partition size (in Gb) for the Swap. \n\n\
None entry defaults to ${default_size}G. \n" \
20 60 2> swap_size

size=$(cat swap_size) && rm swap_size

[[ $size =~ ^[0-9]+$ ]] || size=$default_size

dialog --no-cancel \
--title "Wipe Hard Disk" \
--menu "Choose option for wiping the hard disk ($hd)" \
15 60 4 \
1 "Use dd (wipe disk)" \
2 "Use schred (slow & secure)" \
3 "Hard disk is already empty" 2> eraser

hderaser=$(cat eraser); rm eraser

# Important: this function wipes the hard disk. Call with caution.
function eraseDisk() {
    case $1 in
        1) dd if=/dev/zero of="$hd" status=progress 2>&1 \
            | dialog \
            --title "Formatting $hd..." \
            --progressbox --stdout 20 60;;
        2) shred -v "$hd" \
            | dialog \
            --title "Formatting $hd..." \
            --progressbox --stdout 20 60;;
        3) ;;
    esac
}

eraseDisk "$hderaser"

boot_partition_type=1
[[ "$uefi" == 0 ]] && boot_partition_type=4

# Create partitions

#g - create non empty GPT partition table
#n - create new partition
#p - primary partition
#e - extended partition
#w - write the table to disk and exit

partprobe "$hd"

fdisk "$hd" << EOF
g
n


+512M
t
$boot_partition_type
n


+${size}G
n



w
EOF

partprobe "$hd"

# Format partitions

mkswap "${hd}2"
swapon "${hd}2"
mkfs.ext4 "${hd}3"
mount "${hd}3" /mnt

if [ "$uefi" = 1 ]; then
    mkfs.fat -F32 "${hd}1"
    mkdir -p /mnt/boot/efi
    mount "${hd}1" /mnt/boot/efi
fi

# Install Arch Linux
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

curl https://raw.githubusercontent.com/pearlymo/arch_installer/master/install_chroot.sh > /mnt/install_chroot.sh

arch-chroot /mnt bash install_chroot.sh

rm /mnt/var_uefi
rm /mnt/var_hd
rm /mnt/install_chroot.sh
rm /mnt/comp

dialog --title "Reboot?" --yesno \
"Installation completed. \n\n\
Do you want to reboot your computer?" 20 60

response=$?

case $response in
    0) reboot;;
    1) clear;;
esac
