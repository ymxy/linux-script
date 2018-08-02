# linux-script

# 全文没有原创，只是为了方便自己使用才建的仓库；arch是从padin/dotfiles仓库中copy过来后根据自己需要修改的，Arch是从YangMame/Arch-Linux-Installer仓库中copy过来后根据自己需要修改的，所以万一有人有疑惑请联系原创，侵删
---

## arch，全自动安装，需要在安装前根据需要修改如磁盘格式大小、启动项等内容；安装完成后只需要添加本地域名密码，添加本地用户、下载桌面后重启即可使用
###  脚本使用方法：
连接好网络后执行
```
wget raw.githubusercontent.com/ymxy/linux-script/master/arch.sh
bash arch.sh
```
### 使用及脚本安装完后续步骤：
添加本地域名密码
```
$ passwd
```
添加本地用户
```
$ pacman -S zsh
$ useradd -m -g users -G wheel -s /bin/zsh &user
$ passwd #user
$ pacman -S sudo
$ nano /etc/sudoers
-在root ALL=(ALL) ALL 下面添加 &user ALL=(ALL) ALL取消下一行wheel的#号(注释)
```
下载桌面，如kde桌面
```
$ pacman -S kf5 kf5-aids plasma kdebase sddm sddm-kcm 
$ systemctl enable sddm
```

---

## Arch，半自动安装，在安装时根据需要选择，安装完成后重启即可使用
###  脚本使用方法：
连接好网络后执行
```
wget raw.githubusercontent.com/ymxy/linux-script/master/Arch.sh
bash Arch.sh
```


