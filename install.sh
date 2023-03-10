echo '--NCH ARCH INSTALLER'
echo '----NOT FOR DUAL-BOOTING!!'; sleep 1

echo 'Verifying boot mode (W. 1.6)'
ls /sys/firmware/efi/efivars &&
read -p '[Enter to continue]'

echo 'First YOU have to'
echo '1) set the console keyboard layout (W. 1.5)'
echo '3) Connect to the internet (W. 1.7)'
echo '4) Create (& specify) the partitions (W. 1.9)'
echo -- /dev/$1 -> boot part.
echo -- /dev/$2 -> swap part.
echo -- /dev/$3 -> root part.
read -p 'If you have, [Enter] to continue'
echo '-- INSTALL'
read -p 'Update the system clock (W. 1.6) [any key to proceed]'
timedatectl status &&
read -p '[Enter to continue]'

echo 'Formatting disks (W. 1.10)'
echo -- /dev/$1 -> to FAT32
echo -- /dev/$2 -> to SWAP
echo -- /dev/$3 -> to EXT4
read -p '[any key to format]'
mkfs.fat -F 32 /dev/$1 &&
mkfs.ext4 /dev/$3 &&
mkswap /dev/$2 &&
# verify
lsblk -f
read -p "[Enter to continue]"

echo 'Mount fs (W. 1.11)'
echo -- /dev/$1 : to /mnt/boot
echo -- /dev/$2 : swapon
echo -- /dev/$3 : to /mnt
read -p '[Enter to proceed]'
mount /dev/$3 /mnt &&
mount --mkdir /dev/$1 /mnt/boot &&
swapon /dev/$2 &&
# verify
lsblk -f
read -p "[Enter to continue]"

echo 'Now installing essential packages (W. 2.2)'
echo '(verify before installing)'
read -p 'Pick a kernel [linux, linux-hardened\lts\rt(rt-lts)\zen]: ' ker
cat packages | pacstrap -Ki /mnt $ker - &&

read -p "Generate fstab (W. 3.1) [any key to proceed]"
genfstab -U /mnt >> /mnt/etc/fstab &&
cat /mnt/etc/fstab
read -p "[Enter to continue]"

cp -r ~/nch-archinstall /mnt/root &&
echo 'Files copied to /mnt/root'

echo 'Now chroot into the new system (W. 3.2) and proceed'
