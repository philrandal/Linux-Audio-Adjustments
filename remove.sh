#!/bin/bash

border()
{
    local title="| $1 |"
    local edge=${title//?/-}
    echo -e "${edge}\n${title}\n${edge}"
    sleep 4
}

border 'Removing Linux Audio Tuning'

[[ -f /usr/bin/Sound.sh ]] && rm /usr/bin/Sound.sh
[[ -f /etc/sysctl.d/network-latency.conf ]] && rm /etc/sysctl.d/network-latency.conf
[[ -f /etc/security/limits.d/linuxaudioadjustments.conf ]] && rm /etc/security/limits.d/linuxaudioadjustments.conf
[[ -f /etc/rc.local ]] && sed -i '\|/usr/bin/Sound.sh|d' /etc/rc.local

sudo rm basic-install.sh

border 'Rebooting System'

reboot
