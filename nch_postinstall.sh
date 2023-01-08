echo ---POSTINSTALL

read -p 'Setting time zone to Mexico City (W. 3.3) [any key to proceed]'
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime && hwclock --systohc &&
read -p 'Done. Any key to continue.'

read -p 'Add US and MX utf-8 locales, set MX as lang, change key layout. (W. 3.4) [any key to proceed]'
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen &&
sed -i 's/#es_MX.UTF-8 UTF-8/es_MX.UTF-8 UTF-8/' /etc/locale.gen &&
locale-gen &&
echo LANG=es_MX.UTF-8 > /etc/locale.conf && cat /etc/locale.conf
echo KEYMAP=la-latin1 > /etc/vconsole.conf && cat /etc/vconsole.conf

read -p 'Specify hostname (W. 3.5): ' hostname
echo $hostname > /etc/hostname
read -p 'Done. Remember to setup network after reboot. Any key to continue.'

read -p 'Define root passwd (W. 3.7) [any key to proceed]'
passwd &&
read -p 'Done. Any key to continue.'

read -p 'Setup bootloader (systemd-boot) (W. 3.8) [any key to proceed]'
read -p 'Boot foolder? (e.g. /boot): ' ESP
read -p 'Root partition? (e.g. sda3, no /dev/): ' ROOT_PARTITION
read -p 'Installed? (e.g. Linux/Zen): ' KERNEL
bootctl install &&
echo 'default arch.conf' > $ESP/loader/loader.conf
echo 'timeout 1' >> $ESP/loader/loader.conf
echo 'console-mode max' >> $ESP/loader/loader.conf
echo 'editor no' >> $ESP/loader/loader.conf
echo title Arch $KERNEL > $ESP/loader/entries/arch.conf
# detect vmlinuz-file
VMFILE=$(ls /boot | grep vmlinuz)
echo linux /$VMFILE > $ESP/loader/entries/arch.conf
echo initrd /intel-ucode.img > $ESP/loader/entries/arch.conf
echo initrd /$(ls /boot | grep -v fallback - | grep initramfs -) > $ESP/loader/entries/arch.conf
echo options root=/dev/$ROOT_PARTITION rw > $ESP/loader/entries/arch.conf
## fallback initramfs
echo title Arch $KERNEL (fallback) > $ESP/loader/entries/arch-fallback.conf
echo linux /$VMFILE > $ESP/loader/entries/arch-fallback.conf
echo initrd /intel-ucode.img > $ESP/loader/entries/arch-fallback.conf
echo initrd /$(ls /boot | grep fallback -) > $ESP/loader/entries/arch-fallback.conf
echo options root=/dev/$ROOT_PARTITION rw > $ESP/loader/entries/arch-fallback.conf
