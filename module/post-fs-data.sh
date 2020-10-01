#!/system/bin/sh
MODDIR=${0%/*}

write_log() {
  echo "[`date`] $1" >> /cache/OpenRealGPS.log
}

echo -n > /cache/OpenRealGPS.log
chmod 644 /cache/OpenRealGPS.log
write_log 'post-fs-data start'

write_log 'Cleaning up'
rm -rf $MODDIR/system

if [[ ! -e $MODDIR/i_have_read_the_warning ]]
then
  write_log 'User have not read the warning, exiting.'
  exit
fi

ABI=`resetprop ro.product.cpu.abi`
case "$ABI" in
*arm64*) ARCH=arm64; LIBPATH=lib64;;
*armeabi*) ARCH=arm; LIBPATH=lib;;
*x86_64*) ARCH=x64; LIBPATH=lib64;;
*x86*) ARCH=x86; LIBPATH=lib;;
*) write_log "Unknown ABI: $ABI, exiting."; exit;;
esac
write_log "ABI: $ABI, arch: $ARCH, lib path: $LIBPATH"

write_log 'Preparing files'
mkdir -p $MODDIR/system/vendor/$LIBPATH/hw
mkdir -p $MODDIR/system/vendor/bin/hw

SOPATH=`find /system/vendor/$LIBPATH/hw -name 'android.hardware.gnss@1.0-impl*.so'`
SVPATH=`find /system/vendor/bin/hw -name '*.gnss@1.0-service*'`
if [[ ! $SOPATH ]]; then write_log 'Unable to find GNSS library path, exiting.'; exit; fi
if [[ ! $SVPATH ]]; then write_log 'Unable to find GNSS service path, exiting.'; exit; fi
SONAME=`basename $SOPATH`
SVNAME=`basename $SVPATH`

write_log "Original library path: $SOPATH"
write_log "Original service path: $SVPATH"
cp -v -p $SOPATH $MODDIR/system/vendor/$LIBPATH/hw/gnss-original.so >> /cache/OpenRealGPS.log 2>&1
cp -v $MODDIR/bin/openrealgps-$ARCH.so $MODDIR/system/vendor/$LIBPATH/hw/$SONAME >> /cache/OpenRealGPS.log 2>&1
cp -v -p $SVPATH $MODDIR/system/vendor/bin/hw/gnss-service >> /cache/OpenRealGPS.log 2>&1
cp -v $MODDIR/bin/dummy-service $MODDIR/system/vendor/bin/hw/$SVNAME >> /cache/OpenRealGPS.log 2>&1


SECON=`/system/bin/ls -Z $SVPATH | sed 's/^\(.*\) .*$/\1/g' | sed 's/^.*:\(.*\)_exec.*$/\1/g'`
if [[ $SECON ]]
then
  write_log "Injecting SELinux policies for service context $SECON"
  magiskpolicy --live "allow $SECON * * *"
  magiskpolicy --live "allow * $SECON * *"
  magiskpolicy --live "allow $SECON_exec * * *"
  magiskpolicy --live "allow * $SECON_exec * *"
fi

write_log 'post-fs-data done!'
