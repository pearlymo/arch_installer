# Instruction

## To Test

Use a Virtual Machine first to test if the scripts are running properly.

## Fetch Script

After booting Arch Linux with an bootable medium, check network connection. If connected to the internet, run the following command to fetch the installation script - 

```
curl -LO https://raw.githubusercontent.com/mothighimire/arch_installer/master/install_sys.h
```

## Start Installation

Run the installation script with the following command -

```
bash install_sys.h
```

To install applications with pacman during the process, change tty with CTRL+ALT+F2. You can go back to the installation with CTRL+ALT+F1.

To see the output of pacman while applications are being installed, run this command - 

```
tail -f /tmp/arch_install
```
