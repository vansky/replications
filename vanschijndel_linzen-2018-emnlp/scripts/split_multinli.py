'''
Splits the premise sentences from the MultiNLI corpus into
separate files based on genre.

Usage: python split_multinli.py < input output_dir filename_modifier

input: multinli txt file
output_dir: location to store the output files
filename_modifier: a modifier to the output filenames
  I use "train" or "dev" depending on the input file 
'''

import sys

header = []
corpora = {}
HEADERLINE = True
for line in sys.stdin:
    sline = line.strip().split("\t")
    if HEADERLINE:
        # Use the header to identify the relevant portions of MultiNLI
        HEADERLINE=False
        header = sline
        genix = header.index('genre')
        premix = header.index('sentence1')
        continue
    # Accumulate each genre's premises into a single collection
    if sline[genix] not in corpora:
        corpora[sline[genix]] = []
    corpora[sline[genix]].append(sline[premix])

# Output each genre to output_dir/genre-filename_modifier.txt
for genre in corpora:
    with open(sys.argv[1]+'/'+genre+'-'+sys.argv[2]+'.txt','w') as f:
        f.write('\n'.join(corpora[genre]))
