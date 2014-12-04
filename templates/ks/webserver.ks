reboot --eject 
install
text
lang en_US.UTF-8
keyboard us
network --bootproto=static --ip={{server.service_ip}} --netmask={{server.service_netmask}} --gateway={{server.service_gw}} --device=eth0 --onboot=on --hostname=cdn.oss.letv.com
rootpw  --iscrypted $6$i2F/v4HM$hR4La9LdfLu.sOXEBTtnrPW.odIknz3.wnkH35IZTZNjUUkUvXTufut9zxS.xAnkbcm/mt/Q06gF/gdO/xH1h0
user --name=lele --password=$6$uOoLyAZ.$dfFEtnzTrbo9FM3LbwIKzI3L43evuszAg1BmGw4QdXoKoOxQ2D19BOt2PCh.tZ9d.23DaZvp/8KJJPpBslADx.  --iscrypted
user --name=zabbix --password=$6$k2OhAeyj$5Iw2hycO34pPEuQ2k61ieMpf9/38OJ6Lx1KHHE8IxWgNHY9EslrcU/AmjRT/QpVFyHq.Aeu2LFYFqueos5PCx/ --iscrypted --homedir=/usr
/local/zabbix
firewall --disabled
authconfig --enableshadow --passalgo=sha512
selinux --disabled
timezone --utc Asia/Shanghai
services  --disabled=atd,avahi-daemon,abrtd,cups,ip6tables,iptables,kudzu,portmap,rpcidmapd,postfix,rpcbind,nfslock,mdmonitor,netfs,portreserve
bootloader --location=mbr --append=" console=tty0 console=ttyS1,115200n8 debug printk.time=1 elevator=deadline biosdevname=0"
zerombr
%include /tmp/part-include
%pre
#/bin/sh
for i in `ls /sys/block`
do
   if [ `cat /sys/block/$i/removable` -eq 1 ];then
      name="$i|"$name
   fi
done
[ ! -z $name ]  &&  disk=`echo "$name""mapper"` || disk="mapper"
hddisk=`fdisk  -l 2>/dev/null |egrep -vi "($disk)" |grep "^Disk /dev/"|awk 'BEGIN{m=100000;}{if($4 ~ /[GgBb]/){name[$2]=$3;n++;}} END{if(n>1){for(aa in nam
e){if(m>name[aa]){m=name[aa];dev=aa;}}print dev;}else{for(aa in name) print aa}}'|sed -e 's/\/dev\///;s/://'`
echo "#partitioning scheme generated in %pre for 1 drive" > /tmp/part-include
echo "clearpart --all --initlabel --drives=$hddisk" >> /tmp/part-include
echo "part pv.008002 --grow --size=1 --ondisk=$hddisk" >> /tmp/part-include
echo "part /boot --fstype=ext4 --size=500 --ondisk=$hddisk" >> /tmp/part-include
echo "part swap --size=6000 --ondisk=$hddisk" >> /tmp/part-include
echo "volgroup VGSYS --pesize=4096 pv.008002" >> /tmp/part-include
echo "logvol / --fstype=ext4 --name=lv_root --vgname=VGSYS --size=8000" >> /tmp/part-include
echo "logvol /var --fstype=ext4 --name=lv_var --vgname=VGSYS --size=8000" >> /tmp/part-include
echo "logvol /letv --fstype=xfs --name=lv_letv --vgname=VGSYS --grow --size=1" >> /tmp/part-include

# Add  hostprogress
sn=`dmidecode  -s system-serial-number`
total=
server="10.154.156.187"
while : ;do
    if [ -f /mnt/sysimage/root/install.log ]; then
       dangqian=`wc -l /mnt/sysimage/root/install.log|awk '{print $1}'`
       jindu=$((${dangqian}00/$total))
       if [ $jindu  -eq "100" ];then
           curl -d "jindu=$jindu" "http://${server}:8080/jindu_post/$sn/"
           break
       else
           curl -d "jindu=$jindu" "http://${server}:8080/jindu_post/$sn/"
       fi
       sleep 5
    else
       sleep 10
    fi
done  &
%end

%packages
@additional-devel
@base
@console-internet
@core
@development
@dial-up
@large-systems
@legacy-unix
@network-tools
@performance
@perl-runtime
@system-management-snmp
@server-policy
kernel-debuginfo
pcre-devel
libXinerama-devel
xorg-x11-proto-devel
libbonobo-devel
libXau-devel
libgcrypt-devel
popt-devel
libXrandr-devel
libxslt-devel
libglade2-devel
gnutls-devel
mtools
sgpio
dos2unix
unix2dos
screen
libhugetlbfs-utils
ftp
telnet
tcp_wrappers
iptraf
wireshark
perl-DBD-SQLite
oprofile
dnsmasq
tcptrace
-gnome-keyring-devel
-java-1.6.0-openjdk-devel
-mysql-devel
-gnome-desktop-devel
-postgresql-devel
-mlocate
-elinks
-xinetd
-openswan
-powertop
-perf
-seekwatcher
-latencytop
-perl-XML-Twig
-perl-XML-Grove
-perl-XML-Dumper
axel
pcre-devel
openssl-devel
xfsprogs
ntpdate
ntp
bind
bind-utils
compat-readline5
perl-CGI
perf
fping
facter-1.6.0
puppet-2.6.11
smokeping
monit
Lib_Utils
MegaCli
python-perf
ipmitool-letv
libnl-devel
nethogs
hpacucli
xorg-x11-xauth
letv-lsiutil
letv-release
sysinit
%end

%post
echo "The system is initializing, please wait"
/bin/bash /etc/sysinit.sh
/bin/rm /etc/sysinit.sh
echo "Initialization is complete, Now restart."
echo LetvOS-1.5.4 >/etc/letv-release
########################

cat > /etc/issue << EOF
LetvOS WebServer 1.5.4 (Final)
Kernel \r on an \m
Last boot at \d \t

EOF

sed -i "s/CentOS/LetvOS/" /etc/rc.d/rc.sysinit
sed -i "s/^start/#start/" /etc/init/control-alt-delete.conf
sed -i "s/^exec/#exec/" /etc/init/control-alt-delete.conf
########################
echo '#!/bin/bash' > /etc/start.sh
echo 'echo "-------------------------------------------------------"' >> /etc/start.sh
echo 'echo `cat /etc/issue | awk NR==1`' >> /etc/start.sh
echo 'echo "Kernel `uname -r` on an `uname -m`"' >> /etc/start.sh
echo 'echo -e "Last boot at `date -d "$(awk -F. VARIABLES /proc/uptime) second ago" +"%Y-%m-%d %H:%M:%S"`\n"' >> /etc/start.sh
sed -i "s/VARIABLES/'{print \$1}'/" /etc/start.sh

if [[ -n $(more /boot/grub/grub.conf | grep pci=nomsi) ]] && [[ ! -n $(more /etc/udev/rules.d/70-persistent-net.rules | grep bnx2) ]]
then
sed -i "s/pci=nomsi//" /boot/grub/grub.conf
fi

echo '[ -z "$PS1" ] && return' >> /etc/bashrc
echo '/bin/sh /etc/start.sh' >> /etc/bashrc
#finish install
sn=`dmidecode  -s system-serial-number`
curl -d "sn=$sn" "http://10.154.156.187:8080/finish/"
########################
%end
