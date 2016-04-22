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
        
    Will be keep the sections together, and sort the contents in-place

clip.sh
    Simply calls xclip based on whether stdin is a terminal. Ex:

        $ cat amazing.py | clip     # Store script in clipboard
        $ clip                      # Dump clipboard
        $ clip | curl -sT chunk.io  # Pipe clipboard to curl
        $ clip | grep 'foo' | clip  # Modify clipboard
