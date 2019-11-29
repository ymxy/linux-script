#!/bin/bash

# 设置颜色
color(){
    case $1 in
        red)
            echo -e "\033[31m$2\033[0m"
        ;;
        green)
            echo -e "\033[32m$2\033[0m"
        ;;
    esac
}

partition(){
    if (echo $1 | grep '/' > /dev/null 2>&1);then
        other=$1
    else
        other=/$1
    fi

    fdisk -l
#  输入分区 
    color green "Input the partition (/dev/sdaXn"
    read OTHER
#  是否格式化
    color green "Format it ? y)yes ENTER)no"
    read tmp

    if [ "$other" == "/boot" ];then
        boot=$OTHER
    fi
 # （分区变量，一旦选择格式化则选择以下格式）
    if [ "$tmp" == y ];then
        umount $OTHER > /dev/null 2>&1
 #  输入分区格式
        color green "Input the filesystem's num to format it"
        select type in 'ext2' "ext3" "ext4" "btrfs" "xfs" "jfs" "fat" "swap";do
            case $type in
                "ext2")
                    mkfs.ext2 $OTHER
                    break
                ;;
                "ext3")
                    mkfs.ext3 $OTHER
                    break
                ;;
                "ext4")
                    mkfs.ext4 $OTHER
                    break
                ;;
                "btrfs")
                    mkfs.btrfs $OTHER -f
                    break
                ;;
                "xfs")
                    mkfs.xfs $OTHER -f
                    break
                ;;
                "jfs")
                    mkfs.jfs $OTHER
                    break
                ;;
                "fat")
                    mkfs.fat -F32 $OTHER
                    break
                ;;
                "swap")
                    swapoff $OTHER > /dev/null 2>&1
                    mkswap $OTHER -f
                    break
                ;;
                *)
                    color red "Error ! Please input the num again"
                ;;
            esac
        done
    fi

    if [ "$other" == "/swap" ];then
        swapon $OTHER
    else
        umount $OTHER > /dev/null 2>&1
        mkdir /mnt$other
        mount $OTHER /mnt$other
    fi
}

prepare(){
    fdisk -l
#  是否要调整（重新）分区 （开始界面）
    color green "Do you want to adjust the partition ? y)yes ENTER)no"
    read tmp
    if [ "$tmp" == y ];then
#  输入磁盘（进入cfdisk分区工具）
        color green "Input the disk (/dev/sdX"
        read TMP
        cfdisk $TMP
    fi
#  根目录（/）挂载点
    color green "Input the ROOT(/) mount point(/dev/sdXn:"
    read ROOT
#  是否格式化
    color green "Format it ? y)yes ENTER)no"
    read tmp
    if [ "$tmp" == y ];then
        umount $ROOT > /dev/null 2>&1
#  输入分区格式
        color green "Input the filesystem's num to format it"
        select type in "ext4" "btrfs" "xfs" "jfs";do
            umount $ROOT > /dev/null 2>&1
            if [ "$type" == "btrfs" ];then
                mkfs.$type $ROOT -f
            elif [ "$type" == "xfs" ];then
                mkfs.$type $ROOT -f
            else
                mkfs.$type $ROOT
            fi
            break
        done
    fi
    mount $ROOT /mnt
 #  是否还有其他的挂载点，比如/boot、/home、swap或者按enter跳过
    color green "Do you have another mount point ? if so please input it, such as : /boot /home and swap or just ENTER to skip"
    read other
    while [ "$other" != '' ];do
        partition $other
 #  是否还有其他的挂载点，比如/boot、/home、swap或者按enter跳过
        color green "Still have another mount point ? if so please input it, such as : /boot /home and swap or just ENTER to skip"
        read other
    done
}
#  整理镜像仓库（只保留中国源镜像）
#  安装基本系统并生成fstab文件
install(){
    tmpfile=$(mktemp --suffix=-mirrorlist)	
    url="https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&protocol=https&ip_version=4"
    curl -so ${tmpfile} ${url} 
    sed -i 's/^#Server/Server/g' ${tmpfile}
    mv -f ${tmpfile} /etc/pacman.d/mirrorlist;
    pacman -Syy
    pacstrap /mnt base linux linux-firmware --force
    genfstab -U -p /mnt > /mnt/etc/fstab
}
config(){
    rm -rf /mnt/root/config.sh
    wget https://raw.githubusercontent.com/ymxy/linux-script/master/Arch-config.sh -O /mnt/root/config.sh
    chmod +x /mnt/root/config.sh
    arch-chroot /mnt /root/config.sh $ROOT $boot
}

if [ "$1" != '' ];then
    case $1 in
        "--prepare")
            prepare
        ;;
        "--install")
            install
        ;;
        "--chroot")
            config
        ;;
        "--help")
            color red "--prepare :  prepare disk and partition\n--install :  install the base system\n--chroot :  chroot into the system to install other software"
        ;;
        *)
            color red "Error !\n--prepare :  prepare disk and partition\n--install :  install the base system\n--chroot :  chroot into the system to install other software"
        ;;
    esac
else
    prepare
    install
    config
fi
