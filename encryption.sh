echo 'ENCRYPTION SCRIPT'
echo '--Make sure to create the partition BEFORE running this (make sure it is encryption ready)'
echo '--Make sure user passwd and device passwd is the same'
read -p '[Enter to start]'
read -p 'Partition (no /dev/): ' PARTITION
read -p 'User: ' SETUP_USER
# Setup & test
cryptsetup luksFormat /dev/$PARTITION &&
cryptsetup open /dev/$PARTITION $NAME &&
mkfs.ext4 /dev/mapper/home-$SETUP_USER &&
cryptsetup open device home-$SETUP_USER &&
mount -t ext4 /dev/mapper/home-$SETUP_USER /mnt/home/$SETUP_USER &&
umount /mnt/home/$SETUP_USER &&
cryptsetup close home-$SETUP_USER &&

# Auto-mounting
## pam_cryptsetup
echo '#!/bin/sh' > /etc/pam_cryptsetup.sh
echo -e "\n" >> /etc/pam_cryptsetup.sh
echo CRYPT_USER="$SETUP_USERNAME" >> /etc/pam_cryptsetup.sh
echo MAPPER="/dev/mapper/home-"$CRYPT_USER >> /etc/pam_cryptsetup.sh
echo -e "\n" >> /etc/pam_cryptsetup.sh
echo CRYPT_USER="$SETUP_USERNAME" >> /etc/pam_cryptsetup.sh
echo if [ "$PAM_USER" == "$CRYPT_USER" ] && [ ! -e $MAPPER ] >> /etc/pam_cryptsetup.sh
echo then >> /etc/pam_cryptsetup.sh
echo "  /usr/bin/cryptsetup open /dev/sda2 home-$PAM_USER" >> /etc/pam_cryptsetup.sh
echo then >> /etc/pam_cryptsetup.sh
echo fi >> /etc/pam_cryptsetup.sh
## Editing system-auth
awk '/auth       optional/ { print; print "auth      optional  pam_exec.so expose_authtok quiet /etc/pam_cryptsetup.sh"; next }1' /etc/pam.d/system-auth > /etc/pam.d/system-auth
awk '/session    optional/ { print; print "session   optional  pam_exec.so quiet /etc/pam_cryptsetup.sh"; next }1' /etc/pam.d/system-auth > /etc/pam.d/system-auth
## auto mount-unmount
echo [Unit] > /etc/systemd/system/home-$SETUP_USER.mount
echo Requires=user@1000.service >> /etc/systemd/system/home-$SETUP_USER.mount
echo Before=user@1000.service >> /etc/systemd/system/home-$SETUP_USER.mount
echo -e "\n" >> /etc/systemd/system/home-$SETUP_USER.mount
echo [Mount] >> /etc/systemd/system/home-$SETUP_USER.mount
echo Where=/home/$SETUP_USERNAME >> /etc/systemd/system/home-$SETUP_USER.mount
echo What=/dev/mapper/home-$SETUP_USERNAME >> /etc/systemd/system/home-$SETUP_USER.mount
echo Type=ext4 >> /etc/systemd/system/home-$SETUP_USER.mount
echo Options=defaults,relatime >> /etc/systemd/system/home-$SETUP_USER.mount
echo -e "\n" >> /etc/systemd/system/home-$SETUP_USER.mount
echo [Install] >> /etc/systemd/system/home-$SETUP_USER.mount
echo RequiredBy=user@1000.service >> /etc/systemd/system/home-$SETUP_USER.mount
## (activate)
systemctl enable home-$SETUP_USERNAME.mount

# Lock after unmounting
echo [Unit] > /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo DefaultDependencies=no >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo BindsTo=dev-$PARTITION.device >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo After=dev-$PARTITION.device >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo BindsTo=dev-mapper-home\x2d$SETUP_USER.device >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo Requires=home-$SETUP_USER.mount >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo Before=home-$SETUP_USER.mount >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo Conflicts=umount.target >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo Before=umount.target >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo -e "\n" >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo [Service] >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo Type=oneshot >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo RemainAfterExit=yes >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo TimeoutSec=0 >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo ExecStop=/usr/bin/cryptsetup close home-$SETUP_USER >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo -e "\n" >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo [Install] >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
echo RequiredBy=dev-mapper-home\x2d$SETUP_USER.device >> /etc/systemd/system/cryptsetup-$SETUP_USER.service
## (activate)
systemctl enable cryptsetup-$SETUP_USER.service

echo "Done. Try it out"
