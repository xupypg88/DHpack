#!/bin/bash

#bin file name - flash.bin
WORKFILE=$1
WORKPATH="TMP${WORKFILE}"
IMGSPATH="imgs"
DIRSPATH="dirs"
pwd=$PWD
	
quit() {
	clear
	echo "Done. No errors."
	exit 0
}

bin2folder() {
	file=$1
	clear
	rm -rf $WORKPATH
	echo -n "PK" | dd of=$file conv=notrunc
	echo "Unpacking..."
	mkdir -p $WORKPATH/$IMGSPATH
	unzip $file -d $WORKPATH/$IMGSPATH 2> /dev/null
}

folder2bin() 	{
	folder=$1
	clear
	echo "Packing..."
	cd $WORKPATH/$IMGSPATH
	zip flash.bin *.img
	zip flash.bin Install
	mv -f flash.bin $pwd/$WORKFILE
	cd $pwd
	echo -n "DH" | dd of=$WORKFILE conv=notrunc
	rm -rf $WORKPATH
	}

img2dir() {
	imgfile=$1
	if [ "$imgfile" != "kernel-x.cramfs.img" ]; then
		if [ "$imgfile" != "dm365_ubl_boot_16M.bin.img" ]; then
			#img info
			mkimage -l ${imgfile} > ${imgfile}.cut.info	
			
			dd if=${imgfile} of=${imgfile}.cut bs=64 skip=1 
			rm -f ${imgfile}
			
			fstype=`file ${imgfile}.cut | cut -d':' -f2 | cut -d',' -f1  | sed 's/[ \t]*//' |cut -d' ' -f1`
			case $fstype in 
						"Squashfs")
							unsquashfs -dest $DIRSPATH/${imgfile} ${imgfile}.cut
							;;
						"Linux")
							cramfsck -x $DIRSPATH/${imgfile} ${imgfile}.cut
							;;
						*)
							echo "NOT DISK TYPE!!!"
						;;
			esac
		fi
	fi
}


dir2img() {
	imgfilecut=$1
	fstype=`file ${imgfilecut} | cut -d':' -f2 | cut -d',' -f1  | sed 's/[ \t]*//' |cut -d' ' -f1`		
	name=`cat ${imgfilecut}.info | grep Name | cut -d':' -f2 | sed 's/[ \t]*//'`
	type=`cat ${imgfilecut}.info | grep "Image Type" | cut -d':' -f2 | sed 's/[ \t]*//' | cut -d' ' -f3`
	load=`cat ${imgfilecut}.info | grep Load | cut -d':' -f2 | sed 's/[ \t]*//'`
	entry=`cat ${imgfilecut}.info | grep Entry | cut -d':' -f2 | sed 's/[ \t]*//'`
	comp=`cat ${imgfilecut}.info | grep "Image Type" | cut -d'(' -f2 | cut -d' ' -f1`
	
	if [ "$comp" != "gzip" ]; then
		comp="none"
	fi
			
	rm -rf ${imgfilecut}
	
	if [ "${name}" == "linux" ]; then
		name='kernel'
	fi
	if [ "${name}" == "product" ]; then
		name='pd'
	fi
		
	if [ "$fstype" == "Squashfs" ]; then 
		mksquashfs3 dirs/${name}-x.cramfs.img ${name}-x.cramfs
	else if [ "$fstype" == "Linux" ]; then
		mkcramfs dirs/${name}-x.cramfs.img ${name}-x.cramfs
	else 
		echo "WAAAAAAAAAAAARRRRRRRRNINNGGGGG!!!!!!!!"		
		echo "WAAAAAAAAAAAARRRRRRRRNINNGGGGG!!!!!!!!"
		fi
	fi

	mkimage -A arm -O linux -T $type -C $comp -a $load -e $entry -n $name -d ${name}-x.cramfs ${name}-x.cramfs.img
}

mainmenu() {
	clear	
	
	echo "Please select action:"
	echo "1. Pack"
	echo "2. Unpack"
	echo "3. Pack/Unpack(default)"
	echo "4. Exit"
	echo "Choice:"
	read -n 1 -s act
		
	case $act in
		1)
			mkdir ${WORKPATH}/${IMGSPATH}/$DIRSPATH
			cd ${WORKPATH}/${IMGSPATH}
			for i in $(ls *.cut); do # Not recommended, will break on whitespace
				dir2img $i
			done
			cd $pwd
			folder2bin $WORKPATH
		;;
		2)
			bin2folder $WORKFILE 
			mkdir ${WORKPATH}/${IMGSPATH}/$DIRSPATH
			cd ${WORKPATH}/${IMGSPATH}
			for i in $(ls *.img); do # Not recommended, will break on whitespace
				img2dir $i
			done
			cd $pwd
		;;
		3) 
		
		;;
		4)
			echo "Exiting..."
			exit 0
		;;
		*)
		
		;;
	esac
}

mainmenu

