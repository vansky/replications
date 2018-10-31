#!/bin/bash
# The following regular expressions are used to obtain corpus counts.
# They presuppose that you have a GCG-annotated version of the Wall Street Journal (WSJ) corpus.
# To obtain this, you will need access to the WSJ corpus, and you can download Modelblocks here: 
#   http://sourceforge.net/projects/modelblocks/

# Then go to the main Modelblocks directory and run the following commands:
cd wsjparse
make genmodel/wsj02to21.gcg13.1671.0sm.grammar 
# There may be some required make items you have to make first to configure Modelblocks, 
# so pay attention to what Make has trouble with.

# For each regular expression, sum the probabilities associated with that regular expression.
# This can be automated by piping the output of the grep'd .grammar file to:
# sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l

# For each set of regular expressions, multiply the associated summed probabilities together to 
# obtain the final associated probability 

#############
echo
echo Transitive Interpretation Probabilities
#############

echo P(VP-gNP -> VP-gNP PP)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&gN[^ ]* R&aN" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&gN&lI^g_0 R&aN&lM^g_0 0.17024889762085796

echo Prior counts of transitives
grep -oe 'V-aN-bN-lI [^(]' genmodel/wsj02to21.gcg13.linetrees | wc -l
# = 14719

#############
echo
echo Intransitive Interpretation Probabilities
#############
echo P(VP-gNP -> VP PP-gNP)
grep -e "V&aN&gN&lI[^ ]* -> V&aN[^ ]* R&aN&gN" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&lI^g_0 R&aN&gN&lM^g_0 0.0021914923237144144
# V&aN&gN&lI^g_0 -> V&aN&lI_0 R&aN&gN&lM^g_0 0.009631699992921688
# = .0118231923166361024

echo Prior counts of intransitives
grep -oe 'V-aN-lI [^(]' genmodel/wsj02to21.gcg13.linetrees | wc -l
# = 5617

##########################
##########################

#############
echo
echo Footnote 2 Probabilities
#############

#############
echo
echo Transitive Interpretation Probabilities (with preterminals)
#############

echo P(VP-gNP -> VP-gNP PP)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&gN[^ ]* R&aN" genmodel/wsj02to21.gcg13.1671.0sm.grammar |
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&gN&lI^g_0 R&aN&lM^g_0 0.17024889762085796

echo P(VP-gNP -> TV)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&bN[^ ]* [0-9]" genmodel/wsj02to21.gcg13.1671.0sm.grammar |
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&bN&lI_0 0.2705264963943486
# 
# P(Transitive w/ preterminals) = .17*.27 = 0.0459

#############
echo
echo Intransitive Interpretation Probabilities (with preterminals)
#############

# Now VP != IV:
echo P(VP-gNP -> VP PP-gNP)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&lI^[^ ]* R&aN&gN" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&lI^g_0 R&aN&gN&lM^g_0 0.0021914923237144144

echo P(VP-gNP -> IV *)
grep -e "V&aN&lI^[^ ]* -> V&aN&lI[^ ^]* [^ ]* " genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&lI^g_0 -> V&aN&lI_0 ,&lM^g_0 8.368780275829337E-4
# V&aN&lI^g_0 -> V&aN&lI_0 R&aN&lM^g_0 0.05012570463054172
# V&aN&lI^g_0 -> V&aN&lI_0 &LRB&&lM^g_0 2.6579767403242102E-5
# V&aN&lI^g_0 -> V&aN&lI_0 ``&lM^g_0 1.3222015767976047E-4
# V&aN&lI^g_0 -> V&aN&lI_0 ''&lM^g_0 3.574726012645896E-5
# V&aN&lI^g_0 -> V&aN&lI_0 V&rN&lN^g_0 4.3090905101690196E-4
# V&aN&lI^g_0 -> V&aN&lI_0 :&lM^g_0 3.724486619284002E-5
# V&aN&lI^g_0 -> V&aN&lI_0 R&aN&lN^g_0 1.599401207935901E-5
# V&aN&lI^g_0 -> V&aN&lI_0 R&aN&v&lM^g_0 2.6042973026445687E-5
# V&aN&lI^g_0 -> V&aN&lI_0 R&aN&o&lM^g_0 2.5435580210786205E-5
# = .05169275632586044810
# P(Intransitive w/ preterminals) = .002*.052 = 0.000104

