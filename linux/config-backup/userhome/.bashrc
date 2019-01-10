#!/bin/sh
#By Levin   levinit.github.io
#If not running interactively, don't do anything
[[ $- != *i* ]] && return

#******** Default display ********
#PS1="[\u @ \h > \w ] \$ "

innerip=`ip addr | grep -o -P '1[^2]?[0-9]?(\.[0-9]{1,3}){3}(?=\/)'`
gateway=`ip route | grep 'via' |cut -d ' ' -f 3 |uniq`


echo -e "\e[36mHello, \e[1m`whoami`\e[0m
\e[1m`uname -srm`\e[0m
\e[1;36m`date`\e[0m
\e[1;32m$gateway\e[0m <-- \e[1;31m$innerip\e[0m

\e[1;34mTo grow, we all need to suffer.\e[0m

\e[37m+++++++=====\e[0m\e[37;5m Tips \e[0m\e[37m=====+++++++\e[0m
\e[1mrecord terminal: rec\e[0m
\e[1mplay recordfile: play [filename]\e[0m
\e[1mbackup configs : backup\e[0m

\e[37m+++++=====\e[0m\e[37;5mLet's Begin\e[0m\e[37m====+++++\e[0m"

#******** PATH ********
#proxy | use privoxy transfer socks5 to http
#export ALL_PROXY="socks5://127.0.0.1:1080"
#export no_proxy=
#export ftp_proxy=
#export socket_proxy=
#export http_proxy="http://127.0.0.1:8010"
#export https_proxy="http://127.0.0.1:8010"

alias proxyon="export http_proxy='http://127.0.0.1:8010';export https_proxy='http://127.0.0.1:8010'"
alias proxyoff="unset https_proxy;unset https_proxy"

# ******** alias ********

# ----- device&system -----

#trim for ssd
alias trim='sudo fstrim -v /home && sudo fstrim -v /'

#mount win
alias win='sudo ntfs-3g /dev/sda3 /mnt/windows'

#---power---

alias hs='sudo systemctl hybrid-sleep'
alias hn='sudo systemctl hibernate'
alias sp='sudo systemctl suspend'
alias pf='sudo systemctl poweroff'

#no network save power
alias nonetwork='sudo killall syncthing syncthing-gtk megasync smb nmb telegram-desktop workrave' #ss-qt5

# powertop
alias powertopauto='sudo powertop --auto-tune'

#tlp
alias tlpbat='sudo tlp bat'
alias tlpac='sudo tlp ac'
alias tlpcputemp='sudo tlp-stat -t'

#battery info
alias batsate='cat /sys/class/power_supply/BAT0/capacity'

#CPU freq
alias cpuwatch='watch -d -n 1 cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq'

#----GPU---
alias nvidiaoff='sudo tee /proc/acpi/bbswitch <<<OFF'
alias nvidiaon='sudo tee /proc/acpi/bbswitch <<<ON'
alias nvidiasettings='sudo optirun -b none nvidia-settings -c :8'

#---audio---
#beep
alias beep='sudo rmmod pcspkr && sudo echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf'

#---wireless---

#bluetooth
alias bluetoothon='sudo systemctl start bluetooth'
alias bluetoothoff='sudo systemctl stop bluetooth'

#---print---
alias printer='sudo systemctl start org.cups.cupsd.service'

#===system commands===

#---Arch Linux---
#aur helper
alias up='yay'

#pacman
alias pacman='sudo pacman'
alias orphan='pacman -Rscn $(pacman -Qtdq)'

#makepkg aur packing
alias aurinfo='makepkg --printsrcinfo > .SRCINFO ; git status'

#---temporary locale---
alias x='export LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 LC_MESSAGES=en_US.UTF-8 && startx'
alias xtc='export LANG=zh_TW.UTF-8 LC_CTYPE=zh_TW.UTF-8 LC_MESSAGES=zh_TW.UTF-8 && startx'
alias xsc='export LANG=zh_CN.UTF-8 LC_CTYPE=zh_CN.UTF-8 LC_MESSAGES=zh_CN.UTF-8 && startx'

alias cn='export LANG=zh_CN.UTF-8 LC_CTYPE=zh_CN.UTF-8 LC_MESSAGES=zh_CN.UTF-8'
alias en='export LANGUAGE=en_US.UTF-8'

# ---logs---
# clear 2 weeks ago logs
alias logclean='sudo journalctl --vacuum-time=2weeks'

#---file operation---

alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'

if [[ `which bat` ]]
then
  alias cat=bat
fi

if [[ -d ~/.local/share/Trash/files ]]
then
  alias rm='mv -f --target-directory=$HOME/.local/share/Trash/files/'
fi

alias cp='cp -i'

alias grep='grep --color'

alias tree='tree -C -L 1 --dirsfirst'

alias atd='systemctl start atd'

# clean unused files
alias cleanoldlinks='sudo rm $(find -xtype l -print)'

# ===common tools short commands===
#backup important files
alias backup="echo 'Starting'\
&& \cp -f ~/.bashrc ~/.gitconfig ~/.vimrc ~/.makepkg.conf ~/.bash-powerline.sh\
 -t\
 ~/Documents/it/itnotes/linux/config-backup/userhome/\
&& echo "Done!"
"

#---network---
# proxychains
alias px='proxychains'

# ssh server
alias sshstart='sudo systemctl start sshd'

# update hosts
alias hosts='sudo curl -# -L -o /etc/hosts https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/hosts'

# shadowsocks 1080
alias ssstart='sudo systemctl start shadowsocks@ss'
alias ssstop='sudo systemctl stop shadowsocks@ss'
alias ssrestart='sudo systemctl restart shadowsocks@ss'

# privoxy 8010
alias privoxystart='sudo systemctl start privoxy'
alias privoxyrestart='sudo systemctl restar privoxy'
alias privoxyrestop='sudo systemctl stop privoxy'

#---nmap
#scan alive hosts
alias 'nmap-hosts'="sudo nmap -sS `echo $gateway|cut -d '.' -f 1-3`.0/24"

#install/update geoip database
alias geoipdata="cd /tmp && wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz && wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz && gunzip GeoIP.dat.gz && gunzip GeoIPASNum.dat.gz && gunzip GeoLiteCity.dat.gz && sudo cp GeoIP.dat GeoIPASNum.dat GeoLiteCity.dat /usr/share/GeoIP/ && cd -"

#---convert tools----

#iconv -- file content encoding
alias iconvgbk='iconv -f GBK -t UTF-8'
#convmv -- filename encoding
alias convmvgbk='convmv -f GBK -T UTF-8 --notest --nosmart'

#asciinema record terminal
alias rec='asciinema rec -i 5 terminal-`date +%Y%m%d-%H%M%S`'  #record
alias play='asciinema play'  #play record file

#teamviwer
alias tvstart='sudo systemctl start teamviewerd.service'

#docker
alias dockerstart='sudo systemctl start docker && docker ps -a'

#libvirtd
alias virt='sudo modprobe virtio && sudo systemctl start libvirtd ebtables dnsmasq'

#youdao dict 有道词典
alias yd='ydcv'

#npm -g list --depth=0
alias npmlistg='sudo npm -g list --depth=0'

#docker container
alias hack='sudo systemctl start docker && docker start hack && docker exec -it hack bash'

#---for fun---
#cmatrix
alias matrix='cmatrix'

#starwar
alias starwar='telnet towel.blinkenlights.nl'

#=======

#bash-powerline : https://github.com/riobard/bash-powerline
source ~/.bash-powerline.sh
