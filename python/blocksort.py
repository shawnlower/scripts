#!/usr/bin/python
#
# Sort blocks of text
#

import argparse
import os
import re
import subprocess
from subprocess import PIPE
import sys

DEFAULT_MATCH_STRING='^/.*'

def do_sort(sorter, command):
    return sorter(command)

def sort_simple(block):
    """
    Sort a block of text using internal python methods
    """

    sorted_text = sorted(block)
    return sorted_text

def external_sort(command, block):
    """
    Sort a block using and external command.
    """

    text = "".join(block)
    p = subprocess.Popen(command.split(), stdin=PIPE, stdout=PIPE, stderr=PIPE)
    (stdout, stderr) = p.communicate(text)
    if p.returncode != 0:
        print >>sys.stderr, "Error while executing sort command:\n stdout: %s"\
                            "\n stderr: %s" % (str(stdout), str(stderr))
        sys.exit(1)
    else:
        return stdout

def main(args):
    filename = args.file
    # We have a few built-in sorters, e.g. sort_simple()
    if args.command.startswith('sort_') and args.command in locals():
        sorter = locals()[args.command]
    else:
        sorter = do_sort(external_sort, command)

    pattern = args.pattern

    content = filename.readlines()

    output = []
    block = []
    blocks_found = 0
    for line in content:
        if re.match(pattern, line):
            block.append(line)
        else:
            blocks_found += 1
            output.append("".join(sorter(block)))
            block = []
            output.append(line)
    output.append("".join(sorter(block)))

    print "".join(output)

    sys.stdout.flush()
    print >>sys.stderr, "%s blocks found" % blocks_found

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Block sort')
    parser.add_argument('--file', '-f', default=sys.stdin, required=False, 
                        help="File to sort. Defaults to stdin", 
                        type=argparse.FileType('r'))
    parser.add_argument('--command', '-c', help='Sort command. If command '
            'requires arguments, the entire commandline must be quoted. Use {}'
            ' for the file.', default='sort_simple')
    parser.add_argument('--regex', '-r', help="Regex match to identify",
                        destination=pattern, default='^/.*',
                        "sequential lines in a block. Default: '%s'" %
                        DEFAULT_MATCH_STRING)
    args = parser.parse_args()

    try:
        main(args)
    except IOError:
        # e.g. broken pipe when piping script through less
        pass
