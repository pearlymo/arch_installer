#!/bin/bash

uefi=$(cat /var_uefi); hd=$(cat /var_hd);

cat /comp > /etc/hostname && rm /comp
