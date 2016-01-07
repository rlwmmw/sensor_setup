#!/bin/bash 
# SecOps Configuration Utility

# get current unix time
DATE="$(date +%s)"

initial_setup () {
clear
# check to see if ipv6 is enabled
cat /etc/sysctl.conf | grep 'net.ipv6.conf.all.disable_ipv6 = 1' >/dev/null
if [[ $? -gt 0 ]]; then
    DISABLE_IPV6=no
else
    DISABLE_IPV6=yes
fi

# get current settings/defaults
echo set tabstop=4 >~/.vimrc
echo colorscheme desert >>~/.vimrc
HOSTNAME=$(hostname)
CLIENT_NAME=$(echo -n $HOSTNAME | cut -d- -f1)
SENSOR_NO=$(echo -n $HOSTNAME | tail -c3)
SURICATA_LOG_DIR="/nsm/suricata"
BRO_LOG_DIR="/nsm/bro/logs/current"

# get existing settings if available
if [ -a "/etc/secops/sensor.conf" ]; then
  source "/etc/secops/sensor.conf"
  mv /etc/secops/sensor.conf /etc/secops/sensor.conf.$DATE
else 
  mkdir -p /etc/secops
fi

# Get user input
read -e -i "$CLIENT_NAME" -p "Client Name : " input
CLIENT_NAME="${input:-$CLIENT_NAME}"

number=""
while [[ ! $number =~ ^([0-9]{2}[1-9]{1}|[1-9]{1}[0-9]{2})$ ]]; do
    read -e -i "$SENSOR_NO" -p "Sensor # (001-999) : " number
done
SENSOR_NO="${number:-$SENSOR_NO}"

input=""
read -e -i "$SURICATA_LOG_DIR" -p "Sensor Log Directory : " input
SURICATA_LOG_DIR="${input:-$SURICATA_LOG_DIR}"

input=""
read -e -i "$BRO_LOG_DIR" -p "Bro Log Directory : " input
BRO_LOG_DIR="${input:-$BRO_LOG_DIR}"


OLD_DISABLE_IPV6=$DISABLE_IPV6 # save old settings
yesno=""
while [[ ! $yesno =~ (yes|no) ]]; do 
    read -e -i "yes" -p "Disable ipv6 (yes/no)? (recommended): " yesno
done
DISABLE_IPV6="${yesno:-$DISABLE_IPV6}"

if [ $DISABLE_IPV6 == "yes" ] && [ $OLD_DISABLE_IPV6 == "no" ]; then
    echo 'net.ipv6.conf.all.disable_ipv6 = 1' >>/etc/sysctl.conf
	sysctl -p /etc/sysctl.conf
fi

# Build New Configuration File
cat > /etc/secops/sensor.conf <<EOF
# SecOps Configuration File

HOSTNAME=$HOSTNAME
CLIENT_NAME=$CLIENT_NAME
SENSOR_NO=$SENSOR_NO
SURICATA_LOG_DIR=$SURICATA_LOG_DIR
BRO_LOG_DIR=$BRO_LOG_DIR
DISABLE_IPV6=$DISABLE_IPV6

EOF
}

setup_network () {
clear
echo "This module is not yet complete"
menu;
}

setup_openvpn () {
clear
echo "This module is not yet complete"
menu;
}

setup_bro () {
clear
echo "This module is not yet complete"
menu;
}

setup_suricata () {
clear
echo "This module is not yet complete"
menu;
}

setup_beats () {
clear
echo "This module is not yet complete"
menu;
}

setup_salt () {
clear
echo "This module is not yet complete"
menu;
}

menu () {
# Display a menu

cat > /tmp/menu <<EOF

     ##########################################
     ####### What would you like to do? #######
     ##########################################
     #                                        #
     #     1. Perform initial setup           #
     #     2. Configure Networking            #
     #     3. Configure OpenVPN               #
     #     4. Configure Bro                   #
     #     5. Configure Suricata              #
     #     6. Configure Beats                 #
     #     7. Configure Salt                  #
     #     8. Exit Utility                    #
     #                                        #
     ##########################################

EOF
cat /tmp/menu
rm /tmp/menu
number=""
while [[ ! $number =~ ^[1-8]$ ]]; do
    read -p "Please select an action from above : " number
	echo "That is an in invalid entry"
done
# process selection
case $number in
    1)
	initial_setup
	;;
	
	2)
	setup_network
	;;
	
	3)
	setup_openvpn
	;;
	4)
	setup_bro
	;;
	
	5)
	setup_suricata
	;;
	
	6)
	setup_beats
	;;
	
	7)
	setup_salt
	;;
	
	8)
	clear
	exit 0
	;;
	
	*)
	exit 1
esac
}
clear
menu;
exit 0
