'''
Removes multi-token words from evmeasures

Usage: python script.py < in.evmeasures > norolled.evmeasures
'''
import sys

FIRST = True
rix = 0

for line in sys.stdin:
    sline = line.strip().split()
    if FIRST:
        rix = sline.index('rolled')
        FIRST = False
    else:
        if sline[rix] != '0.0':
            continue
    print(line.strip())
