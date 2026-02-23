lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda           8:0    1     0B  0 disk 
nvme0n1     259:0    0 953.9G  0 disk 
├─nvme0n1p1 259:1    0   487M  0 part 
├─nvme0n1p2 259:2    0    32G  0 part /
├─nvme0n1p3 259:3    0    32G  0 part 
└─nvme0n1p4 259:4    0 889.4G  0 part /var/lib/docker
                                      /home
lsblk -f
NAME        FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sda                                                                                
nvme0n1                                                                            
├─nvme0n1p1 vfat   FAT32       4BFA-0C13                                           
├─nvme0n1p2 ext4   1.0         d78f2cb3-9c2b-41de-a168-be4b8c8962f3    1.3G    91% /
├─nvme0n1p3 swap   1           b87f2097-d65f-45a7-87dd-2dd5c0bc9931                
└─nvme0n1p4 ext4   1.0         5e517ae0-b34d-4192-a106-22bd4024b088    272G    64% /var/lib/docker
                                                                                   /home

## Partition Summary

- nvme0n1p1 is vfat efi partition 500MB
- nvme0n1p2 is root 32GB
- nvme0n1p3 is swap 32GB
- nvme0n1p4 is /home and /var/lib/docker 889GB
