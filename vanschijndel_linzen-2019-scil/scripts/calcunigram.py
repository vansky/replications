'''
Compute unigram counts from a corpus

Usage: python script.py < wikitext-103.train > counts.txt 
'''
import sys
import math

unigrams = {}
total = 0
for line in sys.stdin:
    for word in line.strip().split():
        if word not in unigrams:
            unigrams[word] = 0.0
        unigrams[word] += 1.0
        total += 1.0
print('word unigram')
for word in unigrams:
    print(word+' '+str(math.log(unigrams[word] / total)))
    
