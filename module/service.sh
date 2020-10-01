#!/system/bin/sh
MODDIR=${0%/*}

write_log() {
  /system/bin/log -t 'OpenRealGPS_Service' "$1"
}

if [[ ! -e /vendor/bin/hw/gnss-service ]]
then
  write_log 'GNSS service not found, exiting.'
  exit
fi

{
  write_log "OpenRealGPS service monitor started as: `id`"
  while true
  do
    if [ -z "`/system/bin/ps -AZ | grep gnss-service`" ]
    then
      write_log 'Starting GNSS service in Magisk ...'
      /vendor/bin/hw/gnss-service
      write_log 'Service down, trying to restart after 3s ...'
    fi
    sleep 3
  done
} &
