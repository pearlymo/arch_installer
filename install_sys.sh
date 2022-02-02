#!/bin/bash

# Never run pacman -Sy on your real system!
pacman -Sy dialog --noconfirm

timedatectl set-ntp true

# Welcome message of type yesno - see `man dialog`
dialog --defaultno --title "Are you sure?" --yesno "This is my personnal
arch linux install. \n\n\
It will just DESTROY EVERYTHING on the hard disk of your choice. \n\n\
Don't say YES if you are not sure about what you're doing! \n\n\
Are you sure?" 15 60 || exit

dialog --no-cancel --inputbox "Enter a name for your computer." \
10 60 2> comp
