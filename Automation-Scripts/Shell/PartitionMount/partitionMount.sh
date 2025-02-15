####################################################################
# Author: Suraj Chopade
# This script is used to install the NDR sensor.
#
# Usage:
#   ./partitionMount.sh
#
# Make sure to run this script with appropriate permissions.
####################################################################

# Below shell script which will perform the following 
#       - find the non partitioned volume in server
#       - partition the volume as primary and first partition
#       - format the partition with xfs filesystem type
#       - Label the newly formatted partition as '/ppro'
#       - create a mount point as '/ppronew'
#       - mount the new partion to created mount point
#       - append a permanent mount entry in fstab file as below
#         LABEL=/ppro	/ppro	xfs	defaults	0 0
#       - once fstab entry is completed run 'mount -a' command to mount everything
#       - change ownership with below command
#         chown admin.ppro /pprosl -R
#       - change permission of /ppro to 777 using below command
#         chmod 777 /ppro -R
# ===================================================================

#!/bin/bash

# Function to find the last non-partitioned, unformatted volume
find_non_partitioned_volume() {
    last_non_partitioned_device=""

    # List all block devices (disks only, no partitions)
    for disk in $(lsblk -dno NAME); do
        # Check if the device has no partitions and is not mounted or formatted
        if [ "$(lsblk -no TYPE /dev/$disk)" = "disk" ]; then
            if ! lsblk -no NAME /dev/$disk | grep -q "^${disk}[0-9]"; then
                if [ -z "$(blkid /dev/$disk)" ]; then
                    last_non_partitioned_device="/dev/$disk"
                fi
            fi
        fi
    done

    echo "$last_non_partitioned_device"
}

# Step 1: Find the last non-partitioned, unformatted volume
volume=$(find_non_partitioned_volume)

if [ -z "$volume" ]; then
    echo "No non-partitioned volume found."
    exit 1
fi

echo "Non-partitioned volume found: $volume"

# Step 2: Partition the volume as primary and first partition
echo "Partitioning the volume..."
(
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number 1
echo   # First sector (Accept default)
echo   # Last sector (Accept default)
echo w # Write changes
) | fdisk "$volume"

partition="${volume}1"
echo "Partition created: $partition"

# Step 3: Format the partition with XFS filesystem
echo "Formatting the partition with XFS filesystem..."
mkfs -t xfs "$partition"

# Step 4: Label the newly formatted partition as '/ppronew'
echo "Labeling the partition as '/ppronew'..."
xfs_admin -L "/ppronew" "$partition"

# Step 5: Create a mount point as '/ppronew'
echo "Creating the mount point at '/ppronew'..."
mkdir -p /ppronew

# Step 6: Mount the new partition to the created mount point
echo "Mounting the partition to '/ppronew'..."
mount "$partition" /ppronew

# Step 7: Append a permanent mount entry in the fstab file
echo "Appending the mount entry to /etc/fstab..."
echo "LABEL=/ppro   /ppronew   xfs   defaults   0 0" >> /etc/fstab

# Step 8: Run 'mount -a' to mount all entries in fstab
echo "Running 'mount -a' to mount all entries..."
mount -a

# Step 9: Change ownership
echo "Changing ownership to 'admin.ppro' for '/ppronew'..."
chown admin.ppro /ppronew -R

# Step 10: Change permissions
echo "Changing permissions of '/ppronew' to 777..."
chmod 777 /ppronew -R

echo "All tasks completed successfully."


