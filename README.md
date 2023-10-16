# Table of Contents
1. [Installation](#Installation)
2. [Required Files, Folders and Scripts](#Required-Files,-Folders-and-Scripts)
3. [DATA Preparation](#DATA-Preparation)
4. [Lexicon Expension](#Lexicon-Expension)
5. [Create LM](#Create-LM)
6. [Create AM](#Create-AM)
7. [Decoding](#Decoding)
8. [Handling errors](#Handling-errors)


# Installation
* git clone the kaldi repository and follow the instructions written in **INSTALL** file
    `git clone https://github.com/kaldi-asr/kaldi.git`

* Go to the cloned directory and then to *tools*
      `cd kaldi/tools`
* To check the prerequisites for Kaldi, run the following command.
`./extras/check_dependencies.sh`
    >  And see if there are any packages you need to install. And Make sure you get following output after running the above command:
    > ***./extras/check_dependencies.sh: all OK.***
    > 
    >For more info please visit [Software required to install and run Kaldi
](https://kaldi-asr.org/doc/dependencies.html)

*  Then build the programs using *make* command
  `make -j 4`
    > ***Note :*** here 4 is the number of parallel jobs
    
* Install the irstlm
 `sudo ./extras/install_irstlm.sh`
   > ***Note :*** you can also install this later
    
* Build the programs in *src* 
`cd ../src`
`./configure --shared`
`make depend -j 4`
`make -j 4`
    >***Note :*** this build can take a while



# Required Files, Folders and Scripts
* make a directory where you will run the experiment, lets say *asr_lab*
`mkdir /home/<user>/asr_lab`
* copy the `conf` `local` `utils` `steps` `cmd.sh` `path.sh` from *kalid/egs/wsj/s5/* to */home/<user>/asr_lab/*
`cd kaldi/egs/wsj/s5`
`cp -r conf local utils steps cmd.sh path.sh ../../../../asr_lab`

* Scripts needed:
    `create_lm.sh` (to create the language model)
    `myrun.sh` (to train the HMM GMM model)
    `online_speech1.sh` (to decode the audio from HMM GMM model)[optioanl]
     `make_graph.sh` (to create or update the graph for GMM HMM)[optioanl]
    `make_graph_nnet3.sh` (to create or update the graph for DNN)
    `run_dnn.sh` (to train the DNN model)[optional]
    `online_speech_DNN.sh` (to decode the audio from DNN model)[optional]
    `easy-kaldi.sh` (for data prepration)[optional]
    `lm-tool_2` (folder for lexicon expension)[optional]
     >***Note :*** you can copy some of the scripts from here [here](https://github.com/kkchaudhary11/kaldi_asr)
 

* After copying, `/home/<user>/asr_lab` should contains following files and folders and scripts: 
    `cmd.sh` `conf`    `create_lm.sh`   `local`    `make_graph.sh`    `myrun.sh`    `online_speech1.sh`    `path.sh`    `steps`    `utils` `easy-kaldi.sh`
    


# DATA Preparation
    

    
* Split your data into train and test data which contains wav files (.wav) and its equivalent transcripted files (.txt).
     * make the folder *wav*. Inside *wav* make  *train_data* and *test_Data*
    `mkdir wav wav/train_data wav/test_data`
     * copy the splitted training data into the *train_data* folder  and splitted testing data into the *test_data* folder. 
        >
        For example copy the TECH_ART and STORIES folders to `wav/train_data` folder. Move some of the wav and their equivalent transcripted files form `train_data` to `test_data` 
        >
    The structure will be something simillar to:
    ```
    wav
    ├── test_data
    │   ├── 43.txt
    │   └── 43.wav
    │        ...
    └── train_data
        ├── first
        │   ├── 1.txt
        │   ├── 1.wav
        │   ├── 2.txt
        │   ├── 2.wav
        │   ├── 3.txt
        │   └── 3.wav
        │        ...
        ├── second
        │   ├── 11.txt
        │   └── 11.wav
        │        ...
        └── third
            ├── 13.txt
            ├── 13.wav
            ├── 23.txt
            └── 23.wav
                 ...
            ...
    ```
     >***Note :*** Folder name and path can be anything. 

    
* Make the *data* directory inside the *asr_lab* folder.
    `mkdir asr_lab/data`
    
* Now we will prepare 4 files for both *train_data* and the *test_data* which are as follows -  `spk2utt` `text` `utt2spk` `wav.scp` 

    `./easy-kaldi.sh --train /home/<user>/asr_lab/wav/train_data`
   `./easy-kaldi.sh --test /home/<user>/asr_lab/wav/test_data`
  > ***Note :*** You can also create these files manually 

  
* Above command will create `train` and `test` folders. Move them inside `data` folder.
     `mv train test data/ `

* Create a folder *local* inside *data* folder. And *plain-text* folder inside *local*.
      `cd data`
     `mkdir -p local/plain-text`


* Now we need to grab the text from `train/text` and `test/text` from data folder to create the `text_c1` and `lexicon`
    `cut -f2 train/text > train/train_text`
    `cut -f2 test/text > test/test_text`

* Combine *train_text* and *test_text* files and move it to *plain-text* then sort and remove the duplicates
    `cat train/train_text test/test_text > text_c1`
    `mv text_c1 local/plain-text/`
    `cd local/plain-text`
    `sort text_c1 | uniq > text_c1_sorted_unique`
    `mv text_c1_sorted_unique text_c1 `
    > ***Note :*** You can also use text editer for this 

    

* In text_c1 we need to replace the starting SIL with \<s> and ending SIL with \</s>

    `sed -i 's/SIL /<s> /g' text_c1_sorted_unique`
    `sed -i 's| SIL| </s>|g' text_c1_sorted_unique`
    > ***Note :*** You can also use text editer for this 


    

# Lexicon Expension

* In order to create lexicon create dict folder inside local folder
    `mkdir dict `

* Then we have to keep only unique words from *plain-text/text_c1* , so replace the " "(space) with the "\n" and remove the duplicaes from this data. and also remove the fist 2 lines that contains \<s> and \</s>
    
    `sed 's/ /\n/g' plain-text/text_c1_sorted_unique > unique_words`
    `sort unique_words | uniq > unique_words_sorted`
    `tail -n +3 unique_words_sorted > unique_words`
    > ***Note :*** You can also use text editer for this 


*  Next Let us create the lexicon expension using the script  lm-tools.sh 
    `cd asr_lab/lm-tools_2/`
    `./lm-tools.sh ../data/local/uniqeue_words`
    Go to asr_lab dir
    `cd ../asr_lab`
    `cp lm-tools_2/temp/tmp.parse lexicon.txt`


* you need to do follwing operation on lexicon.txt 
    1. Replace the 2 spaces followed by a single double quote(  ") with tab(\t).
    `sed -i 's/  "/\t/g' lexicon.txt`
    2. Replace the single double quote followed by a tab with a single space.
    `sed -i 's/"  / /g' lexicon.txt`
    3. Replace the double quote present at the end of the line(" ) with nothing.
    `sed -i 's/" //g' lexicon.txt`
    4. Remove the first blank line if it is present from the file.
     `sed -i '1d' lexicon.txt`
    5. add the following two lines at the start of the file
    !SIL    sil
    SIL    sil
    `sed -i '1s/^/!SIL\tsil\nSIL\tsil\n/' lexicon.txt`
     
    The format of lexicon.txt should be something like:
    ```
    !SIL	sil
    SIL	sil
    अकेले	a k ee l ee
    अगर	a g a r
    अगले	a g l ee
    अच्छी	a c ch ii
    अच्छी-अच्छी	a c ch ii a c ch ii
    अंजान	a q j aa n
    ....
    ```

    > ***Note :*** lmtool.sh work best with hindi script only 
    
    For other indic language you can use TTS scripts present at: `/media/linux/TTS/scripts/programs_pranaw/pd_for_hts/<language>/test.pl unique_words` 
    For english you can also use cmu lexicon tool [here](http://www.speech.cs.cmu.edu/tools/lextool.html)


* now from this lexicon.txt run the below command to take only the second column seperated by tab. Save the output in the nonsilence_phones.txt
    `cut -f2 lexicon.txt > nonsilence_phones_raw.txt` 


* open the file, replace the spaces with newline and then remove the duplicates and save it.
    `sed -i 's/ /\n/g' nonsilence_phones_raw.txt`
    `sort nonsilence_phones_raw.txt | uniq > nonsilence_phones_unique.txt`
* Remove the first blank line.
    `sed -i '1d' nonsilence_phones.txt`
* Remove the first 2 lines from nonsilence_phones.txt which contains SIL and !SIL
    `tail -n +3 nonsilence_phones_unique > nonsilence_phones.txt`
    
- create optional_silence.txt and silence_phones.txt file and write 'sil' at first line
    `echo "sil" | cat >> optional_silence.txt`
    `echo "sil" | cat >> silence_phones.txt`



 `data` folder should have following structure :

```
├── local
│   ├── dict
│   │   ├── lexicon.txt
│   │   ├── nonsilence_phones.txt
│   │   ├── optional_silence.txt
│   │   └── silence.txt
│   └── plain-text
│        └── text_c1
├── test
│   ├── spk2utt
│   ├── text
│   ├── utt2spk
│   └── wav.scp
└── train
     ├── spk2utt
     ├── text
     ├── utt2spk
     └── wav.scp
```

# Create LM

* Now, open the path.sh file and change the kaldi path to new kaldi path where it is installed Update the kaldi path in create_lm.sh at "KALDI_ROOT" and "export IRSTLM".

    `export KALDI_ROOT=new_kaldi_path`
    `export IRSTLM=new_kaldi_path/tools/irstlm`
    >
    > ***Note :*** Change the 'n' parameter at the following line in the create_lm.sh script. Here 'n' is the no of words which should be taken into consideration by LM to predict the next word. 
    > *IRSTLM/bin/build-lm.sh -i data/local/plain-text/text_c1 -n 2 -o data/local/tmp/lm_phone_bg.ilm.gz*
    >
     > Read more at the given [link](https://docs.google.com/presentation/d/19ZACTwdCZ8kxOFR-GIEONiadHbvK1hBX5BFk2XyLr-w/edit#slide=id.g23efec24c47_0_29) for **N-gram Language Model** 

* Now run the scirpt
    `./create_lm.sh`
    > Output of the script should show the number something like *0.064155 -0.020947*(values can very) but ensure first number is postitive and second is negative
    > ***Note :*** Before running the script again you might need to remove the following file and directories:
    
   `rm -rf data/lang data/local/lang data/local/temp  data/local/dict/lexiconp.txt`

# Create AM
* myrun.sh is used to train the Acoustic Model.
    * You can change the values of *sen* and *gauss* to find the optimum result 
        ```
       for sen in 400 500 600 700 800 900; do
            for gauss in 4 5 6 7 8 9 10; do
        ```
    * while rerunning the script you can skip the specific task by switching *1* to *0*
        ```
        mfcc=1
        mono=1
        tri1=1
        ```

    * parllel process can be increased or decreased by changing the *nj* value   
        ```
        decode_nj=4
        train_nj=4
        ```
    * change the sampling frequency to 8000 in *conf/mfcc.conf*
    `echo "--sample-frequency=8000" >> mfcc.conf`

* Run the myrun.sh

    `./myrun.sh`

    > ***Note :*** For DNN training, please run *run_dnn.sh* or *Run_tdnn_1i.sh* script.
    To run the scirpt in background use *nohup* or *screen*
    >
    >DNN Model will be stored in following path : 
    *asr_lab/exp/chain/tdnn1a_sp_online/*
    >
    >DNN graph will be present at
    */home/anchal/gst_nnet3_model/exp/chain/tree_sp/*
    >
    >View WER of DNN model
    */exp/chain/tdnn1a_sp_online/decode_<vocab>/decode_<test_set>/scoring_kaldi/best_wer*




# Decoding
*  Update the model path in *online_speech1.sh* to he model dir which has lower WER.

* create the test folder and place the recorded or test audio wav inside it
`mkdir test_audio`


* And run the following command 

    `./online_speech1.sh test_audio/ audio_name.wav`

    > ***Note :*** For DNN decoding, run the *online_speech_DNN.sh* script. use the following command.
    > `./online_speech_DNN.sh test_audio/ audio.wav`
    >
    >The transcribed text will appear on the the terminal and in *test_audio/recog.txt*
    If nothing appear you can check for error in log at *test_audio/out.txt*
    
    
  


# Handling errors

* ERROR: FstHeader::Read: Bad FST header: data/lang/G.fst - 

    > If you get this error then try to copy this file from /home/rushi/kaldi/src/lmbin/arpa2fst to /usr/bin. You can use the following command =>
    >`sudo cp ../../kaldi/src/lmbin/arpa2fst /usr/bin/`

* utils/validate_data_dir.sh: file data/train/utt2spk is not sorted or has duplicates    
   
    > ./utils/fix_data_dir.sh data/train/
    > ./utils/fix_data_dir.sh data/test/ 

* frequency mismatch : make sure you have added folowing line in conf/mfcc.conf
`sample-frequency=8000`
