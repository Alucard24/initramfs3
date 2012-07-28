#!/sbin/busybox sh

extract_payload()
{
	payload_extracted=1
  	chmod 755 /sbin/read_boot_headers
  	eval $(/sbin/read_boot_headers /dev/block/mmcblk0p5)
  	load_offset=$boot_offset
  	load_len=$boot_len
  	cd /
  	dd bs=512 if=/dev/block/mmcblk0p5 skip=$load_offset count=$load_len | tar x
}

. /res/customconfig/customconfig-helper
read_defaults
read_config

mount -o remount,rw /system
/sbin/busybox mount -t rootfs -o remount,rw rootfs
payload_extracted=0

cd /

if [ "$install_root" == "on" ];
then
	if [ -s /system/xbin/su ];
	then
    		echo "Superuser already exists"
  	else
    		if [ "$payload_extracted" == "0" ];
		then
      			extract_payload
    		fi
    			rm -f /system/bin/su > /dev/null 2>&1
    			rm -f /system/xbin/su > /dev/null 2>&1
    			mkdir /system/xbin > /dev/null 2>&1
    			chmod 755 /system/xbin
    			xzcat /res/misc/payload/su.xz > /system/xbin/su
    			chown 0.0 /system/xbin/su
    			chmod 6755 /system/xbin/su

    			rm -f /system/app/*uper?ser.apk > /dev/null 2>&1
    			rm -f /system/app/?uper?u.apk > /dev/null 2>&1
    			rm -f /system/app/*chainfire?supersu*.apk > /dev/null 2>&1
    			rm -f /data/app/*uper?ser.apk > /dev/null 2>&1
    			rm -f /data/app/?uper?u.apk > /dev/null 2>&1
    			rm -f /data/app/*chainfire?supersu*.apk > /dev/null 2>&1
    			rm -rf /data/dalvik-cache/*uper?ser.apk* > /dev/null 2>&1
    			rm -rf /data/dalvik-cache/*chainfire?supersu*.apk* > /dev/null 2>&1
    			xzcat /res/misc/payload/Superuser.apk.xz > /system/app/Superuser.apk
    			chown 0.0 /system/app/Superuser.apk
    			chmod 644 /system/app/Superuser.apk
  	fi
fi;

romtype=`cat /proc/sys/kernel/rom_feature_set`
lightsmd5sum=`/sbin/busybox md5sum /system/lib/hw/lights.exynos4.so | /sbin/busybox awk '{print $1}'`
blnlightsmd5sum=`/sbin/busybox md5sum /res/misc/lights.exynos4.so | /sbin/busybox awk '{print $1}'`

  	if [ "${lightsmd5sum}a" != "${blnlightsmd5sum}a" ];
  	then
    		echo "Copying liblights"
    		/sbin/busybox mv /system/lib/hw/lights.exynos4.so /system/lib/hw/lights.exynos4.so.BAK
    		/sbin/busybox cp /res/misc/lights.exynos4.so /system/lib/hw/lights.exynos4.so
    		/sbin/busybox chown 0.0 /system/lib/hw/lights.exynos4.so
    		/sbin/busybox chmod 644 /system/lib/hw/lights.exynos4.so
  	fi

# New GM EXTWEAKS, Still not fully ready, lets wait for great app.
GMTWEAKS () {
echo "Checking if STweaks is installed"
if [ ! -f /system/.siyah/stweaks-installed ];
then
	#  if [ "$payload_extracted" == "0" ];then
	#    extract_payload
	#  fi
	rm /system/app/STweaks.apk
	rm /data/app/com.gokhanmoral.STweaks*.apk
	rm /data/dalvik-cache/*STweaks.apk*

	cat /res/STweaks.apk > /system/app/STweaks.apk
	chown 0.0 /system/app/STweaks.apk
	chmod 644 /system/app/STweaks.apk
	mkdir /system/.siyah
	chmod 755 /system/.siyah
	echo 1 > /system/.siyah/stweaks-installed
fi
}
#GMTWEAKS # Disabled for now.

if [ ! -s /system/xbin/ntfs-3g ];
then
	if [ "$payload_extracted" == "0" ];then
		extract_payload
  	fi
		xzcat /res/misc/payload/ntfs-3g.xz > /system/xbin/ntfs-3g
		chown 0.0 /system/xbin/ntfs-3g
		chmod 755 /system/xbin/ntfs-3g
fi

rm -rf /res/misc/payload

/sbin/busybox mount -t rootfs -o remount,rw rootfs
mount -o remount,rw /system

