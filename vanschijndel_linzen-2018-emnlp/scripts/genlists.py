# python script prepobjs.dev.sents doubleobjects.dev.sents prepobjs.test.sents doubleobjects.test.sents controls.sents
import os
import sys
import copy
import random

from nltk import sent_tokenize

NCRITS = 100
Ncontrols = 1000
Nvariants = 10 # number of quadruples to generate

# name the output files based on the input filenames
list1fname = sys.argv[1].split('.')[0]
list2fname = sys.argv[2].split('.')[0]

with open(sys.argv[1],'r') as f:
    # prepobjs dev
    items1 = f.readlines()
with open(sys.argv[2],'r') as f:
    # double-objects dev
    items2 = f.readlines()
with open(sys.argv[3],'r') as f:
    # prepobjs test
    items3 = f.readlines()
with open(sys.argv[4],'r') as f:
    # double-objects test
    items4 = f.readlines()
controls = []
with open(sys.argv[5],'r') as f:
    # controls
    for fchunk in f.readlines():
        for line in sent_tokenize(fchunk):
            controls.append(line.strip())

random.seed(1928)

for variant in range(Nvariants):
    # Create 10 dev and test quadruples that share one set of control items
    # Each dev-pair will have the same items in the same order
    #   but the critical items in one will be doubleobjs
    #   and in the other they will be prepobjs
    # Each test-pair will be the same but with different critical items

    # Sample without replacement
    # We don't want any critical items to be duplicated within a set
    #   or to be shared between dev and test
    devitemixs = random.sample(range(0,len(items1)),NCRITS)
    testitemixs = random.sample(range(0,len(items3)),NCRITS)

    # Item sets including controls
    itemlist1 = random.sample(controls,Ncontrols)
    itemlist2 = copy.copy(itemlist1)
    itemlist3 = copy.copy(itemlist1)
    itemlist4 = copy.copy(itemlist1)
    # Item sets with no control sentences
    itemlist5 = []
    itemlist6 = []
    itemlist7 = []
    itemlist8 = []

    for itemix in devitemixs:
        # Note that itemlist1 and itemlist2 have the exact same control
        # stims but are syntactically distinct
        itemlist1.append(items1[itemix])
        itemlist2.append(items2[itemix])
        itemlist5.append(items1[itemix])
        itemlist6.append(items2[itemix])
    for itemix in testitemixs:
        # Note that itemlist3 and itemlist4 have the exact same control
        # stims but are syntactically distinct
        itemlist3.append(items3[itemix])
        itemlist4.append(items4[itemix])
        itemlist7.append(items3[itemix])
        itemlist8.append(items4[itemix])

    # shuffle orderings
    devordering = range(len(itemlist1))
    random.shuffle(devordering)
    testordering = range(len(itemlist3))
    random.shuffle(testordering)

    # populate the lists with the shuffled orderings
    itemlist1 = [ itemlist1[i] for i in devordering ]
    itemlist2 = [ itemlist2[i] for i in devordering ]
    itemlist3 = [ itemlist3[i] for i in testordering ]
    itemlist4 = [ itemlist4[i] for i in testordering ]

    try:
        # make an output directory if it doesn't exist
        os.mkdir('output')
    except:
        # output already exists
        pass
    
    # write the lists out to files in output
    with open('output/{0!s}.{1!s}-{2!s}.dev.{3:d}.sents'.format(list1fname,NCRITS,Ncontrols,variant),'w') as f:
        for sent in itemlist1:
            f.write('{0!s}'.format(sent))
    with open('output/{0!s}.{1!s}-{2!s}.dev.{3:d}.sents'.format(list2fname,NCRITS,Ncontrols,variant),'w') as f:
        for sent in itemlist2:
            f.write('{0!s}'.format(sent))
    with open('output/{0!s}.{1!s}-{2!s}.test.{3:d}.sents'.format(list1fname,NCRITS,Ncontrols,variant),'w') as f:
        for sent in itemlist3:
            f.write('{0!s}'.format(sent))
    with open('output/{0!s}.{1!s}-{2!s}.test.{3:d}.sents'.format(list2fname,NCRITS,Ncontrols,variant),'w') as f:
        for sent in itemlist4:
            f.write('{0!s}'.format(sent))
    with open('output/{0!s}.{1!s}-0.dev.{2:d}.sents'.format(list1fname,NCRITS,variant),'w') as f:
        for sent in itemlist5:
            f.write('{0!s}'.format(sent))
    with open('output/{0!s}.{1!s}-0.dev.{2:d}.sents'.format(list2fname,NCRITS,variant),'w') as f:
        for sent in itemlist6:
            f.write('{0!s}'.format(sent))
    with open('output/{0!s}.{1!s}-0.test.{2:d}.sents'.format(list1fname,NCRITS,variant),'w') as f:
        for sent in itemlist7:
            f.write('{0!s}'.format(sent))
    with open('output/{0!s}.{1!s}-0.test.{2:d}.sents'.format(list2fname,NCRITS,variant),'w') as f:
        for sent in itemlist8:
            f.write('{0!s}'.format(sent))
