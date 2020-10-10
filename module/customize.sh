#!/sbin/sh

if [[ -e /data/adb/modules/openrealgps/i_have_read_the_warning ]]
then
  ui_print 'Old version detected, preserve i_have_read_the_warning flag'
  echo 1 > $MODPATH/i_have_read_the_warning
fi
