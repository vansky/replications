# Replication instructions for Can Entropy Explain Successor Surprisal Effects in Reading? (van Schijndel and Linzen, 2019)

If you run into problems with the `make` commands, go to the bottom of these instructions for step-by-step instructions to manually complete the `make` steps, bypassing make.

* Get [pytorch v0.3.0](https://pytorch.org/)  
* Get [the neural LM](https://github.com/vansky/neural-complexity)  
  After cloning the LM repo, `git checkout tags/v1.0.0` to obtain the correct version.  
* Get [the base LM weights](https://s3.amazonaws.com/colorless-green-rnns/best-models/English/hidden650_batch128_dropout0.2_lr20.0.pt)
* Get [the model vocabulary](https://s3.amazonaws.com/colorless-green-rnns/training-data/English/vocab.txt)
* Get the [Extended Penn Tokenizer](https://github.com/vansky/extended_penn_tokenizer)
* Get [Modelblocks](https://github.com/modelblocks/modelblocks-release)
* Get the [NaturalStories corpus](https://github.com/languageMIT/naturalstories)
* Get the [WikiText-103 corpus](https://s3.amazonaws.com/research.metamind.io/wikitext/wikitext-103-v1.zip)

For these instructions, I assume the above repositories are located at `/XPATH/` (such as `/XPATH/naturalstories`). Just change that location to match the absolute path of the given repository.

In the `modelblocks-release/` directory:  

```
    mkdir config  
    echo '/XPATH/naturalstories/' > config/user-naturalstories-directory.txt  
    echo '/XPATH/extended_penn_tokenizer/' > config/user-tokenizer-directory.txt  
    make workspace  
    cd workspace  
    make genmodel/naturalstories.linetoks  
```

The linetoks file contains the corpus, formatted as LM input

## Experiments

* Put the `%linetoks` files in a subdirectory `natstor` within the `neural-complexity/data` directory
* Put the LM model and vocab in the `neural-complexity` directory

### Obtain top-k complexity measures

Use these commands to get complexity measures for `naturalstories.linetoks`  

```
    python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words --nopp --complexn 50001 > natstor.50k.results  
    python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words --nopp --complexn 5000 > natstor.5k.results  
    python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words --nopp --complexn 500 > natstor.500.results  
    python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words --nopp --complexn 50 > natstor.50.results  
    python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --single --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words --nopp --complexn 5 > natstor.5.results
```

Combine the surp and entropy columns from each `%.results` file into a single `naturalstories.full.results` file.  
Copy `naturalstories.full.results` to your `modelblocks-release/workspace/` directory  
Copy `naturalstories/naturalstories_RTS/processed_RTs.tsv` to the `modelblocks-release/workspace` directory and cd to that directory.  
Use these commands to get unigram measures (assumes `wikitext-103` corpus is in a self-named directory within your modelblocks project directory).  
```
    echo 'word' > natstor.toks  
    sed 's/ /\n/g' genmodel/naturalstories.linetoks >> natstor.toks  
    cut -d' ' -f2- naturalstories.full.results | paste -d' ' natstor.toks - > naturalstories.results.fullwords  
    python scripts/calcunigram.py < wikitext-103/wiki.train.tokens > unigrams.txt  
    python scripts/insertunigrams.py unigrams.txt naturalstories.results.fullwords > naturalstories.fullunigram.results
```

Merge those complexity measures with the reading times to get usable dataframes.
```
    make genmodel/naturalstories.mfields.itemmeasures  
    paste -d' ' natstor.toks <(cut -d' ' -f2- naturalstories.fullunigram.results) | python ../resource-rt/scripts/roll_toks.py <(sed 's/(/-LRB-/g;s/)/-RRB-/g;' naturalstories.mfields.itemmeasures) sentid sentpos > naturalstories.lstm.itemmeasures  
    cut -d' ' -f4- naturalstories.lstm.itemmeasures  | paste -d' ' naturalstories.mfields.itemmeasures - > naturalstories.lstm.mergable.itemmeasures  
    python ../resource-naturalstories/scripts/merge_natstor.py <(cat processed_RTs.tsv | sed 's/\t/ /g;s/peaked/peeked/g;' | python ../resource-rt/scripts/rename_cols.py WorkerId subject RT fdur) naturalstories.lstm.mergable.itemmeasures | sed 's/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;' | python ../resource-rt/scripts/rename_cols.py item docid > naturalstories.lstm.core.evmeasures  
    python ../resource-rt/scripts/rm_unfix_items.py < naturalstories.lstm.core.evmeasures | python ../resource-rt/scripts/futureMetrics.py -I -c surp50001 entropy5 entropy50 entropy500 entropy5000 entropy50001 unigram | python ../resource-rt/scripts/rm_na_items.py | grep -v '<unk>' | python scripts/removerolled.py > naturalstories.lstm.filt.evmeasures  
    mkdir rdata  
    mkdir results  
```

That evmeasures file is then used to run all the regressions in the paper.

### Run RT regressions

```
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filt.evmeasures rdata/naturalstories.lstm.filtunigram.both.lme.rdata -N -S -C -F -A futsurp50001+futentropy50001 -b scripts/spru.lmeform -o 5 -B 100 -U 3000 -d > results/naturalstories.lstm.filtunigram.-NSCFd.spru.surpent50001.lme  
```

The above will generate the data for an analysis like Table 1 in the paper. Table 1 and all significance values were obtained by running on the test partition (replace the `-d` flag with `-t` in the above command) and comparing the likelihoods with those from fitting after ablating a given predictor:

```
    # Ablate Future Entropy  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filtunigram.evmeasures wunigram/naturalstories.lstm.filtunigram.both1.lme.rdata -N -S -C -F -A futsurp50001 -a futentropy50001 -b scripts/spru.lmeform -o 5 -B 100 -U 3000 -t > wunigram/naturalstories.lstm.filtunigram.-NSCFt.spru.futsurp50001.lme  
    # Ablate Future Surprisal  
    ../resource-lmefit/scripts/evmeasures2lmefit.r naturalstories.lstm.filtunigram.evmeasures wunigram/naturalstories.lstm.filtunigram.both1.lme.rdata -N -S -C -F -A futentropy50001 -a futsurp50001 -b scripts/spru.lmeform -o 5 -B 100 -U 3000 -t > wunigram/naturalstories.lstm.filtunigram.-NSCFt.spru.futsurp50001.lme  
```

To fit different top-k entropy measures to build Table 3, you need to modify the `-A futsurp50001+futentropy50001` in the first regression command above. Replace `futentropy50001` with `futentropyK` where `K` is whichever top-k value you'd like. For example `futentropy500` would use top-500 future entropy.

If any models fail to converge, I modified `-b scripts/spru.lmeform` in that command. For the first convergence failure, I would use `scripts/spru2.lmeform`. If that failed to converge, I used `scripts/spru3.lmeform`. And finally, I occasionally had to resort to `scripts/spru4.lmeform`.

Per footnote 1, I also ran these analyses without random word intercepts. To do this, you can replace `scripts/spruX.lmeform` with the corresponding `scripts/spruXnow.lmeform`.