# Note: That was actually kind of a dumb thing to do because some of those weren't plausible, 
#       but it gave P&T '03 the best possible break
# A more principled version would actually be something like this:
echo P(VP-gNP -> IV *)
grep -e "V&aN&lI^[^ ]* -> V&aN&lI[^ ^]* [^&][^vo]*l[^N][^ ]* " genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&lI^g_0 -> V&aN&lI_0 ,&lM^g_0 8.368780275829337E-4
# V&aN&lI^g_0 -> V&aN&lI_0 R&aN&lM^g_0 0.05012570463054172
# V&aN&lI^g_0 -> V&aN&lI_0 ``&lM^g_0 1.3222015767976047E-4
# V&aN&lI^g_0 -> V&aN&lI_0 ''&lM^g_0 3.574726012645896E-5
# V&aN&lI^g_0 -> V&aN&lI_0 :&lM^g_0 3.724486619284002E-5
# = .05116779494212371315
# P(Principled intransitive w/ preterminals) = .002*.051 = 0.000102

##########################

#############
echo
echo Transitive Interpretation Probabilities (with adverb)
#############

echo P(VP-gNP -> VP-gNP PP)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&gN[^ ]* R&aN" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&gN&lI^g_0 R&aN&lM^g_0 0.17024889762085796

echo P(VP-gNP -> VP-gNP Adv) 
# Note that the Nguyen et al. (2012) GCG considers PP and Adv to be the same category
grep -e "V&aN&gN&lI[^ ]* -> V&aN&gN[^ ]* R&aN" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&gN&lI^g_0 R&aN&lM^g_0 0.17024889762085796
# 
# P(Transitive w/ adverb) = .17*.17 = 0.029

#############
echo
echo Intransitive Interpretation Probabilities (with adverb)
#############

echo P(VP-gNP -> VP PP-gNP)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&lI[^ ]* R&aN&gN" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&lI^g_0 R&aN&gN&lM^g_0 0.0021914923237144144
# V&aN&gN&lI^g_0 -> V&aN&lI_0 R&aN&gN&lM^g_0 0.009631699992921688
# = .0118231923166361024

echo P(VP -> VP Adv)
grep -e "V&aN&lI[^ ]* -> V&aN&lI[^ ]* R&aN&[^vo]*l[^N]" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&lI^g_0 -> V&aN&lI^g_0 R&aN&lM^g_0 0.13026808265564047
# V&aN&lI^g_0 -> V&aN&lI_0 R&aN&lM^g_0 0.05012570463054172
# = .18039378728618219
#
# P(Intransitive w/ adverb) = .0118*.1804 = 0.00213

##########################

#############
echo
echo Transitive Interpretation Probabilities (with adverb and preterminals)
#############

echo P(VP-gNP -> VP-gNP PP)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&gN[^ ]* R&aN" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&gN&lI^g_0 R&aN&lM^g_0 0.17024889762085796

echo P(VP-gNP -> VP-gNP Adv)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&gN[^ ]* R&aN" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&gN&lI^g_0 R&aN&lM^g_0 0.17024889762085796

echo P(VP-gNP -> TV)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&bN[^ ]* [0-9]" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&bN&lI_0 0.2705264963943486
#
# P(Transitive w/ adverb and preterms) = .17*.17*.27 = 0.0078

#############
echo
echo Intransitive Interpretation Probabilities (with adverb and preterminals)
#############

# P(VP-gNP -> VP PP-gNP)
grep -e "V&aN&gN&lI[^ ]* -> V&aN&lI^[^ ]* R&aN&gN" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&gN&lI^g_0 -> V&aN&lI^g_0 R&aN&gN&lM^g_0 0.0021914923237144144

