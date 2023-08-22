#!/system/bin/sh
MODDIR=${0%/*}

write_log() {
  echo "[`date +'%m-%d %T.%N'`] $1" >> /cache/OpenRealGPS.log
  /system/bin/log -t 'OpenRealGPS_Service' "$1"
}

VENDORDIR=$MODDIR/system/vendor
if [ "$KSU" = true ]; then VENDORDIR=$MODDIR/vendor; fi
SVPATH=`find $VENDORDIR/bin/hw/* | head -n 1`
if [[ ! $SVPATH ]]; then write_log 'Service path not found, exiting.'; exit; fi

SVNAME=`basename $SVPATH`
write_log "Setting permissions for service $SVNAME"
chown root:shell $SVPATH
chmod +s $SVPATH

SECON=`ls -Z $SVPATH | sed 's/^.*:object_r:\(.*\):.*$/\1/g' | sed 's/^\(.*\)_exec$/\1/g'`
if [[ $SECON ]]
then
  write_log "Injecting SELinux policies for service context $SECON"
  sepolicy1="allow $SECON * * *"
  sepolicy2="allow * $SECON * *"
  if command -v magiskpolicy &> /dev/null
  then
    write_log 'Using magiskpolicy'
    magiskpolicy --live "$sepolicy1"
    magiskpolicy --live "$sepolicy2"
  elif command -v ksud &> /dev/null
  then
    write_log 'Using ksud'
    ksud sepolicy patch "$sepolicy1"
    ksud sepolicy patch "$sepolicy2"
  else
    write_log 'Both magiskpolicy and ksud are not found, what type of SU do you have?'
  fi
fi

write_log "Force restarting service $SVNAME"
pkill -9 -f $SVNAME

if [[ -w /cache/magisk.log ]]
then
  echo '[OpenRealGPS log start]' >> /cache/magisk.log
  cat /cache/OpenRealGPS.log >> /cache/magisk.log
  echo '[OpenRealGPS log end]' >> /cache/magisk.log
fi
