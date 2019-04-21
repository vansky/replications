'''
Inserts unigram probs into a dataframe file.

Usage: python script.py unigram_counts regresstable > regresstable.withunigrams
'''

import sys

unigrams = {}
FIRST = True
with open(sys.argv[1],'r') as f:
    for line in f:
        if FIRST:
            FIRST = False
            continue
        word,unilogprob = line.strip().split()
        unigrams[word] = unilogprob

FIRST = True
with open(sys.argv[2],'r') as f:
    for line in f:
        sline = line.strip().split()
        if FIRST:
            print(' '.join(sline+['fixedunigram']))
            FIRST = False
        else:
            if sline[0] in unigrams:
                print(' '.join(sline+[unigrams[sline[0]]]))
            else:
                print(' '.join(sline+[unigrams['<unk>']]))
