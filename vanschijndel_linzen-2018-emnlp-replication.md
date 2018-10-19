# Replication instructions for A Neural Model of Adaptation in Reading (van Schijndel and Linzen, 2018)

Note: Currently, these instructions only extend through Section 3 and semi-through Section 4, but if there is demand, I can extend these further.

* Get [the adaptive LM](https://github.com/vansky/neural-complexity)
* Get [the base LM weights](https://s3.amazonaws.com/colorless-green-rnns/best-models/English/hidden650_batch128_dropout0.2_lr20.0.pt)
* Get [the model vocabulary](https://s3.amazonaws.com/colorless-green-rnns/training-data/English/vocab.txt)
* Get [Modelblocks](https://github.com/modelblocks/modelblocks-release)
* Get the [NaturalStories corpus](https://github.com/languageMIT/naturalstories)

Within the modelblocks-release/config directory create a `user-naturalstories-directory.txt` with the absolute path to your naturalstories directory.

In the modelblocks-release/ directory:  

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
* naturalstories.linetoks is the entire corpus  
* each numbered linetoks contains a single story  
* %fairy.linetoks contains all the fairytale documents  
* %doc.linetoks contains all the documentary documents

## Section 3

* Put the %linetoks files in a subdirectory `natstor` within the neural-complexity/data directory
* Put the LM model and vocab in the neural-complexity directory

### Analysis 1

Use the quickstart adaptation command to adapt to naturalstories.linetoks  

    time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words --adapt --adapted_model 'adapted_model.pt' > full_corpus.adapted.results  
    time python main.py --model_file 'hidden650_batch128_dropout0.2_lr20.0.pt' --vocab_file 'vocab.txt' --cuda --data_dir './data/natstor/' --testfname 'naturalstories.linetoks' --test --words > full_corpus.notadapted.results  

The final line of full_corpus.{adapted,notadapted}.results provides the perplexity results

### Analysis 2

Repeat the above with `genmodel/naturalstories.fairy.linetoks` and `genmodel/naturalstories.doc.linetoks`
### Analysis 3

Repeat the above with each of `genmodel/naturalstories.{0,1,2,3,4,5,6}.linetoks` compared with each of `genmodel/naturalstories.{7,8,9}.linetoks`

## Section 4

Use modelblocks to generate an %all-itemmeasures for naturalstories, and run the regression using the `surp` column in the above %results files.
