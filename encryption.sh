echo 'ENCRYPTION SCRIPT'
echo '--Make sure to create the partition BEFORE running this (make sure it is encryption ready)'
read -p 'Partition (no /dev/): ' PARTITION
read -p 'User: ' SETUP_USER
# Setuo & test
cryptsetup luksFormat /dev/$PARTITION
cryptsetup open /dev/$PARTITION $NAME
mkfs.ext4 /dev/mapper/home-$SETUP_USER
cryptsetup open device home-$SETUP_USER
mount -t ext4 /dev/mapper/home-$SETUP_USER /mnt/home/$SETUP_USER
umount /mnt/home/$SETUP_USER
cryptsetup close home-$SETUP_USER
# Auto-mounting
