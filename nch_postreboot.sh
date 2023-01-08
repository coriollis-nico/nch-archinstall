echo 'POST-REBOOT CONFIG'
echo 'This script expects to be run as root (before creating users)'

echo '--Network Manager'
read -p '[Enter to start/enable NM]'
systemctl start NetworkManager.service
systemctl enable NetworkManager.service
read -p 'Done [Enter to continue]'

echo '--systemd-boot auto update (NO SECURE BOOT)'
read -p '[Enter to enable auto update]'
systemctl enable systemd-boot-update.service &&
read -p 'Done [Enter to continue]'

echo '--General recommendations:'
read -p 'New user: ' NEWUSER
useradd -m $NEWUSER &&
passwd $NEWUSER &&
chown $NEWUSER -R /home/$NEWUSER &&
read -p 'Done [Enter to continue]'

read -p '[Enter to config. sudo]'
EDITOR=nano visudo
read -p 'Done [Enter to continue]'

echo '[Enter to activate firewalld]'
read -p '(You will have to configure it afterwards)'
systemctl enable firewalld.service &&
systemctl start firewalld.service &&
read -p 'Done [Enter to continue]'

read -p '[Enter to configure pacman]'
rnano /etc/pacman.conf
read -p '[Enter to activate reflector (default config)]'
systemctl enable reflector.service &&
read -p 'Done [Enter to continue]'

read -p '[Enter to start/enable thermald]'
systemctl start thermald.service &&
systemctl enable thermald.service &&
read -p '[Enter to config. & enable cpupower]'
rnano /etc/default/cpupower
systemctl enable cpupower.service &&
read -p 'Done (check the CPU frec. scaling wiki for specific configs. for DEs) [Enter to continue]'

echo 'You now can run the encryption script and/or DE install script'
echo 'Also consider USBGuard and modprobed-db'
