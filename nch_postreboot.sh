echo 'POST-REBOOT CONFIG'
echo 'This script expects to be run as root (before creating users)'

echo '--Network Manager'
read -p '[Enter to start/enable NM]'
systemctl start NetworkManager.service
systemctl enable NetworkManager.service
read -p 'Done [Enter to continue]'

echo '--systemd-boot auto update (NO SECURE BOOT)'
read -p '[Enter to enable auto update]'
systemctl enable systemd-boot-update.service
read -p 'Done [Enter to continue]'

echo '--General recommendations:'
read -p 'New user: ' NEWUSER
useradd -m $NEWUSER
passwd coriollis
chown $NEWUSER -R /home/$NEWUSER
read -p 'Done [Enter to continue]'

