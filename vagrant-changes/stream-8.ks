auth --enableshadow --passalgo=sha512 --kickstart
clearpart --all --initlabel
# autopart 
part  /boot     --asprimary  --size=1024
part  /         --asprimary  --size=70000 --grow
part  swap                   --size=1024
bootloader --location=mbr --append="no_timer_check console=tty0 console=ttyS0,115200n8 elevator=noop"
cdrom
eula --agreed
firewall --disabled
firstboot --disabled
install
keyboard us
lang en_US
network --bootproto=dhcp
reboot
repo --name="AppStream" --baseurl=file:///run/install/repo/AppStream
rootpw vagrant
selinux --permissive
skipx
text
timezone UTC
user --name=vagrant --plaintext --password vagrant
zerombr
%packages
@standard
rsync
-intltool
-fprintd-pam
# Remove microcode_ctl, ehem VM!
-microcode_ctl 
# Remove plymouth, ehem VM!
-plymouth
# Remove unnecessary firmware
-aic94xx-firmware
-alsa-firmware
-alsa-tools-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl105-firmware
-iwl135-firmware
-iwl2000-firmware
-iwl2030-firmware
-iwl3160-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-iwl7260-firmware
-iwl7265-firmware
-libertas-sd8686-firmware
-libertas-sd8787-firmware
-libertas-usb8388-firmware
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-ql2500-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware
-vdo
%end
%post
# sudo
echo "%vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
%end
