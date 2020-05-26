#!/bin/bash

border()
{
    local title="| $1 |"
    local edge=${title//?/-}
    echo -e "${edge}\n${title}\n${edge}"
    sleep 1
}

border 'Creating Sound File'

cat <<EOF > /usr/bin/Sound.sh
#!/bin/bash
#Reduce Audio thread latency
chrt -f -p 54 $(pgrep ksoftirqd/0)
chrt -f -p 54 $(pgrep ksoftirqd/1)
chrt -f -p 54 $(pgrep ksoftirqd/2)
chrt -f -p 54 $(pgrep ksoftirqd/3)
#Uncomment for MPD Affinity and Priority
#chrt -f -p 81 $(pidof mpd)
#taskset -c -p 1 $(pidof mpd)
#SPDIF HAT and WiFi users Uncomment to turn off power to [Ethernet and USB] ports
#echo 0x0 > /sys/devices/platform/soc/3f980000.usb/buspower
#Reduce operating system latency
echo noop > /sys/block/mmcblk0/queue/scheduler
echo 1000000 > /proc/sys/kernel/sched_latency_ns
echo 100000 > /proc/sys/kernel/sched_min_granularity_ns
echo 25000 > /proc/sys/kernel/sched_wakeup_granularity_ns
exit
EOF

chmod 755 /usr/bin/Sound.sh

border 'Increasing Sound Group Priority'

[[ -f /etc/security/limits.conf ]] && mv /etc/security/limits.conf /etc/security/limits.conf.bak
echo '#New Limits' > /etc/security/limits.conf
echo '@audio - rtprio 99' >> /etc/security/limits.conf
echo '@audio - memlock 512000' >> /etc/security/limits.conf
echo '@audio - nice -20' >> /etc/security/limits.conf

border 'Improving Network Latency'

echo "#New Network Latency" > /etc/sysctl.d/network-latency.conf
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.d/network-latency.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.d/network-latency.conf


border 'Creating System Service'

[[ -f /etc/rc.local ]] || echo -e '#/bin/bash\n\nexit 0' > /etc/rc.local
grep -q '/usr/bin/Sound.sh' /etc/rc.local || sed -i '\|^#!/bin/.*sh|a\/usr/bin/Sound.sh' /etc/rc.local
chmod +x /etc/rc.local
#systemctl enable rc-local || systemctl enable rc.local

border 'Rebooting System Enjoy the Music'


reboot
