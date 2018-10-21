# Replication instructions for A Neural Model of Adaptation in Reading (van Schijndel and Linzen, 2018)

Note: Currently, these instructions only extend through Section 4, but if there is demand, I can extend these further.

* Get [the adaptive LM](https://github.com/vansky/neural-complexity)
* Get [the base LM weights](https://s3.amazonaws.com/colorless-green-rnns/best-models/English/hidden650_batch128_dropout0.2_lr20.0.pt)
* Get [the model vocabulary](https://s3.amazonaws.com/colorless-green-rnns/training-data/English/vocab.txt)
* Get [Modelblocks](https://github.com/modelblocks/modelblocks-release)
* Get the [NaturalStories corpus](https://github.com/languageMIT/naturalstories)

Within the `modelblocks-release/config` directory create a `user-naturalstories-directory.txt` containing the absolute path to your naturalstories directory.

In the `modelblocks-release/` directory:  

    make workspace  
    cd workspace  
    make genmodel/naturalstories.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 57 > genmodel/naturalstories.0.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 94 | tail -n 37 > genmodel/naturalstories.1.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 149 | tail -n 55 > genmodel/naturalstories.2.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 204 | tail -n 55 > genmodel/naturalstories.3.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 249 | tail -n 45 > genmodel/naturalstories.4.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 313 | tail -n 64 > genmodel/naturalstories.5.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 361 | tail -n 48 > genmodel/naturalstories.6.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 394 | tail -n 33 > genmodel/naturalstories.7.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 442 | tail -n 48 > genmodel/naturalstories.8.linetoks  
    cat genmodel/naturalstories.linetoks | head -n 485 | tail -n 43 > genmodel/naturalstories.9.linetoks  
    cat genmodel/naturalstories.{0,1,2,3,4,5,6}.linetoks > genmodel/naturalstories.fairy.linetoks  
    cat genmodel/naturalstories.{7,8,9}.linetoks > genmodel/naturalstories.doc.linetoks

Each linetoks file contains the corpus, formatted as LM input
* `naturalstories.linetoks` is the entire corpus  
* each numbered linetoks contains a single story  
* `%fairy.linetoks` contains all the fairytale documents  
* `%doc.linetoks` contains all the documentary documents

## Section 3

* Put the `%linetoks` files in a subdirectory `natstor` within the `neural-complexity/data` directory
* Put the LM model and vocab in the `neural-complexity` directory

### Analysis 1

Use the quickstart adaptation command to adapt to `naturalstories.linetoks`  

    time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words --adapt --adapted_model 'adapted_model.pt' > full_corpus.adapted.results  
    time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words > full_corpus.notadapted.results  

The final line of `full_corpus.{adapted,notadapted}.results` provides the perplexity results

### Analysis 2

Repeat the above with `genmodel/naturalstories.fairy.linetoks` and `genmodel/naturalstories.doc.linetoks`
### Analysis 3

Repeat the above with each of `genmodel/naturalstories.{0,1,2,3,4,5,6}.linetoks` compared with each of `genmodel/naturalstories.{7,8,9}.linetoks`

## Section 4

* Get [R-hacks](https://github.com/aufrank/R-hacks)

Within the `modelblocks-release/config` directory create a `user-rhacks-directory.txt` containing the absolute path to your R-hacks directory.

Use the results from Section 3 Analysis 3, which I'll refer to as `naturalstories.0.{adapt,noadapt}.results`, etc based on the numbers in the linetoks filenames and on whether the model was adaptive or not.

Rename the `surp` column in `naturalstories.0.noadapt.results` to `surpnoa`

    sed -i '1 s/surp/surpnoa/' naturalstories.0.noadapt.results

Paste the `surpnoa` column from each `%noadapt.results` file to the corresponding `%adapt.results` file.

    n=0; paste -d' ' <(cut -d' ' -f-5 "naturalstories.${n}.adapt.results") <(cut -d' ' -f5 "naturalstories.${n}.noadapt.results") <(cut -d' ' -f6- "naturalstories.${n}.adapt.results") > naturalstories.${n}.results

Increment $n until all files have been joined. Then create one long `%results` file

    head -n -3 naturalstories.0.results > naturalstories.full.results  
    head -n -3 naturalstories.1.results | tail -n+2 >> naturalstories.full.results  
    head -n -3 naturalstories.2.results | tail -n+2 >> naturalstories.full.results  
    head -n -3 naturalstories.3.results | tail -n+2 >> naturalstories.full.results  
    head -n -3 naturalstories.4.results | tail -n+2 >> naturalstories.full.results  
    head -n -3 naturalstories.5.results | tail -n+2 >> naturalstories.full.results  
    head -n -3 naturalstories.6.results | tail -n+2 >> naturalstories.full.results  
    head -n -3 naturalstories.7.results | tail -n+2 >> naturalstories.full.results  
    head -n -3 naturalstories.8.results | tail -n+2 >> naturalstories.full.results  
    head -n -3 naturalstories.9.results | tail -n+2 >> naturalstories.full.results  

Copy `naturalstories.full.results` to your `modelblocks-release/workspace/` directory  
Copy `naturalstories/naturalstories_RTS/processed_RTs.tsv` to the `modelblocks-release/workspace` directory and cd to that directory.  

Note: This next section could be made easier, but the modelblocks target syntax changes occasionally (and is currently going through changes as I write this), so to better future-proof things, we'll manually generate most of the needed files. 

    make genmodel/naturalstories.mfields.itemmeasures  
    echo 'word' > natstor.toks  
    sed 's/ /\n/g' genmodel/naturalstories.linetoks >> natstor.toks  
    paste -d' ' natstor.toks <(cut -d' ' -f2-6 naturalstories.full.results) | python ../resource-rt/scripts/roll_toks.py <(sed 's/(/-LRB-/g;s/)/-RRB-/g;' genmodel/naturalstories.mfields.itemmeasures) sentid sentpos > naturalstories.lstm.itemmeasures  
    cut -d' ' -f4- naturalstories.lstm.itemmeasures  | paste -d' ' genmodel/naturalstories.mfields.itemmeasures - > naturalstories.lstm.mergable.itemmeasures  
    python ../resource-naturalstories/scripts/merge_natstor.py <(cat processed_RTs.tsv | sed 's/\t/ /g;s/peaked/peeked/g;' | python ../resource-rt/scripts/rename_cols.py WorkerId subject RT fdur) naturalstories.lstm.mergable.itemmeasures | sed 's/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;' | python ../resource-rt/scripts/rename_cols.py item docid > naturalstories.lstm.core.evmeasures  
    python ../resource-rt/scripts/rm_unfix_items.py < naturalstories.lstm.core.evmeasures | python ../resource-rt/scripts/rm_na_items.py > naturalstories.lstm.filt.evmeasures  
    mkdir scripts  
    
Create a `scripts/spr.lmeform` with the following:

    fdur  
    z.(wlen) + z.(sentpos)  
    z.(wlen) + z.(sentpos)  
    (1 | word)

Now we use the `naturalstories.lstm.filt.evmeasures` file for regressions:

#### Dev regressions

    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.base.lme.rdata -d -N -S -C -F -A surp+surpnoa -a surp+surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFd.base.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.surp.lme.rdata -d -N -S -C -F -A surp+surpnoa -a surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFd.surp.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.surpnoa.lme.rdata -d -N -S -C -F -A surp+surpnoa -a surp -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFd.surpnoa.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.both.lme.rdata -d -N -S -C -F -A surp+surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFd.both.lme  

#### Test regressions

    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.base.lme.rdata -t -N -S -C -F -A surp+surpnoa -a surp+surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFt.base.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.surp.lme.rdata -t -N -S -C -F -A surp+surpnoa -a surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFt.surp.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.surpnoa.lme.rdata -t -N -S -C -F -A surp+surpnoa -a surp -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFt.surpnoa.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.both.lme.rdata -t -N -S -C -F -A surp+surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFt.both.lme  

## Section 5.1

Requires stimuli from Fine and Jaeger (2016)

## Section 5.2

TBD

## Section 6

* Get the [MultiNLI corpus](https://www.nyu.edu/projects/bowman/multinli/)

TBD