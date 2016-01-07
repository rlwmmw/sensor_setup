rm /usr/local/bin/sensor_setup.sh; vim /usr/local/bin/sensor_setup.sh && chmod +x /usr/local/bin/sensor_setup.sh
:imap kj <Esc>
i#!/bin/bash
# SecOps Configuration Utility

# get current unix time
DATE="$(date +%s)"

initial_setup () {

# check to see if ipv6 is enabled
cat /etc/sysctl.conf | grep 'net.ipv6.conf.all.disable_ipv6 = 1'
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
SENSOR_LOG_DIR="/nsm/suricata"
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
    read -e -i "$SENSOR_NO" -p "Sensor # (ex. 001, 002) : " number
	echo "Must contain 3 digits (001-999)"
done
SENSOR_NO="${number:-$SENSOR_NO}"

input=""
read -e -i "$SENSOR_LOG_DIR" -p "Sensor Log Directory : " input
SENSOR_LOG_DIR="${input:-$SENSOR_LOG_DIR}"

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
SENSOR_LOG_DIR=$SENSOR_LOG_DIR
BRO_LOG_DIR=$BRO_LOG_DIR
DISABLE_IPV6=$DISABLE_IPV6

EOF
}

read -p "Would you like to perform initial setup? (y/n) :" input
shopt -s nocasematch
if [[ $input =~ (y|yes) ]]; then
   shopt -u nocasematch
   initial_setup;
fi
shopt -u nocasematch

cat > /etc/secops/menu.lst <<EOF

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
     #     8. Configure ???                   #
     #                                        #
     ##########################################

EOF
cat /etc/secops/menu.lst

read -p "Please select an action from above : " input
echo $input

kj
:wq
