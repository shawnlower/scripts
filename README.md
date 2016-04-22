# scripts

A collection of shell/python/ruby/??? scripts to make life easier.

blocksort.py:
    Sorts an input text-file by blocks, e.g.:

        First block of text
        123 Foo
        344 Bar
        990 Biz

        Next section
        541 Jack
        12  Jane
        999 Jill
        
    Will keep the sections together, and sort the contents in-place

clip.sh
    Simply calls xclip based on whether stdin is a terminal. Ex:

        $ cat amazing.py | clip     # Store script in clipboard
        $ clip                      # Dump clipboard
        $ clip | curl -sT chunk.io  # Pipe clipboard to curl
        $ clip | grep 'foo' | clip  # Modify clipboard

system-sleep-domains.sh

    Causes all running VMs to be saved to disk by libvirt when the system goes
    into suspend. Prevents issues with guests hanging with 100% CPU util on
    resume. Also, allows recovery of guest if the system does not return from
    suspend (e.g. dead battery).

    This script should be symlinked to:
        /usr/lib/systemd/system-sleep/system-sleep-domains.sh