# P(VP -> IV Adv)
grep -e "V&aN&lI^[^ ]* -> V&aN&lI[^ ^]* R&aN[^vo]*l[^N][^ ]* " genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&lI^g_0 -> V&aN&lI_0 R&aN&lM^g_0 0.05012570463054172
#
# P(Intransitive w/ adverb and preterms) = .002*.05 = 0.0001

##########################
##########################

#############
echo
echo
echo Heavy-NP Shift Analysis
#############

echo There are three potential readings one could adopt:
echo 1) Transitive w/ heavy-NP shift
echo   (V-aN (V-aN-bN (V-aN-bN ...) (R-aN ...)) (N ...))

echo P(V-aN -> V-aN-bN N) #here, V-aN-bN is not a preterminal
grep -e "V&aN&lI^[^ ]* -> V&aN&bN&lI^[^ ]* N" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&lI^g_0 -> V&aN&bN&lI^g_0 N&lA^g_0 0.010542968336486146

echo P(V-aN-bN -> V-aN-bN R-aN)
grep -e "V&aN&bN&lI^[^ ]* -> V&aN&bN&lI[^ ^]* R&aN[^vo]*l[^N][^ ]* " genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&bN&lI^g_0 -> V&aN&bN&lI_0 R&aN&lM^g_0 0.14957393282039155
#
# Total = .0015
#  /2.6 = .0006 # just multiply by subcat bias

echo
echo 2) Transitive w/o heavy-NP shift
echo   (V-aN (V-aN (V-aN-bN ...) (N ...)) (R-aN ...))

echo P(V-aN -> V-aN R-aN)
grep -e "V&aN&lI^[^ ]* -> V&aN&lI^[^ ]* R&aN[^vo]*l[^N][^ ]* " genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&lI^g_0 -> V&aN&lI^g_0 R&aN&lM^g_0 0.13026808265564047

echo P(V-aN -> V-aN-bN N) #here, V-aN-bN is a preterminal
grep -e "V&aN&lI^[^ ]* -> V&aN&bN&lI[^ ^]* N" genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&lI^g_0 -> V&aN&bN&lI_0 N&lA^g_0 0.15491621465719815
#
# Total = .13*.155 = .02
#  /2.6 = .0077 # just multiply by subcat bias

echo
echo 3) Intransitive
echo   (V-aN (V-aN ...) (R-aN ...))
echo P(V-aN -> V-aN R-aN)
grep -e "V&aN&lI^[^ ]* -> V&aN&lI[^ ^]* R&aN[^vo]*l[^N][^ ]* " genmodel/wsj02to21.gcg13.1671.0sm.grammar \
| sed 's/^.* \([^ ]*\)$/\1/g' | sed 's/E\([^0-9]*[0-9]*\)/*10^(\1)/g' | paste -sd+ - | bc -l
# V&aN&lI^g_0 -> V&aN&lI_0 R&aN&lM^g_0 0.05012570463054172
#
# Total = .05
#    /1 = .05 # just multiply by subcat bias

# If the verb is optionally transitive:
#   3 [intransitive] is preferred over 1 and 2 because .05 > .0077 & .05 > .0006
#     and if an R-aN comes after the verb, we're either in 1 or 3, so 3 will still be preferred
#   which will cause slowing at the object noun because the verb in 3 is intransitive
# If the verb is obligatorily transitive:
#   We have to be in either 1 or 2 (since 3 is ruled out), so 2 [unshifted] will be preferred
#   which will cause slowing at the pre-object R-aN since 1 was dispreferred
#
# In order for an optionally transitive verb to prefer 1 [shifted] over 3 [intransitive], 
#  it would have to appear in transitive constructions 1*.05/.0006 = 83 times for every 1 
#  time it appeared in intransitive constructions (99% transitive bias)
# If a verb appears as transitive 1*.05/.0077 = 6.5 times for every 1 time it appears as 
#  intransitive (6.5/(6.5+1) = 87% transitive bias) it should yield slowing at the R-aN in the 
#  optionally transitive case (compared with R-aN in the unshifted, optionally transitive case), 
#  which is not something Staub et al. (2006) observed, but their verbs did not approach this level 
#  of transitive bias (in their Experiment 2)


