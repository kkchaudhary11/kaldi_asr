copy files from *kalid/egs/wsj/s5/* \- `conf` `data` `local` `util` `steps` `cmd.sh` `path.sh`

scripts needed : `create_lm.sh` `make_graph.sh` `myrun.sh` `online_speech1.sh`

Update the **kaldi path** in *path.sh*

* * *

*/home/user/asr_lab/scripts* contains following files and folders:

- `cmd.sh`
- `conf`
- `create_lm.sh`
- `data`
- `local`
- `make_graph.sh`
- `myrun.sh`
- `online_speech1.sh`
- `path.sh`
- `steps`
- `utils`

* * *

`data` folder has following structure :

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

* * *

## Steps :

1\. Prepare data

> `$ ./easy-kaldi.sh --train train_data_folder`
> 
> `$ ./easy-kaldi.sh --test test_data_folder`

2\. Create lexicon

> `$  ./lm-tools_2.sh file_name`
> 
> output : *temp/tmp.parse*

3\. Create LM

update the **irstlm path** in *create_lm.sh*

> `./create_lm.sh`

4\. Train Model

> `./myrun.sh`

5\. Decode/Test audio

> `$ online_speech1.sh audio_folder audio_path`
