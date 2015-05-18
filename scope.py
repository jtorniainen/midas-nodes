#!/usr/bin/env python3

# Script for starting LSL visualizations from the command line
# Jari Torniainen 2015
# Finnish Institute of Occupational Health

from midas.node import lsl
from lsltools.vis import Grapher
import sys


def list_streams():
    """ Print all visible LSL streams. """
    streams = lsl.resolve_streams()
    print("\nAvailable streams:")
    for stream in streams:
        print("  %s(%s)@%s[%dHz]" % (stream.name(),
                                     stream.type(),
                                     stream.hostname(),
                                     stream.nominal_srate()))


def plot(stream_name=None, win=200):
    """ Plot the specified stream. """
    #  = Grapher(stream, win)
    stream_found = False
    # Try to find the stream
    if stream_name:
        stream = lsl.resolve_byprop('name', stream_name)
        if stream:
            stream_found = True

    if stream_found:
        print("Starting visualization...")
        try:
            g = Grapher(stream[0], int(win))
        except:
            pass
    else:
        print("Stream not found/recognized!")
        list_streams()

if __name__ == '__main__':
    if len(sys.argv) <= 3:
        plot(*sys.argv[1:])
    else:
        print("scope.py takes max two (2) input arguments")
