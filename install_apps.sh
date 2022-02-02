#!/bin/bash

name=$(cat /tmp/user_name)

apps_path="/tmp/apps.csv"

curl https://raw.githubusercontent.com/mothighimire/arch_installer/master/apps.csv > $apps_path
