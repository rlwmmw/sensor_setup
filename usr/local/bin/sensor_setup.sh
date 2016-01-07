#/bin/bash -x
# SecOps Configuration Utility

# get current unix time
DATE="$(date +%s)"

initial_setup () {
# setup defaults
SENSOR_LOG_DIR="/nsm/suricata"
BRO_LOG_DIR="/nsm/bro/logs/current"

# get existing settings if available
if [ -a "/etc/secops/secops.conf" ]; then
  source "/etc/secops/secops.conf"
  mv /etc/secops/secops.conf /etc/secops/secops.conf.$DATE
else 
  mkdir -p /etc/secops
fi

# Get user input
read -e -i "$CLIENT_NAME" -p "Client Name : " input
CLIENT_NAME="${input:-$CLIENT_NAME}"

read -e -i "$SENSOR_LOG_DIR" -p "Sensor Log Directory : " input
SENSOR_LOG_DIR="${input:-$SENSOR_LOG_DIR}"

read -e -i "$BRO_LOG_DIR" -p "Bro Log Directory : " input
BRO_LOG_DIR="${input:-$BRO_LOG_DIR}"

# Build New Configuration File
cat > /etc/secops/secops.conf <<EOF
# SecOps Configuration File

CLIENT_NAME="$CLIENT_NAME"
SENSOR_LOG_DIR="$SENSOR_LOG_DIR"
BRO_LOG_DIR="$BRO_LOG_DIR"

EOF
}

read -p "Would you like to perform initial setup? (y/n) :" input

shopt -s nocasematch
if [[ $input =~ (y|yes) ]]; then
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
     #     8. Configure packetbeat            #
     #                                        #
     ##########################################

EOF
cat /etc/secops/menu.lst

read -p "Please select an action from above : " input
echo $input
