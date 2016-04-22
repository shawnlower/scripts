#!/bin/bash
#
# Save all running domains to disk. Useful, e.g. when the machine is going
# into suspend mode, since VMs seem to lock up when returning from suspend
# Also, paused (not saved) VMs may prevent the system from actually suspending
# and prevents data loss if host battery dies and not using hybrid-suspend
#
# (c) 2016 Shawn Lower
# shawn@shawnlower.com - license GNU GPL v2

# Lock dir
lock_dir=/var/tmp

function save_domains(){
    # Amount of required free space in addition to guest savefiles (in MiB)
    min_free_mb=2048

    # Location to store the save files
    # So we're now using libvirt to actually manage the save file
    # but we'll need this location for determining free space
    savefile_location='/var/lib/libvirt/qemu/save'

    # Get a list of all running domains
    domain_list="$(sudo virsh list | awk '$3 == "running" { print $2 }')"

    # Clean up old lock files
    for domain in $domain_list; do
        rm -f ${lock_dir}/${domain}.saved.by.suspend
    done

    # Determine whether we have sufficient disk space to suspend.
    total_mem_usage=0
    for domain in $domain_list; do
        dom_mem_usage="$(virsh dommemstat $domain | awk '/rss/ { print $2 }')"
        (( total_mem_usage+=$dom_mem_usage ))
    done

    # Mem usage is in KiB. Convert to MiB
    (( total_mem_usage = $total_mem_usage / 1024 ))

    echo "Total memory usage is: $total_mem_usage MiB"

    # Get available space in savefile location
    disk_free="$(df -m "$savefile_location" --output=avail | sed -n '2p')"

    echo "Free space in '$savefile_location': $disk_free MiB"

    if [[ $[ $disk_free - $total_mem_usage - $min_free_mb ] -lt 0 ]]; then
        echo "Insufficient memory to suspend:"
        echo "* Free space: $disk_free"
        echo "* Total memory usage of domains: $total_mem_usage"
        echo "* Additional headroom requested: $min_free_mb"
        exit 1
    fi

    echo "Suspending domains:"

    # Perform the actual save
    for domain in $domain_list; do
        echo "Saving domain ${domain}..."
        virsh managedsave --verbose $domain && touch ${lock_dir}/${domain}.saved.by.suspend
    done
}

function resume_domains(){
    # Resume domains that were previously saved via
    # system-sleep-domains.sh

    extension="saved.by.suspend"

    file_list=${lock_dir}/*.${extension}

    domains="$(
      for file in $file_list; do
          basename $file .saved.by.suspend
      done
    )"

    echo "Domains to resume: "$domains

    for domain in $domains; do
        virsh start $domain && rm -f ${lock_dir}/${domain}.${extension}
    done
}

case $1 in
    pre)
        # If we're hibernating, then this is redundant
        if [[ "$2" != "hibernate" ]]; then
            save_domains
        fi
        ;;

    post)
        if [[ "$2" != "hibernate" ]]; then
            resume_domains
        fi
        ;;

    *)
        echo "Error: invalid parameters."
        echo "usage: $0 (pre|post) (suspend|hibernate|hybrid-sleep)"
        exit 1
esac

