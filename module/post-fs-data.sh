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
rm -rf $MODDIR/service_context

if [[ ! -e $MODDIR/i_have_read_the_warning ]]
then
  write_log 'User have not read the warning, exiting.'
  exit
fi

write_log 'Preparing files'
ABI=`resetprop ro.product.cpu.abi`
case "$ABI" in
*arm64*) ARCH=arm64; LIBPATH=lib64;;
*armeabi*) ARCH=arm; LIBPATH=lib;;
*x86_64*) ARCH=x64; LIBPATH=lib64;;
*x86*) ARCH=x86; LIBPATH=lib;;
*) write_log "Unsupported ABI: $ABI, exiting."; exit;;
esac
write_log "ABI: $ABI, ARCH: $ARCH, LIBPATH: $LIBPATH"

SOPATH=`find /system/vendor/$LIBPATH/hw -name 'android.hardware.gnss@?.?-impl*.so' | head -n 1`
if [[ ! $SOPATH ]]; then write_log 'Unable to find GNSS library path, exiting.'; exit; fi
SVPATH=`find /system/vendor/bin/hw -name 'android.hardware.gnss@*-service*' | head -n 1`
if [[ ! $SVPATH ]]; then SVPATH=`find /system/vendor/bin/hw -name '*.gnss@?.?-service*' | head -n 1`; fi
if [[ ! $SVPATH ]]; then write_log 'Unable to find GNSS service path, exiting.'; exit; fi
SONAME=`basename $SOPATH`
SVNAME=`basename $SVPATH`
HIDL_VER=`echo $SONAME | sed 's/^.*android.hardware.gnss@\(.*\)-impl.*$/\1/g'`
NEW_SOPATH="$MODDIR/bin/$ARCH/android.hardware.gnss@$HIDL_VER-impl-openrealgps.so"
if [[ ! -e $NEW_SOPATH ]]
then
  write_log "Unsupported GNSS HIDL version: $HIDL_VER, exiting."
  exit
fi

write_log "Original library path: $SOPATH"
write_log "Original service path: $SVPATH"
mkdir -p $MODDIR/system/vendor/$LIBPATH/hw
mkdir -p $MODDIR/system/vendor/bin/hw
cp -v -p $SOPATH "$MODDIR/system/vendor/$LIBPATH/hw/gnss-original.so" >> /cache/OpenRealGPS.log 2>&1
cp -v $NEW_SOPATH "$MODDIR/system/vendor/$LIBPATH/hw/$SONAME" >> /cache/OpenRealGPS.log 2>&1
cp -v -p $SVPATH "$MODDIR/system/vendor/bin/hw/gnss-service" >> /cache/OpenRealGPS.log 2>&1
cp -v "$MODDIR/bin/dummy-service" "$MODDIR/system/vendor/bin/hw/$SVNAME" >> /cache/OpenRealGPS.log 2>&1

SECON=`/system/bin/ls -Z $SVPATH | sed 's/^.*u:object_r:\(.*\):s0.*$/\1/g' | sed 's/^\(.*\)_exec$/\1/g'`
if [[ $SECON ]]
then
  write_log "Saving service context $SECON"
  echo -n $SECON > $MODDIR/service_context
fi
write_log 'post-fs-data done!'
