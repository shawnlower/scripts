#!/bin/bash
#
# Shortcut for clipboard
#
# If stdin is not a terminal, we assume we want to copy stdin to the clipboard
# otherwise, dump the clipboard contents to stdout
# 

# We could switch this to be primary, etc
SELECTION=clipboard

# Trying this will hang
if [ ! -t 0 ] && [ ! -t 1 ]; then
    echo "Simultaneous redirect of stdin and stdout is not supported."
    exit 1
fi

# If stdin is not a terminal, then
if [ ! -t 0 ]; then
    echo "Copying stdin to $SELECTION" >&2
    exec xclip -i -selection $SELECTION
else
    xclip -o -selection $SELECTION
    exit
fi

