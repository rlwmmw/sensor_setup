#!/bin/sh

source /etc/secops/secops.conf
NOW=$(date +%s)

/etc/init.d/suricata stop

mv $SURICATA_LOG_DIR/eve.json $SURICATA_LOG_DIR/eve.json.$NOW

/etc/init.d/suricata start

OLD="$(expr $NOW - 2592000)"
for f in $SURICATA_LOG_DIR/eve.json.*; do
 i=$(echo $f | cut -d. -f3)
 if [ $i -lt $OLD ]; then
   rm $SURICATA_LOG_DIR/eve.json.$i
 fi
done
