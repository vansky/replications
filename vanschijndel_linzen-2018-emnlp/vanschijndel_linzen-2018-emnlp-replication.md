# Replication instructions for A Neural Model of Adaptation in Reading (van Schijndel and Linzen, 2018)

If you run into problems with the `make` commands, go to the bottom of these instructions for step-by-step instructions to manually complete the `make` steps, bypassing make.

* Get [pytorch v0.3.0](https://pytorch.org/)  
* Get [the adaptive LM](https://github.com/vansky/neural-complexity)  
  After cloning the LM repo, `git checkout tags/v1.0.0` to obtain the correct version.  
* Get [the base LM weights](https://s3.amazonaws.com/colorless-green-rnns/best-models/English/hidden650_batch128_dropout0.2_lr20.0.pt)
* Get [the model vocabulary](https://s3.amazonaws.com/colorless-green-rnns/training-data/English/vocab.txt)
* Get the [Extended Penn Tokenizer](https://github.com/vansky/extended_penn_tokenizer)
* Get [Modelblocks](https://github.com/modelblocks/modelblocks-release)
* Get the [NaturalStories corpus](https://github.com/languageMIT/naturalstories)

For these instructions, I assume the above repositories are located at `/XPATH/` (such as `/XPATH/naturalstories`). Just change that location to match the absolute path of the given repository.

In the `modelblocks-release/` directory:  

```
    mkdir config  
    echo '/XPATH/naturalstories/' > config/user-naturalstories-directory.txt  
    echo '/XPATH/extended_penn_tokenizer/' > config/user-tokenizer-directory.txt  
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
```

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

```
    time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words --adapt --adapted_model 'adapted_model.pt' > full_corpus.adapted.results  
    time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words > full_corpus.notadapted.results  
```

The final line of `full_corpus.{adapted,notadapted}.results` provides the perplexity results

### Analysis 2

Repeat the above with `genmodel/naturalstories.fairy.linetoks` and `genmodel/naturalstories.doc.linetoks`
### Analysis 3

Repeat the above with each of `genmodel/naturalstories.{0,1,2,3,4,5,6}.linetoks` compared with each of `genmodel/naturalstories.{7,8,9}.linetoks`

## Section 4

You'll need `R` along with the following R packages:
* optparse
* optimx
* lme4

Then you'll need to get [R-hacks](https://github.com/aufrank/R-hacks).

Copy the scripts within the `R-hacks` repository into the `modelblocks-release/resources-rhacks/scripts` directory

Use the results from Section 3 Analysis 3, which I'll refer to as `naturalstories.0.{adapt,noadapt}.results`, etc based on the numbers in the linetoks filenames and on whether the model was adaptive or not.

Rename the `surp` column in `naturalstories.0.noadapt.results` to `surpnoa`

```
    sed -i '1 s/surp/surpnoa/' naturalstories.0.noadapt.results
```

Paste the `surpnoa` column from each `%noadapt.results` file to the corresponding `%adapt.results` file.

```
    n=0; paste -d' ' <(cut -d' ' -f-5 "naturalstories.${n}.adapt.results") <(cut -d' ' -f5 "naturalstories.${n}.noadapt.results") <(cut -d' ' -f6- "naturalstories.${n}.adapt.results") > naturalstories.${n}.results
```

Increment $n until all files have been joined. Then create one long `%results` file

```
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
```

Copy `naturalstories.full.results` to your `modelblocks-release/workspace/` directory  
Copy `naturalstories/naturalstories_RTS/processed_RTs.tsv` to the `modelblocks-release/workspace` directory and cd to that directory.  

Note: This next section could be made easier, but the modelblocks target syntax changes occasionally (and is currently going through changes as I write this), so to better future-proof things, we'll manually generate most of the needed files. 

```
    make genmodel/naturalstories.mfields.itemmeasures  
    echo 'word' > natstor.toks  
    sed 's/ /\n/g' genmodel/naturalstories.linetoks >> natstor.toks  
    paste -d' ' natstor.toks <(cut -d' ' -f2-6 naturalstories.full.results) | python ../resource-rt/scripts/roll_toks.py <(sed 's/(/-LRB-/g;s/)/-RRB-/g;' genmodel/naturalstories.mfields.itemmeasures) sentid sentpos > naturalstories.lstm.itemmeasures  
    cut -d' ' -f4- naturalstories.lstm.itemmeasures  | paste -d' ' genmodel/naturalstories.mfields.itemmeasures - > naturalstories.lstm.mergable.itemmeasures  
    python ../resource-naturalstories/scripts/merge_natstor.py <(cat processed_RTs.tsv | sed 's/\t/ /g;s/peaked/peeked/g;' | python ../resource-rt/scripts/rename_cols.py WorkerId subject RT fdur) naturalstories.lstm.mergable.itemmeasures | sed 's/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;' | python ../resource-rt/scripts/rename_cols.py item docid > naturalstories.lstm.core.evmeasures  
    python ../resource-rt/scripts/rm_unfix_items.py < naturalstories.lstm.core.evmeasures | python ../resource-rt/scripts/rm_na_items.py > naturalstories.lstm.filt.evmeasures  
    mkdir scripts  
```

Create a `scripts/spr.lmeform` file that contains these lines:

```
    fdur  
    z.(wlen) + z.(sentpos)  
    z.(wlen) + z.(sentpos)  
    (1 | word)
```

Now we use the `naturalstories.lstm.filt.evmeasures` file for regressions:

#### Dev regressions

```
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.base.lme.rdata -d -N -S -C -F -A surp+surpnoa -a surp+surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFd.base.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.surp.lme.rdata -d -N -S -C -F -A surp+surpnoa -a surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFd.surp.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.surpnoa.lme.rdata -d -N -S -C -F -A surp+surpnoa -a surp -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFd.surpnoa.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.both.lme.rdata -d -N -S -C -F -A surp+surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFd.both.lme  
```

#### Test regressions

```
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.base.lme.rdata -t -N -S -C -F -A surp+surpnoa -a surp+surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFt.base.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.surp.lme.rdata -t -N -S -C -F -A surp+surpnoa -a surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFt.surp.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.surpnoa.lme.rdata -t -N -S -C -F -A surp+surpnoa -a surp -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFt.surpnoa.lme  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures naturalstories.lstm.filt.both.lme.rdata -t -N -S -C -F -A surp+surpnoa -b scripts/spr.lmeform > naturalstories.lstm.filt.-NSCFt.both.lme  
```

## Section 5.1

Requires stimuli from Fine and Jaeger (2016), which come in the form of 16 lists: `ListA1`, `ListA1_reversed`, `ListA2`, etc.

Ensure that the stimulus sentences are tokenized properly by passing them through the `extended_penn_tokenizer`. The below commands assume these are named things like `ListA1.linetoks` 

Put the lists in `data/fj16`

```
    mkdir fj-output  

    list=ListA1  
    
    time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/fj16/' --testfname "${list}.linetoks" --test --words > "fj-output/${list}.adapting.output"  
    time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --lr ${learnrate} --data_dir './data/fj16/' --testfname "${list}.linetoks" --test --words --adapt --adapted_model "fj-output/adapted_model-${list}.pt" > "fj-output/${list}.adapting.output"
```

Repeat the above for each list.

I'll just roughly sketch out the rest of this section because it's pretty straight-forward:

Using the original list files, merge the stimulus conditions into the model output based on the sentence IDs.

If you load each list into pandas, you can use this python function to identify the disambiguating regions based on sentence position:

```
    def add_regionnums(row):  
      if row['condition'] == 'ambiguous' and row['sentpos'] in (7,8,9):  
        #ambiguous critical region starts with word 7  
        return(3)  
      elif row['condition'] == 'unambiguous' and row['sentpos'] in (9,10,11):  
        #unambiguous critical region starts with word 9  
        return(3)  
      else:  
        return(0)  
  
    data['region'] = data.apply(lambda row: addregionnums(row),axis=1)  
    data=data[data['region']==3]  
    data=data[data['condition']!='filler'].reset_index().drop('index',axis=1)  
    data=data.groupby(('sentid','condition')).agg('mean').reset_index()  
    data['order']=range(40)
```

After processing each list via the above python code, concatenate all the lists together into a long data file. It must have columns for `condition` (ambiguous vs unambiguous), `order`, and `sentid`. Read that file into R:

```
    library('ggplot2')  
    library('stringr')  
    theme_set(theme_gray(base_size = 16))  
      
    df <- read.table('finejaeger.csv',sep=',',header=T)  
    df$residsurp <- residuals(lm(surp~sentid,data=df))  
      
    ggplot(df, aes(order+1, residsurp, group = condition, colour = condition, fill = condition)) +  
                 stat_summary(fun.y=mean, geom="point", aes(colour=condition,shape=shape)) +  
                 geom_smooth(method = lm, formula = y ~ log(x+1), aes(linetype=condition)) +  
                 scale_colour_manual("condition",labels=c('ambiguous','unambiguous'),values=mypal) +  
                 scale_shape_manual("condition",labels=c('ambiguous','unambiguous'),values=c(1,2)) +  
                 scale_linetype_manual("condition",labels=c('ambiguous','unambiguous'),values=c('solid','dashed')) +  
                 xlab('Item order (#RCs seen)') +  
                 ylab('Order-corrected surprisal (bits)')  
```

## Section 5.2

* Build the dative dataset (requires the Wikitext-2 `train.txt` data included with `neural-complexity`)

```
    # This command will generate an output directory  
    #  and fill it with 10 dev and test pairs for each of DO and PO  
    # They will be named prepobjs.100-1000.{dev,test}.{0..9}.sents (including controls)  
    # They will be named prepobjs.100-0.{dev,test}.{0..9}.sents (no controls)  
    # There are parameters that can be tweaked at the beginning of genlists.py  
    python scripts/genlists.py prepobjs.dev.sents doubleobjects.dev.sents prepobjs.test.sents doubleobjects.test.sents train.txt
```

* Move `datives` into the `neural-complexity/data/`
* Go to `neural-complexity` and make some directories to store models and output

```
    mkdir dative-models  
    mkdir dative-output
```

* Run the adaptive mechanism over a dev set and then freeze the weights and test against the corresponding test sets

```
    i=0; # This is used to iterate over all the input files  
    python -u main.py --words --test --lr 20.0 --vocab_file "vocab.txt" --model_file "hidden650_batch128_dropout0.2_lr20.0.pt" --adapted_model "dative-models/dodev.$i.adapted.pt" --tied --cuda --data_dir ./data/datives/ --adapt --testfname doubleobj.100-1000.dev.$i.sents > dative-output/dodev-$i.training  
    python -u main.py --words --test --lr 20.0 --vocab_file "vocab.txt" --model_file "dative-models/dodev.$i.adapted.pt" --tied --cuda --data_dir ./data/datives/ --testfname doubleobj.100-1000.dev.$i.sents > dative-output/dodev-$i.test-do  
    python -u main.py --words --test --lr 20.0 --vocab_file "vocab.txt" --model_file "dative-models/dodev.$i.adapted.pt" --tied --cuda --data_dir ./data/datives/ --testfname prepobj.100-1000.dev.$i.sents > dative-output/dodev-$i.test-po  
    # Repeat the above but switch DO with PO  
    python -u main.py --words --test --lr 20.0 --vocab_file "vocab.txt" --model_file "hidden650_batch128_dropout0.2_lr20.0.pt" --adapted_model "dative-models/podev.$i.adapted.pt" --tied --cuda --data_dir ./data/datives/ --adapt --testfname prepobj.100-1000.dev.$i.sents > dative-output/podev-$i.training  
    python -u main.py --words --test --lr 20.0 --vocab_file "vocab.txt" --model_file "dative-models/podev.$i.adapted.pt" --tied --cuda --data_dir ./data/datives/ --testfname doubleobj.100-1000.dev.$i.sents > dative-output/podev-$i.test-do  
    python -u main.py --words --test --lr 20.0 --vocab_file "vocab.txt" --model_file "dative-models/podev.$i.adapted.pt" --tied --cuda --data_dir ./data/datives/ --testfname prepobj.100-1000.dev.$i.sents > dative-output/podev-$i.test-po
```

* Increment `i` in the above code block and repeat for each dev set (default: 0..10)
    
## Section 6

* Get the [MultiNLI corpus](https://www.nyu.edu/projects/bowman/multinli/)

```
    mkdir data/multinli  
    cat /XPATH/multinli_1.0/multinli_1.0_dev_mismatched.txt <( tail -n+2 /XPATH/multinli_1.0/multinli_1.0_dev_matched.txt ) | scripts/split_multinli.py /XPATH/neural-complexity/data/multinli dev  
```

Now you should have files like `neural-complexity/data/multinli/fiction-dev.txt`. In this work, we ignore the training sets in order to make use of all 10 genres in the corpus, but that means we need to generate train/test sets from the dev corpora. Within the `neural-complexity` directory:

```
    genre=fiction;
    head -n1000 data/multinli/$genre-dev.txt > data/multinli/$genre-dev1.txt  
    tail -n+1001 data/multinli/$genre-dev.txt > data/multinli/$genre-dev2.txt
```

Repeat the above for each of the ten genres.

```
   mkdir multinli-output  
   
   # Generate the non-adaptive and adaptive baselines  
   genre='government'  
   time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/multinli/' --testfname "${genre}-dev2.txt" --test --words > "multinli-output/${genre}.noadapt.output"  
   time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/multinli/' --testfname "${genre}-dev1.txt" --test --words --adapt --adapted_model "multinli-output/adapted_model-${genre}.pt" > "multinli-output/${genre}.adapting.output"  
   time python main.py --model_file "multinli-output/adapted_model-${genre}.pt" --vocab_file 'vocab.txt' --cuda --single --data_dir './data/multinli/' --testfname "${genre}-dev2.txt" --test --words > "multinli-output/${genre}.postadapt.output"  
```

Repeat the above for each of the ten genres. Note that we always test on `dev2` while we adapt to `dev1` in order to avoid training on test data.

```
    genre1='government'  
    genre2='fiction'  
    time python main.py --model_file "multinli-output/adapted_model-${genre1}.pt" --vocab_file 'vocab.txt' --cuda --single --data_dir './data/multinli/' --testfname "${genre2}-dev1.txt" --test --words --adapt --adapted_model "multinli-output/adapted_model-${genre1}-${genre2}.pt" > "multinli-output/${genre1}.${genre2}.adapting2.output"  
    time python main.py --model_file "multinli-output/adapted_model-${genre1}-${genre2}.pt" --vocab_file 'vocab.txt' --cuda --single --data_dir './data/multinli/' --testfname "${genre1}-dev2.txt" --test --words > "multinli-output/${genre1}.${genre2}.postadapt2.output"  

```

Repeat the above for every pair of genres where `genre1` != `genre2`. The final line of each file should report perplexity, so just compare the perplexity distribution of `multinli-output/*.noadapt.output` to `multinli-output/*.postadapt.output` to `multinli-output/*.postadapt2.output`.

## Bypassing Make

Make can be a pain to get working. These are the instructions for manually building each of the items for which I invoked `make` above. 

All of these instructions will require you to change `/XPATH` to the relevant path for each item, based on where the given resource is on your computer. Further `python` commands use python 2.x and `python3` commands use python 3.x, so you will need to change those calls if your computer is setup with `python2` as python 2.x and `python` as python 3.x.

### make genmodel/naturalstories.linetoks

```
    cat /XPATH/naturalstories/parses/penn/all-parses.txt.penn | perl /XPATH/modelblocks-release/resource-linetrees/scripts/editabletrees2linetrees.pl > genmodel/naturalstories.penn.linetrees  
    cat genmodel/naturalstories.penn.linetrees | python /XPATH/modelblocks-release/resource-naturalstories/scripts/penn2sents.py | sed 's/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;s/peaked/peeked/g;' > genmodel/naturalstories.linetoks  
```

### make genmodel/naturalstories.mfields.itemmeasures

```
    cat /XPATH/naturalstories_RTS/all_stories.tok | sed 's/\t/ /g;s/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;s/peaked/peeked/g;' | python /XPATH/modelblocks-release/resource-rt/scripts/toks2sents.py genmodel/naturalstories.linetoks > genmodel/naturalstories.lineitems  
    paste -d' ' <(cat /XPATH/naturalstories/naturalstories_RTS/all_stories.tok | sed 's/\t/ /g;s/peaked/peeked/g') <(cat genmodel/naturalstories.lineitems | python /XPATH/modelblocks-release/resource-rt/scripts/sents2sentids.py | cut -d' ' -f 2-) \  
    <(cat /XPATH/naturalstories/naturalstories_RTS/all_stories.tok | sed 's/\t/ /g;' | awk -f /XPATH/modelblocks-release/resource-rt/scripts/filter_cols.awk -v cols=item - | python /XPATH/modelblocks-release/resource-rt/scripts/rename_cols.py item docid) > genmodel/naturalstories.mfields.itemmeasures  
    rm genmodel/naturalstories.lineitems  
```
