#!/bin/bash

# Set variables
SNAPSHOT_PATH=/home/$(logname)/.snapshot
CUR_SNAP=CUR_SNAPSHOT
PREV_SNAP=PREV_SNAPSHOT
INCLUDE_FILES=(
    "/etc/passwd"
    "/etc/group"
    "/etc/shadow"
)
EXCLUDE_DIRS=(
    "/dev/*"
    "/proc/*"
    "/sys/*"
    "/tmp/*"
    "/run/*"
    "/mnt/*"
    "/media/*"
    "/lost+found"
    "/home/$(logname)/.snapshot"
)

# Check if snapshot path exists
dirs=($SNAPSHOT_PATH/$CUR_SNAP $SNAPSHOT_PATH/$PREV_SNAP)
	for dir in ${dirs[@]}; do
		if [ ! -d $dir ]; then
			echo "mkdir $dir"
			if ! mkdir -p $dir; then
				echo "Can't create folder at path $dir; PLEASE SET THE CORRECT BACKUP_PATH in the script; exit"
				exit 0
			fi
		fi
	done
	
# Ask user whether to create a snapshot or restore from a snapshot
echo "Do you want to create a snapshot or restore from a snapshot? (enter 1.'create' or 'restore'\n
2.'prev_create' or 'prev_restore')"
read choice

# Use case statement to execute the appropriate command
case "$choice" in
    "create")
        # Take snapshot using rsync
        rsync -aAXH --info=progress2 --delete \
            --exclude-from=<(printf "%s\n" "${EXCLUDE_DIRS[@]}") \
            $(printf "%s\n" "${INCLUDE_FILES[@]/#/--include=}") \
            / "$SNAPSHOT_PATH/$CUR_SNAP"
        echo "Snapshot complete!"
        ;;
    "restore")
        # Restore snapshot using rsync
        rsync -aAXH --info=progress2 --delete \
            --exclude-from=<(printf "%s\n" "${EXCLUDE_DIRS[@]}") \
            "$SNAPSHOT_PATH/$CUR_SNAP" /
        echo "Restoration complete!"
        ;;
        "prev_create")
        # Take snapshot using rsync
        rsync -aAXH --info=progress2 --delete \
            --exclude-from=<(printf "%s\n" "${EXCLUDE_DIRS[@]}") \
            $(printf "%s\n" "${INCLUDE_FILES[@]/#/--include=}") \
            / "$dirs"
        echo "Snapshot complete!"
        ;;
    "prev_restore")
        # Restore snapshot using rsync
        rsync -aAXH --info=progress2 --delete \
            --exclude-from=<(printf "%s\n" "${EXCLUDE_DIRS[@]}") \
            "$SNAPSHOT_PATH/$PREV_SNAP" /
        echo "Restoration complete!"
        ;;
    *)
        echo "Invalid choice; exiting"
        exit 1
        ;;
esac

