#!/system/bin/sh
MODDIR=${0%/*}

write_log() {
  echo "[`date`] $1" >> /cache/OpenRealGPS.log
  /system/bin/log -t 'OpenRealGPS_Service' "$1"
}

if [[ ! -e /vendor/bin/hw/gnss-service ]]
then
  write_log 'GNSS service not found, exiting.'
  exit
fi

if [[ ! -e $MODDIR/service_path ]]
then
  write_log 'Original service path not found, exiting.'
  exit
fi

SVPATH=`cat $MODDIR/service_path`
SVNAME=`basename $SVPATH`
write_log "Force restart service $SVNAME"
PID=`/system/bin/pkill -f -V -9 $SVNAME`
if [[ $PID ]]; then write_log "Restarted PID $PID"; fi

{
  write_log "OpenRealGPS service monitor started as: `id`"
  while true
  do
    if [ -z "`/system/bin/ps -A | grep gnss-service`" ]
    then
      write_log 'Starting GNSS service in Magisk ...'
      /vendor/bin/hw/gnss-service
      write_log 'Service down, trying to restart after 3s ...'
    fi
    sleep 3
  done
} &

SECON=`/system/bin/ls -Z $SVPATH | sed 's/^.*u:object_r:\(.*\):s0.*$/\1/g' | sed 's/^\(.*\)_exec$/\1/g'`
if [[ $SECON ]]
then
  write_log "Injecting SELinux policies for service context $SECON"
  magiskpolicy --live "allow { $SECON ${SECON}_exec } * * *"
  magiskpolicy --live "allow * { $SECON ${SECON}_exec } * *"
fi
