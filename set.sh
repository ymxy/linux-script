#!/bin/bash

print_line() {
	printf "%$(tput cols)s\n"|tr ' ' '-'
}

print_title() {
	clear
	print_line
	echo -e "# ${Bold}$1${Reset}"
	print_line
	echo ""
}
arch_chroot() {
	arch-chroot /mnt /bin/bash -c "${1}"
}

#替换仓库列表
update_mirrorlist(){
	print_title "update_mirrorlist"
	tmpfile=$(mktemp --suffix=-mirrorlist)	
	url="https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&protocol=https&ip_version=4"
	curl -so ${tmpfile} ${url} 
	sed -i 's/^#Server/Server/g' ${tmpfile}
	mv -f ${tmpfile} /etc/pacman.d/mirrorlist;
        pacman -Syy
}

#最小安装（efi引导的话，将grub改成grub-efi-x86_64 efibootmgr）
install_baseSystem(){
	print_title "install_baseSystem"
	pacstrap /mnt base base-devel iw wireless_tools wpa_supplicant dialog netctl vim grub screenfetch git xorg-server xf86-input-synaptics  wqy-zenhei ttf-dejavu wqy-microhei adobe-source-code-pro-fonts   
}

#生成标卷文件表
generate_fstab(){
	print_title "generate_fstab"
	genfstab -U /mnt >> /mnt/etc/fstab
}

#配置系统时间,地区和语言
configure_system(){
	print_title "configure_system"
	arch_chroot "ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime"
	arch_chroot "hwclock --systohc --utc"
	arch_chroot "mkinitcpio -p linux"
	echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
	echo "zh_CN.UTF-8 UTF-8" >> /mnt/etc/locale.gen
	arch_chroot "locale-gen"
	echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
}

#安装驱动程序
configrue_drive(){
	print_title "configrue_drive"
	arch_chroot "pacman -S --noconfirm bumblebee -y"
        arch_chroot "systemctl enable bumblebeed"
        arch_chroot "pacman -S --noconfirm nvidia -y"        
}

#安装网络管理程序
configrue_networkmanager(){
	print_title "configrue_networkmanager"
  	arch_chroot "pacman -S --noconfirm networkmanager networkmanager-openconnect rp-pppoe network-manager-applet net-tools -y"
        arch_chroot "systemctl enable NetworkManager.service"      
}

#安装配置引导程序
configrue_bootloader(){
	print_title "configrue_bootloader"
	arch_chroot "grub-install --target=i386-pc /dev/sda"
       #arch_chroot "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=boot" (efi引导)
        arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg" 
}


#添加本地域名
configure_hostname(){

	print_title "configure_hostname"

	read -p "Hostname [ex: archlinux]: " host_name

	echo "$host_name" > /mnt/etc/hostname

	if [[ ! -f /mnt/etc/hosts.aui ]]; then

	cp /mnt/etc/hosts /mnt/etc/hosts.aui

	else

	cp /mnt/etc/hosts.aui /mnt/etc/hosts

	fi

	arch_chroot "sed -i '/127.0.0.1/s/$/ '${host_name}'/' /etc/hosts"

	arch_chroot "sed -i '/::1/s/$/ '${host_name}'/' /etc/hosts"
	
	umount -R /mnt
	
	clear
	
	print_title "install has been.please reboot ."

}



update_mirrorlist
install_baseSystem
generate_fstab
configure_system
configrue_drive
configrue_networkmanager
configrue_bootloader
configure_hostname
