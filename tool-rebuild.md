sda1 EFI
sda2 /
sda3 swap
sda4 /home

- install grub
- run grub-install
- run grub-mkconfig
- in chroot
  - systemctl enable NetworkManager
  - systemctl enable sddm
  - install NetworkManager network-manager-applet base-devel niri jq
