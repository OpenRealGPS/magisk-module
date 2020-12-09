#!/system/bin/sh
MODDIR=${0%/*}

write_log() {
  echo "[`date`] $1" >> /cache/OpenRealGPS.log
  /system/bin/log -t 'OpenRealGPS_Service' "$1"
}

SVPATH=`find $MODDIR/system/vendor/bin/hw/* | head -n 1`
if [[ ! $SVPATH ]]; then write_log 'Service path not found, exiting.'; exit; fi

SVNAME=`basename $SVPATH`
write_log "Setting permissions for service $SVNAME"
chown root:shell $SVPATH
chmod +s $SVPATH

SECON=`ls -Z $SVPATH | sed 's/^.*:object_r:\(.*\):.*$/\1/g' | sed 's/^\(.*\)_exec$/\1/g'`
if [[ $SECON ]]
then
  write_log "Injecting SELinux policies for service context $SECON"
  magiskpolicy --live "allow { $SECON ${SECON}_exec } * * *"
  magiskpolicy --live "allow * { $SECON ${SECON}_exec } * *"
fi

write_log "Force restarting service"
pkill -9 -f $SVNAME
