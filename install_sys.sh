#!/bin/bash

# Never run pacman -Sy on your real system!
pacman -Sy dialog --noconfirm

timedatectl set-ntp true
