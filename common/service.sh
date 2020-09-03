#!/system/bin/sh

iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination 8.8.8.8:53
iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination 1.1.1.1:53
iptables -t nat -I OUTPUT -p tcp --dport 53 -j DNAT --to-destination 8.8.8.8:53
iptables -t nat -I OUTPUT -p udp --dport 53 -j DNAT --to-destination 1.1.1.1:53

#Gaming Mode
while true; do
 sleep 5
 if [ $(top -n 1 -d 1 | head -n 12 | grep -o -e 'codm' -e 'tencent' -e 'moonton' -e 'gameloft' -e 'garena' | head -n 1) ]; then
  echo "0" > /sys/module/msm_thermal/core_control/enabled
  chmod 0644 > /sys/module/workqueue/parameters/power_efficient
  echo "N" > /sys/module/workqueue/parameters/power_efficient
  echo "1" > /sys/module/msm_thermal/core_control/enabled
 else
  sleep 5
  echo "0" > /sys/module/msm_thermal/core_control/enabled
  chmod 0644 > /sys/module/workqueue/parameters/power_efficient
  echo "Y" > /sys/module/workqueue/parameters/power_efficient
  echo "1" > /sys/module/msm_thermal/core_control/enabled
 fi;
done
