#!/sbin/sh

echo "update settings set value='5.5.0.4' where key='current_recovery_version';" | /system/xbin/sqlite3 /data/data/com.koushikdutta.rommanager/databases/settings.db
